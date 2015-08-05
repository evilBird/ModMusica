//
//  MMPlaybackController.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/5/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PdBase.h>
#import <PdAudioController.h>
#import <PdDispatcher.h>
#import "MMPatternLoader.h"

static NSString *kPlaybackDidChangeNotification = @"com.birdSound.ModMusica.playbackDidChange";

@protocol MMPlaybackDelegate
@optional

- (void)playback:(id)sender clockDidChange:(NSInteger)clock;
- (void)playbackBegan:(id)sender;
- (void)playbackEnded:(id)sender;
- (void)playback:(id)sender detectedUserTempo:(double)tempo;
- (void)playback:(id)sender didLoadModuleName:(NSString *)moduleName;

@end

@interface MMPlaybackController : NSObject

@property (nonatomic,weak)                      id<MMPlaybackDelegate>  delegate;
@property (nonatomic,strong)                    PdDispatcher            *dispatcher;
//@property (nonatomic,strong)                    MMPatternLoader         *patternLoader;

@property (nonatomic,strong)                    NSString                *currentModName;
@property                                       void                    *patch;
@property (nonatomic, getter=isPlaying)         BOOL                    playing;
@property (nonatomic, getter=isShuffled)        BOOL                    shuffleMods;
@property (nonatomic, getter=isTempoLocked)     BOOL                    tempoLocked;
@property (nonatomic, getter=allowsRandom)      BOOL                    allowRandom;
@property (nonatomic, getter=isReady)           BOOL                    ready;
@property (nonatomic, getter=isWaiting)         BOOL                    waiting;
@property (nonatomic)                           BOOL                    patchIsOpen;

//- (void)playPattern:(NSString *)patternName;

- (void)startPlayback;
- (void)stopPlayback;
- (void)tapTempo;

//- (void)setInstrumentLevelsOn;
//- (void)setInstrumentLevelsOff;

@end
