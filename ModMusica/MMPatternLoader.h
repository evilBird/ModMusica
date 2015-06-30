//
//  MMPatternLoader.h
//  ModMusica
//
//  Created by Travis Henspeter on 10/30/14.
//  Copyright (c) 2014 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMPatternLoader.h"
#import "MMFileReader.h"

@interface MMPatternLoader : NSObject

@property (nonatomic,strong)NSString *currentPattern;
@property (nonatomic)NSInteger currentSection;

- (NSDictionary *)headerComponents;
- (NSArray *)patternData;

- (void)setPattern:(NSString *)pattern;
- (void)playNextSection;
- (void)playPreviousSection;
- (void)playSection:(NSInteger)section;

@end
