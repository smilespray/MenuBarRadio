//
//  AboutWindowController.h
//  MenuBarRadio
//
//  Created by Snorre Milde on 31/07/16.
//  Copyright © 2016 Snorre Milde. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AboutWindowController : NSWindowController

@property (weak) IBOutlet NSTextField *totalTimeListenedLabel;

@property (weak) IBOutlet NSTextField *timeOnStationLabel;

@property (weak) IBOutlet NSTextField *stationChangesLabel;
@property (strong, atomic) NSTimer *totalPlayedTimer;

@end
