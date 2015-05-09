//
//  RadioStationService.h
//  MenuBarRadio
//
//  Created by Trygve Sanne Hardersen on 08/05/15.
//  Copyright (c) 2015 Snorre Milde. All rights reserved.
//

#import "ManagedObjectContextObject.h"

OBJC_EXPORT NSString *kRadioStationServiceVersionKey;
OBJC_EXPORT NSString *kRadioStationServiceRegionsKey;
OBJC_EXPORT NSString *kRadioStationServiceRegionCodeKey;
OBJC_EXPORT NSString *kRadioStationServiceRegionNameKey;
OBJC_EXPORT NSString *kRadioStationServiceRegionStationsKey;
OBJC_EXPORT NSString *kRadioStationServiceStationNameKey;
OBJC_EXPORT NSString *kRadioStationServiceStationURLKey;

@interface RadioStationService : ManagedObjectContextObject

+ (instancetype)defaultService;

- (instancetype)init;
- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (void)syncRadioStations:(void (^)(BOOL ok, NSError *error))completion;

@end
