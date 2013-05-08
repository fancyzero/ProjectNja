//
//  SaDEditor.m
//  ShotAndRun4
//
//  Created by Zero Fancy on 12-10-26.
//
//

#import "SaDEditor.h"
#import "cocos2d.h"
#import "SpriteDefManager.h"
#import "GameSouSouSouEditorLevel.h"
#import "EditorController.h"

@implementation SaDEditor


-(id) init
{
	m_level_ = NULL;
	self = [super init];
	m_current_level_filename = NULL;
	[GameBase set_game:self];
	return self;
}
-(void) update :(float) delta_time
{
	[super update:delta_time];
	[m_level_ update:delta_time];
}
-(bool) init_shaders
{
    
	
	CCGLProgram *p = [[CCGLProgram alloc] initWithVertexShaderFilename:@"shaders/base.vs.fsh"
												fragmentShaderFilename:@"shaders/base.ps.fsh"];
	

    
	[p addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
	[p addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
	[p addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
	[p addAttribute:@"a_mask_color" index:3];
    
	[p link];
	[p updateUniforms];
    
    [[CCShaderCache sharedShaderCache] addProgram:p forKey:@"base_shader"];
	[p release];
    
	
	p = [[CCGLProgram alloc] initWithVertexShaderFilename:@"shaders/base.vs.fsh"
												fragmentShaderFilename:@"shaders/multiply_mask_color.fsh"];
	
	
    
	[p addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
	[p addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
	[p addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
	[p addAttribute:@"a_mask_color" index:3];
    
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
	
    [self init_game ];
    
	
    return 0;
}

-(void) init_game
{
	[super init_game];

	m_controller_ = [EditorController new];
    m_level_ = [GameSouSouSouEditorLevel new];
    [ m_level_ reset];
	//[ m_level_ load_from_file:@"levels/test_level.xml"];
}

-(void) new_level
{
	
}

-(void) cleanup
{
    [super cleanup];
	[[[ CCDirector sharedDirector] eventDispatcher] removeAllKeyboardDelegates];
	[[[ CCDirector sharedDirector] eventDispatcher] removeAllMouseDelegates];
	if ( m_controller_ != NULL )
		[m_controller_ release];
	m_controller_ = NULL;
    if ( m_level_ != NULL )
    {
		NSLog(@"%d",(int)[ m_level_ retainCount]);
        assert([ m_level_ retainCount] == 1);
        [  m_level_ release ];
    }
	m_level_ = NULL;
	
}

-(void) open_level: (NSString*) filename
{
	[[GameBase get_game] reset];
	[[GameBase get_game].m_level load_from_file:filename];
	
}

-(void) save_current_level:(NSString*) filename
{
	if ( filename == NULL )
	{
		NSAlert* a = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Nothing to save"];
		[a runModal];
		return;
	}
	if ( m_current_level_filename != NULL )
		[ m_current_level_filename release ];
	m_current_level_filename = [filename copy];
	[m_current_level_filename retain];
	GameSouSouSouEditorLevel* lvl = (GameSouSouSouEditorLevel*) self.m_level ;
	[lvl save_to_file:filename];

}

-(void) save_current_level
{

	[self save_current_level:m_current_level_filename];
}

-(void) add_sprite:(NSString*) class_name location:(CGPoint) loc :(NSDictionary*) params
{
}
-(void) delete_sprite:(SpriteBase*) sprite;//delete the trigger that spawned the sprite
{
    
}
-(bool) is_editor
{
    return true;
}

- (void)dealloc
{
    if ( m_current_level_filename != NULL )
		[m_current_level_filename release];
    [super dealloc];
}
-(ControllerBase*) get_controller
{
	return m_controller_;
}
@end
