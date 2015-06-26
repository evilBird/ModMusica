//
//  MyGLKViewController.h
//  GLKitStuff
//
//  Created by Travis Henspeter on 6/12/15.
//  Copyright (c) 2015 birdSound LLC. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "MMPlaybackController.h"
#import "HamburgerButton.h"

@protocol MyGLKViewControllerDelegate <NSObject>

- (void)openCloseDrawer:(id)sender;

@end

@interface MyGLKViewController : GLKViewController

@property (nonatomic,getter=isPlaying)              BOOL                                    playing;

@property (nonatomic,strong)                        NSString                                *currentModName;
@property (nonatomic,strong)                        UILabel                                 *titleLabel;
@property (nonatomic,strong)                        UILabel                                 *nowPlayingLabel;
@property (nonatomic,strong)                        UILabel                                 *infoLabel;
@property (nonatomic,strong)                        HamburgerButton                         *hamburgerButton;

@property (nonatomic,strong)                        UIColor                                 *mainColor;

@property (strong, nonatomic)                       MMPlaybackController                    *playbackController;
@property (strong, nonatomic)                       id<MyGLKViewControllerDelegate>         glkDelegate;

- (void)showDetails;
- (void)randomizeColors;

@end
