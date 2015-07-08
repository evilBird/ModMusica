//
//  MMRootViewController+Mods.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/23/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMRootViewController.h"
#import "MMModuleViewController.h"
@interface MMRootViewController (Mods)<MMModuleViewControllerDatasource,MMModuleViewControllerDelegate>


#pragma mark - MMModuleViewControllerDatasource
- (NSArray *)modulesForModuleView:(id)sender;

#pragma mark - MMModuleViewControllerDelegate
- (void)moduleView:(id)sender tappedButton:(id)button selectedModuleWithName:(NSString *)moduleName;
- (void)moduleView:(id)sender shuffleDidChange:(int)shuffle;
- (void)moduleView:(id)sender lockTempoDidChange:(int)lock;
- (CGFloat)openDrawerWidth;
- (UIColor *)currentTextColor;
- (UIColor *)currentFillColor;


@end
