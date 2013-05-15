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
    ps_none,
};

platform_side string_to_platform_side( const char* str );

@interface PlatformBase : SpriteBase
{
    bool m_passable;
    bool m_kill_touched;
    platform_side m_side;
}

-(CGPoint) get_passed_position:(platform_side) from_side :(CGPoint) from_pos;
-(bool) passable;
-(bool) kill_touched;
-(platform_side) get_side;
-(void) set_side:( platform_side ) side;

@end
