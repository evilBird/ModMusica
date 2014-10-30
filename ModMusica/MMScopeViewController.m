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
static NSString *kKickTable = @"kickScope";
static NSString *kSnareTable = @"snareScope";
static NSString *kPercTable = @"percScope";
static NSString *kSynthTable1 = @"synthScope1";
static NSString *kSynthTable2 = @"synthScope2";
static NSString *kSynthTable3 = @"synthScope3";
static NSString *kFuzzTable = @"fuzzScope";
static NSString *kTremeloTable = @"tremeloScope";

@interface MMScopeViewController ()<MMScopeViewDelegate>

@property (strong, nonatomic) IBOutlet MMScopeView *scopeView;
@property (nonatomic,strong)NSTimer *updateTimer;
@property (nonatomic,strong)NSTimer *touchTimer;

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
    _timeInterval = 4.0;
    self.scopeView.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)setTimeInterval:(CGFloat)timeInterval
{
    if (timeInterval != _timeInterval) {
        _timeInterval = timeInterval;
        if (self.isRunning) {
            [self.updateTimer invalidate];
            self.updateTimer = nil;
            self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval
                                                                target:self
                                                              selector:@selector(update)
                                                              userInfo:nil
                                                               repeats:YES];
        }
    }
}

- (void)start
{
    self.updateTimer = nil;
    self.running = YES;
    [PdBase sendBangToReceiver:@"clearScopes"];
    [PdBase sendFloat:1 toReceiver:@"onOff"];
    self.messageLabel.text = NSLocalizedString(@"press and hold to stop", nil);
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(update) userInfo:nil repeats:YES];
    self.scopeView.animateDuration = self.timeInterval * 0.9;
    self.updateTimer.tolerance = self.timeInterval * 0.1;
    [UIView animateWithDuration:5.0
                     animations:^{
                         self.messageLabel.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             [self.messageLabel removeFromSuperview];
                         });
                     }];
}

- (void)stop
{
    [self.updateTimer invalidate];
    [PdBase sendBangToReceiver:@"clearScopes"];
    [self update];
    self.running = NO;
    [PdBase sendFloat:0 toReceiver:@"onOff"];
    [self.view addSubview:self.messageLabel];
    self.messageLabel.text = NSLocalizedString(@"tap anywhere to start", nil);
    [UIView animateWithDuration:0.5 animations:^{
        self.messageLabel.alpha = 1.0f;
    }];
}

- (void)update
{
    __weak MMScopeViewController *weakself = self;

    UIColor *newColor = [UIColor randomColor];
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:weakself.timeInterval animations:^{
            weakself.view.backgroundColor = newColor;
            weakself.scopeView.backgroundColor = newColor;
        }];
    });
    
    [PdBase sendBangToReceiver:@"updateScopes"];
    NSArray *scopes = @[kTableName,kBassTable,kSamplerTable,kSynthTable,kDrumTable,kKickTable,kSnareTable,kPercTable,kSynthTable1,kSynthTable2,kSynthTable3,kFuzzTable,kTremeloTable];
    NSInteger idx = 0;
    for (id scope in scopes) {
        CGFloat completion = (CGFloat)idx/(CGFloat)scopes.count;
        NSTimeInterval del = completion * self.timeInterval;
        CGFloat verticalOffsetRange = CGRectGetHeight(self.scopeView.bounds);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(del * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                CGFloat width = (CGFloat)arc4random_uniform(100) * 0.5;
                CGFloat verticalOffset = (CGFloat)arc4random_uniform(verticalOffsetRange) - verticalOffsetRange * 0.5;
                NSArray *points = [weakself getNewDataFromSource:scope verticalOffset:verticalOffset];
                UIColor *random = [UIColor randomColor];
                UIColor *color = [random colorHarmonyWithExpression:^CGFloat(CGFloat value) {
                    return value;
                } alpha:0.5];
                
                [weakself.scopeView animateLineDrawingWithPoints:points
                                                           width:width
                                                           color:color
                                                        duration:weakself.timeInterval
                                                           index:idx];
            }];
        });
        
        idx++;
    }
}

- (void)animateChangeColor:(UIColor *)newColor inView:(UIView *)view duration:(CGFloat)duration
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    animation.fromValue = view.backgroundColor;
    animation.toValue = newColor;
    animation.duration = duration;
    [view.layer addAnimation:animation forKey:@"colorAnimation"];
    [view.layer setValue:newColor forKey:@"backgroundColor"];
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

- (void)handleLongPress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized) {
        NSLog(@"gesture recognized");
        if (self.isRunning) {
            [self stop];
        }else{
            [self start];
        }
    }
}

- (void)touchesBeganInScopeView:(id)sender
{
    if (!self.isRunning) {
        [self start];
        return;
    }
    
    self.touchTimer = nil;
    self.touchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(handleTouchTimer:) userInfo:nil repeats:NO];
    
    //[PdBase sendBangToReceiver:@"tapTempo"];
}

- (void)handleTouchTimer:(id)sender
{
    if (self.isRunning) {
        [self stop];
    }else{
        [self start];
    }
}

- (void)touchesEndedInScopeView:(id)sender
{
    [self.touchTimer invalidate];
    self.touchTimer = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
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
