//
//  MMAudioScopeViewController+Gesture.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/9/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMAudioScopeViewController+Gesture.h"
#import "PdBase.h"

@interface MMAudioScopeViewController () <UIGestureRecognizerDelegate>

@end

@implementation MMAudioScopeViewController (Gesture)

- (void)handleTap:(id)sender
{
    UITapGestureRecognizer *tap = sender;
    if (tap.state == UIGestureRecognizerStateRecognized) {
        [PdBase sendBangToReceiver:@"tapTempo"];
    }
}

- (void)addTapGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
    tap.delegate = self;
    
}

- (void)handlePress:(id)sender
{
    UILongPressGestureRecognizer *press = sender;
    if (press.state == UIGestureRecognizerStateRecognized) {
        static NSInteger play;
        play = (play+1)%2;

    }
}

- (void)addPressGesture
{
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handlePress:)];
    [self.view addGestureRecognizer:press];
    press.delegate = self;
}

- (void)addSwipeGesture
{
    
}

@end
