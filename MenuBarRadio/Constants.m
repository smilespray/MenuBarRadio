//
//  Constants.m
//  MenuBarRadio
//
//  Created by Trygve Sanne Hardersen on 08/05/15.
//  Copyright (c) 2015 Snorre Milde. All rights reserved.
//

#import "Constants.h"

#pragma mark - Radio Stations Feed

const NSTimeInterval kRadioStationsFeedSyncInterval = 60.0f;
NSString *kRadioStationsFeedURL = @"http://menubarradio.hypobytes.com/feed.json";
const NSTimeInterval kRadioStationsFeedTimeout = 30.0f;

#pragma mark - Internal Error Codes

NSString *kMenuBarRadioErrorDomain = @"com.snorremilde.MenuBarRadio";
NSString *kMenuBarRadioErrorKey = @"description";

#pragma mark - HTTP Status Codes

const NSUInteger kHTTPStatusCodeOK = 200;
const NSUInteger kHTTPStatusCodeNoContent = 204;

@implementation Constants

+ (NSString *)createUUID
{
    NSUUID *uuid = [NSUUID UUID];
    return [uuid UUIDString];
}


@end