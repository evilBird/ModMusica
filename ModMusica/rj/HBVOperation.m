//
//  HBVOperation.m
//  Herbivore
//
//  Created by Travis Henspeter on 2/17/14.
//  Copyright (c) 2014 Herbivore. All rights reserved.
//

#import "HBVOperation.h"

@implementation HBVOperation : NSOperation

- (void)main {
    // a lengthy operation
    NSLog(@"performing operation...");
    @autoreleasepool {
        
        self.block();

    }
}


@end
