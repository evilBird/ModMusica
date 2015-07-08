//
//  MMModuleManager.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/13/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMModuleManager.h"
#import "NSUserDefaults+Mods.h"

#define kTitle @"title"
#define kPurchased @"purchased"

@implementation MMModuleManager

+ (NSArray *)availableModNames
{
    return [MMModuleManager namesForMods:[MMModuleManager availableMods]];
}

+ (NSArray *)purchasedModNames
{
    return [MMModuleManager namesForMods:[MMModuleManager purchasedMods]];
}

+ (NSArray *)purchasedMods
{
    return [NSUserDefaults purchasedMods];
}

+ (NSArray *)availableMods
{
    //TODO: Check app store for available mods
    NSArray *purchased = [MMModuleManager purchasedMods];
    NSArray *names = @[@"mario",@"fantasy",@"mega",@"menace",@"sad"];

    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:names.count];
    for (NSString *modName in names) {
        NSMutableDictionary *mod = [NSMutableDictionary dictionary];
        mod[kTitle] = modName;
        if ([MMModuleManager getMod:modName fromArray:purchased]) {
            mod[kPurchased] = @(1);
        }else{
            mod[kPurchased] = @(0);
        }
        
        [temp addObject:mod];
    }
    
    
    return [NSArray arrayWithArray:temp];
}

+ (void)purchaseMod:(NSString *)modName completion:(void(^)(BOOL success))completion
{

    
    if (!modName || !modName.length) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    if (![MMModuleManager getMod:modName fromArray:[MMModuleManager availableMods]] || [MMModuleManager getMod:modName fromArray:[MMModuleManager purchasedMods]])
    {
        if (completion) {
            completion(NO);
        }
        
        return;
    }
    
    //TODO: IAP
    BOOL successful = YES;
    NSMutableDictionary *purchasedMod = [MMModuleManager getMod:modName fromArray:[MMModuleManager availableMods]].mutableCopy;
    if (successful) {
        purchasedMod[kPurchased] = @(1);
    }else{
        purchasedMod[kPurchased] = @(0);
    }
    
    [NSUserDefaults savePurchasedMod:[NSDictionary dictionaryWithDictionary:purchasedMod]];
    if (completion) {
        completion(successful);
    }
}

+ (NSArray *)namesForMods:(NSArray *)mods
{
    if (!mods || !mods.count) {
        return nil;
    }
    
    NSMutableArray *temp = [NSMutableArray array];
    for (NSDictionary *aMod in mods) {
        NSString *name = aMod[kTitle];
        [temp addObject:name];
    }
    
    return [NSArray arrayWithArray:temp];
}


+ (NSDictionary *)getMod:(NSString *)modName fromArray:(NSArray *)mods
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K MATCHES[cd] %@",kTitle,modName];
    NSArray *filtered = [mods filteredArrayUsingPredicate:pred];
    return filtered.firstObject;
}



@end
