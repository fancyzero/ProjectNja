//
//  Level.m
//  dodgeandrun
//
//  Created by Fancy Zero on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Level.h"
#include <vector>
#import "World.h"
#import "SpriteXMLParser.h"
#import "PhysicsDebuger.h"
#import "GameScene.h"
#include <box2d.h>
#import "Common.h"
#import "GameBase.h"

level_progress_trigger::level_progress_trigger()
:params(NULL),progress_pos(0),id(0)
{
}
level_progress_trigger::level_progress_trigger(const level_progress_trigger& cpy)
{

	params = NULL;
	progress_pos = cpy.progress_pos;
	id = cpy.id;
	set_params(cpy.params);
}
void level_progress_trigger::set_params(NSMutableDictionary* p)
{
	if ( params != NULL )
	{
		//NSLog(@"%p releasing %ld", params, [params retainCount]);
		[params release];
		params = NULL;
	}

	params = [NSMutableDictionary dictionaryWithDictionary: p ];
	
	[params retain];
	//NSLog(@"set params from %p to %p %ld", p, params,params.retainCount);
}

level_progress_trigger::~level_progress_trigger()
{
	if ( params != NULL )
	{
		//NSLog(@"%p releasing %ld", params, [params retainCount]);
		[params release];
		
		params = NULL;
	}
}



@implementation LevelParser

-(id) init
{
	self = [super init];
	return self;
}

-(void) set_progres_offset:(float) offset
{
    m_progress_offset = offset;
}

-(void) set_position_offset:(CGPoint) offset
{
    m_position_offset = offset;
}


-(void) on_node_begin:(NSString *)cur_path nodename:(NSString *)node_name attributes:(NSDictionary *)attributes
{
    if ( [ cur_path isEqualToString:@"/xml" ] )
    {
        if ( [ node_name isEqualToString:@"level" ] )
        {
			[ m_level set_map_size:[[ attributes valueForKey:@"map_width" ] intValue ]:[[ attributes valueForKey:@"map_height" ] intValue]];
		}
    }
    if ( [ cur_path isEqualToString:@"/xml/level/acting_range" ] )
    {
        if ( [ node_name isEqualToString:@"keyframe" ] )
        {
			level_acting_range_keyframe k;
			CGPoint p;
			p = read_CGPoint_value(attributes, @"pos", ccp(0, 0));
			k.act_rect.origin = p;
			p = read_CGPoint_value(attributes, @"size", ccp(0, 0));
			k.act_rect.size.width = p.x;
			k.act_rect.size.height = p.y;
			k.progress = read_float_value(attributes, @"progress");
			[m_level add_acting_range_keyframe: k];
		}
    }
	if ( [ cur_path isEqualToString:@"/xml/level/actions"])
	{
		if ( [ node_name isEqualToString:@"action" ] )
		{
			level_progress_trigger trigger;
			trigger.progress_pos = [[attributes valueForKey:@"progress"] floatValue];// + m_current_progress_parsed;
			m_current_progress_parsed = trigger.progress_pos;
			trigger.set_params( [NSMutableDictionary dictionaryWithDictionary:attributes]);
			//NSLog(@"add trigger %@",trigger.get_params());
            if ( m_position_offset.x != 0 || m_position_offset.y != 0 )
            {
                CGPoint pt = read_CGPoint_value(trigger.get_params(), @"init_position", ccp(0,0));
                pt = ccpAdd( pt, m_position_offset);
                [trigger.get_params() setValue:[NSString stringWithFormat:@"%f,%f", pt.x, pt.y] forKey:@"init_position"];
            }
			[m_level add_trigger: trigger];
			//NSLog(@"%p temp trigger %ld", &trigger, [trigger.get_params() retainCount]);
			
		}
		//trigger.
	}
}


-(void) on_node_end:(NSString *)cur_path nodename:(NSString *)node_name
{
    
}
@end

@implementation LevelBase

@synthesize m_acting_range = m_acting_range_;
@synthesize m_map_rect = m_map_rect_;
@synthesize m_need_reset;
@synthesize m_level_progress = m_level_progress_;
@synthesize m_next_trigger;//下一个未处理的trigger
@synthesize m_acting_range_velocity = m_acting_range_velocity_;

-(id) init
{
	m_next_trigger = 0;
    m_need_reset = false;
	m_acting_range_body_ = NULL;
    return self;
}


-(void) dealloc
{
	
	std::vector<level_progress_trigger>::iterator it;
	//for ( it = m_level_triggers.begin(); it != m_level_triggers.end(); it++)
	//{
	//	[(*it).params release];
	//}
	m_level_triggers.clear();
	[ super dealloc];
}

