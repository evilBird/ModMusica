//
//  ViewController.h
//  ModMusica
//
//  Created by Travis Henspeter on 10/27/14.
//  Copyright (c) 2014 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSDynamicsDrawerViewController.h"
#import "MMPlaybackController.h"
#import "MMAudioScopeViewController.h"

@interface ViewController : MSDynamicsDrawerViewController

@property (nonatomic,getter=isPlaying)      BOOL        playing;
@property (nonatomic,strong)                MMPlaybackController            *playbackController;
@property (nonatomic,strong)                MMAudioScopeViewController      *scopeViewController;


- (void)showDetails;

@end

