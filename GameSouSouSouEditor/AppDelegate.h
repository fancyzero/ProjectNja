//
//  AppDelegate.h
//  GameSaDEditor
//
//  Created by Zero Fancy on 12-10-27.
//  Copyright __MyCompanyName__ 2012年. All rights reserved.
//

#import "cocos2d.h"

struct level_progress_trigger;
@interface sprite_class_collection_datasrc : NSObject<NSComboBoxDataSource>
{
@public
	NSArray*	sprite_classes;
}
@end


@interface sprite_desc_collection_datasrc : NSObject<NSComboBoxDataSource>
{

}
@end


@interface sprite_spawn_params_datasrc : NSObject<NSTableViewDataSource>
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
@end
@interface TriggerPropertyWindow: NSView
{
	NSComboBox* sprite_class_;
	NSTextField *trigger_progress_;
	NSTableView *spawn_params;
	sprite_spawn_params_datasrc *spawn_params_datasource;
	NSTextField *trigger_id;
	NSTextField *trigger_init_position;
	NSTextField *trigger_init_rotation;
	NSTextField *trigger_init_scale;
	NSTextField *trigger_init_zorder;
	NSSegmentedControl *edit_mode_switch;
	NSComboBox *trigger_layer;
	NSComboBox *trigger_sprite_desc;
	sprite_desc_collection_datasrc *sprite_def_collections;
	
	struct level_progress_trigger* m_trigger;

	sprite_class_collection_datasrc *sprite_class_collections;;

}
- (IBAction)on_param_changed:(id)sender;

- (IBAction)on_other_param_add_row:(id)sender;
- (IBAction)on_other_param_clear:(id)sender;
- (IBAction)on_other_param_remove_row:(id)sender;
-(void) set_trigger:(struct level_progress_trigger*) trigger;
-(void) update_content;
@property (assign) IBOutlet NSTextField *trigger_id;
@property (assign) IBOutlet sprite_class_collection_datasrc *sprite_class_collections;
@property (assign) IBOutlet NSTextField *trigger_init_position;
@property (retain) IBOutlet NSTextField *trigger_init_rotation;
- (IBAction)on_edit_mode_changed:(NSSegmentedControl *)sender;
@property (assign) IBOutlet NSTextField *trigger_init_scale;
@property (assign) IBOutlet sprite_spawn_params_datasrc *spawn_params_datasource;
@property (assign) IBOutlet NSComboBox *sprite_class;
@property (assign) IBOutlet NSTableView *spawn_params;
@property (assign) IBOutlet NSTextField *trigger_progress;
@property (assign) IBOutlet NSTextField *trigger_init_zorder;
@property (assign) IBOutlet NSSegmentedControl *edit_mode_switch;
@property (assign) IBOutlet NSComboBox *trigger_layer;

@property (assign) IBOutlet NSComboBox *trigger_sprite_desc;
@property (assign) IBOutlet sprite_desc_collection_datasrc *sprite_def_collections;

@end

@interface GameSaDEditorAppDelegate : NSObject <NSApplicationDelegate>
{
	NSWindow	*window_;
	TriggerPropertyWindow		*toolbox_;
	CCGLView	*glView_;
	NSSliderCell *current_progress_slider;
	NSTextField *current_progress_txt;
	NSTextField *max_progress;
}
@property (assign) IBOutlet NSTextField *max_progress;

@property (assign) IBOutlet NSTextField *current_progress_txt;
@property (assign) IBOutlet NSSliderCell *current_progress_slider;
@property (assign) IBOutlet NSWindow	*window;
@property (assign) IBOutlet TriggerPropertyWindow		*toolbox;
@property (assign) IBOutlet CCGLView	*glView;
//@property (assign) IBOutlet sprite_collection_datasrc* sprite_collection;
- (IBAction)on_file_open:(id)sender;
- (IBAction)on_file_saveas:(id)sender;
- (IBAction)on_file_save:(id)sender;
- (IBAction)on_undo:(id)sender;
- (IBAction)on_redo:(id)sender;
- (IBAction)on_copy:(id)sender;
- (IBAction)on_paste:(id)sender;

- (IBAction)toggleFullScreen:(id)sender;
- (IBAction)toggle_show_act_range:(id)sender;

- (IBAction)on_level_progress_changed:(id)sender;



@end

@interface mytextfield : NSTextField
- (BOOL)textShouldBeginEditing:(NSText *)textObject;
@end
