//
//  SpriteBase.m
//  testproj1
//
//  Created by Fancy Zero on 12-3-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#include "Box2D.h"
#import "SpriteBase.h"
#import "CCSprite.h"

#import "Common.h"
#import "Simpleaudioengine.h"
#include <vector>
#import "SpriteDefManager.h"
#import "Level.h"
#import "World.h"
#import "Custom_Interfaces.h"
#import "CollisionListener.h"
#import "GameLayer.h"
#import "SpriteProxy.h"
#import "GameBase.h"



unsigned long long g_sprite_uid = 0;
@implementation SpriteBase 

@synthesize m_position;
@synthesize m_zorder;
@synthesize m_rotation;
@synthesize m_scale;
@synthesize m_color;
@synthesize m_health;
@synthesize m_spawned_time;
@synthesize m_time_before_remove_outof_actrange = m_time_before_remove_outof_actrange_;
@synthesize m_max_health =m_max_health_;

-(CGPoint) m_position
{
	if ( m_sprite_components.size()>0 )
		return m_sprite_components[0].m_position;
	else
		return ccp(0,0);
}
//@synthesize m_root_node = m_root_node_;
-(int) init_default_values
{
	[super init_default_values];
	m_batchable = false;
    m_spawned_time = [GameBase current_time];
	if ( [ GameBase get_game ].m_level != NULL )
		m_spawned_progress_ = [ GameBase get_game ].m_level.m_level_progress;
	else
		m_spawned_progress_ = 0;

    m_dead = false;
    m_scale = 1.0f;
	m_dead_on_health_empty = true;
	m_scalex = 1;
	m_scaley = 1;
	m_removed = false;
	m_time_before_remove_outof_actrange_ = 10;
	m_been_in_range_ = false;
	m_time_outof_actrange_ = 0;
	m_blink_end_time_ = 0;
	m_visible_set_ = 0;
    m_hitproxy_ = NULL;
	//m_root_node_ = [CCNode node];

	return 0;
}
-(id) init
{
    self = [ super init ];
	[ self init_default_values];
    m_uid = g_sprite_uid++;
    return self;
}


-(id) init_with_spawn_params:(NSDictionary*) params
{
	
	self = [super init_with_spawn_params:params];//self init_default_values 必须在self 被附直后才能使用
	[ self init_default_values];
	sprite_spawn_param spawn_params;//TODO 删除这个临时变量，全部从params 中直接读取
	::load_sprite_spawn_param( &spawn_params, params );

	CGPoint init_pos;
	if ( !spawn_params.init_pos_rel_act )
		init_pos = spawn_params.init_position;
	else
	{
		init_pos = current_acting_range().origin;
		init_pos = ccpAdd(init_pos, spawn_params.init_position);
		
	}
	[self set_position:init_pos.x y:init_pos.y];
	[self set_rotation:spawn_params.init_rotation];
	[self set_scale:spawn_params.init_scale :spawn_params.init_scale];
	[self set_rotation:spawn_params.init_rotation];
	[self init_with_xml:spawn_params.sprite_desc];

	[ self set_zorder:spawn_params.init_zorder];
	m_batchable = read_bool_value(params, @"batchable",false);
	self.m_max_health = read_float_value(params, @"init_max_health",0);
	self.m_health = read_float_value(params, @"init_health",0);


//	[self read_sprite_spawn_param: params ];
    return self;
}

-(void) dead
{
    if ( m_dead == true )
        return;
    m_dead = true;
    
    LevelBase* lvl;
    lvl = [GameBase get_game].m_level;
    if ( lvl != NULL )
    {
        [lvl on_sprite_dead:self];
    }
}
-(bool) isdead
{
    return m_dead;
}

-(void) cleanup
{
	for ( SPRITECOMPONENTS::iterator it = m_sprite_components.begin(); it != m_sprite_components.end(); ++it )
	{
		if ( (*it) )
			[ *it release];
	}
	m_sprite_components.clear();
	
	for ( DROPDESCS::iterator it = m_drop_descs.begin(); it != m_drop_descs.end(); ++it )
	{
		if ( (*it).params != NULL )
			[(*it).params release];
		if ( (*it).spriteclass != NULL )
			[(*it).spriteclass release];
		
	}
	m_drop_descs.clear();
    [m_hitproxy_ release];
    m_hitproxy_ = NULL;
	//[m_root_node_ release];
	//m_root_node_ = NULL;
    //GameSad* game = [ GameBase get_game ];
    //NSLog( @"%@ : m_physics_body = %p", self, m_physics_body);
}
//int j = 0;
-(void) dealloc
{
    GameBase* game = [ GameBase get_game ];
    //if ( game.m_DBG_loop_stat <= 1 )
    //{
    //    j++;
    //}
    assert( game.m_DBG_loop_stat > 1 );
    //NSLog( @"%@ : %@ destroyed.", self, self.m_name );
    [ self cleanup];
    [super dealloc];

}
-(int) collied_with:(SpriteBase *)other :(Collision*) collision
{
    //NSLog( @"%@ collied with %@", self.m_name, other.m_name );
    return 0;
}


