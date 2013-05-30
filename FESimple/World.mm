//
//  World.m
//  testproj1
//
//  Created by Fancy Zero on 12-3-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#include <Box2D.h>
#include <vector>
#include "CollisionListener.h"
#import "GLES-RENDER.H"
#import "World.h"
#import "GameScene.h"
#import "SpriteBase.h"
#import "GameBase.h"
#import "common.h"

@implementation World

@synthesize m_gameobjects;
@synthesize m_physics_world;
@synthesize m_physics_debug;

-(id) init
{
    self = [super init];

    m_gameobjects = [NSMutableArray new ];
    m_physics_world = new b2World(b2Vec2(0,0));
    m_physics_world->SetContinuousPhysics(true);   
    m_collision_listener = new CollisionListener();
    m_physics_world->SetContactListener(m_collision_listener);
    m_physics_debug = new GLESDebugDraw([GameBase get_ptm_ratio]);
    accum_delta = 0;
    physic_frame_time = 1/60.0f;
    uint32 flags = 0;
    flags += b2Draw::e_shapeBit;
    		flags += b2Draw::e_jointBit;
    //		flags += b2Draw::e_aabbBit;
    //		flags += b2Draw::e_pairBit;
    		flags += b2Draw::e_centerOfMassBit;
    m_physics_debug->SetFlags(flags);
    m_physics_world->SetDebugDraw(m_physics_debug);
	
	
	int k;
	k=100;
	k=10;
	//test texture packer

    return self;
}

-(void) set_collision_handling_mode:(collision_process_mode) mode
{
	m_collision_listener->m_collision_process_mode = mode;
}

-(void) dealloc
{
    if ( m_physics_debug != NULL )
    {
        m_physics_debug = NULL;
        delete m_physics_debug;
    }
    if ( m_physics_world != NULL )
        delete m_physics_world;
    if ( m_collision_listener != NULL )
        delete m_collision_listener;
    [super dealloc ];
}

-(void) add_gameobj: (GameObjBase*) obj layer:(NSString*) layer
{
    [ m_gameobjects addObject:obj ];
    GameBase* game = [ GameBase get_game ];
    if ( [obj isKindOfClass:[SpriteBase class]] )
    {
        //add sprite
        //SpriteBase* sprite = (SpriteBase*)obj;
        // assert(((SpriteBase*)obj).m_sprite);
		SpriteBase* spr = (SpriteBase*)obj;
		
		
		if ( [layer isEqualToString: @"game"])
		{
			[game.m_scene.m_layer add_sprite:spr];
		}
		else if ( [layer isEqualToString: @"ui"])
		{
			[game.m_scene.m_UIlayer add_sprite:spr];
		}
		else if ( [layer isEqualToString:@"bg1" ])
		{
			[game.m_scene.m_BGLayer1 add_sprite:spr];
		}
		else if ( [layer isEqualToString: @"bg2"])
		{
			[game.m_scene.m_BGLayer2 add_sprite:spr];
		}
		
	}
}



-(void) add_gameobj: (GameObjBase*) obj
{
	[self add_gameobj: obj layer:@"game"];
}

-(GameObjBase*) find_obj_by_name:(NSString*) name
{
    for (GameObjBase* obj in m_gameobjects) 
    {
        if ( [ obj.m_name isEqualToString:name] )
            return obj;
    }
    return nil;
}

-(NSMutableArray*) find_objs_by_name:(NSString*) name
{
	NSMutableArray* objs = [NSMutableArray array];//this is autorelease
    for (GameObjBase* obj in m_gameobjects)
    {
        if ( [ obj.m_name isEqualToString:name] )
           [ objs addObject:obj];
    }
	return objs;
}

