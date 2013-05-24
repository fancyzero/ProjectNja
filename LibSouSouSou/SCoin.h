//
//  SCoin.h
//  GameSouSouSou
//
//  Created by FancyZero on 13-5-14.
//
//

#import "PlatformBase.h"

@interface SCoin : PlatformBase
{
    bool m_attracted;
    float m_attracted_time;
    float m_points;
}

-(float) get_points;

@end

