//
//  ModMelodyEditorViewController+Data.h
//  ModMusica
//
//  Created by Travis Henspeter on 7/2/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ModMelodyEditorViewController.h"

@interface ModMelodyEditorViewController (Data)

- (void)setupStepPitchTags;
- (void)setupStepPitchTags:(NSArray *)data;
- (NSArray *)editedData;
- (NSArray *)formattedEditedData;
- (NSArray *)getSavedData;
- (NSArray *)getSavedDataVoice:(NSUInteger)voiceIndex;
- (NSUInteger)maxPitchInData:(NSArray *)data;
- (NSUInteger)minPitchInData:(NSArray *)data;
- (NSArray *)stepPitchTagsWithData:(NSArray *)data;

@end
