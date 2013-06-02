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


template<typename T, bool use_fixed_morph_time>
struct morph_value
{
    T cur;
    T dest;
    T approch_speed;
    float set_time = 0;
    T   from_cur;
    float fixed_morph_time = 0;
    operator T()
    {
        return cur;
    }
    void set_cur( T c )
    {
        cur = c;

    }
    void set_dest( T d )
    {
        from_cur = cur;
        dest = d;
        set_time = current_game_time();
    }
    void update( float delta_time )
    {
        if ( use_fixed_morph_time )
        {
            if ( cur != dest )
            {
                T delta = dest - from_cur;
                float len = current_game_time() - set_time;
                if ( len > fixed_morph_time )
                    cur = dest;
                float alpha = len / fixed_morph_time;
                if ( alpha < 0 )
                    alpha = 0;
                if (alpha > 1 )
                    alpha = 1;
                alpha *= alpha;
                cur = from_cur + alpha * delta;
            }
        }
        else
        {
            T delta = delta_time * approch_speed;
            
            if ( cur > dest )
            {
                if ( delta > cur - dest )
                    cur = dest;
                else
                    cur -= delta;
            }
            else if ( cur < dest )
            {
                if ( delta > dest - cur )
                    cur = dest;
                else
                    cur += delta;
            }
        }

    }
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
    bool    m_last_touching_passable_platform;
    float   m_move_distance_when_leave_platform;//离开任何platform时的x距离
    bool    m_under_user_will;//用户输入了操作，后，未碰到可站立的platform前
    boostable_value<float>           m_magnet;
    boostable_value<float>           m_speed;
    boostable_value<int>             m_god_mode;//0 off, other on
    bool m_hovering;//是否处在离开passable platform 后的一段滞空状态
    morph_value<float,true>         m_hero_scale;
    
}


-(bool) is_god;

-(void) set_god_mode:(int) v;
-(void) set_magnet:(float) v;
-(void) set_speed:(float) v;
-(void) set_god_mode_boost:(int)v :(float) time;
-(void) set_magnet_boost:(float) v :(float) time;
-(void) set_speed_boost:(float) v :(float) time;
-(float) current_moved;
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
