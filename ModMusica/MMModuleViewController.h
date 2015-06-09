//
//  MMModuleViewController.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/9/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MMModuleViewControllerDelegate <NSObject>

- (void)moduleView:(id)sender selectedModuleWithName:(NSString *)moduleName;
- (CGFloat)openDrawerWidth;
- (UIColor *)currentFillColor;
- (UIColor *)currentTextColor;

@end

@protocol MMModuleViewControllerDatasource <NSObject>

- (NSArray *)modulesForModuleView:(id)sender;

@end

@interface MMModuleViewController : UITableViewController

@property (nonatomic,weak)      id<MMModuleViewControllerDelegate>      delegate;
@property (nonatomic,weak)      id<MMModuleViewControllerDatasource>    datasource;
@property (nonatomic,strong)    NSArray                                 *modules;

@end