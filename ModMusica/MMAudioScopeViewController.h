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

@property (nonatomic,strong)                UILabel                 *label;
@property (nonatomic,strong)                UILabel                 *titleLabel;
@property (nonatomic,strong)                UILabel                 *nowPlayingLabel;

@property (nonatomic)                       double                  stepsPerMinute;
@property (nonatomic)                       double                  beatsPerMinute;
@property (nonatomic,strong)                NSString                *nowPlaying;

@property (nonatomic,getter=isUpdating)     BOOL                    updating;

- (void)showDetails;
- (void)beginUpdates;
- (void)endUpdates;
- (void)randomizeColors;

@end
