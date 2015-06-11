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
#import "MMAudioScopeViewController+Label.h"
#import "UIColor+HBVHarmonies.h"
#import "UIView+Layout.h"

static NSString *kStartMessage = @"press & hold to start";
static NSString *kStopMessage = @"press & hold to stop";
static NSString *kTapTempoMessage = @"tap to set tempo";

@interface MMAudioScopeViewController ()

@property (nonatomic,strong)        NSMutableArray          *scopeDataSources;
@property (nonatomic,strong)        NSMutableArray          *shapeLayers;
@property (nonatomic,strong)        NSMutableArray          *oldPaths;
@property (nonatomic,strong)        NSMutableArray          *oldColors;
@property (nonatomic,strong)        UIVisualEffectView      *effectsView;
@end

@implementation MMAudioScopeViewController

- (void)tapInHamburgerButton:(id)sender
{
    [self.delegate showSettings:self];
}

- (void)showDetails
{
    [self showAllForDuration:10];
}

- (void)beginUpdates
{
    self.updating = YES;
    
    for (MMScopeDataSource *source in self.scopeDataSources) {
        [source beginUpdates];
    }
    
    [UIView animateWithDuration:10.0
                          delay:5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self hideAll];
                     } completion:NULL];

}

- (void)endUpdates
{
    self.updating = NO;
    
    for (MMScopeDataSource *source in self.scopeDataSources) {
        [source endUpdates];
    }
    
    [self showAll];
}

- (void)setStepsPerMinute:(double)stepsPerMinute
{
    _stepsPerMinute = stepsPerMinute;
    [self showStepsPerMinute];
}

- (void)setBeatsPerMinute:(double)beatsPerMinute
{
    _beatsPerMinute = beatsPerMinute;
    [self showBeatsPerMinute];
}
- (void)setNowPlaying:(NSString *)nowPlaying
{
    _nowPlaying = nowPlaying;
    [self showNowPlaying];
}

- (void)randomizeColors
{
    [self randomizeColorsInShapeLayers:self.shapeLayers.mutableCopy];
    [self randomizeAlphasInShapeLayers:self.shapeLayers coefficient:0.2];
    UIColor *baseColor = [UIColor randomColor];
    self.view.backgroundColor = baseColor;
    self.label.textColor = [[baseColor complement]jitterWithPercent:5];
    self.titleLabel.textColor = [[baseColor complement]jitterWithPercent:5];
    self.nowPlayingLabel.textColor = [[baseColor complement] jitterWithPercent:5];
    self.hamburgerButton.mainColor = self.titleLabel.textColor;
}

- (MMScopeDataSource *)newScopeDataSource:(NSString *)table
{
    CGFloat updateInterval = 0.1;
    MMScopeDataSource *scopeData = [[MMScopeDataSource alloc]initWithUpdateInterval:updateInterval sourceTable:table];
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
        [self.effectsView.contentView.layer addSublayer:layer];
    }
}


- (void)setupViews
{
    UIVisualEffect *blur = [UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    
    self.effectsView = [[UIVisualEffectView alloc]initWithEffect:blur];
    self.effectsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.effectsView];
    [self.view addConstraints:[self.effectsView pinEdgesToSuperWithInsets:UIEdgeInsetsZero]];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setupViews];
    [self configureLayersAndData];
    [self.view setBackgroundColor:[UIColor randomColor]];
    [self configureLabels];
    [self.effectsView.contentView addSubview:self.label];
    [self.effectsView.contentView addSubview:self.titleLabel];
    [self.effectsView.contentView addSubview:self.nowPlayingLabel];
    [self configureLabelConstraints];
    
    self.hamburgerButton = [[HamburgerButton alloc]init];
    self.hamburgerButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.hamburgerButton addTarget:self action:@selector(tapInHamburgerButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.effectsView.contentView addSubview:self.hamburgerButton];
    [self.view addConstraint:[self.hamburgerButton pinHeight:30]];
    [self.view addConstraint:[self.hamburgerButton pinWidth:40]];
    [self.view addConstraint:[self.hamburgerButton alignAxis:LayoutAxis_Vertical
                                                      toAxis:LayoutAxis_Vertical
                                                      ofView:self.titleLabel
                                                      offset:0]];
    
    [self.view addConstraint:[self.hamburgerButton pinEdge:LayoutEdge_Left
                                                    toEdge:LayoutEdge_Left
                                                    ofView:self.hamburgerButton.superview withInset:20]];
    [self.view layoutIfNeeded];
    self.hamburgerButton.mainColor = self.titleLabel.textColor;
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
