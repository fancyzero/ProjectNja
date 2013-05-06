//
//  GameSad.h
//  testproj1
//
//  Created by Fancy Zero on 12-3-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameBase.h"
@class LevelBase;

@class PlayerBase;

@interface GameSouSouSou : GameBase
{
	PlayerBase* m_player;
}
-(PlayerBase*) get_player:(int) player_num;
-(void) set_player:(int) player_num :(PlayerBase*) hero;
-(int) init_default;
-(void) init_game;
-(void) update :(float) delta_time;
+(GameSouSouSou*) get_instance;

//@property   (nonatomic, assign)    LevelBase*  m_level;//current level

@end