-(void) set_position: (float)x y:(float)y
{
    m_position.x = x;
    m_position.y = y;
	for ( SPRITECOMPONENTS::iterator it = m_sprite_components.begin(); it != m_sprite_components.end(); ++it )
	{
		CGPoint pos = m_position;

		if ( (*it) )
		{
			pos.x += (*it).m_offset.x;
			pos.y += (*it).m_offset.y;
			(*it).m_position = pos;
		}
	}
	//[m_root_node_ setPosition:m_position];
}

-(void) set_rotation:(float)rotat
{
	m_rotation = rotat;
	for ( SPRITECOMPONENTS::iterator it = m_sprite_components.begin(); it != m_sprite_components.end(); ++it )
	{
		
		if (*it)
		{
			[(*it) setRotation:rotat];
			[(*it) set_physic_rotation:rotat];
		}
	}
	
	//[m_root_node_ setRotation:-rotat];
}

-(void) set_scale:(float) scalex :(float) scaley
{
	m_scalex = scalex;
	m_scaley = scaley;
	for ( SPRITECOMPONENTS::iterator it = m_sprite_components.begin(); it != m_sprite_components.end(); ++it )
	{
		
		if (*it)
		{
			[(*it) set_scale:scalex :scaley];
		}
	}
}

-(void) set_zorder: (int)z
{
    m_zorder = z;
	for ( SPRITECOMPONENTS::iterator it = m_sprite_components.begin(); it != m_sprite_components.end(); ++it )
	{
		
		if (*it)
		{
			[(*it) setZOrder:z];
		}
	}
}

-(int) post_init
{
	return 0;
}

-(void) add_drop_desc:(drop_desc) desc
{
	[desc.params retain];
	[desc.spriteclass retain];
	m_drop_descs.push_back(desc);
}

-(int) init_with_xml:(NSString *)filename
{
	float ptm = [GameBase get_ptm_ratio];
    sprite_def* sdef = [ SpriteDefManager load_sprite_def:filename];
	
	for ( SPRITEPARTDEFS::iterator it = sdef->m_parts.begin(); it != sdef->m_parts.end(); ++it )
	{
		PhysicsSprite* spr = [PhysicsSprite new ];
		spr.m_parent = self;


        sprite_component_def* scdef = [ SpriteDefManager load_sprite_component_def:(*it).m_desc];

        //set scale and position before creating physic body
        //此处的offset决定了这个part创建时，距离SpriteBase坐标的偏移
		spr.m_position = ccpAdd( m_position, (*it).m_offset );
		spr.m_rotation = m_rotation;
		if ( m_scalex <= 0 )
			m_scalex = 1;
		if ( m_scalex <= 0 )
			m_scalex = 1;
		spr.scaleX = m_scalex;
		spr.scaleY = m_scaley;
        
		[ spr init_by_sprite_component_def: scdef ];
        assert( (spr.m_position.y == ccpAdd( m_position, (*it).m_offset ).y) &&  (spr.m_position.x == ccpAdd( m_position, (*it).m_offset ).x) );
		/*
         set position and rotation again after calling initxxxx,
         because the ccnode init will reset the position_ to {0,0} if this sprite have no physics body
         */
		
         spr.m_position = ccpAdd( m_position, (*it).m_offset ) ;
         spr.m_rotation = m_rotation;
         spr.scaleX = m_scalex;
         spr.scaleY = m_scaley;
         
		
		m_sprite_components.push_back(spr);
		
		
		//[m_root_node_ addChild:spr];
	}
	for ( SPRITEJOINTDEFS::iterator it = sdef->m_joints.begin(); it != sdef->m_joints.end(); ++it )
	{
		if ( (*it).joint_type == e_revoluteJoint )
		{
			b2RevoluteJointDef joint;
			PhysicsJoint pj;
			int idxa = (*it).component_a;
			int idxb = (*it).component_b;
			
			joint.Initialize(m_sprite_components[idxa].m_phy_body, m_sprite_components[idxb].m_phy_body, b2Vec2(m_sprite_components[idxb].m_position.x/ptm, m_sprite_components[idxb].m_position.y/ptm));
			joint.enableLimit = (*it).joint_flags[0];
			joint.upperAngle = CC_DEGREES_TO_RADIANS( (*it).joint_params[0] );
			joint.lowerAngle = CC_DEGREES_TO_RADIANS( (*it).joint_params[1] );
			pj.m_b2Joint =	[GameBase get_game].m_world.m_physics_world->CreateJoint(&joint);
			
			m_physic_joints.push_back(pj);
		}
	}
	[self post_init];
    return 1;
}
-(bool) is_blinking
{
	return m_blink_end_time_ > current_game_time();
}

