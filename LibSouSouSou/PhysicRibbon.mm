//
//  PhysicRibbon.m
//  GameSouSouSou
//
//  Created by Fancyzero on 13-6-2.
//
//

#import "PhysicRibbon.h"
#include "Box2D.h"
#import "GameBase.h"
#import "World.h"
@implementation PhysicRibbon

-(int) init_physics
{
    b2World * world = [GameBase get_game].m_world.m_physics_world;
    b2BodyDef bddef;
    bddef.position = b2Vec2(-900,200);
    bddef.type = b2_dynamicBody;
    b2Body* body = world->CreateBody(&bddef);
    b2FixtureDef fixdef;
    b2PolygonShape s;
    s.SetAsBox(100/32, 15/32.0f);
    fixdef.shape = &s;
    fixdef.density = 0.001;
    body->CreateFixture(&fixdef);
    m_phy_body_ = body;
    return 0;
}

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect rotated:(BOOL)rotated
{
    self = [super initWithTexture:texture rect:rect rotated:rotated];
    [self setPosition:ccp(-900  , 200)];
    [self init_physics];
    return self;
}

-(void) draw
{
    [super draw];
}
@end
