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

#pragma mark - accessors

- (void)setCurrentModName:(NSString *)currentModName
{
    NSString *prevModName = _currentModName;
    _currentModName = currentModName;
    
    if ([_currentModName isEqualToString:prevModName]) {
        self.ready = YES;
        return;
    }
    
    [self loadModuleName:_currentModName];
}

- (void)setReady:(BOOL)ready
{
    _ready = ready;
    if (_ready && self.isWaiting) {
        self.waiting = NO;
        [self startPlaybackNow];
        [self.delegate playbackBegan:self];
    }
}

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

- (void)loadModuleName:(NSString *)modName
{
    __weak MMPlaybackController *weakself = self;
    self.ready = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself loadResourcesForModName:modName completion:^{
            weakself.ready = YES;
            NSLog(@"finished loading mod %@",modName);
        }];
    });
}

- (void)startPlayback
{
    if (self.isPlaying || self.isWaiting) {
        return;
    }
    
    if (self.isReady) {
        [self startPlaybackNow];
    }else{
        self.waiting = YES;
    }
}

- (void)startPlaybackNow
{
    [PdBase sendFloat:1 toReceiver:OUTPUT_VOL];
    [PdBase sendFloat:kInputVol toReceiver:INPUT_VOL];
    [PdBase sendFloat:1 toReceiver:AUDIO_SWITCH];
    [PdBase sendFloat:1 toReceiver:ON_OFF];
    self.playing = YES;
    [self.delegate playbackBegan:self];
}

- (void)stopPlayback
{
    if (!self.isPlaying || self.isWaiting) {
        return;
    }

    [self stopPlaybackNow];
}


- (void)stopPlaybackNow
{
    [PdBase sendFloat:0 toReceiver:OUTPUT_VOL];
    [PdBase sendFloat:0 toReceiver:INPUT_VOL];
    [PdBase sendFloat:0 toReceiver:ON_OFF];
    [PdBase sendFloat:0 toReceiver:AUDIO_SWITCH];
    self.playing = NO;
    [self.delegate playbackEnded:self];
}

#pragma mark - constructors

- (void)commonInit
{
    _allowRandom = YES;
    _shuffleMods = NO;
    _tempoLocked = NO;
    _ready = NO;
    _waiting = NO;
    _patchIsOpen = NO;
    _playing = NO;
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
    [self.dispatcher addListener:self forSource:ON_OFF];
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
    [self.dispatcher removeListener:self forSource:ON_OFF];

    self.dispatcher = nil;
}

#pragma mark - Pd Patch management

- (void)setInstrumentLevelsOn
{
    //[PdBase sendFloat:1 toReceiver:OUTPUT_VOL];
}

- (void)setInstrumentLevelsOff
{
    //[PdBase sendFloat:0.0 toReceiver:OUTPUT_VOL];
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
