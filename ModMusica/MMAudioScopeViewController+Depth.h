//
//  MMAudioScopeViewController+Depth.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/11/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMAudioScopeViewController.h"
#import "MMScopeDepthManager.h"

#define EYE_POSITION 0.02
#define DEPTH_ANIM_DURATION 8.0
#define kMinZPosition -0.01
#define kMaxZPosition 0.01


@interface MMAudioScopeViewController (Depth)<MMScopeDepthManagerDelegate>

- (void)setupDepthOfField;
- (void)startUpdatingDepth;
- (void)stopUpdatingDepth;

@end
