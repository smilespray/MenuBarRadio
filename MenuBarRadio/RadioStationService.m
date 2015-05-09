//
//  RadioStationService.m
//  MenuBarRadio
//
//  Created by Trygve Sanne Hardersen on 08/05/15.
//  Copyright (c) 2015 Snorre Milde. All rights reserved.
//

#import "RadioStationService.h"

#import "Constants.h"
#import "RadioStationDAO.h"
#import "StoreSettingsDAO.h"

NSString *kRadioStationServiceVersionKey = @"version";
NSString *kRadioStationServiceRegionsKey = @"regions";
NSString *kRadioStationServiceRegionCodeKey = @"code";
NSString *kRadioStationServiceRegionNameKey = @"name";
NSString *kRadioStationServiceRegionStationsKey = @"stations";
NSString *kRadioStationServiceStationNameKey = @"name";
NSString *kRadioStationServiceStationURLKey = @"url";

@interface RadioStationService ()

@property (readonly, strong, nonatomic) RadioStationDAO *radioStationDAO;
@property (readonly, strong, nonatomic) StoreSettingsDAO *storeSettingsDAO;

@end

@implementation RadioStationService

@synthesize radioStationDAO = _radioStationDAO;
@synthesize storeSettingsDAO = _storeSettingsDAO;

+ (instancetype)defaultService
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[RadioStationService alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if (!(self = [super init])) {
        return nil;
    }
    
    return self;
}

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    if (!(self = [super initWithManagedObjectContext:managedObjectContext])) {
        return nil;
    }
    
    return self;
}

