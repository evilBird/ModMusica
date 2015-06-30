//
//  MMModuleViewController.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/9/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MMModuleViewControllerDelegate <NSObject>

@optional
- (void)moduleView:(id)sender selectedModuleWithName:(NSString *)moduleName;
- (void)moduleView:(id)sender shuffleDidChange:(int)shuffle;
- (void)moduleView:(id)sender lockTempoDidChange:(int)lock;

- (CGFloat)openDrawerWidth;
- (UIColor *)currentFillColor;
- (UIColor *)currentTextColor;
- (void)moduleViewEdit:(id)sender;


@end

@protocol MMModuleViewControllerDatasource <NSObject>

- (NSArray *)modulesForModuleView:(id)sender;

@end

@interface MMModuleViewController : UITableViewController

@property (nonatomic,weak)      id<MMModuleViewControllerDelegate>      delegate;
@property (nonatomic,weak)      id<MMModuleViewControllerDatasource>    datasource;
@property (nonatomic,strong)    NSArray                                 *modules;

@end
