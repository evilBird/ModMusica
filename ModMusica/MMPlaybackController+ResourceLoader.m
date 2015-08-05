//
//  MMPlaybackController+ResourceLoader.m
//  ModMusica
//
//  Created by Travis Henspeter on 7/22/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMPlaybackController+ResourceLoader.h"
#import "ModMusicaDefs.h"
#import "PdBase.h"
#import "MMModuleManager+Packages.h"

@implementation MMPlaybackController (ResourceLoader)

- (void)openPatch
{
    NSString *patchName = nil;
    
    if (!self.patternName || !self.patternName.length) {
        patchName = DEFAULT_PATCH;
    }else{
        patchName = [NSString stringWithFormat:PATCH_NAME_FORMAT_STRING,PATCH_BASE,self.patternName];
    }
    
    if (self.patchIsOpen) {
        [self closePatch];
    }
    NSString *patchPath = [MMModuleManager contentPathModName:self.patternName];
    
    if (!patchPath) {
        patchPath = [[NSBundle mainBundle]pathForResource:DEFAULT_PATCH ofType:PATCH_FILE_EXTENSION];
    }
    
    self.patch = [PdBase openFile:patchName path:patchPath];
    
    if (self.patch != NULL) {
        self.patchIsOpen = YES;
    }
}

- (void)closePatch
{
    if (self.isPlaying) {
        [self stopPlayback];
    }
    
    
    if (self.patch != NULL && self.patchIsOpen) {
        [PdBase closeFile:self.patch];
        self.patch = NULL;
    }
    
    self.patchIsOpen = NO;
}

- (void)loadDrumSamples:(NSArray *)samples basePath:(NSString *)basePath receiver:(NSString *)receiver
{
    if (!samples || !receiver) {
        return;
    }
    for (NSUInteger i = 0; i < samples.count; i++) {
        NSString *samplePath = [basePath stringByAppendingPathComponent:samples[i]];
        [PdBase sendList:@[@(i),SAMPLE_FLAG_READ,SAMPLE_FLAG_RESIZE,samplePath] toReceiver:receiver];
    }
}

- (void)loadOtherSamples:(NSArray *)samples basePath:(NSString *)basePath receiver:(NSString *)receiver
{
    if (!samples || !receiver) {
        return;
    }
    
    for (NSUInteger i = 0; i < samples.count; i++) {
        NSString *samplePath = [basePath stringByAppendingPathComponent:samples[i]];
        [PdBase sendList:@[@(i),SAMPLE_FLAG_SAMPLE,samplePath] toReceiver:receiver];
    }
    
}

- (void)loadKickSamplesForModName:(NSString *)modName
{
    NSString *path = [MMModuleManager kickSamplesPathModName:modName];
    NSArray *samples = [MMModuleManager getModResourceAtPath:path];
    [self loadDrumSamples:samples basePath:path receiver:LOAD_KICK_SAMPLE];
}

- (void)loadSnareSamplesForModName:(NSString *)modName
{
    NSString *path = [MMModuleManager snareSamplesPathModName:modName];
    NSArray *samples = [MMModuleManager getModResourceAtPath:path];
    [self loadDrumSamples:samples basePath:path receiver:LOAD_SNARE_SAMPLE];
}

- (void)loadPercSamplesForModName:(NSString *)modName
{
    NSString *path = [MMModuleManager percussionSamplesPathModName:modName];
    NSArray *samples = [MMModuleManager getModResourceAtPath:path];
    [self loadDrumSamples:samples basePath:path receiver:LOAD_PERC_SAMPLE];
}

- (void)loadDrumSamplesForModName:(NSString *)modName
{
    [self loadKickSamplesForModName:modName];
    [self loadSnareSamplesForModName:modName];
    [self loadPercSamplesForModName:modName];
}

- (void)loadOtherSamplesForModName:(NSString *)modName
{
    NSString *path = [MMModuleManager otherSamplesPathModName:modName];
    NSArray *allSamples = [MMModuleManager getModResourceAtPath:path];
    NSRange range;
    range.location = 0;
    if (allSamples.count < 4) {
        range.length = allSamples.count;
    }else{
        range.length = 4;
    }

    NSIndexSet *indices = [NSIndexSet indexSetWithIndexesInRange:range];
    NSArray *samples = [allSamples objectsAtIndexes:indices];
    [self loadOtherSamples:samples basePath:path receiver:LOAD_OTHER_SAMPLE];
}

- (void)loadPatternsForModName:(NSString *)modName
{
    self.patternLoader.currentPattern = modName;
    self.patternLoader.currentSection = -1;
}

- (void)loadPatchForModName:(NSString *)modName
{
    self.patternName = modName;
    [self openPatch];
}

- (void)loadResourcesForModName:(NSString *)modName completion:(void(^)(void))completion
{
    if (!modName || ![[MMModuleManager purchasedModNames]containsObject:modName]) {
        return;
    }
    
    [self loadPatchForModName:modName];
    NSString *contentPath = [MMModuleManager contentPathModName:modName];
    NSString *path = [contentPath stringByAppendingString:@"/"];
    NSLog(@"content path: %@",path);
    [PdBase sendSymbol:path toReceiver:@"path"];
    [self loadDrumSamplesForModName:modName];
    [self loadOtherSamplesForModName:modName];
    [PdBase sendBangToReceiver:FINISHED_LOADING_SAMPLES];
}

@end
