//
//  MMStepCounter.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/5/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMStepCounter.h"
#import <CoreMotion/CoreMotion.h>

static NSUInteger kQueueSize = 4;

@interface MMStepCounter ()
{
    NSInteger kPrevStepCt;
}
@property (nonatomic,strong)        CMPedometer         *pedometer;
@property (nonatomic,strong)        NSTimer             *timer;
@property (nonatomic,strong)        NSDate              *startDate;
@property (nonatomic,strong)        CMPedometerHandler  pedometerHandler;
@property (nonatomic)               NSTimeInterval      elaspedTime;
@property (nonatomic,strong)        NSMutableArray      *myStepQueue;

@end

@implementation MMStepCounter

- (void)handlePedometerData:(CMPedometerData *)data
{
    NSInteger newStepCount = data.numberOfSteps.integerValue;
    
    if (newStepCount > kPrevStepCt) {
        if (!self.myStepQueue) {
            self.myStepQueue = [NSMutableArray array];
        }
        
        NSDate *now = [NSDate date];
        NSDictionary *newest = @{@"date":now,@"count":@(newStepCount)};
        NSInteger prevCount = self.myStepQueue.count;
        [self.myStepQueue addObject:newest];
        
        if (prevCount == kQueueSize){
            NSDictionary *oldest = self.myStepQueue.firstObject;
            [self.myStepQueue removeObjectAtIndex:0];
            [self.myStepQueue addObject:newest];
            NSDate *oldestDate = oldest[@"date"];
            NSNumber *oldestSteps = oldest[@"steps"];
            NSTimeInterval elapsed = [now timeIntervalSinceDate:oldestDate];
            NSInteger newSteps = newStepCount - oldestSteps.integerValue;
            double secPerStep = elapsed/(double)(newSteps - 1.0);
            double bpm = 60.0/secPerStep;
            self.stepsPerMinute = bpm;
            [self.delegate stepCounter:self updatedStepsPerMinute:self.stepsPerMinute];
        }
    }
    
    kPrevStepCt = newStepCount;
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
    kPrevStepCt = 0;
    self.startDate = [NSDate date];
    
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
    self.myStepQueue = nil;
}


@end
