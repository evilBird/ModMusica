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

#define kSetTempoReceiver @"manualSetTempo"

@interface ViewController () <MMPlaybackDelegate,MMStepCounterDelegate,UIGestureRecognizerDelegate>

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
    self.stepCounter = [[MMStepCounter alloc]init];
    self.stepCounter.delegate = self;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.scopeViewController = [storyboard instantiateViewControllerWithIdentifier:@"AudioScopeViewController"];
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
    if ([dest isKindOfClass:[MMVisualViewController class]]) {
        self.visualViewController = dest;
    }else{
        self.scopeViewController = dest;
    }
}

#pragma mark - MMVisualPlaybackDelegate
- (void)playbackBegan:(id)sender
{
    [self.scopeViewController randomizeColors];
    [self.scopeViewController beginUpdates];
    [self.stepCounter startUpdates];
}

- (void)playbackEnded:(id)sender
{
    [self.scopeViewController endUpdates];
    [self.stepCounter endUpdates];
}

- (void)playback:(id)sender clockDidChange:(NSInteger)clock
{
    [self.visualViewController playback:sender clockDidChange:clock];
}

- (void)playback:(id)sender detectedUserTempo:(double)tempo
{
    [self.scopeViewController showBeatsPerMinute:tempo];
}

#pragma mark - MMStepCounterDelegate
- (void)stepCounter:(id)sender updatedStepsPerMinute:(double)stepsPerMinute
{
    [self.scopeViewController showStepsPerMinute:stepsPerMinute];
    if (stepsPerMinute > 1 && self.stepCounter.isUpdating) {
        [PdBase sendFloat:stepsPerMinute toReceiver:kSetTempoReceiver];
    }
}


@end
