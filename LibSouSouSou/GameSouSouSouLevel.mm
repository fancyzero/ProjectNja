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
#import "RepeatBG.h"

float god_safe_width = 300;

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
    return m_move_speed + [(Hero*)(get_player(-1)) get_speed];
}

-(float) get_total_moved
{
    return m_total_moved;
}

-(void)reset
{
    init_global_config();
	m_filename_ = nil;
    [super reset];
    if ( m_bg1 != nil )
       [ m_bg1 release];
    m_total_moved = 0;

    m_god_safe_insert_pos_begin = m_cur_god_safe_insert_pos = -god_safe_width*3;
    m_god_safe_insert_pos = god_safe_width*5 + m_cur_god_safe_insert_pos;//m_god_safe_insert_pos必须是god_safe_width的整数倍
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
    
    m_bg1 = [[RepeatBG new] initWithFile:@"pic/bg.png"];
    [m_bg1 setAnchorPoint:ccp(0,0)];
    
    float ratio = [[CCDirector sharedDirector] winSize].height / [[CCDirector sharedDirector] winSize].width;
    if ( ratio < 1 )
        ratio = 1/ ratio;
    [m_bg1 setPosition:ccp(-1024*ratio,0)];
    m_bg1.m_width = 1024*ratio;
    m_bg1.scale = ratio;
    ccTexParams tp;
    tp.magFilter = GL_LINEAR;
    tp.minFilter = GL_LINEAR;
    tp.wrapS = GL_REPEAT;
    tp.wrapT = GL_REPEAT;
    [m_bg1.texture setTexParameters:&tp];
    
    [[GameBase get_game].m_scene.m_layer addChild:m_bg1 ];
    
    if ( get_float_config(@"debug_physic") > 1 )
	{
		physics_debug_sprite* pds = [ physics_debug_sprite new ];
		pds.zOrder = 200; 
		[[GameBase get_game].m_scene.m_layer addChild:pds ];
	}
	m_cur_path = 0;
    
    NSString* sector_file = [[self applicationDocumentsDirectory] stringByAppendingString: [self rand_next_sector]];
    
    [self attach_sector:sector_file :ccp(-1024,0)];
    m_moved_pos = 1024;
    m_level_progress_ = 0;
    if ( m_score_display != nil )
    {
        //TODO: memory leak?
        [m_score_display release];
    }
    m_score_display = [[ [BumppingScoreDisplay alloc] initWithString:@"0" charMapFile:@"fonts/fps_images.png" itemWidth:12 itemHeight:32 startCharMap:'.'] autorelease];
    [m_score_display display_integer_value];
    [m_score_display setRotation:90];
    
    [ m_score_display init_default ];
    
    [[[GameBase get_game].m_scene get_layer_by_name:@"ui"] addChild:m_score_display];
    [m_score_display set_auto_bump: false];
    [m_score_display retain];
    
}

-(void) attach_sector:(NSString*) filename :(CGPoint) at_pos
{
    //NSLog(@"attach %d sector %@ at %f, %f", m_sector_attached, filename, at_pos.x, at_pos.y);
    m_sector_attached ++;
    if ( (m_sector_attached % 5 == 0) && (m_sector_attached != 0) )
        m_move_speed = get_global_config().level_move_speed  * (1 + get_global_config().level_move_accleration*(m_sector_attached / 5));
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
        
        float w = (1024 - 300 )/ptm;
        float h = 768 / ptm;
        float xoffset = -(1024 - 300)/ptm;
        
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
-(NSString*) rand_next_sector
{
    NSString* rnd_file;
    if ( [ get_global_config().test_maps count ] > 0 )
    {
        return [get_global_config().test_maps objectAtIndex: m_sector_attached % [ get_global_config().test_maps count ]];
    }
    
    
    if ( m_sector_attached == 0 )
        rnd_file = @"/levels/sector1.xml";
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
    return rnd_file;
};

-(void)update:(float)delta_time
{
    [ super update:delta_time];
	
	[m_score_display setPosition:ccp(1200,768/2)];
    [m_score_display set_default_scale: 3];
    float score = [(Hero*)get_player(-1) get_score ];
    [m_score_display set_value:score ];
	// update acting range
	CGRect rc_act;
    rc_act.origin = ccp(-1024,0);
    rc_act.size.width = 1024;
    rc_act.size.height = 768;
    
    [self set_acting_range:rc_act];
    
    /*
     添加物体阶段
     */
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
    
    while ( [get_player(-1) is_god] && m_cur_god_safe_insert_pos < m_god_safe_insert_pos )
    {
        //        NSLog(@"add god safe %f %f", m_total_moved, m_god_safe_insert_pos-1024 );
        
        Platform* safe_platform = nil;
        safe_platform = [Platform new] ;
        [ safe_platform init_default_values];
        [ safe_platform init_with_xml:@"sprites/base.xml:earth_4"];
        [ safe_platform set_physic_position:0 :ccp(m_cur_god_safe_insert_pos ,0)];
        [ safe_platform set_zorder:300];
        [ [GameBase get_game].m_world add_gameobj:safe_platform layer:@"game"];
        safe_platform = [Platform new] ;
        [ safe_platform init_default_values];
        [ safe_platform init_with_xml:@"sprites/base.xml:earth_4"];
        [ safe_platform set_physic_position:0 :ccp(m_cur_god_safe_insert_pos ,768)];
        [ safe_platform set_zorder:300];
        [ safe_platform set_physic_rotation:0 :180];
        [ [GameBase get_game].m_world add_gameobj:safe_platform layer:@"game"];
        //NSLog(@"new safe insert pos\t\t%0.2f\t\t%.02f", m_cur_god_safe_insert_pos, m_total_moved );
        m_cur_god_safe_insert_pos += god_safe_width;
        
    }
    /*
     添加物体阶段 结束
     移动场景开始
     */
    
    m_moved_pos += [self get_move_speed] * delta_time;
    m_total_moved += [self get_move_speed] * delta_time;
    m_cur_god_safe_insert_pos -= [self get_move_speed] * delta_time;
    if ( m_cur_god_safe_insert_pos < m_god_safe_insert_pos_begin )
        m_cur_god_safe_insert_pos = m_god_safe_insert_pos_begin;
    m_bg1.m_offset = fmod(m_total_moved/6.0,1024);
    
    if ( m_moved_pos >= m_current_sector_width )
    {
        NSString* rnd_file;
        
        rnd_file = [ self rand_next_sector ];
        NSString* sector_file = [[self applicationDocumentsDirectory] stringByAppendingString: rnd_file];
        float fix = m_moved_pos - m_current_sector_width;
        CGPoint at_pos = ccp( -fix, 0);
        [ self attach_sector:sector_file :at_pos];
        m_acting_range_keyframes_.clear();
        m_moved_pos = fix;
    }

}


-(void) append_from_file:(NSString*) filename :(CGPoint) at_pos
{
	m_filename_ = filename;
    
    LevelParser* my_parser = [ LevelParser new];
    [my_parser set_position_offset:at_pos];
	my_parser->m_level = self;
    [my_parser parse_level_from_file:filename];
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

