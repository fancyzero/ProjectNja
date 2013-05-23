//
//  EditorCommon.h
//  GameSaDEditor
//
//  Created by Zero Fancy on 12-12-5.
//
//

#import <Foundation/Foundation.h>
#import <vector>
@class TriggerPropertyWindow;
@class SpriteBase;
@class OperatorBase;
TriggerPropertyWindow* get_trigger_property_window();
NSWindow* get_main_window();
OperatorBase* get_current_op();
std::vector<SpriteBase*> get_current_op_selected_sprites();
void clear_selected();