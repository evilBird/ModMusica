//
//  MMPatternLoader.m
//  ModMusica
//
//  Created by Travis Henspeter on 10/30/14.
//  Copyright (c) 2014 birdSound. All rights reserved.
//

#import "MMPatternLoader.h"
#import "MMFileReader.h"
#import <PdBase.h>

static NSString *kTableName = @"notes";

@interface MMPatternLoader ()

- (BOOL)loadPattern:(NSString *)pattern;
- (BOOL)loadPattern:(NSString *)pattern section:(NSInteger)section;

@end

@implementation MMPatternLoader

#pragma mark - Public

- (void)setPattern:(NSString *)pattern
{
    self.currentPattern = pattern;
}

- (void)playNextSection
{
    if (self.currentPattern == nil) {
        return;
    }
    
    if ([self loadPattern:self.currentPattern section:self.currentSection + 1]) {
        self.currentSection += 1;
        NSLog(@"current section:%@",@(self.currentSection));
        return;
    }
    
    self.currentSection = 0;
    [self loadPattern:self.currentPattern section:self.currentSection];
    NSLog(@"current section:%@",@(self.currentSection));
}

- (void)playPreviousSection
{
    if (self.currentPattern == nil) {
        return;
    }
    
    if (self.currentSection > 0) {
        self.currentSection -= 1;
        [self loadPattern:self.currentPattern section:self.currentSection];
        return;
    }
}

- (void)playSection:(NSInteger)section
{
    if (self.currentPattern == nil) {
        return;
    }
    
    if ([self loadPattern:self.currentPattern section:section]) {
        self.currentSection = section;
    }
}

#pragma mark - Private

- (void)setCurrentPattern:(NSString *)currentPattern
{
    if (_currentPattern == nil) {
        _currentPattern = currentPattern;
        self.currentSection = -1;
        return;
    }
    
    if (![currentPattern isEqualToString:_currentPattern]) {
        _currentPattern = currentPattern;
        self.currentSection = -1;
    }
}

- (BOOL)loadPattern:(NSString *)pattern
{
    NSArray *noteTables = [MMFileReader readFile:pattern];
    if (noteTables == nil) {
        return NO;
    }
    NSArray *header = [MMFileReader headerForFile:pattern];
    [self handleHeader:header];
    for (NSArray *table in noteTables) {
        [PdBase sendList:table toReceiver:kTableName];
    }
    return YES;
}

- (void)handleHeader:(NSArray *)header
{
    for (NSString *headerLine in header) {
        NSArray *components = [headerLine componentsSeparatedByString:@","];
        NSString *receiver = components.firstObject;
        float value = [components[1]floatValue];
        [PdBase sendFloat:value toReceiver:receiver];
    }
}

- (BOOL)loadPattern:(NSString *)pattern section:(NSInteger)section
{
    NSString *fileName = [NSString stringWithFormat:@"%@-%@.csv",@(section),pattern];
    if ([self.currentPattern isEqualToString:@"ohn"]) {
        fileName = [NSString stringWithFormat:@"0-%@.csv",pattern];
    }

    return [self loadPattern:fileName];
}


@end
