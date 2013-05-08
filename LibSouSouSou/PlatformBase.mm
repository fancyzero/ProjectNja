//
//  PlatformBase.m
//  GameSouSouSou
//
//  Created by Fancyzero on 13-5-5.
//
//

#import "PlatformBase.h"

platform_side string_to_platform_side( const char* str )
{
    if ( strcmp("top", str) == 0 )
        return ps_top;
    if ( strcmp("bottom", str) == 0 )
        return ps_bottom;
    if ( strcmp("passable_top", str) == 0 )
        return ps_passable_top;
    if ( strcmp("passable_bottom", str) == 0 )
        return ps_passable_bottom;
    return ps_top;
}

@implementation PlatformBase
{
    platform_side m_side;
}

-(platform_side) get_side
{
    return m_side;
}

-(void) set_side:( platform_side ) side
{
    m_side = side;
}
@end
