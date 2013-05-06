//
//  CCAnimateEx.h
//  GameSaDEditor
//
//  Created by FancyZero on 13-3-2.
//
//

#import "cocos2d.h"
/*
 expand CCanimate in cocos2d
 set first frame to the target sprite, when the animation been activated
 instead of set first frame at next update
 */
@interface CCAnimateEx : CCAnimate
+(id) actionWithAnimation: (CCAnimation*)anim;
-(void) startWithTarget:(id)target;
@end
