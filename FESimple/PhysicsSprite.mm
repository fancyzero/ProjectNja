//
//  PhysicsSprite.mm
//  ShotAndRun4
//
//  Created by Fancy Zero on 12-7-19.
//  Copyright __MyCompanyName__ 2012年. All rights reserved.
//


#import "PhysicsSprite.h"
#import "cocos2d.h"
#import "Box2D.h"
#import "GameBase.h"
#import "world.h"
#import "common.h"
#import "GameLayer.h"
#import "CCAnimateEx.h"

#pragma mark - PhysicsSprite

static NSMutableDictionary* anim_cache = nil;

void push_anim( CCAnimation* anim, NSString* for_sprite, NSString* anim_name )
{
    if ( anim_cache == nil )
        anim_cache = [[NSMutableDictionary dictionary] retain];
    [anim_cache setValue:anim forKey:[NSString stringWithFormat:@"%@::%@", for_sprite, anim_name]];
}

CCAnimation* get_anim( anim_sequence_def* def, NSString* for_sprite, NSString* anim_name )
{
    if ( anim_cache == nil )
        anim_cache = [[NSMutableDictionary dictionary]retain];
    CCAnimation* anim = [anim_cache valueForKey:[NSString stringWithFormat:@"%@::%@", for_sprite, anim_name]];
    if ( anim )
        return anim;
    NSMutableArray *Frames = [NSMutableArray array];//todo memory leak?
    CCSpriteFrame* frame;

    if ( [[def->filename pathExtension] isEqualToString:@"plist"] )
    {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:def->filename];
        NSArray* framenames = [def->frame_names componentsSeparatedByString:@","];
        for( int i=0; i < [framenames count]; i++ )
        {
            
            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[framenames objectAtIndex:i]];
            /*
             通过以上方法得来的frame 没有texture指针，之保存了贴图名
             每次setDisplayFrame时都要先执行一次texturecache addimage一次才行
             所以干脆就再创建这个frame之后，手动通过texturefilename设置texture指针，省的每次都要addimage一次
             */
            frame.texture = [[CCTextureCache sharedTextureCache] addImage:  [frame textureFilename]];
            //[frame.texture setAliasTexParameters];
            [Frames addObject:frame];
            //NSLog(@"frame ratain count:%d",[frame retainCount]);
        }
    }
    else
    {
        CCTexture2D* tex = [ [ CCTextureCache  sharedTextureCache ] addImage:def->filename];
        //[tex setAliasTexParameters];
        
        if ( def->animated )
        {
            for(int i = 0; i < def->frame_cnt; ++i)
            {
                frame = [ CCSpriteFrame frameWithTexture:tex rect:CGRectMake( (i%def->cells_per_line)*(def->cell_w+def->cell_pad_x),
                                                                             i/def->cells_per_line*(def->cell_h+def->cell_pad_y),
                                                                             def->cell_w, def->cell_h) ];
                [Frames addObject:frame];
            }
        }
        else
        {
            // TODO:  Inpixels or InPoints?
            frame = [ CCSpriteFrame frameWithTexture:tex rect:CGRectMake( 0,0, tex.contentSize.width, tex.contentSize.height )];
            //NSLog(@"frame ratain count:%d",[frame retainCount]);
            
            [Frames addObject:frame];
        }
    }
    anim = [CCAnimation animationWithSpriteFrames:Frames delay:def->frame_speed ];

    //NSLog(@"frames ratain count:%d",[Frames retainCount]);
    //[Frames release];

    push_anim( anim, for_sprite, anim_name );
    return anim;
}

@implementation PhysicsSprite

@synthesize m_mask_color = m_mask_color_;
@synthesize m_zorder = m_zorder_;
@synthesize m_offset = m_offset_;
@synthesize m_phy_body = m_phy_body_;
@synthesize m_color_override_endtime = m_color_override_endtime_;

float m_physics_loading_scale = 0.5;



+(void) set_physics_loading_scale:(float) s
{
    m_physics_loading_scale = s;
}

-(void) setM_position:(CGPoint)pos
{
	m_position_ = pos;
	[super setPosition:pos];
	[self set_physic_position: pos ];
}

-(CGPoint) m_position
{
	return m_position_;
}

-(void) setM_rotation:(float) rot
{
	m_rotation_ = rot;
	[super setRotation:rot];
	[self set_physic_rotation:rot ];
}

-(float) m_rotation
{
	return m_rotation_;
}

-(void) setPhysicsBody:(b2Body *)body
{
	m_phy_body_ = body;
}

