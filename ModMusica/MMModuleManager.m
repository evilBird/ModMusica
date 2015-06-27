//
//  MMModuleManager.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/13/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMModuleManager.h"

#define kTitle @"title"
#define kPurchased @"purchased"

@implementation MMModuleManager

+ (NSArray *)modNames
{
     return @[@"mario",@"fantasy",@"mega",@"menace",@"sad"];
}

+ (NSArray *)mods
{
    NSMutableArray *temp = [NSMutableArray array];
    NSArray *names = [MMModuleManager modNames];
    for (NSString *name in names) {
        [temp addObject:@{kTitle:name,kPurchased:@(1)}];
    }
    
    return [NSArray arrayWithArray:temp];
}

@end
