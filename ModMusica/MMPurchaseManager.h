//
//  MMPurchaseManager.h
//  ModMusica
//
//  Created by Travis Henspeter on 7/8/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface MMPurchaseManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic,strong)        NSMutableSet            *products;

- (void)getProductsCompletion:(void(^)(NSArray *products, NSError *error))completion;
- (void)buyProduct:(NSString *)productName completion:(void(^)(id product, NSError *error))completion;

- (void)buyProduct:(NSString *)productName
          progress:(void(^)(id product, double downloadProgress))progress
        completion:(void(^)(id product, NSError *error))completion;


@end
