//
//  GameScene.m
//  testproj1
//
//  Created by Fancy Zero on 12-3-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"
#import "GameViewLayer.h"
#import "GameBase.h"

@implementation GameScene

@synthesize m_layer;
@synthesize m_UIlayer;
@synthesize m_BGLayer1 = m_BGLayer1_;
@synthesize m_BGLayer2 = m_BGLayer2_;
@synthesize m_ed_viewoffset = m_ed_viewoffset_;
@synthesize m_gameplayer_layer = m_gameplaye_layer_;
+(id) node
{
    GameScene* ret;
	
    ret = [super node ] ;
	ret.m_ed_viewoffset = ccp(0,0);
    if ( ret )
    {
		ret->m_gameplaye_layer_ = [GameLayer node ];
		[ret->m_gameplaye_layer_ setAnchorPoint:ccp(0,0)];
		[ret->m_gameplaye_layer_ setPosition:ccp(0,0)];
		[ret addChild:ret->m_gameplaye_layer_];
        ret.m_layer = [GameLayer node ];

        ret.m_UIlayer = [ GameUILayer node];
		ret.m_BGLayer1 = [ GameLayer node];
		ret.m_BGLayer1.m_move_scale = 0.75;
		ret.m_BGLayer2 = [ GameLayer node];
		ret.m_BGLayer2.m_move_scale = 0.5;
		[ ret->m_gameplaye_layer_ addChild: ret.m_layer z:3];
		[ret.m_layer setAnchorPoint:ccp(0,0)];
        [ret->m_gameplaye_layer_ addChild: ret.m_BGLayer1 z:1];
		[ret.m_BGLayer1 setAnchorPoint:ccp(0,0)];
		[ret->m_gameplaye_layer_ addChild: ret.m_BGLayer2 z:0];
		[ret.m_BGLayer2 setAnchorPoint:ccp(0,0)];

        [ret addChild: ret.m_UIlayer z:100];
		[ret.m_UIlayer setAnchorPoint:ccp(0,0)];

    }
	[ret scheduleUpdate];
    return ret;
}

-(GameLayer*) get_layer_by_name:(NSString*) name
{
	if ( [name isEqualToString:@"game"] )
		return m_layer;
	if ( [name isEqualToString:@"ui"] )
		return m_UIlayer;
	if ( [name isEqualToString:@"bg1"] )
		return m_BGLayer1_;
	if ( [name isEqualToString:@"bg2"])
		return m_BGLayer2_;
	return m_layer;
}

-(void) update: (ccTime) delta_time
{
	/*if ( delta_time > 25.0f/1 )
		delta_time = 25.0f/1;*/
	[ [ GameBase get_game ] update:delta_time ];
    [ [ GameBase get_game ].m_level update:delta_time ];
    [ [ GameBase get_game ].m_world update: delta_time ];
	
	{
	[ m_layer update:delta_time ];
	//[ m_UIlayer update:delta_time ];
	[ m_BGLayer1_ update:delta_time ];
	[ m_BGLayer2_ update:delta_time ];
	}
}

@end
