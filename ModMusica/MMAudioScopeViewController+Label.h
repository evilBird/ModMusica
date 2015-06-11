//
//  MMAudioScopeViewController+Label.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMAudioScopeViewController.h"

@interface MMAudioScopeViewController (Label)

- (void)configureLabels;
- (void)configureLabelConstraints;
- (void)showNowPlaying;
- (void)hideNowPlaying;
- (void)hideTitle;
- (void)hideLabel;
- (void)showStepsPerMinute;
- (void)showBeatsPerMinute;
- (void)showAllForDuration:(NSTimeInterval)duration;
- (void)showAll;
- (void)hideAll;
- (void)hideAllAfterDelay:(NSTimeInterval)duration;

@end
