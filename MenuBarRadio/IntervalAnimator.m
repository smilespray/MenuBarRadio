//
//  IntervalAnimator.m
//  MenuBarRadio
//
//  Created by Anni S
//  http://stackoverflow.com/questions/6611912/how-to-add-animated-icon-to-os-x-status-bar

#import "IntervalAnimator.h"

@interface IntervalAnimator()
{
    NSTimer* animTimer;
}

@end

@implementation IntervalAnimator
@synthesize numberOfFrames;
@synthesize delegate;
@synthesize currentFrame;

- (void)startAnimating
{
    currentFrame = -1;
    animTimer = [NSTimer scheduledTimerWithTimeInterval:0.50 target:delegate selector:@selector(onUpdate) userInfo:nil repeats:YES];
}

- (void)stopAnimating
{
    [animTimer invalidate];
}

@end