-(void) init_shader
{
	CCGLProgram * p = [[CCShaderCache sharedShaderCache] programForKey:@"base_shader"];
	super.shaderProgram = p;
}

-(id) init
{
    self = [super init];
	m_anim_sequences_ = [ NSMutableDictionary new];
    m_mask_color_ = ccc4f(1.0,1.0,1.0,1.0);
	m_parent_ = NULL;
	m_component_def = NULL;

	m_color_override_endtime_ = 0;
	[self init_shader];
	[self reset_mask_color];
    return self;
}

-(int) init_by_sprite_component_def:(struct sprite_component_def*) def
{
	m_component_def = def;
	int ret;
	ret = [self init_physics: &def->m_phy_body ];
	if ( ret < 0 )
		return ret;

	ret = [ self init_animations: &def->m_spr_anim];
    [self play_anim_sequence:@"default"];
    //anchorPoint only can be set after animations has been loaded othough the anchorPointInPixel will be caculated wrong
    super.anchorPoint = def->m_phy_body.anchor_point;


	return ret;
}

-(void) play_anim_sequence:(NSString *)name
{
    if ( m_current_anim_sequence_ != NULL )
        [ self stopAction:m_current_anim_sequence_ ];
    
   // NSValue* seq_val = [ m_anim_sequences_ objectForKey:name ];
    CCAction* act = (CCAction*)[ m_anim_sequences_ objectForKey:name ];//(CCAction*)[seq_val pointerValue ];
        
	m_current_anim_sequence_ = act;
	[ self runAction:act];
}
-(int) init_animations:(spr_anim_def*) anims
{
	
	for ( ANIM_SEQUENCES::iterator it = anims->m_anim_sequences.begin(); it != anims->m_anim_sequences.end(); ++it )
	{
        CCAnimation* anim = get_anim( &(*it), m_component_def->m_name, (*it).anim_name);
		//NSLog(@"frames ratain count:%d",[act retainCount]);
		//seq->act = act;
        CCAction* act;
        if ( it->repeat_count <= 0 )
        {
            act = [CCRepeatForever actionWithAction:[CCAnimateEx actionWithAnimation:anim ]];
        }
        else
        {
            act = [CCRepeat actionWithAction:[CCAnimateEx actionWithAnimation:anim ] times:it->repeat_count];
        }

		[m_anim_sequences_ setObject:act forKey:(*it).anim_name ];//todo use another struct to save actions
	}
	return 0;
	
}



-(void) clear_physics
{
	GameBase* game = [ GameBase get_game];

    std::vector<fixture_data*> fixes;
	if ( m_phy_body_ != NULL )
	{
        b2Fixture* fix = m_phy_body_->GetFixtureList();
        while( fix )
        {
            fixture_data* d = (fixture_data*)fix->GetUserData();
            fixes.push_back(d);
            fix = fix->GetNext();
        }
        
		game.m_world.m_physics_world->DestroyBody(m_phy_body_);
	}
    for( std::vector<fixture_data*>::iterator it = fixes.begin(); it != fixes.end(); ++it )
    {
        if ( *it != nil )
        {
            //NSLog(@"%p deleted", *it);
            delete *it;
        }
    }
	m_phy_body_ = nil;
	
}

