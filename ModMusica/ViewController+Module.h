//
//  ViewController+Module.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/9/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ViewController.h"
#import "MMModuleViewController.h"

@interface ViewController (Module)<MMModuleViewControllerDelegate,MMModuleViewControllerDatasource,MSDynamicsDrawerViewControllerDelegate>

- (NSArray *)modulesForModuleView:(id)sender;
- (void)moduleView:(id)sender selectedModuleWithName:(NSString *)moduleName;
- (void)configureModules;
- (CGFloat)openDrawerWidth;
- (UIColor *)currentTextColor;
- (UIColor *)currentFillColor;

@end
