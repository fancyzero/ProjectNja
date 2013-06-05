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
#import "PhysicRibbon.h"

const float invalid_distance = -10000;
const float hover_distance = 100;
@implementation Hero
bool play_dead = false;
float standard_mass = 0;
GameSouSouSouLevel* get_game_level()
{
    return (GameSouSouSouLevel*)[GameBase get_game].m_level;
}

-(id) init
{
    
    self = [super init];
  // [self set_god_mode_boost:2 :10000];

    m_hero_scale.cur = m_hero_scale.dest = 1;
    m_hero_scale.fixed_morph_time = 0.3;
    m_hovering = false;
    m_move_distance_when_leave_platform = invalid_distance;
    m_speed.reset();
    m_magnet.reset();
    
    play_dead = false;
    m_landing_platforms.clear();
    

    m_touched_side = ps_top;
   [self init_with_xml:@"sprites/base.xml:ninja" ];
   /* [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"pic/scene.plist"];
    CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"ribbon.png"];
    PhysicRibbon* rib = [[PhysicRibbon alloc] initWithSpriteFrame:frame];
    rib.m_parent = self;
    self->m_sprite_components.push_back(rib);
    rib.m_position = ccpAdd( ccp(-200,0), self.m_position);
    [rib init_physics];
    */
    PhysicsJoint pj;
    //create joint
    /*b2RevoluteJointDef joint;


    joint.Initialize(m_sprite_components[0].m_phy_body, m_sprite_components[1].m_phy_body, m_sprite_components[0].m_phy_body->GetPosition());
    joint.enableLimit = true;
    joint.upperAngle = 45;
    joint.lowerAngle = -45;
    joint.enableMotor = true;
    joint.maxMotorTorque = 100;
    joint.motorSpeed = 10;*/
/*
    b2DistanceJointDef joint;
    joint.Initialize(m_sprite_components[0].m_phy_body, m_sprite_components[1].m_phy_body, m_sprite_components[0].m_phy_body->GetPosition(),m_sprite_components[1].m_phy_body->GetPosition());
    //joint.collideConnected = true;
    joint.frequencyHz = 100;*/
    
   /* b2RopeJointDef joint;
    joint.bodyA = m_sprite_components[0].m_phy_body;
    joint.bodyB = m_sprite_components[1].m_phy_body;
    joint.localAnchorA = b2Vec2(0,0);
    joint.localAnchorB = b2Vec2(0,0);
    joint.maxLength = 1;
    pj.m_b2Joint =	[GameBase get_game].m_world.m_physics_world->CreateJoint(&joint);

    m_physic_joints.push_back(pj);
    */
    standard_mass = [self get_sprite_component:0].m_phy_body->GetMass();

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
    [self get_sprite_component:0].m_phy_body->SetBullet(true);

    return self;
}

-(score ) get_score
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


-(PlatformBase*) first_touching_passable_platform
{
    std::map<PlatformBase*, int>::const_iterator it = std::find_if(m_landing_platforms.begin(), m_landing_platforms.end(), [] ( std::map<PlatformBase*, int>::const_reference p){ return [p.first passable]; } );
    if ( it != m_landing_platforms.end() )
        return it->first;
    else
        return nil;
}
class rccb : public b2RayCastCallback
{
public:
    b2Vec2 hit_pos;
    b2Vec2 from_pos;
    bool hited;
    platform_side from_side;
    std::map<PlatformBase*, int> m_from_platforms;
    rccb()
    :hited(false)
    {
    }
    virtual float32 ReportFixture(	b2Fixture* fixture, const b2Vec2& point,const b2Vec2& normal, float32 fraction)
    {
        PhysicsSprite* spr = get_sprite(fixture);
        if ( spr && spr.m_parent )
        {
            if ( [spr.m_parent isKindOfClass:[PlatformBase class]]
                && m_from_platforms.find((PlatformBase*)spr.m_parent) != m_from_platforms.end()
                && [ ((PlatformBase*)(spr.m_parent))  passable])
            {
                float ptm = [GameBase get_ptm_ratio];
                float platofrm_y = [spr.m_parent get_physic_position:0].y;
                if ( from_side == platform_side::ps_passable_top && platofrm_y >= from_pos.y * ptm )
                    return -1;
                if ( from_side == platform_side::ps_passable_bottom && platofrm_y < from_pos.y * ptm )
                    return -1;
                
                if ( !hited )//alwayse take first hitpoint
                {
                    
                    hited = true;
                    hit_pos = point;
                }
                else
                {
                    // then alwayse use further hitpoint
                    if ( (hit_pos - from_pos).Length() < (point - from_pos).Length() )
                    {
                        hit_pos = point;
                    }
                }
                return -1;
            }
        }
        return -1;
    }
};


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
    ccb.from_side = from_side;
    ccb.m_from_platforms = m_landing_platforms;
    ccb.from_pos = b2Vec2( from_pos.x / ptm, from_pos.y / ptm);
    [ GameBase get_game ].m_world.m_physics_world->RayCast(&ccb, start, end );
    CGPoint ret = ccp(-10000,-10000);
    if ( ccb.hited )
        ret = ccp(ccb.hit_pos.x * ptm, ccb.hit_pos.y * ptm );
    return ret;
}

