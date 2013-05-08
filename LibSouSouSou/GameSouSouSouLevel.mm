//
//  GameSadLevel.m
//  ShotAndRun4
//
//  Created by Zero Fancy on 12-11-20.
//
//

#import "GameSouSouSou.h"
#import "GameSouSouSouLevel.h"
#import "Hero.h"
#import "Controller.h"

#include <vector>
#import "World.h"
#import "SpriteXMLParser.h"
#import "PhysicsDebuger.h"
#import "GameScene.h"
#include <box2d.h>
#import "Common.h"
#import "Platform.h"
@implementation GameSouSouSouLevel

-(void)reset
{
	
	[super reset];
    GameBase* game = [GameBase get_game];
    [ game cleanup_world ];
	
    //[ super set_map_size:1024 - 160 :800];
    World* world = [ GameBase get_game].m_world;
    Hero* hero;
    hero = [ Hero new];
    hero.m_name = @"Hero";
	CGPoint spawnpos;
	spawnpos.x = 1024 /2 - 300;
	spawnpos.y = 1024 / 2 ;
    [ hero set_physic_position:0 : spawnpos ];
    [ world add_gameobj:hero ];
    
    Controller* ctrl = [ Controller new ];
	[[GameBase get_input_device] set_controller: ctrl];
	//NSLog(@"controller retaincount:%d", [ctrl retainCount]);
    [ ctrl set_player:hero ];
	[ hero set_controller: ctrl ];
    [ ctrl set_pose:single_player ];
	

    if ( 0 )
	{
		physics_debug_sprite* pds = [ physics_debug_sprite new ];
		pds.zOrder = 200;
		[[GameBase get_game].m_scene.m_layer addChild:pds ];
	}
	m_cur_path = 0;
	
}


-(void)update:(float)delta_time
{
    [ super update:delta_time];
	
	
	// update acting range
	//todo: optmize
	std::vector<level_acting_range_keyframe>::const_iterator i;
	level_acting_range_keyframe a,b;
	
	for ( i = m_acting_range_keyframes_.begin(); i != m_acting_range_keyframes_.end(); ++i)
	{
		b = *i;
		if ( b.progress >= m_level_progress_ )
			break;
	}
	if ( i != m_acting_range_keyframes_.begin())
	{
		a = (*(i-1));
		CGRect rc_act;
		if ( b.progress == a.progress )
		{
			[self set_acting_range:b.act_rect];
			self->m_acting_range_velocity_ = ccp(0,0);
		}
		else
		{
			float alpha = (m_level_progress_ - a.progress) / (b.progress - a.progress);
			rc_act.origin.x = a.act_rect.origin.x * (1- alpha) + b.act_rect.origin.x * alpha;
			rc_act.origin.y = a.act_rect.origin.y * (1- alpha) + b.act_rect.origin.y * alpha;
			rc_act.size.width = a.act_rect.size.width * (1- alpha) + b.act_rect.size.width * alpha;
			rc_act.size.height = a.act_rect.size.height * (1- alpha) + b.act_rect.size.height * alpha;
			self->m_acting_range_velocity_.x = (b.act_rect.origin.x - a.act_rect.origin.x) / (b.progress - a.progress);
			self->m_acting_range_velocity_.y = (b.act_rect.origin.y - a.act_rect.origin.y) / (b.progress - a.progress);
			[self set_acting_range:rc_act];
		}
		
	}
	else
	{
		[self set_acting_range:b.act_rect];
	}

	if ( super.m_next_trigger < m_level_triggers.size() )
	{
		for ( int i = super.m_next_trigger; i < m_level_triggers.size(); ++i )
		{
			if ( m_level_triggers[i].progress_pos < self.m_level_progress )
			{
				[ self triggering_trigger:&m_level_triggers[i]];
				super.m_next_trigger = i+1;
			}
			else
			{
				break;
			}
		}
	}
    
 
}


-(void) on_sprite_dead: (SpriteBase*) sprite
{
    if ( [sprite isKindOfClass:[ Hero class]] )
    {
		// sleep( 3 );
        [ self request_reset];
    }
}
-(void) on_remove_obj: (GameObjBase*) obj
{
}
-(void) on_sprite_spawned: (SpriteBase*) sprite
{
}
-(void) on_add_obj: (GameObjBase*) obj
{
}
-(void) on_level_start
{
}

@end

