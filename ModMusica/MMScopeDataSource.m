//
//  MMScopeDataSource.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/5/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMScopeDataSource.h"
#import "PdBase.h"
#import <UIKit/UIKit.h>

static NSString *kUpdateScopes = @"updateScopes";
static double sampsPerWidth = 0.2;

@interface MMScopeDataSource ()


@end

@implementation MMScopeDataSource

- (instancetype)initWithUpdateInterval:(NSTimeInterval)interval sourceTable:(NSString *)table
{
    self = [super init];
    if (self) {
        _interval = interval;
        _sourceTable = table;
    }
    
    return self;
}

- (void)handleUpdateTimer:(id)sender
{
    __weak MMScopeDataSource *weakself = self;
    double width = [UIScreen mainScreen].bounds.size.width;
    int length = (int)(width *sampsPerWidth);
    [MMScopeDataSource getScopeDataFromTable:self.sourceTable length:length completion:^(NSArray *data) {
        if (data && data.count) {
            [weakself.dataConsumer scope:weakself receivedData:data];
        }
    }];
}

- (void)beginUpdates
{
    self.updating = YES;
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:self.interval
                                                        target:self
                                                      selector:@selector(handleUpdateTimer:)
                                                      userInfo:nil
                                                       repeats:YES];
    self.updateTimer.tolerance = (self.interval * 0.05);
    
}

- (void)endUpdates
{
    self.updating = NO;
    [self.updateTimer invalidate];
    self.updateTimer = nil;
}

- (void)dealloc
{
    if (self.isUpdating) {
        [self endUpdates];
    }
}

+ (NSArray *)allTableNames
{
    return @[kBassTable,kSynthTable,kDrumTable,kSamplerTable,kKickTable,kSnareTable,kPercTable,kSynthTable1,kSynthTable2,kSynthTable3,kFuzzTable,kTremeloTable,kInputTable,kRawInputTable];
}

+ (NSString *)randomTable
{
    NSArray *names = [MMScopeDataSource allTableNames];
    NSUInteger index = (NSUInteger)arc4random_uniform((UInt32)names.count);
    return names[index];
}

+ (void)getRandomScopeDataLength:(int)length completion:(void(^)(NSArray *data))completion
{
    NSString *table = [MMScopeDataSource randomTable];
    [MMScopeDataSource getScopeDataFromTable:table length:length completion:completion];
}

+ (void)sampleArray:(int)numSamples maxIndex:(int)maxIndex fromTable:(NSString *)table completion:(void(^)(float data[]))completion
{
    if (!table) {
        completion(nil);
        return;
    }
    
    int scopeArrayLength = [PdBase arraySizeForArrayNamed:table];
    
    if (scopeArrayLength <= maxIndex) {
        completion(nil);
        return;
    }
    
    int bufferSize = maxIndex + 1;
    float myData[bufferSize];
    float *temp = malloc(sizeof(float)*bufferSize);
    [PdBase copyArrayNamed:table withOffset:0 toArray:temp count:bufferSize];
    double stepSize = (double)maxIndex/(double)numSamples;
    for (int i = 0; i<bufferSize; i ++) {
        int idx = round(i*stepSize);
        float val = temp[idx];
        if (val!=val) {
            myData[i] = 0.0;
        }else{
            myData[i] = val;
        }
    }
    
    free(temp);
    completion(myData);
    [PdBase sendBangToReceiver:kUpdateScopes];
}

+ (void)getScopeDataFromTable:(NSString *)table length:(int)length completion:(void(^)(NSArray *data))completion
{
    if (!length || !table) {
        completion(nil);
        return;
    }
    
    int scopeArrayLength = [PdBase arraySizeForArrayNamed:table];
    
    if (scopeArrayLength < 1) {
        completion(nil);
        return;
    }
    
    [PdBase sendBangToReceiver:kUpdateScopes];
    float *rawPoints = malloc(sizeof(float) * scopeArrayLength);
    [PdBase copyArrayNamed:table withOffset:0 toArray:rawPoints count:scopeArrayLength];
    NSMutableArray *result = nil;
    int sum = 0;
    int stepSize = scopeArrayLength/(double)length;
    for (int i = 0; i < (length-1); i ++ ) {
        int idx = i*stepSize;
        float val = rawPoints[idx];
        if (val == val) {
            if (!result) {
                result = [NSMutableArray array];
            }
            sum += val;
            [result addObject:@(val)];
        }
    }
    
    float val = rawPoints[scopeArrayLength-1];
    
    [result addObject:@(val)];
    
    free(rawPoints);
    
    if (result) {
        completion([NSArray arrayWithArray:result]);
    }
}

@end
