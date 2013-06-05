//
//  GameSadLevel.h
//  ShotAndRun4
//
//  Created by Zero Fancy on 12-11-20.
//
//

#import "Level.h"
#import "PlatformBase.h"
@class BumppingScoreDisplay;
@class RepeatBG;
class b2PhysicBody;
@class BoundingPlatform;
@interface GameSouSouSouLevel : LevelBase
{
    int m_cur_path;
    RepeatBG* m_bg1;
    float m_moved_pos;
    float m_current_sector_width;
    BumppingScoreDisplay* m_score_display;
    int     m_sector_attached;
    float m_move_speed;
    float m_total_moved;
    float m_god_safe_insert_pos_begin;
    float m_god_safe_insert_pos;
    float m_cur_god_safe_insert_pos;
    CCLabelTTF* m_result;
    float m_waiting_reset_start;
    BoundingPlatform*   m_top_bound;
    BoundingPlatform*   m_bottom_bound;

}

-(void) enable_bound:(bound_type) type :(bool) enable;
-(float) get_total_moved;
-(float) get_move_speed;
-(void) update:(float)delta_time;

@end

