//
//  ModMelodyEditorViewController+Data.m
//  ModMusica
//
//  Created by Travis Henspeter on 7/2/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ModMelodyEditorViewController+Data.h"
#import "ModMelodyEditorViewController+Switches.h"

@implementation ModMelodyEditorViewController (Data)

- (NSArray *)editedData
{
    NSMutableArray *temp = [NSMutableArray array];
    NSUInteger i = 0;
    for (NSNumber *aTag in self.stepPitchTags.mutableCopy) {
        NSInteger tagVal = aTag.integerValue;
        NSUInteger newPitch = [self pitchFromSwitchIndex:tagVal step:i];
        [temp addObject:@(newPitch)];
        i++;
    }
    
    return [NSArray arrayWithArray:temp];
}

- (NSArray *)formattedEditedData
{
    NSMutableArray *temp = [NSMutableArray array];
    [temp addObject:@([self.delegate currentVoiceIndex])];
    [temp addObjectsFromArray:[self editedData]];
    return [NSArray arrayWithArray:temp];
}

- (void)setupStepPitchTags
{
    [self setupStepPitchTags:[self getSavedData]];
}

- (void)setupStepPitchTags:(NSArray *)data
{
    self.minPitch = [self minPitchInData:data];
    self.maxPitch = [self maxPitchInData:data];
    self.stepPitchTags = [self stepPitchTagsWithData:data].mutableCopy;
}

- (NSArray *)getSavedData
{
    return [self getSavedDataVoice:[self.delegate currentVoiceIndex]];
}

- (NSArray *)getSavedDataVoice:(NSUInteger)voiceIndex
{
    if (!self.datasource) {
        return nil;
    }
    
    NSArray *allData = [self.datasource patternData];
    if (!allData) {
        return nil;
    }
    
    NSMutableArray *rawData = [allData[voiceIndex]mutableCopy];
    [rawData removeObjectAtIndex:0];
    NSArray *data = [NSArray arrayWithArray:rawData];
    
    return data;
}

- (NSUInteger)maxPitchInData:(NSArray *)data
{
    NSNumber *max = [data valueForKeyPath:@"@max.self"];
    return max.unsignedIntegerValue;
}

- (NSUInteger)minPitchInData:(NSArray *)data
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"self > 0"];
    NSArray *filteredData = [data filteredArrayUsingPredicate:pred];
    NSNumber *min = [filteredData valueForKeyPath:@"@min.self"];
    return min.unsignedIntegerValue;
}


- (NSArray *)stepPitchTagsWithData:(NSArray *)data
{
    NSAssert(data.count == [self.datasource numSteps], @"num steps %@ doesn't match pattern length %@",@(data.count),@([self.datasource numSteps]));
    
    NSMutableArray *temp = [NSMutableArray array];
    NSEnumerator *dataEnum = data.objectEnumerator;
    
    for (NSInteger i = 0; i < [self.datasource numSteps]; i++) {
        NSNumber *data = [dataEnum nextObject];
        
        if (!data) {
            temp[i] = [NSNumber numberWithInteger:-1];
        }else{
            NSInteger index = [self switchIndexFromPitch:data.integerValue step:i];
            temp[i] = [NSNumber numberWithInteger:index];
        }
    }
    
    return temp;
}

@end
