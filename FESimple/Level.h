//
//  Level.h
//  dodgeandrun
//
//  Created by Fancy Zero on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameObjBase.h"
#include <vector>

enum trigger_action_type
{
    ta_unknown,
	ta_addobj,
	ta_rand_addobj,
};

trigger_action_type string_to_action_type(NSString* actstr);

@class SpriteBase;
struct level_progress_trigger
{

	level_progress_trigger();
	level_progress_trigger(const level_progress_trigger& cpy);
	~level_progress_trigger();
	
	float progress_pos;
	int id;
	NSMutableDictionary* get_params()
	{
		return params;
	}
	void set_params(NSMutableDictionary* p);
protected:
	NSMutableDictionary* params;
};

struct level_acting_range_keyframe
{
	CGRect	act_rect;
	float	progress;
};


@interface LevelBase : GameObjBase
{
	NSString*	m_filename_;
	std::vector<level_progress_trigger>	m_level_triggers;

	CGRect	m_map_rect_;
	struct b2Body*	m_acting_range_body_;
	float	m_level_progress_;
	std::vector<level_acting_range_keyframe> m_acting_range_keyframes_;

	@protected
	CGPoint m_acting_range_velocity_;
	CGRect	m_acting_range_;
	int		m_current_trigger_id;
}
-(void) add_dps:(float) dps :(GameObjBase*) sender;
-(void) set_filename: (NSString*) filename;
-(void) add_acting_range_keyframe :(const level_acting_range_keyframe&) key;
-(void) set_acting_range : (CGRect)rect;
-(int)	add_trigger: (struct level_progress_trigger) trigger;//再最末尾添加trigger
-(int)	load_from_file:(NSString*) filename;
-(void) on_sprite_dead: (SpriteBase*) sprite;
-(void) on_remove_obj: (GameObjBase*) obj;
-(void) on_sprite_spawned: (SpriteBase*) sprite;
-(void) on_add_obj: (GameObjBase*) obj;
-(void) on_level_start;
-(void) reset;
-(void) update:(float)delta_time;
-(void) set_map_size:(int)w :(int)h;
-(void) update:(float)delta_time;
-(void) request_reset;
-(float) get_max_level_progress;
-(bool) triggering_trigger:(level_progress_trigger*) trigger;
-(NSArray*) get_sprite_by_trigger_id:(int) tid;
-(void) advance_level_progress:(float) delta_time;
//for editor
-(struct level_progress_trigger*) get_trigger_by_id:(int) tid;

@property (nonatomic, assign, readonly) CGRect  m_acting_range;
@property (nonatomic, assign, readonly) CGPoint  m_acting_range_velocity;
@property (nonatomic, assign,readonly) bool		m_need_reset;
@property (nonatomic, assign,readonly) CGRect	m_map_rect;
@property (nonatomic, assign) float	m_level_progress;
@property (nonatomic, assign) int	m_next_trigger;
@end