-(int) init_physics:(phy_body_def*) def
{
	//super.anchorPoint = def->anchor_point; 此时还没有加载贴图，设置anchorPoint是无意义的
    
	if (def->m_phy_shapes.size() <= 0 )
		return 0;
	
	GameBase* game = [ GameBase get_game];
	
	float ptm = [ GameBase get_ptm_ratio];
	[ self clear_physics];
	//delete all fixturedef first



	b2BodyDef bodydef;

	bodydef.type = (b2BodyType)def->type;

	
	bodydef.position = b2Vec2( (m_position_.x + def->offset.x )/[GameBase get_ptm_ratio], (m_position_.y+def->offset.y)/[GameBase get_ptm_ratio] );
	bodydef.angle = CC_DEGREES_TO_RADIANS(m_rotation_);
	//b2Body* bdy1 = game.m_world.m_physics_world->CreateBody(&bodydef);
    b2Body* bdy = game.m_world.m_physics_world->CreateBody(&bodydef);
    //game.m_world.m_physics_world->DestroyBody(bdy1);
	
	PHY_SHAPES::const_iterator it2 = def->m_phy_shapes.begin();
	for( ; it2 !=  def->m_phy_shapes.end(); ++it2 )
	{
		const phy_shape_def* s;
		b2Shape* b2s;
		s = &(*it2);
		
		b2CircleShape cs;
		b2PolygonShape ps;
		if ( s->type == pst_circle )
		{
			cs.m_type = b2Shape::e_circle;
			cs.m_radius = s->radius * scaleX_ * m_physics_loading_scale / ptm;
			cs.m_p.x = s->offset_x * scaleX_ * m_physics_loading_scale / ptm;
			cs.m_p.y = s->offset_y * scaleY_ * m_physics_loading_scale / ptm;
			b2s = &cs;
		}
		else if ( s->type == pst_box)
		{
			ps.SetAsBox(s->w * scaleX_ * m_physics_loading_scale / ptm, s->h * scaleY_ * m_physics_loading_scale / ptm,b2Vec2(s->offset_x*scaleX_*m_physics_loading_scale/ptm,s->offset_y*scaleY_*m_physics_loading_scale/ptm), s->rotation);
			ps.m_type = b2Shape::e_polygon;
			b2s = &ps;
		}
		else if ( s->type == pst_polygon)
		{
			ps.m_type = b2Shape::e_polygon;
			b2Vec2* vecs = new b2Vec2[s->float_array.size()/2];
			b2Vec2* p = vecs;
			for( std::vector<float>::const_iterator i = s->float_array.begin(); i != s->float_array.end(); )
			{
				p->x = (*i)* scaleX_*m_physics_loading_scale/ptm;
				++i;
				p->y = (*i)* scaleY_*m_physics_loading_scale/ptm;
				++i;
				p++;
			}
			ps.Set(vecs, s->float_array.size()/2);
			b2s = &ps;
			delete[] vecs;
		}
		b2FixtureDef fixtureDef;
		fixtureDef.shape = b2s;
		fixtureDef.isSensor = s->is_sensor;
        fixture_data* data = new fixture_data();
        data->identity = s->identity;
        data->sprite = self;
		fixtureDef.userData = data;
		fixtureDef.density = s->density;
        fixtureDef.restitution = def->restitution;
		bdy->CreateFixture(&fixtureDef);
		bdy->SetAwake(true);
	}
	m_phy_body_	= bdy;
	return 0;
}



// this method will only get called if the sprite is batched.
// return YES if the physics values (angles, position ) changed
// If you return NO, then nodeToParentTransform won't be called.
-(BOOL) dirty
{
    if ( m_phy_body_ == NULL )
		return super.dirty;
	return YES;
}

-(void) draw
{
//	CGRect rc = self.layer_bounding_box;
//	rc.origin = ccpMult(rc.origin, [ self get_layer].m_move_scale );
	CGRect rc;
	rc.size = [CCDirector sharedDirector].winSize;
	rc.origin = ccp(0,0);
	if ( !CGRectIntersectsRect(rc, self.world_bounding_box ) )
		return;
	//if ( is_outof_acting_range(self.m_position, self.boundingBox ))
	//	return;
	CC_PROFILER_START_CATEGORY(kCCProfilerCategorySprite, @"CCSprite - draw");
    
	NSAssert(!batchNode_, @"If CCSprite is being rendered by CCSpriteBatchNode, CCSprite#draw SHOULD NOT be called");
    
	CC_NODE_DRAW_SETUP();
    
	ccGLBlendFunc( blendFunc_.src, blendFunc_.dst );
    
	ccGLBindTexture2D( [texture_ name] );
    
	//
	// Attributes
	//
    
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_PosColorTex | kCCVertexAttribFlag_MaskColor );
    
#define kQuadSize sizeof(quad_.bl)
	long offset = (long)&quad_;
    
	// vertex
	NSInteger diff = offsetof( ccV3F_C4B_T2F, vertices);
	glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, kQuadSize, (void*) (offset + diff));
    
	// texCoods
	diff = offsetof( ccV3F_C4B_T2F, texCoords);
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, (void*)(offset + diff));
    
	// color
	diff = offsetof( ccV3F_C4B_T2F, colors);
	glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, (void*)(offset + diff));
    
	// mask color
	diff = offsetof( ccV3F_C4B_T2F, mask_colors);
	glVertexAttribPointer(kCCVertexAttrib_MaskColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, (void*)(offset + diff));
    
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
	CHECK_GL_ERROR_DEBUG();
    
    
