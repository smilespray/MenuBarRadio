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

@interface AppDelegate () {
    STKAudioPlayer* audioPlayer;
    NSStatusItem *statusItem;
    NSWindowController *prefsWindowController;
    NSWindowController *stationsWindowsController;
}

- (void)syncRadioStations;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    // sync the radio stations
    //[self syncRadioStations];
    
    //Set up the station list
    _stationList = @[@"http://lyd.nrk.no/nrk_radio_p3_mp3_h",
                     @"http://lyd.nrk.no/nrk_radio_p13_mp3_h",
                     @"http://lyd.nrk.no/nrk_radio_mp3_mp3_h",
                     @"http://kcrw.ic.llnwd.net/stream/kcrw_music",
                     @"http://ice2.somafm.com/groovesalad-128-aac"];
    
    //Set up the status bar item
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    NSImage *statusImage = [NSImage imageNamed:@"MenuBarIcon"];
    statusImage.template = YES;
    [statusItem setImage:statusImage];
    [statusItem setHighlightMode:YES];
    
    //Set up the menu
    _menu = [[NSMenu alloc] init];
    [_menu addItemWithTitle:@"Play" action:@selector(startPlaying:) keyEquivalent:@""];
    [_menu addItemWithTitle:@"Stop" action:@selector(stopPlaying:) keyEquivalent:@""];
    [_menu addItem:[NSMenuItem separatorItem]];
    
    //List of stations (placeholder for now)
    [_menu addItemWithTitle:@"NRK P3" action:@selector(playNRKP3:) keyEquivalent:@""];
    [_menu addItemWithTitle:@"NRK P13" action:@selector(playNRKP13:) keyEquivalent:@""];
    [_menu addItemWithTitle:@"NRK mP3" action:@selector(playNRKMP3:) keyEquivalent:@""];
    [_menu addItemWithTitle:@"KCRW Music" action:@selector(playKCRW:) keyEquivalent:@""];
    [_menu addItemWithTitle:@"Soma FM Groove Salad" action:@selector(playSomaFM:) keyEquivalent:@""];
    
    //[_menu addItem:[NSMenuItem separatorItem]];
    //[_menu addItemWithTitle:@"Edit Station List…" action:@selector(showEditStations:) keyEquivalent:@""];
    //[_menu addItemWithTitle:@"Preferences…" action:@selector(showPrefs:) keyEquivalent:@""];
    
    [_menu addItem:[NSMenuItem separatorItem]];
    [_menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
    
    [statusItem setMenu:_menu];
    
    //Play icon
    NSMenuItem *playItem = [_menu itemAtIndex:0];
    NSImage *playImage = [NSImage imageNamed:@"play"];
    playImage.template = YES;
    [playItem setImage:playImage];

    //Stop icon
    NSMenuItem *stopItem = [_menu itemAtIndex:1];
    NSImage *stopImage = [NSImage imageNamed:@"stop"];
    stopImage.template = YES;
    [stopItem setImage:stopImage];
    
    //Set up player
    audioPlayer = [[STKAudioPlayer alloc] initWithOptions:(STKAudioPlayerOptions){
        .enableVolumeMixer = NO
    }];
    audioPlayer.delegate = self;
    audioPlayer.equalizerEnabled = NO;
    audioPlayer.meteringEnabled = NO;
    audioPlayer.volume = 1.0f;
    
    //retrieve last played station from prefs
    //TODO
    
    //If we were playing the last time we quit, start playing.
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"wasPlaying"]) {
        NSLog(@"*** Auto-starting stream on launch.");
        [self startPlaying:nil];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(void) updateMenu:(BOOL)wasPlaying forItem:(id)sender {

    NSInteger stationIndex = [_menu indexOfItem:sender];
    stationIndex = stationIndex - 3; //Change offset to remove play/stop/divider.
    if (stationIndex >= 0) {
        
        //Update menu checkmark
        [_currentMenuItem setState:NSOffState];
        [sender setState:NSOnState];

        //Save the currently playing station menu index
        [[NSUserDefaults standardUserDefaults] setInteger:stationIndex forKey:@"lastPlayingStation"];
    }
    
    //Save playback state
    [[NSUserDefaults standardUserDefaults] setBool:wasPlaying forKey:@"wasPlaying"];

    //Save the prefs to disk
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSLog(@"stationIndex: %ld", (long)stationIndex);
    
    _currentMenuItem = sender;
}


-(void) startPlaying:(id)sender {
    NSInteger stationIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"stationIndex"];
    stationIndex += 3;
    NSString *stationURLString = [_stationList objectAtIndex:stationIndex];
    NSURL *stationURL = [[NSURL alloc] initWithString:stationURLString];
    [audioPlayer playURL:stationURL];
    [self updateMenu:YES forItem:sender];
}


-(void) playNRKP3:(id)sender {
    //[currentItem setState:NSOffState];
    [self updateMenu:YES forItem:sender];
    [audioPlayer playURL:[[NSURL alloc] initWithString:[_stationList objectAtIndex:0]]];
}
-(void) playNRKP13:(id)sender {
    [self updateMenu:YES forItem:sender];
    [audioPlayer playURL:[[NSURL alloc] initWithString:[_stationList objectAtIndex:1]]];
}
-(void) playNRKMP3:(id)sender {
    [self updateMenu:YES forItem:sender];
    [audioPlayer playURL:[[NSURL alloc] initWithString:[_stationList objectAtIndex:2]]];
}
-(void) playKCRW:(id)sender {
    [self updateMenu:YES forItem:sender];
    [audioPlayer playURL:[[NSURL alloc] initWithString:[_stationList objectAtIndex:3]]];
}
-(void) playSomaFM:(id)sender {
    [self updateMenu:YES forItem:sender];
    [audioPlayer playURL:[[NSURL alloc] initWithString:[_stationList objectAtIndex:4]]];
}

-(void) switchStation:(id)sender {
    NSLog(@"switchStation called.");
    int stationIndex = 0;
    NSString *stationURLString = [_stationList objectAtIndex:stationIndex];
    NSURL *stationURL = [[NSURL alloc] initWithString:stationURLString];
    [audioPlayer playURL:stationURL];
    [self updateMenu:YES forItem:sender];
}

-(void) stopPlaying:(id)sender {
    NSLog(@"stopPlaying called.");
    [audioPlayer stop];
    //Remember playback state
    //[self rememberPlaybackState:NO forItem:nil];
}

-(void) showPrefs:(id)sender {
    NSLog(@"showPrefs");
    prefsWindowController = [[NSWindowController alloc] initWithWindowNibName:@"Prefs"];
    [prefsWindowController showWindow:self];
    //NSLog(@"*** DEFAULTS:\n %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
}

-(void) showEditStations:(id)sender {
    NSLog(@"showEditStations");
    stationsWindowsController = [[NSWindowController alloc] initWithWindowNibName:@"Stations"];
    [stationsWindowsController showWindow:self];
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer logInfo:(NSString*)line {
    NSLog(@"logInfo: %@", line);
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
