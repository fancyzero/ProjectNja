//
//  DynamicObject.h
//  GameSouSouSou
//
//  Created by Fancyzero on 13-5-19.
//
//

#import "PlatformBase.h"

@interface FallenRock : PlatformBase
{
    float m_fall_speed;
    float m_rotat_speed;
}

@end

@interface Razor : FallenRock
{
    float m_sweep_speed;
    float m_sweep_range;
    float m_init_pos;
    
}

@end
