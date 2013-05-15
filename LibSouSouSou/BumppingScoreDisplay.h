//
//  BumppingScoreDisplay.h
//  ShotAndRun4
//
//  Created by FancyZero on 13-3-30.
//
//

#import "CCLabelAtlas.h"

@interface BumppingScoreDisplay : CCLabelAtlas
{
    float m_current_value;
    float m_current_scale;
    float m_stay_time;
    float m_bump_time;
    float m_fade_time;
    float m_time_value_changed;
    bool  m_display_float_value;
    float m_bump_start;
    bool  m_hide_if_not_bumping;
    bool m_auto_bump;
    
    float m_bump_scale;
    float m_default_scale;

}
-(void) set_bump_scale:(float) s;
-(void) set_default_scale:(float) s;
-(void) bump;
- (void) init_default;
-(void) set_auto_bump:(bool) auto_bump;
-(void) set_hide_if_not_bumping:(bool) hide ;
-(void) set_value:(float) value;
-(void) display_float_value;
-(void) display_integer_value;
@end
