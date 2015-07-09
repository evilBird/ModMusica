//
//  MMFileReader.h
//  ModMusica
//
//  Created by Travis Henspeter on 10/30/14.
//  Copyright (c) 2014 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMFileReader : NSObject

+ (NSArray *)readFileAtPath:(NSString *)filePath;
//+ (NSArray *)readFile:(NSString *)fileName;
//+ (NSArray *)headerForFile:(NSString *)fileName;
+ (NSArray *)headerForFileAtPath:(NSString *)filePath;
//+ (NSArray *)readFile:(NSString *)fileName section:(NSInteger)section length:(NSInteger)length;
+ (NSArray *)readFileAtPath:(NSString *)filePath section:(NSInteger)section length:(NSInteger)length;

@end