#if CC_SPRITE_DEBUG_DRAW == 1
	// draw bounding box
	CGPoint vertices[4]={
		ccp(quad_.tl.vertices.x,quad_.tl.vertices.y),
		ccp(quad_.bl.vertices.x,quad_.bl.vertices.y),
		ccp(quad_.br.vertices.x,quad_.br.vertices.y),
		ccp(quad_.tr.vertices.x,quad_.tr.vertices.y),
	};
	ccDrawPoly(vertices, 4, YES);
#elif CC_SPRITE_DEBUG_DRAW == 2
	// draw texture box
	CGSize s = self.textureRect.size;
	CGPoint offsetPix = self.offsetPosition;
	CGPoint vertices[4] = {
		ccp(offsetPix.x,offsetPix.y), ccp(offsetPix.x+s.width,offsetPix.y),
		ccp(offsetPix.x+s.width,offsetPix.y+s.height), ccp(offsetPix.x,offsetPix.y+s.height)
	};
	ccDrawPoly(vertices, 4, YES);
#endif // CC_SPRITE_DEBUG_DRAW
    
	CC_INCREMENT_GL_DRAWS(1);
    
	CC_PROFILER_STOP_CATEGORY(kCCProfilerCategorySprite, @"CCSprite - draw");
}

-(void) set_shader_parameter:(const GLchar*)name param_f1:(float) f1
{
    GLint loc = glGetUniformLocation( shaderProgram_->program_, name);
    if ( loc >=0 )
        [ shaderProgram_ setUniformLocation:loc withF1:f1];
}

-(void) set_shader_parameter:(const GLchar*)name param_color:(ccColor4F) c
{
    GLint loc = glGetUniformLocation( shaderProgram_->program_, name);
    if ( loc >= 0 )
        [ shaderProgram_ setUniformLocation:loc withF1:c.r f2:c.g f3:c.b f4:c.a];
}
// returns the transform matrix according the Physics Body values
-(CGAffineTransform) nodeToParentTransform
{
    if ( m_phy_body_ == NULL )
    {
        return [ super nodeToParentTransform ];
    }
	b2Vec2 pos  = m_phy_body_->GetPosition();
	
	float x = pos.x * [GameBase get_ptm_ratio];
	float y = pos.y * [GameBase get_ptm_ratio];
	
	if ( ignoreAnchorPointForPosition_ )
	{
		x += anchorPointInPoints_.x;
		y += anchorPointInPoints_.y;
	}
	
	// Make matrix
	float radians = m_phy_body_->GetAngle();
	float c = cosf(radians);
	float s = sinf(radians);
	
	if( ! CGPointEqualToPoint(anchorPointInPoints_, CGPointZero) ){
		x += c*-anchorPointInPoints_.x*scaleX_ + -s*-anchorPointInPoints_.y*scaleY_;
		y += s*-anchorPointInPoints_.x*scaleX_ + c*-anchorPointInPoints_.y*scaleY_;
	}
	
	// Rot, Translate Matrix
	transform_ = CGAffineTransformMake( c*scaleX_,  s*scaleX_,
									   -s*scaleY_,	c*scaleY_,
									   x,	y );
	
	return transform_;
}

-(void) update_mask_color;
{
	ccColor4B clr;
	clr. r = m_mask_color_.r * 255;
	clr. g = m_mask_color_.g * 255;
	clr. b = m_mask_color_.b * 255;
	clr. a = m_mask_color_.a * 255;
	quad_.bl.mask_colors = clr;
	quad_.br.mask_colors = clr;
	quad_.tl.mask_colors = clr;
	quad_.tr.mask_colors = clr;
	// renders using batch node
	if( batchNode_ ) {
		if( atlasIndex_ != CCSpriteIndexNotInitialized)
			[textureAtlas_ updateQuad:&quad_ atIndex:atlasIndex_];
		else
			// no need to set it recursively
			// update dirty_, don't update recursiveDirty_
			dirty_ = YES;
	}
}

-(void) reset_mask_color;
{
	[self set_color_override:ccc4f(0,0,0,0) duration:3600*24*7 ];
	[self update_mask_color];
	
}
-(void) dealloc
{
	[ self clear_physics];
	//NSLog(@"m_anim_sequences_ retaincount %d:",[ m_anim_sequences_ retainCount]);
    //NSLog(@"%@ dealloc",self);
	[ m_anim_sequences_ release];
	[super dealloc];
}
-(void)set_physic_position:(CGPoint) pos
{
    if ( m_phy_body_ == NULL )
        return;
	
    m_phy_body_->SetTransform( b2Vec2(pos.x/[ GameBase get_ptm_ratio ],pos.y/[ GameBase get_ptm_ratio ]), m_phy_body_->GetAngle() );
    m_phy_body_->SetAwake(TRUE);
}
-(void)set_physic_angular_velocity:(float) v
{
    if ( m_phy_body_ != NULL)
    {
        m_phy_body_->SetAngularVelocity(CC_DEGREES_TO_RADIANS(v) );
    }
}

