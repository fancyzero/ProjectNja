//
//  GameSouSouSouEditorLevel.m
//  GameSaDEditor
//
//  Created by Zero Fancy on 12-11-24.
//
//

#import "GameSouSouSouEditorLevel.h"
#import "SaDEditor.h"

#include <vector>
#import "World.h"
#import "SpriteXMLParser.h"
#import "PhysicsDebuger.h"
#import "GameScene.h"
#include <box2d.h>
#import "Common.h"
#import "PhysicsSprite.h"
#import "SpriteProxy.h"
#import	"EditorVisualizer.h"
#import "GLES-Render.h"
#import "EditorCommon.h"
@implementation GameSouSouSouEditorLevel

-(void)reset
{
    m_filename_ = nil;
	m_show_act_range = FALSE;
	[super reset];
    GameBase* game = [GameBase get_game];// get_instance];
    [ game cleanup_world ];
	
    //[ super set_map_size:1024 - 160 :800];
//     World* world = game.m_world;

	CGRect ar;
	ar.origin = ccp(0,0);
	ar.size.width = 1000;
	ar.size.height = 700;
	[self set_acting_range: ar];
	if ( 1 )
	{
		physics_debug_sprite* pds = [ physics_debug_sprite new ];
		pds.zOrder = 2000;
		[[GameBase get_game].m_scene.m_layer addChild:pds ];
	}
	EditorVisualizer * act_vis = [ EditorVisualizer new];
	act_vis.zOrder = 1000;
	[[GameBase get_game].m_scene.m_layer addChild:act_vis ];
	
	
}

-(void)update:(float)delta_time
{
	float keep_level_progress = m_level_progress_;
    [ super update:delta_time];
	m_level_progress_ = keep_level_progress;
	//m_level_progress_ = 0;
	// update acting range
	//todo: optmize
	std::vector<level_acting_range_keyframe>::const_iterator i;
	level_acting_range_keyframe a,b;
	
	for ( i = m_acting_range_keyframes_.begin(); i != m_acting_range_keyframes_.end(); ++i)
	{
		b = *i;
		if ( b.progress >= m_level_progress_ )
			break;
	}
	if ( i != m_acting_range_keyframes_.begin())
	{
		a = (*(i-1));
		CGRect rc_act;
		if ( b.progress == a.progress )
		{
			[self set_acting_range:b.act_rect];
			self->m_acting_range_velocity_ = ccp(0,0);
		}
		else
		{
			float alpha = (m_level_progress_ - a.progress) / (b.progress - a.progress);
			rc_act.origin.x = a.act_rect.origin.x * (1- alpha) + b.act_rect.origin.x * alpha;
			rc_act.origin.y = a.act_rect.origin.y * (1- alpha) + b.act_rect.origin.y * alpha;
			rc_act.size.width = a.act_rect.size.width * (1- alpha) + b.act_rect.size.width * alpha;
			rc_act.size.height = a.act_rect.size.height * (1- alpha) + b.act_rect.size.height * alpha;
			self->m_acting_range_velocity_.x = (b.act_rect.origin.x - a.act_rect.origin.x) / (b.progress - a.progress);
			self->m_acting_range_velocity_.y = (b.act_rect.origin.y - a.act_rect.origin.y) / (b.progress - a.progress);
			[self set_acting_range:rc_act];
		}
		
	}
	else
	{
		[self set_acting_range:b.act_rect];
	}
	
    GameBase* game = [GameBase get_game];
	if ( super.m_next_trigger < m_level_triggers.size() )
	{
		for ( int i = super.m_next_trigger; i < m_level_triggers.size(); ++i )
		{
			//NSLog(@"trigging trigger %d %@", i, m_level_triggers[i].get_params());
			[ self triggering_trigger:&m_level_triggers[i]];
			super.m_next_trigger = i+1;
		}
	}
	
/*	[game.m_scene.m_layer setPosition: ccpAdd( ccp(0,0), game.m_scene.m_ed_viewoffset)];
	[game.m_scene.m_BGLayer1 setPosition: ccpAdd( ccp(0,0), game.m_scene.m_ed_viewoffset)];
	[game.m_scene.m_BGLayer2 setPosition: ccpAdd( ccp(0,0), game.m_scene.m_ed_viewoffset)];
*/
	CGPoint layerpt;
	layerpt = [[GameBase get_game].m_scene.m_layer calc_layer_pt:game.m_scene.m_ed_viewoffset];
	[[GameBase get_game].m_scene.m_layer set_desired_position: layerpt];
	[[GameBase get_game].m_scene.m_layer set_approaching_speed:200000];
	
	layerpt = [[GameBase get_game].m_scene.m_BGLayer1 calc_layer_pt:game.m_scene.m_ed_viewoffset];
	[[GameBase get_game].m_scene.m_BGLayer1 set_desired_position: layerpt];
	[[GameBase get_game].m_scene.m_BGLayer1 set_approaching_speed:200000];
	
	layerpt = [[GameBase get_game].m_scene.m_BGLayer2 calc_layer_pt:game.m_scene.m_ed_viewoffset];
	[[GameBase get_game].m_scene.m_BGLayer2 set_desired_position: layerpt];
	[[GameBase get_game].m_scene.m_BGLayer2 set_approaching_speed:200000];
	
}

