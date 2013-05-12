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
-(int) init_default_values
{
    [ super init_default_values];
    return 0;
}
-(platform_side) get_side
{
    return m_side;
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
        if ( fixture->GetUserData() != nil )
        {
            PhysicsSprite* spr = (PhysicsSprite*)fixture->GetUserData();
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
    if ( [params valueForKey:@"passable"] != nil )
        m_passable = [[params valueForKey:@"passable"] boolValue];
    else
        m_passable = false;
    
    m_side = string_to_platform_side([params valueForKey:@"side"]);
    return self;
}

-(int) init_with_xml:(NSString *)filename
{
    [super init_with_xml:filename];
    [ self set_collision_filter:cg_player1 | cg_player2 cat:cg_static];
    [ self set_physic_restitution: 0 ];
    [ self set_physic_friction:0 ];
    return  0;
}

@end
