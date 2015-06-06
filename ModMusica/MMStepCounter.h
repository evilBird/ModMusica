//
//  MMStepCounter.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/5/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMStepCounterDelegate <NSObject>

- (void)stepCounter:(id)sender updatedStepsPerMinute:(double)stepsPerMinute;

@end

@interface MMStepCounter : NSObject

@property (nonatomic,weak)                          id<MMStepCounterDelegate>       delegate;
@property (nonatomic,getter=isUpdating)             BOOL                            updating;
@property (nonatomic)                               double                          stepsPerMinute;

- (void)startUpdates;
- (void)endUpdates;

@end
