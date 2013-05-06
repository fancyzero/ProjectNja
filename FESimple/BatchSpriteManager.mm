//
//  BatchDrawManager.m
//  ShotAndRun4
//
//  Created by Zero Fancy on 13-2-11.
//
//

#import "BatchSpriteManager.h"
#import "cocos2d.h"
#import "SpriteBase.h"
#import "GameLayer.h"

//#import "TextureAtlasWithCumtomQuad.h"
//负责将可以batch的SpriteBase的sprite放到一个batchnode中
//用于提高同屏大量小怪的渲染速度
@implementation SpriteBatchNodeWithCustomTextureAtlas
-(void) change_texture_atlas:(CCTextureAtlas *)new_atlas
{
	
	[textureAtlas_ release];
	textureAtlas_ = new_atlas;
}
@end


@implementation BatchSpriteManager
+(id) manager_with_layer:(GameLayer*) layer
{
	BatchSpriteManager* mgr = [super new];
	mgr->m_layer = layer;
	return mgr;
}
-(void) cleanup
{
	m_batch_datas.clear();
}
-(void) add_sprite:(SpriteBase*) sprite
{
	if ( sprite.sprite_components_count <= 0 )
		return;
	
	//we assum that all 'batchable' spritebase's sub sprite component use same textures
	//look for is there alrady a batchnode contain same textureid
	
	BATCH_ARRAY::iterator it;//linear serach is ok, because there won't be too much different texture ids

	for ( it = m_batch_datas.begin(); it != m_batch_datas.end(); ++it )
	{
		if ( (*it).texture_id == [sprite get_sprite_component:0].texture.name )
		{
			//found it

			for ( int i = 0; i < sprite.sprite_components_count; i++ )
				[(*it).batch_node addChild:[sprite get_sprite_component:i]];
			return;
		}
	}
	
	//if not found , automaticlly create new batchnode if not exist
	assert( [sprite get_sprite_component:0].texture != NULL );
	CCSpriteBatchNode* newnode = [ CCSpriteBatchNode batchNodeWithTexture:[sprite get_sprite_component:0].texture];

	[newnode setShaderProgram:[[CCShaderCache sharedShaderCache] programForKey:@"base_shader"]];
	//TextureAtlasWithCumtomQuad* ta = [[TextureAtlasWithCumtomQuad alloc] initWithTextur:[sprite get_sprite_component:0].texture ] ;
	//[newnode change_texture_atlas:ta];//the batchnode will keep the reference of this texture atlast until it destroyed
	batch_data bd;
	bd.batch_node = newnode;
	bd.batch_id = 0;
	bd.texture_id = [sprite get_sprite_component:0].texture.name;
	m_batch_datas.push_back(bd);
	[m_layer addChild:newnode];
	for ( int i = 0; i < sprite.sprite_components_count; i++ )
		[ newnode addChild:[sprite get_sprite_component:i] ];
	
}



@end
