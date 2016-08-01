//
//  PrefsViewController.m
//  MenuBarRadio
//
//  Created by Snorre Milde on 31/07/16.
//  Copyright © 2016 Snorre Milde. All rights reserved.
//

#import "PrefsWindowController.h"

static NSString *const kSecond = @"second";
static NSString *const kSeconds = @"seconds";

@interface PrefsWindowController ()

@end

@implementation PrefsWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    NSLog(@"****** PrefsWindowController ******");
    
    //Force the window to front
    [NSApp activateIgnoringOtherApps:YES];
    
    self.bufferSizeInSeconds = (NSInteger) [[NSUserDefaults standardUserDefaults] valueForKey:@"bufferSizeInSeconds"];
    NSLog(@"bufferSizeInSeconds: %li", (NSInteger) self.bufferSizeInSeconds);
    
}

- (void)windowWillClose:(NSNotification *)notification {
    NSLog(@"Prefs window closing.");
    
    //Saving prefs
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (IBAction)handleBufferSlider:(id)sender {
    
    self.changeEffectLabel.hidden = NO;
    
    NSString *secondLabel = kSeconds;
    if (self.bufferSizeInSeconds == 1) {
        secondLabel = kSecond;
    }
    
    [self.bufferLabel setStringValue:[NSString stringWithFormat:@"%li %@", (long)self.bufferSizeInSeconds, secondLabel]];
    
    NSLog(@"bufferSizeInSeconds: %li", (long)self.bufferSizeInSeconds);

    [[NSUserDefaults standardUserDefaults] setInteger:self.bufferSizeInSeconds forKey:@"bufferSizeInSeconds"];
    
    //NSLog(@"hello %li", (long)self.bufferSizeInSeconds);
}

@end
