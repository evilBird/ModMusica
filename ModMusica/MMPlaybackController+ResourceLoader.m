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
        patchName = [NSString stringWithFormat:@"%@_%@.pd",PATCH_BASE,self.patternName];
    }
    
    if (self.patchIsOpen) {
        [self closePatch];
    }
    NSString *patchPath = [MMModuleManager contentPathModName:self.patternName];
    
    if (!patchPath) {
        patchPath = [[NSBundle mainBundle]pathForResource:DEFAULT_PATCH ofType:@".pd"];
    }
    
    self.patch = [PdBase openFile:patchName path:patchPath];
    
    [PdBase sendSymbol:[NSBundle mainBundle].resourcePath toReceiver:@"setPath"];
    
    if (self.patch != NULL) {
        self.patchIsOpen = YES;
        [self setInstrumentLevelsOn];
    }
}

- (void)closePatch
{
    if (self.isPlaying) {
        self.playing = NO;
    }
    
    [self setInstrumentLevelsOff];
    
    if (self.patch != NULL) {
        [PdBase closeFile:self.patch];
        self.patch = NULL;
    }
    
    self.patchIsOpen = NO;
}

- (void)loadSamples:(NSArray *)samples receiver:(NSString *)receiver
{
    if (!samples || !receiver) {
        return;
    }
    
    for (NSString *sample in samples) {
        [PdBase sendList:@[sample] toReceiver:receiver];
    }
}

- (void)loadKickSamplesForModName:(NSString *)modName
{
    NSString *path = [MMModuleManager kickSamplesPathModName:modName];
    NSArray *samples = [MMModuleManager getModResourceAtPath:path];
    [self loadSamples:samples receiver:LOAD_KICK_SAMPLE];
}

- (void)loadSnareSamplesForModName:(NSString *)modName
{
    NSString *path = [MMModuleManager snareSamplesPathModName:modName];
    NSArray *samples = [MMModuleManager getModResourceAtPath:path];
    [self loadSamples:samples receiver:LOAD_SNARE_SAMPLE];
}

- (void)loadPercSamplesForModName:(NSString *)modName
{
    NSString *path = [MMModuleManager percussionSamplesPathModName:modName];
    NSArray *samples = [MMModuleManager getModResourceAtPath:path];
    [self loadSamples:samples receiver:LOAD_PERC_SAMPLE];
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
    NSArray *samples = [MMModuleManager getModResourceAtPath:path];
    [self loadSamples:samples receiver:LOAD_OTHER_SAMPLE];
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
    [self loadPatternsForModName:modName];
    [self loadDrumSamplesForModName:modName];
    [self loadOtherSamplesForModName:modName];
    
}

@end
