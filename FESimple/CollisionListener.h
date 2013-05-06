//
//  CollisionListener.h
//  shotandrun
//
//  Created by Fancy Zero on 12-3-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef shotandrun_CollisionListener_h
#define shotandrun_CollisionListener_h
#include "common_datatype.h"
#include "Box2D.h"
#include <vector>
	struct Collision
	{
		class b2Fixture *fixtureA;
		class b2Fixture *fixtureB;
        b2Vec2         collision_point;//wolrd position
        b2Vec2         get_collision_point()
        {
            return collision_point;
        }
		bool operator==(const Collision& other) const
		{
			return (fixtureA == other.fixtureA) && (fixtureB == other.fixtureB);
		}
	};

	class CollisionListener : public b2ContactListener
	{
		
	public:
		
		
		CollisionListener();
		~CollisionListener();
		
		virtual void BeginContact(b2Contact* contact);
		virtual void EndContact(b2Contact* contact);
		virtual void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);
		virtual void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
	public:
		collision_process_mode m_collision_process_mode;
		std::vector<Collision> m_collisions;
		
	};
	
#endif
