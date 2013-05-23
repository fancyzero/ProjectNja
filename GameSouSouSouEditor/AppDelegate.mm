
//
//  AppDelegate.mm
//  GameSaDEditor
//
//  Created by Zero Fancy on 12-10-27.
//  Copyright __MyCompanyName__ 2012年. All rights reserved.
//



#import "cocos2d.h"

#import "AppDelegate.h"
#import "SaDEditor.h"
#import "GameScene.h"
#import "GameSouSouSou.h"
#import "Level.h"
#import "EditorCommon.h"
#import "GameSouSouSouEditorLevel.h"
#import "EditorCommon.h"
typedef void *Cache;
#import "obj_runtime_new.h"
#import <Cocoa/Cocoa.h>
#import "SpriteDefManager.h"
#import "EditorController.h"

NSMutableDictionary* get_other_params (NSMutableDictionary* init_params)
{
	NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:init_params];
	[dict removeObjectForKey:@"progress"];
	[dict removeObjectForKey:@"act"];
	[dict removeObjectForKey:@"class"];
	[dict removeObjectForKey:@"init_position"];
	[dict removeObjectForKey:@"init_rotation"];
	[dict removeObjectForKey:@"init_scale"];
	[dict removeObjectForKey:@"init_zorder"];
	[dict removeObjectForKey:@"sprite_desc"];
	[dict removeObjectForKey:@"layer"];
	return dict;
}
void clear_other_params (NSMutableDictionary* init_params )
{
	NSArray* keys = [init_params allKeys];
	NSArray* reserved_keys = [NSArray arrayWithObjects:@"progress",@"act",@"class", @"init_position",@"init_rotation", @"init_scale",@"init_zorder", @"sprite_desc", @"layer", nil];
	
	for (NSString* k in keys)
	{
		if ( [reserved_keys indexOfObject: k] == NSNotFound )
			[init_params removeObjectForKey:k];
	}
	
}

@implementation sprite_class_collection_datasrc
-(id) init
{
	self = [super init];
	sprite_classes = NULL;
	return self;
}
-(NSInteger) numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
	if ( sprite_classes != NULL )
		return [sprite_classes count];
	else
		return 0;
}


- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
	if ( sprite_classes == NULL )
		return NULL;
	
	if (index > [sprite_classes count] || index < 0  )
		return nil;
	return [sprite_classes objectAtIndex:index ];
	
}
@end



@implementation sprite_desc_collection_datasrc
-(NSInteger) numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
	return [SpriteDefManager  sprite_def_count];
}


- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
	return [SpriteDefManager get_sprite_def_url:(int)index];
}
@end

@implementation GameSaDEditorAppDelegate
@synthesize max_progress;
@synthesize current_progress_txt;
@synthesize current_progress_slider;

@synthesize window=window_, glView=glView_, toolbox=toolbox_;
//,sprite_collection=sprite_collection_;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	
	// enable FPS and SPF
	[director setDisplayStats:YES];
	
	// connect the OpenGL view with the director
	[director setView:glView_];
	
	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	// Use kCCDirectorResize_NoScale if you don't want auto-scaling.
	[director setResizeMode:kCCDirectorResize_NoScale];
	
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:YES];
	
	// Center main window
	[window_ center];
	
    SaDEditor* game = [SaDEditor new ];
    [ game init_default ];
    [director runWithScene:game.m_scene];
	//sprite_collection_ = [sprite_collection_datasrc new];
	
	
	//collect all sub class of SPriteBAse
	//NSArray* a = [DKRuntimeHelper allClassesOfKind:[SpriteBase class]];
	
	//sprite_collection_->sprite_collection_ = [a copy];
	//[sprite_collection_->sprite_collection_ retain];
	//[sprite_collection_combobox_ setDataSource:sprite_collection_];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
	return YES;
}

- (void)dealloc
{
	[[CCDirector sharedDirector] end];
	[window_ release];
	[super dealloc];
}

#pragma mark AppDelegate - IBActions