-(void) set_physic_fixed_rotation: (bool) fixed
{
	if ( m_phy_body_ != NULL)
		m_phy_body_->SetFixedRotation(fixed);
}
-(void)set_physic_angular_damping:(float) d
{
	if ( m_phy_body_ != NULL)
        m_phy_body_->SetAngularDamping(d);
}

-(void) set_physic_linear_velocity: (float)x :(float)y
{
	if ( m_phy_body_ != NULL)
        m_phy_body_->SetLinearVelocity( b2Vec2(x, y));
}

-(void) apply_impulse_at_world_location:(float)speed_x :(float)speed_y :(float) loc_x :(float) loc_y
{
	if ( m_phy_body_ != NULL)
		m_phy_body_->ApplyLinearImpulse(b2Vec2(speed_x, speed_y), b2Vec2(loc_x,loc_y));
}

-(void) apply_impulse:(float)speed_x :(float)speed_y
{
	if ( m_phy_body_ != NULL)
		m_phy_body_->ApplyLinearImpulse(b2Vec2(speed_x, speed_y), m_phy_body_->GetPosition());
}

-(float) get_physic_mass
{
    if ( m_phy_body_ != NULL )
        return m_phy_body_->GetMass();
    else
        return 0;
}

-(void) apply_force_center:(float)force_x force_y:(float)force_y
{
	if ( m_phy_body_ != NULL)
		m_phy_body_->ApplyForce(b2Vec2(force_x, force_y), m_phy_body_->GetPosition() );
}
-(void) apply_angular_impulse:(float)angular_impulse
{
 	if ( m_phy_body_ != NULL)
		m_phy_body_->ApplyAngularImpulse(CC_DEGREES_TO_RADIANS(angular_impulse));
}

-(void) apply_torque:(float)t
{
	if ( m_phy_body_ != NULL)
		m_phy_body_->ApplyTorque(t);
}

-(void) clamp_physic_maxspeed: (float) max_speed
{
	if ( m_phy_body_ != NULL)
	{
		b2Vec2 v = m_phy_body_->GetLinearVelocity();
		b2Vec2 dir = v;
		dir.Normalize();
		float len = v.Length();
		if ( len > max_speed )
			len = max_speed;
		dir *= len;
		m_phy_body_->SetLinearVelocity(dir);
	}
}

-(void) set_physic_torque:(float) torque
{
    if ( m_phy_body_ != NULL )
        m_phy_body_->ApplyTorque(torque);
}

-(void) set_physic_linear_damping :(float) damping
{
	if ( m_phy_body_ != NULL )
		m_phy_body_->SetLinearDamping(damping);
}
-(void) set_physic_rotation:(float) angle
{
    if ( m_phy_body_ != NULL )
	{
		b2Vec2 pos = m_phy_body_->GetPosition();
		
		m_phy_body_->SetTransform( pos, CC_DEGREES_TO_RADIANS(angle) );
		m_phy_body_->SetAwake(TRUE);
	}
}
-(float) get_physic_angular_velocity
{
	if ( m_phy_body_ != NULL)
	{
		return CC_RADIANS_TO_DEGREES(m_phy_body_->GetAngularVelocity());
	}
	else
	{
		return 0;
	}
}
-(CGPoint) get_physic_linear_velocity
{
	CGPoint ret;
	ret.x = ret.y = 0;
	if ( m_phy_body_ != NULL )
	{
		ret.x = m_phy_body_->GetLinearVelocity().x;
		ret.y = m_phy_body_->GetLinearVelocity().y;
		return ret;
	}
	else
	{
		return ret;
	}
}
-(void) set_physic_friction:(float) f
{
	if ( m_phy_body_ )
	{
		b2Fixture* fix = m_phy_body_->GetFixtureList();
		while (fix)
		{
            fix->SetFriction(f);
			fix = fix->GetNext();
		}
        
	}
}

-(void) set_physic_restitution:(float) r
{
	if ( m_phy_body_ )
	{
		b2Fixture* fix = m_phy_body_->GetFixtureList();
		while (fix)
		{
            fix->SetRestitution(r);
			fix = fix->GetNext();
		}
        
	}
}

