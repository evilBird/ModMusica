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

+ (void)setupDefaultMods
{
    if (![MMModuleManager purchasedMods]) {
        NSDictionary *defaultMod1 = [MMModuleManager setupDefaultMod:@"fantasy" numPatterns:2];
        if (defaultMod1) {
            [NSUserDefaults savePurchasedMod:defaultMod1];
        }
    }
}

+ (NSDictionary *)setupDefaultMod:(NSString *)modName numPatterns:(NSUInteger)numPatterns
{
    NSMutableDictionary *defaultMod = [NSMutableDictionary dictionary];
    defaultMod[kProductTitleKey] = modName;
    defaultMod[kProductPriceKey] = @(0);
    defaultMod[kProductFormattedPriceKey] = @"FREE";
    defaultMod[kProductPurchasedKey] = @(1);
    defaultMod[kProductDescriptionKey] = modName;
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *folderPath = [documentsPath stringByAppendingPathComponent:modName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:folderPath]) {
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSError *err = nil;
    
    for (NSUInteger i = 0; i < numPatterns; i++) {
        NSString *patternName = [NSString stringWithFormat:@"%@-%@",@(i),modName];
        NSString *bundlePath = [[NSBundle mainBundle]pathForResource:patternName ofType:@".csv"];
        NSString *docsPath = [folderPath stringByAppendingPathComponent:[patternName stringByAppendingPathExtension:@"csv"]];
        [fileManager copyItemAtPath:bundlePath toPath:docsPath error:&err];
        
        if (err) {
            break;
        }
    }
    
    if (err) {
        return nil;
    }
    
    defaultMod[kProductContentPathKey] = folderPath;
    return defaultMod;
}


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
    [available addObjectsFromArray:purchased];
    
    for (SKProduct *product in products) {
        NSString *name = product.localizedTitle;
        NSArray *myNames = [MMModuleManager namesForMods:available.allObjects];
        if (![myNames containsObject:name]) {
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
        
    }
    
    return [NSArray arrayWithArray:available.allObjects];
    
}

+ (void)purchaseMod:(NSString *)modName completion:(void(^)(BOOL success))completion
{
    if (!completion) {
        return;
    }
    
    if (!modName || !modName.length) {
        completion(NO);
        return;
    }
    
    if (![MMModuleManager getMod:modName fromArray:[MMModuleManager availableMods]])
    {
        completion(NO);
        return;
    }
    
    
    if ([MMModuleManager getMod:modName fromArray:[MMModuleManager purchasedMods]]) {
        completion(YES);
        return;
    }
    
    
    [[NSOperationQueue new]addOperationWithBlock:^{
        [[MMPurchaseManager sharedInstance]buyProduct:modName completion:^(id product, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    NSString *contentPath = product;
                    NSMutableDictionary *purchasedMod = [MMModuleManager getMod:modName fromArray:[MMModuleManager availableMods]].mutableCopy;
                    NSString *productContentPath = [contentPath stringByAppendingPathComponent:@"Contents"];
                    purchasedMod[kProductPurchasedKey] = @(1);
                    purchasedMod[kProductContentPathKey] = productContentPath;
                    
                    [NSUserDefaults savePurchasedMod:[NSDictionary dictionaryWithDictionary:purchasedMod]];
                    
                    if (completion) {
                        completion(YES);
                    }
                }else{
                    
                    if (completion) {
                        completion(NO);
                    }
                }
                
            });
        }];
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