-(float) current_moved
{
    return [(GameSouSouSouLevel*)[GameBase get_game].m_level get_total_moved ];
}

-(void) go_left
{
    if ( m_landing_platforms.size() <= 0 )
    {
        if ( [self current_moved] - m_move_distance_when_leave_platform > hover_distance )
        {
           // NSLog(@"denined");
            return;
        }
    }
    
switch (  [self get_track ] )
    {
        case tr_top:
            
            break;
        case tr_middle:
           [ get_game_level() enable_bound:bottom :true];
            break;
        case tr_bottom:
            [ get_game_level() enable_bound:top :true];
            break;
    }
    m_move_distance_when_leave_platform = invalid_distance;
    m_under_user_will = true;
    [self play_jump_sfx];
    [self set_player_side: ps_can_land_top ];
    if ( [self first_touching_passable_platform] )
    {
        CGPoint pos = [self get_physic_position:0];
        pos = [self get_passed_position:ps_passable_bottom :pos ];
        if ( pos.x != -10000 && pos.y != -10000 )
        {
            pos.y += 30;
            [self set_physic_position:0 :pos ];
            [self set_player_side: ps_can_land_bottom ];
            
        }
        
    }
}
-(track) get_track
{
    CGPoint pos = [self get_physic_position:0];
    if ( pos.y < 768 /3 )
        return tr_bottom;
    else if ( pos.y < 768/3*2 )
        return tr_middle;
    else
        return tr_top;
}

