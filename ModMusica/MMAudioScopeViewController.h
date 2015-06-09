//
//  MMAudioScopeViewController.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/5/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMScopeDataSource.h"

@interface MMAudioScopeViewController : UIViewController <MMScopeDataSourceConsumer>

@property (nonatomic,strong)        UILabel                 *label;

- (void)showDetails;
- (void)beginUpdates;
- (void)endUpdates;
- (void)randomizeColors;
- (void)showStepsPerMinute:(double)steps;
- (void)showBeatsPerMinute:(double)bpm;
- (void)showNowPlaying:(NSString *)nowPlaying;
@end
