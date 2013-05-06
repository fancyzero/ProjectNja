//
//  SSceneStaticObj.m
//  ShotAndRun4
//
//  Created by Zero Fancy on 12-8-30.
//
//

#import "SSceneStaticObj.h"
#import "Common.h"
@implementation SSceneStaticObj

-(int) post_init
{
	[self set_collision_filter:cg_player1 | cg_player2  cat: cg_static ];
	return 0;
}

-(id) init_with_spawn_params:(NSDictionary *)params
{
	self = [super init_with_spawn_params:params];
	m_breakable_ = read_bool_value(params, @"breakable");
	super.m_health = read_float_value(params, @"init_health");
	return self;
}

-(void) on_health_empty
{
	[self remove_from_game:true];
}
-(void) apply_damage:(float) dmg collision:(struct Collision*) collision
{
	if ( m_breakable_ )
		[super apply_damage:dmg collision:collision];
}
@end
