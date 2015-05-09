//
//  Constants.h
//  MenuBarRadio
//
//  Created by Trygve Sanne Hardersen on 08/05/15.
//  Copyright (c) 2015 Snorre Milde. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Radio Stations Feed

extern const NSTimeInterval kRadioStationsFeedSyncInterval;
OBJC_EXPORT NSString *kRadioStationsFeedURL;
extern const NSTimeInterval kRadioStationsFeedTimeout;

#pragma mark - Internal Error Codes

OBJC_EXPORT NSString *kMenuBarRadioErrorDomain;
OBJC_EXPORT NSString *kMenuBarRadioErrorKey;

#pragma mark - HTTP Status Codes

extern const NSUInteger kHTTPStatusCodeOK;
extern const NSUInteger kHTTPStatusCodeNoContent;

@interface Constants : NSObject

+ (NSString *)createUUID;

@end
