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
void mm_textfile_setup(void);

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
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            [weakself loadResourcesForModName:self.patternName completion:^{
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    [weakself.delegate playback:self didLoadModuleName:patternName];

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
    [self startNow];
    [self.delegate playbackBegan:self];
}

- (void)stopPlayback
{
    if (!self.isPlaying) {
        return;
    }
    
    [self stopNow];
    [self.delegate playbackEnded:self];
}

- (void)startNow
{
    [PdBase sendFloat:1 toReceiver:OUTPUT_VOL];
    [PdBase sendFloat:1 toReceiver:AUDIO_SWITCH];
    [PdBase sendFloat:1 toReceiver:ON_OFF];
    self.playing = YES;
}

- (void)stopNow
{
    [PdBase sendFloat:0 toReceiver:OUTPUT_VOL];
    [PdBase sendFloat:0 toReceiver:ON_OFF];
    [PdBase sendFloat:0 toReceiver:AUDIO_SWITCH];
    self.playing = NO;
}

#pragma mark - constructors

- (void)commonInit
{
    self.probPatternChange = kProbPatternChangeDefault;
    self.probSectionChangeNone = kProbSectionChangeNoneDefault;
    self.probSectionChangeNext = kProbSectionChangeNextDefault;
    self.probSectionChangePrevious = kProbSectionChangePreviousDefault;
    self.allowRandom = YES;
    self.shuffleMods = NO;
    self.tempoLocked = NO;
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
    mm_textfile_setup();
}

- (void)subscribeToPdMessages
{
    self.dispatcher = [[PdDispatcher alloc]init];
    [PdBase setDelegate:self.dispatcher];
    [self.dispatcher addListener:self forSource:DETECTED_TEMPO];
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
    [self.dispatcher removeListener:self forSource:CLOCK];
    self.dispatcher = nil;
}

#pragma mark - Pd Patch management

- (void)setInstrumentLevelsOn
{
    [PdBase sendFloat:1 toReceiver:OUTPUT_VOL];
}

- (void)setInstrumentLevelsOff
{
    [PdBase sendFloat:0.0 toReceiver:OUTPUT_VOL];
}

#pragma mark - PdListener
- (void)receiveFloat:(float)received fromSource:(NSString *)source
{
    if ([source isEqualToString:CLOCK]) {
        [self.delegate playback:self clockDidChange:(NSInteger)received];
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
