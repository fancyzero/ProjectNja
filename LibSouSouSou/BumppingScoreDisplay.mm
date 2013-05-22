//
//  BumppingScoreDisplay.m
//  ShotAndRun4
//
//  Created by FancyZero on 13-3-30.
//
//
#import "cocos2d.h"
#import "BumppingScoreDisplay.h"
#include "common.h"
@implementation BumppingScoreDisplay
- (void) init_default
{
    
    m_current_value = 0;
    m_bump_start = -1000;
    m_bump_time = 0.5;
    m_stay_time = 0.5;
    m_fade_time = 0.5;
    m_hide_if_not_bumping = false;
    m_auto_bump = true;
    m_default_scale = 1;
    m_bump_scale = 3;
    self.anchorPoint=ccp(0.5,0.5);
    [self scheduleUpdate];
    
}
-(void) set_bump_scale:(float) s
{
    m_bump_scale = s;
}
-(void) set_auto_bump:(bool) auto_bump;
{
    m_auto_bump = auto_bump;
}

-(void) set_default_scale:(float) s
{
    m_default_scale = s;
}

-(void) set_hide_if_not_bumping:(bool) hide
{
    m_hide_if_not_bumping = hide;
}
-(void) bump
{
    m_bump_start = current_game_time();
    self.rotation = (frandom()-0.5 )* 15;
}
-(void) set_value:(float) value
{
    m_time_value_changed = current_game_time();
    if ( m_auto_bump && value > m_current_value + 10 )
    {
        m_bump_start = current_game_time();
    }
    m_current_value = value;
    if ( m_display_float_value )
    {
        [self setString:[ NSString stringWithFormat:@"%.2f", value] ];
    }
    else
    {
        [self setString:[ NSString stringWithFormat:@"%d", (int)value] ];
    }
    
}

-(void) update: (ccTime) t
{
    //[super update:t];
    float curtime = current_game_time();
    if ( curtime - m_bump_start < m_bump_time )
    {
        [self setScale: powf( 1 - (curtime - m_bump_start)*2 ,4)*m_bump_scale+ m_default_scale ];
    }
    else
        [self setScale:m_default_scale];
    if ( m_hide_if_not_bumping )
    {
        if ( curtime > m_bump_start + m_bump_time + m_stay_time )
        {
            float op = (m_fade_time - (curtime - m_bump_start - m_stay_time - m_bump_time )) / m_fade_time;
            if ( op >=0 && op <= 1)
                [self setOpacity:  op * 255];
            else
                [self setOpacity:  255];
            //NSLog(@"%f", op);
        }
    }
    
    if ( m_hide_if_not_bumping && curtime - m_bump_start > m_bump_time + m_fade_time + m_stay_time )
        [self setVisible:FALSE];
    else
        [self setVisible:TRUE];
    
    
}

-(void) display_float_value
{
    m_display_float_value = true;
}

-(void) display_integer_value
{
    m_display_float_value = false;
}

@end
