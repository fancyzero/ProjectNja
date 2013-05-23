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
    BumppingScoreDisplay* m_score_display;
    int     m_sector_attached;
    float m_move_speed;
    float m_total_moved;
}
-(float) get_move_speed;
-(void) update:(float)delta_time;

@end

