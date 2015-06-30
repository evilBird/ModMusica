//
//  ModEditorDefs.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/30/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#ifndef ModMusica_ModEditorDefs_h
#define ModMusica_ModEditorDefs_h

#import <Foundation/Foundation.h>
#import "MMPlaybackController.h"


#define INNERPADDING 2
#define OUTERPADDING 8
#define DEFAULT_PITCHES 25
#define DEFAULT_STEPS 64



@protocol ModEditorDatasource <NSObject>

- (NSUInteger)numSteps;
- (NSUInteger)numMeasures;
- (NSUInteger)beatsPerMeasure;
- (NSUInteger)divsPerBeat;
- (NSUInteger)currentSection;
- (MMPlaybackController *)playbackController;

@optional

- (NSUInteger)numPitches;
- (NSUInteger)currentVoiceIndex;
- (NSString *)currentModName;

@end

#endif
