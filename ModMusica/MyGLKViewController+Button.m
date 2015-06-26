//
//  MyGLKViewController+Button.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/26/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MyGLKViewController+Button.h"
#import "UIView+Layout.h"
#import "UIColor+HBVHarmonies.h"

@implementation MyGLKViewController (Button)

- (void)tapInHamburgerButton:(id)sender
{
    [self.glkDelegate openCloseDrawer:self];
}

- (void)setupHamburgerButton
{
    self.hamburgerButton = [[HamburgerButton alloc]init];
    self.hamburgerButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.hamburgerButton addTarget:self action:@selector(tapInHamburgerButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.hamburgerButton];
    [self.view addConstraint:[self.hamburgerButton pinHeight:30]];
    [self.view addConstraint:[self.hamburgerButton pinWidth:40]];
    [self.view addConstraint:[self.hamburgerButton alignAxis:LayoutAxis_Vertical
                                                      toAxis:LayoutAxis_Vertical
                                                      ofView:self.titleLabel
                                                      offset:0]];
    
    [self.view addConstraint:[self.hamburgerButton pinEdge:LayoutEdge_Left
                                                    toEdge:LayoutEdge_Left
                                                    ofView:self.hamburgerButton.superview withInset:20]];
    [self updateHamburgerButtonColor];
}

- (void)updateHamburgerButtonColor
{
    self.hamburgerButton.mainColor = [self.mainColor complement];
}

@end
