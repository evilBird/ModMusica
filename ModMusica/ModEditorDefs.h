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
#import <UIKit/UIKit.h>
#import "MMPlaybackController.h"


#define INNERPADDING 2
#define OUTERPADDING 8
#define DEFAULT_PITCHES 25
//#define DEFAULT_STEPS 64

#define HEADER_NUM_MEASURES @"measures"
#define HEADER_DIVS_PER_BEAT @"divisions"
#define HEADER_BEATS_PER_MEASURE @"beats"
#define HEADER_SWING @"swing"
#define HEADER_MAX_TEMPO @"maxTempo"
#define HEADER_MIN_TEMPO @"minTempo"


@protocol ModEditorViewControllerDelegate <NSObject>

@optional
- (void)editor:(id)sender playbackChanged:(float)playback;
- (void)editorDidSave:(id)sender;
- (void)editorDidRevertToSaved:(id)sender;
- (void)editorShouldClose:(id)sender completion:(void(^)(void))completion;
- (void)updatePatternData:(NSArray *)patternData atVoiceIndex:(NSUInteger)voiceIndex;
- (NSUInteger)currentVoiceIndex;

@end

@protocol ModMelodyEditorStepPitchViewDelegate <NSObject>

- (UIColor *)myMainColor;
- (NSUInteger)initialValueForSwitchWithTag:(NSUInteger)tag;
- (void)melodyEditor:(id)sender stepSwitch:(id)stepSwitch valueDidChange:(id)value;

@end

@protocol ModEditorDatasource <NSObject>

- (NSUInteger)numSteps;
- (NSUInteger)numMeasures;
- (NSUInteger)beatsPerMeasure;
- (NSUInteger)divsPerBeat;
- (NSUInteger)currentSection;
- (NSArray *)patternData;
- (MMPlaybackController *)playbackController;

@optional

- (NSUInteger)numPitches;
- (NSString *)currentModName;

@end

#endif
