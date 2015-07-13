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
#import "MMModuleManager.h"

static float kDrumVolume = 0.45;
static float kBassVolume = 0.26;
static float kSynthVolume = 0.25;
static float kSamplerVolume = 0.30;

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

- (void)setPlaying:(BOOL)playing
{
    if (playing != _playing) {
        [self sendPlaybackNotification:playing];
    }
    _playing = playing;
}

- (void)setAllowRandom:(BOOL)allowRandom
{
    _allowRandom = allowRandom;
    [PdBase sendFloat:(float)allowRandom toReceiver:@"allowRandom"];
}

- (void)sendPlaybackNotification:(BOOL)playback
{
    [[NSNotificationCenter defaultCenter]postNotificationName:kPlaybackDidChangeNotification object:nil userInfo:@{@"playback":@(playback)}];
}

- (void)handleAudioInterruption:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    AVAudioSessionInterruptionType type = [userInfo[AVAudioSessionInterruptionTypeKey]unsignedIntegerValue];
    AVAudioSessionInterruptionOptions options = [userInfo[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        [self stopPlayback];
    }else if (type == AVAudioSessionInterruptionTypeEnded && options == AVAudioSessionInterruptionOptionShouldResume){
        [self startPlayback];
    }
}

- (void)handleAudioRouteChange:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    AVAudioSessionRouteChangeReason reason = [userInfo[AVAudioSessionRouteChangeReasonKey]unsignedIntegerValue];
    if (reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        [PdBase sendFloat:0 toReceiver:@"inputVolume"];
    }else if (reason == AVAudioSessionRouteChangeReasonNewDeviceAvailable){
        [PdBase sendFloat:1 toReceiver:@"inputVolume"];
    }
    
    
}

- (void)addNotificationListeners
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleAudioRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleAudioInterruption:) name:AVAudioSessionInterruptionNotification object:nil];
}

- (void)removeNotificationListeners
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)setTempoLocked:(BOOL)tempoLocked
{
    _tempoLocked = tempoLocked;
    [PdBase sendFloat:(float)tempoLocked toReceiver:@"lockTempo"];
}

- (void)startPlayback
{
    if (!self.patternName) {
        self.patternName = [MMModuleManager purchasedModNames].firstObject;
    }
    
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
    self.probPatternChange = 10;
    self.probSectionChangeNone = 55;
    self.probSectionChangeNext = 35;
    self.probSectionChangePrevious = 10;
    kIdx = -1;
    kPrev = 0;
    [self initalizePd];
    [self addNotificationListeners];
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

- (void)openPatch
{
    self.patch = nil;
    NSString *patchName = @"modmusica_1.pd";
    self.patch = [PdBase openFile:patchName path:[[NSBundle mainBundle]resourcePath]];
}

- (void)setPatternName:(NSString *)patternName
{
    _patternName = patternName;
    self.patternLoader.currentPattern = patternName;
    self.patternLoader.currentSection = -1;
}

- (void)playPattern:(NSString *)patternName
{
    self.patternName = patternName;
    [self.patternLoader playSection:0];
    [self.delegate playback:self didLoadModuleName:patternName];
    
    if (!self.isPlaying) {
        [self startPlayback];
    }
}

- (void)tapTempo
{
    [PdBase sendBangToReceiver:@"tapTempo"];
}

- (void)changeSectionMaybe
{
    if (!self.allowsRandom) {
        return;
    }
    
    NSInteger rand = arc4random_uniform(100);
    
    if (self.isShuffled) {
        if (rand < self.probPatternChange) {
            NSArray *mods = [MMModuleManager purchasedModNames];
            NSUInteger idx = (NSUInteger)((int)arc4random_uniform(100)%(int)mods.count);
            NSString *pattern = mods[idx];
            [self playPattern:pattern];
            return;
        }
    }
    
    if (rand > self.probSectionChangeNone && rand <= (100 - self.probSectionChangePrevious)) {
        [self.patternLoader playNextSection];
    }else if (rand > (100 - self.probSectionChangePrevious)){
        [self.patternLoader playPreviousSection];
    }
}

- (void)setInstrumentLevelsOn
{
    [PdBase sendFloat:1 toReceiver:@"audioSwitch"];
    [PdBase sendFloat:1 toReceiver:@"outputVolume"];
    [PdBase sendFloat:1 toReceiver:@"inputVolume"];
    [PdBase sendFloat:kDrumVolume toReceiver:@"drumsVolume"];
    [PdBase sendFloat:kSynthVolume toReceiver:@"synthVolume"];
    [PdBase sendFloat:kSamplerVolume toReceiver:@"samplerVolume"];
    [PdBase sendFloat:kBassVolume toReceiver:@"bassVolume"];
    [PdBase sendBangToReceiver:@"loadNewSamples"];
}

- (void)setInstrumentLevelsOff
{
    [PdBase sendFloat:0.0 toReceiver:@"outputVolume"];
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
        if (!self.isTempoLocked) {
            [self.delegate playback:self detectedUserTempo:received];
        }
    }
}

- (void)dealloc
{
    [self closePd];
    [self removeNotificationListeners];
}

@end
