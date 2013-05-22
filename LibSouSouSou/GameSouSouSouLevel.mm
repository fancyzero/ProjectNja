//
//  GameSadLevel.m
//  ShotAndRun4
//
//  Created by Zero Fancy on 12-11-20.
//
//

#import "GameSouSouSou.h"
#import "GameSouSouSouLevel.h"
#import "Hero.h"
#import "Controller.h"

#include <vector>
#import "World.h"
#import "SpriteXMLParser.h"
#import "PhysicsDebuger.h"
#import "GameScene.h"
#include <box2d.h>
#import "Common.h"
#import "Platform.h"
#import "GameBase.h"
#import "SCoin.h"
#import "BumppingScoreDisplay.h"
#import "GlobalConfig.h"
@implementation GameSouSouSouLevel
int reset_count = 0;
- (NSString *)applicationDocumentsDirectory
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

-(float) get_move_speed
{
    return m_move_speed;
}

-(void)reset
{
    init_global_config();
	m_filename_ = nil;
    [super reset];

    m_sector_attached = 0;

    m_move_speed = get_global_config().level_move_speed;
    m_moved_pos = 0;
    m_current_sector_width = 0;
    GameBase* game = [GameBase get_game];
    [ game cleanup_world ];
	
    //[ super set_map_size:1024 - 160 :800];
    World* world = [ GameBase get_game].m_world;
    Hero* hero;
    hero = [ Hero new];
    hero.m_name = @"Hero";
	CGPoint spawnpos;
	spawnpos.x = 300 - 1024;
	spawnpos.y = 768 / 2 ;
    [ hero set_physic_position:0 : spawnpos ];
    [ world add_gameobj:hero ];
    
    Controller* ctrl = [ Controller new ];
	[[GameBase get_input_device] set_controller: ctrl];
	//NSLog(@"controller retaincount:%d", [ctrl retainCount]);
    [ ctrl set_player:hero ];
	[ hero set_controller: ctrl ];
    [ ctrl set_pose:single_player ];
    
    m_bg1 = [SpriteBase new];
    [m_bg1 init_with_xml:@"sprites/base.xml:bg1"];
    [m_bg1 set_position: 0 y:768/2];
    [[GameBase get_game].m_world add_gameobj:m_bg1 layer:@"bg2"];
    
    if ( get_float_config(@"debug_physic") > 1 )
	{
		physics_debug_sprite* pds = [ physics_debug_sprite new ];
		pds.zOrder = 200;
		[[GameBase get_game].m_scene.m_layer addChild:pds ];
	}
	m_cur_path = 0;
    
    NSString* sector_file = [[self applicationDocumentsDirectory] stringByAppendingString: @"/levels/sector1.xml"];
    
    [self attach_sector:sector_file :ccp(-1024,0)];
    m_moved_pos = 1024;
    m_level_progress_ = 0;
    if ( m_score_display != nil )
    {
        //TODO: memory leak?
        
        [m_score_display release];

    }
    m_score_display = [ [BumppingScoreDisplay alloc] initWithString:@"0" charMapFile:@"fonts/fps_images.png" itemWidth:12 itemHeight:32 startCharMap:'.'];
    [m_score_display display_integer_value];

    
    [ m_score_display init_default ];
    [[[GameBase get_game].m_scene get_layer_by_name:@"ui"] addChild:m_score_display];
        [m_score_display set_auto_bump: false];
    [m_score_display retain];
    
}

-(void) attach_sector:(NSString*) filename :(CGPoint) at_pos
{
    NSLog(@"attach %d sector %@ at %f, %f", m_sector_attached, filename, at_pos.x, at_pos.y);
    m_sector_attached ++;
    if ( (m_sector_attached % 5 == 0) && (m_sector_attached != 0) )
        m_move_speed = get_global_config().level_move_speed  * get_global_config().level_move_accleration*(m_sector_attached / 5);
    if ( m_move_speed > get_global_config().level_move_speed_max )
        m_move_speed = get_global_config().level_move_speed_max;
    m_acting_range_keyframes_.clear();
    [self append_from_file:filename :at_pos];
    m_level_progress_ = 0;
    m_current_sector_width = m_acting_range_keyframes_[0].act_rect.size.width ;
    m_moved_pos = 0;
}

