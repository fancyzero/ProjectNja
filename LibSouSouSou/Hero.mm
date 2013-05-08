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
    [ self set_zorder:100];
    m_player_side = ps_can_land_bottom;
    return self;
}

-(void) go_left
{
    m_velocity = ccp( 0, 4000 );
    if ( m_player_side != ps_can_land_top )
    {
    
        [m_sprite_components[0] setFlipY:TRUE];
        CGPoint anchor = m_sprite_components[0].anchorPointInPoints;
        anchor.y = m_sprite_components[0].contentSize.height - anchor.y;
        anchor.x /= m_sprite_components[0].contentSize.width;
        anchor.y /= m_sprite_components[0].contentSize.height;
        [ m_sprite_components[0] setAnchorPoint: anchor ];
    }
    m_player_side = ps_can_land_top;
}

-(void) go_right
{
    m_velocity = ccp( 0, -4000 );
    if ( m_player_side != ps_can_land_bottom )
    {
        [m_sprite_components[0] setFlipY:FALSE];
        CGPoint anchor = m_sprite_components[0].anchorPointInPoints;
        anchor.y = m_sprite_components[0].contentSize.height - anchor.y;
        anchor.x /= m_sprite_components[0].contentSize.width;
        anchor.y /= m_sprite_components[0].contentSize.height;
        [ m_sprite_components[0] setAnchorPoint: anchor ];
    }
    m_player_side = ps_can_land_bottom;
}

-(void) on_begin_contact :( struct b2Contact* ) contact
{
    b2Fixture* fa = contact->GetFixtureA();
    b2Fixture* fb = contact->GetFixtureB();
	PhysicsSprite* sprite_comp_A = (PhysicsSprite*)fa->GetUserData();
	PhysicsSprite* sprite_comp_B = (PhysicsSprite*)fb->GetUserData();
	SpriteBase* spriteA = NULL;
	SpriteBase* spriteB = NULL;
	if ( sprite_comp_A != NULL )
		spriteA = sprite_comp_A.m_parent;
	if ( sprite_comp_B != NULL )
		spriteB = sprite_comp_B.m_parent;
    SpriteBase* other;
    if ( spriteA != self )
        other = spriteB;
    else
        other = spriteA;
    if ( other != NULL)
    {
        if ( [other isKindOfClass:[PlatformBase class]] )
        {
            PlatformBase* platform = (PlatformBase*) other;
            switch ( [platform get_side] )
            {
                case ps_top:
                    if (m_player_side == ps_can_land_bottom )
                        contact->SetEnabled( false );
                    break;
                case ps_bottom:
                    if (m_player_side == ps_can_land_top )
                        contact->SetEnabled( false );
                case ps_passable_top:
                    if (m_player_side == ps_can_land_bottom )
                        contact->SetEnabled( false );
                    break;
                case ps_passable_bottom:
                    if (m_player_side == ps_can_land_top )
                        contact->SetEnabled( false );
                default:
                    assert(0);
            }
        }
    }
        
}

-(void) on_end_contact :( struct b2Contact* ) contact
{
    
}


-(int) collied_with:(SpriteBase *)other :(Collision*) collision
{
    if ( [ other isKindOfClass:[PlatformBase class] ] )
    {
        
    }
    return 1;
}


-(void) update:(float)delta_time
{
    [ super update:delta_time];
    [ self apply_force_center:0 :m_velocity.x force_y:m_velocity.y ];


    //if ( [self get_physic_position:0].x < 100 )
    [ self apply_force_center:0 :1000 force_y:0];
    //[self set_physic_linear_velocity:0 :m_velocity.x :m_velocity.y ];
}
@end
