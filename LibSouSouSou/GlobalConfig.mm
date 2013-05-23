//
//  GlobalConfig.m
//  GameSouSouSou
//
//  Created by FancyZero on 13-5-16.
//
//

#import "GlobalConfig.h"
static GlobalConfig g_global_config;
float get_float_config(NSString* str)
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;

    NSString* file = [basePath stringByAppendingString: @"/config.plist"];
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:file];
    
    return [[dict valueForKey:str] floatValue];

}

NSString* get_string_config(NSString* str)
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSString* file = [basePath stringByAppendingString: @"/config.plist"];
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:file];
    
    return [dict valueForKey:str] ;
    
}

void init_global_config()
{
        NSString * tm = get_string_config(@"test_maps");
    g_global_config.level_move_speed = get_float_config(@"min_level_speed");
    g_global_config.level_move_speed_max = get_float_config(@"max_level_speed");
    g_global_config.level_move_accleration = get_float_config(@"level_acceleration");
    g_global_config.ninja_push_force = get_float_config(@"push_force");
    g_global_config.ninja_jump_speed = get_float_config(@"ninja_speed");

    NSArray* arr = [ tm componentsSeparatedByString:@","];
    g_global_config.test_maps = arr;
    [ g_global_config.test_maps retain];
}



const GlobalConfig& get_global_config()
{
    return g_global_config;
}