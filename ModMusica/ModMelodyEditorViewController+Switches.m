//
//  ModMelodyEditorViewController+Switches.m
//  ModMusica
//
//  Created by Travis Henspeter on 7/2/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ModMelodyEditorViewController+Switches.h"
#import "UIColor+HBVHarmonies.h"

@implementation ModMelodyEditorViewController (Switches)

- (NSInteger)switchIndexFromPitch:(NSInteger)pitch step:(NSInteger)step
{
    if (pitch <= 0) {
        return -1;
    }
    
    NSInteger offsetPitch = pitch - self.minPitch;
    NSInteger maxRow = [self.datasource numPitches] - 1;
    NSInteger reflectedPitch = maxRow - offsetPitch;
    NSInteger switchIndex = reflectedPitch * [self.datasource numSteps] + step;
    return switchIndex;
}

- (NSInteger)pitchFromSwitchIndex:(NSInteger)index step:(NSInteger)step
{
    if (index < 0) {
        return 0;
    }
    
    NSInteger row = index/[self.datasource numSteps];
    NSInteger maxRow = [self.datasource numPitches] - 1;
    NSInteger reflectedRow = maxRow - row;
    NSInteger offsetPitch = reflectedRow + self.minPitch;
    
    return offsetPitch;
}

#pragma mark - ModMelodyEditorStepPitchViewDelegate
#pragma mark - ModMelodyEditorStepPitchViewDelegate

- (UIColor *)myMainColor
{
    return [self.mainColor complement];
}

- (void)melodyEditor:(id)sender stepSwitch:(id)stepSwitch valueDidChange:(id)value
{
    ModMelodyEditorSwitch *theSwitch = stepSwitch;
    NSUInteger stepIndex = (NSUInteger)((int)theSwitch.tag)%((int)[self.datasource numSteps]);
    NSUInteger val = [value unsignedIntegerValue];
    if (val) {
        NSNumber *oldTag = self.stepPitchTags[stepIndex];
        if (oldTag.integerValue != -1 && oldTag.integerValue!=theSwitch.tag) {
            ModMelodyEditorSwitch *oldSwitch = self.pitchView.switches[oldTag.unsignedIntegerValue];
            oldSwitch.value = 0;
        }
        self.stepPitchTags[stepIndex] = @(theSwitch.tag);
    }else{
        self.stepPitchTags[stepIndex] = @(-1);
    }
    
    [self stepPitchTagsDidChange];
}

- (NSUInteger)initialValueForSwitchWithTag:(NSUInteger)tag
{
    NSUInteger stepIndex = (NSUInteger)((int)tag)%((int)[self.datasource numSteps]);
    NSNumber *oldTag = self.stepPitchTags[stepIndex];
    if (tag == oldTag.unsignedIntegerValue) {
        return 1;
    }
    return 0;
}

- (double)fontScaleForStepLabelAtIndex:(NSUInteger)index
{
    int idx = (int)(index - 1);
    int beatsPerMeasure = (int)[self.datasource beatsPerMeasure];
    int stepsPerBeat = (int)[self.datasource divsPerBeat];
    int stepsPerMeasure = beatsPerMeasure * stepsPerBeat;
    if (idx%stepsPerMeasure == 0) {
        return 1.0;
    }else if (idx%stepsPerBeat == 0){
        return 0.6;
    }
    return 0.0;
}

- (NSString *)textForStepLabelAtIndex:(NSUInteger)index
{
    int value = 0;
    int idx = (int)(index - 1);
    int beatsPerMeasure = (int)[self.datasource beatsPerMeasure];
    int stepsPerBeat = (int)[self.datasource divsPerBeat];
    int stepsPerMeasure = beatsPerMeasure * stepsPerBeat;
    int measure = idx/stepsPerMeasure;
    int beat = (idx%stepsPerMeasure)/stepsPerBeat;
    if (idx%stepsPerMeasure == 0) {
        value = measure + 1;
    }else if (idx%stepsPerBeat == 0){
        value = beat + 1;
    }
    
    if (value > 0) {
        return [NSString stringWithFormat:@"%d",value];
    }
    
    return @" ";
}

- (NSString *)textForPitchLabelAtIndex:(NSUInteger)index
{
    NSInteger invertedIndex = [self.datasource numPitches] - index - 1;
    NSInteger pitch = self.minPitch + invertedIndex;
    return [self textForPitch:pitch];
}

- (NSString *)textForPitch:(NSInteger)pitch
{
    NSArray *notes = @[@"C",@"C#",@"D",@"D#",@"E",@"F",@"F#",@"G",@"G#",@"A",@"A#",@"B"];
    int idx = ((int)pitch)%12;
    int num = ((int)pitch)/12;
    NSString *note = notes[idx];
    NSString *text = [NSString stringWithFormat:@"%@%@",note,@(num)];
    return text;
}


@end
