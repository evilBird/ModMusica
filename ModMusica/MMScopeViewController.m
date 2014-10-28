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

static NSInteger kNumPoints = 20;
static NSString *kTableName = @"scopeArray";

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
    [PdBase sendFloat:256 toReceiver:@"resizeScopeArray"];
    self.timeInterval = 0.5;
    self.scopeView.animateDuration = self.timeInterval * 0.9;
    // Do any additional setup after loading the view.
}

- (void)start
{
    self.updateTimer = nil;
    self.running = YES;
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(update) userInfo:nil repeats:YES];
    self.updateTimer.tolerance = self.timeInterval * 0.1;
}

- (void)stop
{
    [self.updateTimer invalidate];
    self.running = NO;
}

- (void)update
{
    [self.scopeView displayData:[self getNewDataFromSource:kTableName]];
}

- (NSArray *)getNewDataFromSource:(NSString *)source
{
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    CGFloat midY = CGRectGetMidY(self.view.bounds);
    CGFloat x_int = width/(CGFloat)kNumPoints;
    CGFloat scale = height * 0.5;
    CGFloat xinset = 6;
    [PdBase sendBangToReceiver:@"updateScope"];
    int scopeArrayLength = [PdBase arraySizeForArrayNamed:source];
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
