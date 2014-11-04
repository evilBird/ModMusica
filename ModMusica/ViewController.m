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
#import "MMPatternLoader.h"

@interface ViewController ()<PdListener,MMPlaybackDelegate>

@property (nonatomic,strong)PdAudioController *audioController;
@property (nonatomic,strong)PdDispatcher *dispatcher;
@property (nonatomic,strong)MMScopeViewController *scopeViewController;
@property (nonatomic,strong)MMPatternLoader *patternLoader;
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
    self.patternLoader = [[MMPatternLoader alloc]init];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSArray *children = self.childViewControllers;
    id first = children.firstObject;
    if ([first isKindOfClass:[MMScopeViewController class]]) {
        self.scopeViewController = first;
        self.scopeViewController.playbackDelegate = self;
    }
    
    [self.patternLoader setPattern:@"mega"];
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
    [self.dispatcher addListener:self forSource:@"interval"];
    [self.dispatcher addListener:self forSource:@"beat"];
    [self.dispatcher addListener:self forSource:@"clock"];
    self.patch = [PdBase openFile:@"modmusica_2.pd" path:[[NSBundle mainBundle]resourcePath]];
    
    [PdBase sendFloat:1 toReceiver:@"audioSwitch"];
    [PdBase sendFloat:1 toReceiver:@"outputVolume"];
    //[PdBase sendFloat:0.66 toReceiver:@"drumsVolume"];
    //[PdBase sendFloat:0.25 toReceiver:@"synthVolume"];
    //[PdBase sendFloat:0.7 toReceiver:@"samplerVolume"];
    [PdBase sendFloat:0.33 toReceiver:@"bassVolume"];
    [PdBase sendBangToReceiver:@"loadNewSamples"];
}

- (void)playbackStarted
{
    [self.patternLoader playNextSection];
}

- (void)playbackStopped
{
    
}

#pragma mark - PdListener

- (void)receiveFloat:(float)received fromSource:(NSString *)source
{
    if ([source isEqualToString:@"interval"]) {
        self.scopeViewController.timeInterval = received * 0.001;
        [self.scopeViewController update];
        return;
    }
    
    if ([source isEqualToString:@"beat"]) {
        [self.scopeViewController updateScope:received];
        return;
    }
    
    if ([source isEqualToString:@"clock"] && received == 0) {
        static NSInteger rep;
        if (rep%2 == 0) {
            NSLog(@"reps: %@",@(rep));
            if (rep == 4) {
                rep = 0;
                [self.patternLoader playNextSection];
            }
        }
        
        rep += 1;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches began in vc");
}


@end
