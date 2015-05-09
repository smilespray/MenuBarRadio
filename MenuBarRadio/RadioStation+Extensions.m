//
//  RadioStation+Extensions.m
//  MenuBarRadio
//
//  Created by Trygve Sanne Hardersen on 09/05/15.
//  Copyright (c) 2015 Snorre Milde. All rights reserved.
//

#import "RadioStation+Extensions.h"

@implementation RadioStation (Extensions)

- (RadioStationOrigin)stationOrigin
{
    return [RadioStation stationOriginFromNumber:self.origin];
}

- (void)setStationOrigin:(RadioStationOrigin)stationOrigin
{
    self.origin = [NSNumber numberWithUnsignedInteger:stationOrigin];
}

+ (RadioStationOrigin)stationOriginFromNumber:(NSNumber *)number
{
    NSUInteger origin = (number ? number.unsignedIntegerValue : RadioStationOriginUnknown);
    RadioStationOrigin stationOrigin;
    switch (origin) {
        case RadioStationOriginCloud:
            origin = RadioStationOriginCloud;
            break;
        case RadioStationOriginUser:
            origin = RadioStationOriginUser;
            break;
        case RadioStationOriginFriend:
            origin = RadioStationOriginFriend;
            break;
        default:
            stationOrigin = RadioStationOriginUnknown;
            break;
    }
    return stationOrigin;
}

@end
