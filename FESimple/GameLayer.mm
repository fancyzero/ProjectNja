//
//  GameLayer.m
//  ShotAndRun4
//
//  Created by Zero Fancy on 12-10-21.
//
//

#import "GameLayer.h"
#import "GameBase.h"
#import "Level.h"
#import "World.h"
#import "BatchSpriteManager.h"

@implementation GameLayer
@synthesize m_move_scale = m_move_scale_;
@synthesize m_world	= m_world_;

-(id) init
{
	self = [super init];
	m_move_scale_ = 1;
	m_approaching_speed = 0;
	m_desired_position = ccp(0,0);
	//[self scheduleUpdate];
	m_batch_sprite_manager = [BatchSpriteManager manager_with_layer:self];
	return self;
}
-(void) cleanup
{
	[self removeAllChildrenWithCleanup:TRUE];
	[m_batch_sprite_manager cleanup];
}
-(void) add_sprite:(SpriteBase*) sprite
{
	//	
	[sprite set_layer:self];

	if ( [sprite is_batchable] && ![[GameBase get_game] is_editor])
	{
		[self->m_batch_sprite_manager add_sprite:sprite];
	}
	else
	{
		int cnt = [ sprite sprite_components_count];

		for ( int i = 0; i < cnt; i++)
		{
			PhysicsSprite* spr = [ sprite get_sprite_component:i];
			
			assert(spr.parent == NULL );
			
			[self addChild:spr];
		}
	}
}
-(void) set_desired_position:(CGPoint) pos
{
	m_desired_position = pos;
}
-(void) set_approaching_speed:(float) speed
{
	m_approaching_speed = speed;
}

-(CGPoint) calc_layer_pt  :(CGPoint) viewport_pos
{
    CGPoint viewport_size;
	GameLayer* layer = self;
	float layerscale = layer.scale;
	
    viewport_size.x = ([CCDirector sharedDirector].winSize.width)/layerscale;
    viewport_size.y = ([CCDirector sharedDirector].winSize.height)/layerscale;
	
	
    
    CGPoint viewport_center;
    viewport_center.x = viewport_size.x /2;
    viewport_center.y = viewport_size.y /2;
    
    
    CGPoint layer_pt;
    layer_pt.x = -viewport_pos.x + viewport_center.x;
    layer_pt.y = -viewport_pos.y + viewport_center.y;
	if ( ![[GameBase get_game] is_editor] )
	{
		if ( layer_pt.x > 0 )
			layer_pt.x = 0;
		if ( layer_pt.y > 0 )
			layer_pt.y = 0;
		
		
		
		CGRect maprect = [ GameBase get_game].m_level.m_map_rect;
		CGRect acting_rect = [ GameBase get_game].m_level.m_acting_range;
		
		if ( layer_pt.x > 0 )
			layer_pt.x = 0;
		if ( layer_pt.y > 0 )
			layer_pt.y = 0;
		if ( layer_pt.x < -(maprect.size.width - viewport_size.x) )
			layer_pt.x = -(maprect.size.width - viewport_size.x) ;
		if ( layer_pt.y < -(maprect.size.height - viewport_size.y)  )
			layer_pt.y = -(maprect.size.height - viewport_size.y) ;
		
		
		if ( layer_pt.x > -acting_rect.origin.x )
			layer_pt.x = -acting_rect.origin.x;
		if ( layer_pt.y > acting_rect.origin.y )
			layer_pt.y = -acting_rect.origin.y;
		
		if ( layer_pt.x < -(acting_rect.size.width + acting_rect.origin.x - viewport_size.x) )
			layer_pt.x = -(acting_rect.size.width + acting_rect.origin.x - viewport_size.x) ;
		if ( layer_pt.y < -(acting_rect.size.height + acting_rect.origin.y - viewport_size.y)  )
			layer_pt.y = -(acting_rect.size.height + acting_rect.origin.y - viewport_size.y) ;
	}
	layer_pt = ccpMult(layer_pt, layer.m_move_scale *layerscale);
    return layer_pt;
}

-(void) fix_layer_pt
{
	
	CGPoint viewport_size;
	float layerscale = self.scale;
	CGPoint layer_pt = self.position;
	layer_pt = ccpMult( layer_pt, 1/(self.m_move_scale*layerscale));
	
    viewport_size.x = ([CCDirector sharedDirector].winSize.width)/layerscale;
    viewport_size.y = ([CCDirector sharedDirector].winSize.height)/layerscale;
	
    CGRect acting_rect = [ GameBase get_game].m_level.m_acting_range;
	
    if ( layer_pt.x > 0 )
        layer_pt.x = 0;
    if ( layer_pt.y > 0 )
        layer_pt.y = 0;
	
    if ( layer_pt.x > -acting_rect.origin.x )
        layer_pt.x = -acting_rect.origin.x;
    if ( layer_pt.y > acting_rect.origin.y )
        layer_pt.y = -acting_rect.origin.y;
	
    if ( layer_pt.x < -(acting_rect.size.width + acting_rect.origin.x - viewport_size.x) )
        layer_pt.x = -(acting_rect.size.width + acting_rect.origin.x - viewport_size.x) ;
    if ( layer_pt.y < -(acting_rect.size.height + acting_rect.origin.y - viewport_size.y)  )
        layer_pt.y = -(acting_rect.size.height + acting_rect.origin.y - viewport_size.y) ;
	
	layer_pt = ccpMult(layer_pt, self.m_move_scale *layerscale);
	[self setPosition:layer_pt];
	
}


-(void) approching_to_desired_position:(float) delta_time
{
	if ( m_approaching_speed * delta_time > 1 )
	{
		[self setPosition:m_desired_position];
		return;
	}
	else
	{
		self.position = ccpAdd(self.position, ccpMult( ccpSub(m_desired_position, self.position ), m_approaching_speed*delta_time));
		
	}

	if ( ![[GameBase get_game] is_editor] )
	{

	
	[ self fix_layer_pt ];
	}
}

-(void) update:(float) delta_time
{
	//[super update:delta_time];
	[ self approching_to_desired_position: delta_time];
}

@end
