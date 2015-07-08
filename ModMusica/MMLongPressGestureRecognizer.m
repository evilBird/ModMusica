//
//  MMGestureRecognizer.m
//  ModMusica
//
//  Created by Travis Henspeter on 7/7/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMLongPressGestureRecognizer.h"
#import "MMPinchGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface MMLongPressGestureRecognizer () <UIGestureRecognizerDelegate>

@property (nonatomic,strong)        NSTimer         *touchTimer;
@property (nonatomic)               BOOL            touchesAreHappening;

@end

@implementation MMLongPressGestureRecognizer

- (instancetype)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if (self) {
        _pressDuration = 0.4;
        _touchesAreHappening = NO;
        self.delegate = self;
    }
    
    return self;
}

- (void)handleTouchTimer:(id)sender
{
    [self.touchTimer invalidate];
    self.touchTimer = nil;
    if (self.touchesAreHappening) {
        self.state = UIGestureRecognizerStateRecognized;
    }else{
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touches.count > 1) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    self.touchesAreHappening = YES;
    self.state = UIGestureRecognizerStatePossible;
    self.touchTimer = [NSTimer scheduledTimerWithTimeInterval:self.pressDuration
                                                       target:self
                                                     selector:@selector(handleTouchTimer:)
                                                     userInfo:nil
                                                      repeats:NO];
    
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touches.count > 1) {
        if (self.touchTimer && self.touchTimer.isValid) {
            [self.touchTimer invalidate];
            self.touchTimer = nil;
        }
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    self.touchesAreHappening = YES;
    if (self.touchTimer && self.touchTimer.isValid) {
        self.state = UIGestureRecognizerStatePossible;
    }else{
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touches.count > 1) {
        if (self.touchTimer && self.touchTimer.isValid) {
            [self.touchTimer invalidate];
            self.touchTimer = nil;
        }
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    self.touchesAreHappening = YES;
    if (self.touchTimer && self.touchTimer.isValid) {
        self.state = UIGestureRecognizerStatePossible;
    }else{
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.touchesAreHappening = NO;
    if (self.touchTimer.isValid) {
        [self.touchTimer invalidate];
        self.touchTimer = nil;
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)reset
{
    self.touchesAreHappening = NO;
    if (self.touchTimer.isValid) {
        [self.touchTimer invalidate];
        self.touchTimer = nil;
        self.state = UIGestureRecognizerStatePossible;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return NO;
    }
    
    return YES;
}

@end
