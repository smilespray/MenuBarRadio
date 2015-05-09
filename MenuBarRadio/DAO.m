//
//  DAO.m
//  MenuBarRadio
//
//  Created by Trygve Sanne Hardersen on 08/05/15.
//  Copyright (c) 2015 Snorre Milde. All rights reserved.
//

#import "DAO.h"

#import "Constants.h"

const NSUInteger kDAOFetchZero = 0;
const NSUInteger kDAOFetchOne = 1;

const NSUInteger kDAOFetchOneReturnMultipleErrorCode = 500;

@interface DAO ()

- (void)initalizeWithEntityName:(NSString *)entityName;

@end

@implementation DAO

@synthesize entityName = _entityName;

#pragma mark - DAO Lifecycle

- (instancetype)initWithEntityName:(NSString *)entityName
{
    if (!(self = [super init])) {
        return nil;
    }
    
    [self initalizeWithEntityName:entityName];
    
    return self;
}

- (instancetype)initWithEntityName:(NSString *)entityName
              managedObjectContect:(NSManagedObjectContext *)managedObjectContext
{
    if (!(self = [super initWithManagedObjectContext:managedObjectContext])) {
        return nil;
    }
    
    [self initalizeWithEntityName:entityName];
    
    return self;
}

- (void)initalizeWithEntityName:(NSString *)entityName
{
    _entityName = entityName;
}

#pragma mark - NSManagedObjectContext Lifecycle

- (BOOL)saveChanges:(NSError *__autoreleasing *)error
{
    BOOL saved = NO;
    NSError *err = nil;
    if (!(saved = [self.managedObjectContext save:&err])) {
        NSLog(@"Unable to save NSManagedObjectContext for %@ due to:\n%@", self.entityName, err);
    }
    if (error) {
        *error = err;
    }
    return saved;
}

- (void)rollbackChanges
{
    [self.managedObjectContext rollback];
}

#pragma mark - NSManagedObject Lifecycle

- (id)insertObject
{
    id object = [NSEntityDescription insertNewObjectForEntityForName:self.entityName
                                              inManagedObjectContext:self.managedObjectContext];
    return object;
}

- (void)deleteObject:(id)object
{
    [self.managedObjectContext deleteObject:object];
}

#pragma mark - NSManagedObject Fetching

- (id)fetchObject:(NSFetchRequest *)request
            error:(NSError *__autoreleasing *)error
{
    request.fetchLimit = kDAOFetchOne;
    
    NSError *err = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&err];
    if (error) {
        *error = err;
    }
    if (err) {
        NSLog(@"Unable to execute single object fetch request for %@ due to: %@",
              self.entityName, err);
        return nil;
    }
    if (!result || result.count == kDAOFetchZero) {
        return nil;
    }
    if (result.count != kDAOFetchOne) {
        NSString *errorString = [NSString stringWithFormat:@"Single object fetch request for %@ returned %lu objects",
                                 self.entityName, (unsigned long)result.count];
        NSLog(@"%@", errorString);
        if (error) {
            err = [NSError errorWithDomain:kMenuBarRadioErrorDomain
                                      code:kDAOFetchOneReturnMultipleErrorCode
                                  userInfo:@{kMenuBarRadioErrorKey: errorString}];
        }
        return nil;
    }
    return [result objectAtIndex:0];
}

- (NSArray *)fetchObjects:(NSFetchRequest *)request error:(NSError *__autoreleasing *)error
{
    NSError *err = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&err];
    if (error) {
        *error = err;
    }
    if (err) {
        NSLog(@"Unable to execute multi object fetch request for %@ due to: %@",
              self.entityName, err);
        return nil;
    }
    if (!result) {
        return [NSArray new];
    }
    return result;
}

#pragma mark - NSFetchRequest Helpers

- (NSFetchRequest *)fetchRequest
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName
                                              inManagedObjectContext:self.managedObjectContext];
    request.entity = entity;
    return request;
}

- (NSFetchRequest *)fetchRequestUsingPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *request = [self fetchRequest];
    request.predicate = predicate;
    return request;
}

- (NSFetchRequest *)fetchRequestUsingPredicate:(NSPredicate *)predicate
                                sortDescriptor:(NSSortDescriptor *)sortDescriptor
{
    NSFetchRequest *request = [self fetchRequestUsingPredicate:predicate];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    return request;
}

- (NSFetchRequest *)fetchRequestUsingSortDescriptor:(NSSortDescriptor *)sortDescriptor
{
    NSFetchRequest *request = [self fetchRequest];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    return request;
}

#pragma mark - Getters & Setters

- (NSString *)entityName
{
    if (!_entityName) {
        [NSException raise:NSInternalInconsistencyException format:@"EntityName not initialized"];
        return nil;
    }
    return _entityName;
}

@end