-(void) updaet_acting_range_physic
{
	float ptm = [GameBase get_ptm_ratio];
	if ( m_acting_range_body_ == NULL )
    {
        b2BodyDef bodydef;
        bodydef.type = b2_staticBody;
        bodydef.position = b2Vec2(0,0);
        b2Body* body = [GameBase get_game].m_world.m_physics_world->CreateBody(&bodydef);
        
        float w = (1024 - 300)/ptm;
        float h = 768 / ptm;
        float xoffset = (-1024 + 300)/ptm;
        
        b2PolygonShape shape;
        shape.SetAsBox(w/2, h/2, b2Vec2(w/2 + xoffset, h/2), 0);
        b2Filter filter;
        filter.categoryBits=cg_acting_range;
        filter.maskBits=cg_player1 | cg_player2 | cg_acting_range;
        
        b2Fixture* fix = body->CreateFixture(&shape,1);
        fix->SetFriction( 0 );
        fix->SetRestitution(0);
        fix->SetFilterData(filter);
        
        
        m_acting_range_body_  = body;
    }
    
	
}

-(void)update:(float)delta_time
{
    [ super update:delta_time];
	
	[m_score_display setPosition:ccp(200,730)];
    float score = [(Hero*)get_player(-1) get_score ];
    [m_score_display set_value:score ];
	// update acting range
	CGRect rc_act;
    rc_act.origin = ccp(-1024,0);
    rc_act.size.width = 1024;
    rc_act.size.height = 768;
    
    [self set_acting_range:rc_act];
    
    
	if ( super.m_next_trigger < m_level_triggers.size() )
	{
		for ( int i = super.m_next_trigger; i < m_level_triggers.size(); ++i )
		{
			if ( m_level_triggers[i].progress_pos < self.m_level_progress )
			{
				[ self triggering_trigger:&m_level_triggers[i]];
				super.m_next_trigger = i+1;
			}
			else
			{
				break;
			}
		}
	}
    
    m_moved_pos += m_move_speed * delta_time;
    
    
    
    if ( m_moved_pos >= m_current_sector_width )
    {
        NSString* rnd_file;
        if ( m_sector_attached == 1 )
            rnd_file = @"/levels/sector2.xml";
        else if ( (m_sector_attached % 10 == 0) && (m_sector_attached != 0) )
        {
            if ( rand() %2 )
                rnd_file = @"/levels/sector10.xml";
            else
                rnd_file = @"/levels/sector11.xml";
        }
        else
            rnd_file = [NSString stringWithFormat:@"/levels/sector%d.xml", rand() % 7 +  3 ];

        NSString* sector_file = [[self applicationDocumentsDirectory] stringByAppendingString: rnd_file];
        float fix = m_moved_pos - m_current_sector_width;
        CGPoint at_pos = ccp( -fix, 0);
        [ self attach_sector:sector_file :at_pos];
        m_acting_range_keyframes_.clear();
        m_moved_pos = fix;
    }
    

    //m_move_speed += get_global_config().level_move_accleration * delta_time;
    //if ( m_move_speed > get_global_config().level_move_speed_max )
     //   m_move_speed = get_global_config().level_move_speed_max;
}

-(void) append_from_file:(NSString*) filename :(CGPoint) at_pos
{
	m_filename_ = filename;
    NSURL *xmlURL = [NSURL fileURLWithPath:[[CCFileUtils sharedFileUtils] fullPathFromRelativePath:filename]];
    NSXMLParser* xmlparser = [[ NSXMLParser alloc ] initWithContentsOfURL:xmlURL];
	SpriteXMLParser *sxmlparser = [[ SpriteXMLParser alloc] init:NULL];
    LevelParser* my_parser = [ LevelParser new];
    [my_parser set_position_offset:at_pos];
	my_parser->m_level = self;
	[ sxmlparser->m_parsers addObject: my_parser ];
	[ xmlparser setDelegate:sxmlparser];
	BOOL ret = [ xmlparser parse ];
	assert( ret );
	ret = 0;
	
	[sxmlparser release];
	[xmlparser release];
}

-(void) on_sprite_dead: (SpriteBase*) sprite
{
    if ( [sprite isKindOfClass:[ Hero class]] )
    {
		// sleep( 3 );
        [ self request_reset];
    }
}
-(void) on_remove_obj: (GameObjBase*) obj
{
}
-(void) on_sprite_spawned: (SpriteBase*) sprite
{
}
-(void) on_add_obj: (GameObjBase*) obj
{
}
-(void) on_level_start
{
}

@end

