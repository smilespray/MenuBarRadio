//
//  StoreSettingsDAO.h
//  MenuBarRadio
//
//  Created by Trygve Sanne Hardersen on 09/05/15.
//  Copyright (c) 2015 Snorre Milde. All rights reserved.
//

#import "DAO.h"
#import "StoreSettings+Extensions.h"

OBJC_EXPORT NSString *kStoreSettingsEntityName;

@interface StoreSettingsDAO : DAO

#pragma mark - StoreSettingsDAO Lifecycle

- (instancetype)initWithManagedObjectContect:(NSManagedObjectContext *)managedObjectContext;

#pragma mark - StoreSettingsDAO Fetching

- (StoreSettings *)fetchStoreSettings:(NSError **)error;

@end
