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
    return [MMModuleManager mods];
}

#pragma mark - MMModuleViewControllerDelegate
- (void)moduleView:(id)sender selectedModuleWithName:(NSString *)moduleName
{
    __weak MMRootViewController *weakself = self;
    [self setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:NO completion:^{
        [[weakself getGLKViewController].playbackController playPattern:moduleName];
        [weakself getGLKViewController].currentModName = moduleName;
        [[weakself getGLKViewController]randomizeColors];
        if (![weakself getGLKViewController].isPlaying) {
            [weakself getGLKViewController].playing = YES;
        }
    }];
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

#pragma mark - MSDynamicsDrawerViewControllerDelegate
- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction
{
    if (paneState == MSDynamicsDrawerPaneStateClosed) {
        [[self getGLKViewController] showDetails];
    }
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController mayUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction
{
    if (paneState == MSDynamicsDrawerPaneStateClosed) {
        [[self getGLKViewController] showDetails];
    }
}

@end