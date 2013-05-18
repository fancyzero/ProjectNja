//
//  GameSadLevel.h
//  ShotAndRun4
//
//  Created by Zero Fancy on 12-11-20.
//
//

#import "Level.h"
@class BumppingScoreDisplay;
@interface GameSouSouSouLevel : LevelBase
{
    int m_cur_path;
    SpriteBase* m_bg1;
    float m_moved_pos;
    float m_current_sector_width;
    float m_move_speed;
    float m_max_move_speed;
    float m_move_acceleration;
    BumppingScoreDisplay* m_score_display;
    int     m_sector_attached;
}
-(float) get_move_speed;
-(void) update:(float)delta_time;

@end

