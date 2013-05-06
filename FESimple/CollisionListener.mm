//
//  CollisionListener.cpp
//  shotandrun
//
//  Created by Fancy Zero on 12-3-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Box2D.h>
#include <vector>
#include "Box2D.h"
#include "CollisionListener.h"
#import "SpriteBase.h"
#import "PhysicsSprite.h"

CollisionListener::CollisionListener()
{
	m_collision_process_mode = collision_process_after_simulation;
}

CollisionListener::~CollisionListener()
{
}

void CollisionListener::BeginContact(b2Contact* contact)
{
    // We need to copy out the data because the b2Contact passed in
    // is reused.
	// NSLog(@"on contact %p %p", contact->GetFixtureA(), contact->GetFixtureB() );
    assert ( (contact->GetFixtureA() != NULL) && (contact->GetFixtureB() != NULL) );
    Collision myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
	PhysicsSprite* sprite_comp_A = (PhysicsSprite*)myContact.fixtureA->GetUserData();
	PhysicsSprite* sprite_comp_B = (PhysicsSprite*)myContact.fixtureB->GetUserData();
    b2WorldManifold world_manifold;
    contact->GetWorldManifold( &world_manifold );
    b2Vec2 tmp = world_manifold.points[1] - world_manifold.points[0];
    tmp *= 0.5f;
    tmp += world_manifold.points[0];
    myContact.collision_point = tmp;
	SpriteBase* spriteA = NULL;
	SpriteBase* spriteB = NULL;
	if ( sprite_comp_A != NULL )
		spriteA = sprite_comp_A.m_parent;
	if ( sprite_comp_B != NULL )
		spriteB = sprite_comp_B.m_parent;
	if ( spriteA != spriteB )
	{
		if ( m_collision_process_mode == collision_process_after_simulation )
		{
			m_collisions.push_back(myContact);
		}
		else
		{
			//NSLog(@"spriteA %@ spriteB %@", spriteA, spriteB);
			//NSLog(@"spriteA dead %d spriteB dead %d", [spriteA isdead], [spriteB isdead]);
			if ( ![spriteA isdead] && ![spriteB isdead] )
			{
				[ spriteA collied_with:spriteB :&myContact ];
				[ spriteB collied_with:spriteA :&myContact ];
			}
		}
		
	}
    
}

void CollisionListener::EndContact(b2Contact* contact)
{
	Collision myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    std::vector<Collision>::iterator pos;
    pos = std::find(m_collisions.begin(), m_collisions.end(), myContact);
    if (pos != m_collisions.end())
    {
        m_collisions.erase(pos);
    }
}

void CollisionListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold)
{
	if ( m_collision_process_mode == collision_process_durring_simulation )
	{
		Collision myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
		PhysicsSprite* sprite_comp_A = (PhysicsSprite*)myContact.fixtureA->GetUserData();
		PhysicsSprite* sprite_comp_B = (PhysicsSprite*)myContact.fixtureB->GetUserData();
		SpriteBase* spriteA = NULL;
		SpriteBase* spriteB = NULL;
		if ( sprite_comp_A != NULL )
			spriteA = sprite_comp_A.m_parent;
		if ( sprite_comp_B != NULL )
			spriteB = sprite_comp_B.m_parent;
		if ( spriteA != spriteB )
		{

			if ( [spriteA isdead] || [spriteB isdead] )
				
			{
				contact->SetEnabled(false);
			}
		}
	}
}

void CollisionListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse)
{
}