-(CGPoint) get_physic_position
{
	if ( m_phy_body_ == NULL)
	{
		CGPoint ret;
		ret.x = ret.y = 0;
		return ret;
	}
	float ptm = [ GameBase get_ptm_ratio];
	CGPoint ret;
	ret.x = m_phy_body_->GetPosition().x*ptm;
	ret.y = m_phy_body_->GetPosition().y*ptm;
	return ret;
}
-(float) get_intertia
{
    if ( m_phy_body_ == NULL )
    return 0;
    return m_phy_body_->GetInertia();
}
-(float) get_physic_rotation
{
	if ( m_phy_body_ == NULL )
		return 0;
	return m_phy_body_->GetAngle()/0.01745329252f;
}

-(void) sync_physic_to_sprite
{
	if ( m_phy_body_ != NULL )
	{
		m_position_ = [ self get_physic_position];
		m_rotation_ = [ self get_physic_rotation];
		[self setPosition:m_position_];
		[self setRotation:m_rotation_];

	}
	
}

-(void) set_collision_filter:(int)mask  cat:(int) cat
{
	if ( m_phy_body_ )
	{
		b2Fixture* fix = m_phy_body_->GetFixtureList();
		while (fix)
		{
			b2Filter ft;
			ft.maskBits = mask;
			ft.categoryBits = cat;
			ft.groupIndex = 0;
			
			fix->SetFilterData(ft);
			fix = fix->GetNext();
		}

	}
}

struct fixture_def
{
	b2Filter filter;
};

-(void) set_scale:(float) scalex :(float)scaley
{
	super.scaleX = scalex;
	super.scaleY = scaley;

	if ( (m_component_def != NULL) )
	{
		//back up some data
		std::vector<fixture_def> fixture_def_backup;
		b2Vec2	velocity_speed;
		float	angular_speed;
		if ( m_phy_body_ != NULL)
		{
			b2Fixture* f = m_phy_body_->GetFixtureList();

			velocity_speed = m_phy_body_->GetLinearVelocity();
			angular_speed = m_phy_body_->GetAngularVelocity();
			
			while( f != NULL )
			{
				fixture_def fdef;
				fdef.filter = f->GetFilterData();
				fixture_def_backup.push_back(fdef);
				f = f->GetNext();
			}
		}
       bool dolog = false;
        if ( m_phy_body_ != NULL )
            dolog = true;
        //if (dolog)
        //NSLog(@"body before reinit:%p fixture: %p",m_phy_body_, m_phy_body_->GetFixtureList());
		[ self init_physics: &m_component_def->m_phy_body];
                //if (dolog)
        //NSLog(@"body after reinit:%p fixture: %p",m_phy_body_,m_phy_body_->GetFixtureList());
		if ( m_phy_body_ != NULL)
		{
			b2Fixture* f = m_phy_body_->GetFixtureList();
			int idx = 0;
			while( f != NULL )
			{
				if ( idx > fixture_def_backup.size())
					break;
				f->SetFilterData(fixture_def_backup[idx].filter);
				f = f->GetNext();
				idx ++;
			}
			m_phy_body_->SetLinearVelocity(velocity_speed);
		}
	}
}

-(void) set_color_override :( ccColor4F ) color duration:(float) duration
{

	if ( m_mask_color_.r != color.r ||   m_mask_color_.g != color.g ||  m_mask_color_.b != color.b || m_mask_color_.a != color.a )
	{
		m_mask_color_ = color;
		[self update_mask_color ];
	}
	m_color_override_endtime_ = duration + current_game_time();
}

-(CGRect) world_bounding_box
{
	CGRect rect = CGRectMake(0, 0, contentSize_.width, contentSize_.height);
	return CGRectApplyAffineTransform(rect, [self nodeToWorldTransform]);
}

-(CGRect) layer_bounding_box
{
	CGRect rect = CGRectMake(0, 0, contentSize_.width, contentSize_.height);
	CGAffineTransform t = convert_transform_to_layer_space(self);
	return CGRectApplyAffineTransform( rect, t );
}

-(GameLayer*) get_layer
{
	CCNode *p ;
	for ( p = self.parent; p != nil; p = p.parent)
	{
		if ( [p isKindOfClass: [GameLayer class]] )
			break;
	}
	return (GameLayer*)p;
}

-(CCAction*) get_current_anim_sequence
{
    return m_current_anim_sequence_;
}
@end

