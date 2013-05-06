//
//  BatchDrawManager.h
//  ShotAndRun4
//
//  Created by Zero Fancy on 13-2-11.
//
//

#import <Foundation/Foundation.h>
#include <vector>
#import "CCSpriteBatchNode.h"
@class CCSpriteBatchNode;
@class SpriteBase;
@class GameLayer;
struct batch_data
{
	CCSpriteBatchNode*	batch_node;
	unsigned int		batch_id;//for custom group, default always 0
	GLuint				texture_id;//unique id //TODO: use unsigned int to replace GLuint
	batch_data()
	:batch_node(NULL),batch_id(0),texture_id(0)
	{
		
	}
};

typedef std::vector<batch_data> BATCH_ARRAY;
//TODO move this class to another file
@interface SpriteBatchNodeWithCustomTextureAtlas : CCSpriteBatchNode
-(void) change_texture_atlas:(CCTextureAtlas*) new_atlas;
@end


@interface BatchSpriteManager: NSObject
{
	GameLayer*				m_layer;
	std::vector<batch_data> m_batch_datas;
}
+(id) manager_with_layer:(GameLayer*) layer;
-(void) cleanup;
-(void) add_sprite:(SpriteBase*) sprite;
//remove is needent spritebase will remove all it's spritecomponent form theirs(spritecomponent's) parent
//-(void) remove_spite:(SpriteBase*) sprite;
@end
