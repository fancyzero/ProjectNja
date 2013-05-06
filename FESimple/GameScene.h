//
//  GameScene.h
//  testproj1
//
//  Created by Fancy Zero on 12-3-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "GameViewLayer.h"
#import "GameUILayer.h"

@interface GameScene : CCScene
{
	GameLayer*	m_BGLayer1_;
	GameLayer*	m_BGLayer2_;
	CGPoint			m_ed_viewoffset_;
	CCCamera*		m_camera_;
	GameLayer*		m_gameplaye_layer_;//all layer belown this layer except the uilayer
}

-(GameLayer*) get_layer_by_name:(NSString*) name;

@property (nonatomic, assign) GameLayer* m_layer;
@property (nonatomic, assign) GameUILayer* m_UIlayer;
@property (nonatomic, assign) GameLayer* m_BGLayer1;
@property (nonatomic, assign) GameLayer* m_BGLayer2;
@property (nonatomic, assign) CGPoint m_ed_viewoffset;
@property (nonatomic, assign) GameLayer* m_gameplayer_layer;
@property (nonatomic, assign) CCCamera* m_camera;
+(id) node;
@end
