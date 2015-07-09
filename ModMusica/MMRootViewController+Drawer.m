//
//  MMRootViewController+Drawer.m
//  ModMusica
//
//  Created by Travis Henspeter on 7/7/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMRootViewController+Drawer.h"

@implementation MMRootViewController (Drawer)

- (void)setupDrawerDynamics
{
    self.elasticity = 0;
    self.gravityMagnitude = 10.0;
    self.bounceElasticity = 0;
    self.bounceMagnitude = 0;
}

#pragma mark - MSDynamicsDrawerViewControllerDelegate
- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction
{
    if (paneState == MSDynamicsDrawerPaneStateClosed && self.paneViewController == [self getGLKViewController]) {
        [[self getGLKViewController] showDetailsFade:[self getGLKViewController].isPlaying];
    }
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController mayUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction
{
    if (paneState == MSDynamicsDrawerPaneStateClosed && self.paneViewController == [self getGLKViewController]) {
        [[self getGLKViewController] showDetailsFade:[self getGLKViewController].isPlaying];
    }
}

- (BOOL)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController shouldBeginPanePan:(UIPanGestureRecognizer *)panGestureRecognizer
{
    return YES;
}

#pragma mark - MyGLKViewControllerDelegate
- (void)openCloseDrawer:(id)sender
{
    if (self.paneState == MSDynamicsDrawerPaneStateClosed) {
        [self setPaneState:MSDynamicsDrawerPaneStateOpen inDirection:MSDynamicsDrawerDirectionLeft animated:YES allowUserInterruption:YES completion:nil];
    }else{
        [self setPaneState:MSDynamicsDrawerPaneStateClosed inDirection:MSDynamicsDrawerDirectionLeft animated:YES allowUserInterruption:YES completion:nil];
    }
}

- (void)glkViewController:(id)sender playbackChanged:(BOOL)playing
{
    
}

@end
