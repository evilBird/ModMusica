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

@interface MMPlaybackController ()

- (void)startPlaybackNow;
- (void)stopPlaybackNow;

@end

@implementation MMPlaybackController (ResourceLoader)

- (BOOL)openPatch:(NSString *)modName
{
    if (![self closePatch:modName]) {
        return NO;
    }
    
    NSString *patchName = [NSString stringWithFormat:PATCH_NAME_FORMAT_STRING,PATCH_BASE,modName];
    NSString *patchPath = [MMModuleManager contentPathModName:modName];
    if (!patchPath || ![[NSFileManager defaultManager]fileExistsAtPath:patchPath]) {
        return NO;
    }
    
    self.patch = [PdBase openFile:patchName path:patchPath];
    
    if (self.patch != NULL) {
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)closePatch:(NSString *)modName
{
    if (!self.patchIsOpen) {
        return YES;
    }
    
    if (self.isPlaying) {
        [self stopPlaybackNow];
    }
    
    if (self.patch != NULL && self.patchIsOpen) {
        [PdBase closeFile:self.patch];
        self.patch = NULL;
    }
    
    if (self.patch!=NULL) {
        return NO;
    }
    
    return YES;
}

- (BOOL)loadDrumSamples:(NSArray *)samples basePath:(NSString *)basePath receiver:(NSString *)receiver
{
    if (!samples || !receiver) {
        return NO;
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL success = NO;
    for (NSUInteger i = 0; i < samples.count; i++) {
        NSString *samplePath = [basePath stringByAppendingPathComponent:samples[i]];
        if (![fm fileExistsAtPath:samplePath]){
            success = NO;
            break;
        }else{
            success = YES;
        }
        
        [PdBase sendList:@[@(i),SAMPLE_FLAG_READ,SAMPLE_FLAG_RESIZE,samplePath] toReceiver:receiver];
    }
    
    return success;
}

- (BOOL)loadOtherSamples:(NSArray *)samples basePath:(NSString *)basePath receiver:(NSString *)receiver
{
    if (!samples || !receiver) {
        return NO;
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL success = NO;
    
    for (NSUInteger i = 0; i < samples.count; i++) {
        NSString *samplePath = [basePath stringByAppendingPathComponent:samples[i]];
        if (![fm fileExistsAtPath:samplePath]){
            success = NO;
            break;
        }else{
            success = YES;
        }
        [PdBase sendList:@[@(i),SAMPLE_FLAG_SAMPLE,samplePath] toReceiver:receiver];
    }
    
    return success;
}

- (BOOL)loadKickSamplesForModName:(NSString *)modName
{
    NSString *path = [MMModuleManager kickSamplesPathModName:modName];
    NSArray *samples = [MMModuleManager getModResourceAtPath:path];
    return [self loadDrumSamples:samples basePath:path receiver:LOAD_KICK_SAMPLE];
}

- (BOOL)loadSnareSamplesForModName:(NSString *)modName
{
    NSString *path = [MMModuleManager snareSamplesPathModName:modName];
    NSArray *samples = [MMModuleManager getModResourceAtPath:path];
    return [self loadDrumSamples:samples basePath:path receiver:LOAD_SNARE_SAMPLE];
}

- (BOOL)loadPercSamplesForModName:(NSString *)modName
{
    NSString *path = [MMModuleManager percussionSamplesPathModName:modName];
    NSArray *samples = [MMModuleManager getModResourceAtPath:path];
    return [self loadDrumSamples:samples basePath:path receiver:LOAD_PERC_SAMPLE];
}

- (BOOL)loadDrumSamplesForModName:(NSString *)modName
{
    return ([self loadKickSamplesForModName:modName]&&[self loadSnareSamplesForModName:modName]&&[self loadPercSamplesForModName:modName]);
}

- (BOOL)loadOtherSamplesForModName:(NSString *)modName
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
    return [self loadOtherSamples:samples basePath:path receiver:LOAD_OTHER_SAMPLE];
}

- (BOOL)loadResources
{
    NSString *modName = self.modName;
    if (!modName || ![[MMModuleManager purchasedModNames]containsObject:modName]) {
        return NO;
    }
    
    self.patchIsOpen = [self openPatch:modName];
    NSString *contentPath = [MMModuleManager contentPathModName:modName];
    NSString *path = [contentPath stringByAppendingString:@"/"];
    [PdBase sendSymbol:path toReceiver:@"path"];
    if (![self loadDrumSamplesForModName:modName]) {
        return NO;
    }
    
    if (![self loadOtherSamplesForModName:modName]) {
        return NO;
    }
    
    [PdBase sendBangToReceiver:FINISHED_LOADING_SAMPLES];
    
    return YES;
}

@end
