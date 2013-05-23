//
//  OperatorBase.h
//  GameSaDEditor
//
//  Created by Zero Fancy on 12-11-15.
//
//

#import <Foundation/Foundation.h>
#import <vector>
#import "Level.h"
@class SpriteBase;
struct mouse_key_event
{
	CGPoint loc_in_view;
	float	scroll_delta_x;
	float	scroll_delta_y;
	int key;
};
template <class T>
class Selection
{
	std::vector<T> m_selection;
	
public:
	std::vector<T> get_selection()
	{
		return m_selection;
	}
	void set_selection( std::vector<T>& selection)
	{
		m_selection = selection;
	}
    void clear()
    {
        m_selection.clear();
    }
    void remove(T obj)
    {
        for( typename std::vector<T>::iterator it = m_selection.begin(); it != m_selection.end(); ++it )
        {
            if ( *it == obj )
            {
                m_selection.erase(it);
                break;
            }
        }
    }
};


@interface OperatorBase : NSObject
{
	@public
	Selection<SpriteBase*> m_selected_sprites;
    std::vector<level_progress_trigger> m_copied_triggers;//for copy and paste
}
-(void) apply_selection;
-(void) unselect_all;
-(void) update_selection;//当某些selection中的object被另一个operator删除后，调用一下这个函数，可以刷新该operator的selection集合，剔除已被删除的object
-(void) on_activated;
-(BOOL) on_mouse_down:(mouse_key_event) event;
-(BOOL) on_mouse_moved:(mouse_key_event) event;
-(BOOL) on_mouse_up:(mouse_key_event) event;
-(BOOL) on_mouse_scroll:(mouse_key_event) event;
-(BOOL) on_key_down:(mouse_key_event) event;
-(BOOL) on_key_up:(mouse_key_event) event;
-(void) pre_sprtie_deleted:(SpriteBase*) spr;//即将要删除一个sprite时
-(void) on_copy;
-(void) on_paste;
-(void) on_param_changed:(id) sender;
//-(void) on_sprite_added;
@end

@interface NavigatorOperator : OperatorBase //navigat in level using mouse
{
	CGPoint m_mouse_down_loc_;
	BOOL	m_mouse_down_;
	BOOL	m_moved_since_mouse_down_;
	CGPoint m_navstart_mouse_loc_;
	CGPoint m_navstart_scene_viewoffset_;
	BOOL	m_navigating_;
}
-(void) on_activated;
-(BOOL) on_mouse_down:(mouse_key_event) event;
-(BOOL) on_mouse_moved:(mouse_key_event) event;
-(BOOL) on_mouse_up:(mouse_key_event) event;
-(BOOL) on_mouse_scroll:(mouse_key_event) event;
-(BOOL) on_key_down:(mouse_key_event) event;
-(BOOL) on_key_up:(mouse_key_event) event;
-(void) on_param_changed:(id) sender;
@end

@interface AddOperator : OperatorBase
{
	struct level_progress_trigger m_template_trigger;//for add operator	
}
-(void) on_activated;
-(void) on_param_changed:(id) sender;
-(BOOL) on_mouse_down:(mouse_key_event) event;
@end