//
//  MMRootViewController+Mods.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/23/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMRootViewController.h"
#import "MMModuleViewController.h"
@interface MMRootViewController (Mods)<MMModuleViewControllerDatasource,MMModuleViewControllerDelegate,MSDynamicsDrawerViewControllerDelegate,MyGLKViewControllerDelegate>

#pragma mark - MMModuleViewControllerDatasource
- (NSArray *)modulesForModuleView:(id)sender;

#pragma mark - MMModuleViewControllerDelegate
- (void)moduleView:(id)sender selectedModuleWithName:(NSString *)moduleName;
- (CGFloat)openDrawerWidth;
- (UIColor *)currentTextColor;
- (UIColor *)currentFillColor;

#pragma mark - MSDynamicsViewControllerDelegate
- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction;
- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController mayUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction;

#pragma mark - MyGLKViewControllerDelegate

- (void)openCloseDrawer:(id)sender;

@end
