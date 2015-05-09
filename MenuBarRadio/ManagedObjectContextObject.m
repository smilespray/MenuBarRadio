//
//  ManagedObjectContextObject.m
//  MenuBarRadio
//
//  Created by Trygve Sanne Hardersen on 09/05/15.
//  Copyright (c) 2015 Snorre Milde. All rights reserved.
//

#import "ManagedObjectContextObject.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
#endif

@interface ManagedObjectContextObject ()

@property (readonly, strong, nonatomic) NSThread *managedObjectContextThread;

@end

@implementation ManagedObjectContextObject

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectContextThread = _managedObjectContextThread;

- (instancetype)init
{
    if (!(self = [super init])) {
        return nil;
    }
    
    if ([NSThread currentThread] == [NSThread mainThread]) {
        _managedObjectContext = [ManagedObjectContextObject managedObjectContextFromAppDelegate];
    } else {
        if ([self conformsToProtocol:@protocol(ManagedObjectContextCustomization)]) {
            id<ManagedObjectContextCustomization> customization = (id<ManagedObjectContextCustomization>)self;
            _managedObjectContext = [ManagedObjectContextObject managedObjectContextForCurrentThread:customization];
        } else {
            _managedObjectContext = [ManagedObjectContextObject managedObjectContextForCurrentThread:nil];
        }
    }
    _managedObjectContextThread = [NSThread currentThread];
    
    return self;
}

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _managedObjectContext = managedObjectContext;
    _managedObjectContextThread = [NSThread currentThread];
    
    return self;
}

+ (NSManagedObjectContext *)managedObjectContextFromAppDelegate
{
    NSManagedObjectContext *managedObjectContext;
#if TARGET_OS_IPHONE
    UIApplication *app = [UIApplication sharedApplication];
#elif TARGET_OS_MAC
    NSApplication *app = [NSApplication sharedApplication];
#endif
    if (app != nil && app.delegate != nil && [app.delegate respondsToSelector:@selector(managedObjectContext)]) {
        managedObjectContext = [app.delegate performSelector:@selector(managedObjectContext)];
    }
    if (!managedObjectContext) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Unable to obtain NSManagedObjectContext from app delegate"];
        return nil;
    }
    return managedObjectContext;
}

+ (NSManagedObjectContext *)managedObjectContextForCurrentThread:(id<ManagedObjectContextCustomization>)customization
{
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
#if TARGET_OS_IPHONE
    UIApplication *app = [UIApplication sharedApplication];
#elif TARGET_OS_MAC
    NSApplication *app = [NSApplication sharedApplication];
#endif
    if (app != nil && app.delegate != nil && [app.delegate respondsToSelector:@selector(persistentStoreCoordinator)]) {
        persistentStoreCoordinator = [app.delegate performSelector:@selector(persistentStoreCoordinator)];
    }
    if (!persistentStoreCoordinator) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Unable to obtain NSPersistentStoreCoordinator from app delegate"];
        return nil;
    }
    
    if (customization && [customization respondsToSelector:@selector(willCreateManagedObjectContext:)]) {
        [customization willCreateManagedObjectContext:persistentStoreCoordinator];
    }
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
    if (customization && [customization respondsToSelector:@selector(didCreateManagedObjectContext:)]) {
        [customization didCreateManagedObjectContext:managedObjectContext];
    }
    
    return managedObjectContext;
}

@end
