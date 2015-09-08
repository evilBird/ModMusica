//
//  MMRootViewController+Mods.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/23/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMRootViewController.h"
#import "MMModuleViewController.h"

@interface MMRootViewController (Mods)<MMModuleViewControllerDatasource,MMModuleViewControllerDelegate,MMPlaybackDelegate>

- (void)setupPlayback:(NSString *)modName completion:(void(^)(BOOL success))completion;
+ (UIAlertView *)errorAlert:(NSString *)errorDescription modName:(NSString *)modName;

#pragma mark - MMModuleViewControllerDatasource
- (NSString *)currentModName;
- (NSArray *)modulesForModuleView:(id)sender;
- (NSArray *)moduleNamesForView:(id)sender;
- (NSDictionary *)modForName:(NSString *)modName;
- (BOOL)modIsPurchased:(NSString *)modName;
- (BOOL)playbackIsActive;
- (NSString *)formattedPriceForMod:(NSString *)modName;

#pragma mark - MMModuleViewControllerDelegate
- (void)moduleView:(id)sender tappedButton:(id)button selectedModuleWithName:(NSString *)moduleName;
- (void)moduleView:(id)sender shuffleDidChange:(int)shuffle;
- (void)moduleView:(id)sender lockTempoDidChange:(int)lock;
- (void)moduleView:(id)sender randomDidChange:(int)random;

#pragma mark - MMPlaybackControllerDelegate
- (void)playback:(id)sender clockDidChange:(NSInteger)clock;
- (void)playbackBegan:(id)sender;
- (void)playbackEnded:(id)sender;
- (void)playback:(id)sender detectedUserTempo:(double)tempo;
- (void)playback:(id)sender didLoadModuleName:(NSString *)moduleName;


- (UIColor *)currentTextColor;
- (UIColor *)currentFillColor;




@end
