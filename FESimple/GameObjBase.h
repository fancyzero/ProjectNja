//
//  GameObjBase.h
//  testproj1
//
//  Created by Fancy Zero on 12-3-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameObjBase : NSObject
{
	int trigger_id_; //the trigger that spawned the object
    GameObjBase* m_owner;
}
-(void) set_owner:(GameObjBase*) owner;
-(GameObjBase*) get_owner;
-(int) init_default_values;
-(id) init_with_spawn_params:(NSDictionary*) params;
-(void) cleanup;
-(void) update : (float)delta_time;
-(void) ed_update:(float)delta_time;
-(void) set_trigger_id:(int) trigger_id;
-(int) get_trigger_id;
-(void) set_tag_flag:( int) flag;
-(void) unset_tag_flag:( int ) flag;
@property (nonatomic, assign) NSString* m_name;
@property (nonatomic, assign) int  m_tag;
@property (nonatomic, assign, readonly) float m_spawned_time;
@end

