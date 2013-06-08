//
//  ExcellentText.m
//  GameSouSouSou
//
//  Created by FancyZero on 13-6-8.
//
//

#import "ExcellentText.h"
#import "common.h"
@implementation ExcellentText

- (id)init
{
    self = [super init];
    if (self) {
        m_spawned_time = 0;
    }
    return self;
}
-(void) update:(float)delta_time
{
    float curtime = current_game_time();
    float scale = powf( 1 - (curtime - m_spawned_time)*2 ,4)*2 + 1;
    [self set_scale:scale :scale  ];
    if ( curtime - m_spawned_time > 1 )
       [ self remove_from_game:true];
}
@end