-(void) blink:(float)duration
{
	m_blink_end_time_ = current_game_time() + duration;
}

-(void) play_anim_sequence:(NSString *)name
{
}

-(void) set_physic_friction:(float) f
{
	for ( SPRITECOMPONENTS::iterator it = m_sprite_components.begin(); it != m_sprite_components.end(); ++it )
	{
		
		if (*it != NULL )
		{
			[(*it) set_physic_friction: f];
		}
	}
}

-(void) set_physic_restitution:(float) r
{
	for ( SPRITECOMPONENTS::iterator it = m_sprite_components.begin(); it != m_sprite_components.end(); ++it )
	{
		
		if (*it != NULL )
		{
			[(*it) set_physic_restitution: r];
		}
	}
}

-(void) set_collision_filter:(int)mask  cat:(int) cat
{
	for ( SPRITECOMPONENTS::iterator it = m_sprite_components.begin(); it != m_sprite_components.end(); ++it )
	{
		
		if (*it != NULL )
		{
			[(*it) set_collision_filter:mask cat:cat];
		}
	}
}



-(void) setM_color:(ccColor4B)color
{
    ccColor3B tmpc;
    tmpc.r = color.r;
    tmpc.g = color.g;
    tmpc.b = color.b;
	//todo
	for ( SPRITECOMPONENTS::iterator it = m_sprite_components.begin(); it != m_sprite_components.end(); ++it )
	{
		
		(*it).color = tmpc;
		(*it).opacity = color.a;
	}

}

-(ccColor4B) m_color
{
    ccColor4B tempc;
	//todo
    return tempc;
}

-(void) set_color_override :( ccColor4F ) color   duration:(float) duration
{
	for ( SPRITECOMPONENTS::iterator it = m_sprite_components.begin(); it != m_sprite_components.end(); ++it )
	{
		[ (*it) set_color_override :color  duration:duration];
	}
}

-(void) init_shader
{

}

-(void) sync_physic_to_sprite
{
	for ( SPRITECOMPONENTS::iterator it = m_sprite_components.begin(); it != m_sprite_components.end(); ++it )
	{
		[(*it) sync_physic_to_sprite];
	}
}

-(void) set_visible:(bool) visible :(unsigned int) flag
{
	unsigned int old_vis_set = m_visible_set_;
	if ( !visible )
		m_visible_set_ |= flag;
	else
		m_visible_set_ &= ~flag;
	
	if ( old_vis_set != m_visible_set_)
	{
		
		if( m_visible_set_ != 0)
		{
			for ( SPRITECOMPONENTS::iterator it = m_sprite_components.begin(); it != m_sprite_components.end(); ++it )
			{
				[(*it) setVisible:false];
			}
		}
		else
		{
			for ( SPRITECOMPONENTS::iterator it = m_sprite_components.begin(); it != m_sprite_components.end(); ++it )
			{
				[(*it) setVisible:true];
			}
		}
	}
}
-(void) ed_update:(float)delta_time
{
	[ self sync_physic_to_sprite];
}
-(void) update : (float)delta_time
{
	[ self sync_physic_to_sprite];
	if (  m_time_before_remove_outof_actrange_ > 0 && m_sprite_components.size() > 0)
	{
		if ( m_time_before_remove_outof_actrange_ > 0 && m_been_in_range_ &&  m_time_outof_actrange_ > m_time_before_remove_outof_actrange_ )
		{
			[self remove_from_game:true];
		}
		//CGRect bb = m_sprite_components[0].boundingBox;
		//float rad = bb.size.width;
		//if ( rad < bb.size.height)
		//	rad = bb.size.height;
		//TODO: can this be optimized??
		CGRect rc = m_sprite_components[0].layer_bounding_box;

		bool outofrange = is_outof_acting_range(self.m_position, rc, [m_sprite_components[0] get_layer].m_move_scale  );
		if ( outofrange && m_been_in_range_ )
			m_time_outof_actrange_ += delta_time;
		if ( !outofrange )
			m_been_in_range_ = true;
	}
	if ( m_blink_end_time_ > current_game_time())
	{
		float d = (m_blink_end_time_ - current_game_time());
		if ( sinf(d*3.14*10) < 0 )
			[ self set_visible:false :2];
		else
			[ self set_visible:true :2];
	}
	else
	{
		[ self set_visible:true :2];
	}
	
	for ( SPRITECOMPONENTS::iterator it = m_sprite_components.begin(); it != m_sprite_components.end(); ++it )
	{
		float curtime = current_game_time();
		if ( curtime > (*it).m_color_override_endtime )
			[ (*it) reset_mask_color ];
	}

}

