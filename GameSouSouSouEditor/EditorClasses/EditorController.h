//
//  EditorController.h
//  ShotAndRun4
//
//  Created by Zero Fancy on 12-10-26.
//
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"
#import "ControllerBase.h"
#import "Level.h"
@class NavigatorOperator;
@class SaDEditor;
@class OperatorBase;
@class AddOperator;

enum SadEdMode
{
	sed_modify,
	sed_add,
};


@interface EditorController : ControllerBase<CCMouseEventDelegate,CCKeyboardEventDelegate>
{
	@public
	SaDEditor*			m_editor_;
	OperatorBase*		m_op_current;
	NavigatorOperator*	m_op_navigator;
	AddOperator*		m_op_add;

}
-(enum SadEdMode) get_edit_mode;
-(void) swith_edit_mode:(enum SadEdMode) mode;
//
// left
//
/** called when the "mouseDown" event is received.
 Return YES to avoid propagating the event to other delegates.
 */
-(BOOL) ccMouseDown:(NSEvent*)event;

/** called when the "mouseDragged" event is received.
 Return YES to avoid propagating the event to other delegates.
 */
-(BOOL) ccMouseDragged:(NSEvent*)event;

/** called when the "mouseMoved" event is received.
 Return YES to avoid propagating the event to other delegates.
 By default, "mouseMoved" is disabled. To enable it, send the "setAcceptsMouseMovedEvents:YES" message to the main window.
 */
-(BOOL) ccMouseMoved:(NSEvent*)event;

/** called when the "mouseUp" event is received.
 Return YES to avoid propagating the event to other delegates.
 */
-(BOOL) ccMouseUp:(NSEvent*)event;


//
// right
//

/** called when the "rightMouseDown" event is received.
 Return YES to avoid propagating the event to other delegates.
 */
-(BOOL) ccRightMouseDown:(NSEvent*)event;

/** called when the "rightMouseDragged" event is received.
 Return YES to avoid propagating the event to other delegates.
 */
-(BOOL) ccRightMouseDragged:(NSEvent*)event;

/** called when the "rightMouseUp" event is received.
 Return YES to avoid propagating the event to other delegates.
 */
-(BOOL) ccRightMouseUp:(NSEvent*)event;
@end
