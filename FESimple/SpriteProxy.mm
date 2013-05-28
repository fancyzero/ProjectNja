
#include <vector>
#import "GameObjBase.h"
#import "CCSprite.h"
#import "PhysicsSprite.h"
#import "Custom_Interfaces.h"
#import	"cocos2d.h"
#include "SpriteProxy.h"
#import	"PhysicsSprite.h"
#import "SpriteBase.h"
#import "Common.h"
#import "Box2D.h"
#import "GameBase.h"
@implementation SpriteProxyBase
-(void) set_sprite:(SpriteBase*) sprite
{
    m_sprite_ = sprite;
}
@end


class myquerycb :public b2QueryCallback
{
public:
	std::vector<PhysicsSprite*>* sprites;
	virtual bool ReportFixture(b2Fixture* fixture)
	{
		PhysicsSprite* spr = get_sprite(fixture);
		if ( spr == NULL )
			return true;
		else
			sprites->push_back(spr);
		return true;
	}
};
@implementation SpriteHitProxy

-(std::vector<PhysicsSprite*>) pick :( CGPoint) loc
{
	std::vector<PhysicsSprite*> results;
	if ( m_sprite_ == NULL )
		return results;
	for ( int i = 0; i < [m_sprite_ sprite_components_count]; i++ )
	{
		PhysicsSprite* sprcmp = [m_sprite_ get_sprite_component:i];
		if ( sprcmp != NULL )
		{
			if ( sprcmp.m_phy_body != NULL )
			{
				if ( is_in_rect( loc, [sprcmp boundingBox] ) )
				{
					b2Fixture* fixture = sprcmp.m_phy_body->GetFixtureList();
					b2Vec2 testpt;
					testpt.x = loc.x / [GameBase get_ptm_ratio];
					testpt.y = loc.y / [GameBase get_ptm_ratio];
					while ( fixture )
					{
						if ( fixture->TestPoint(testpt) )
						{
							results.push_back(sprcmp);
							break;
						}
						fixture = fixture->GetNext();
					}
				}

			}
			else
			{
				if ( is_in_rect( loc, [sprcmp boundingBox] ) )
					results.push_back(sprcmp);
			}
		}
	}
	return results;
}
-(void) set_picked_offset:(CGPoint) offset
{
	m_picked_offset_ = offset;
}

-(CGPoint) get_picked_offset
{
	return m_picked_offset_;
}

-(void) set_deleted:(BOOL) deleted
{
    m_deleted = deleted;
}
-(BOOL) is_deleted
{
    return m_deleted;
}

-(void) set_selected:(BOOL) selected
{
	if ( m_sprite_ == NULL )
		return;
	if ( selected )
		[m_sprite_ set_color_override:ccc4f(0, 1, 0.1, 0.5) duration:40000000];
	else
		[m_sprite_ set_color_override:ccc4f(0, 1, 0.1, 0)  duration:0];

}
@end
