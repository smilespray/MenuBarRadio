//
//  RadioStationDAO.h
//  MenuBarRadio
//
//  Created by Trygve Sanne Hardersen on 08/05/15.
//  Copyright (c) 2015 Snorre Milde. All rights reserved.
//

#import "DAO.h"
#import "RadioStation+Extensions.h"

OBJC_EXPORT NSString *kRadioStationEntityName;
OBJC_EXPORT NSString *kRadioStationPropertyName;
OBJC_EXPORT NSString *kRadioStationPropertyURL;
OBJC_EXPORT NSString *kRadioStationPropertyPlaying;

@interface RadioStationDAO : DAO

#pragma mark - RadioStationDAO Lifecycle

- (instancetype)init;
- (instancetype)initWithManagedObjectContect:(NSManagedObjectContext *)managedObjectContext;

#pragma mark - RadioStationDAO Fetching

- (RadioStation *)fetchByName:(NSString *)name
                       origin:(RadioStationOrigin)origin
                        error:(NSError **)error;
- (NSArray *)fetchByDifferentSyncUUID:(NSString *)syncUUID
                               origin:(RadioStationOrigin)origin
                                error:(NSError **)error;
- (NSArray *)fetchSortedByName:(NSError **)error;

@end
