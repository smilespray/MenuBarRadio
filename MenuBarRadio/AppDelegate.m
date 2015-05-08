//
//  AppDelegate.m
//  Menu Bar Radio
//
//  Created by Snorre Milde on 07/05/15.
//  Copyright (c) 2015 Snorre Milde. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate () {
    STKAudioPlayer* audioPlayer;
    NSStatusItem *statusItem;
    NSWindowController *prefsWindowController;
    NSWindowController *stationsWindowsController;
}
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

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

@end
