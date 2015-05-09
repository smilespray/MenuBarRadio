//
//  RadioStationDAO.m
//  MenuBarRadio
//
//  Created by Trygve Sanne Hardersen on 08/05/15.
//  Copyright (c) 2015 Snorre Milde. All rights reserved.
//

#import "RadioStationDAO.h"

NSString *kRadioStationEntityName = @"RadioStation";
NSString *kRadioStationPropertyName = @"name";
NSString *kRadioStationPropertyURL = @"url";
NSString *kRadioStationPropertyPlaying = @"playing";

@implementation RadioStationDAO

#pragma mark - RadioStationDAO Lifecycle

- (instancetype)init
{
    if (!(self = [super initWithEntityName:kRadioStationEntityName])) {
        return nil;
    }
    return self;
}

- (instancetype)initWithManagedObjectContect:(NSManagedObjectContext *)managedObjectContext
{
    if (!(self = [super initWithEntityName:kRadioStationEntityName
                      managedObjectContect:managedObjectContext])) {
        return nil;
    }
    return self;
}

#pragma mark - RadioStationDAO Fetching

- (RadioStation *)fetchByName:(NSString *)name
                       origin:(RadioStationOrigin)origin
                        error:(NSError *__autoreleasing *)error
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@ AND origin = %@",
                              name,
                              [NSNumber numberWithUnsignedInteger:origin]];
    NSFetchRequest *fetchRequest = [self fetchRequestUsingPredicate:predicate];
    return [self fetchObject:fetchRequest error:error];
}

- (NSArray *)fetchByDifferentSyncUUID:(NSString *)syncUUID
                               origin:(RadioStationOrigin)origin
                                error:(NSError *__autoreleasing *)error
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"syncUUID != %@ AND origin = %@",
                              syncUUID,
                              [NSNumber numberWithUnsignedInteger:origin]];
    NSFetchRequest *fetchRequest = [self fetchRequestUsingPredicate:predicate];
    return [self fetchObjects:fetchRequest error:error];
}

- (NSArray *)fetchSortedByName:(NSError *__autoreleasing *)error
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kRadioStationPropertyName
                                                                     ascending:YES];
    NSFetchRequest *fetchRequest = [self fetchRequestUsingSortDescriptor:sortDescriptor];
    return [self fetchObjects:fetchRequest error:error];
}

@end
