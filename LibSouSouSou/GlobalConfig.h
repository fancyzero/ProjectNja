//
//  GlobalConfig.h
//  GameSouSouSou
//
//  Created by FancyZero on 13-5-16.
//
//

#import <Foundation/Foundation.h>

float get_float_config(NSString* str);
struct GlobalConfig
{
    float level_move_speed;
    float ninja_jump_speed;
    float ninja_push_force;
    float level_move_speed_max;
    float level_move_accleration;
    float hero_spawn_location;
    NSArray* test_maps;
};

void init_global_config();
const GlobalConfig& get_global_config();