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
#import <CoreMotion/CoreMotion.h>


@protocol MyGLKViewControllerDelegate <NSObject>

- (void)openCloseDrawer:(id)sender;
- (void)glkViewController:(id)sender playbackChanged:(BOOL)playing;

@end

@interface MyGLKViewController : GLKViewController
{
    float       _zoom;
    float       _scale;
}

@property (nonatomic,getter=isPlaying)              BOOL                                    playing;

@property (nonatomic,strong)                        NSString                                *currentModName;
@property (nonatomic,strong)                        UILabel                                 *titleLabel;
@property (nonatomic,strong)                        UILabel                                 *nowPlayingLabel;
@property (nonatomic,strong)                        UILabel                                 *infoLabel;
@property (nonatomic,strong)                        HamburgerButton                         *hamburgerButton;

@property (nonatomic,strong)                        UIColor                                 *mainColor;
@property (strong, nonatomic)                       EAGLContext                             *context;
@property (strong, nonatomic)                       GLKBaseEffect                           *effect;
@property (nonatomic,readonly)                      NSTimeInterval                          timeSinceLastSampleUpdate;
@property (nonatomic, strong)                       CMAttitude                              *referenceFrame;
@property (nonatomic)                               double                                  tempo;
@property (nonatomic)                               double                                  clock;

@property (strong, nonatomic)                       MMPlaybackController                    *playbackController;
@property (strong, nonatomic)                       id<MyGLKViewControllerDelegate>         glkDelegate;

- (void)showDetailsFade:(BOOL)shouldFade;
- (void)randomizeColors;
- (void)playback:(id)sender detectedUserTempo:(double)tempo;
- (void)playback:(id)sender didLoadModuleName:(NSString *)moduleName;
- (void)changeScale:(CGFloat)scale;

@end
