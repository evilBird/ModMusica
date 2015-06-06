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

- (void)beginUpdates;
- (void)endUpdates;

- (void)randomizeColors;

@end
