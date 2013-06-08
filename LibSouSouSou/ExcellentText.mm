//
//  ExcellentText.m
//  GameSouSouSou
//
//  Created by FancyZero on 13-6-8.
//
//

#import "ExcellentText.h"
#import "common.h"
#import "GameSouSouSouLevel.h"
#import "GameBase.h"
@implementation ExcellentText

- (id)init
{
    self = [super init];
    if (self) {
        m_spawned_time = current_game_time();
    }
    return self;
}
-(void) update:(float)delta_time
{
    float curtime = current_game_time();
    float scale = powf( 1 - (curtime - m_spawned_time)*2 ,4)*2 + 1;
    [self set_scale:scale :scale  ];
    if ( curtime - m_spawned_time > 0.5 )
       [ self remove_from_game:true];
    GameSouSouSouLevel* lvl = (GameSouSouSouLevel*)[GameBase get_game].m_level;
    float level_speed = [lvl get_move_speed];
    [self set_position:self.m_position.x - level_speed * delta_time    y:self.m_position.y];
    
}
@end
