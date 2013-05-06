//
//  ActRangeVisualizerSprite.m
//  GameSaDEditor
//
//  Created by Zero Fancy on 13-1-26.
//
//

#import "EditorVisualizer.h"
#import	"GameBase.h"
#import	"World.h"
#import	"GameSadEditorLevel.h"
@implementation EditorVisualizer
-(void) draw
{
	GameSadEditorLevel* lvl = (GameSadEditorLevel*)[GameBase get_game].m_level;
	[lvl draw_acting_range];
	//[lvl draw_selected_mark];
}
@end
