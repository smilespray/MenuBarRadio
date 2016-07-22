//
//  AppDelegate.h
//  Menu Bar Radio
//
//  Created by Snorre Milde on 07/05/15.
//  Copyright (c) 2015 Snorre Milde. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "STKAudioPlayer.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, STKAudioPlayerDelegate>

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end
