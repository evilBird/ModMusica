//
//  ViewController+Module.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/9/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ViewController+Module.h"
#import "MMModuleViewController.h"
#import "MMAudioScopeViewController+Random.h"
#import "MMModuleManager.h"

@implementation ViewController (Module)

- (void)configureModules
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MMModuleViewController *mm =[storyboard instantiateViewControllerWithIdentifier:@"DrawerViewController"];
    mm.datasource = self;
    mm.delegate = self;
    self.delegate = self;
    [self setDrawerViewController:mm forDirection:MSDynamicsDrawerDirectionLeft];
}

#pragma mark - MMModuleViewControllerDatasource
- (NSArray *)modulesForModuleView:(id)sender
{
    return [MMModuleManager mods];
}

#pragma mark - MMModuleViewControllerDelegate
- (void)moduleView:(id)sender selectedModuleWithName:(NSString *)moduleName
{
    __weak ViewController *weakself = self;
    [self setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:NO completion:^{
        [weakself.playbackController playPattern:moduleName];
        weakself.scopeViewController.nowPlaying = moduleName;
        [weakself.scopeViewController randomizeColors];
        if (!weakself.isPlaying) {
            weakself.playing = YES;
        }
    }];
}

- (CGFloat)openDrawerWidth
{
    return [self revealWidthForDirection:MSDynamicsDrawerDirectionLeft];
}

- (UIColor *)currentFillColor
{
    return self.scopeViewController.view.backgroundColor;
}

- (UIColor *)currentTextColor
{
    return self.scopeViewController.label.textColor;
}

#pragma mark - MSDynamicsDrawerViewControllerDelegate
- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction
{
    if (paneState == MSDynamicsDrawerPaneStateClosed) {
        [self showDetails];
    }
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController mayUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction
{
    if (paneState == MSDynamicsDrawerPaneStateClosed) {
        [self showDetails];
    }
}


@end
