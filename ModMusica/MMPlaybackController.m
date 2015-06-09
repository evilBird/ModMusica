//
//  MMPlaybackController.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/5/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMPlaybackController.h"
#import <PdBase.h>
#import <PdAudioController.h>
#import <PdDispatcher.h>
#import "MMScopeDataSource.h"

@interface MMPlaybackController () <PdListener>
{
    NSInteger kIdx;
    float kPrev;
}

@property (nonatomic,strong)            NSArray             *patterns;

@end

void expr_tilde_setup(void);
void fiddle_tilde_setup(void);
void expr_setup(void);
void helmholtz_tilde_setup(void);
void bonk_tilde_setup(void);

@implementation MMPlaybackController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)startPlayback
{
    [self playbackWillStart];
    [self startNow];
    [self.delegate playbackBegan:self];
}

- (void)stopPlayback
{
    [self stopNow];
    [self playbackDidStop];
    [self.delegate playbackEnded:self];
}

- (void)playbackWillStart
{
    [self changeEverything];
    [self setInstrumentLevelsOn];
    [self.patternLoader playNextSection];
}

- (void)startNow
{
    [PdBase sendFloat:1 toReceiver:@"onOff"];
    self.playing = YES;
}

- (void)playbackDidStop
{
    [self setInstrumentLevelsOff];
}

- (void)stopNow
{
    [PdBase sendFloat:0 toReceiver:@"onOff"];
    self.playing = NO;
    kPrev = 0;
    kIdx = -1;
}

- (void)commonInit
{
    self.patternLoader = [[MMPatternLoader alloc]init];
    self.patterns = @[@"mario",@"fantasy",@"mega",@"menace"];
    kIdx = -1;
    kPrev = 0;
    [self initalizePd];
}

- (void)initalizePd
{
    [self setupPdExternals];
    [self subscribeToPdMessages];
    [self openPatch];
}

- (void)setupPdExternals
{
    expr_tilde_setup();
    fiddle_tilde_setup();
    expr_setup();
    bonk_tilde_setup();
    helmholtz_tilde_setup();
}

- (void)subscribeToPdMessages
{
    self.dispatcher = [[PdDispatcher alloc]init];
    [PdBase setDelegate:self.dispatcher];
    [self.dispatcher addListener:self forSource:@"detectedTempo"];
    [self.dispatcher addListener:self forSource:@"interval"];
    [self.dispatcher addListener:self forSource:@"beat"];
    [self.dispatcher addListener:self forSource:@"clock"];
}

- (void)closePd
{
    if (self.patch != NULL) {
        [PdBase closeFile:self.patch];
    }
    [self unsubscribePdMessages];
    
}

- (void)unsubscribePdMessages
{
    [self.dispatcher removeListener:self forSource:@"detectedTempo"];
    [self.dispatcher removeListener:self forSource:@"interval"];
    [self.dispatcher removeListener:self forSource:@"beat"];
    [self.dispatcher removeListener:self forSource:@"clock"];
    self.dispatcher = nil;
}

- (void)changeEverything
{
    kIdx ++;
    [self changePattern];
    [self changeSectionMaybe];
}

- (void)openPatch
{
    self.patch = nil;
    NSString *patchName = @"modmusica_1.pd";
    self.patch = [PdBase openFile:patchName path:[[NSBundle mainBundle]resourcePath]];
}

- (void)changePattern
{
    NSInteger newPattern = arc4random_uniform((int)self.patterns.count);
    NSString *pattern = self.patterns[newPattern];
    self.patternLoader.currentPattern = pattern;
    NSLog(@"\n\nSelected pattern: %@\n\n",pattern);
    self.patternLoader.currentSection = -1;
}

- (void)changeSectionMaybe
{
    NSInteger rand = arc4random_uniform(100);
    if (rand > 80 && rand <= 94) {
        [self.patternLoader playNextSection];
    }else if (rand > 94){
        [self.patternLoader playPreviousSection];
    }
}

- (void)setInstrumentLevelsOn
{
    [PdBase sendFloat:1 toReceiver:@"audioSwitch"];
    [PdBase sendFloat:1 toReceiver:@"outputVolume"];
    [PdBase sendFloat:1 toReceiver:@"inputVolume"];
    [PdBase sendFloat:0.25 toReceiver:@"drumsVolume"];
    [PdBase sendFloat:0.25 toReceiver:@"synthVolume"];
    [PdBase sendFloat:0.25 toReceiver:@"samplerVolume"];
    [PdBase sendFloat:0.25 toReceiver:@"bassVolume"];
    [PdBase sendBangToReceiver:@"loadNewSamples"];
}

- (void)setInstrumentLevelsOff
{
    [PdBase sendFloat:0 toReceiver:@"outputVolume"];
    [PdBase sendFloat:0.0 toReceiver:@"drumsVolume"];
    [PdBase sendFloat:0.0 toReceiver:@"inputVolume"];
    [PdBase sendFloat:0.0 toReceiver:@"synthVolume"];
    [PdBase sendFloat:0.0 toReceiver:@"samplerVolume"];
    [PdBase sendFloat:0.0 toReceiver:@"bassVolume"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [PdBase sendFloat:0 toReceiver:@"audioSwitch"];
    });
}

#pragma mark - PdListener

- (void)receiveFloat:(float)received fromSource:(NSString *)source
{
    if ([source isEqualToString:@"clock"]) {
        [self.delegate playback:self clockDidChange:(NSInteger)received];
        if (received==0) {
            [self changeSectionMaybe];
        }
    }else if ([source isEqualToString:@"detectedTempo"]){
        [self.delegate playback:self detectedUserTempo:received];
    }
}

- (void)dealloc
{
    [self closePd];
}

@end
