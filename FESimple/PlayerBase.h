//
//  PlayerBase.h
//  ShotAndRun4
//
//  Created by Zero Fancy on 12-11-20.
//
//

#import <Foundation/Foundation.h>
#import "SpriteBase.h"
@class ControllerBase;
@class LevelBase;
@class GameBase;
@interface PlayerBase : SpriteBase

-(id) init_with_game: (GameBase*) level;
-(void) set_controller:(ControllerBase*) ctrl;
@end
