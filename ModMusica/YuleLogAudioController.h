//
//  YuleLogAudioController.h
//  ModMusica
//
//  Created by Travis Henspeter on 12/21/14.
//  Copyright (c) 2014 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YuleLogAudioControllerDelegate <NSObject>



@end

@interface YuleLogAudioController : NSObject

@property (nonatomic,readonly)BOOL isPlaying;

- (void)initializeAudio;
- (void)tearDown;
- (void)startPlayback;
- (void)stopPlayback;

@end
