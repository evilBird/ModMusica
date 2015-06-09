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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    kStartDate = [NSDate date];
    kPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
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
    NSTimeInterval touchDuration = [[NSDate date]timeIntervalSinceDate:kStartDate];
    [kPressTimer invalidate];
    kPressTimer = nil;
    kStartDate = nil;
    NSLog(@"\ntap lasted %@ seconds\n",@(touchDuration));
    [PdBase sendBangToReceiver:@"tapTempo"];
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
