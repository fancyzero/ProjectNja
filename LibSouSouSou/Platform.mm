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
    return 0;
}

-(int) init_with_xml:(NSString *)filename
{
    [super init_with_xml:filename];
    [ self set_collision_filter:cg_player1 | cg_player2 cat:cg_static];
    return  0;
}
@end

@implementation PassthroughPlatform



@end