//
//  MMModuleManager.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/13/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMModuleManager : NSObject

+ (NSArray *)availableMods;
+ (NSArray *)purchasedMods;
+ (NSArray *)availableModNames;
+ (NSArray *)purchasedModNames;
+ (NSDictionary *)getMod:(NSString *)modName fromArray:(NSArray *)mods;

+ (void)purchaseMod:(NSString *)modName completion:(void(^)(BOOL success))completion;

@end
