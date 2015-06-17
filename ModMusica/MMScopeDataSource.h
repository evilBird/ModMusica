//
//  MMScopeDataSource.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/5/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *kTableName = @"scopeArray";
static NSString *kBassTable = @"bassScope";
static NSString *kSynthTable = @"synthScope";
static NSString *kDrumTable = @"drumScope";
static NSString *kSamplerTable = @"samplerScope";
static NSString *kKickTable = @"kickScope";
static NSString *kSnareTable = @"snareScope";
static NSString *kPercTable = @"percScope";
static NSString *kSynthTable1 = @"synthScope1";
static NSString *kSynthTable2 = @"synthScope2";
static NSString *kSynthTable3 = @"synthScope3";
static NSString *kFuzzTable = @"fuzzScope";
static NSString *kTremeloTable = @"tremeloScope";
static NSString *kInputTable = @"inputScope";
static NSString *kRawInputTable = @"rawInputTable";

@protocol MMScopeDataSourceConsumer <NSObject>

- (void)scope:(id)sender receivedData:(NSArray *)data;

@end

@interface MMScopeDataSource : NSObject

+ (NSArray *)allTableNames;

+ (void)getRandomScopeDataLength:(int)length completion:(void(^)(NSArray *data))completion;

+ (void)getScopeDataFromTable:(NSString *)table length:(int)length completion:(void(^)(NSArray *data))completion;

+ (void)sampleArray:(int)numSamples maxIndex:(int)maxIndex fromTable:(NSString *)table completion:(void(^)(float data[], int n))completion;

- (instancetype)initWithUpdateInterval:(NSTimeInterval)interval sourceTable:(NSString *)table;

- (void)beginUpdates;
- (void)endUpdates;

@property (nonatomic,strong)                NSString                        *sourceTable;
@property (nonatomic,getter=isUpdating)     BOOL                            updating;
@property (nonatomic,weak)                  id<MMScopeDataSourceConsumer>   dataConsumer;
@property (nonatomic)                       NSTimeInterval                  interval;
@property (nonatomic,strong)                NSTimer                         *updateTimer;

@end
