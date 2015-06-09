//
//  ViewController.h
//  ModMusica
//
//  Created by Travis Henspeter on 10/27/14.
//  Copyright (c) 2014 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSDynamicsDrawerViewController.h"

@interface ViewController : MSDynamicsDrawerViewController

@property (nonatomic,getter=isPlaying)      BOOL        playing;

- (void)showDetails;

@end

