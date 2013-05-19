//
//  DynamicObject.m
//  GameSouSouSou
//
//  Created by Fancyzero on 13-5-19.
//
//

#import "DynamicObject.h"
#include "common.h"
#import "GameBase.h"
#import "GameSouSouSouLevel.h"
@implementation FallenRock

-(id) init_with_spawn_params:(NSDictionary *)params
{
    self = [super init_with_spawn_params:params];

    m_fall_speed = read_float_value(params, @"fall_speed", 0);
    m_rotat_speed = read_float_value(params, @"rotat_speed", 0);
    
    
    return self;
}
-(void) update:(float)delta_time
{
    [super update:delta_time];
    [ self set_physic_fixed_rotation:0 :false];
    [ self set_physic_angular_velocity:0 :m_rotat_speed];
    GameSouSouSouLevel* lvl = (GameSouSouSouLevel*)[GameBase get_game].m_level;
    float level_speed = [lvl get_move_speed];
    float move_speed = (level_speed + m_fall_speed)/[GameBase get_ptm_ratio];
    [self set_physic_linear_velocity:0 :-move_speed  :0];
}
@end

@implementation Razor

-(id) init_with_spawn_params:(NSDictionary *)params
{
    self = [super init_with_spawn_params:params];
    m_init_pos = [self get_physic_position:0].y;
    m_sweep_speed = read_float_value(params, @"sweep_speed", 0);
    m_sweep_range = read_float_value(params, @"sweep_range", 200);
    return self;
}

-(void) update:(float)delta_time
{
    [super update:delta_time];
    [ self set_physic_fixed_rotation:0 :false];
    [ self set_physic_angular_velocity:0 :m_rotat_speed];
    GameSouSouSouLevel* lvl = (GameSouSouSouLevel*)[GameBase get_game].m_level;
    float level_speed = [lvl get_move_speed];
    float move_speed = (level_speed + m_fall_speed)/[GameBase get_ptm_ratio];
    float x = [self get_physic_position:0].x;
    float y = sin((current_game_time() - self.m_spawned_time)*m_sweep_speed) * m_sweep_range + m_init_pos;
    [self set_physic_position:0 :ccp(x,y)];
    [self set_physic_linear_velocity:0 :-move_speed  :0];
}

@end