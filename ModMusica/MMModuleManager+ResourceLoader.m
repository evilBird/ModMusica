//
//  MMModuleManager+ResourceLoader.m
//  ModMusica
//
//  Created by Travis Henspeter on 7/22/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMModuleManager+ResourceLoader.h"
#import "ModEditorDefs.h"
#import "MMModuleManager+Packages.h"

@implementation MMModuleManager (ResourceLoader)

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
    
}

- (void)loadPatchForModName:(NSString *)modName
{
    
}

- (void)loadResourcesForModName:(NSString *)modName completion:(void(^)(void))completion
{
    [self loadDrumSamplesForModName:modName];
    [self loadOtherSamplesForModName:modName];
    
}

@end
