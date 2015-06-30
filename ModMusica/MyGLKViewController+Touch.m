//
//  MyGLKViewController+Touch.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/17/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MyGLKViewController+Touch.h"
#import "PdBase.h"
#import "MyGLKDefs.h"


@implementation MyGLKViewController (Touch)

static NSDate   *kStartDate;
static NSTimer  *kPressTimer;
static NSDate   *kLastTap;
static NSInteger kTapCount;
static UIPinchGestureRecognizer *kPinch = nil;
static bool lock = 0;

- (void)handlePinch:(id)sender
{
    if (sender != kPinch) {
        return;
    }
    
    kStartDate = nil;
    [kPressTimer invalidate];
    
    switch (kPinch.state) {
        case UIGestureRecognizerStateBegan:
            lock = 1;
            _scale =  kPinch.scale;
            //kPinch.scale
            break;
            case UIGestureRecognizerStateChanged:
            lock = 1;
            _scale = kPinch.scale;
            break;
            
            case UIGestureRecognizerStateCancelled:
            lock = 0;
            
            break;
            
            case UIGestureRecognizerStateRecognized:
            lock = 0;
            
            break;
            
            case UIGestureRecognizerStateFailed:
            lock = 0;
            
            break;
            
            case UIGestureRecognizerStatePossible:
            
            break;
            
        default:
            break;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!kPinch) {
        //kPinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
        //[self.view addGestureRecognizer:kPinch];
        //kPinch.enabled = YES;
    }
    
    
    kStartDate = [NSDate date];
    kPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.45
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
    }else if (kTapCount <= 1){
        [self showDetails];
    }
    
    kLastTap = [NSDate date];
    kPressTimer = nil;
    kStartDate = nil;
}

- (void)handlePress
{
    if (lock) {
        return;
    }
    
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
