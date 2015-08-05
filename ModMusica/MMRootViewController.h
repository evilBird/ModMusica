//
//  BlameViewController.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/23/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MSDynamicsDrawerViewController.h"
#import "MyGLKViewController.h"
#import "MMPlaybackController+ResourceLoader.h"

@interface MMRootViewController : MSDynamicsDrawerViewController

- (MyGLKViewController *)getGLKViewController;

@property (strong, nonatomic)                       MMPlaybackController                    *playbackController;

@end
