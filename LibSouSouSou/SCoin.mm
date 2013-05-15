//
//  SCoin.m
//  GameSouSouSou
//
//  Created by FancyZero on 13-5-14.
//
//

#import "SCoin.h"
#import "common.h"

@implementation SCoin
-(int) init_with_xml:(NSString *)filename
{
    [super init_with_xml:filename];
    [ self set_collision_filter:cg_player1 | cg_player2 cat:cg_static];
    return  0;
}

@end
