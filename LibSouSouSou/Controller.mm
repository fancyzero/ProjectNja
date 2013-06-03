//
//  Controller.m
//  shotandrun
//
//  Created by Fancy Zero on 12-3-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Controller.h"
#import "GameSouSouSou.h"
#import "Common.h"
#import "World.h"
#import "GameScene.h"
#import "InputDeviceBase.h"
#import "Hero.h"
#import "Level.h"
float g_move_dir_max_len = 17;
float g_dir_len_power = 3;
@implementation Controller


-(id) init
{
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(orientationChanged:)
												 name:@"UIDeviceOrientationDidChangeNotification"
											   object:nil];
	

    return self;
}
- (void) orientationChanged:(NSNotification *)notification
{
#ifdef __CC_PLATFORM_IOS
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	//do stuff
	if ( UIInterfaceOrientationIsLandscape(orientation) )
	{
    }
	else if ( UIInterfaceOrientationIsPortrait(orientation) )
	{

	}
	//NSLog(@"Orientation changed");
#endif 
}

-(void) unregister_delegates
{

	//CCTouchDispatcher *dispatcher = [[CCDirector sharedDirector] touchDispatcher];
	
	//[dispatcher removeAllDelegates];
	//[m_dir_touch_delegate release];


}

-(void) set_pose :(enum pose) pose
{
  
}

-(void) set_player: (Hero*)   player
{
    m_player = player;
}

-(void) on_touch_move:(CGPoint) pos :(CGPoint) prev_pos;
{


}
-(BOOL) on_touch_begin: (CGPoint) pos
{

   // static int gogotest = 0;
    //if ( gogotest %2 )
    if ( get_player(-1) == nil)
    {
        [[GameBase get_game].m_level request_reset];
    }
    if( pos.y > [[CCDirector sharedDirector] winSize].height/2 )
        [ get_player(-1) go_right];
    else
        [ get_player(-1) go_left];
    //gogotest ++;
	return NO;
}

-(void) on_touch_end:(CGPoint) pos
{
}
-(void) dealloc
{
		
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	InputDeviceBase* input_device = [GameBase get_input_device];

	Controller* ctrl = [ input_device get_controller ];
	if ( ctrl == self )
		[ input_device set_controller :NULL ];
    [super dealloc];

}

-(void) on_touches_began: ( const std::vector<touch_info>& )touches
{
}
-(void) on_touches_ended: ( const std::vector<touch_info>& )touches
{

}

@end

