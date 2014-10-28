//
//  HBVOperation.h
//  Herbivore
//
//  Created by Travis Henspeter on 2/17/14.
//  Copyright (c) 2014 Herbivore. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^HBVOperationBlock)(void);

@interface HBVOperation : NSOperation

@property (nonatomic, strong) HBVOperationBlock block;

@end
