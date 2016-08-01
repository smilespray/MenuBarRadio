//
//  PrefsViewController.h
//  MenuBarRadio
//
//  Created by Snorre Milde on 31/07/16.
//  Copyright © 2016 Snorre Milde. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PrefsWindowController : NSWindowController

@property (weak, nonatomic) IBOutlet NSSlider *bufferSlider;
@property NSInteger bufferSizeInSeconds;


@property (weak) IBOutlet NSTextField *bufferLabel;
@property (weak) IBOutlet NSTextField *changeEffectLabel;


@end
