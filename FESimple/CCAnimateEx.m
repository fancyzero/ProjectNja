//
//  CCAnimateEx.m
//  GameSaDEditor
//
//  Created by FancyZero on 13-3-2.
//
//

#import "CCAnimateEx.h"

@implementation CCAnimateEx

+(id) actionWithAnimation: (CCAnimation*)anim
{
	return [[[self alloc] initWithAnimation:anim] autorelease];
}

-(void) startWithTarget:(id)target
{
    [ super startWithTarget:target ];
    if ( target != NULL )
    {
        NSArray *frames = [animation_ frames];
        NSUInteger numberOfFrames = [frames count];
        if ( numberOfFrames > 0 )
        {
            CCAnimationFrame* anim_frame = [frames objectAtIndex:0];
            
            [(CCSprite*)target_ setDisplayFrame: anim_frame.spriteFrame ];
        }
    }
}
@end
