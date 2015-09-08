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
    float kInputVol;
    
}

@property (nonatomic,strong)                    NSString                *currentModName;
@property (nonatomic,strong)                    NSString                *previousModName;
@property (nonatomic)                           BOOL                    playbackState;

@end

void expr_tilde_setup(void);
void fiddle_tilde_setup(void);
void expr_setup(void);
void helmholtz_tilde_setup(void);
void bonk_tilde_setup(void);
void mm_textfile_setup(void);

@implementation MMPlaybackController

#pragma mark - Notification handlers

#pragma mark - Audio Routing Notification Handlers

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
        kInputVol = 0;
        [PdBase sendFloat:kInputVol toReceiver:INPUT_VOL];
    }else if (reason == AVAudioSessionRouteChangeReasonNewDeviceAvailable){
        kInputVol = 1;
        [PdBase sendFloat:kInputVol toReceiver:INPUT_VOL];
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

#pragma mark - Public Methods

- (void)startPlayback
{
    if (self.isPlaying || !self.isReady) {
        return;
    }
    
    [self startPlaybackNow];
}

- (void)stopPlayback
{
    if (!self.isPlaying || !self.isReady) {
        return;
    }
    
    [self stopPlaybackNow];
}

- (BOOL)isPlaying
{
    return self.playbackState;
}

- (NSString *)modName
{
    return self.currentModName;
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

- (void)preparePlaybackForMod:(NSString *)modName completion:(void(^)(BOOL success))completion
{
    self.currentModName = modName;
    if (self.previousModName && [modName isEqualToString:self.previousModName]) {
        self.ready = YES;
    }else{
        self.ready = NO;
        self.ready = [self loadResources];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(self.ready);
    });
}

#pragma mark - Private Methods

- (void)startPlaybackNow
{
    [PdBase sendFloat:1 toReceiver:AUDIO_SWITCH];
    [PdBase sendFloat:1 toReceiver:OUTPUT_VOL];
    [PdBase sendFloat:1 toReceiver:INPUT_VOL];
    [PdBase sendFloat:1 toReceiver:ON_OFF];
    [self setInitialPdVariables];
    self.playbackState = YES;
    [self.delegate playbackBegan:self];
}

- (void)stopPlaybackNow
{
    [PdBase sendFloat:0 toReceiver:OUTPUT_VOL];
    [PdBase sendFloat:0 toReceiver:INPUT_VOL];
    [PdBase sendFloat:0 toReceiver:ON_OFF];
    [PdBase sendFloat:0 toReceiver:AUDIO_SWITCH];
    self.playbackState = NO;
    [self.delegate playbackEnded:self];
}

- (void)setCurrentModName:(NSString *)currentModName
{
    self.previousModName = _currentModName;
    _currentModName = currentModName;
}

- (void)setPlaybackState:(BOOL)playbackState
{
    _playbackState = playbackState;
    [self sendPlaybackNotification:_playbackState];
}


#pragma mark - constructors

- (void)setInitialPdVariables
{
    self.allowRandom = YES;
    self.tempoLocked = NO;
    self.shuffleMods = NO;
}

- (void)commonInit
{
    _allowRandom = NO;
    _shuffleMods = NO;
    _tempoLocked = NO;
    _playbackState = NO;
    _ready = NO;
    _patchIsOpen = NO;
    kInputVol = 1.0;
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

#pragma mark - Pd Setup

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
    [self.dispatcher addListener:self forSource:ON_OFF];
}

#pragma mark - Pd Teardown

- (void)closePd
{
    [self closePatch:self.modName];
    [self unsubscribePdMessages];
}

- (void)unsubscribePdMessages
{
    [self.dispatcher removeListener:self forSource:DETECTED_TEMPO];
    [self.dispatcher removeListener:self forSource:CLOCK];
    [self.dispatcher removeListener:self forSource:ON_OFF];
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

- (void)tearDown
{
    [self stopPlaybackNow];
    [self closePd];
    [self removeNotificationListeners];
    self.delegate = nil;
    self.patch = nil;
    self.currentModName = nil;
    self.previousModName = nil;
}

- (void)dealloc
{
    [self closePd];
    [self removeNotificationListeners];
}

@end
