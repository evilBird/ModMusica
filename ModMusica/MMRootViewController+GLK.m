//
//  MMRootViewController+Drawer.m
//  ModMusica
//
//  Created by Travis Henspeter on 7/7/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMRootViewController+GLK.h"
#import "MMRootViewController+Mods.h"

@implementation MMRootViewController (GLK)

- (void)glkViewController:(id)sender playbackChanged:(BOOL)playing
{
    
}

- (void)glkViewController:(id)sender tappedMenuButton:(id)button
{
    [sender performSegueWithIdentifier:@"ShowModViewController" sender:self];
}

- (UIColor *)mainColorForGlkViewController:(id)sender
{
    return self.mainColor;
}

- (BOOL)glkViewControllerShouldDraw:(id)sender
{
    return YES;
}

- (BOOL)glkViewControllerShouldUpdate:(id)sender
{
    return self.isPlaying;// self.playbackController.isPlaying;
}

- (double)glkViewControllerScale:(id)sender
{
    return self.scale;
}

- (double)glkViewControllerRotation:(id)sender
{
    return self.rotation;
}

- (void)glkViewController:(id)sender willShowModalViewController:(id)modalVC
{
    if ([modalVC isKindOfClass:[MMModuleViewController class]]){
        MMModuleViewController *mvc = modalVC;
        mvc.delegate = self;
        mvc.datasource = self;
    }
}

@end
