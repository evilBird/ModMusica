//
//  ViewController+Touch.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/9/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ViewController+Touch.h"
#import "PdBase.h"

@implementation ViewController (Touch)

static NSDate   *kStartDate;
static NSTimer  *kPressTimer;
static NSDate   *kLastTap;
static NSInteger kTapCount;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    kStartDate = [NSDate date];
    kPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.35
                                                   target:self
                                                 selector:@selector(handlePress)
                                                 userInfo:nil
                                                  repeats:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (kStartDate!=nil) {
        [self handleTap];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (kStartDate!=nil) {
        [self handleTap];
    }
}

- (void)handleTap
{
    NSDate *now = [NSDate date];
    NSTimeInterval touchDuration = [now timeIntervalSinceDate:kStartDate];
    [kPressTimer invalidate];
    NSLog(@"\ntap lasted %@ seconds\n",@(touchDuration));
    
    NSTimeInterval timeSinceLastTap = 0;
    if (kLastTap!=nil) {
        timeSinceLastTap = [now timeIntervalSinceDate:kLastTap];
    }
    
    if (timeSinceLastTap > 4.0) {
        kTapCount = 0;
    }else{
        kTapCount++;
    }
    
    if (kTapCount > 1) {
        [PdBase sendBangToReceiver:@"tapTempo"];
    }else if (kTapCount == 1){
        [self showDetails];
    }
    
    kLastTap = [NSDate date];
    kPressTimer = nil;
    kStartDate = nil;
}

- (void)handlePress
{
    NSTimeInterval touchDuration = [[NSDate date]timeIntervalSinceDate:kStartDate];
    [kPressTimer invalidate];
    kPressTimer = nil;
    kStartDate = nil;
    NSLog(@"\npress lasted %@ seconds\n",@(touchDuration));
    if (self.isPlaying) {
        self.playing = NO;
    }else{
        self.playing = YES;
    }
}

@end