-(void) set_filename: (NSString*) filename
{
	m_filename_ = filename;
}
-(void) add_dps:(float) dps :(GameObjBase*) sender
{
    
}

-(void) add_acting_range_keyframe:(const level_acting_range_keyframe &)key
{
	m_acting_range_keyframes_.push_back(key);
}

-(int)	add_trigger: (level_progress_trigger) trigger
{
	
	trigger.id = m_current_trigger_id;
	m_current_trigger_id++;
	m_level_triggers.push_back(trigger);
	return trigger.id;
}

-(int) load_from_file:(NSString*) filename
{
	m_filename_ = filename;
    NSURL *xmlURL = [NSURL fileURLWithPath:[[CCFileUtils sharedFileUtils] fullPathFromRelativePath:filename]];
    NSXMLParser* xmlparser = [[ NSXMLParser alloc ] initWithContentsOfURL:xmlURL];
	SpriteXMLParser *sxmlparser = [[ SpriteXMLParser alloc] init:NULL];
    LevelParser* my_parser = [ LevelParser new];
	my_parser->m_level = self;
	[ sxmlparser->m_parsers addObject: my_parser ];
	[ xmlparser setDelegate:sxmlparser];
	BOOL ret = [ xmlparser parse ];
	assert( ret );
	ret = 0;
	
	[sxmlparser release];
	[xmlparser release];
	return 0;
}

-(void) updaet_acting_range_physic
{
	float ptm = [GameBase get_ptm_ratio];
	if ( m_acting_range_body_ != NULL )
		[GameBase get_game].m_world.m_physics_world->DestroyBody(m_acting_range_body_);
	b2BodyDef bodydef;
	bodydef.type = b2_staticBody;
	bodydef.position = b2Vec2(0,0);
	b2Body* body = [GameBase get_game].m_world.m_physics_world->CreateBody(&bodydef);
	
	b2EdgeShape edge;
	float x1, y1,x2,y2;
	x1 = m_acting_range_.origin.x/ptm;
	y1 = m_acting_range_.origin.y/ptm;
	x2 = (m_acting_range_.origin.x + m_acting_range_.size.width) / ptm;
	y2 = (m_acting_range_.origin.y + m_acting_range_.size.height) / ptm;
	edge.Set(b2Vec2(x1,y1),b2Vec2(x2,y1));
	b2Filter filter;
	filter.categoryBits=cg_acting_range;
	filter.maskBits=cg_player1 | cg_player2 | cg_acting_range;
	
	body->CreateFixture(&edge,1)->SetFilterData(filter);
	edge.Set(b2Vec2(x2,y1),b2Vec2(x2,y2));
	body->CreateFixture(&edge,1)->SetFilterData(filter);;
	edge.Set(b2Vec2(x2,y2),b2Vec2(x1,y2));
	body->CreateFixture(&edge,1)->SetFilterData(filter);;
	edge.Set(b2Vec2(x1,y2),b2Vec2(x1,y1));
	body->CreateFixture(&edge,1)->SetFilterData(filter);;
	
	
	m_acting_range_body_  = body;
	
}

-(void) set_acting_range : (CGRect)rect
{
	m_acting_range_ = rect;
	//NSLog(@"set act range: %f, %f", rect.size.width, rect.size.height);
	[self updaet_acting_range_physic];
}

-(void) on_sprite_dead: (SpriteBase*) sprite{}
-(void) on_remove_obj: (GameObjBase*) obj{}
-(void) on_sprite_spawned: (SpriteBase*) sprite{}
-(void) on_add_obj: (GameObjBase*) obj{}
-(void) on_level_start{}
-(void) reset
{
	if ( m_acting_range_body_ != NULL )
	{
		[GameBase get_game].m_world.m_physics_world->DestroyBody(m_acting_range_body_);
		m_acting_range_body_ = NULL;
	}
	m_level_triggers.clear();
	m_current_trigger_id = 0;
	m_next_trigger = 0;
	m_level_progress_ = 0;
	if ( m_filename_ != nil)
		[self load_from_file:m_filename_];
	
};
-(void) request_reset
{
    m_need_reset = true;
}

-(void) advance_level_progress:(float) delta_time
{
    m_level_progress_ += delta_time;
}

-(void) update:(float)delta_time
{
    if ( m_need_reset )
    {
        [ self reset];
        m_need_reset = false;
    }
	[ self advance_level_progress :delta_time ];
};
-(void) set_map_size:(int)w :(int)h
{
    m_map_rect_.origin.x = 0;
    m_map_rect_.origin.y = 0;
    m_map_rect_.size.width = w;
    m_map_rect_.size.height = h;
}