- (IBAction)on_file_open:(id)sender
{

	NSOpenPanel* openDlg = [NSOpenPanel openPanel];
	
    // Enable the selection of files in the dialog.
    [openDlg setCanChooseFiles:YES];
	
    // Enable the selection of directories in the dialog.
    [openDlg setCanChooseDirectories:YES];

	
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ( [openDlg runModal ] == NSOKButton )
    {
		[openDlg close];
        // Get an array containing the full filenames of all
        // files and directories selected.
		NSURL* url = [openDlg URL];
		NSString* str = [url path];
		SaDEditor* game = (SaDEditor*)[GameBase get_game];
		[game open_level:str];
		if ( [GameSouSouSou get_game].m_level != NULL )
		{
			GameSouSouSouLevel* lvl = (GameSouSouSouLevel*)[GameSouSouSou get_game].m_level;
			[max_progress setFloatValue:[ lvl get_max_level_progress ]];
		}
    }
}

- (IBAction)on_file_saveas:(id)sender
{
	SaDEditor* game = (SaDEditor*)[GameBase get_game];
	NSSavePanel* saveDlg = [ NSSavePanel savePanel];
	[saveDlg setCanCreateDirectories:TRUE];
	
	if ( [saveDlg runModal] == NSOKButton )
	{
		NSURL* url = [saveDlg URL];
		[game save_current_level:[url path]];
	}
}

- (IBAction)on_file_save:(id)sender
{
	SaDEditor* game = (SaDEditor*)[GameBase get_game];
	[game save_current_level];
}

- (IBAction)on_undo:(id)sender
{
	SaDEditor* game = (SaDEditor*)[GameBase get_game];
	[(GameSouSouSouEditorLevel*) game.m_level  pop_histroy];
}

- (IBAction)on_redo:(id)sender
{
	SaDEditor* game = (SaDEditor*)[GameBase get_game];
	[(GameSouSouSouEditorLevel*) game.m_level  pop_redo_histroy];
}

- (IBAction)on_copy:(id)sender
{
    [ get_current_op() on_copy ];
}

- (IBAction)on_paste:(id)sender
{
    [get_current_op() on_paste];
}

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
}

- (IBAction)toggle_show_act_range:(id)sender
{
	NSMenuItem* item = (NSMenuItem*)sender;
	GameSouSouSouEditorLevel* lvl = (GameSouSouSouEditorLevel*)[GameBase get_game].m_level;
	[lvl show_act_range: ![lvl is_act_range_showed]];
	if ( [lvl is_act_range_showed] == TRUE )
		[item setState:1];
	else
		[item setState:0];
}

- (IBAction)on_level_progress_changed:(id)sender
{
	GameSouSouSouEditorLevel* lvl = (GameSouSouSouEditorLevel*)[GameBase get_game].m_level;
		float value = [sender floatValue];
	[ lvl set_progress :value];


	[ current_progress_slider setFloatValue:value];
	[ current_progress_txt setFloatValue:value];
	
}



@end


@implementation TriggerPropertyWindow
@synthesize trigger_id;
@synthesize trigger_progress = trigger_progress_;
@synthesize trigger_init_zorder;
@synthesize edit_mode_switch;
@synthesize trigger_layer;
@synthesize trigger_sprite_desc;
@synthesize sprite_def_collections;
@synthesize sprite_class_collections;

@synthesize trigger_init_position;
@synthesize trigger_init_rotation;
@synthesize trigger_init_scale;
@synthesize spawn_params_datasource;
@synthesize sprite_class =sprite_class_;
@synthesize spawn_params;

-(void) select_class:(NSString*) classname
{

    if ( classname != NULL )
        [sprite_class_ setStringValue:classname];

}

