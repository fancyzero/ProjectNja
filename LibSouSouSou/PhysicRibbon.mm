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
void make_distance_joint(  b2Body* a ,b2Body* b)
{
    b2World * world = [GameBase get_game].m_world.m_physics_world;
    b2DistanceJointDef joint;
    joint.Initialize(a,b,a->GetPosition(), b->GetPosition() );
   // joint.collideConnected = true;
    joint.frequencyHz = 50;
    joint.dampingRatio = 1;
    world->CreateJoint(&joint);

}

-(int) init_physics 
{
    b2World * world = [GameBase get_game].m_world.m_physics_world;
    float ptm = [GameBase get_ptm_ratio];
    b2Body* bodys[10*2];
    for ( int i = 0; i < 10; i++ )
    {
        for ( int j = 0; j < 2; j++ )
        {
            b2BodyDef bddef;
            bddef.position = b2Vec2(i*0.5 + m_position_.x / ptm,j*0.5 + m_position_.y/ptm) ;
            bddef.type = b2_dynamicBody;
            b2Body* body = world->CreateBody(&bddef);
            
            b2FixtureDef fixdef;
            b2CircleShape s;
            s.m_radius = 0.2f;
            s.m_p = b2Vec2(0,0);
            fixdef.shape = &s;
            fixdef.density = 0.001;
            fixdef.isSensor = true;
            fixdef.filter.categoryBits = 0;
            fixdef.filter.maskBits = 0;
            body->CreateFixture(&fixdef);
            if ( m_phy_body_ == nil )
            {
                m_phy_body_ = body;
                //return 0;
            }
            else
            {
                if ( i > 0 )
                    make_distance_joint( body, bodys[(i-1)*2+j]);
                if ( j > 0 )
                    make_distance_joint( body, bodys[i*2+j-1]);
            }
            bodys[i*2+j] = body;
        }
    }
    return 0;
}

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect rotated:(BOOL)rotated
{
    self = [super initWithTexture:texture rect:rect rotated:rotated];
    return self;
}

- (void)dealloc
{
    NSLog(@"ribbon gone");
    [super dealloc];
}

-(void) draw
{
    [super draw];
}
@end
