//
//  ScoreLayer.h
//  GameSouSouSou
//
//  Created by Fancyzero on 13-6-3.
//
//

#import "GameLayer.h"

@interface ScoreLayer : GameLayer
@property (nonatomic,assign) CCLabelTTF*   m_score_label;
@property (nonatomic,assign) CCLayer*      m_bg_layer;

@end
