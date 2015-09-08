//
//  MMModuleManager+Packages.h
//  ModMusica
//
//  Created by Travis Henspeter on 7/22/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMModuleManager.h"

#define USE_LOCAL_PRODUCTS 1

@interface MMModuleManager (Packages)

+ (NSArray *)getModResourceAtPath:(NSString *)path;

+ (NSString *)bundlePathModName:(NSString *)modName;
+ (NSString *)contentPathModName:(NSString *)modName;
+ (NSString *)drumSamplesPathModName:(NSString *)modName;
+ (NSString *)kickSamplesPathModName:(NSString *)modName;
+ (NSString *)snareSamplesPathModName:(NSString *)modName;
+ (NSString *)percussionSamplesPathModName:(NSString *)modName;
+ (NSString *)otherSamplesPathModName:(NSString *)modName;
+ (NSString *)plistPathModName:(NSString *)modName;
+ (NSString *)patchPathModName:(NSString *)modName;

@end
