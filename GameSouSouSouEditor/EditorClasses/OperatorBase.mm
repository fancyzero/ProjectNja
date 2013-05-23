//
//  OperatorBase.m
//  GameSaDEditor
//
//  Created by Zero Fancy on 12-11-15.
//
//
#import <Foundation/Foundation.h>
#import "OperatorBase.h"
#import "GameBase.h"
#import "cocos2d.h"
#import "GameScene.h"
#import "GameSouSouSouEditorLevel.h"
#import "EditorCommon.h"
#import "AppDelegate.h"
#import "SpriteProxy.h"
#include <set>

@implementation OperatorBase
-(void) apply_selection
{
	//[ self unselect_all];

	std::vector<SpriteBase*> current_selected_sprites = m_selected_sprites.get_selection();
	std::vector<SpriteBase*>::iterator it;
    
    for ( it = current_selected_sprites.begin(); it != current_selected_sprites.end(); ++it )
    {
		[[*it get_hitproxy] set_selected:TRUE];
		[*it retain];
		//break;
    }

    
}

-(void) unselect_all
{
	std::vector<SpriteBase*> current_selected_sprites = m_selected_sprites.get_selection();
	std::vector<SpriteBase*>::iterator it;

    for ( it = current_selected_sprites.begin(); it != current_selected_sprites.end(); ++it )
    {
		[[*it get_hitproxy] set_selected:FALSE];
		[*it release];
		//break;
    }
    m_selected_sprites.clear();
}

-(void) update_selection
{
    //遍历当前selection，把所有hitproxy标记为deleted的object释放
	std::vector<SpriteBase*> current_selected_sprites = m_selected_sprites.get_selection();
	std::vector<SpriteBase*>::iterator it;
    std::vector<SpriteBase*> new_selected_sprites;
    for ( it = current_selected_sprites.begin(); it != current_selected_sprites.end(); ++it )
    {
		if ( [[*it get_hitproxy] is_deleted] )
        {
            [*it release];
            
        }
		//break;
    }
    m_selected_sprites.clear();
    
}

-(void) pre_sprtie_deleted:(SpriteBase*) spr
{
    m_selected_sprites.remove(spr);
}

-(void) on_activated
{
	[self apply_selection];
}

-(BOOL) on_mouse_down:(mouse_key_event) event
{
	return TRUE;
}

-(BOOL) on_mouse_moved:(mouse_key_event) event
{
	return TRUE;
}

-(BOOL) on_mouse_up:(mouse_key_event) event
{
	return TRUE;
}

-(BOOL) on_mouse_scroll:(mouse_key_event)event
{
	return TRUE;
}

-(BOOL) on_key_down:(mouse_key_event) event
{
	return TRUE;
}

-(BOOL) on_key_up:(mouse_key_event) event
{
	return TRUE;
}

-(void) on_copy
{
    if ( m_selected_sprites.get_selection().size() == 0 )
        return;
    m_copied_triggers.clear();
    //copy triggers
    std::set<int> trigger_ids;
    for ( std::vector<SpriteBase*>::iterator it = m_selected_sprites.get_selection().begin(); it != m_selected_sprites.get_selection().end(); ++it )
    {
        trigger_ids.insert([(*it) get_trigger_id]);
    }
    for ( std::set<int>::iterator it = trigger_ids.begin(); it != trigger_ids.end(); ++it )
    {
        level_progress_trigger t = *([[GameBase get_game].m_level get_trigger_by_id: (*it)]);
        m_copied_triggers.push_back(t);
    }
    
}
-(void) on_paste;
{
    GameSouSouSouEditorLevel* lvl = (GameSouSouSouEditorLevel*) [GameBase get_game].m_level;

    //[ lvl push_histroy];
    for ( std::vector<level_progress_trigger>::iterator it = m_copied_triggers.begin(); it != m_copied_triggers.end(); ++it )
    {
        [lvl add_trigger_at_runtime:*it];
    }
}
-(void) on_param_changed:(id)sender
{
}
@end

@implementation NavigatorOperator
-(void) on_activated
{
    [ super on_activated];
	[self setup_trigger_property_window];
}

