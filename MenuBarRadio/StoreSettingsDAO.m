//
//  StoreSettingsDAO.m
//  MenuBarRadio
//
//  Created by Trygve Sanne Hardersen on 09/05/15.
//  Copyright (c) 2015 Snorre Milde. All rights reserved.
//

#import "StoreSettingsDAO.h"

NSString *kStoreSettingsEntityName = @"StoreSettings";

@implementation StoreSettingsDAO

#pragma mark - StoreSettingsDAO Lifecycle

- (instancetype)init
{
    if (!(self = [super initWithEntityName:kStoreSettingsEntityName])) {
        return nil;
    }
    return self;
}

- (instancetype)initWithManagedObjectContect:(NSManagedObjectContext *)managedObjectContext
{
    if (!(self = [super initWithEntityName:kStoreSettingsEntityName
                      managedObjectContect:managedObjectContext])) {
        return nil;
    }
    return self;
}

#pragma mark - StoreSettingsDAO Fetching

- (StoreSettings *)fetchStoreSettings:(NSError *__autoreleasing *)error
{
    NSFetchRequest *fetchRequest = [self fetchRequest];
    return [self fetchObject:fetchRequest error:error];
}

@end
