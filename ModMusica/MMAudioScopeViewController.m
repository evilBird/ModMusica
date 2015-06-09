//
//  MMAudioScopeViewController.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/5/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMAudioScopeViewController.h"
#import "MMAudioScopeViewController+Layer.h"
#import "MMAudioScopeViewController+Path.h"
#import "UIColor+HBVHarmonies.h"
#import "UIView+Layout.h"

static NSString *kStartMessage = @"Press & hold to start";
static NSString *kStopMessage = @"Press & hold to stop";
static NSString *kTapTempoMessage = @"Tap to set tempo";

@interface MMAudioScopeViewController ()

@property (nonatomic,strong)        NSMutableArray          *scopeDataSources;
@property (nonatomic,strong)        NSMutableArray          *shapeLayers;
@property (nonatomic,strong)        NSMutableArray          *oldPaths;
@property (nonatomic,strong)        NSMutableArray          *oldColors;

@property (nonatomic,strong)        UILabel                 *label;
@property (nonatomic,strong)        UILabel                 *titleLabel;

@end

@implementation MMAudioScopeViewController

- (void)showDetails
{
    self.titleLabel.alpha = 1.0;
    self.label.alpha = 1.0;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideLabel) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideTitle) object:nil];
    
    [self performSelector:@selector(hideLabel) withObject:nil afterDelay:10];
    [self performSelector:@selector(hideTitle) withObject:nil afterDelay:10];
    
}

- (NSString *)messageTextPlaying:(BOOL)playing
{
    NSString *result = nil;
    NSString *start = NSLocalizedString(kStartMessage, nil);
    NSString *stop = NSLocalizedString(kStopMessage, nil);
    NSString *tap = NSLocalizedString(kTapTempoMessage, nil);
    
    if (playing) {
        result = [NSString stringWithFormat:@"%@\n\n%@",tap,stop];
    }else{
        result = [NSString stringWithFormat:@"%@",start];
    }
    
    return result;
}

- (void)hideTitle
{
    self.titleLabel.alpha = 0.0;
}

- (void)showLabel
{
    self.label.alpha = 1.0;
}

- (void)hideLabel
{
    self.label.alpha = 0.0;
}

- (void)beginUpdates
{
    for (MMScopeDataSource *source in self.scopeDataSources) {
        [source beginUpdates];
    }
    
    
    self.label.text = [self messageTextPlaying:YES];
    
    [UIView animateWithDuration:10.0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.label.alpha = 0.0;
                     } completion:NULL];
    
    [UIView animateWithDuration:10.0
                          delay:10.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.titleLabel.alpha = 0.0;
                     } completion:NULL];
}

- (void)endUpdates
{
    for (MMScopeDataSource *source in self.scopeDataSources) {
        [source endUpdates];
    }
    self.label.text = [self messageTextPlaying:NO];
    self.label.alpha = 1.0;
    self.titleLabel.alpha = 1.0;
}

- (void)showStepsPerMinute:(double)steps
{
    self.label.text = [NSString stringWithFormat:@"%.f steps/min",steps];
    [self showLabel];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideLabel) object:nil];
    [self performSelector:@selector(hideLabel) withObject:nil afterDelay:5];
}

- (void)showBeatsPerMinute:(double)bpm
{
    self.label.text = [NSString stringWithFormat:@"%.f beats/min",bpm];
    [self showLabel];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideLabel) object:nil];
    [self performSelector:@selector(hideLabel) withObject:nil afterDelay:5];
}

- (void)randomizeColors
{
    [self randomizeColorsInShapeLayers:self.shapeLayers.mutableCopy];
    [self randomizeAlphasInShapeLayers:self.shapeLayers coefficient:0.2];
    self.view.backgroundColor = [UIColor randomColor];
    self.label.textColor = [[self.view backgroundColor]complement];
    self.titleLabel.textColor = [[self.view backgroundColor]complement];
}

- (MMScopeDataSource *)newScopeDataSource:(NSString *)table
{
    MMScopeDataSource *scopeData = [[MMScopeDataSource alloc]initWithUpdateInterval:0.1 sourceTable:table];
    scopeData.dataConsumer = self;
    return scopeData;
}

- (void)configureLayersAndData
{
    self.scopeDataSources = [NSMutableArray array];
    self.shapeLayers = [NSMutableArray array];
    NSArray *scopeNames = [MMScopeDataSource allTableNames];
    self.oldPaths = [self setupPathBuffers:scopeNames.count].mutableCopy;
    for (NSString *name in scopeNames) {
        MMScopeDataSource *datasource = [self newScopeDataSource:name];
        [self.scopeDataSources addObject:datasource];
        CAShapeLayer *layer = [self newShapeLayer];
        [self.shapeLayers addObject:layer];
        [self.view.layer addSublayer:layer];
    }
}


- (void)configureLabels
{
    self.label = [UILabel new];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    self.label.numberOfLines = 4;
    self.label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:[UIFont labelFontSize]];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.textColor = [self.view.backgroundColor complement];
    self.label.text = [self messageTextPlaying:NO];
    
    self.titleLabel = [UILabel new];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:[UIFont labelFontSize]*2.7];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [self.view.backgroundColor complement];
    self.titleLabel.text = NSLocalizedString(@"ModMusica", nil);
}

- (void)configureLabelConstraints
{
    [self.view addConstraint:[self.label alignCenterXToSuperOffset:0]];
    [self.view addConstraint:[self.label pinEdge:LayoutEdge_Bottom
                                          toEdge:LayoutEdge_Bottom
                                          ofView:self.view
                                       withInset:-20]];
    [self.view addConstraint:[self.titleLabel alignCenterXToSuperOffset:0]];
    [self.view addConstraint:[self.titleLabel pinEdge:LayoutEdge_Top
                                               toEdge:LayoutEdge_Top
                                               ofView:self.view
                                            withInset:28]];
    [self.view layoutIfNeeded];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureLayersAndData];
    [self.view setBackgroundColor:[UIColor randomColor]];
    [self configureLabels];
    [self.view addSubview:self.label];
    [self.view addSubview:self.titleLabel];
    [self configureLabelConstraints];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MMScopeDataConsumer

- (void)scope:(id)sender receivedData:(NSArray *)data
{
    if (!self.scopeDataSources || ![self.scopeDataSources containsObject:sender]) {
        return;
    }
    MMScopeDataSource *source = sender;
    NSUInteger index = [self.scopeDataSources indexOfObject:source];
    CAShapeLayer *layer = self.shapeLayers[index];
    
    UIBezierPath *newPath = [self pathWithScopeData:data];
    if (newPath == nil) {
        return;
    }
    
    UIBezierPath *oldPath = nil;
    
    if (self.oldPaths) {
        oldPath = self.oldPaths[index];
    }
    
    [self animateLayer:layer
               newPath:newPath
               oldPath:oldPath
              duration:source.interval];
    
    self.oldPaths[index] = newPath;
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
