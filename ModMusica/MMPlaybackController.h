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

@end

@interface MMPlaybackController : NSObject

@property (nonatomic,weak)                      id<MMPlaybackDelegate>  delegate;
@property (nonatomic,strong)                    PdDispatcher            *dispatcher;
@property (nonatomic,strong)                    MMPatternLoader         *patternLoader;
@property (nonatomic,strong)                    NSString                *patternName;
@property                                       void                    *patch;
@property (nonatomic,getter=isPlaying)          BOOL                    playing;
@property (nonatomic,getter=isShuffled)         BOOL                    shuffleMods;
@property (nonatomic, getter=isTempoLocked)     BOOL                    tempoLocked;

- (void)startPlayback;
- (void)stopPlayback;
- (void)playPattern:(NSString *)patternName;
- (void)tapTempo;

@end
