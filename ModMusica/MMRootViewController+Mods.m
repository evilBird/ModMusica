//
//  MMRootViewController+Mods.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/23/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMRootViewController+Mods.h"
#import "MMModuleManager.h"
#import "UIColor+HBVHarmonies.h"

@implementation MMRootViewController (Mods)


#pragma mark - MMModuleViewControllerDatasource
- (NSArray *)modulesForModuleView:(id)sender
{
    return [MMModuleManager availableMods];
}

- (BOOL)modsAreShuffled:(id)sender
{
    return [self getGLKViewController].playbackController.isShuffled;
}

- (void)setCurrentMod:(NSString *)moduleName
{
    __weak MMRootViewController *weakself = self;
    [self setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:NO completion:^{
        [[weakself getGLKViewController].playbackController playPattern:moduleName];
        [[weakself getGLKViewController]randomizeColors];
        if (![weakself getGLKViewController].isPlaying) {
            [weakself getGLKViewController].playing = YES;
        }
    }];
}

#pragma mark - MMModuleViewControllerDelegate

- (void)moduleView:(id)sender selectedModuleWithName:(NSString *)moduleName
{
    __weak MMRootViewController *weakself = self;
    if (![MMModuleManager getMod:moduleName fromArray:[MMModuleManager purchasedMods]]) {
        [MMModuleManager purchaseMod:moduleName completion:^(BOOL success) {
            if (success) {
                [[(MMModuleViewController *)sender tableView] reloadData];
                [weakself setCurrentMod:moduleName];
            }
        }];
        
        return;
    }
    
    [self setCurrentMod:moduleName];
}

- (void)moduleView:(id)sender shuffleDidChange:(int)shuffle
{
    [self getGLKViewController].playbackController.shuffleMods = (BOOL)shuffle;
}

- (void)moduleView:(id)sender lockTempoDidChange:(int)lock
{
    [self getGLKViewController].playbackController.tempoLocked = (BOOL)lock;
    [PdBase sendFloat:(float)lock toReceiver:@"lockTempo"];
}

- (CGFloat)openDrawerWidth
{
    return [self revealWidthForDirection:MSDynamicsDrawerDirectionLeft];
}

- (UIColor *)currentFillColor
{
    return [self getGLKViewController].mainColor;
}

- (UIColor *)currentTextColor
{
    return [[self currentFillColor]complement];
}

@end
