//
//  SCoin.m
//  GameSouSouSou
//
//  Created by FancyZero on 13-5-14.
//
//

#import "SCoin.h"
#import "common.h"
#import "Hero.h"
@implementation SCoin
- (id)init
{
    self = [super init];
    if (self) {
        m_attracted = false;
        m_attracted_time = 0;
    }
    return self;
}

-(int) init_with_xml:(NSString *)filename
{
    [super init_with_xml:filename];
    [ self set_collision_filter:cg_player1 | cg_player2 cat:cg_static];

    return  0;
}

-(float) get_points
{
    return m_points;
}

-(id) init_with_spawn_params:(NSDictionary*) params
{
    self = [super init_with_spawn_params:params];
    [ self set_batchable:true];
        m_time_before_remove_outof_actrange_ = 0.1;
    m_points = read_float_value(params, @"points", 1);
    return self;
}

-(void) update:(float)delta_time
{
    [super update:delta_time];
    Hero* player = get_player(-1);
    CGPoint pos1 = [ player get_physic_position:0];
    CGPoint pos2 = [self get_physic_position:0];

    if ( (ccpLength( ccpSub(pos1, pos2) ) < [player get_magnet])  && !m_attracted)
    {
        m_attracted = true;
        m_attracted_time = current_game_time();
    }
    
    if ( m_attracted )
    {
        CGPoint v;
        float s = (current_game_time() - m_attracted_time) / 0.5f;
        if ( s > 1)
            s = 1;
        if ( s < 0 )
            s = 0;
        s *= s;
        s *= 500;
        //s += m_move_speed;
        v = ccpSub(pos1, pos2);
        v = ccpNormalize(v);
        v = ccpMult(v, s);

        [self set_physic_linear_velocity:0 :v.x :v.y];
    }
}
@end
