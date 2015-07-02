//
//  ModMelodyEditorViewController+Switches.h
//  ModMusica
//
//  Created by Travis Henspeter on 7/2/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ModMelodyEditorViewController.h"

@interface ModMelodyEditorViewController (Switches)<ModMelodyEditorStepPitchViewDelegate>

- (NSInteger)switchIndexFromPitch:(NSInteger)pitch step:(NSInteger)step;
- (NSInteger)pitchFromSwitchIndex:(NSInteger)index step:(NSInteger)step;

#pragma mark - ModMelodyEditorStepPitchViewDelegate
- (UIColor *)myMainColor;
- (void)melodyEditor:(id)sender stepSwitch:(id)stepSwitch valueDidChange:(id)value;
- (NSUInteger)initialValueForSwitchWithTag:(NSUInteger)tag;
- (double)fontScaleForStepLabelAtIndex:(NSUInteger)index;
- (NSString *)textForStepLabelAtIndex:(NSUInteger)index;
- (NSString *)textForPitchLabelAtIndex:(NSUInteger)index;
- (NSString *)textForPitch:(NSInteger)pitch;

@end
