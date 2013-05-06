//
//  Controller.h
//  shotandrun
//
//  Created by Fancy Zero on 12-3-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "SpriteBase.h"
#import <Foundation/Foundation.h>
#import "ControllerBase.h"
@class Hero;

enum pose
{
    single_player,
    duel_top,
    duel_bottom,
};

@class PlayerBase;

@interface Controller : ControllerBase
{
	Hero* m_player;
}

-(void) on_touch_move:(CGPoint) pos :(CGPoint) prev_pos;
-(BOOL) on_touch_begin: (CGPoint) pos;
-(void) on_touch_end:(CGPoint) pos;
-(void) on_touches_began: ( const std::vector<touch_info>& )touches;
-(void) on_touches_ended: ( const std::vector<touch_info>& )touches;
-(id)   init;
-(void) set_pose :(enum pose) pose;
-(void) set_player: (Hero*)   player;


@end
