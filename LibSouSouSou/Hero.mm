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
#include <algorithm>
#import "World.h"
#import "GameScene.h"
#include "Box2D.h"
@implementation Hero
bool play_dead = false;
-(void) clear_next_input
{
        m_next_input = input::none;
}
-(id) init
{
    
    self = [super init];
    [self set_god_mode:1];
    [self clear_next_input];
    m_next_action = none;
    m_speed.reset();
    m_magnet.reset();
    m_score = 0;
    play_dead = false;
    m_landing_platforms.clear();
    
    m_touched_side = ps_top;
    [self init_with_xml:@"sprites/base.xml:ninja" ];
  /*  soft_ball* b = [[soft_ball alloc] initWithFile:@"blocks.png"];
   [ b init_physics:[GameBase get_game].m_world.m_physics_world :30];
    [b setZOrder:100];
    [b setVisible:TRUE];
    [[[GameBase get_game].m_scene get_layer_by_name:@"game"] addChild:b];
   // self->m_sprite_components.push_back(b);*/
    [ self set_physic_position:0 :ccp(0,0)];
    
    [ self set_collision_filter:collision_filter_player() cat:cg_player1];
    [ self set_physic_linear_damping:0 :1 ];
    [ self set_physic_fixed_rotation:0 :true ];
    [ self set_physic_restitution: 0];
    [ self set_physic_friction:0];
    [ self set_zorder:100];
    m_player_side = ps_can_land_bottom;
    m_velocity = ccp( 0, -get_global_config().ninja_jump_speed);
    self.m_time_before_remove_outof_actrange = 1;
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
            m_velocity = ccp( 0, get_global_config().ninja_jump_speed );
        }
        else
        {
            [m_sprite_components[0] setFlipY:FALSE];
            CGPoint anchor = m_sprite_components[0].anchorPointInPoints;
            anchor.y = m_sprite_components[0].contentSize.height - anchor.y;
            anchor.x /= m_sprite_components[0].contentSize.width;
            anchor.y /= m_sprite_components[0].contentSize.height;
            [ m_sprite_components[0] setAnchorPoint: anchor ];
            m_velocity = ccp( 0, -get_global_config().ninja_jump_speed );
        }
    }
    m_player_side = side;
}

-(void) play_jump_sfx
{
    play_sfx(@"sfx/jump.wav",1 + (rand() / (float)RAND_MAX - 0.5) * 0.1);
}

-(void) go_left
{
    if ( m_landing_platforms.size() <= 0 )
    {
        m_next_input = input::go_left;
        NSLog(@"denined");
        return;
    }
    [self play_jump_sfx];
    [self set_player_side: ps_can_land_top ];
    if ( m_landing_platforms.size() > 0 )
    {
        if ( [self first_touching_passable_platform ] != nil )
        {

            CGPoint pos = [self get_physic_position:0];
            PlatformBase* p = [self first_touching_passable_platform];
            CGPoint platform_pos = [p get_physic_position:0];
            
            if ( pos.y < platform_pos.y )
            {
                pos = [p get_passed_position:ps_passable_bottom :pos ];
                if ( pos.x != -10000 && pos.y != -10000 )
                {
                    pos.y += 35;
                    [self set_physic_position:0 :pos ];
                    [self set_player_side: ps_can_land_bottom ];
                    
                }
                else
                {
                    NSLog(@"fuke %p, %f, %f", p, pos.x, pos.y);
                    pos = [self get_physic_position:0];
                    pos = [p get_passed_position:ps_passable_bottom :pos ];

                }
                
            }
        }
    }
    
}

-(PlatformBase*) first_touching_passable_platform
{
    std::map<PlatformBase*, int>::const_iterator it = std::find_if(m_landing_platforms.begin(), m_landing_platforms.end(), [] ( std::map<PlatformBase*, int>::const_reference p){ return [p.first passable]; } );
    if ( it != m_landing_platforms.end() )
        return it->first;
    else
        return NULL;
}

