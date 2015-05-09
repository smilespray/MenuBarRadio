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
    [self syncRadioStations];

    //Set up the status bar item
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setAlternateImage:[NSImage imageNamed:@"MenuBarIcon-highlighted"]];
    [statusItem setImage:[NSImage imageNamed:@"MenuBarIcon"]];
    [statusItem setHighlightMode:YES];
    
    //Set up the menu
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"Play" action:@selector(startPlaying) keyEquivalent:@""];
    [menu addItemWithTitle:@"Stop" action:@selector(stopPlaying) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    
    //List of stations (placeholder for now)
    [menu addItemWithTitle:@"NRK P3" action:@selector(nilSymbol) keyEquivalent:@""];
    [menu addItemWithTitle:@"NRK P13" action:@selector(nilSymbol) keyEquivalent:@""];
    [menu addItemWithTitle:@"NRK mP3" action:@selector(nilSymbol) keyEquivalent:@""];
    [menu addItemWithTitle:@"KCRW Music" action:@selector(nilSymbol) keyEquivalent:@""];
    
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"Edit Station List…" action:@selector(showEditStations) keyEquivalent:@""];
    [menu addItemWithTitle:@"Preferences…" action:@selector(showPrefs) keyEquivalent:@""];
    
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
    
    [statusItem setMenu:menu];
    
    audioPlayer = [[STKAudioPlayer alloc] initWithOptions:(STKAudioPlayerOptions){
        .enableVolumeMixer = NO
    } ];
    
    audioPlayer.delegate = self;
    audioPlayer.equalizerEnabled = NO;
    audioPlayer.meteringEnabled = NO;
    audioPlayer.volume = 1.0f;
    
    //retrieve last played station from prefs
    //TODO
    
    //If we were playing the last time we quit, start playing.
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"wasPlaying"]) {
        NSLog(@"Auto-starting stream on launch.");
        [self startPlaying];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(void) startPlaying {
    /*
     *** NRK Icecast sample playlists MP3 @ 192 kbit/s
     P3: http://lyd.nrk.no/nrk_radio_p3_mp3_h
     P13: http://lyd.nrk.no/nrk_radio_p13_mp3_h
     mP3: http://lyd.nrk.no/nrk_radio_mp3_mp3_h
     *** NRK Icecast sample streams AAC @ 128kbit/s
     http://lyd.nrk.no/nrk_radio_mp3_aac_h
     http://lyd.nrk.no/nrk_radio_p13_aac_h
     *** KCRW Eclectic24
     http://newmedia.kcrw.com/legacy/pls/kcrwmusic.pls //oops this doesn't work, I have to find or write a PLS parser! What about M3U?
     http://kcrw.ic.llnwd.net/stream/kcrw_music // <-- this is the actual stream
     
     *** Groove Salad
     http://somafm.com/groovesalad.pls

     Here is the Groove Salad PLS dumped with curl:

     [playlist]
     numberofentries=5
     File1=http://uwstream1.somafm.com:80
     Title1=SomaFM: Groove Salad (#1 128k mp3): A nicely chilled plate of ambient/downtempo beats and grooves.
     Length1=-1
     File2=http://xstream1.somafm.com:8032
     Title2=SomaFM: Groove Salad (#2 128k mp3): A nicely chilled plate of ambient/downtempo beats and grooves.
     Length2=-1
     File3=http://uwstream2.somafm.com:8032
     Title3=SomaFM: Groove Salad (#3 128k mp3): A nicely chilled plate of ambient/downtempo beats and grooves.
     Length3=-1
     File4=http://uwstream3.somafm.com:8032
     Title4=SomaFM: Groove Salad (#4 128k mp3): A nicely chilled plate of ambient/downtempo beats and grooves.
     Length4=-1
     File5=http://ice.somafm.com/groovesalad
     Title5=SomaFM: Groove Salad (Firewall-friendly 128k mp3) A nicely chilled plate of ambient/downtempo beats and grooves.
     Length5=-1
     Version=2
     
     */
    
    [audioPlayer play:@"http://kcrw.ic.llnwd.net/stream/kcrw_music"];
    NSLog(@"startPlaying");
    
    //Remember playback state
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"wasPlaying"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) stopPlaying {
    NSLog(@"stopPlaying called.");
    [audioPlayer stop];
    //Remember playback state
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"wasPlaying"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) showPrefs {
    NSLog(@"showPrefs");
    prefsWindowController = [[NSWindowController alloc] initWithWindowNibName:@"Prefs"];
    [prefsWindowController showWindow:self];
    //NSLog(@"*** DEFAULTS:\n %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
}

-(void) showEditStations {
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
