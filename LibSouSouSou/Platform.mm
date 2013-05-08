//
//  Platform.m
//  GameSouSouSou
//
//  Created by Fancyzero on 13-5-5.
//
//

#import "Platform.h"
#import "Common.h"
#include <Box2D.h>
@implementation Platform
-(int) init_default_values
{
    [ super init_default_values];
    [ self set_collision_filter:cg_player1 cat:cg_static ];
    return 0;
}
@end

@implementation PassthroughPlatform



@end