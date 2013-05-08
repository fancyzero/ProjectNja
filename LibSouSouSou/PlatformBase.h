//
//  PlatformBase.h
//  GameSouSouSou
//
//  Created by Fancyzero on 13-5-5.
//
//

#import "SpriteBase.h"
enum platform_side
{
    ps_top,
    ps_passable_top,
    ps_passable_bottom,
    ps_bottom,
};

platform_side string_to_platform_side( const char* str );

@interface PlatformBase : SpriteBase

-(platform_side) get_side;
-(void) set_side:( platform_side ) side;

@end
