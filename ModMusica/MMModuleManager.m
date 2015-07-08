//
//  MMModuleManager.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/13/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMModuleManager.h"
#import "NSUserDefaults+Mods.h"
#import "MMPurchaseManager.h"



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
    NSArray *purchased = [MMModuleManager purchasedMods];
    NSMutableArray *products = [[MMPurchaseManager sharedInstance]products].allObjects.mutableCopy;
    NSMutableSet *available = [[NSMutableSet alloc]init];
    NSMutableSet *names = [[NSMutableSet alloc]init];
    
    for (SKProduct *product in products) {
        NSString *name = product.localizedTitle;
        if (![names containsObject:name]) {
            NSNumber *price = product.price;
            NSString *description = product.description;
            NSMutableDictionary *mod = [NSMutableDictionary dictionary];
            mod[kProductTitleKey] = name;
            mod[kProductPriceKey] = price;
            mod[kProductDescriptionKey] = description;
            
            NSString *formattedString = nil;
            if (price.integerValue == 0) {
                formattedString = @"FREE";
            }else{
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
                [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                [numberFormatter setLocale:product.priceLocale];
                formattedString = [numberFormatter stringFromNumber:product.price];
            }
            
            mod[kProductFormattedPriceKey] = formattedString;
            if ([MMModuleManager getMod:name fromArray:purchased]) {
                mod[kProductPurchasedKey] = @(1);
            }else{
                mod[kProductPurchasedKey] = @(0);
            }
            
            [available addObject:mod];
        }
        
        [names addObject:name];
    }
    
    return [NSArray arrayWithArray:available.allObjects];
    
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
    
    
    [[MMPurchaseManager sharedInstance]buyProduct:modName completion:^(id product, NSError *error) {
        
        NSMutableDictionary *purchasedMod = [MMModuleManager getMod:modName fromArray:[MMModuleManager availableMods]].mutableCopy;
        
        if (!error) {
            
            
            purchasedMod[kProductPurchasedKey] = @(1);
            
            [NSUserDefaults savePurchasedMod:[NSDictionary dictionaryWithDictionary:purchasedMod]];
            
            if (completion) {
                completion(YES);
            }
        }else{
            
            
            purchasedMod[kProductPurchasedKey] = @(0);
            if (completion) {
                completion(NO);
            }
        }
    }];
}



+ (NSArray *)namesForMods:(NSArray *)mods
{
    if (!mods || !mods.count) {
        return nil;
    }
    
    NSMutableArray *temp = [NSMutableArray array];
    for (NSDictionary *aMod in mods) {
        NSString *name = aMod[kProductTitleKey];
        [temp addObject:name];
    }
    
    return [NSArray arrayWithArray:temp];
}


+ (NSDictionary *)getMod:(NSString *)modName fromArray:(NSArray *)mods
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K MATCHES[cd] %@",kProductTitleKey,modName];
    NSArray *filtered = [mods filteredArrayUsingPredicate:pred];
    return filtered.firstObject;
}



@end
