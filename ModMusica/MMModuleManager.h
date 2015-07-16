//
//  MMModuleManager.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/13/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kProductTitleKey @"com.birdSound.modmusica.sk.title"
#define kProductPurchasedKey @"com.birdSound.modmusica.sk.purchased"
#define kProductPriceKey @"com.birdSound.modmusica.sk.price"
#define kProductDescriptionKey @"com.birdSound.modmusica.sk.description"
#define kProductFormattedPriceKey @"com.birdSound.modmusica.sk.formatted.price"
#define kProductContentPathKey @"com.birdSound.modmusica.sk.content.path"

@interface MMModuleManager : NSObject

+ (void)setupDefaultMods;
+ (NSArray *)availableMods;
+ (NSArray *)purchasedMods;
+ (NSArray *)availableModNames;
+ (NSArray *)purchasedModNames;
+ (NSDictionary *)getMod:(NSString *)modName fromArray:(NSArray *)mods;

+ (void)purchaseMod:(NSString *)modName completion:(void(^)(BOOL success))completion;

@end
