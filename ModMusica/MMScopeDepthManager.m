//
//  MMScopeDepthManager.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/11/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//
#import "MMScopeDepthManager.h"

@interface MMScopeDepthManager ()

@property (nonatomic,strong)        NSTimer             *timer;
@property (nonatomic)               int                 counter;

@end

@implementation MMScopeDepthManager

- (instancetype)initWithDelegate:(id<MMScopeDepthManagerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _counter = 0;
    }
    return self;
}

- (void)handleTimer:(id)sender
{
    NSArray *layers = [self.delegate shapeLayersForDepthManager:self];
    int ct = (int)layers.count;
    int i = self.counter%ct;
    if (i<layers.count) {
        NSUInteger index = (NSUInteger)i;
        [self.delegate depthManager:self animateLayerAtIndex:index];
    }
    self.counter++;
}

- (void)startUpdates
{
    if (self.isUpdating) {
        return;
    }
    
    self.updating = YES;
    _counter = 0;
    NSTimeInterval timeBase = [self.delegate animationDuration];
    double count = (double)[self.delegate shapeLayersForDepthManager:self].count;
    if (!count) {
        return;
    }
    
    NSTimeInterval interval = timeBase/count;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
    self.timer.tolerance = (interval * 0.05);
}

- (void)endUpdates
{
    if (!self.isUpdating) {
        return;
    }
    self.updating = NO;
    _counter = 0;
    [self.timer invalidate];
    self.timer = nil;
}

- (void)dealloc
{
    [self endUpdates];
    _delegate = nil;
}

@end
