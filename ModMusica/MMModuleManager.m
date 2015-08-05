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

+ (id)modName:(NSString *)modName valueForKey:(NSString *)key
{
    NSDictionary *mod = [MMModuleManager getMod:modName fromArray:[MMModuleManager purchasedMods]];
    if (!mod) {
        return nil;
    }
    
    if (![mod.allKeys containsObject:key]) {
        return nil;
    }
    
    return mod[key];
}

+ (void)setupDefaultMods
{
    if (![MMModuleManager purchasedMods]) {
        //[NSUserDefaults savePurchasedMod:[MMModuleManager setupDefaultMod:@"gushies"]];
        //[NSUserDefaults savePurchasedMod:[MMModuleManager setupDefaultMod:@"mario"]];
    }
}

+ (NSDictionary *)setupDefaultMod:(NSString *)modName
{
    NSMutableDictionary *defaultMod = [NSMutableDictionary dictionary];
    defaultMod[kProductTitleKey] = modName;
    defaultMod[kProductPriceKey] = @(0);
    defaultMod[kProductFormattedPriceKey] = @"FREE";
    defaultMod[kProductPurchasedKey] = @(1);
    defaultMod[kProductDescriptionKey] = modName;
    defaultMod[kProductIDKey] = [NSString stringWithFormat:@"com.birdSound.modmusica.%@",modName];
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *folderPath = [documentsPath stringByAppendingPathComponent:defaultMod[kProductIDKey]];
    NSString *bundlePath = [[NSBundle mainBundle]pathForResource:defaultMod[kProductIDKey] ofType:nil];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *err = nil;
    
    if (![fileManager fileExistsAtPath:folderPath]) {
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&err];
        if (err) {
            return nil;
        }
        
        [fileManager copyItemAtPath:bundlePath toPath:documentsPath error:&err];
        if (err) {
            return nil;
        }
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
            mod[kProductIDKey] = product.productIdentifier;
            
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
