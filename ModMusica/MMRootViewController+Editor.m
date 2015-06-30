//
//  MMRootViewController+Editor.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/30/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMRootViewController+Editor.h"

@implementation MMRootViewController (Editor)

- (MMPlaybackController *)playbackController
{
    return [self getGLKViewController].playbackController;
}

- (NSUInteger)numSteps
{
    NSDictionary *header = [[self playbackController].patternLoader headerComponents];
    return 64;
    
}
- (NSUInteger)numMeasures
{
    NSDictionary *header = [[self playbackController].patternLoader headerComponents];
    return 4;
}
- (NSUInteger)beatsPerMeasure
{
    NSDictionary *header = [[self playbackController].patternLoader headerComponents];
    return 4;
}
- (NSUInteger)divsPerBeat
{
    NSDictionary *header = [[self playbackController].patternLoader headerComponents];
    return 4;
}

- (NSUInteger)numPitches
{
    NSDictionary *header = [[self playbackController].patternLoader headerComponents];
    return 25;
}

- (NSUInteger)currentSection
{
    return [self playbackController].patternLoader.currentSection;
}

- (NSString *)currentModName
{
    return [self playbackController].patternLoader.currentPattern;
}

@end
