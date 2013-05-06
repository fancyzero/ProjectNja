//
//  SPlayAnimOnce.m
//  ShotAndRun4
//
//  Created by FancyZero on 13-2-24.
//
//

#import "SPlayAnimOnce.h"
#import "PhysicsSprite.h"
@implementation SPlayAnimOnce
-(void) update:(float)delta_time
{
    [super update:delta_time];

    PhysicsSprite* spr;
    if ( super.sprite_components_count <= 0 )
        [ self remove_from_game:true];
    spr = m_sprite_components[0];
    
    if ( spr != NULL && ([spr get_current_anim_sequence ] == NULL || [[spr get_current_anim_sequence ] isDone]) )
        [ self remove_from_game:true];
}

@end
