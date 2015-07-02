//
//  MMRootViewController+Editor.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/30/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMRootViewController+Editor.h"
#import "ModMelodyEditorViewController.h"

@implementation MMRootViewController (Editor)

#pragma mark - MMModuleViewControllerDelegate

- (void)moduleViewEdit:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ModMelodyEditorViewController *editor = [storyboard instantiateViewControllerWithIdentifier:@"ModEditorRootViewController"];
    editor.mainColor = [self getGLKViewController].mainColor;
    editor.datasource = self;
    editor.delegate = self;
    [self playbackController].editing = YES;
    [self presentViewController:editor
                       animated:YES
                     completion:^{
                         [self getGLKViewController].paused = YES;
                     }];

}

#pragma mark - ModEditorDatasource

- (MMPlaybackController *)playbackController
{
    return [self getGLKViewController].playbackController;
}

- (NSUInteger)numSteps
{
    return [self numMeasures] * [self beatsPerMeasure] * [self divsPerBeat];
}

- (NSUInteger)numMeasures
{
    NSDictionary *header = [[self playbackController].patternLoader headerComponents];
    if (!header || ![header.allKeys containsObject:HEADER_NUM_MEASURES]) {
        return 0;
    }
    
    return [header[HEADER_NUM_MEASURES]integerValue];
}

- (NSUInteger)beatsPerMeasure
{
    NSDictionary *header = [[self playbackController].patternLoader headerComponents];
    if (!header || ![header.allKeys containsObject:HEADER_BEATS_PER_MEASURE]) {
        return 0;
    }
    
    return [header[HEADER_BEATS_PER_MEASURE]integerValue];
}

- (NSUInteger)divsPerBeat
{
    NSDictionary *header = [[self playbackController].patternLoader headerComponents];
    if (!header || ![header.allKeys containsObject:HEADER_DIVS_PER_BEAT]) {
        return 0;
    }
    
    return [header[HEADER_DIVS_PER_BEAT]integerValue];
}

- (NSUInteger)numPitches
{
    return DEFAULT_PITCHES;
}

- (NSUInteger)currentSection
{
    return [self playbackController].patternLoader.currentSection;
}

- (NSString *)currentModName
{
    return [self playbackController].patternLoader.currentPattern;
}

- (NSArray *)patternData
{
    return [[self playbackController].patternLoader patternData];
}

#pragma mark - ModMelodyEditorViewControllerDelegate

- (void)editor:(id)sender playbackChanged:(float)playback
{
    if (playback) {
        [self getGLKViewController].playing = YES;
    }else{
        [self getGLKViewController].playing = NO;
    }
}

- (void)updatePatternData:(NSArray *)patternData atVoiceIndex:(NSUInteger)voiceIndex
{
    NSMutableArray *data = [NSMutableArray array];
    [data addObject:@(voiceIndex)];
    [data addObjectsFromArray:patternData];
    [[self playbackController].patternLoader sendNotesToPd:data];
}

- (void)editorDidSave:(id)sender
{
    
}

- (void)editorDidClear:(id)sender
{
    
}

- (void)editorDidRevertToSaved:(id)sender
{
    
}

- (void)editorShouldClose:(id)editor completion:(void(^)(void))completion
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self playbackController].editing = NO;
        [self getGLKViewController].paused = NO;
        if (completion) {
            completion();
        }
    }];
}

@end
