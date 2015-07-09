//
//  BlameViewController.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/23/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMRootViewController.h"
#import "MMModuleViewController.h"
#import "MyGLKViewController.h"
#import "MMRootViewController+Mods.h"
#import "MMRootViewController+Drawer.h"
#import "MMStepCounter.h"
#import "MMLongPressGestureRecognizer.h"
#import "MMTapGestureRecognizer.h"
#import "MMPurchaseManager.h"
#import "MMPinchGestureRecognizer.h"

@interface MMRootViewController () <MMStepCounterDelegate>

@property (nonatomic,strong)            MMStepCounter                       *stepCounter;
@property (nonatomic,strong)            MyGLKViewController                 *myGLKViewController;
@property (nonatomic,strong)            MMLongPressGestureRecognizer        *longPress;
@property (nonatomic,strong)            MMTapGestureRecognizer              *tap;
@property (nonatomic,strong)            MMPinchGestureRecognizer            *pinch;

@end

@implementation MMRootViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];    
    self.delegate = self;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.myGLKViewController = [storyboard instantiateViewControllerWithIdentifier:@"MyGLKViewController"];
    self.myGLKViewController.currentModName = @"";
    self.myGLKViewController.glkDelegate = self;
    self.longPress = [[MMLongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    self.tap = [[MMTapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    self.pinch = [[MMPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
    [self.myGLKViewController.view addGestureRecognizer:self.tap];
    [self.myGLKViewController.view addGestureRecognizer:self.longPress];
    [self.myGLKViewController.view addGestureRecognizer:self.pinch];
    self.paneViewController = self.myGLKViewController;
    
    MMModuleViewController *mm =[storyboard instantiateViewControllerWithIdentifier:@"DrawerViewController"];
    mm.delegate = self;
    mm.datasource = self;
    [self setDrawerViewController:mm forDirection:MSDynamicsDrawerDirectionLeft];
    [self setPaneDragRevealEnabled:YES forDirection:MSDynamicsDrawerDirectionLeft];
    [self setupDrawerDynamics];
    
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    static CGPoint initialLoc;
    static CGPoint previousLoc;
    
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
    NSLog(@"ds = %@, dv = %@",@(deltaScale),@(deltaVelocity));
    previousScale = scale;
    previousVelocity = velocity;
    [[self getGLKViewController]changeScale:deltaScale];
}

- (void)handleTap:(id)sender
{
    MMTapGestureRecognizer *tap = sender;
    UIGestureRecognizerState state = tap.state;
    NSUInteger numTaps = tap.tapCount;
    NSLog(@"num taps: %@",@(numTaps));
    BOOL tempoLocked = [self getGLKViewController].playbackController.isTempoLocked;
    BOOL playing = [self getGLKViewController].isPlaying;
    
    switch (state) {
        case UIGestureRecognizerStateRecognized:
            switch (tap.tapCount) {
                case 1:
                    [[self getGLKViewController]showDetailsFade:[self getGLKViewController].isPlaying];
                    NSLog(@"show details");
                    break;
                    
                default:
                    if (!tempoLocked && playing) {
                        [[self getGLKViewController].playbackController tapTempo];
                        NSLog(@"\ntap tempo");
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
    BOOL playing = [self getGLKViewController].isPlaying;
    
    switch (state) {
        case UIGestureRecognizerStateRecognized:
            [self getGLKViewController].playing = (BOOL)(1-playing);
            NSLog(@"\npress");
            break;
        case UIGestureRecognizerStateFailed:
            
            break;
            
        default:
            break;
    }
}

- (MyGLKViewController *)getGLKViewController
{
    return self.myGLKViewController;
}

#pragma mark GLKViewControllerDelegate

- (void)glkViewController:(id)sender playbackChanged:(BOOL)playing
{
    if (playing) {
        self.stepCounter = [[MMStepCounter alloc]init];
        self.stepCounter.delegate = self;
        [self.stepCounter startUpdates];
    }else{
        [self.stepCounter endUpdates];
        self.stepCounter = nil;
    }
}

#pragma mark MMStepCounterDelegate

- (void)stepCounter:(id)sender updatedStepsPerMinute:(double)stepsPerMinute
{
    if (self.paneViewController != self.myGLKViewController) {
        return;
    }
    
    if (![self getGLKViewController].playbackController.isTempoLocked) {
        [PdBase  sendFloat:stepsPerMinute toReceiver:@"manualSetTempo"];
        [[self getGLKViewController]playback:sender detectedUserTempo:stepsPerMinute];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
