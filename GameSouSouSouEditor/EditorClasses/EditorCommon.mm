//
//  EditorCommon.m
//  GameSaDEditor
//
//  Created by Zero Fancy on 12-12-5.
//
//

#import <Foundation/Foundation.h>
#import "EditorCommon.h"
#import "AppDelegate.h"
#import <vector>
#import "SaDEditor.h"
#import "EditorController.h"
#import "OperatorBase.h"
@class SpriteBase;
TriggerPropertyWindow* get_trigger_property_window()
{
	GameSaDEditorAppDelegate* dele;
	dele = (GameSaDEditorAppDelegate* )[NSApplication sharedApplication].delegate;
	return dele.toolbox;
	
}

std::vector<SpriteBase*> get_current_op_selected_sprites()
{
	std::vector<SpriteBase*> empty_array;
	SaDEditor* editor;
	
	editor = (SaDEditor*)[GameBase get_game];
	if ( editor == NULL )
		return empty_array;
	EditorController* edctrl = (EditorController*)[editor get_controller];
	if ( edctrl == NULL )
		return empty_array;
	return edctrl->m_op_current->m_selected_sprites.get_selection();
}