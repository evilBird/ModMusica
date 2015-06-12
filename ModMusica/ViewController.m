//
//  ViewController.m
//  ModMusica
//
//  Created by Travis Henspeter on 10/27/14.
//  Copyright (c) 2014 birdSound. All rights reserved.
//

#import "ViewController.h"
#import "MMVisualViewController.h"
#import "MMStepCounter.h"
#import "ViewController+Touch.h"
#import "ViewController+Module.h"
#import "MMAudioScopeViewController+Random.h"

#define kSetTempoReceiver @"manualSetTempo"

@interface ViewController () <MMPlaybackDelegate,MMStepCounterDelegate,MMAudioScopeViewControllerDelegate>

@property (nonatomic,strong)        MMVisualViewController          *visualViewController;
@property (nonatomic,strong)        MMStepCounter                   *stepCounter;

@end

@implementation ViewController

#pragma mark - Public
#pragma mark - Accessors

- (void)setPlaying:(BOOL)playing
{
    BOOL old = _playing;
    _playing = playing;
    if (_playing != old) {
        if (_playing) {
            [self.playbackController startPlayback];
            self.scopeViewController.nowPlaying = self.playbackController.patternName;
        }else{
            [self.playbackController stopPlayback];
        }
    }
}

- (void)showDetails
{
    [self.scopeViewController showDetails];
}

#pragma mark - Private
#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.playbackController = [[MMPlaybackController alloc]init];
    self.playbackController.delegate = self;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.scopeViewController = [storyboard instantiateViewControllerWithIdentifier:@"AudioScopeViewController"];
    self.scopeViewController.delegate = self;
    self.paneViewController = self.scopeViewController;
    [self configureModules];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id dest = segue.destinationViewController;
    if ([dest isKindOfClass:[MMAudioScopeViewController class]]) {
        self.scopeViewController = dest;
    }
}

#pragma mark - MMVisualPlaybackDelegate
- (void)playbackBegan:(id)sender
{
    [self.scopeViewController randomizeColors];
    [self.scopeViewController beginUpdates];
    self.stepCounter = [[MMStepCounter alloc]init];
    self.stepCounter.delegate = self;
    [self.stepCounter startUpdates];
}

- (void)playbackEnded:(id)sender
{
    [self.scopeViewController endUpdates];
    [self.stepCounter endUpdates];
    self.stepCounter = nil;
}

- (void)playback:(id)sender clockDidChange:(NSInteger)clock
{
    if (clock%64 == 0) {
        [self.scopeViewController randomizeColors];
    }
}

- (void)playback:(id)sender detectedUserTempo:(double)tempo
{
    self.scopeViewController.beatsPerMinute = tempo;
}

#pragma mark - MMStepCounterDelegate

- (void)stepCounter:(id)sender updatedStepsPerMinute:(double)stepsPerMinute
{
    self.scopeViewController.stepsPerMinute = stepsPerMinute;
    [PdBase sendFloat:stepsPerMinute toReceiver:kSetTempoReceiver];
}

#pragma mark - MMAudioScopeViewControllerDelegate
- (void)showSettings:(id)sender
{
    if (self.paneState == MSDynamicsDrawerPaneStateClosed) {
        [self setPaneState:MSDynamicsDrawerPaneStateOpen
               inDirection:MSDynamicsDrawerDirectionLeft
                  animated:YES
     allowUserInterruption:NO
                completion:NULL];
    }
}

@end