-(void) setup_trigger_property_window
{
	std::vector<SpriteBase*> current_selected_sprites = m_selected_sprites.get_selection();
	std::vector<SpriteBase*>::iterator it;

    for ( it = current_selected_sprites.begin(); it != current_selected_sprites.end(); ++it )
    {
        //todo: support multi selectiong
		int triggerid = [(*it) get_trigger_id];
		//[[*it get_hitproxy] set_selected:TRUE];
		level_progress_trigger* trigger = [[GameBase get_game].m_level get_trigger_by_id: triggerid];
		[get_trigger_property_window() set_trigger: trigger];
		//[ *it retain];
		//break;
    }
}
-(BOOL) on_mouse_down:(mouse_key_event) event
{
	m_mouse_down_ = TRUE;
	m_moved_since_mouse_down_ = FALSE;
	std::vector<SpriteBase*> current_selected_sprites = m_selected_sprites.get_selection();
	std::vector<SpriteBase*>::iterator it;
    GameSouSouSouEditorLevel* edlvl = (GameSouSouSouEditorLevel*)[GameBase get_game].m_level;
    [self unselect_all];

	std::vector<SpriteBase*> selected_sprites = [edlvl pick_sprite:event.loc_in_view :0];

    m_selected_sprites.set_selection(selected_sprites);
	[ self apply_selection ];
	[ self setup_trigger_property_window ];
    //NSLog(L"%@", picked);
	return TRUE;
}
-(BOOL) on_mouse_moved:(mouse_key_event) event
{
	CGPoint loc = event.loc_in_view;//[[ CCDirector sharedDirector] convertToGL : event.loc_in_view];
	if ( m_navigating_ )
	{
		CGPoint down = m_navstart_mouse_loc_;//[[ CCDirector sharedDirector] convertToGL : m_mouse_down_loc_];
		CGPoint offset = ccpSub( loc , down);
		offset = ccpMult(offset, -4.0/[GameBase get_game].m_scene.m_gameplayer_layer.scale);
		[GameBase get_game].m_scene.m_ed_viewoffset = ccpAdd( m_navstart_scene_viewoffset_ , offset );//ccpAdd( pos, ccpMult(ccpSub(loc1, loc2), 1.0f/
	}
	if ( m_mouse_down_ == TRUE )
	{
		if ( m_moved_since_mouse_down_ == FALSE )
		{
			[(GameSouSouSouEditorLevel*) [GameBase get_game].m_level push_histroy];
		}
		m_moved_since_mouse_down_ = TRUE;
		std::vector<SpriteBase*> selected_sprites = m_selected_sprites.get_selection();
		std::vector<SpriteBase*>::iterator it;
		for ( it = selected_sprites.begin(); it != selected_sprites.end(); ++it )
		{
			CGPoint loc_in_layer = [[(*it) get_layer] convertToNodeSpace:loc];
			CGPoint offset = [[(*it) get_hitproxy] get_picked_offset];
			for( int i = 0; i < (*it).sprite_components_count; i++ )
			{
				[ (*it) set_physic_position:i :ccpAdd( loc_in_layer, offset ) ];
				//modify the grigger init position param
			}
			CGPoint pt = ccpAdd( loc_in_layer, offset);
			[(*it) set_position:pt.x y:pt.y];
			CGPoint newpos = (*it).m_position;
			level_progress_trigger* trigger = [[GameBase get_game].m_level get_trigger_by_id: [ (*it) get_trigger_id]];
			[trigger->get_params() setObject:[NSString stringWithFormat:@"%.2f,%.2f", newpos.x, newpos.y ] forKey:@"init_position"];
			
			break;
		}
		
		[get_trigger_property_window() update_content];
	}
	return TRUE;
}
-(BOOL) on_mouse_up:(mouse_key_event) event
{
	m_mouse_down_ = FALSE;
	return TRUE;
}

-(BOOL) on_mouse_scroll:(mouse_key_event)event
{
	float s = [GameBase get_game].m_scene.m_gameplayer_layer.scale;
	CGPoint scroll_orig;
	CGPoint ed_viewoffset = [GameBase get_game].m_scene.m_ed_viewoffset;
	scroll_orig = ccpSub( event.loc_in_view,ed_viewoffset );
	scroll_orig = ccpMult( scroll_orig, 1.0/s );
	s -= event.scroll_delta_y/1000;
	if ( s > 4 )
		s = 4;
	if ( s < 0.3 )
		s = 0.3;
	
	
	[[GameBase get_game].m_scene.m_gameplayer_layer setScale:s];
//	[[GameBase get_game].m_scene.m_BGLayer1 setScale:s];
//	[[GameBase get_game].m_scene.m_BGLayer2 setScale:s];
	CGPoint offset = ccpMult(scroll_orig, -s );
	//CGPoint viewoffset = ccpMult(event.loc_in_view, s/olds );
	offset = ccpAdd( offset, event.loc_in_view);
	//	offset = ccpMult(scroll_orig, s);
	[GameBase get_game].m_scene.m_ed_viewoffset = offset;//ccpAdd([GameBase get_game].m_scene.m_ed_viewoffset, offset);
	return TRUE;
}

