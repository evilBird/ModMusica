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
{
    NSTimer *kTimer;
}

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
    
    //[self.patternLoader setPattern:@"menace"];
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
}

- (void)playbackStarted
{
    //[self changeEverything];
    //[self setInstrumentLevels];
    
    NSArray *patterns = @[@"mario",@"fantasy",@"mega",@"menace"];
    static NSInteger idx;
    idx += 1 + arc4random_uniform(100);
    self.patch = nil;
    //NSString *patchName = [NSString stringWithFormat:@"modmusica_%@.pd",@((idx + arc4random_uniform(100))%patterns.count + 1)];
    NSString *patchName = @"modmusica_2.pd";
    self.patch = [PdBase openFile:patchName path:[[NSBundle mainBundle]resourcePath]];
    [PdBase sendFloat:1 toReceiver:@"audioSwitch"];
    [PdBase sendFloat:1 toReceiver:@"outputVolume"];
    [PdBase sendFloat:0.45 toReceiver:@"drumsVolume"];
    [PdBase sendFloat:0.23 toReceiver:@"synthVolume"];
    [PdBase sendFloat:0.4 toReceiver:@"samplerVolume"];
    [PdBase sendFloat:0.27 toReceiver:@"bassVolume"];
    [PdBase sendBangToReceiver:@"loadNewSamples"];
    NSString *pattern = patterns[idx%patterns.count];
    self.patternLoader.currentPattern = pattern;
    [self.patternLoader playNextSection];
    kTimer = [NSTimer scheduledTimerWithTimeInterval:0.033 target:self selector:@selector(incrementTimer) userInfo:nil repeats:YES];
    
}

- (void)incrementTimer
{
    static CGFloat timer;
    timer+=0.01;
    [self.scopeViewController setTime:timer];
}

- (void)changeEverything
{
    [self changePatch];
    [self changePattern];
    [self changeSection];
}

- (void)changePatch
{
    NSArray *patterns = @[@"als",@"gs",@"jb",@"ohn"];
    static NSInteger idx;
    idx += 1 + arc4random_uniform(100);
    if (self.patch != nil) {
        [PdBase closeFile:self.patch];
    }
    idx += 1 + arc4random_uniform(100);
    self.patch = nil;
    NSString *patchName = [NSString stringWithFormat:@"modmusica_%@.pd",@((idx + arc4random_uniform(100))%patterns.count + 1 )];
    self.patch = [PdBase openFile:patchName path:[[NSBundle mainBundle]resourcePath]];
}

- (void)changePattern
{
    NSArray *patterns = @[@"gs",@"jb",@"ohn"];
    static NSInteger idx;
    idx += 1 + arc4random_uniform(100);
    NSString *pattern = patterns[idx%patterns.count];
    self.patternLoader.currentPattern = pattern;
    self.patternLoader.currentSection = -1;
}

- (void)changeSection
{
    [self.patternLoader playNextSection];
}

- (void)setInstrumentLevels
{
    [PdBase sendFloat:1 toReceiver:@"audioSwitch"];
    [PdBase sendFloat:1 toReceiver:@"outputVolume"];
    [PdBase sendFloat:0.5 toReceiver:@"drumsVolume"];
    [PdBase sendFloat:0.23 toReceiver:@"synthVolume"];
    [PdBase sendFloat:0.4 toReceiver:@"samplerVolume"];
    [PdBase sendFloat:0.3 toReceiver:@"bassVolume"];
    [PdBase sendBangToReceiver:@"loadNewSamples"];
}

- (void)playbackStopped
{
    [PdBase closeFile:self.patch];
    [kTimer invalidate];
    kTimer = nil;
}

#pragma mark - PdListener

- (void)receiveFloat:(float)received fromSource:(NSString *)source
{
    if ([source isEqualToString:@"interval"]) {
        self.scopeViewController.timeInterval = received * 0.001;
        return;
    }
    
    if ([source isEqualToString:@"beat"]) {
        //[self.scopeViewController updateScope:received];
        return;
    }
    if ([source isEqualToString:@"clock"]) {
        //[self.scopeViewController setTime:received];
    }

    if ([source isEqualToString:@"clock"] && received == 0) {

        //[self changeSection];

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
