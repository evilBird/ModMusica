//
//  ViewController.m
//  ModMusica
//
//  Created by Travis Henspeter on 10/27/14.
//  Copyright (c) 2014 birdSound. All rights reserved.
//

#import "ViewController.h"
#import "MMVisualViewController.h"
#import "MMAudioScopeViewController.h"

@interface ViewController () <MMPlaybackDelegate>

@property (nonatomic,strong)        MMPlaybackController            *playbackController;
@property (nonatomic,strong)        MMVisualViewController          *visualViewController;
@property (nonatomic,strong)        MMAudioScopeViewController      *scopeViewController;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.playbackController = [[MMPlaybackController alloc]init];
    self.playbackController.delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches began in vc");
    if (self.playbackController.isPlaying) {
        [self.playbackController stopPlayback];
    }else{
        [self.playbackController startPlayback];
    }
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
}

- (void)playbackEnded:(id)sender
{
    [self.scopeViewController endUpdates];
}

- (void)playback:(id)sender clockDidChange:(NSInteger)clock
{
    [self.visualViewController playback:sender clockDidChange:clock];
}


@end
