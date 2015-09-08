//
//  BlameViewController.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/23/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMRootViewController.h"
#import "MMModuleViewController.h"
#import "MMRootViewController+Mods.h"
#import "MMStepCounter.h"
#import "MMLongPressGestureRecognizer.h"
#import "MMTapGestureRecognizer.h"
#import "MMPurchaseManager.h"
#import "MMPinchGestureRecognizer.h"
#import "MMModuleManager.h"
#import "UIColor+HBVHarmonies.h"
#import "UIView+Layout.h"
#import "MMRootViewController+GLK.h"
#import "MMShaderViewController+Labels.h"

@interface MMRootViewController ()

@property (nonatomic,strong)            MMLongPressGestureRecognizer        *longPress;
@property (nonatomic,strong)            MMTapGestureRecognizer              *tap;
@property (nonatomic,strong)            MMPinchGestureRecognizer            *pinch;


@end

@implementation MMRootViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.mainColor = [UIColor randomColor];
    [self resetMetrics];
    // Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    __weak MMRootViewController *weakself = self;
    NSString *modName = @"mario";
    [self setupPlayback:modName completion:^(BOOL success) {
        if (success){
            weakself.shaderViewController.shaderKey = modName;
            [weakself setupGestureRecognizers];
            [weakself.shaderViewController hideActivity];
        }else{
            [weakself.shaderViewController hideActivity];
            [[MMRootViewController errorAlert:@"Failed to setup audio" modName:modName]show];
        }
    }];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetMetrics
{
    self.scale = 1.0;
    self.rotation = 0.0;
}

- (void)setupGestureRecognizers
{
    self.longPress = [[MMLongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    [self.view addGestureRecognizer:self.longPress];
    self.tap = [[MMTapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:self.tap];
    self.pinch = [[MMPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:self.pinch];
}

- (void)handlePinch:(id)sender
{
    MMPinchGestureRecognizer *pinch = sender;
    CGFloat scale = pinch.scale;
    CGFloat velocity = pinch.velocity;
    
    static CGFloat initalScale;
    static CGFloat previousScale;
    static CGFloat initialVelocity;
    static CGFloat previousVelocity;
    
    CGFloat deltaScale;
    CGFloat deltaVelocity;
    
    
    switch (pinch.state) {
        case UIGestureRecognizerStateBegan:
            initalScale = scale;
            initialVelocity = velocity;
            
            break;
        default:
            
            break;
    }
    deltaScale = scale - initalScale;
    deltaVelocity = velocity - initialVelocity;
    previousScale = scale;
    previousVelocity = velocity;
    self.scale  = scale;
}

- (void)handleTap:(id)sender
{
    MMTapGestureRecognizer *tap = sender;
    UIGestureRecognizerState state = tap.state;
    BOOL tempoLocked = self.playbackController.isTempoLocked;
    BOOL playing = self.playbackController.isPlaying;
    
    switch (state) {
        case UIGestureRecognizerStateRecognized:
            switch (tap.tapCount) {
                case 1:
                    [self.shaderViewController showDetailsFade:self.playbackController.isPlaying];
                    break;
                    
                default:
                    if (!tempoLocked && playing) {
                        [self.playbackController tapTempo];
                    }
                    break;
            }
            break;
            
        default:
            break;
    }
}

- (void)handleLongPress:(id)sender
{
    MMLongPressGestureRecognizer *lp = sender;
    UIGestureRecognizerState state = lp.state;
    BOOL playing = self.playbackController.isPlaying;
    
    switch (state) {
        case UIGestureRecognizerStateRecognized:
            if (playing) {
                [self.playbackController stopPlayback];
            }else{
                [self.playbackController startPlayback];
            }            
            break;
        case UIGestureRecognizerStateFailed:
            
            break;
            
        default:
            break;
    }
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    id dest = segue.destinationViewController;
    if ([dest isKindOfClass:[MMShaderViewController class]]) {
        self.shaderViewController = dest;
        self.shaderViewController.glkDelegate = self;
        [self.shaderViewController showActivity];
        //self.shaderViewController.shaderKey = @;
    }
    
}

@end
