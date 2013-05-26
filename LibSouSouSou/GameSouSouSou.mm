//
//  GameSad.m
//  testproj1
//
//  Created by Fancy Zero on 12-3-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameSouSouSou.h"
#import "GameScene.h"
#import "Hero.h"
#import "GameSouSouSouLevel.h"
#include "Box2D.h"
#import "CDAudioManager.h"
#import "World.h"
#import "SpriteDefManager.h"
#import "GameSouSouSou.h"

//NSMutableArray* m_sprites;



@implementation GameSouSouSou


//@synthesize m_level;


-(id) init
{
	self = [super init];
	[GameBase set_game:self];
	m_player = NULL;
	return self;
}

-(void) cleanup
{

    
    [super cleanup];
    if ( m_level_ != NULL )
    {
        assert([ m_level_ retainCount] == 1);
        [  m_level_ release ];
    }
}

-(PlayerBase*) get_player:(int) player_num
{
	return m_player;
}

-(void) set_player:(int) player_num :(PlayerBase*) hero
{
	m_player = hero;
}

+(GameSouSouSou*) get_instance
{

    return (GameSouSouSou*)[GameBase get_game];
}


-(void) init_game
{
	[super init_game];
    m_level_ = [GameSouSouSouLevel new];
    [ m_level_ reset];
    [[GameBase get_game].m_scene setAnchorPoint:ccp(0,0)];
    CGSize device_size = [[CCDirector sharedDirector] winSize];
    float ratio = device_size.width / 768.0;
    [[GameBase get_game].m_scene setScale: ratio ];
 
    [[GameBase get_game].m_scene setPosition:ccp(0,0)];//(1024 - device_size.height) * ratio,0) ];

}

-(void) init_duel
{

}

-(CGRect) get_map_rect
{
    return m_level_.m_map_rect;
}

-(void) update :(float) delta_time
{
	[super update:delta_time];
	//[m_level_ update:delta_time];
}
-(bool) init_shaders
{
    

	CCGLProgram *p = [[CCGLProgram alloc] initWithVertexShaderFilename:@"shaders/base.vs.fsh"
												fragmentShaderFilename:@"shaders/base.ps.fsh"];
    
	[p addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
	[p addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
	[p addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
    //[p addAttribute:@"a_mask_color" index:3];
	[p link];
	[p updateUniforms];
    
    [[CCShaderCache sharedShaderCache] addProgram:p forKey:@"base_shader"];
	[p release];
	p = [[CCGLProgram alloc] initWithVertexShaderFilename:@"shaders/base.vs.fsh"
												fragmentShaderFilename:@"shaders/multiply_mask_color.fsh"];
	
	
    
	[p addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
	[p addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
	[p addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
	//[p addAttribute:@"a_mask_color" index:3];
    
	[p link];
	[p updateUniforms];
    
    [[CCShaderCache sharedShaderCache] addProgram:p forKey:@"multiply_mask_shader"];
	[p release];
	CHECK_GL_ERROR_DEBUG();
    return true;
}

-(int) init_default //just need call onec per run
{

    [ self init_shaders];
	[ SpriteDefManager load_sprite_def_database:@"sprites/base.xml" ];
	[ SpriteDefManager load_sprite_component_def_database:@"sprite_components/base.xml" ];
	[super init_default];
 	//[ self.m_world set_collision_handling_mode: collision_process_durring_simulation];
    [self init_game ];
    

    return 0;
}

@end
