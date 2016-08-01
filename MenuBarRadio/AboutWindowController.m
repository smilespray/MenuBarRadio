//
//  AboutWindowController.m
//  MenuBarRadio
//
//  Created by Snorre Milde on 31/07/16.
//  Copyright © 2016 Snorre Milde. All rights reserved.
//

#import "AboutWindowController.h"
//#import "AppDelegate.h"

static NSString *const kListeningLabel = @"Seconds spent listening to the radio:";


@interface AboutWindowController ()

@end

@implementation AboutWindowController


-(void) updateTotalListeningMinutesLabel {

    AppDelegate *appDelegate = myAppDelegate;
    int timeOnStation = [appDelegate.audioPlayer progress];

    NSUInteger hh = timeOnStation / 3600;
    NSUInteger mm = (timeOnStation / 60) % 60;
    NSUInteger ss = timeOnStation % 60;
    NSString *formattedTime = [NSString stringWithFormat:@"%02ldh %02ldm %02lds", (long)hh, (long)mm, (long)ss];
    self.timeOnStationLabel.stringValue = formattedTime;
    
    //TODO: Add up all time and persist to user defaults etc
    self.totalTimeListenedLabel.stringValue = formattedTime;
    
    NSString *stationSwitchCountLabel = [NSString stringWithFormat:@"%lu", (unsigned long)appDelegate.stationSwitchCount];
    self.stationChangesLabel.stringValue = stationSwitchCountLabel;
    
}

- (void)windowDidLoad {
    [super windowDidLoad];

    //Force the window to front
    [NSApp activateIgnoringOtherApps:YES];

    [self updateTotalListeningMinutesLabel];
    
    self.totalPlayedTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                         target:self
                                                       selector:@selector(updateTotalListeningMinutesLabel)
                                                       userInfo:nil
                                                        repeats:YES];
}

- (void)windowWillClose:(NSNotification *)notification {
    NSLog(@"About window closing.");
    [self.totalPlayedTimer invalidate];
    self.totalPlayedTimer = nil;
}

- (IBAction)launchSupportWebSite:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://googleapps.com/"]];
}

@end
