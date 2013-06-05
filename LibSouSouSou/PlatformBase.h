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
    @protected
    bool m_passable;
    bool m_kill_touched;
    platform_side m_side;
    float m_move_speed;
    bool m_killed;//killed by player;
    bool m_excellented;//touched by 绝妙
}
-(bool) get_excellented;
-(void) set_excellented;
-(void) set_killed;
-(CGPoint) get_passed_position:(platform_side) from_side :(CGPoint) from_pos;
-(bool) passable;
-(bool) kill_touched;
-(platform_side) get_side;
-(void) set_side:( platform_side ) side;

@end

enum bound_type
{
    top,
    bottom,
};
@interface BoundingPlatform : PlatformBase
{
    bound_type m_type;
}
-(void) enable:(bool) flag;
-(void) set_type:(bound_type) type;
@end