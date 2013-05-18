//
//  GlobalConfig.m
//  GameSouSouSou
//
//  Created by FancyZero on 13-5-16.
//
//

#import "GlobalConfig.h"

float get_float_config(NSString* str)
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;

    NSString* file = [basePath stringByAppendingString: @"/config.plist"];
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:file];
    
    return [[dict valueForKey:str] floatValue];

}