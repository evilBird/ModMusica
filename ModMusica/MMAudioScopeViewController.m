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
#import "MMAudioScopeViewController+Random.h"
#import "MMAudioScopeViewController+Depth.h"
#import "UIColor+HBVHarmonies.h"
#import "UIView+Layout.h"

static NSString *kStartMessage = @"press & hold to start";
static NSString *kStopMessage = @"press & hold to stop";
static NSString *kTapTempoMessage = @"tap to set tempo";

@interface MMAudioScopeViewController ()

@property (nonatomic,strong)        NSMutableArray          *scopeDataSources;
@property (nonatomic,strong)        UIVisualEffectView      *effectsView;


@end

@implementation MMAudioScopeViewController

#pragma mark - Public Methods

- (void)showDetails
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         [self showAllForDuration:10];
                     }];
}

- (void)beginUpdates
{
    self.updating = YES;
    
    for (MMScopeDataSource *source in self.scopeDataSources) {
        [source beginUpdates];
    }
    [self startUpdatingDepth];
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
    [self stopUpdatingDepth];
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

- (void)tapInHamburgerButton:(id)sender
{
    [self.delegate showSettings:self];
}

#pragma mark - Private Methods

#pragma mark - ScopeData config

- (MMScopeDataSource *)newScopeDataSource:(NSString *)table
{
    CGFloat updateInterval = 0.1;
    MMScopeDataSource *scopeData = [[MMScopeDataSource alloc]initWithUpdateInterval:updateInterval sourceTable:table];
    scopeData.dataConsumer = self;
    return scopeData;
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
    
    if (newPath)
    {
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            [self animateLayer:layer
                          path:newPath
                      duration:source.interval];
        }];
    }
}

#pragma mark - UI config
- (void)configureLayersAndData
{
    self.scopeDataSources = [NSMutableArray array];
    self.shapeLayers = [NSMutableArray array];
    NSArray *scopeNames = [MMScopeDataSource allTableNames];
    for (NSString *name in scopeNames) {
        MMScopeDataSource *datasource = [self newScopeDataSource:name];
        [self.scopeDataSources addObject:datasource];
        CAShapeLayer *layer = [self newShapeLayer];
        [self.shapeLayers addObject:layer];
        [self.contentView.layer addSublayer:layer];
    }
}


- (void)setupViews
{
    UIVisualEffect *blur = [UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    self.effectsView = [[UIVisualEffectView alloc]initWithEffect:blur];
    self.effectsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.effectsView];
    [self.view addConstraints:[self.effectsView pinEdgesToSuperWithInsets:UIEdgeInsetsZero]];
    self.contentView = self.effectsView.contentView;
}

- (void)setupHamburgerButton
{
    self.hamburgerButton = [[HamburgerButton alloc]init];
    self.hamburgerButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.hamburgerButton addTarget:self action:@selector(tapInHamburgerButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.hamburgerButton];
    [self.view addConstraint:[self.hamburgerButton pinHeight:30]];
    [self.view addConstraint:[self.hamburgerButton pinWidth:40]];
    [self.view addConstraint:[self.hamburgerButton alignAxis:LayoutAxis_Vertical
                                                      toAxis:LayoutAxis_Vertical
                                                      ofView:self.titleLabel
                                                      offset:0]];
    
    [self.view addConstraint:[self.hamburgerButton pinEdge:LayoutEdge_Left
                                                    toEdge:LayoutEdge_Left
                                                    ofView:self.hamburgerButton.superview withInset:20]];
    self.hamburgerButton.mainColor = self.titleLabel.textColor;
}

#pragma mark - ViewController LifeCycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    //[self setupViews];
    [self.view setBackgroundColor:[UIColor randomColor]];
    self.contentView = self.view;
    [self configureLayersAndData];
    [self configureLabels];
    [self configureLabelConstraints];
    [self setupHamburgerButton];
    [self setupDepthOfField];
    [self.view layoutIfNeeded];
    // Do any additional setup after loading the view.
}

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