-(void) on_sprite_dead: (SpriteBase*) sprite
{

}
-(void) on_remove_obj: (GameObjBase*) obj
{
}
-(void) on_sprite_spawned: (SpriteBase*) sprite
{
}
-(void) on_add_obj: (GameObjBase*) obj
{
}
-(void) on_level_start
{
}

-(int) compare_zorder:(SpriteBase*) a :(SpriteBase*) b
{
	if ( [a get_layer].zOrder > [b get_layer].zOrder )
		return 1;
	if ( [a get_layer].zOrder < [b get_layer].zOrder )
		return -1;
	
	if ( [a get_sprite_component:0].zOrder > [b get_sprite_component:0].zOrder )
		return 1;
	if ( [a get_sprite_component:0].zOrder == [b get_sprite_component:0].zOrder )
		return 1;
	if ( [a get_sprite_component:0].zOrder < [b get_sprite_component:0].zOrder )
		return -1;
	return 0;
}

//editor interface
-(std::vector<SpriteBase*>) pick_sprite:(CGPoint) pos :(int) layer
{
    GameBase* game;
    game = [ GameBase get_game ];
    std::vector<SpriteBase*> arr;
    for (GameObjBase* obj in game.m_world.m_gameobjects)
    {
        if ( [obj isKindOfClass:[SpriteBase class]] )
        {
            SpriteBase* spr;
            spr = (SpriteBase*) obj;
			CGPoint layer_pos = [[spr get_layer ] convertToNodeSpace:pos];
            SPRITECOMPONENTS result = [[spr get_hitproxy] pick:layer_pos];

            if ( result.size() > 0 )
            {
				[[spr get_hitproxy] set_picked_offset: ccpSub(spr.m_position, layer_pos) ];
                //[spr set_color_override:ccc4f(0, 1, 0, 1) mask:0.5 duration:10000];
				if ( arr.size() == 0 )
					arr.push_back(spr);
				else
				{
					std::vector<SpriteBase*>::iterator it ;
					for ( it = arr.begin(); it != arr.end(); ++it )
					{
						SpriteBase* itspr = *it;
						if ( [self compare_zorder:spr :itspr ] >= 1 )
						{
							arr.insert(it, spr);
							break;
						}

					}
					if ( it == arr.end())
						arr.push_back(spr);
				}
					
            }
        }
    }

	//return only one sprite,current not support multi select
	if ( arr.size() > 1 )
		arr.resize(1);
	//todo: sort by layer and zorder
	
    return arr;
}


-(void) on_trigger_changed:(int) trigger_id
{
	GameBase* game;
    game = [ GameBase get_game ];
    std::vector<SpriteBase*> arr;
	NSMutableArray* spr_to_remove = [NSMutableArray array];
	
    for (GameObjBase* obj in game.m_world.m_gameobjects)
    {
        if ( [obj isKindOfClass:[SpriteBase class]] )
        {
            SpriteBase* spr;
            spr = (SpriteBase*) obj;
			if ( [spr get_trigger_id ] == trigger_id )
			{
				[spr_to_remove addObject:spr];
			}
        }
    }
	
	for (SpriteBase* s in spr_to_remove)
	{
		[s remove_from_game:true];
	}
	[self triggering_trigger:[self get_trigger_by_id:trigger_id]];
	//delete sprite spawned by this trigger
	// and respawn it
}

-(void) save_to_file:(NSString *)filepath
{
	FILE* pf;
	pf = fopen( [filepath UTF8String] , "w+" );

	if ( pf == NULL )
		return;
	
	fprintf( pf, "<xml>\r\n");
	fprintf( pf, "\t<level map_width=\"%.2f\" map_height=\"%.2f\" >\r\n" , self.m_map_rect.size.width, self.m_map_rect.size.height);

	fprintf( pf, "\t\t<acting_range>\r\n");

	for ( std::vector<level_acting_range_keyframe>::iterator it = m_acting_range_keyframes_.begin(); it != m_acting_range_keyframes_.end(); ++it )
	{
		fprintf( pf, "<keyframe progress=\"%.2f\" pos=\"%.2f,%.2f\" size=\"%.2f,%.2f\"/>\r\n", (*it).progress,
			   (*it).act_rect.origin.x, (*it).act_rect.origin.y , (*it).act_rect.size.width, (*it).act_rect.size.height );
	}
	fprintf( pf, "\t\t</acting_range>\r\n");
	fprintf( pf, "\t\t<actions>\r\n");
	
	for ( std::vector<level_progress_trigger>::iterator it = m_level_triggers.begin(); it != m_level_triggers.end(); ++it )
	{
		level_progress_trigger& t = (*it);


		fprintf(pf, "\t\t\t<action " );
		NSArray* keys = [t.get_params() allKeys];
		NSString* tmppp = [ NSString stringWithFormat:@"%f",t.progress_pos];
		[t.get_params() setValue:tmppp forKey:@"progress"];
		for (NSString* s in keys )
		{
			NSString* v = [t.get_params() objectForKey:s];
			fprintf( pf, "%s=\"%s\" ", [s UTF8String] , [v UTF8String]);
		}
		fprintf(pf, "/>\r\n" );
	}
	fprintf( pf, "\t\t</actions>\r\n");
	fprintf( pf, "\t</level>\r\n");	
	fprintf( pf, "</xml>\r\n");

	
	fclose(pf);
}

