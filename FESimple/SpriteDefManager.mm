
//
//  SpriteDefManager.m
//  ShotAndRun3
//
//  Created by Fancy Zero on 12-6-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SpriteDefManager.h"
#import "SpriteBase.h"
#import "SpriteXMLParser.h"
#import "CCFileUtils.h"
#import "GameBase.h"
#import "SpriteXMLParser.h"
#include "pugixml/pugixml.hpp"
#include "Box2D.h"


void read_sprite_def( sprite_def& def, const pugi::xml_node& node )
{
    auto parts = node.child("components").children("component");
    for( auto it_component : parts)
    {
        sprite_part_def part;
        part.m_desc = it_component.attribute("desc").as_string();
        part.m_rotation = it_component.attribute("rotation").as_float();
        sscanf(it_component.attribute("offset").as_string(), "%f,%f", &part.m_offset.x, &part.m_offset.y);
        def.m_parts.push_back(part);
        
    }
    auto joints = node.child("joints").children("joint");
    for( auto it_joint : joints)
    {
        sprite_joint_def joint;
        joint.component_a = it_joint.attribute("component_a").as_int();
        joint.component_b = it_joint.attribute("component_b").as_int();
        joint.joint_flags[0] = it_joint.attribute("enable_limit").as_bool();
        joint.joint_params[0] = it_joint.attribute("up_limit").as_float();
        joint.joint_params[1] = it_joint.attribute("low_limit").as_float();
        if ( strcmp( it_joint.attribute("type").as_string(), "revolute") == 0 )
            joint.joint_type = e_revoluteJoint;
        def.m_joints.push_back(joint);
    }
    
}


NSMutableDictionary* sprite_defs = NULL;
NSMutableDictionary* sprite_component_defs = NULL;
@implementation SpriteDefManager

+(void) add_sprite_component_def: ( struct sprite_component_def*) def :(NSString*) name
{
	if ( sprite_component_defs == NULL )
        sprite_component_defs = [ NSMutableDictionary new];
	[ sprite_component_defs setObject:[ NSValue valueWithPointer:def] forKey:name];
}

+(void) add_sprite_def: ( struct sprite_def*) def :(NSString*) name
{
	if ( sprite_defs == NULL )
        sprite_defs = [ NSMutableDictionary new];
	[ sprite_defs setObject:[ NSValue valueWithPointer:def] forKey:name];
}

+(struct sprite_def*) load_sprite_def : (NSString*) filename
{
	if ( sprite_defs == NULL )
        sprite_defs = [ NSMutableDictionary new];
    if ( [ sprite_defs valueForKey:filename ] != NULL )
        return (struct sprite_def*)[[ sprite_defs valueForKey:filename ] pointerValue ];
    sprite_def* def = new sprite_def();
    [ self load_sprite_def_database:filename ];
    [ sprite_defs setObject: [ NSValue valueWithPointer:def] forKey:filename];
    return def;
}




+( sprite_component_def*) load_sprite_component_def : (NSString*) filename
{
    if ( sprite_component_defs == NULL )
        sprite_component_defs = [ NSMutableDictionary new];
    if ( [ sprite_component_defs valueForKey:filename ] != NULL )
	{
		struct sprite_component_def* def;
		def = (struct sprite_component_def*)[[ sprite_component_defs valueForKey:filename ] pointerValue ];
        return def;
	}
    sprite_component_def* def = new sprite_component_def();

    NSURL *xmlURL = [NSURL fileURLWithPath:[[CCFileUtils sharedFileUtils] fullPathFromRelativePath:filename]];
    NSXMLParser* xmlparser = [[ NSXMLParser alloc ] initWithContentsOfURL:xmlURL];
    SpriteXMLParser* my_parser = [[ SpriteXMLParser alloc ] init:def];
    
    [ xmlparser setDelegate:my_parser ];
    
    [ my_parser->m_parsers addObject:[ phy_parser new ]];
    [ my_parser->m_parsers addObject:[ anim_parser new ]];
	
	
    [ xmlparser parse ];
    [ my_parser release];
	[ xmlparser release ];
    [ sprite_component_defs setObject: [ NSValue valueWithPointer:def] forKey:filename];
//	NSLog(@"xmlurl retain count :%d", [ xmlURL retainCount ]);
    return def;
}


+(void) load_sprite_def_database:(NSString*) filename
{
    NSString* full_path = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:filename];
    
    pugi::xml_document doc;
    doc.load_file([full_path UTF8String] );
    
    NSLog(@"%s", doc.root().name() );
    auto sprites = doc.child("sprites").children("sprite");
    for ( auto it = sprites.begin(); it != sprites.end(); ++it )
    {
        NSLog(@"load sprite: %s", it->attribute("name").as_string());
        sprite_def* def = new sprite_def();
        NSString* keyname = [filename stringByAppendingFormat:@":%s" ,it->attribute("name").as_string()];
        
        read_sprite_def( *def ,*it );
        [SpriteDefManager add_sprite_def: def :keyname];
    }
    
}

+(void) load_sprite_component_def_database:(NSString*) filename
{
	NSURL *xmlURL = [NSURL fileURLWithPath:[[CCFileUtils sharedFileUtils] fullPathFromRelativePath:filename]];
    NSXMLParser* xmlparser = [[ NSXMLParser alloc ] initWithContentsOfURL:xmlURL];
    SpriteXMLParser* my_parser = [[ SpriteXMLParser alloc ] init:NULL];
    [ xmlparser setDelegate:my_parser ];
    sprite_component_database_loader* loader = [ sprite_component_database_loader new ];
	loader->m_filename = filename;
	loader->current_def = NULL;
    [ my_parser->m_parsers addObject:loader];
	
    [ xmlparser parse ];
    [ my_parser release];
	[ xmlparser release ];
}
+(int) sprite_def_count
{
	return (int)[sprite_defs count];
}

+(NSString*) get_sprite_def_url:(int) index
{
	if ( [sprite_defs count] > index )
	{
		return [sprite_defs allKeys][index];
	}
	return NULL;
}

@end
