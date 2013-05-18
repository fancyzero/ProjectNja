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

-(id) init_with_spawn_params:(NSDictionary*) params
{
    self = [super init_with_spawn_params:params];
    [ self set_batchable:true];
        m_time_before_remove_outof_actrange_ = 0.1;
    return self;
}


@end
