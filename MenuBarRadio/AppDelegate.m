//
//  AppDelegate.m
//  Menu Bar Radio
//
//  Created by Snorre Milde on 07/05/15.
//  Copyright (c) 2015 Snorre Milde. All rights reserved.
//

#import "AppDelegate.h"

#import "Constants.h"
#import "RadioStationService.h"

static const NSInteger kMenuPlay = -1;
static const NSInteger kMenuStop = -2;
static const NSInteger kMenuNowPlaying = -3;

static const NSInteger kStationName = 0;
static const NSInteger kStationURL = 1;

NSString *const kPrefsWasPlaying = @"wasPlaying";
NSString *const kPrefsStationID = @"stationID";

@interface AppDelegate () {
    STKAudioPlayer *audioPlayer;
    NSStatusItem *statusItem;
    NSWindowController *prefsWindowController;
    NSWindowController *stationsWindowsController;
}

@property (strong, nonatomic) NSMenu *menu;
@property (strong, nonatomic) NSArray *stationList;
@property (weak, nonatomic) NSMenuItem *currentStationMenuItem;

- (void)syncRadioStations;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    // sync the radio stations
    //[self syncRadioStations];
    
    //Set up the station list
    self.stationList = @[
        @[@"dummy",                     @"dummy"],
        @[@"NRK P3",                    @"http://lyd.nrk.no/nrk_radio_p3_mp3_h"],
        @[@"NRK P13",                   @"http://lyd.nrk.no/nrk_radio_p13_mp3_h"],
        @[@"NRK MP13",                  @"http://lyd.nrk.no/nrk_radio_mp3_mp3_h"],
        @[@"KCRW Music",                @"http://kcrw.streamguys1.com/kcrw_128k_aac_e24_itunes"],
        @[@"SomaFM Groove Salad",       @"http://ice2.somafm.com/groovesalad-128-aac"],
        @[@"SomaFM Fluid",              @"http://ice1.somafm.com/fluid-128-aac"],
        @[@"SomaFM Secret Agent",       @"http://ice1.somafm.com/secretagent-128-aac"],
        @[@"SomaFM Deep Space One",     @"http://ice1.somafm.com/deepspaceone-128-aac"],
        @[@"SomaFM Drone Zone",         @"http://ice1.somafm.com/dronezone-128-aac"],
        @[@"SomaFM DEF CON Radio",      @"http://ice2.somafm.com/defcon-32-aac"],
        @[@"SomaFM Left Coast 70s",     @"http://ice1.somafm.com/seventies-128-aac"],
        @[@"SomaFM Underground 80s",    @"http://ice1.somafm.com/u80s-256-mp3"],
        @[@"SomaFM Lush",               @"http://ice1.somafm.com/lush-128-aac"],
    ];
    
    //Set up the status bar item
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    NSImage *statusImage = [NSImage imageNamed:@"MenuBarIcon"];
    statusImage.template = YES;
    [statusItem setImage:statusImage];
    [statusItem setHighlightMode:YES];
    
    //Set up the menu
    NSMenuItem *item;
    self.menu = [[NSMenu alloc] init];

    item = [self.menu addItemWithTitle:@"Play" action:@selector(handlePlay:) keyEquivalent:@""];
    [item setTag:kMenuPlay];

    item = [self.menu addItemWithTitle:@"Stop" action:@selector(handleStop:) keyEquivalent:@""];
    [item setTag:kMenuStop];

    [self.menu addItem:[NSMenuItem separatorItem]];
    
    item = [self.menu addItemWithTitle:@"Now Playing: -" action:nil keyEquivalent:@""]; //Metadata menu item
    [item setTag:kMenuNowPlaying];

    [self.menu addItem:[NSMenuItem separatorItem]];
    
    //Generate menu items for station list
    NSInteger index = 0;
    
    for (NSArray *station in self.stationList) {
        if (index > 0) { //Ignore the first element
            item = [self.menu addItemWithTitle:station[kStationName] action:@selector(playStation:) keyEquivalent:@""];
            [item setTag:index];
        }
        index ++;
    }

    //[self.menu addItem:[NSMenuItem separatorItem]];
    //[self.menu addItemWithTitle:@"Edit Station List…" action:@selector(showEditStations:) keyEquivalent:@""];
    //[self.menu addItemWithTitle:@"Preferences…" action:@selector(showPrefs:) keyEquivalent:@""];
    
    [self.menu addItem:[NSMenuItem separatorItem]];
    [self.menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
    
    [statusItem setMenu:self.menu];
    
    //Reference to currently playing station menu item
    self.currentStationMenuItem = nil;
    
    //Play icon
    NSMenuItem *playItem = [self.menu itemAtIndex:0];
    NSImage *playImage = [NSImage imageNamed:@"play"];
    playImage.template = YES;
    [playItem setImage:playImage];

    //Stop icon
    NSMenuItem *stopItem = [self.menu itemAtIndex:1];
    NSImage *stopImage = [NSImage imageNamed:@"stop"];
    stopImage.template = YES;
    [stopItem setImage:stopImage];
    
    //Store reference to ID3 metadata menu item
    [self updateNowPlaying:@"-"];

    //Set up player
    audioPlayer = [[STKAudioPlayer alloc] initWithOptions:(STKAudioPlayerOptions){
        .enableVolumeMixer = NO
    }];
    audioPlayer.delegate = self;
    audioPlayer.equalizerEnabled = NO;
    audioPlayer.meteringEnabled = NO;
    audioPlayer.volume = 1.0f;

    //Dump the preferences
    //NSLog(@"*** DEFAULTS:\n %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);

    //If we were playing the last time we quit, start playing.
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kPrefsWasPlaying]) {
        NSLog(@"*** Auto-starting stream on launch.");
        
        //Locate the station and menu item
        NSInteger stationID = [[NSUserDefaults standardUserDefaults] integerForKey:kPrefsStationID];
        NSMenuItem *station = [self.menu itemWithTag:stationID];

        //Start playing
        [self handlePlay:station];
    }
}


