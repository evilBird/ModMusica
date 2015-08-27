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
    return self.playbackController.isShuffled;
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
    return self.playbackController.isPlaying;
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
    return self.playbackController.currentModName;
}

- (void)setCurrentMod:(NSString *)moduleName
{
    if (!moduleName) {
        return;
    }
    
    self.playbackController.currentModName = moduleName;
    [self.playbackController startPlayback];
}

#pragma mark - MMModuleViewControllerDelegate

- (void)moduleView:(id)sender tappedButton:(id)button selectedModuleWithName:(NSString *)moduleName
{
    __weak MMRootViewController *weakself = self;
    
    NSDictionary *mod = [MMModuleManager getMod:moduleName fromArray:[MMModuleManager purchasedMods]];
    if (mod) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[(MMModuleViewController *)sender tableView] reloadData];
            [self setCurrentMod:moduleName];
        });
        return;
    }
    
    if (!mod) {
        __block UIButton *myButton = button;
        myButton.enabled = NO;
        [MMModuleManager purchaseMod:moduleName
                            progress:^(double downloadProgress){
                                [myButton setTitle:[NSString stringWithFormat:@"%.f%%",downloadProgress * 100] forState:UIControlStateDisabled];
                            }completion:^(BOOL success) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (success) {
                                        [[(MMModuleViewController *)sender tableView] reloadData];
                                        [weakself setCurrentMod:moduleName];
                                        myButton.enabled = YES;
                                        myButton.selected = YES;
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
    self.playbackController.shuffleMods = (BOOL)shuffle;
}

- (void)moduleView:(id)sender lockTempoDidChange:(int)lock
{
    self.playbackController.tempoLocked = (BOOL)lock;
    [PdBase sendFloat:(float)lock toReceiver:LOCK_TEMPO];
}

- (void)moduleView:(id)sender randomDidChange:(int)random
{
    self.playbackController.allowRandom = (BOOL)(1 - random);
    [PdBase sendFloat:(float)random toReceiver:ALLOW_RANDOM];
}

- (void)setupPlayback
{
    self.playbackController = [[MMPlaybackController alloc]init];
    self.playbackController.delegate = self;
}

#pragma mark - MMPlaybackControllerDelegate

- (void)playback:(id)sender clockDidChange:(NSInteger)clock
{
    [self getShaderViewController].clock = clock;
}

- (void)playbackBegan:(id)sender
{
    [self getShaderViewController].playing = YES;
}

- (void)playbackEnded:(id)sender
{
    [self getShaderViewController].playing = NO;
}

- (void)playback:(id)sender detectedUserTempo:(double)tempo
{
    [self getShaderViewController].tempo = tempo;
}

- (void)playback:(id)sender didLoadModuleName:(NSString *)moduleName
{
    [self getShaderViewController].currentModName = moduleName;
}

- (CGFloat)openDrawerWidth
{
    return [self revealWidthForDirection:MSDynamicsDrawerDirectionLeft];
}

- (UIColor *)currentFillColor
{
    return [self getShaderViewController].mainColor;
}

- (UIColor *)currentTextColor
{
    return [[self currentFillColor]complement];
}

@end
