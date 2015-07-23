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
#import "ModMusicaDefs.h"
#import "MMPlaybackController+ResourceLoader.h"

@interface MMPlaybackController () <PdListener>
{
}

@end

void expr_tilde_setup(void);
void fiddle_tilde_setup(void);
void expr_setup(void);
void helmholtz_tilde_setup(void);
void bonk_tilde_setup(void);

@implementation MMPlaybackController

#pragma mark - Notification handlers

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
        [PdBase sendFloat:0 toReceiver:INPUT_VOL];
    }else if (reason == AVAudioSessionRouteChangeReasonNewDeviceAvailable){
        [PdBase sendFloat:1 toReceiver:INPUT_VOL];
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

#pragma mark - accessors

- (void)setPlaying:(BOOL)playing
{
    _playing = playing;
    [self sendPlaybackNotification:playing];
}

- (void)setAllowRandom:(BOOL)allowRandom
{
    _allowRandom = allowRandom;
    [PdBase sendFloat:(float)allowRandom toReceiver:ALLOW_RANDOM];
}

- (void)setTempoLocked:(BOOL)tempoLocked
{
    _tempoLocked = tempoLocked;
    [PdBase sendFloat:(float)tempoLocked toReceiver:LOCK_TEMPO];
}

- (void)tapTempo
{
    [PdBase sendBangToReceiver:TAP_TEMPO];
}

#pragma mark - Playback

- (void)playPattern:(NSString *)patternName
{
    NSString *prevModName = self.patternName;
    self.patternName = patternName;
    if (!prevModName || ![self.patternName isEqualToString:prevModName]) {
        __weak MMPlaybackController *weakself = self;
        [[NSOperationQueue new]addOperationWithBlock:^{
            [weakself loadResourcesForModName:self.patternName completion:^{
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    [weakself.patternLoader playSection:0];
                    [weakself.delegate playback:self didLoadModuleName:patternName];
                    if (!weakself.isPlaying) {
                        [weakself startPlayback];
                    }
                }];
            }];
        }];
    }
}

- (void)startPlayback
{
    if (self.isPlaying || !self.patternName) {
        return;
    }
    [self playbackWillStart];
    [self startNow];
    [self.delegate playbackBegan:self];
}

- (void)stopPlayback
{
    if (!self.isPlaying) {
        return;
    }
    
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
    [PdBase sendFloat:1 toReceiver:ON_OFF];
    self.playing = YES;
}

- (void)playbackDidStop
{
    [self setInstrumentLevelsOff];
}

- (void)stopNow
{
    [PdBase sendFloat:0 toReceiver:ON_OFF];
    self.playing = NO;
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

#pragma mark - constructors

- (void)commonInit
{
    self.patternLoader = [[MMPatternLoader alloc]init];
    self.probPatternChange = kProbPatternChangeDefault;
    self.probSectionChangeNone = kProbSectionChangeNoneDefault;
    self.probSectionChangeNext = kProbSectionChangeNextDefault;
    self.probSectionChangePrevious = kProbSectionChangePreviousDefault;
    _allowRandom = YES;
    _shuffleMods = NO;
    _tempoLocked = NO;
    _playing = NO;
    [self initalizePd];
    [self addNotificationListeners];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

#pragma mark - initializers

- (void)initalizePd
{
    [self setupPdExternals];
    [self subscribeToPdMessages];
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
    [self.dispatcher addListener:self forSource:DETECTED_TEMPO];
    [self.dispatcher addListener:self forSource:DETECTED_INTERVAL];
    [self.dispatcher addListener:self forSource:DETECTED_BEAT];
    [self.dispatcher addListener:self forSource:CLOCK];
}

#pragma mark - deinitializers

- (void)closePd
{
    [self closePatch];
    [self unsubscribePdMessages];
}

- (void)unsubscribePdMessages
{
    [self.dispatcher removeListener:self forSource:DETECTED_TEMPO];
    [self.dispatcher removeListener:self forSource:DETECTED_INTERVAL];
    [self.dispatcher removeListener:self forSource:DETECTED_BEAT];
    [self.dispatcher removeListener:self forSource:CLOCK];
    self.dispatcher = nil;
}

#pragma mark - Pd Patch management

- (void)setInstrumentLevelsOn
{
    [PdBase sendFloat:1 toReceiver:AUDIO_SWITCH];
    [PdBase sendFloat:1 toReceiver:OUTPUT_VOL];
    [PdBase sendFloat:1 toReceiver:INPUT_VOL];
    [PdBase sendFloat:kDrumVolume toReceiver:DRUM_VOL];
    [PdBase sendFloat:kSynthVolume toReceiver:SYNTH_VOL];
    [PdBase sendFloat:kSamplerVolume toReceiver:SAMPLER_VOL];
    [PdBase sendFloat:kBassVolume toReceiver:BASS_VOL];
}

- (void)setInstrumentLevelsOff
{
    [PdBase sendFloat:0.0 toReceiver:OUTPUT_VOL];
    [PdBase sendFloat:0.0 toReceiver:DRUM_VOL];
    [PdBase sendFloat:0.0 toReceiver:INPUT_VOL];
    [PdBase sendFloat:0.0 toReceiver:SYNTH_VOL];
    [PdBase sendFloat:0.0 toReceiver:SAMPLER_VOL];
    [PdBase sendFloat:0.0 toReceiver:BASS_VOL];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [PdBase sendFloat:0 toReceiver:AUDIO_SWITCH];
    });
}

#pragma mark - PdListener

- (void)receiveFloat:(float)received fromSource:(NSString *)source
{
    if ([source isEqualToString:CLOCK]) {
        [self.delegate playback:self clockDidChange:(NSInteger)received];
        if (received==0) {
            [self changeSectionMaybe];
        }
    }else if ([source isEqualToString:DETECTED_TEMPO]){
        if (!self.isTempoLocked) {
            [self.delegate playback:self detectedUserTempo:received];
        }
    }
}

#pragma mark - dealloc

- (void)dealloc
{
    [self closePd];
    [self removeNotificationListeners];
}

@end
