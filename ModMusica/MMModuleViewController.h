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

- (void)moduleView:(id)sender tappedButton:(id)button selectedModuleWithName:(NSString *)moduleName;
- (void)moduleView:(id)sender shuffleDidChange:(int)shuffle;
- (void)moduleView:(id)sender lockTempoDidChange:(int)lock;
- (void)moduleView:(id)sender randomDidChange:(int)random;

- (CGFloat)openDrawerWidth;
- (UIColor *)currentFillColor;
- (UIColor *)currentTextColor;

@end

@protocol MMModuleViewControllerDatasource <NSObject>

- (NSArray *)modulesForModuleView:(id)sender;
- (NSArray *)moduleNamesForView:(id)sender;
- (NSDictionary *)modForName:(NSString *)modName;
- (NSString *)currentModName;
- (BOOL)modsAreShuffled:(id)sender;
- (BOOL)modIsPurchased:(NSString *)modName;
- (BOOL)playbackIsActive;
- (NSString *)formattedPriceForMod:(NSString *)modName;


@end

@interface MMModuleViewController : UITableViewController

@property (nonatomic,weak)      id<MMModuleViewControllerDelegate>      delegate;
@property (nonatomic,weak)      id<MMModuleViewControllerDatasource>    datasource;
@property (nonatomic,readonly)  NSArray                                 *modules;
@property (nonatomic,readonly)  NSArray                                 *modName;

@end
