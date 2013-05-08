//
//  SaDEditor.h
//  ShotAndRun4
//
//  Created by Zero Fancy on 12-10-26.
//
//

#import <Foundation/Foundation.h>
#import "GameBase.h"
#import <vector>
#include <string>
@class GameSouSouSouEditorLevel;
@class ControllerBase;
@class SpriteBase;


@interface SaDEditor : GameBase
{
	ControllerBase*	m_controller_;
	NSString*	m_current_level_filename;
}
-(int) init_default;
-(void) new_level;
-(void) open_level: (NSString*) filename;
-(void) save_current_level:(NSString*) filename;
-(void) save_current_level;
-(void) add_sprite:(NSString*) class_name location:(CGPoint) loc :(NSDictionary*) params;
-(bool) is_editor;
-(void) delete_sprite:(SpriteBase*) sprite;//delete the trigger that spawned the sprite
-(ControllerBase*) get_controller;
@end