-(void) delete_trigger:(int) trigger_id
{
    //get tigger, remove it from trigger list
	std::vector<level_progress_trigger> new_triggers;
    for ( std::vector<level_progress_trigger>::iterator it = m_level_triggers.begin(); it != m_level_triggers.end(); ++it )
    {
        if ( (*it).id == trigger_id )
        {
			//delete sprites spawned by this trigger
			[ self delete_sprites_spawned_by_trigger: (*it).id ];
            //m_level_triggers.erase(it);
            //break;
        }
		else
		{
			new_triggers.push_back(*it);
		}
    }
	m_level_triggers.clear();
	m_level_triggers = new_triggers;
    
}

-(void) delete_sprites_spawned_by_trigger:(int)trigger_id
{
    //get all stprite spawned by same triger
    NSArray* sprites = [super get_sprite_by_trigger_id: trigger_id];
    for (SpriteBase* spr in sprites)
    {
        [spr remove_from_game:TRUE];
    }
}

-(int)	add_trigger_at_runtime:(struct level_progress_trigger) trigger
{
	//应该只有编辑器才会进到这里
	[self push_histroy];
	assert([[GameBase get_game] is_editor]);
	trigger.id = m_current_trigger_id;
	m_current_trigger_id++;
    
	std::vector<level_progress_trigger>::iterator it;
	int insert_pos = 0; //如果添加的trigger在 m_current_trigger 之前，会导致之后某个trigger被重复触发，所以这里要做下处理
	
	for ( it = m_level_triggers.begin(); it != m_level_triggers.end(); ++it )
	{
		if ( (*it).progress_pos > trigger.progress_pos )
		{
			m_level_triggers.insert(it, trigger);
			break;
		}
		insert_pos++;
	}
	if ( it == m_level_triggers.end() )
		m_level_triggers.push_back(trigger);
	else
	{
		//已修正：在游戏过程中，在triggers的中间插入了一个新的trigger,并且处于下一个要处理的trigger之前，也就是该trigger永远不会被自动triggering到
		if ( insert_pos < super.m_next_trigger )
		{
			
			super.m_next_trigger ++;
			//需要手动triggering一下
			[ self triggering_trigger:&trigger];
		}
	}
	return trigger.id;
}

-(void) show_act_range:(BOOL) show
{
	m_show_act_range = show;
}

-(BOOL) is_act_range_showed
{
	return m_show_act_range;
}

-(void) draw_acting_range
{
	b2Color color;
	color.Set(0, 1, 0);
	b2Vec2 verts[4];
	float ratio  = 1/[ GameBase get_ptm_ratio];
	verts[0].Set( m_acting_range_.origin.x*ratio, m_acting_range_.origin.y*ratio );
	verts[1].Set( m_acting_range_.origin.x*ratio + m_acting_range_.size.width*ratio, m_acting_range_.origin.y*ratio );
	verts[2].Set( m_acting_range_.origin.x*ratio + m_acting_range_.size.width*ratio, m_acting_range_.origin.y*ratio + m_acting_range_.size.height*ratio );
	verts[3].Set( m_acting_range_.origin.x*ratio , m_acting_range_.origin.y*ratio + m_acting_range_.size.height*ratio );

	
	[GameBase get_game].m_world.m_physics_debug->DrawPolygon(verts, 4, color);
}

-(void) set_progress:(float)progress
{
	m_level_progress_ = progress;
}

-(void) push_histroy
{
	
	m_op_histroy.push(m_level_triggers);
}
-(void) pop_histroy
{
	
	if ( m_op_histroy.size() == 0 )
		return;
    clear_selected();
	[self push_redo_histroy];
    
	std::vector<level_progress_trigger> triggers;
	triggers = m_op_histroy.top();
	m_op_histroy.pop();

	NSString* backup_filename = m_filename_;
	m_filename_ = @"";
	[self reset];
	m_level_triggers = triggers;
	m_filename_ = backup_filename;
}

-(void) push_redo_histroy 
{
	
	m_op_redo_histroy.push(m_level_triggers);
}

-(void) pop_redo_histroy
{

	if ( m_op_redo_histroy.size() == 0 )
		return;
        clear_selected();
		[self push_histroy];
	std::vector<level_progress_trigger> triggers;
	triggers = m_op_redo_histroy.top();
	m_op_redo_histroy.pop();
	
	NSString* backup_filename = m_filename_;
	m_filename_ = @"";
	[self reset];
	m_level_triggers = triggers;
	m_filename_ = backup_filename;
}
@end
