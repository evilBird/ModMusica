//
//  MMRootViewController+Editor.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/30/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMRootViewController.h"
#import "ModEditorDefs.h"

@interface MMRootViewController (Editor)<ModEditorDatasource>

- (NSUInteger)numSteps;
- (NSUInteger)numMeasures;
- (NSUInteger)beatsPerMeasure;
- (NSUInteger)divsPerBeat;
- (MMPlaybackController *)playbackController;
- (NSUInteger)numPitches;
- (NSUInteger)currentSection;
- (NSString *)currentModName;

@end