-(void) remove_gameobj:(GameObjBase *)obj
{
    //NSLog(@"remove obj %X", obj);
    //GameSad* game = [ GameBase get_game ];
    
    [ m_gameobjects removeObject:obj ];
    
	if ( [obj isKindOfClass:[SpriteBase class]] )
	{
		SpriteBase* spr = (SpriteBase*)obj;
		int cnt = [ spr sprite_components_count];
		//[spr.m_root_node.parent removeChild:spr.m_root_node cleanup:TRUE];
		for ( int i = 0; i < cnt; i++)
		{
			PhysicsSprite* sprite = [ spr get_sprite_component:i];
			[sprite.parent removeChild:sprite cleanup:TRUE];
		}
		
	}
}

-(void) enable_listener:(bool) enable :(bool) clear
{
    if( clear )
        m_collision_listener->m_collisions.clear();
    if ( enable )
        m_physics_world->SetContactListener( m_collision_listener );
    else
        m_physics_world->SetContactListener( nil );
}

-(void) update:(float)delta_time
{
    GameBase* game;
    game = [ GameBase get_game ];
    game.m_DBG_loop_stat = 0;
    if ( [ game need_reset ] )// reset entire game, back to title 
    {
        game.m_DBG_loop_stat = 2;
        [ game reset];
    }
    game.m_DBG_loop_stat = 1;
   // NSLog(@"world update start");
    NSMutableArray* copyof_gameobjects;
 
    copyof_gameobjects =[m_gameobjects copy];
    //NSLog(@"world update 111: %d",i);
    for (GameObjBase* obj in copyof_gameobjects)
    {
        //NSLog(@"update obj: %X",obj);
		if ( [[GameBase get_game] is_editor])
			[ obj ed_update:delta_time];
		else
			[ obj update:delta_time];
         //NSLog(@"end update obj: %X",obj);
    }
    //NSLog(@"world update 222: %d",i);
    NSMutableArray* tmp = copyof_gameobjects;//[m_gameobjects copy];
    copyof_gameobjects =[m_gameobjects copy];

    accum_delta += delta_time;
    while (accum_delta > physic_frame_time)
    {
        m_physics_world->Step(physic_frame_time, 1, 1);
        accum_delta -= physic_frame_time;
    }
    //process contacts
    std::vector<Collision>::iterator it;
    for ( it = m_collision_listener->m_collisions.begin(); 
         it != m_collision_listener->m_collisions.end(); 
         ++it )
    {
        PhysicsSprite* sprite_comp_A = get_sprite((*it).fixtureA);
        PhysicsSprite* sprite_comp_B = get_sprite((*it).fixtureB);
		SpriteBase* spriteA = NULL;
		SpriteBase* spriteB = NULL;
		if ( sprite_comp_A != NULL )
			spriteA = sprite_comp_A.m_parent;
		if ( sprite_comp_B != NULL )
			spriteB = sprite_comp_B.m_parent;
		if ( spriteA != spriteB )
		{
			bool a = false;
			bool b = false;
			if ( spriteA == NULL )
				a = true;
			else if ( ![spriteA isdead])
				a = true;
			
			if ( spriteB == NULL )
				b = true;
			else if ( ![spriteB isdead])
				b = true;
			
			if ( a && b )
			//if ( (spriteA == NULL || ![spriteA isdead]) && ( spriteB == NULL || ![spriteB isdead] ) )
			{
				[ spriteA collied_with:spriteB :&(*it) ];
				[ spriteB collied_with:spriteA :&(*it) ];
			}
		}
		// }
    }
	//m_collision_listener->m_collisions.clear();
    game.m_DBG_loop_stat = 2;
    [tmp release];
    [copyof_gameobjects release];
   
   // NSLog(@"world update end");
   // i++;

}

-(bool) has_colision
{
    return m_collision_listener->m_collisions.size() > 0;
}
-(void) cleanup
{
//    NSLog(@"world cleanup , list retaincount");
    for ( GameObjBase* obj in m_gameobjects )
    {
        //NSLog(@"%@ : %@ : %d",obj.m_name, obj,  [ obj retainCount ]);
        [obj release ];
    }
//    NSLog(@"world cleanup retaincount end");
    [ m_gameobjects removeAllObjects ];
    m_collision_listener->m_collisions.clear();
}


@end