-(void) go_right
{
    if ( m_landing_platforms.size() <= 0 )
    {
        m_next_input = input::go_right;
        NSLog(@"denined");
        return;
    }
    
    [self play_jump_sfx];
    [self set_player_side: ps_can_land_bottom ];
    if ( m_landing_platforms.size() > 0 )
    {
        if ( [self first_touching_passable_platform ] != nil )
        {
            CGPoint pos = [self get_physic_position:0];
            PlatformBase* p = [self first_touching_passable_platform];
            CGPoint platform_pos = [p get_physic_position:0];
            if ( pos.y >= platform_pos.y )
            {
                pos = [p get_passed_position:ps_passable_top :pos ];
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
	PhysicsSprite* sprite_comp_A = get_sprite(fa);
	PhysicsSprite* sprite_comp_B = get_sprite(fb);
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
	SpriteBase* spriteA = get_sprite_base(fa);
	SpriteBase* spriteB = get_sprite_base(fb);
    SpriteBase* other;
    b2Fixture* myself;
    if ( spriteA == nil || spriteB == nil )
        return;
    if ( spriteA != self )
    {
        myself = fb;
        other = spriteA;
    }
    else
    {
        other = spriteB;
        myself = fa;
    }
    
    if ( [self is_valid_fixture:myself] )
    {
        if ( [other isKindOfClass:[PlatformBase class]] )
        {
            NSLog(@"begin contact platform: %p, ", other, other );
            [self add_landing_platform:(PlatformBase*)other];
            [other set_color_override:ccc4f(1, 1, 1, 1) duration:10000];
        }
    }
    
}

-(void) on_end_contact :( struct b2Contact* ) contact
{
    b2Fixture* fa = contact->GetFixtureA();
    b2Fixture* fb = contact->GetFixtureB();
	SpriteBase* spriteA = get_sprite_base(fa);
	SpriteBase* spriteB = get_sprite_base(fb);
    SpriteBase* other;
    b2Fixture* myself;
    if ( spriteA == nil || spriteB == nil )
        return;
    if ( spriteA != self )
    {
        myself = fb;
        other = spriteA;
    }
    else
    {
        other = spriteB;
        myself = fa;
    }
    if ( [self is_valid_fixture:myself])
    {
        if ( [other isKindOfClass:[PlatformBase class]] )
        {
            //        NSLog(@"end contact platform: %p", other);
            [ self del_landing_platform:(PlatformBase*)other];
                        [other set_color_override:ccc4f(1, 1, 1, 0) duration:10000];
        }
    }
}


-(int) collied_with:(SpriteBase *)other :(Collision*) collision
{
    b2Fixture* self_fixture;
    b2Fixture* other_fixture;
    get_self_fixture(self, collision, self_fixture, other_fixture );

    
    if ( [ other isKindOfClass:[PlatformBase class] ] )
    {
        
        //touch killer platform with valid_fixture
        if ([( (PlatformBase*) other) kill_touched] )
        {
            if ( [self is_valid_fixture:self_fixture])
            {
                if ( [self is_god] )
                {
                    [(PlatformBase*)other set_killed];
                    float angle = frandom() * 3.1415926f * 2;
                    [other set_physic_linear_velocity:0 :cos(angle)*100 :sin(angle)*100];
                    [other set_physic_angular_velocity:0 :3000];
                }
                else
                {
                    play_dead = true;
                }
            }
            else
            {
                //绝妙
                PlatformBase* p = (PlatformBase*)other;
                if ( ![p get_excellented] )
                {
                    [ p set_excellented];
                    m_score += 100;
                }
            }
        }
        
    }
    if ( [self is_valid_fixture:self_fixture] &&[ other isKindOfClass:[SCoin class] ] )
    {
//        static float32 p = 1;
        play_sfx(@"sfx/coin.wav");//, p+=0.01f);
        [other remove_from_game:true];
        m_score += [(SCoin*)other get_points];
    }
    return 1;
}

-(bool) is_god
{
    return m_god_mode != 0;
}

-(void) set_god_mode:(int) v
{
    m_god_mode.base_value = v;
}

-(void) set_god_mode_boost:(int)v :(float) time
{
    m_god_mode.boost(time, v );
}

-(void) set_magnet:(float) v
{
    m_magnet.base_value = v;
}

-(void) set_speed:(float) v
{
    m_speed.base_value = v;
}

-(void) set_magnet_boost:(float) v :(float) time
{
    m_magnet.boost( time, v);
}

-(void) set_speed_boost:(float) v :(float) time;
{
    m_speed.boost( time, v);
}

-(float) get_magnet
{
    return m_magnet;
}

-(float) get_speed
{
    return m_speed;
}

-(void) turn_on_god_mode
{
    b2Body* bdy = [self get_sprite_component:0].m_phy_body;
    b2Fixture * fix;
    fix = bdy->GetFixtureList();
    while( fix )
    {
        fix->SetSensor(true);
        fix = fix->GetNext();
    }
}

-(void) turn_off_god_mode
{
    b2Body* bdy = [self get_sprite_component:0].m_phy_body;
    b2Fixture * fix;
    fix = bdy->GetFixtureList();
    while( fix )
    {
        fix->SetSensor(false);
        fix = fix->GetNext();
    }
    
}

-(void) update:(float)delta_time
{
    [ super update:delta_time];
    
    switch (m_next_action)
    {
        case go_left:
            [self go_left];
            break;
        case go_right:
            [self go_right];
            break;
        default:
            break;
    }
    m_next_action = none;
    if ( play_dead )
    {
        sleep(2);
        [self dead];
    }
   /* if ( [self is_god] )
        [self turn_on_god_mode];
    else
        [self turn_off_god_mode];
    */
   [ [self get_sprite_component:1] set_physic_position:[self get_physic_position:0]];
    [ self apply_force_center:0 :m_velocity.x force_y:m_velocity.y ];
    
    
    //if ( [self get_physic_position:0].x < 100 )
    [ self apply_force_center:0 :get_global_config().ninja_push_force force_y:0];
    float s = [((GameSouSouSouLevel*)[GameBase get_game].m_level) get_move_speed ];
    m_score += (s * delta_time)*0.1;
    
    /*
     debug ---
    PlatformBase* touching = [ self first_touching_passable_platform];
    for (PlatformBase* p in [GameBase get_game].m_world.m_gameobjects)
    {
        if ( m_landing_platforms.find(p) != m_landing_platforms.end() )
            [p set_color_override:ccc4f(1, 0, 1, 1) duration:1000];
        else
            [p set_color_override:ccc4f(1, 0, 1, 0) duration:1000];
        if ( p == touching )
            [ p set_color_override:ccc4f(1, 1, 1, 1) duration:1000];
        
    }
     */
    //[self set_physic_linear_velocity:0 :m_velocity.x :m_velocity.y ];
}

-(void) add_landing_platform:(PlatformBase*) platform
{
    //NSLog(@"add platform %p",platform);
    int old_count = m_landing_platforms.size();
    if ( m_landing_platforms.find(platform) != m_landing_platforms.end() )
    {
        //assert(0);//should not happen
    }
    m_landing_platforms[platform] ++;
    if ( old_count == 0 )
    {
        
        if ( m_next_input != input::none )
        {
            m_next_action = m_next_input;
        }
        [self clear_next_input];
    }
}

-(void) del_landing_platform:(PlatformBase*) platform
{
    
    //NSLog(@"del platform %p",platform);
    if ( m_landing_platforms.find(platform) == m_landing_platforms.end() )
    {
        //assert(0);
    }
    else
    {
    m_landing_platforms[platform] --;
        if ( m_landing_platforms[platform] == 0 )
        {
            m_landing_platforms.erase(platform);
        }
    }
}

-(bool) is_valid_fixture:(b2Fixture*) fix
{
    return ((fixture_data*)fix->GetUserData())->identity == 0;
}

@end
