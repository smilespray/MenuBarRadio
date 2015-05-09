//
//  StoreSettings.h
//  MenuBarRadio
//
//  Created by Trygve Sanne Hardersen on 09/05/15.
//  Copyright (c) 2015 Snorre Milde. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface StoreSettings : NSManagedObject

@property (nonatomic, retain) NSNumber * radioStationsVersion;

@end
