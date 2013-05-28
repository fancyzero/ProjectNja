//
//  Pickup.m
//  GameSouSouSou
//
//  Created by Fancyzero on 13-5-23.
//
//

#import "Pickup.h"
#import "common.h"
#import "Hero.h"
#import "CollisionListener.h"



@implementation Pickup

@end

@implementation PickupBoost

-(id) init_with_spawn_params:(NSDictionary *)params
{
    self = [super init_with_spawn_params:params];
    m_boost_time = read_float_value(params, @"duration", 10.0f );
    m_boost_value = read_float_value(params, @"value", 400 );
    return self;
}

-(int) collied_with:(SpriteBase *)other :(struct Collision *)collision
{
    if ( [other isKindOfClass:[Hero class]])
    {
        Hero* h = (Hero*)other;
        b2Fixture* self_fix;
        b2Fixture* other_fix;
        get_self_fixture( self, collision, self_fix, other_fix );
        if ( [h is_valid_fixture:other_fix] )
        {
            [h set_speed_boost:m_boost_value :m_boost_time ];
        }
    }
    [self remove_from_game:true];
    return 0;
}

@end

@implementation PickupMagnet

-(id) init_with_spawn_params:(NSDictionary *)params
{
    self = [super init_with_spawn_params:params];
    m_magnet_time = read_float_value(params, @"duration", 10.0f );
    m_magnet_value = read_float_value(params, @"value", 400 );
    return self;
}


-(int) collied_with:(SpriteBase *)other :(struct Collision *)collision
{
    if ( [other isKindOfClass:[Hero class]])
    {
        Hero* h = (Hero*)other;
        b2Fixture* self_fix;
        b2Fixture* other_fix;
        get_self_fixture( self, collision, self_fix, other_fix );
        if ( [h is_valid_fixture:other_fix] )
        {
            [  h set_magnet_boost:m_magnet_value  :m_magnet_time ];
                    [self remove_from_game:true];
        }
    }

    return 0;
}

@end