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
#import "SCoin.h"
#import "GameSouSouSouLevel.h"
#import "GameBase.h"
#import "GlobalConfig.h"

@implementation Hero
bool play_dead = false;
-(id) init
{

    self = [super init];
    m_push_force = get_float_config(@"push_force");
    m_speed = get_float_config(@"ninja_speed");
    m_score = 0;
    play_dead = false;
    m_landing_platform = nil;
    m_platform_contacted = 0;
    m_touched_side = ps_top;
    [self init_with_xml:@"sprites/base.xml:ninja" ];
    [ self set_physic_position:0 :ccp(0,0)];

    [ self set_collision_filter:collision_filter_player() cat:cg_player1];
    [ self set_physic_linear_damping:0 :1 ];
    [ self set_physic_fixed_rotation:0 :true ];
    [ self set_physic_restitution: 0];
    [ self set_physic_friction:0];
    [ self set_zorder:100];
    m_player_side = ps_can_land_bottom;
    m_velocity = ccp( 0, -m_speed);
    self.m_time_before_remove_outof_actrange = 3;
    return self;
}

-(float ) get_score
{
    return m_score;
}

-(void) set_player_side:(player_side) side
{
    if ( m_player_side != side )
    {
        if ( side == ps_can_land_top )
        {
            [m_sprite_components[0] setFlipY:TRUE];
            CGPoint anchor = m_sprite_components[0].anchorPointInPoints;
            anchor.y = m_sprite_components[0].contentSize.height - anchor.y;
            anchor.x /= m_sprite_components[0].contentSize.width;
            anchor.y /= m_sprite_components[0].contentSize.height;
            [ m_sprite_components[0] setAnchorPoint: anchor ];
            m_velocity = ccp( 0, m_speed );
        }
        else
        {
            [m_sprite_components[0] setFlipY:FALSE];
            CGPoint anchor = m_sprite_components[0].anchorPointInPoints;
            anchor.y = m_sprite_components[0].contentSize.height - anchor.y;
            anchor.x /= m_sprite_components[0].contentSize.width;
            anchor.y /= m_sprite_components[0].contentSize.height;
            [ m_sprite_components[0] setAnchorPoint: anchor ];
            m_velocity = ccp( 0, -m_speed );
        }
    }
    m_player_side = side;
}

-(void) go_left
{
    if ( m_platform_contacted <= 0 )
    {
        NSLog(@"denined");
        return;
    }

    [self set_player_side: ps_can_land_top ];
    if ( m_landing_platform != nil )
    {
        if ( [m_landing_platform passable] )
        {
            CGPoint pos = [self get_physic_position:0];
            CGPoint platform_pos = [m_landing_platform get_physic_position:0];
            if ( pos.y < platform_pos.y )
            {
                pos = [m_landing_platform get_passed_position:ps_passable_bottom :pos ];
                if ( pos.x != -10000 && pos.y != -10000 )
                {
                    pos.y += 35;
                    [self set_physic_position:0 :pos ];
                    [self set_player_side: ps_can_land_bottom ];
                    
                }
            }
        }
    }

}

-(void) go_right
{
    if ( m_platform_contacted <= 0 )
    {
        NSLog(@"denined");
        return;
    }

     [self set_player_side: ps_can_land_bottom ];

    if ( m_landing_platform != nil )
    {
        if ( [m_landing_platform passable] )
        {
            CGPoint pos = [self get_physic_position:0];
            CGPoint platform_pos = [m_landing_platform get_physic_position:0];
            if ( pos.y >= platform_pos.y )
            {
                pos = [m_landing_platform get_passed_position:ps_passable_top :pos ];
                if ( pos.x != -10000 && pos.y != -10000 )
                {
                     pos.y -= 35;
                    [self set_physic_position:0 :pos ];
                    [self set_player_side: ps_can_land_top ];
                    
                }
            }
        }
    }
}

-(void) on_pre_solve:(struct b2Contact*) contact :(const struct b2Manifold*) old_manifold
{
    return;
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
        other = spriteA;
    else
        other = spriteB  ;
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
        other = spriteA;
    else
        other = spriteB  ;
    if ( [other isKindOfClass:[PlatformBase class]] )
    {
        m_platform_contacted ++;
        m_landing_platform = (PlatformBase*)other;
    }
    
}

-(void) on_end_contact :( struct b2Contact* ) contact
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
        other = spriteA;
    else
        other = spriteB  ;
    if ( [other isKindOfClass:[PlatformBase class]] )
    {
        m_platform_contacted --;
        if ( m_platform_contacted <= 0 )
            m_landing_platform = nil;
    }
}


-(int) collied_with:(SpriteBase *)other :(Collision*) collision
{
    if ( [ other isKindOfClass:[PlatformBase class] ] )
    {
        if ([( (PlatformBase*) other) kill_touched] )
        {

            play_dead = true;
        }
    }
    if ( [ other isKindOfClass:[SCoin class] ] )
    {
        [other remove_from_game:true];
        m_score += 10;
    }
    return 1;
}


-(void) update:(float)delta_time
{
    [ super update:delta_time];
    if ( play_dead )
    {
        sleep(2);
        [self dead];
    }
    [ self apply_force_center:0 :m_velocity.x force_y:m_velocity.y ];


    //if ( [self get_physic_position:0].x < 100 )
    [ self apply_force_center:0 :m_push_force force_y:0];
    float s = [((GameSouSouSouLevel*)[GameBase get_game].m_level) get_move_speed ];
    m_score += s * delta_time;
    //[self set_physic_linear_velocity:0 :m_velocity.x :m_velocity.y ];
}
@end
