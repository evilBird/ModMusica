//
//  NSUserDefaults+Mods.h
//  ModMusica
//
//  Created by Travis Henspeter on 7/8/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Mods)

+ (NSArray *)purchasedMods;
+ (void)savePurchasedMod:(NSDictionary *)mod;

@end
