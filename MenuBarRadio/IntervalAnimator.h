//
//  IntervalAnimator.h
//  MenuBarRadio
//
//  Created by Anni S
//  http://stackoverflow.com/questions/6611912/how-to-add-animated-icon-to-os-x-status-bar

#import <Foundation/Foundation.h>

@protocol IntervalAnimatorDelegate <NSObject>

- (void)onUpdate;

@end


@interface IntervalAnimator : NSObject
{
    NSInteger numberOfFrames;
    NSInteger currentFrame;
    __unsafe_unretained id <IntervalAnimatorDelegate> delegate;
}

@property(assign) id <IntervalAnimatorDelegate> delegate;
@property (nonatomic) NSInteger numberOfFrames;
@property (nonatomic) NSInteger currentFrame;

- (void)startAnimating;
- (void)stopAnimating;
@end