- (IBAction)on_param_changed:(id)sender
{
	level_progress_trigger* trigger;
	NSString* identifier = [sender identifier];
	NSString* strval = [sender stringValue];

	GameSouSouSouEditorLevel* lvl = (GameSouSouSouEditorLevel*)[GameBase get_game].m_level;
	EditorController* edctrl = (EditorController*)[ (SaDEditor*)[GameBase get_game] get_controller];
	
	if ( [edctrl get_edit_mode] == sed_modify )
		[lvl push_histroy];
	std::vector<SpriteBase*> selected_sprites =get_current_op_selected_sprites();

	for( std::vector<SpriteBase*>::iterator it = selected_sprites.begin(); it != selected_sprites.end(); ++it )
	{
		trigger = [[GameBase get_game].m_level get_trigger_by_id:[(*it) get_trigger_id ] ];
		if ( [identifier isEqualToString:@"trigger_class"] )
			[trigger->get_params() setObject:strval forKey:@"class"];
		
		if ( [identifier isEqualToString:@"trigger_progress_pos"] )
		{
			trigger->progress_pos = [sender floatValue];
			[trigger->get_params() setObject:strval forKey:@"progress"];
		}
		if ( [identifier isEqualToString:@"trigger_init_position"] )
			[trigger->get_params() setObject:strval forKey:@"init_position"];

		if ( [identifier isEqualToString:@"trigger_init_rotation"] )
			[trigger->get_params() setObject:strval forKey:@"init_rotation"];
		
		if ( [identifier isEqualToString:@"trigger_init_scale"] )
			[trigger->get_params() setObject:strval forKey:@"init_scale"];
		
		if ( [identifier isEqualToString:@"trigger_init_zorder"] )
			[trigger->get_params() setObject:strval forKey:@"init_zorder"];
		
		if ( [identifier isEqualToString:@"trigger_sprite_desc"] )
			[trigger->get_params() setObject:strval forKey:@"sprite_desc"];
		
		if ( [identifier isEqualToString:@"trigger_layer"] )
			[trigger->get_params() setObject:strval forKey:@"layer"];
		
		[lvl  on_trigger_changed: [(*it) get_trigger_id] ];
	}
}

- (IBAction)on_other_param_add_row:(id)sender
{
	[m_trigger->get_params() setObject:@"new value" forKey:@"new param"];
	[ self update_content];
}



- (IBAction)on_other_param_clear:(id)sender
{
	clear_other_params( m_trigger->get_params() );
	[ self update_content];
}

- (IBAction)on_other_param_remove_row:(id)sender
{
	NSInteger idx = spawn_params.selectedRow;
	NSDictionary* otherparams = get_other_params(m_trigger->get_params());
	NSArray* allkeys = [otherparams allKeys];
	if ( idx >= 0 && idx < allkeys.count )
	{
		
		[m_trigger->get_params() removeObjectForKey: allkeys[idx] ];
		[ self update_content];
	}
	
}

-(void) set_trigger:(struct level_progress_trigger*) trigger
{
	//collect all sub class of SPriteBAse
	NSArray* a = [DKRuntimeHelper allClassesOfKind:[SpriteBase class]];
	
	if ( sprite_class_collections->sprite_classes  != NULL )
		[sprite_class_collections->sprite_classes release];
	sprite_class_collections->sprite_classes = [a copy];
	[sprite_class_collections->sprite_classes retain];

	m_trigger = trigger;
	[ self update_content ];
}

-(void) update_content
{
	if (m_trigger != NULL )
	{
		[ trigger_progress_ setFloatValue: m_trigger->progress_pos ];
		[ trigger_id setIntValue: m_trigger->id ];
		if (  [m_trigger->get_params() valueForKey:@"init_position"] != NULL )
			[trigger_init_position setStringValue: [m_trigger->get_params() valueForKey:@"init_position"] ];

		else
			[trigger_init_position setStringValue: @"0,0"];
		if ( [m_trigger->get_params() objectForKey:@"init_rotation"] != NULL )
			[trigger_init_rotation setStringValue: [m_trigger->get_params() valueForKey:@"init_rotation"] ];
		else
			[trigger_init_rotation setStringValue: @"0" ];
		if ( [m_trigger->get_params() objectForKey:@"init_scale"] != NULL )
			[trigger_init_scale setStringValue: [m_trigger->get_params() valueForKey:@"init_scale"] ];
		else
			[trigger_init_scale setStringValue: @"1" ];
		
		if ( [ m_trigger->get_params() objectForKey:@"sprite_desc" ] )
			[trigger_sprite_desc setStringValue: [m_trigger->get_params() objectForKey:@"sprite_desc"]];
		else
			[trigger_sprite_desc setStringValue: @"" ];

		if ( [ m_trigger->get_params() objectForKey:@"layer" ] )
			[trigger_layer setStringValue: [m_trigger->get_params() objectForKey:@"layer"]];
		else
			[trigger_layer setStringValue: @"" ];
		
		if ( [m_trigger->get_params() objectForKey:@"init_zorder"] != NULL )
			[trigger_init_zorder setStringValue: [m_trigger->get_params() valueForKey:@"init_zorder"] ];
		else
			[trigger_init_zorder setStringValue: @"1" ];
		[spawn_params reloadData];
		[ self select_class: [m_trigger->get_params() objectForKey:@"class" ] ];
		//NSTableColumn* col = spawn_params.tableColumns[0];
	}
	else
	{
		[ trigger_progress_ setIntValue:-1];
	}
}

