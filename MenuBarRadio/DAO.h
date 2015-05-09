//
//  DAO.h
//  MenuBarRadio
//
//  Created by Trygve Sanne Hardersen on 08/05/15.
//  Copyright (c) 2015 Snorre Milde. All rights reserved.
//

#import "ManagedObjectContextObject.h"

extern const NSUInteger kDAOFetchZero;
extern const NSUInteger kDAOFetchOne;

extern const NSUInteger kDAOFetchOneReturnMultipleErrorCode;

@interface DAO : ManagedObjectContextObject

@property (readonly, strong, nonatomic) NSString *entityName;

#pragma mark - DAO Lifecycle

- (instancetype)initWithEntityName:(NSString *)entityName;
- (instancetype)initWithEntityName:(NSString *)entityName
              managedObjectContect:(NSManagedObjectContext *)managedObjectContext;

#pragma mark - NSManagedObjectContext Lifecycle

- (BOOL)saveChanges:(NSError **)error;
- (void)rollbackChanges;

#pragma mark - NSManagedObject Lifecycle

- (id)insertObject;
- (void)deleteObject:(id)object;

#pragma mark - NSManagedObject Fetching

- (id)fetchObject:(NSFetchRequest *)request error:(NSError **)error;
- (NSArray *)fetchObjects:(NSFetchRequest *)request error:(NSError **)error;

#pragma mark - NSFetchRequest Helpers

- (NSFetchRequest *)fetchRequest;
- (NSFetchRequest *)fetchRequestUsingPredicate:(NSPredicate *)predicate;
- (NSFetchRequest *)fetchRequestUsingPredicate:(NSPredicate *)predicate
                                sortDescriptor:(NSSortDescriptor *)sortDescriptor;
- (NSFetchRequest *)fetchRequestUsingSortDescriptor:(NSSortDescriptor *)sortDescriptor;

@end