-(void) go_right
{
    if ( m_landing_platforms.size() <= 0 )
    {
        if ( [self current_moved] - m_move_distance_when_leave_platform > hover_distance )
        {
           // NSLog(@"denined");
            return;
        }
    }
    
    
    switch (  [self get_track ] )
    {
        case tr_top:
            [ get_game_level() enable_bound:bottom :true];
            break;
        case tr_middle:
            [ get_game_level() enable_bound:top :true];
            break;
        case tr_bottom:

            break;
    }
    
    m_move_distance_when_leave_platform = invalid_distance;
    m_under_user_will = true;
    [self play_jump_sfx];
    [self set_player_side: ps_can_land_bottom ];
    if ( [self first_touching_passable_platform] )
    {
        CGPoint pos = [self get_physic_position:0];
        pos = [self get_passed_position:ps_passable_top :pos ];
        if ( pos.x != -10000 && pos.y != -10000 )
        {
            pos.y -= 30;
            [self set_physic_position:0 :pos ];
            [self set_player_side: ps_can_land_top ];
        }
    }
    
}
-(void) on_post_solve:(struct b2Contact*) contact :(const struct b2ContactImpulse*) impulse
{
//    for ( int i = 0; i < impulse->count; i++ )
    //if ( impulse->tangentImpulses[0] > 0 )
    //{
      //  NSLog(@"impulse %f, %f,%f, %f", impulse->normalImpulses[0], impulse->normalImpulses[1],impulse->tangentImpulses[0], impulse->tangentImpulses[1]);
    //}
}
-(void) on_pre_solve:(struct b2Contact*) contact :(const struct b2Manifold*) old_manifold
{
    //return;
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
            if ( [platform passable])
            {
                CGPoint platform_pos = [platform get_physic_position:0];
                if ( self.m_position.y > platform_pos.y && m_player_side == ps_can_land_top )
                    contact->SetEnabled(false);
                if ( self.m_position.y <= platform_pos.y && m_player_side == ps_can_land_bottom )
                    contact->SetEnabled(false);
            }
            if ( [self is_god] && ( [platform passable] || [platform kill_touched]) )
            {
                contact->SetEnabled(false);
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
    b2Fixture* otherfix;
    if ( spriteA == nil || spriteB == nil )
        return;
    if ( spriteA != self )
    {
        myself = fb;
        otherfix = fa;
        other = spriteA;
    }
    else
    {
        other = spriteB;
        otherfix = fb;
        myself = fa;
    }
    
    if ( [self is_valid_fixture:myself] )
    {
        if ( [other isKindOfClass:[PlatformBase class]] )
        {
            //NSLog(@"begin contact platform: %p, %p,  %p", other, otherfix, otherfix->GetUserData() );
            PlatformBase* platform = (PlatformBase*)other;
            
            if ( m_hovering && [platform passable] )//滞空的时候碰到可翻越平台，取消滞空条件
                m_move_distance_when_leave_platform = invalid_distance;
                
            [self add_landing_platform:(PlatformBase*)other];
            m_under_user_will = false;
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
        if ([( (PlatformBase*) other) kill_touched] || [( (PlatformBase*) other) passable])
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
                else if ([( (PlatformBase*) other) kill_touched])
                {
                    play_dead = true;
                }
            }
            else
            {
                //绝妙
               /* PlatformBase* p = (PlatformBase*)other;
                if ( ![p get_excellented] )
                {
                    [ p set_excellented];
                    m_score += 100;
                }
                */
            }
        }
        
    }
    if ( [self is_valid_fixture:self_fixture] &&[ other isKindOfClass:[SCoin class] ] )
    {
        //        static float32 p = 1;
        play_sfx(@"sfx/coin.wav");//, p+=0.01f);
        [other remove_from_game:true];
        m_score.coins += [(SCoin*)other get_points];
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

//        {
//            [ self set_collision_filter:collision_filter_player() cat:cg_god_player];
//            [self set_scale:2 :2];
//        }
//        else
//        {
//            [ self set_collision_filter:collision_filter_player() cat:cg_player1];
//            [self set_scale:1 :1];
//        }
//    }
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
    float old_scale = m_hero_scale;
    m_hero_scale.update(delta_time);
    if ( old_scale != m_hero_scale )
        [self set_scale:m_hero_scale :m_hero_scale ];
    bool cur_god = [self is_god];
    if ( cur_god != m_old_is_god )
    {
            if ( cur_god )
                m_hero_scale.set_dest(2);
            else
            {
                for (SpriteBase* p in [GameBase get_game].m_world.m_gameobjects)
                {
                    PlatformBase* plat;
                    if ( [p isKindOfClass:[PlatformBase class]] )
                        plat = (PlatformBase*) p;

                    if ( [plat kill_touched] && plat.m_position.x - self.m_position.x < 500 )
                    {
                        [plat set_killed];
                        float angle = frandom() * 3.1415926f * 2;
                        [plat set_physic_linear_velocity:0 :cos(angle)*100 :sin(angle)*100];
                        [plat set_physic_angular_velocity:0 :3000];
                    }
                    
                }
                
                m_hero_scale.set_dest(1);
            }
    }
    m_old_is_god = cur_god;
    //[self remove_from_game:true];
    // static int gogotest2 = 0;
    //gogotest2++;
    //m_next_action = (input)(gogotest2 % 2);
    if ( play_dead )
    {
        //sleep(2);
        [self dead];
    }
    /* if ( [self is_god] )
     [self turn_on_god_mode];
     else
     [self turn_off_god_mode];
     */
    float current_mass = [self get_sprite_component:0].m_phy_body->GetMass();
    
    [ [self get_sprite_component:1] set_physic_position:[self get_physic_position:0]];

    [ self apply_force_center:0 :m_velocity.x* current_mass / standard_mass force_y:m_velocity.y *current_mass / standard_mass];
    
    
    //if ( [self get_physic_position:0].x < 100 )
    
    float s = [((GameSouSouSouLevel*)[GameBase get_game].m_level) get_move_speed ];
    m_score.len += (s * delta_time)*0.01;
    
    bool touching_passable_platform = [self first_touching_passable_platform];
    if ( !touching_passable_platform && m_last_touching_passable_platform )
        m_move_distance_when_leave_platform = [self current_moved];
    
    [ self apply_force_center:0 :get_global_config().ninja_push_force force_y:0];
/*    if ( [self current_moved]- m_move_distance_when_leave_platform < hover_distance &&  !m_under_user_will )
    {
        m_hovering = true;
        [self set_physic_linear_damping:0 :1000000];
        [self set_color_override:ccc4f(1,1, 1, 1) duration:10000];
    }
    else
    {
                [self set_color_override:ccc4f(1,1, 1, 0) duration:10000];
        m_hovering = false;
        [self set_physic_linear_damping:0 :1];
    }*/
    m_last_touching_passable_platform = touching_passable_platform;

    b2Vec2 v = [self get_sprite_component:0].m_phy_body->GetLinearVelocity();
    if ( v.x < 0 )
        v.x = 0;
    [self get_sprite_component:0].m_phy_body->SetLinearVelocity(v);
}

-(void) add_landing_platform:(PlatformBase*) platform
{
    //NSLog(@"add platform %p",platform);
    if ( m_landing_platforms.find(platform) != m_landing_platforms.end() )
    {
        //assert(0);//should not happen
    }
    m_landing_platforms[platform] ++;
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
