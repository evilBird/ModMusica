//
//  ViewController.m
//  ModMusica
//
//  Created by Travis Henspeter on 10/27/14.
//  Copyright (c) 2014 birdSound. All rights reserved.
//

#import "ViewController.h"
#import <PdBase.h>
#import <PdAudioController.h>
#import <PdDispatcher.h>
#import "MMScopeViewController.h"

@interface ViewController ()<PdListener>

@property (nonatomic,strong)PdAudioController *audioController;
@property (nonatomic,strong)PdDispatcher *dispatcher;
@property void *patch;
@end

@implementation ViewController

void expr_tilde_setup(void);
void fiddle_tilde_setup(void);
void expr_setup(void);
void helmholtz_tilde_setup(void);
void bonk_tilde_setup(void);

- (void)viewDidLoad {
    [super viewDidLoad];
    self.audioController = [[PdAudioController alloc]init];
    [self.audioController configurePlaybackWithSampleRate:44100 numberChannels:2 inputEnabled:YES mixingEnabled:YES];
    self.audioController.active = YES;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self initalizePd];
    NSArray *children = self.childViewControllers;
    MMScopeViewController *vc = children.firstObject;
    [vc start];
}

-(void)initalizePd
{
    NSLog(@"initializing PD");
    self.dispatcher = [[PdDispatcher alloc]init];
    [PdBase setDelegate:self.dispatcher];
    expr_tilde_setup();
    fiddle_tilde_setup();
    expr_setup();
    bonk_tilde_setup();
    helmholtz_tilde_setup();
    
    [self.dispatcher addListener:self forSource:@"playbackFinished"];
    [self.dispatcher addListener:self forSource:@"detectedTempo"];
    [self.dispatcher addListener:self forSource:@"colorTheme"];
    [self.dispatcher addListener:self forSource:@"patternNumber"];
    [self.dispatcher addListener:self forSource:@"CPU"];
    [self.dispatcher addListener:self forSource:@"clockBang"];
    [self.dispatcher addListener:self forSource:@"rootMeanSquare"];
    
    self.patch = [PdBase openFile:@"modMusicPatch_Test_3.pd" path:[[NSBundle mainBundle]resourcePath]];
    [PdBase sendFloat:1.0f toReceiver:@"outputVolume"];
    [PdBase sendFloat:1 toReceiver:@"audioSwitch"];
    [PdBase sendFloat:1 toReceiver:@"onOff"];
}

#pragma mark - PdListener

- (void)receiveFloat:(float)received fromSource:(NSString *)source
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
