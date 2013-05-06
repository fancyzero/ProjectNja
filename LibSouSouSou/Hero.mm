//
//  Hero.m
//  GameSouSouSou
//
//  Created by Fancyzero on 13-5-4.
//
//

#import "Hero.h"
#import "Common.h"
#include <Box2D.h>

@implementation Hero

-(id) init
{
    self = [super init];
    [self init_with_xml:@"sprites/base.xml:ninja" ];
    [ self set_physic_position:0 :ccp(0,0)];

    [ self set_collision_filter:collision_filter_player() cat:cg_player1];
    [ self set_physic_linear_damping:0 :2 ];
    [ self set_physic_fixed_rotation:0 :true ];
    b2Fixture *f = m_sprite_components[0].m_phy_body->GetFixtureList();
    while( f )
    {
        f->SetFriction(0);
        f = f->GetNext();
    }
    return self;
}

-(void) go_left
{
    m_velocity = ccp( 0, 4000 );
}

-(void) go_right
{
    m_velocity = ccp( 0, -4000 );
}


-(void) update:(float)delta_time
{
    [ self apply_force_center:0 :m_velocity.x force_y:m_velocity.y ];
    if ( fabs([ self get_physic_linear_velocity:0].y) >  0.1 )
    {
        m_sprite_components[0].scaleY = 1.5;
        m_sprite_components[0].scaleX = 0.7;
    }
    else
    {
        m_sprite_components[0].scale = 1;
    }
    if ( [self get_physic_position:0].x < 100 )
        [ self apply_force_center:0 :50 force_y:0];
    //[self set_physic_linear_velocity:0 :m_velocity.x :m_velocity.y ];
}
@end
