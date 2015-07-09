//
//  MMFileReader.m
//  ModMusica
//
//  Created by Travis Henspeter on 10/30/14.
//  Copyright (c) 2014 birdSound. All rights reserved.
//

#import "MMFileReader.h"

@implementation MMFileReader
/*
+ (NSArray *)readFile:(NSString *)fileName
{
    NSError *err = nil;
    NSArray *components = [fileName componentsSeparatedByString:@"."];
    if (components.count < 2) {
        return nil;
    }
    
    NSString *path = [[NSBundle mainBundle]pathForResource:components.firstObject ofType:components.lastObject];
    NSString *fileText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    return [MMFileReader parseText:fileText];
}
*/
+ (NSArray *)readFileAtPath:(NSString *)filePath
{
    NSError *err = nil;
    NSString *fileText = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&err];
    if (err) {
        return nil;
    }
    
    return [MMFileReader parseText:fileText];
}
/*
+ (NSArray *)headerForFile:(NSString *)fileName
{
    NSError *err = nil;
    NSArray *components = [fileName componentsSeparatedByString:@"."];
    if (components.count < 2) {
        return nil;
    }
    NSString *path = [[NSBundle mainBundle]pathForResource:components.firstObject ofType:components.lastObject];
    NSString *fileText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    return [MMFileReader extractHeader:fileText];
}
*/
+ (NSArray *)headerForFileAtPath:(NSString *)filePath
{
    NSError *err = nil;
    NSString *fileText = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&err];
    if (err) {
        return nil;
    }
    
    return [MMFileReader extractHeader:fileText];
}

+ (NSArray *)extractHeader:(NSString *)text
{
    if (!text) {
        return nil;
    }
    
    NSArray *rows = [text componentsSeparatedByString:@"\n"];
    NSRange headerRange;
    headerRange.location = 0;
    headerRange.length = 6;
    NSIndexSet *headerIndexSet = [NSIndexSet indexSetWithIndexesInRange:headerRange];
    NSArray *header = [rows objectsAtIndexes:headerIndexSet];
    return header;
}

+ (NSArray *)readFileAtPath:(NSString *)filePath section:(NSInteger)section length:(NSInteger)length
{
    NSArray *allRows = [MMFileReader readFileAtPath:filePath];
    if (!allRows) {
        return nil;
    }
    NSInteger startIndex = section * length;
    NSInteger stopIndex = startIndex + length;
    return [MMFileReader readFromRows:allRows startIndex:startIndex stopIndex:stopIndex];
}
/*
+ (NSArray *)readFile:(NSString *)fileName section:(NSInteger)section length:(NSInteger)length
{
    NSArray *allRows = [self readFile:fileName];
    NSInteger startIndex = section * length;
    NSInteger stopIndex = startIndex + length;
    return [MMFileReader readFromRows:allRows startIndex:startIndex stopIndex:stopIndex];
}
 */

+ (NSArray *)parseText:(NSString *)text
{
    if (!text) {
        return nil;
    }
    
    NSArray *rows = [text componentsSeparatedByString:@"\n"];
    NSMutableArray *rowsCopy = rows.mutableCopy;
    NSRange headerRange;
    headerRange.location = 0;
    headerRange.length = 6;
    NSIndexSet *headerIndexSet = [NSIndexSet indexSetWithIndexesInRange:headerRange];
    [rowsCopy removeObjectsAtIndexes:headerIndexSet];
    if (!rowsCopy) {
        return nil;
    }
    
    return [MMFileReader readFromRows:rowsCopy startIndex:0 stopIndex:rowsCopy.count];

}

+ (void)handleHeader:(NSArray *)header
{
    NSLog(@"header: %@",header);
}

+ (NSArray *)readFromRows:(NSArray *)allRows startIndex:(NSInteger)startIndex stopIndex:(NSInteger)stopIndex
{
    if (stopIndex > allRows.count) {
        return nil;
    }
    NSRange range;
    range.location = startIndex;
    range.length = stopIndex;
    NSIndexSet *indices = [NSIndexSet indexSetWithIndexesInRange:range];
    NSArray *rows = [allRows objectsAtIndexes:indices];
    
    NSMutableArray *result = nil;
    
    for (NSString *row in rows) {
        NSString *values = [row stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        values = [values stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSArray *columns = [values componentsSeparatedByString:@","];
        NSInteger idx = 0;
        for (NSString *value in columns) {
            if (result == nil) {
                result = [NSMutableArray array];
            }
            
            NSMutableArray *columnArray = nil;
            if (result.count <= idx) {
                columnArray = [NSMutableArray array];
                [columnArray addObject:@(idx)];
                [result addObject:columnArray];
            }else{
                columnArray = result[idx];
            }

            NSInteger integer = value.integerValue;
            [columnArray addObject:@(integer)];
            
            idx ++;
        }
    }
    
    return result;
}

@end
