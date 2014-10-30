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
@property (nonatomic,strong)MMScopeViewController *scopeViewController;
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
    [self initalizePd];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSArray *children = self.childViewControllers;
    id first = children.firstObject;
    if ([first isKindOfClass:[MMScopeViewController class]]) {
        self.scopeViewController = first;
    }
}

-(void)initalizePd
{
    self.dispatcher = [[PdDispatcher alloc]init];
    [PdBase setDelegate:self.dispatcher];
    
    expr_tilde_setup();
    fiddle_tilde_setup();
    expr_setup();
    bonk_tilde_setup();
    helmholtz_tilde_setup();
    
    [self.dispatcher addListener:self forSource:@"detectedTempo"];
    [self.dispatcher addListener:self forSource:@"clockBang"];
    [self.dispatcher addListener:self forSource:@"interval"];
    [self.dispatcher addListener:self forSource:@"beat"];
    self.patch = [PdBase openFile:@"modmusica_1.pd" path:[[NSBundle mainBundle]resourcePath]];
    
    [PdBase sendFloat:1 toReceiver:@"audioSwitch"];
    [PdBase sendFloat:1 toReceiver:@"outputVolume"];
    [PdBase sendFloat:0.46 toReceiver:@"drumsVolume"];
    [PdBase sendFloat:0.25 toReceiver:@"synthVolume"];
    [PdBase sendFloat:0.66 toReceiver:@"samplerVolume"];
    [PdBase sendFloat:0.33 toReceiver:@"bassVolume"];
    [PdBase sendBangToReceiver:@"loadNewSamples"];
}

#pragma mark - PdListener

- (void)receiveFloat:(float)received fromSource:(NSString *)source
{
    
    if ([source isEqualToString:@"interval"]) {
        NSLog(@"interval: %f",received);
        self.scopeViewController.timeInterval = received * 0.001;
        [self.scopeViewController update];
        return;
    }
    
    if ([source isEqualToString:@"beat"]) {
        [self.scopeViewController updateScope:received];
    }
    
    /*
    if ([source isEqualToString:@"detectedTempo"]){
        NSLog(@"detectedTempo: %f",received);
        NSTimeInterval interval = 60000.0f/received;
        if (self.scopeViewController.timeInterval != (interval * 0.004)) {
            self.scopeViewController.timeInterval = interval * 0.004;
        }
        return;
    }
     */
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
