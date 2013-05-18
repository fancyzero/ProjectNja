//
//  Hero.h
//  GameSouSouSou
//
//  Created by Fancyzero on 13-5-4.
//
//

#import "PlayerBase.h"
#import "PlatformBase.h"
#include <map>
enum player_side
{
    ps_can_land_top,
    ps_can_land_bottom,
};

@interface Hero : PlayerBase
{
    CGPoint m_velocity;
    
    player_side     m_player_side;
    platform_side   m_touched_side;

    float           m_score;
    float           m_speed;
    float           m_push_force;
    std::map<PlatformBase*, int> m_landing_platforms;
}

-(float) get_score;
-(id) init;
-(void) go_left;
-(void) go_right;
-(int) collied_with:(SpriteBase *)other :(Collision*) collision;
-(void) on_begin_contact :( struct b2Contact* ) contact;
-(void) on_end_contact :( struct b2Contact* ) contact;
-(void) add_landing_platform:(PlatformBase*) platform;
-(void) del_landing_platform:(PlatformBase*) platform;
@end
