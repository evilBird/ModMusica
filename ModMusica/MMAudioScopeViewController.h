//
//  MMAudioScopeViewController.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/5/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMScopeDataSource.h"
#import "HamburgerButton.h"

@protocol MMAudioScopeViewControllerDelegate <NSObject>

- (void)showSettings:(id)sender;

@end

@class MMScopeDepthManager;

@interface MMAudioScopeViewController : UIViewController <MMScopeDataSourceConsumer>

@property (nonatomic,weak)                  id<MMAudioScopeViewControllerDelegate> delegate;

@property (nonatomic,strong)                UILabel                 *label;
@property (nonatomic,strong)                UILabel                 *titleLabel;
@property (nonatomic,strong)                UILabel                 *nowPlayingLabel;
@property (nonatomic,strong)                HamburgerButton         *hamburgerButton;
@property (nonatomic,strong)                UIView                  *contentView;
@property (nonatomic,strong)                NSMutableArray          *shapeLayers;
@property (nonatomic,strong)                MMScopeDepthManager     *depthManager;


@property (nonatomic)                       double                  stepsPerMinute;
@property (nonatomic)                       double                  beatsPerMinute;
@property (nonatomic,strong)                NSString                *nowPlaying;
@property (nonatomic,getter=isUpdating)     BOOL                    updating;

- (void)showDetails;
- (void)beginUpdates;
- (void)endUpdates;

@end
