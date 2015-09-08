//
//  MMModuleManager.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/13/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModMusicaDefs.h"

@interface MMModuleManager : NSObject

+ (void)setupDefaultMods;
+ (NSArray *)availableMods;
+ (NSArray *)purchasedMods;
+ (NSArray *)availableModNames;
+ (NSArray *)purchasedModNames;
+ (NSDictionary *)getMod:(NSString *)modName fromArray:(NSArray *)mods;
+ (void)purchaseMod:(NSString *)modName completion:(void(^)(BOOL success))completion;

+ (void)purchaseMod:(NSString *)modName
           progress:(void(^)(double downloadProgress))progress
         completion:(void(^)(BOOL success))completion;

+ (BOOL)mockPurchaseMod:(NSString *)modName;

+ (id)modName:(NSString *)modName valueForKey:(NSString *)key;

@end
