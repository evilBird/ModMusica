//
//  NSUserDefaults+Mods.m
//  ModMusica
//
//  Created by Travis Henspeter on 7/8/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "NSUserDefaults+Mods.h"

static NSString *kModMusicaPurchasedItemsKey = @"com.birdSound.modmusica.purchased";

@implementation NSUserDefaults (Mods)

+ (void)printPurchasedMods
{
    NSLog(@"\n\nPURCHASED MODS:\n%@\n\n",[NSUserDefaults purchasedMods]);
}

+ (NSArray *)purchasedMods
{
    NSArray *mods = nil;
    mods = [[NSUserDefaults standardUserDefaults]valueForKey:kModMusicaPurchasedItemsKey];
    return mods;
}

+ (void)savePurchasedMod:(NSDictionary *)mod
{
    if (!mod) {
        return;
    }
    
    NSArray *purchasedMods = [NSUserDefaults purchasedMods];
    NSMutableArray *purchasedModsCopy = nil;
    
    if (purchasedMods && purchasedMods.count) {
        purchasedModsCopy = purchasedMods.mutableCopy;
    }else{
        purchasedModsCopy = [NSMutableArray array];
    }
    
    [purchasedModsCopy addObject:mod];
    NSArray *updatedPurchasedMods = [NSArray arrayWithArray:purchasedModsCopy];
    [[NSUserDefaults standardUserDefaults]setValue:updatedPurchasedMods forKey:kModMusicaPurchasedItemsKey];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


@end
