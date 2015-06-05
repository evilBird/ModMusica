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


@interface MMPlaybackController : NSObject

@property (nonatomic,strong)        PdDispatcher            *dispatcher;
@property (nonatomic,strong)        MMPatternLoader         *patternLoader;
@property void *patch;

- (void)startPlayback;
- (void)stopPlayback;

@end
