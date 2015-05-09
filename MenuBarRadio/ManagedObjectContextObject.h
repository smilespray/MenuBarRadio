//
//  ManagedObjectContextObject.h
//  MenuBarRadio
//
//  Created by Trygve Sanne Hardersen on 09/05/15.
//  Copyright (c) 2015 Snorre Milde. All rights reserved.
//

#import <CoreData/CoreData.h>

/*!
 Protocol adopted by objects that need to customize the NSManagedObjectContext
 automatically created for [NSThread currentThread].
 */
@protocol ManagedObjectContextCustomization <NSObject>

@optional
/*!
 Called before the NSManagedObjectContext is created.
 @param persistentStoreCoordinator The NSPersistentStoreCoordinator obtained from
 the UIApplication's or NSApplication's app delegate.
 */
- (void)willCreateManagedObjectContext:(NSPersistentStoreCoordinator *)persistentStoreCoordinator;
/*!
 Called after the NSManagedObjectContext is created.
 @param managedObjectContext The created NSManagedObjectContext.
 */
- (void)didCreateManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

/*!
 Base object to inherit for objects that require a NSManagedObjectContext.
 Support automatically obtaining the NSManagedObjectContext from the
 UIApplication's or NSApplication's app delegate if used on [NSThread mainThread].
 If used on another thread the NSManagedObjectContext must either be manually set
 or automatically created for [NSThread currentThread].
 */
@interface ManagedObjectContextObject : NSObject
/*!
 The ManagedObjectContextObject NSManagedObjectContext. 
 Raises an NSException if nil or not used on the correct thread.
 */
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
/*!
 Automatically initializes the ManagedObjectContextObject's NSManagedObjectContext.
 Obtains the NSManagedObjectContext from the UIApplication's or the NSApplication's 
 app delegate if used on [NSThread mainThread], otherwise creates a new 
 NSManagedObjectContext for [NSThread currentThread].
 @return A new ManagedObjectContextObject instance.
 */
- (instancetype)init;
/*!
 Manually initializes the ManagedObjectContextObject's NSManagedObjectContext.
 @param managedObjectContext The NSManagedObjectContext to use for the ManagedObjectContextObject.
 @return A new ManagedObjectContextObject instance.
 */
- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
/*!
 Obtains the NSManagedObjectContext from the UIApplication's or the NSApplication's
 app delegate.
 @return The NSManagedObjectContext from the UIApplication's or the NSApplication's
 app delegate, never nil. Raises an NSException is the NSManagedObjectContext 
 can not be automatically obtained.
 */
+ (NSManagedObjectContext *)managedObjectContextFromAppDelegate;
/*!
 Creates a new NSManagedObjectContext for [NSThread currentThread].
 Uses the NSPersistentStoreCoordinator from the UIApplication's or the NSApplication's
 app delegate.
 @param customization Optional customization object.
 @return A new NSManagedObjectContext for [NSThread currentThread], never nil.
 Raises an NSException is the NSPersistentStoreCoordinator can not be automatically 
 obtained or if the NSManagedObjectContext can not be created.
 */
+ (NSManagedObjectContext *)managedObjectContextForCurrentThread:(id<ManagedObjectContextCustomization>)customization;

@end