-(void) handlePlay:(id)sender {
    
    NSMenuItem *item = sender;
    NSInteger stationID = [[NSUserDefaults standardUserDefaults] integerForKey:kPrefsStationID];

    if (item) { //We're called from the menu item

        if (self.currentStationMenuItem) {
            item = self.currentStationMenuItem;
        } else {
            item = [self.menu itemWithTag:stationID];
        }
        [self playStation:item];
    
    } else { //Figure out what station to play
        item = [self.menu itemWithTag:stationID];
        self.currentStationMenuItem = item;
    }
    
    [self playStation:item];
}

-(void) handleStop:(id)sender {
    NSLog(@"*** stopPlaying.");
    
    //Stop playing
    [audioPlayer stop];

    //Clear meta data display
    [self updateNowPlaying:@"-"];
    
    //Clear menu checkmark
    if (self.currentStationMenuItem) {
        [self.currentStationMenuItem setState:NSOffState];
    }
    
    //Remember playback state for later
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kPrefsWasPlaying];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

-(void) playStation:(id)sender {
    
    if (sender) {
        
        //Clear meta data display
        [self updateNowPlaying:@"-"];

        //Change the menu checkmark
        [self.currentStationMenuItem setState:NSOffState];
        [sender setState:NSOnState];
        
        //Remember currently playing station for next station switch
        self.currentStationMenuItem = sender;

        //Get the station ID
        NSInteger stationID = [sender tag];
        
        //Look up the URL
        NSString *stationURLString = [self.stationList[stationID] objectAtIndex:kStationURL];
        NSURL *stationURL = [[NSURL alloc] initWithString:stationURLString];

        //Start playing
        [audioPlayer playURL:stationURL];
        
        //Save prefs for station ID and playback boolean state
        [[NSUserDefaults standardUserDefaults] setInteger:stationID forKey:kPrefsStationID];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPrefsWasPlaying];
        [[NSUserDefaults standardUserDefaults] synchronize];

        NSLog(@"*** playStation: Started playing %@", [self.stationList[stationID] objectAtIndex:kStationName]);
    
    } else {
        NSLog(@"*** playStation: Unidentified menu item.");
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(void) showPrefs:(id)sender {
    NSLog(@"showPrefs");
    prefsWindowController = [[NSWindowController alloc] initWithWindowNibName:@"Prefs"];
    [prefsWindowController showWindow:self];
}

-(void) showEditStations:(id)sender {
    NSLog(@"showEditStations");
    stationsWindowsController = [[NSWindowController alloc] initWithWindowNibName:@"Stations"];
    [stationsWindowsController showWindow:self];
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer logInfo:(NSString*)line {
    NSLog(@"logInfo: %@", line);
}

-(void)audioPlayer:(STKAudioPlayer *)audioPlayer didReadStreamMetadata:(NSDictionary *)dictionary {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateNowPlaying:dictionary[@"StreamTitle"]];
    });
}

