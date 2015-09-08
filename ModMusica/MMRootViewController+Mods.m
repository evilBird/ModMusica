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

- (NSString *)currentModName
{
    return self.modName;
}

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

+ (UIAlertView *)errorAlert:(NSString *)errorDescription modName:(NSString *)modName
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"ERROR (%@)",modName] message:[NSString stringWithFormat:@"%@",errorDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    return alert;
}

#pragma mark - MMModuleViewControllerDelegate

- (void)loadPurchasedMod:(NSString *)modName selectedFromTable:(UITableView *)tableView withButton:(UIButton *)button
{
    __block UIButton *myButton = button;
    __block UITableView *myTableView = tableView;
    __weak MMRootViewController *weakself = self;
    [self setupPlayback:modName
             completion:^(BOOL success) {
                 if (success) {
                         weakself.modName = modName;
                         myButton.enabled = YES;
                         myButton.selected = YES;
                         [myTableView reloadData];
                 }else{
                         myButton.enabled = YES;
                         myButton.selected = NO;
                         weakself.modName = nil;
                         [[MMRootViewController errorAlert:@"Failed to load" modName:modName]show];
                         [myTableView reloadData];
                 }
             }];
}

- (void)purchaseAndLoadMod:(NSString *)modName selectedFromTable:(UITableView *)tableView withButton:(UIButton *)button
{
    __block UIButton *myButton = button;
    __block UITableView *myTableView = tableView;
    myButton.enabled = NO;
    __weak MMRootViewController *weakself = self;
    [MMModuleManager purchaseMod:modName
                        progress:^(double downloadProgress){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [myButton setTitle:[NSString stringWithFormat:@"%.f%%",downloadProgress * 100] forState:UIControlStateDisabled];
                            });

                        }completion:^(BOOL success) {
                            if (!success) {
                                    myButton.enabled = YES;
                                    myButton.selected = NO;
                                    weakself.modName = nil;
                                    [[MMRootViewController errorAlert:@"Failed to purchase" modName:modName]show];
                                    [myTableView reloadData];
                            }else{
                                [weakself loadPurchasedMod:modName selectedFromTable:tableView withButton:button];
                            }
                        }];
}

- (void)moduleView:(id)sender tappedButton:(id)button selectedModuleWithName:(NSString *)moduleName
{
    NSDictionary *mod = [MMModuleManager getMod:moduleName fromArray:[MMModuleManager purchasedMods]];
    __block UITableView *tableView = [(MMModuleViewController *)sender tableView];
    __block UIButton *myButton = button;
    dispatch_async(dispatch_get_main_queue(), ^{
        myButton.enabled = NO;
        [tableView reloadData];
    });
    
    if (mod) {
        [self loadPurchasedMod:moduleName selectedFromTable:tableView withButton:button];
        return;
    }else{
        [self purchaseAndLoadMod:moduleName selectedFromTable:tableView withButton:button];
        return;
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

- (void)setupPlayback:(NSString *)modName completion:(void(^)(BOOL success))completion
{
    self.playing = NO;
    if (self.playbackController) {
        [self.playbackController tearDown];
        self.playbackController = nil;
    }
    
    self.playbackController = [[MMPlaybackController alloc]init];
    self.playbackController.delegate = self;
    [self.playbackController preparePlaybackForMod:modName
                                        completion:completion];    
}

#pragma mark - MMPlaybackControllerDelegate

- (void)playback:(id)sender clockDidChange:(NSInteger)clock
{
    
}

- (void)playbackBegan:(id)sender
{
    self.playing = YES;
    self.shaderViewController.playing = self.playing;
}

- (void)playbackEnded:(id)sender
{
    self.playing = NO;
    self.shaderViewController.playing = self.playing;
}

- (void)playback:(id)sender detectedUserTempo:(double)tempo
{
    self.tempo = tempo;
    self.shaderViewController.tempo = tempo;
}

- (void)playback:(id)sender didLoadModuleName:(NSString *)moduleName
{
    //self.modName = moduleName;
}

- (UIColor *)currentTextColor
{
    return [self.mainColor complement];
}

- (UIColor *)currentFillColor
{
    return self.mainColor;
}

@end
