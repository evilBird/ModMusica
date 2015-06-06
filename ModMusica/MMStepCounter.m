//
//  MMStepCounter.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/5/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMStepCounter.h"
#import <CoreMotion/CoreMotion.h>

@interface MMStepCounter ()

@property (nonatomic,strong)        CMPedometer         *pedometer;
@property (nonatomic,strong)        NSTimer             *timer;
@property (nonatomic,strong)        NSDate              *startDate;
@property (nonatomic,strong)        CMPedometerHandler  pedometerHandler;
@property (nonatomic)               NSTimeInterval      elaspedTime;
@end

@implementation MMStepCounter

- (void)handlePedometerData:(CMPedometerData *)data
{
    double bpm = data.numberOfSteps.integerValue/self.elaspedTime;
    self.stepsPerMinute = bpm;
    NSLog(@"\n\nBPM: %@\n\n",@(bpm));
}

- (void)commonInit
{
}

- (void)startUpdates
{
    if (![CMPedometer isStepCountingAvailable]) {
        self.updating = NO;
        self.stepsPerMinute = -1;
        return;
    }
    
    if (!self.pedometer) {
        self.pedometer = [[CMPedometer alloc]init];
    }
    self.updating = YES;
    self.startDate = [NSDate date];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(incrementTimer:) userInfo:nil repeats:YES];
    __weak MMStepCounter *weakself = self;
    [self.pedometer startPedometerUpdatesFromDate:self.startDate withHandler:^(CMPedometerData *pedometerData, NSError *error) {
        if (error) {
            NSLog(@"\nError handling pedometer data: %@\n",error.debugDescription);
        }else{
            if (pedometerData) {
                [weakself handlePedometerData:pedometerData];
            }
        }
    }];
}

- (void)endUpdates
{
    self.updating = NO;
    [self.timer invalidate];
    self.timer = nil;
    [self.pedometer stopPedometerUpdates];
}

- (void)incrementTimer:(id)sender
{
    self.elaspedTime = (1.0/60.0) * [[NSDate date]timeIntervalSinceDate:self.startDate] + 0.000001;
    if (self.elaspedTime > 1.0) {
        [self restartUpdatesFromNow];
    }
}

- (void)restartUpdatesFromNow
{
    [self.pedometer stopPedometerUpdates];
    [self startUpdates];
}

@end
