//
//  MMRootViewController+Drawer.h
//  ModMusica
//
//  Created by Travis Henspeter on 7/7/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMRootViewController.h"

@interface MMRootViewController (Drawer)<MSDynamicsDrawerViewControllerDelegate,MyGLKViewControllerDelegate>

- (void)setupDrawerDynamics;

#pragma mark - MSDynamicsViewControllerDelegate
- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction;
- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController mayUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction;
- (BOOL)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController shouldBeginPanePan:(UIPanGestureRecognizer *)panGestureRecognizer;

#pragma mark - MyGLKViewControllerDelegate
- (void)openCloseDrawer:(id)sender;
- (void)glkViewController:(id)sender playbackChanged:(BOOL)playing;
@end
