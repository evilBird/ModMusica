//
//  MMFileReader.h
//  ModMusica
//
//  Created by Travis Henspeter on 10/30/14.
//  Copyright (c) 2014 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMFileReader : NSObject

+ (NSArray *)readFile:(NSString *)fileName;
+ (NSArray *)readFile:(NSString *)fileName section:(NSInteger)section length:(NSInteger)length;


@end