- (IBAction)on_edit_mode_changed:(NSSegmentedControl *)sender
{
	switch( [sender selectedSegment] )
	{
		case 0:
			[(EditorController*)[ (SaDEditor*)[GameBase get_game] get_controller] swith_edit_mode:sed_add];
			break;
		case 1:
			[(EditorController*)[ (SaDEditor*)[GameBase get_game] get_controller] swith_edit_mode:sed_modify];
			break;
	}
}
@end

@implementation sprite_spawn_params_datasrc

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	
	std::vector<SpriteBase*> selected_sprites = get_current_op_selected_sprites();
	for( std::vector<SpriteBase*>::iterator it = selected_sprites.begin(); it != selected_sprites.end(); ++it )
	{
		level_progress_trigger* trigger = [[GameBase get_game].m_level get_trigger_by_id: [(*it) get_trigger_id]];
		if ( trigger == NULL )
			return 0;
		NSMutableDictionary* dict = get_other_params( trigger->get_params() );
		
		NSUInteger i = [dict count];;
		return i;
		break;
	}
	return 0;
}



- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	
	std::vector<SpriteBase*> selected_sprites = get_current_op_selected_sprites();
	for( std::vector<SpriteBase*>::iterator it = selected_sprites.begin(); it != selected_sprites.end(); ++it )
	{
		level_progress_trigger* trigger = [[GameBase get_game].m_level get_trigger_by_id: [(*it) get_trigger_id]];
		if ( trigger == NULL || trigger->get_params() == NULL )
			return NULL;
		NSMutableDictionary* dict = get_other_params( trigger->get_params() );
		NSArray* keys = [dict allKeys];
		if ( row >= keys.count )
			return NULL;
		if ( row < 0 )
			return NULL;

		if ( [tableColumn.identifier isEqualToString: @"col_key"])
			return keys[row];
		if ( [tableColumn.identifier isEqualToString: @"col_value"])
			return [trigger->get_params() valueForKey:keys[row]];
		break;
	}
	return NULL;
}



-(void)MessageBox:(NSString *) header:(NSString *) message
{

	CFUserNotificationDisplayAlert(0, 0, 0, 0, 0, (CFStringRef)header, (CFStringRef)message, 0, 0, 0, 0);

	return;
}



- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	std::vector<SpriteBase*> selected_sprites = get_current_op_selected_sprites();
	for( std::vector<SpriteBase*>::iterator it = selected_sprites.begin(); it != selected_sprites.end(); ++it )
	{
		level_progress_trigger* trigger = [[GameBase get_game].m_level get_trigger_by_id: [(*it) get_trigger_id]];
		if ( trigger == NULL || trigger->get_params() == NULL )
			return ;
		NSMutableDictionary* dict = get_other_params( trigger->get_params() );
		NSArray* keys = [dict allKeys];		if ( row >= keys.count )
			return ;
		if ( row < 0 )
			return ;
	
		NSString* old_key;
		NSString* old_value;
		NSString* new_key;
		NSString* new_value;
		old_key = keys[row];
		old_value = [trigger->get_params() valueForKey:old_key];
		
		if ( [tableColumn.identifier isEqualToString: @"col_key"])
		{
			if ( [trigger->get_params() valueForKey:object] != NULL )
			{
				[self MessageBox:@"duplicated key" :@"duplicated key, edit cancled"];
				return;
			}
			new_value = [old_value copy];
			new_key = [object copy];
			[trigger->get_params() removeObjectForKey:old_key];
			[trigger->get_params() setObject:new_value forKey:new_key];
		}
		if ( [tableColumn.identifier isEqualToString: @"col_value"])
		{
			new_value = [object copy];
			[trigger->get_params() setObject:new_value forKey:old_key];
		}
		[tableView reloadData];
		GameSouSouSouEditorLevel* lvl = (GameSouSouSouEditorLevel*)[GameBase get_game].m_level;
		[lvl  on_trigger_changed: trigger->id];

		break;
	}
}

@end

@implementation mytextfield

- (BOOL)textShouldBeginEditing:(NSText *)textObject
{
	return YES;
}

@end
