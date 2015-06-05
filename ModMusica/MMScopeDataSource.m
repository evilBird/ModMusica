//
//  MMScopeDataSource.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/5/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMScopeDataSource.h"
#import "PdBase.h"

static NSString *kUpdateScopes = @"updateScopes";
static int kDefaultLength = 64;

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
    [MMScopeDataSource getScopeDataFromTable:self.sourceTable length:kDefaultLength completion:^(NSArray *data) {
        if (data && data.count) {
            [weakself.dataConsumer scopeData:weakself receivedData:data];
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
    return @[kBassTable,kSynthTable,kDrumTable,kSamplerTable,kKickTable,kSnareTable,kPercTable,kSynthTable1,kSynthTable2,kSynthTable3,kFuzzTable,kTremeloTable];
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
