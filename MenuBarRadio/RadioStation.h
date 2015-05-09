//
//  RadioStation.h
//  MenuBarRadio
//
//  Created by Trygve Sanne Hardersen on 09/05/15.
//  Copyright (c) 2015 Snorre Milde. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RadioStation : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * playing;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * origin;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSString * syncUUID;

@end
