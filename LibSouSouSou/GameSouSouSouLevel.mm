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
	spawnpos.x = 300;
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

-(void) updaet_acting_range_physic
{
	float ptm = [GameBase get_ptm_ratio];
	if ( m_acting_range_body_ == NULL )
    {
        b2BodyDef bodydef;
        bodydef.type = b2_staticBody;
        bodydef.position = b2Vec2(0,0);
        b2Body* body = [GameBase get_game].m_world.m_physics_world->CreateBody(&bodydef);

        float x1, y1,x2,y2;
        x1 = 300/ptm;
        y1 = 300/ptm;
        x2 = (0 + 1024) / ptm;
        y2 = (0 + 768) / ptm;
        b2PolygonShape shape;
        shape.SetAsBox((1024-300)/2.0/ptm, 768/2.0/ptm, b2Vec2(300/ptm + (1024-300)/2.0/ptm, 768/2.0/ptm), 0);
        b2Filter filter;
        filter.categoryBits=cg_acting_range;
        filter.maskBits=cg_player1 | cg_player2 | cg_acting_range;
        
        b2Fixture* fix = body->CreateFixture(&shape,1);
        fix->SetFriction( 0 );
        fix->SetRestitution(0);
        fix->SetFilterData(filter);

        
        m_acting_range_body_  = body;
    }

	
}

-(void)update:(float)delta_time
{
    [ super update:delta_time];
	
	
	// update acting range
	CGRect rc_act;
    rc_act.origin = ccp(0,0);
    rc_act.size.width = 1024;
    rc_act.size.height = 768;

    [self set_acting_range:rc_act];


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

