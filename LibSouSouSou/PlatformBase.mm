//
//  PlatformBase.m
//  GameSouSouSou
//
//  Created by Fancyzero on 13-5-5.
//
//
#import "common.h"
#import "PlatformBase.h"
#import "GameBase.h"
#include "Box2D.h"
#import "World.h"
#import "GameSouSouSouLevel.h"



platform_side string_to_platform_side( NSString* str )
{
    if ( [str isEqualToString:@"top"] )
        return ps_top;
    if ( [str isEqualToString:@"bottom"] )
        return ps_bottom;
    if ( [str isEqualToString:@"passable_top"] )
        return ps_passable_top;
    if ( [str isEqualToString:@"passable_bottom"]  )
        return ps_passable_bottom;
    return ps_top;
}

@implementation PlatformBase

- (void)dealloc
{
    [super dealloc];
}

-(int) init_default_values
{
    [ super init_default_values];
    [ self set_batchable:true];
    m_time_before_remove_outof_actrange_ = 0.1;
    return 0;
}
-(platform_side) get_side
{
    return m_side;
}

-(bool) kill_touched
{
    return m_kill_touched;
}
-(void) set_side:( platform_side ) side
{
    m_side = side;
}
class rccb : public b2RayCastCallback
{
public:
    b2Vec2 hit_pos;
    bool hited;
    PlatformBase*   from_platform;
    rccb()
    :hited(false)
    {
    }
    virtual float32 ReportFixture(	b2Fixture* fixture, const b2Vec2& point,const b2Vec2& normal, float32 fraction)
    {
        PhysicsSprite* spr = get_sprite(fixture);
        if ( spr )
        {
            if ( spr.m_parent == from_platform )
            {
                hited = true;
                hit_pos = point;
                return -1;
            }
        }
        return -1;
    }
};
b2RayCastCallback * cb;

-(CGPoint) get_passed_position:(platform_side) from_side :(CGPoint) from_pos
{
    b2Vec2 start, end;
    float ptm = [ GameBase get_ptm_ratio];
    if ( from_side == ps_passable_top )
    {
        end = b2Vec2( from_pos.x / ptm, 2048 / ptm ) ;
        start = b2Vec2( from_pos.x / ptm, -100 / ptm ) ;
    }
    else
    {
        start = b2Vec2( from_pos.x / ptm, 2048 / ptm ) ;
        end = b2Vec2( from_pos.x / ptm, -100 / ptm ) ;
    }
    rccb ccb;
    ccb.from_platform = self;
    [ GameBase get_game ].m_world.m_physics_world->RayCast(&ccb, start, end );
    CGPoint ret = ccp(-10000,-10000);
    if ( ccb.hited )
        ret = ccp(ccb.hit_pos.x * ptm, ccb.hit_pos.y * ptm );
    return ret;
}
-(bool) passable
{
    return m_passable;
}

-(id) init_with_spawn_params:(NSDictionary*) params
{
    self = [super init_with_spawn_params:params];
    m_passable = read_bool_value(params, @"passable", false);
    m_kill_touched = read_bool_value(params, @"kill_touched", false);
    m_killed = false;
    //m_side = string_to_platform_side([params valueForKey:@"side"]);
    [ self set_batchable:true];
    m_time_before_remove_outof_actrange_ = 0.1;
    m_excellented = false;
    return self;
}

-(void) set_excellented
{
    m_excellented = true;
}

-(bool) get_excellented
{
    return m_excellented;
}
-(void) set_killed
{
    m_killed = true;
    [self set_physic_fixed_rotation:0 :false];
    [self set_collision_filter:0 cat:0];
}
-(int) init_with_xml:(NSString *)filename
{
    [super init_with_xml:filename];
    [ self set_collision_filter:cg_player1 | cg_player2 cat:cg_static];
    [ self set_physic_restitution: 0 ];
    [ self set_physic_friction:0 ];
    [self set_batchable:true];
    return  0;
}

-(void) update:(float)delta_time
{
    [super update:delta_time];
    GameSouSouSouLevel* lvl = (GameSouSouSouLevel*)[GameBase get_game].m_level;
    float level_speed = [lvl get_move_speed];
    if ( !m_killed )
        [self set_physic_linear_velocity:0 :-level_speed /[GameBase get_ptm_ratio]:0];
}

@end
