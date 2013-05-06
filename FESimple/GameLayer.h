//
//  GameLayer.h
//  ShotAndRun4
//
//  Created by Zero Fancy on 12-10-21.
//
//

#import "SpriteBase.h"
@class World;
@class BatchSpriteManager;
@interface GameLayer : CCLayer
{
	BatchSpriteManager* m_batch_sprite_manager;
	World* m_world_;
	float m_move_scale_;
	CGPoint m_desired_position;//for smooth following
	float   m_approaching_speed;//how fast the layer moving to it's desired_position
}
@property (nonatomic, assign) float m_move_scale;
@property (nonatomic, assign) World* m_world;
-(void) cleanup;
-(void) add_sprite:(SpriteBase*) sprite;
-(void) set_desired_position:(CGPoint) pos;
-(void) set_approaching_speed:(float) speed;
-(CGPoint) calc_layer_pt  :(CGPoint) viewport_pos;
-(void) update:(float) delta_time;
@end
