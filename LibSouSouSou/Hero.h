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
#include "common.h"
enum player_side
{
    ps_can_land_top,
    ps_can_land_bottom,
};

enum input
{
    go_left,
    go_right,
    none
};

template<typename T>
struct boostable_value
{
    T base_value;
    T boost_value;
    float boost_time;
    float boost_start;
    void reset()
    {
        boost_time = 0;
        boost_start = 0;
        boost_value = 0;
        base_value = 0;
    }
    void boost( float time, float value )
    {
        boost_time = time;
        boost_start = current_game_time();
        boost_value = value;
    }
    operator T()
    {
        if ( current_game_time() - boost_start > boost_time )
            return base_value;
        else
            return base_value + boost_value;
    }
};

@interface Hero : PlayerBase
{
    CGPoint m_velocity;
    
    player_side     m_player_side;
    platform_side   m_touched_side;

    float           m_score;
    std::map<PlatformBase*, int> m_landing_platforms;
    input m_next_input;
    input m_next_action;
    boostable_value<float>           m_magnet;
    boostable_value<float>           m_speed;
    boostable_value<int>             m_god_mode;//0 off, other on
    
}


-(bool) is_god;

-(void) set_god_mode:(int) v;
-(void) set_magnet:(float) v;
-(void) set_speed:(float) v;
-(void) set_god_mode_boost:(int)v :(float) time;
-(void) set_magnet_boost:(float) v :(float) time;
-(void) set_speed_boost:(float) v :(float) time;

-(float) get_magnet;
-(float) get_speed;
-(float) get_score;
-(id) init;
-(void) go_left;
-(void) go_right;
-(int) collied_with:(SpriteBase *)other :(Collision*) collision;
-(void) on_begin_contact :( struct b2Contact* ) contact;
-(void) on_end_contact :( struct b2Contact* ) contact;
-(void) add_landing_platform:(PlatformBase*) platform;
-(void) del_landing_platform:(PlatformBase*) platform;
-(bool) is_valid_fixture:(class b2Fixture*) fix;
@end
