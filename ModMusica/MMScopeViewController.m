//
//  MMScopeViewController.m
//  ModMusica
//
//  Created by Travis Henspeter on 10/27/14.
//  Copyright (c) 2014 birdSound. All rights reserved.
//

#import "MMScopeViewController.h"
#import "MMScopeView.h"
#import <PdBase.h>
#import "UIColor+HBVHarmonies.h"

static NSInteger kNumPoints = 100;
static NSString *kTableName = @"scopeArray";
static NSString *kBassTable = @"bassScope";
static NSString *kSynthTable = @"synthScope";
static NSString *kDrumTable = @"drumScope";
static NSString *kSamplerTable = @"samplerScope";

@interface MMScopeViewController ()

@property (strong, nonatomic) IBOutlet MMScopeView *scopeView;
@property (nonatomic)CGFloat timeInterval;
@property (nonatomic,strong)NSTimer *updateTimer;
@end

CGFloat wrapValue(CGFloat value, CGFloat min, CGFloat max)
{
    CGFloat range = max - min;
    
    if (value < min) {
        value += range;
    }
    
    if (value > max) {
        value -= range;
    }
    
    return value;
}

@implementation MMScopeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [PdBase sendFloat:1 toReceiver:@"sampleRate"];
    [PdBase sendBangToReceiver:@"loadNewSamples"];
    [PdBase sendFloat:512 toReceiver:@"resizeScopes"];
    [PdBase sendBangToReceiver:@"clearScopes"];
    // Do any additional setup after loading the view.
}

- (void)start
{
    self.updateTimer = nil;
    self.running = YES;
    self.timeInterval = 0.5;
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(update) userInfo:nil repeats:YES];
    self.scopeView.animateDuration = self.timeInterval * 0.9;
    self.updateTimer.tolerance = self.timeInterval * 0.1;
}

- (void)stop
{
    [self.updateTimer invalidate];
    [PdBase sendBangToReceiver:@"clearScopes"];
    [self update];
    self.running = NO;
}

- (void)update
{
    if (self.view.backgroundColor == [UIColor whiteColor] || self.view.backgroundColor == [UIColor blackColor]) {
        self.view.backgroundColor = [UIColor randomColor];
        self.scopeView.alpha = 1;
    }
    
    __weak MMScopeViewController *weakself = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        weakself.view.backgroundColor = [self.view.backgroundColor jitterWithPercent:10];
        weakself.scopeView.backgroundColor = self.view.backgroundColor;
    });

    [PdBase sendBangToReceiver:@"updateScopes"];
    NSArray *scopes = @[kTableName,kBassTable,kSamplerTable,kSynthTable,kDrumTable];
    
    NSInteger idx = 0;
    for (id scope in scopes) {
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            NSArray *points = [weakself getNewDataFromSource:scope verticalOffset:idx * 20];
            [weakself.scopeView animateLineDrawingWithPoints:points
                                                       width:10
                                                       color:[weakself.view.backgroundColor jitterWithPercent:33]
                                                    duration:weakself.timeInterval
                                                       index:idx];
        }];
        idx++;
    }
}

- (NSArray *)getNewDataFromSource:(NSString *)source
{
    return [self getNewDataFromSource:source verticalOffset:0];
}

- (NSArray *)getNewDataFromSource:(NSString *)source verticalOffset:(CGFloat)offset
{
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    CGFloat midY = CGRectGetMidY(self.view.bounds) + offset;
    CGFloat x_int = width/(CGFloat)kNumPoints;
    CGFloat scale = height * 0.5;
    CGFloat xinset = 6;
    int scopeArrayLength = [PdBase arraySizeForArrayNamed:source];
    if (scopeArrayLength < 1) {
        return nil;
    }
    float *rawPoints = malloc(sizeof(float) * scopeArrayLength);
    [PdBase copyArrayNamed:source withOffset:0 toArray:rawPoints count:scopeArrayLength];
    NSMutableArray *result = nil;
    
    for (int i = 0; i<kNumPoints; i++) {
        
        int sampleIdx = i * scopeArrayLength/kNumPoints;
        if (!result) {
            result = [NSMutableArray array];
        }
        
        float value = rawPoints[sampleIdx];
        if (value!=value) {
            value = 0.0;
        }
        
        float norm = (value + 1.0f) * 0.5f;
        CGFloat x = i * x_int + xinset;
        CGFloat y = midY - norm * scale;
        
        if (y!=y) {
            y = 0.0f;
        }
        CGPoint point = CGPointMake(x, y);
        NSValue *val = [NSValue valueWithCGPoint:point];
        [result addObject:val];
    }
    
    return result;
}

#pragma mark - MMScopeViewDelegate
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
