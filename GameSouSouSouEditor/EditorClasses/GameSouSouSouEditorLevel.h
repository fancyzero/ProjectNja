//
//  GameSouSouSouEditorLevel.h
//  GameSaDEditor
//
//  Created by Zero Fancy on 12-11-24.
//
//
#import <vector>
#import "GameSouSouSouLevel.h"
#import <stack>
@interface GameSouSouSouEditorLevel : LevelBase
{
	BOOL m_show_act_range;
	std::stack<std::vector<level_progress_trigger> > m_op_histroy;
	std::stack<std::vector<level_progress_trigger> > m_op_redo_histroy;
}
-(void) update:(float)delta_time;
-(void) save_to_file:(NSString*) filepath;
-(void) on_trigger_changed:(int) trigger_id;
-(void) delete_sprites_spawned_by_trigger:(int) trigger_id;
-(void) delete_trigger:(int) trigger_id;
-(int)	add_trigger_at_runtime:(struct level_progress_trigger) trigger;//添加trigger，保证按照progress的大小排序
-(void) show_act_range:(BOOL) show;
-(BOOL) is_act_range_showed;
-(void) draw_acting_range;
-(void) set_progress:(float)progress;
-(void) push_histroy;
-(void) pop_histroy;
-(void) push_redo_histroy;
-(void) pop_redo_histroy;
//editor interface
-(std::vector<SpriteBase*>) pick_sprite:(CGPoint) pos :(int) layer;
@end
