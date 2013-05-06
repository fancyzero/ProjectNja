//
//  Hero.h
//  GameSouSouSou
//
//  Created by Fancyzero on 13-5-4.
//
//

#import "PlayerBase.h"

@interface Hero : PlayerBase
{
    CGPoint m_velocity;
}
-(id) init;
-(void) go_left;
-(void) go_right;
@end
