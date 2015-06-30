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
#import "MMRootViewController+Touches.h"
#import "MMRootViewController+Editor.h"
#import "MMStepCounter.h"


@interface MMRootViewController () <MMStepCounterDelegate>

@property (nonatomic,strong)            MMStepCounter           *stepCounter;
@property (nonatomic,strong)            MyGLKViewController     *myGLKViewController;

@end

@implementation MMRootViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.delegate = self;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.myGLKViewController = [storyboard instantiateViewControllerWithIdentifier:@"MyGLKViewController"];
    self.myGLKViewController.currentModName = @"mario";
    self.myGLKViewController.glkDelegate = self;
    self.paneViewController = self.myGLKViewController;
    
    MMModuleViewController *mm =[storyboard instantiateViewControllerWithIdentifier:@"DrawerViewController"];
    mm.delegate = self;
    mm.datasource = self;
    
    [self setDrawerViewController:mm forDirection:MSDynamicsDrawerDirectionLeft];
    
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    if (![self getGLKViewController].playbackController.lockTempo) {
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