-(void)updateNowPlaying:(NSString*)metaData {
    [[self.menu itemWithTag:kMenuNowPlaying] setTitle:[NSString stringWithFormat:@"Now Playing: %@", metaData]];
    [statusItem setToolTip:metaData];
    NSLog(@"%@", metaData);
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId {
    //NSLog(@"*** didStartPlayingQueueItemId");
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId {
    //NSLog(@"*** didFinishBufferingSourceWithQueueItemId");
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState {
    //Handle state changes, update the menu etc?
    //NSLog(@"*** stateChanged");
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration {
    //NSLog(@"*** didFinishPlayingQueueItemId");
    
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode {
    NSLog(@"*** unexpectedError!");
}

#pragma mark - Radio Stations

- (void)syncRadioStations
{
    __weak __typeof__(self) weakSelf = self;
    [[RadioStationService defaultService] syncRadioStations:^(BOOL ok, NSError *error) {
        [weakSelf performSelector:@selector(syncRadioStations)
                       withObject:nil
                       afterDelay:kRadioStationsFeedSyncInterval];
    }];
}

#pragma mark - Core Data stack

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file.
    // This code uses a directory named "net.hardersen.CoreDataTest" in the
    // user's Application Support directory.
    NSURL *appSupportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory
                                                                   inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.snorremilde.MenuBarRadio"];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application.
    // It is a fatal error for the application not to be able to
    // find and load its model.
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MenuBarRadio" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
#warning this needs to handle app store distribution, automatic schema updates and db maintenance
    
    // The persistent store coordinator for the application.
    // This implementation creates and return a coordinator,
    // having added the store for the application to it.
    // (The directory for the store is created, if necessary.)
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationDocumentsDirectory = [self applicationDocumentsDirectory];
    BOOL shouldFail = NO;
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    // Make sure the application files directory is there
    NSDictionary *properties = [applicationDocumentsDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey]
                                                                              error:&error];
    if (properties) {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            failureReason = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).",
                             [applicationDocumentsDirectory path]];
            shouldFail = YES;
        }
    } else if ([error code] == NSFileReadNoSuchFileError) {
        error = nil;
        [fileManager createDirectoryAtPath:[applicationDocumentsDirectory path]
               withIntermediateDirectories:YES attributes:nil
                                     error:&error];
    }
    
    if (!shouldFail && !error) {
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        NSURL *url = [applicationDocumentsDirectory URLByAppendingPathComponent:@"MenuBarRadio.storedata"];
        if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
            coordinator = nil;
        }
        _persistentStoreCoordinator = coordinator;
    }
    
    if (shouldFail || error) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        if (error) {
            dict[NSUnderlyingErrorKey] = error;
        }
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application
    // (which is already bound to the persistent store coordinator for the application.)
    // This can only be accessed on the application's main thread
    if ([NSThread currentThread] != [NSThread mainThread]) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Attempt to access AppDelegate's NSManagedObjectContext on other than main thread"];
        return nil;
    }
    
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedObjectContext;
}

#pragma mark - Core Data Saving and Undo support

- (IBAction)saveAction:(id)sender {
    // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    NSError *error = nil;
    if ([[self managedObjectContext] hasChanges] && ![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
    return [[self managedObjectContext] undoManager];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(syncRadioStations) object:nil];
    
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        
        // Customize this code block to include application-specific recovery steps.
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }
        
        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertFirstButtonReturn) {
            return NSTerminateCancel;
        }
    }
    
    return NSTerminateNow;
}

@end
