//
//  obj_runtime_new.m
//  GameSaDEditor
//
//  Created by Zero Fancy on 12-10-27.
//
//
#import <Foundation/Foundation.h>
#import "obj_runtime_new.h"
#import <objc/objc.h>


struct objc_class2 {
    Class isa;
    Class super_class;
    const char *name;
    long version;
    long info;
    long instance_size;
    struct objc_ivar_list *ivars;
    struct objc_method_list **methodLists;
    struct objc_cache *cache;
    struct objc_protocol_list *protocols;
};

BOOL classIsSubclassOfClass2( const Class aClass, const Class subclass )
{
	struct objc_class2* temp = (struct objc_class2*)aClass;
	struct objc_class2* sub = (struct objc_class2*)subclass;
	int match = -1;
	
	while( temp != NULL && temp->super_class!= subclass  )
		temp = temp->super_class;
	
	if ( temp != NULL )
		return TRUE;
	return FALSE;
}

BOOL classIsNSObject( const Class aClass ) {
	// returns YES if <aClass> is an NSObject derivative, otherwise NO.
	// It does this without invoking any methods on the class being tested.
	return classIsSubclassOfClass2( aClass, [NSObject class]);
}


@implementation DKRuntimeHelper

+ (NSArray*) allClasses {
    return [self allClassesOfKind:[NSObject class]];
}

+ (NSArray*) allClassesOfKind:(Class) aClass {
    // returns a list of all Class objects that are of kind <aClass> or a subclass of it currently
    // registered in the runtime. This caches the result so that the relatively expensive
    // run-through is only performed the first time
    static NSMutableDictionary* cache = nil;
	
    if ( cache == nil )
		cache = [[NSMutableDictionary alloc] init];
	
    // is the list already cached?
    NSArray* cachedList = [cache objectForKey:NSStringFromClass( aClass )];
	
    if ( cachedList != nil )
		return cachedList;
	
    // if here, list wasn't in the cache, so build it the hard way
    NSMutableArray* list = [NSMutableArray array];
	
    Class* buffer = NULL;
    Class  cl;
	
    int i, numClasses = objc_getClassList( NULL, 0 );
	
    if( numClasses > 0 )  {
		buffer = malloc( sizeof(Class) * numClasses );
		NSAssert( buffer != nil, @"couldn't allocate the buffer");
		(void) objc_getClassList( buffer, numClasses );
		
		// Go through the list and carefully check whether the class can respond to isSubclassOfClass:
		// If so, add it to the list.
		
		for( i = 0; i < numClasses; ++i ) {
			cl = buffer[i];
			if( classIsSubclassOfClass2( cl, aClass ))
				[list addObject:cl];
		}
		free( buffer );
    }
	
    // save in cache for next time
	NSString* str = NSStringFromClass( aClass ) ;
    [cache setObject:list forKey:str];
    return list;
}

@end