//
//  Pickup.h
//  GameSouSouSou
//
//  Created by Fancyzero on 13-5-23.
//
//

#import "PlatformBase.h"

@interface Pickup : PlatformBase
@end

@interface PickupGodPortion : Pickup
{
    float m_boost_value;
    float m_god_time;
}
@end

@interface PickupMagnet : Pickup
{
    float m_magnet_value;
    float m_magnet_time;
}
@end