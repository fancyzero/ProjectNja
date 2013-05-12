//
//  Hero.h
//  GameSouSouSou
//
//  Created by Fancyzero on 13-5-4.
//
//

#import "PlayerBase.h"
#import "PlatformBase.h"

enum player_side
{
    ps_can_land_top,
    ps_can_land_bottom,
};

@interface Hero : PlayerBase
{
    CGPoint m_velocity;
    
    player_side     m_player_side;
    platform_side   m_touched_side;
    int             m_platform_contacted;
    PlatformBase*   m_landing_platform;

}
-(id) init;
-(void) go_left;
-(void) go_right;
-(int) collied_with:(SpriteBase *)other :(Collision*) collision;
-(void) on_begin_contact :( struct b2Contact* ) contact;
-(void) on_end_contact :( struct b2Contact* ) contact;
@end
