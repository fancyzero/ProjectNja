//
//  World.h
//  testproj1
//
//  Created by Fancy Zero on 12-3-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameObjBase.h"
#import "SpriteBase.h"
#import "common_datatype.h"

@class GameBase;


@interface World : NSObject
{
    struct CollisionListener*   m_collision_listener;
    struct GLESDebugDraw*       m_physics_debug;
    float                       accum_delta;//for fixed frame rate physic
    float                       physic_frame_time;

@public
}
@property (nonatomic, assign) struct b2World* m_physics_world;
-(id) init;
-(void) set_collision_handling_mode:(collision_process_mode) mode;
-(void) add_gameobj: (GameObjBase*) obj layer:(NSString*) layer;
-(void) add_gameobj: (GameObjBase*) obj;
-(void) remove_gameobj: (GameObjBase*) obj;
-(void) update:(float)delta_time;
-(void) enable_listener:(bool) enable :(bool) clear;
/*
 bool has_colision
 for debug purpose
 */
-(bool) has_colision;

-(void) cleanup;

-(GameObjBase*) find_obj_by_name:( NSString*) name;
-(NSMutableArray*) find_objs_by_name:(NSString*) name;
@property (nonatomic, readonly) NSMutableArray* m_gameobjects;
@property (nonatomic, readonly)  struct GLESDebugDraw*       m_physics_debug;
@end