//logic
-(void) apply_damage:(float) dmg collision:(struct Collision*) collision
{
	float last_health = m_health;
    m_health -= dmg;
    float real_dmg = dmg;
    LevelBase* lvl = [GameBase get_game].m_level;
    
    PhysicsSprite* sprite_comp_A = (PhysicsSprite*)collision->fixtureA->GetUserData();
    PhysicsSprite* sprite_comp_B = (PhysicsSprite*)collision->fixtureB->GetUserData();
    

    if ( last_health > 0 && m_health <= 0)
    {
        [ self on_health_empty];
        real_dmg = last_health;
    }
    else
    {
        SimpleAudioEngine* eng = [SimpleAudioEngine sharedEngine];
        [ eng playEffect:@"sfx/hit1.wav"];
		
        
		if ( sprite_comp_A.m_parent == self )
			[ sprite_comp_A set_color_override:ccc4f(1,1,1,0.5)  duration:0.1];
		if ( sprite_comp_B.m_parent == self )
			[ sprite_comp_B set_color_override:ccc4f(1,1,1,0.5)  duration:0.1];
    }
    SpriteBase* damage_origin = NULL;
    //TODO: 这个功能应该移动到子类里
    if ( sprite_comp_A.m_parent == self )
        damage_origin = sprite_comp_B.m_parent;
    else
        damage_origin = sprite_comp_A.m_parent;

    [lvl add_dps: dmg :[damage_origin get_owner]];
}

-(void) random_drop
{
	if ( m_drop_descs.size() > 0 )
	{
		int idx = rand()% m_drop_descs.size();
		drop_desc desc = m_drop_descs[idx];
		NSString* clsname = NULL;
		NSMutableDictionary* params = NULL;

		clsname = desc.spriteclass;
		params = [NSMutableDictionary dictionaryWithDictionary:desc.params ];
		
		SpriteBase* spr = (SpriteBase*)[[GameBase get_game] add_game_obj_by_classname:clsname spawn_params:params];
		[spr set_position:self.m_position.x y:self.m_position.y];
		//[params release];
	}
}

- (void) on_health_empty
{
	[self random_drop ];
}

-(void) remove_from_game:(bool) dead
{
	//assert(!m_removed);
    if ( dead )
        [self dead];
	if ( !m_removed )
	{
		m_removed=true;
		
		GameBase* game = [GameBase get_game];
		[ game.m_world remove_gameobj:self];
		[ self release ];
	}

}


-(PhysicsSprite*)	m_first_sprite
{
	if ( m_sprite_components.size() > 0 )
		return m_sprite_components[0];
	else
		return NULL;
}

-(int) sprite_components_count
{
	return (int)m_sprite_components.size();
}
-(PhysicsSprite*) get_sprite_component: (int) index
{
	if ( m_sprite_components.size() > index )
	{
		return m_sprite_components[index];
	}
	else
		return NULL;
}

-(CGPoint) get_physic_position:(int) component
{
	if ( m_sprite_components.size() > component )
		return [m_sprite_components[component] get_physic_position];
    else
        return ccp(0,0);
}

