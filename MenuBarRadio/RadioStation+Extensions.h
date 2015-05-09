//
//  RadioStation+Extensions.h
//  MenuBarRadio
//
//  Created by Trygve Sanne Hardersen on 09/05/15.
//  Copyright (c) 2015 Snorre Milde. All rights reserved.
//

#import "RadioStation.h"

typedef enum : NSUInteger {
    RadioStationOriginUnknown = 0,
    RadioStationOriginCloud = 10,
    RadioStationOriginUser = 20,
    RadioStationOriginFriend = 30
} RadioStationOrigin;

@interface RadioStation (Extensions)

@property (assign, nonatomic) RadioStationOrigin stationOrigin;

+ (RadioStationOrigin)stationOriginFromNumber:(NSNumber *)number;

@end