-(BOOL) on_key_down:(mouse_key_event) event
{
	if ( event.key == 49 && m_navigating_ == false )
	{
		m_navstart_mouse_loc_ = event.loc_in_view;
		m_navstart_scene_viewoffset_ = [GameBase get_game].m_scene.m_ed_viewoffset;
		m_navigating_ = true;
		NSLog(@"key down");
	}
    if ( event.key == 51 )
    {
		GameSouSouSouEditorLevel* lvl = (GameSouSouSouEditorLevel*)[GameBase get_game].m_level;
		[lvl push_histroy];
        std::vector<int> trigger_ids;
        //get all trigger for these sprites
        std::vector<SpriteBase*> current_selected_sprites = m_selected_sprites.get_selection();
        for( std::vector<SpriteBase*>::iterator it = current_selected_sprites.begin(); it != current_selected_sprites.end(); ++it )
        {
            if ( (*it) != NULL )
                trigger_ids.push_back([(*it) get_trigger_id]);
        }
        
		for ( std::vector<int>::iterator it = trigger_ids.begin(); it != trigger_ids.end(); ++it )
		{
			
			[lvl delete_trigger: *it ];
		}
        //删除所有trigger后选中的Sprite自然会被删除
		
        //clear selection
        [self unselect_all];
        NSLog(@"delete");
    }
	return  TRUE;
}

-(void) on_param_changed:(id) sender
{
}

-(BOOL) on_key_up:(mouse_key_event) event
{
	if ( event.key == 49 )
		m_navigating_ = false;
	
	return TRUE;
}
@end

@implementation AddOperator

-(void) on_param_changed:(id) sender
{
	level_progress_trigger* trigger;
	NSString* identifier = [sender identifier];
	NSString* strval = [sender stringValue];
    
    trigger = &m_template_trigger;
    if ( trigger->get_params() == nil )
    {
        trigger->set_params([NSMutableDictionary dictionary]);
    }
    
    if ( [identifier isEqualToString:@"trigger_class"] )
        [trigger->get_params() setObject:strval forKey:@"class"];
    
    if ( [identifier isEqualToString:@"trigger_progress_pos"] )
    {
        trigger->progress_pos = [sender floatValue];
        [trigger->get_params() setObject:strval forKey:@"progress"];
    }
    if ( [identifier isEqualToString:@"trigger_init_position"] )
        [trigger->get_params() setObject:strval forKey:@"init_position"];
    
    if ( [identifier isEqualToString:@"trigger_init_rotation"] )
        [trigger->get_params() setObject:strval forKey:@"init_rotation"];
    
    if ( [identifier isEqualToString:@"trigger_init_scale"] )
        [trigger->get_params() setObject:strval forKey:@"init_scale"];
    
    if ( [identifier isEqualToString:@"trigger_init_zorder"] )
        [trigger->get_params() setObject:strval forKey:@"init_zorder"];
    
    if ( [identifier isEqualToString:@"trigger_sprite_desc"] )
        [trigger->get_params() setObject:strval forKey:@"sprite_desc"];
    
    if ( [identifier isEqualToString:@"trigger_layer"] )
        [trigger->get_params() setObject:strval forKey:@"layer"];
    
    
    
}

-(void) on_activated
{
	[get_trigger_property_window() set_trigger:&m_template_trigger];
}

-(BOOL) on_mouse_down:(mouse_key_event)event
{
	
	CGPoint spawn_loc = event.loc_in_view;
	//construct trigger
	level_progress_trigger trigger;
	//trigger.action_type = ta_addobj;
	trigger.progress_pos = 0;
	trigger.id = 0;
	TriggerPropertyWindow* wnd = get_trigger_property_window();
	NSString* strlayer = [wnd.trigger_layer stringValue];
	if ( [strlayer isEqualToString:@""] )
		strlayer = @"game";
	if ( [[wnd.trigger_sprite_desc stringValue] isEqualToString:@""] )
        return FALSE;
    if ([[wnd.sprite_class stringValue] isEqualToString:@""] )
        return FALSE;
    
	spawn_loc = [[[GameBase get_game].m_scene get_layer_by_name:strlayer ] convertToNodeSpace:spawn_loc];
	trigger.set_params(  [NSMutableDictionary dictionary] );
//	[trigger.get_params() retain];
	[trigger.get_params() setObject:@"add_obj" forKey:@"act"];
	[trigger.get_params() setObject:[wnd.trigger_sprite_desc stringValue] forKey:@"sprite_desc"];
	[trigger.get_params() setObject:strlayer forKey:@"layer"];
	[trigger.get_params() setObject:[NSString stringWithFormat:@"%.2f,%.2f", spawn_loc.x, spawn_loc.y ] forKey:@"init_position"];
	[trigger.get_params() setObject:[wnd.trigger_init_scale stringValue] forKey:@"init_scale"];
	[trigger.get_params() setObject:[wnd.trigger_init_zorder stringValue] forKey:@"init_zorder"];
	[trigger.get_params() setObject:[NSString stringWithFormat:@"%.2f",trigger.progress_pos ] forKey:@"progress"];
	[trigger.get_params() setObject:[wnd.sprite_class stringValue] forKey:@"class"];

	//then add it into level	
	//int newtriggerid =
	[(GameSouSouSouEditorLevel*)[GameBase get_game].m_level add_trigger_at_runtime:trigger];
	
	//newtriggerid;
	return TRUE;
}

@end