-(NSArray*) get_sprite_by_trigger_id:(int) tid
{
    NSMutableArray* sprites = [NSMutableArray array];
    
    for (GameObjBase* spr in [GameBase get_game].m_world.m_gameobjects)
    {
        if ( [spr isKindOfClass:[SpriteBase class]] )
        {
            if ( [((SpriteBase*)spr) get_trigger_id] == tid )
                [sprites addObject:spr];
        }
    }
    return sprites;
}

-(level_progress_trigger*) get_trigger_by_id:(int) tid
{
	std::vector<level_progress_trigger>::iterator it;
	for ( it = m_level_triggers.begin(); it != m_level_triggers.end(); ++it )
	{
		if ( (*it).id == tid )
			return &(*it);
	}
	return NULL;
}


-(bool) triggering_trigger:(level_progress_trigger*) trigger
{
	GameBase* game = [GameBase get_game];
	trigger_action_type acttype = string_to_action_type( [trigger->get_params() objectForKey:@"act"]);
	NSString* class_name = [trigger->get_params() objectForKey:@"class"];
	if ( acttype == ta_addobj )
	{
		//if ( m_level_triggers[i].progress_pos < self.m_level_progress )
		//{
		Class c = NSClassFromString( class_name );
		assert( [c isSubclassOfClass:[GameObjBase class]]);
		GameObjBase* object = [[ c alloc] init_with_spawn_params:trigger->get_params()];
		[object set_trigger_id:trigger->id];
		
		if ( [trigger->get_params() objectForKey:@"layer"] != NULL )
			[game.m_world add_gameobj:object layer:[trigger->get_params() valueForKey:@"layer"] ];
		else
			[game.m_world add_gameobj:object  ];
        return true;
		//[game add_game_obj_by_classname:trigger->script pos_x:0 pos_y:0];
		
		//}
		//else
		//	break;
	}
	if ( acttype == ta_rand_addobj )
	{
		//if ( trigger->progress_pos < self.m_level_progress )
		//{
		Class c = NSClassFromString( class_name );
		assert( [c isSubclassOfClass:[GameObjBase class]]);
		
		int count = read_int_value(trigger->get_params(), @"rand_add_count");
		CGPoint orig = read_CGPoint_value(trigger->get_params(), @"rand_add_orig", ccp(0,0));
		CGPoint range = read_CGPoint_value(trigger->get_params(), @"rand_add_range", ccp(0,0));
		float scale_base = read_float_value(trigger->get_params(), @"rand_add_scale_base");
		float scale_range = read_float_value(trigger->get_params(), @"rand_add_scale_range");
		for ( int j = 0; j < count; j++ )
		{
			float s = (scale_base + (rand()/float(RAND_MAX))*scale_range);
			NSMutableString* val = [NSString stringWithFormat:@"%f" ,s];
			
			[trigger->get_params() setObject:val forKey:@"init_scale"];
			val =[NSString stringWithFormat:@"%d", rand()%360];
			[trigger->get_params() setObject:val forKey:@"init_rotation"];
			val =[NSString stringWithFormat:@"%f,%f", orig.x + rand()%(int)range.x, orig.y + rand()%(int)range.y];
			[trigger->get_params() setObject:val forKey:@"init_position"];
			GameObjBase* object = [[ c alloc] init_with_spawn_params:trigger->get_params()];
			
			[object set_trigger_id:trigger->id];
			
			if ( [trigger->get_params() objectForKey:@"layer"] != NULL )
				[game.m_world add_gameobj:object layer:[trigger->get_params() valueForKey:@"layer"] ];
			else
				[game.m_world add_gameobj:object  ];
		}
        return true;
	}
    return false;
}

-(float) get_max_level_progress
{
	float max_trigger_progress = 0;
	std::vector<level_progress_trigger>::iterator it;
	for( it = m_level_triggers.begin(); it != m_level_triggers.end(); ++it )
	{
		if ( max_trigger_progress < (*it).progress_pos )
			max_trigger_progress = (*it).progress_pos;
	}
	float max_acting_range_progress = 0;
	std::vector<level_acting_range_keyframe>::iterator it2;
	for( it2 = m_acting_range_keyframes_.begin(); it2 != m_acting_range_keyframes_.end(); ++it2 )
	{
		if ( max_acting_range_progress < (*it2).progress )
			max_acting_range_progress = (*it2).progress;
	}
	return fmax( max_acting_range_progress, max_trigger_progress);
}
@end

trigger_action_type string_to_action_type( NSString* actstr )
{
	trigger_action_type acttype = ta_unknown;
	if ( [actstr isEqualToString:@"add_obj"] )
	{
		acttype = ta_addobj;
	}
	if ( [actstr isEqualToString:@"rand_add_obj"] )
	{
		acttype = ta_rand_addobj;
	}
	return acttype;
}