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

- (NSArray *)moduleNamesForView:(id)sender
{
    NSArray *names = [MMModuleManager availableModNames];
    NSArray *sorted = [names sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return sorted;
}

- (NSDictionary *)modForName:(NSString *)modName
{
    return [MMModuleManager getMod:modName fromArray:[MMModuleManager availableMods]];
}

- (BOOL)modIsPurchased:(NSString *)modName
{
    NSDictionary *mod = [MMModuleManager getMod:modName fromArray:[MMModuleManager purchasedMods]];
    
    if (mod) {
        return YES;
    }
    
    return NO;
}

- (BOOL)playbackIsActive
{
    return [self getGLKViewController].isPlaying;
}

- (NSString *)formattedPriceForMod:(NSString *)modName
{
    NSDictionary *mod = [MMModuleManager getMod:modName fromArray:[MMModuleManager availableMods]];
    if (!mod) {
        return nil;
    }
    
    return mod[kProductFormattedPriceKey];
}

- (NSString *)currentModName
{
    return [self getGLKViewController].playbackController.patternName;
}

- (void)setCurrentMod:(NSString *)moduleName
{
    if (!moduleName) {
        return;
    }
    
    [[self getGLKViewController].playbackController playPattern:moduleName];
    __weak MMRootViewController *weakself = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:YES completion:nil];
    });
}

#pragma mark - MMModuleViewControllerDelegate

- (void)moduleView:(id)sender tappedButton:(id)button selectedModuleWithName:(NSString *)moduleName
{
    __weak MMRootViewController *weakself = self;
    
    NSDictionary *mod = [MMModuleManager getMod:moduleName fromArray:[MMModuleManager purchasedMods]];
    if (mod) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[(MMModuleViewController *)sender tableView] reloadData];
        });
        [self setCurrentMod:moduleName];
        return;
    }
    
    if (!mod) {
        __block UIButton *myButton = button;
        myButton.enabled = NO;
        [MMModuleManager purchaseMod:moduleName completion:^(BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    myButton.enabled = YES;
                    [[(MMModuleViewController *)sender tableView] reloadData];
                    [weakself setCurrentMod:moduleName];
                }else{
                    myButton.enabled = YES;
                    [[(MMModuleViewController *)sender tableView] reloadData];
                }
            });
        }];
        
    }
    
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
