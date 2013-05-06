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

TriggerPropertyWindow* get_trigger_property_window();
std::vector<SpriteBase*> get_current_op_selected_sprites();