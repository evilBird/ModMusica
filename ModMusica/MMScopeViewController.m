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

static NSInteger kNumPoints = 64;
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
        self.scopeView.animateDuration = _timeInterval;
    }
}

- (void)start
{
    self.updateTimer = nil;
    self.running = YES;
    [PdBase sendBangToReceiver:@"clearScopes"];
    [PdBase sendFloat:1 toReceiver:@"onOff"];
    self.messageLabel.text = NSLocalizedString(@"press and hold to stop", nil);
    [self update];
    [self.playbackDelegate playbackStarted];
    [UIView animateWithDuration:5.0
                          delay:5.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         self.messageLabel.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             [self.messageLabel removeFromSuperview];
                         });
                     }];
}

- (void)stop
{
    [PdBase sendBangToReceiver:@"clearScopes"];
    [self update];
    [self.playbackDelegate playbackStopped];
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
}

- (void)updateScope:(NSInteger)scope
{
    NSArray *scopes = @[kTableName,kBassTable,kSamplerTable,kSynthTable,kDrumTable,kKickTable,kSnareTable,kPercTable,kSynthTable1,kSynthTable2,kSynthTable3,kFuzzTable,kTremeloTable];
    
    if (scope >= scopes.count) {
        return;
    }
    
    CGFloat verticalOffsetRange = CGRectGetHeight(self.scopeView.bounds);
    CGFloat width = (CGFloat)arc4random_uniform(100) * 0.25;
    CGFloat verticalOffset = (CGFloat)arc4random_uniform(verticalOffsetRange) - verticalOffsetRange * 0.5;
    NSString *scopeName = scopes[scope];
    NSArray *points = [self getNewDataFromSource:scopeName verticalOffset:verticalOffset];
    CGFloat count = (CGFloat)self.scopeView.layer.sublayers.count + 1;
    CGFloat progress = (CGFloat)scope/(CGFloat)count;
    CGFloat remaining = 1.0f - progress;
    UIColor *color = [self.scopeView.backgroundColor colorHarmonyWithExpression:^CGFloat(CGFloat value) {
        return value/(CGFloat)((scope + 1) * 2.0f);
    } alpha:remaining];
    
    if (scope%3 == 0) {
        color = [UIColor randomColor];
    }
    
    __weak MMScopeViewController *weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.scopeView animateLineDrawingWithPoints:points
                                               width:width
                                               color:color
                                            duration:weakself.timeInterval
                                               index:scope];
    });


    
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.isRunning) {
        [self start];
        return;
    }
    
    self.touchTimer = nil;
    self.touchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(handleTouchTimer:) userInfo:nil repeats:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.touchTimer invalidate];
    self.touchTimer = nil;
}

- (void)handleTouchTimer:(id)sender
{
    if (self.isRunning) {
        [self stop];
    }else{
        [self start];
    }
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