-(void) set_physic_position:(int) component :(CGPoint) pos
{
	if ( m_sprite_components.size() > component )
		[m_sprite_components[component] set_physic_position: pos];
}
-(void) set_physic_angular_velocity:(int) component :(float) v
{
	if ( m_sprite_components.size() > component )
		[m_sprite_components[component] set_physic_angular_velocity: v];
	
}
-(void) set_physic_angular_damping:(int) component :(float) d
{
	if ( m_sprite_components.size() > component )
		[m_sprite_components[component] set_physic_angular_damping: d];
}
-(void) set_physic_linear_damping :(int) component :(float) damping
{
	if ( m_sprite_components.size() > component )
		[m_sprite_components[component] set_physic_linear_damping: damping];
}
-(float) get_physic_rotation:(int) component
{
	if ( m_sprite_components.size() > component )
		return [ m_sprite_components[component] get_physic_rotation ];
	else
		return 0;
}

-(float) get_intertia:(int) component
{
    assert(component >= 0 && component < m_sprite_components.size() );
    if ( component >= 0 && component < m_sprite_components.size() )
    {
        return [m_sprite_components[component] get_intertia];
    }
    return 0;
}


-(float) get_physic_mass:(int) component
{
    assert(component >= 0 && component < m_sprite_components.size() );
    if ( component >= 0 && component < m_sprite_components.size() )
    {
        return [m_sprite_components[component] get_physic_mass];
    }
    return 0;
}
-(void) apply_torque:(float) torque
{
    SPRITECOMPONENTS::iterator it;
    for ( it = m_sprite_components.begin(); it != m_sprite_components.end(); ++it )
    {
        [*it apply_torque:torque];
    }
}
-(void) apply_torque:(int) component :(float)torque
{
    assert(component >= 0 && component < m_sprite_components.size() );
    if ( component >= 0 && component < m_sprite_components.size() )
    {
        [m_sprite_components[component] apply_torque:torque];
    }
}

-(void) apply_angular_impulse:(int) component :(float)angular_impulse
{
    assert(component >= 0 && component < m_sprite_components.size() );
    if ( component >= 0 && component < m_sprite_components.size() )
    {
        [m_sprite_components[component] apply_angular_impulse:angular_impulse];
    }
}

-(float) get_physic_mass
{
    float mass = 0;
    SPRITECOMPONENTS::iterator it;
    for ( it = m_sprite_components.begin(); it != m_sprite_components.end(); ++it )
    {
        mass += [*it get_physic_mass];
    }
    return mass;
}

-(void) set_physic_rotation:(int) component :(float) angle
{
	if ( m_sprite_components.size() > component )
		[m_sprite_components[component] set_physic_rotation: angle];
}
-(void) set_physic_linear_velocity:(int) component : (float) x :(float) y
{
	if ( m_sprite_components.size() > component )
		[m_sprite_components[component] set_physic_linear_velocity:x :y];
}
-(void) set_physic_fixed_rotation:(int) component : (bool) fixed
{
	if ( m_sprite_components.size() > component )
		[m_sprite_components[component] set_physic_fixed_rotation:fixed];
}

-(void) apply_impulse:(int) component :(float)speed_x :(float)speed_y
{
	if ( m_sprite_components.size() > component )
		[m_sprite_components[component] apply_impulse:speed_x :speed_y ];
}

-(void) apply_impulse_at_world_location:(int) component :(float)speed_x :(float)speed_y :(float) loc_x :(float) loc_y
{
	if ( m_sprite_components.size() > component )
		[m_sprite_components[component] apply_impulse_at_world_location:speed_x :speed_y :loc_x :loc_y];
}

-(void) apply_force_center:(int) component :(float)force_x force_y:(float)force_y
{
	if ( m_sprite_components.size() > component )
		[m_sprite_components[component]  apply_force_center:force_x force_y:force_y];
}
-(float) get_physic_angular_velocity:(int) component
{
	if ( m_sprite_components.size() > component )
		return [m_sprite_components[component] get_physic_angular_velocity];
	else
		return 0;
}
-(CGPoint) get_physic_linear_velocity:(int) component
{

	if ( m_sprite_components.size() > component )
		return [m_sprite_components[component] get_physic_linear_velocity];
	else
	{
		CGPoint ret;
		ret.x = ret.y = 0;
		return ret;
	}
}

-(void) clamp_physic_maxspeed:(int) component :(float) max_speed
{
	if ( m_sprite_components.size() > component )
		[m_sprite_components[component]  clamp_physic_maxspeed:max_speed];
}

-(void) heal:(float)health
{
	m_health += health;
	if ( m_health > m_max_health_ )
		m_health = m_max_health_;
}
//editor interface

