//
//  MMRootViewController+Drawer.h
//  ModMusica
//
//  Created by Travis Henspeter on 7/7/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMRootViewController.h"

@interface MMRootViewController (GLK)<MyGLKViewControllerDelegate>

#pragma mark - MyGLKViewControllerDelegate
- (void)glkViewController:(id)sender playbackChanged:(BOOL)playing;
- (void)glkViewController:(id)sender tappedMenuButton:(id)button;
- (UIColor *)mainColorForGlkViewController:(id)sender;
- (BOOL)glkViewControllerShouldDraw:(id)sender;
- (BOOL)glkViewControllerShouldUpdate:(id)sender;
- (double)glkViewControllerScale:(id)sender;
- (double)glkViewControllerRotation:(id)sender;
- (double)glkViewControllerDeltaScale:(id)sender;
- (double)glkViewControllerDeltaRotation:(id)sender;
- (void)glkViewController:(id)sender subscribeToMessages:(NSString *)messageSource;
- (void)glkViewController:(id)sender unsubscribeToMessages:(NSString *)messageSource;

@end
