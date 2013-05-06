//
//  Platform.m
//  GameSouSouSou
//
//  Created by Fancyzero on 13-5-5.
//
//

#import "Platform.h"
#import "Common.h"
#include <Box2D.h>
@implementation Platform
-(id) init
{
    self = [super init];
    [ self init_with_xml:@"sprites/base.xml:brick" ];
    [ self set_collision_filter:cg_player1 cat:cg_static];
    b2Fixture *f = m_sprite_components[0].m_phy_body->GetFixtureList();
    while( f )
    {
        f->SetFriction(0);
        f = f->GetNext();
    }
    return self;
}
@end