-(void) set_selected :(bool) selected
{
	
}

-(SpriteHitProxy*) get_hitproxy
{
    if ( m_hitproxy_ == NULL )
    {
        m_hitproxy_ = [SpriteHitProxy new];
        [m_hitproxy_ set_sprite:self];
    }
	return m_hitproxy_;
}

-(void) set_layer:(GameLayer*) layer
{
	m_layer_ = layer;
}
-(GameLayer*) get_layer
{
	return m_layer_;
}
-(void) on_pre_solve:(struct b2Contact*) contact :(const struct b2Manifold*) old_manifold
{
}

-(void) on_begin_contact :( struct b2Contact* ) contact
{
    
}

-(void) on_end_contact :( struct b2Contact* ) contact
{
    
}

-(bool) is_batchable
{
	return m_batchable;
}

-(void) set_batchable:(bool) batchable
{
	m_batchable = true;//only worked if this sprite is not attached to a batchnode
}

-(std::vector<sprite_buff>&) get_buffs
{
    return m_buffs;
}
-(sprite_buff*) get_buff:(int) buff_type
{
    std::vector<sprite_buff>::iterator it;
    for ( it = m_buffs.begin(); it != m_buffs.end(); ++it )
    {
        if ( (*it).type == buff_type )
            return &(*it);
    }

    return NULL;
}

-(unsigned long long ) get_uid
{
    return m_uid;
}
-(void) add_buff:(const sprite_buff&) buff
{

}

-(void) do_add_buff:(const sprite_buff&) buff
{
    m_buffs.push_back(buff);
}

-(void) remove_buff_by_type:(int) buff_type
{

}

-(void) do_remove_buff_by_type:(int) buff_type
{
    std::vector<sprite_buff>::iterator it;
    for ( it = m_buffs.begin(); it != m_buffs.end(); ++it )
    {
        if ( (*it).type == buff_type )
        {
            m_buffs.erase(it);
            break;
        }
    }
}

//collision process
/*
-(void) add_collision: ( const Collision&) c
{
    m_collisions.push_back(c);
}
-(void) remove_collision: ( const Collision&) c
{
    std::vector<Collision>::iterator new_end;
    new_end = std::remove(m_collisions.begin(), m_collisions.end(), c);
    m_collisions.resize(new_end - m_collisions.begin());
}
-(const std::vector<Collision>&) get_collisions
{
    return m_collisions;
}

struct collison_sprites
{
    PhysicsSprite* spr_a;
    PhysicsSprite* spr_b;
    SpriteBase* sprite_a;
    SpriteBase* sprite_b;
};

-(collison_sprites) get_collision_sprites : (Collision&) c
{
    collison_sprites result;
    result.spr_a = (PhysicsSprite*)c.fixtureA->GetUserData();
    result.spr_b = (PhysicsSprite*)c.fixtureB->GetUserData();
    result.sprite_a = NULL;
    result.sprite_b = NULL;
    if ( result.spr_a != NULL )
        result.sprite_a = (SpriteBase* )result.spr_a.parent;
    if ( result.spr_b != NULL )
        result.sprite_b = (SpriteBase* )result.spr_b.parent;
    return result;
}

-(void) process_with_collisions
{
    std::vector<Collision>::iterator it;
    for ( it = m_collisions.begin(); it != m_collisions.end(); ++it )
    {
        collison_sprites cs = [self get_collision_sprites:*it];
       
        if ( cs.sprite_a == self && cs.sprite_b != NULL)
        {
            [ self collied_with:cs.sprite_b :&(*it) ];
        }
        else if ( cs.sprite_b == self && cs.sprite_a != NULL)
        {
            [ self collied_with:cs.sprite_a :&(*it) ];
        }
    }
}*/
/*
 从和他发生碰撞的所有sprites中删除有关他的碰撞信息
*/
/*
-(void) clear_related_collisions
{
    std::vector<Collision>::iterator it;
    for ( it = m_collisions.begin(); it != m_collisions.end(); ++it )
    {
        collison_sprites cs = [self get_collision_sprites:*it];
        if ( cs.sprite_a == self && cs.sprite_b != NULL)
        {
            [cs.sprite_b remove_collision:*it];
        }
        else if ( cs.sprite_b == self && cs.sprite_a != NULL)
        {
            [ cs.sprite_a remove_collision:*it ];
        }

    }
}
*/
@end
