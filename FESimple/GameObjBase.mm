//
//  GameObjBase.m
//  testproj1
//
//  Created by Fancy Zero on 12-3-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameObjBase.h"

@implementation GameObjBase
@synthesize  m_name;
@synthesize m_tag;

-(int) init_default_values
{
	trigger_id_ = -1;
	return 0;
}
-(void) set_owner:(GameObjBase*) owner
{
    m_owner = owner;
}
-(GameObjBase*) get_owner
{
    return m_owner;
}
-(id) init_with_spawn_params:(NSDictionary*) params
{
	return self;
}
-(void) update: (float)delta_time
{
    
}
-(void) ed_update:(float)delta_time
{
	
}
-(void) cleanup
{

}
/*bisb
- (void)dealloc
{
    //NSLog(@"%@ dealloc" , self);
    [super dealloc];
}*/

-(void) set_trigger_id:(int) trigger_id
{
	//NSLog(@"Spawn class:%@ with triggerid: %d", self, trigger_id);
	trigger_id_ = trigger_id;
}

-(int) get_trigger_id
{
	return trigger_id_;
}

-(void) set_tag_flag:( int) flag
{
    m_tag |= flag;
}

-(void) unset_tag_flag:( int ) flag
{
    m_tag &= ~flag;
}

@end
