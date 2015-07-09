//
//  MMPatternLoader.m
//  ModMusica
//
//  Created by Travis Henspeter on 10/30/14.
//  Copyright (c) 2014 birdSound. All rights reserved.
//

#import "MMPatternLoader.h"
#import "MMFileReader.h"
#import "MMModuleManager.h"
#import <PdBase.h>

static NSString *kTableName = @"notes";

@interface MMPatternLoader ()


@property (nonatomic,strong)            NSDictionary            *currentMod;

- (BOOL)loadPattern:(NSString *)pattern;
- (BOOL)loadPattern:(NSString *)pattern section:(NSInteger)section;

@end

@implementation MMPatternLoader

#pragma mark - Public

- (NSDictionary *)headerComponents
{
    if (!self.currentPattern) {
        return nil;
    }
    
    NSInteger section = self.currentSection;
    if (section < 0) {
        section++;
    }
    
    NSString *file = [self fileNameForPattern:self.currentPattern section:section];
    NSArray *header = [MMFileReader headerForFileAtPath:file];
    if (!header || !header.count) {
        return nil;
    }
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    for (NSString *headerLine in header) {
        NSArray *components = [headerLine componentsSeparatedByString:@","];
        NSString *receiver = components.firstObject;
        result[receiver] = components[1];
    }
    
    return [NSDictionary dictionaryWithDictionary:result];
}

- (NSArray *)patternData
{
    NSInteger section = self.currentSection;
    if (section < 0) {
        section++;
    }
    
    NSString *file = [self fileNameForPattern:self.currentPattern section:section];
    NSArray *data = [MMFileReader readFileAtPath:file];
    return data;
}

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
        return;
    }
    
    self.currentSection = 0;
    [self loadPattern:self.currentPattern section:self.currentSection];
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
    NSArray *noteTables = [MMFileReader readFileAtPath:pattern];
    
    if (noteTables == nil) {
        return NO;
    }
    
    NSArray *header = [MMFileReader headerForFileAtPath:pattern];
    
    [self handleHeader:header];
    
    for (NSArray *table in noteTables) {
        [PdBase sendList:table toReceiver:kTableName];
    }
    return YES;
}

- (void)sendNotesToPd:(NSArray *)notes
{
    [PdBase sendList:notes toReceiver:kTableName];
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

- (NSString *)fileNameForPattern:(NSString *)patternName section:(NSInteger)section
{
    NSDictionary *mod = [MMModuleManager getMod:patternName fromArray:[MMModuleManager purchasedMods]];
    NSString *modPath = mod[kProductContentPathKey];
    if (!modPath) {
        return nil;
    }
    
    NSString *fileName = [NSString stringWithFormat:@"%@-%@.csv",@(section),patternName];
    NSString *fullPath = [modPath stringByAppendingPathComponent:fileName];
    return fullPath;
}

- (BOOL)loadPattern:(NSString *)pattern section:(NSInteger)section
{
    NSString *fileName = [self fileNameForPattern:pattern section:section];
    return [self loadPattern:fileName];
}

@end
