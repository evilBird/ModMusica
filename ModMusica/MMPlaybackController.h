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

@protocol MMPlaybackDelegate

- (void)playback:(id)sender clockDidChange:(NSInteger)clock;

@end

@interface MMPlaybackController : NSObject

@property (nonatomic,weak)                  id<MMPlaybackDelegate>  delegate;
@property (nonatomic,strong)                PdDispatcher            *dispatcher;
@property (nonatomic,strong)                MMPatternLoader         *patternLoader;
@property                                   void                    *patch;
@property (nonatomic,getter=isPlaying)      BOOL                    playing;

- (void)startPlayback;
- (void)stopPlayback;

@end