- (void)syncRadioStations:(void (^)(BOOL, NSError *))completion
{
    void(^finito)(NSUInteger, NSUInteger, NSUInteger) = ^(NSUInteger inserted, NSUInteger updated, NSUInteger deleted) {
        if (inserted == 0 && updated == 0 && deleted == 0) {
            NSLog(@"Successfully sync radio stations feed, no need to update local database");
            if (completion) {
                completion(YES, nil);
            }
            return;
        }
        NSError *err = nil;
        if ([self.radioStationDAO saveChanges:&err]) {
            if (completion) {
                completion(YES, nil);
            }
            NSLog(@"Successfully sync radio stations feed, inserted %lu, updated %lu and deleted %lu stations",
                  (unsigned long)inserted,
                  (unsigned long)updated,
                  (unsigned long)deleted);
        } else {
            [self.radioStationDAO rollbackChanges];
            if (completion) {
                completion(NO, err);
            }
        }
    };
    
    void (^res)(NSURLResponse *, NSData *, NSError *)= ^(NSURLResponse *response, NSData *data, NSError *error){
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        BOOL ok = NO;
        
        // check the response
        if (error) {
            NSLog(@"Unable to sync radio stations feed from %@ due to:\n%@",
                  kRadioStationsFeedURL, error);
            if (completion) {
                completion(NO, error);
            }
        } else if (httpResponse.statusCode != kHTTPStatusCodeOK) {
            NSString *msg = [NSString stringWithFormat:@"Unable to sync radio stations feed from %@ \
                             (response code %li - %@)",
                kRadioStationsFeedURL,
                (long)httpResponse.statusCode,
                             [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]];
            NSLog(@"%@", msg);
            if (completion) {
                NSError *err = [NSError errorWithDomain:kMenuBarRadioErrorDomain
                                                   code:httpResponse.statusCode
                                               userInfo:@{kMenuBarRadioErrorKey: msg}];
                completion(NO, err);
            }
        } else if (data.length == 0) {
            NSString *msg = [NSString stringWithFormat:@"Unable to sync radio stations feed from %@ \
                             (server returned no data)",
                             kRadioStationsFeedURL];
            NSLog(@"%@", msg);
            if (completion) {
                NSError *err = [NSError errorWithDomain:kMenuBarRadioErrorDomain
                                                   code:kHTTPStatusCodeNoContent
                                               userInfo:@{kMenuBarRadioErrorKey: msg}];
                completion(NO, err);
            }
        } else {
            ok = YES;
        }
        
        // did we get some presumably valid data?
        if (!ok) {
            return;
        }
        
        NSError *err = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        
        if (err || !json) {
            NSLog(@"Unable to parse radio stations feed from %@ due to:\n%@",
                  kRadioStationsFeedURL, err);
            if (completion) {
                completion(NO, err);
            }
            return;
        }
        
        NSUInteger inserted = 0, updated = 0, deleted = 0;
        
        // if there are no regions we skip the sync
        NSArray *regions = [json objectForKey:kRadioStationServiceRegionsKey];
        if (!regions || regions.count == 0) {
            finito(inserted, updated, deleted);
            return;
        }
        
        // check version and skip sync if not changed
        NSNumber *version = [json objectForKey:kRadioStationServiceVersionKey];
        if (!version) {
            finito(inserted, updated, deleted);
            return;
        }
        StoreSettings *storeSettings = [self.storeSettingsDAO fetchStoreSettings:nil];
        if (!storeSettings) {
            storeSettings = [self.storeSettingsDAO insertObject];
        }
        
        if (storeSettings.radioStationsVersion && storeSettings.radioStationsVersion.unsignedIntegerValue == version.unsignedIntegerValue) {
            finito(inserted, updated, deleted);
            return;
        }
        
        storeSettings.radioStationsVersion = version;
        
        // create an UUID to keep track of deleted stations
        NSString *syncUUID = [Constants createUUID];
        
        // now insert all stations
        for (NSDictionary *region in regions) {
            NSArray *stations = [region objectForKey:kRadioStationServiceRegionStationsKey];
            if (!stations || stations.count == 0) {
                continue;
            }
            for (NSDictionary *station in stations) {
                NSString *name = [station objectForKey:kRadioStationServiceStationNameKey];
                NSString *urlString = [station objectForKey:kRadioStationServiceStationURLKey];
                NSURL *url = [NSURL URLWithString:urlString];
                if (!name || !url) {
                    continue;
                }
                
                RadioStation *radioStation = [self.radioStationDAO fetchByName:name
                                                                        origin:RadioStationOriginCloud
                                                                         error:nil];
                if (!radioStation) {
                    radioStation = [self.radioStationDAO insertObject];
                    radioStation.name = name;
                    radioStation.url = urlString;
                    radioStation.stationOrigin = RadioStationOriginCloud;
                    inserted++;
                } else {
                    if (![radioStation.url isEqualToString:urlString]) {
                        radioStation.url = urlString;
                        updated++;
                    }
                }
                
                radioStation.syncUUID = syncUUID;
            }
        }
        
        // remove all deleted stations
        NSArray *deletedStations = [self.radioStationDAO fetchByDifferentSyncUUID:syncUUID
                                                                           origin:RadioStationOriginCloud
                                                                            error:nil];
        if (!deletedStations || deletedStations.count == 0) {
            finito(inserted, updated, deleted);
            return;
        }
        
        for (RadioStation *radioStation in deletedStations) {
            [self.radioStationDAO deleteObject:radioStation];
            deleted++;
        }
        
        finito(inserted, updated, deleted);
    };
    
    NSLog(@"Syncing radio stations feed from %@", kRadioStationsFeedURL);
    
    NSURL *url = [NSURL URLWithString:kRadioStationsFeedURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:kRadioStationsFeedTimeout];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:res];
}

#pragma mark - Getters & Setters

- (RadioStationDAO *)radioStationDAO
{
    if (_radioStationDAO) {
        return _radioStationDAO;
    }
    
    _radioStationDAO = [[RadioStationDAO alloc] initWithManagedObjectContect:self.managedObjectContext];
    return _radioStationDAO;
}

- (StoreSettingsDAO *)storeSettingsDAO
{
    if (_storeSettingsDAO) {
        return _storeSettingsDAO;
    }
    
    _storeSettingsDAO = [[StoreSettingsDAO alloc] initWithManagedObjectContect:self.managedObjectContext];
    return _storeSettingsDAO;
}

@end
