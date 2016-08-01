//
//  StationWindowController.m
//  MenuBarRadio
//
//  Created by Snorre Milde on 31/07/16.
//  Copyright © 2016 Snorre Milde. All rights reserved.
//

#import "StationWindowController.h"

@interface StationWindowController ()

@end

@implementation StationWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    NSLog(@"****** StationWindowController ******");

    //Force the window to front
    [NSApp activateIgnoringOtherApps:YES];
    
}

@end
