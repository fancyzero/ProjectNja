//
//  EditorController.m
//  ShotAndRun4
//
//  Created by Zero Fancy on 12-10-26.
//
//

#import "EditorController.h"
#import "OperatorBase.h"
#import "EditorCommon.h"
#import "AppDelegate.h"
@implementation EditorController


-(id) init
{
	self = [super init];
	[[[CCDirector sharedDirector] eventDispatcher] addKeyboardDelegate:self priority:0];
	[[[CCDirector sharedDirector] eventDispatcher] addMouseDelegate:self priority:0];
	m_op_current = m_op_navigator =[ NavigatorOperator new ];
	m_op_add = [ AddOperator new ];
	[self swith_edit_mode:sed_modify];
	return self;
}

- (void)dealloc
{
	[m_op_navigator release];
	[m_op_add release];
    [super dealloc];
}
-(enum SadEdMode) get_edit_mode
{
	if ( m_op_current == m_op_navigator)
		return sed_modify;
	else
		return sed_add;
}
-(void) swith_edit_mode:(enum SadEdMode) mode
{
	switch (mode) {
		case sed_add:
			m_op_current = m_op_add;
			[m_op_add on_activated];
			//[get_trigger_property_window() set_trigger:&m_template_trigger];
			break;
		case sed_modify:
			m_op_current = m_op_navigator;
			[m_op_navigator on_activated];
			
			//[get_trigger_property_window() set_trigger:&m_template_trigger];

		default:
			break;
	}
}

-(BOOL) ccMouseDown:(NSEvent*)event
{
	
	mouse_key_event mevt;
	GameSaDEditorAppDelegate* dele;
	dele = (GameSaDEditorAppDelegate* )[NSApplication sharedApplication].delegate;
	NSPoint pt1 = [dele.glView convertPointFromBase:[event locationInWindow]];
	mevt.loc_in_view = pt1;
	

	[m_op_current on_mouse_down: mevt];
	return TRUE;
}

-(BOOL) ccMouseDragged:(NSEvent*)event
{
	mouse_key_event mevt;
	GameSaDEditorAppDelegate* dele;
	dele = (GameSaDEditorAppDelegate* )[NSApplication sharedApplication].delegate;
	NSPoint pt1 = [dele.glView convertPointFromBase:[event locationInWindow]];
	mevt.loc_in_view = pt1;
	[m_op_current on_mouse_moved: mevt];
	return TRUE;
}

-(BOOL) ccMouseMoved:(NSEvent*)event
{
	mouse_key_event mevt;
	GameSaDEditorAppDelegate* dele;
	dele = (GameSaDEditorAppDelegate* )[NSApplication sharedApplication].delegate;
	NSPoint pt1 = [dele.glView convertPointFromBase:[event locationInWindow]];
	mevt.loc_in_view = pt1;
	[m_op_current on_mouse_moved: mevt];
	return TRUE;
}

-(BOOL) ccMouseUp:(NSEvent*)event
{
	mouse_key_event mevt;
	GameSaDEditorAppDelegate* dele;
	dele = (GameSaDEditorAppDelegate* )[NSApplication sharedApplication].delegate;
	NSPoint pt1 = [dele.glView convertPointFromBase:[event locationInWindow]];
	mevt.loc_in_view = pt1;
	[m_op_current on_mouse_up: mevt];
	return TRUE;
}

-(BOOL) ccScrollWheel:(NSEvent *)event
{
	mouse_key_event mevt;
	mevt.scroll_delta_x = [event scrollingDeltaX];
	mevt.scroll_delta_y = [event scrollingDeltaY];
	GameSaDEditorAppDelegate* dele;
	dele = (GameSaDEditorAppDelegate* )[NSApplication sharedApplication].delegate;
	NSPoint pt1 = [dele.glView convertPointFromBase:[event locationInWindow]];
	mevt.loc_in_view = pt1;
	
	[ m_op_current on_mouse_scroll:mevt];
	return TRUE;
}

-(BOOL) ccRightMouseDown:(NSEvent*)event
{
	return TRUE;
}

-(BOOL) ccRightMouseDragged:(NSEvent*)event
{
	return TRUE;
}

-(BOOL) ccRightMouseUp:(NSEvent*)event
{
	return TRUE;	
}

-(BOOL) ccKeyDown:(NSEvent *)event
{
	mouse_key_event kevt;

	GameSaDEditorAppDelegate* dele;
	dele = (GameSaDEditorAppDelegate* )[NSApplication sharedApplication].delegate;
	//NSPoint mouseloc = [NSEvent mouseLocation];
	NSPoint pt1 = [dele.glView convertPointFromBase:[dele.window convertScreenToBase: [NSEvent mouseLocation]]];
	kevt.loc_in_view = pt1;
	kevt.key = [event keyCode];
	if ( kevt.key == 12 )
	{
		[get_trigger_property_window().edit_mode_switch setSelectedSegment:0];
		[self swith_edit_mode:sed_add];
	}
	if ( kevt.key == 13 )
	{
		[get_trigger_property_window().edit_mode_switch setSelectedSegment:1];
		[self swith_edit_mode:sed_modify];
	}
	[ m_op_current on_key_down:kevt];
	return TRUE;
}

-(BOOL) ccKeyUp:(NSEvent *)event
{
	mouse_key_event kevt;
	GameSaDEditorAppDelegate* dele;
	dele = (GameSaDEditorAppDelegate* )[NSApplication sharedApplication].delegate;
	NSPoint pt1 = [dele.glView convertPointFromBase:[dele.window convertScreenToBase: [NSEvent mouseLocation]]];
	kevt.loc_in_view = pt1;
	kevt.key = [event keyCode];
	[ m_op_current on_key_up:kevt];
	return TRUE;
}
@end
