//
//  MMScopeViewController.h
//  ModMusica
//
//  Created by Travis Henspeter on 10/27/14.
//  Copyright (c) 2014 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMScopeViewController : UIViewController

@property (nonatomic,getter=isRunning)BOOL running;

- (void)start;
- (void)stop;
- (void)update;

@property (nonatomic)CGFloat timeInterval;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;

@end
