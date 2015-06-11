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
@property (nonatomic,strong)        CMPedometerHandler  pedometerHandler;

@end

@implementation MMStepCounter

- (void)handlePedometerData:(CMPedometerData *)data
{
    NSInteger newStepCount = data.numberOfSteps.doubleValue;
    NSDate *startDate = data.startDate;
    NSDate *endDate = data.endDate;
    NSTimeInterval seconds = [endDate timeIntervalSinceDate:startDate];
    NSTimeInterval minutes = seconds/60.0;
    self.stepsPerMinute = round((newStepCount/minutes));
    
    if (self.stepsPerMinute > 40.0 && self.isUpdating) {
        [self.delegate stepCounter:self updatedStepsPerMinute:self.stepsPerMinute];
    }
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
    
    NSDate *now = [NSDate date];
    __weak MMStepCounter *weakself = self;
    [self.pedometer startPedometerUpdatesFromDate:now withHandler:^(CMPedometerData *pedometerData, NSError *error) {
        if (error) {
            NSLog(@"\nError handling pedometer data: %@\n",error.debugDescription);
        }else{
            if (pedometerData) {
                [weakself handlePedometerData:pedometerData];
                weakself.updating = YES;
            }
        }
    }];
}

- (void)endUpdates
{
    self.updating = NO;
    [self.pedometer stopPedometerUpdates];
    self.pedometer = nil;
}


@end
