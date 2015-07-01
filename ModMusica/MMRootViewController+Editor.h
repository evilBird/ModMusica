//
//  MMRootViewController+Editor.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/30/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMRootViewController.h"
#import "ModEditorDefs.h"
#import "MMModuleViewController.h"

@interface MMRootViewController (Editor)<ModEditorDatasource,MMModuleViewControllerDelegate,ModEditorViewControllerDelegate>

#pragma mrak - ModEditorDataSource

- (NSUInteger)numSteps;
- (NSUInteger)numMeasures;
- (NSUInteger)beatsPerMeasure;
- (NSUInteger)divsPerBeat;
- (MMPlaybackController *)playbackController;
- (NSUInteger)numPitches;
- (NSUInteger)currentVoiceIndex;
- (NSUInteger)currentSection;
- (NSString *)currentModName;
- (NSArray *)patternData;
- (void)updatePatternData:(NSArray *)patternData;

#pragma mark - MMModuleViewControllerDelegate
- (void)moduleViewEdit:(id)sender;

#pragma mark - ModMelodyEditorViewControllerDelegate

- (void)editor:(id)sender playbackChanged:(float)playback;
- (void)editorDidSave:(id)sender;
- (void)editorDidClear:(id)sender;
- (void)editorDidRevertToSaved:(id)sender;
- (void)editorShouldClose:(id)editor completion:(void(^)(void))completion;

@end
