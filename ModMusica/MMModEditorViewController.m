//
//  MMModEditorViewController.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/29/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMModEditorViewController.h"
#import "UIView+Layout.h"
#import "MMModEditorButton.h"
#import "MMScrollView.h"
#import "UIColor+HBVHarmonies.h"

#define INNERPADDING 2
#define OUTERPADDING 8
#define DEFAULT_PITCHES 25
#define DEFAULT_STEPS 64

@interface MMModEditorViewController () <ModEditorButtonViewDelegate>

@property (nonatomic,strong)            NSMutableArray          *pitchLabels;
@property (nonatomic,strong)            NSMutableArray          *stepLabels;
@property (nonatomic,strong)            NSMutableArray          *controls;

@property (nonatomic,strong)            UIView                  *containerView;
@property (nonatomic,strong)            UIView                  *pitchLabelsView;
@property (nonatomic,strong)            UIView                  *stepLabelsView;
@property (nonatomic,strong)            UIView                  *controlsView;



@end

@implementation MMModEditorViewController

- (void)voiceStepperValueChanged:(id)sender
{
    UIStepper *stepper = sender;
    UILabel *stepperLabel = self.controls.lastObject;
    stepperLabel.text = [NSString stringWithFormat:@"%@",@(stepper.value)];
}

- (void)tapInControlButton:(id)sender
{
    UIButton *button = sender;
    switch (button.tag) {
        case 0:
            NSLog(@"Save");
            break;
        case 1:
            NSLog(@"Clear");
            break;
        case 2:
            button.selected = (BOOL)(1-(int)button.isSelected);
            break;
        default:
            break;
    }
}

- (void)setupControlsView
{
    NSMutableArray *tempControls = [NSMutableArray array];
    UIButton *saveButton = [UIButton new];
    saveButton.translatesAutoresizingMaskIntoConstraints = NO;
    saveButton.tag = 0;
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(tapInControlButton:) forControlEvents:UIControlEventTouchUpInside];
    [tempControls addObject:saveButton];
    [self.controlsView addSubview:saveButton];
    
    UIButton *clearButton = [UIButton new];
    clearButton.translatesAutoresizingMaskIntoConstraints = NO;
    clearButton.tag = 1;
    [clearButton setTitle:@"Clear" forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(tapInControlButton:) forControlEvents:UIControlEventTouchUpInside];
    [clearButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];

    [tempControls addObject:clearButton];
    [self.controlsView addSubview:clearButton];
    
    UIButton *playButton = [UIButton new];
    playButton.translatesAutoresizingMaskIntoConstraints = NO;
    playButton.tag = 2;
    [playButton setTitle:@"Play" forState:UIControlStateNormal];
    [playButton setTitle:@"Stop" forState:UIControlStateSelected];
    [playButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(tapInControlButton:) forControlEvents:UIControlEventTouchUpInside];
    [tempControls addObject:playButton];
    [self.controlsView addSubview:playButton];
    
    UIStepper *voiceStepper = [UIStepper new];
    voiceStepper.translatesAutoresizingMaskIntoConstraints = NO;
    voiceStepper.tag = 3;
    voiceStepper.minimumValue = 0;
    voiceStepper.maximumValue = 3;
    voiceStepper.value = 0;
    [voiceStepper addTarget:self action:@selector(voiceStepperValueChanged:) forControlEvents:UIControlEventValueChanged];
    [tempControls addObject:voiceStepper];
    [self.controlsView addSubview:voiceStepper];
    
    UILabel *voiceStepperLabel = [UILabel new];
    voiceStepperLabel.translatesAutoresizingMaskIntoConstraints = NO;
    voiceStepperLabel.tag = 4;
    voiceStepperLabel.textAlignment = NSTextAlignmentCenter;
    voiceStepperLabel.text = @"0";
    [tempControls addObject:voiceStepperLabel];
    [self.controlsView addSubview:voiceStepperLabel];
    
    self.controls = tempControls;
}

- (void)setupStepLabelsView
{
    NSMutableArray *temp = [NSMutableArray array];
    
    for (int i = 0; i < DEFAULT_STEPS; i ++) {
        UILabel *lab = [UILabel new];
        lab.translatesAutoresizingMaskIntoConstraints = NO;
        lab.textAlignment = NSTextAlignmentCenter;
        lab.textColor = [UIColor blackColor];
        [self.stepLabelsView addSubview:lab];
        [temp addObject:lab];
    }
    
    self.stepLabels = temp;
}

- (void)setupPitchLabelsView
{
    NSMutableArray *temp = [NSMutableArray array];
    
    for (int i = 0; i < DEFAULT_PITCHES; i ++) {
        UILabel *lab = [UILabel new];
        lab.translatesAutoresizingMaskIntoConstraints = NO;
        lab.textAlignment = NSTextAlignmentRight;
        lab.textColor = [UIColor blackColor];
        [self.pitchLabelsView addSubview:lab];
        [temp addObject:lab];
    }
    
    self.pitchLabels = temp;
}

- (void)setupControlsConstraints
{
    CGFloat padWidth = self.controlsView.bounds.size.width * 0.1;
    CGFloat controlWidth = (self.controlsView.bounds.size.width - padWidth * 5)/4.0;
    CGFloat widthMultiplier = controlWidth/self.controlsView.bounds.size.width;
    UIView *left = nil;
    LayoutEdge leftEdge;
    CGFloat leftOffset = 0;
    
    for (NSUInteger i = 0; i < 4; i ++) {
        UIView *control = self.controls[i];
        [self.view addConstraint:[control pinWidthProportionateToSuperview:widthMultiplier]];
        
        if (i == 0) {
            left = self.controlsView;
            leftEdge = LayoutEdge_Left;
            leftOffset = padWidth;
        }else{
            left = self.controls[i-1];
            leftEdge = LayoutEdge_Right;
            leftOffset = padWidth;
        }
        
        if (i == 3) {
            [self.view addConstraint:[control pinEdge:LayoutEdge_Right
                                               toEdge:LayoutEdge_Right
                                               ofView:self.controlsView
                                            withInset:-padWidth]];
            [self.view addConstraint:[control alignCenterYToSuperOffset:0]];
            UIView *lab = self.controls.lastObject;
            [self.view addConstraint:[lab pinEdge:LayoutEdge_Left
                                           toEdge:LayoutEdge_Left
                                           ofView:control
                                        withInset:0]];
            [self.view addConstraint:[lab pinEdge:LayoutEdge_Right
                                           toEdge:LayoutEdge_Right
                                           ofView:control
                                        withInset:0]];
            [self.view addConstraint:[lab pinEdge:LayoutEdge_Bottom
                                           toEdge:LayoutEdge_Top
                                           ofView:control
                                        withInset:-4]];
            [self.view addConstraint:[lab pinHeight:15.0]];
            
            
        }else{
            [self.view addConstraint:[control pinEdge:LayoutEdge_Top toEdge:LayoutEdge_Top ofView:self.controlsView withInset:10]];
            [self.view addConstraint:[control pinEdge:LayoutEdge_Bottom toEdge:LayoutEdge_Bottom ofView:self.controlsView withInset:-10]];
        }
        
        [self.view addConstraint:[control pinEdge:LayoutEdge_Left
                                           toEdge:leftEdge
                                           ofView:left
                                        withInset:padWidth]];
        
    }

}

- (void)setupStepLabelConstraints
{
    CGFloat labWidth = (self.stepLabelsView.bounds.size.width - OUTERPADDING * 2.0)/DEFAULT_STEPS;
    CGFloat widthMultiplier = labWidth/self.stepLabelsView.bounds.size.width;
    UIView *left = nil;
    LayoutEdge leftEdge;
    CGFloat leftOffset = 0;
    UIView *right = nil;
    LayoutEdge rightEdge;
    CGFloat rightOffset = 0;
    
    for (int i = 0; i < DEFAULT_STEPS; i ++) {
        if (i == 0) {
            left = self.stepLabelsView;
            leftEdge = LayoutEdge_Left;
            leftOffset = OUTERPADDING;
        }else{
            left = self.stepLabels[i-1];
            leftEdge = LayoutEdge_Right;
            leftOffset = 0;
        }
        
        if (i == (DEFAULT_STEPS - 1)) {
            right = self.stepLabelsView;
            rightEdge = LayoutEdge_Right;
            rightOffset = -OUTERPADDING;
        }else{
            right = self.stepLabels[i+1];
            rightEdge = LayoutEdge_Left;
            rightOffset = 0;
        }
        
        int step = i+1;
        NSLog(@"add label with step %d",step);
        UILabel *lab = self.stepLabels[i];
        lab.text = [NSString stringWithFormat:@"%d",step];
        if (i%16 == 0) {
            lab.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        }else if (i%8 == 0){
            lab.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize] * 0.9];
        }else if (i%4 == 0){
            lab.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize] * 0.8];
        }else if (i%2 == 0){
            lab.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize] * 0.7];
        }else{
            lab.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize] * 0.6];
        }
        
        [self.view addConstraint:[lab pinEdge:LayoutEdge_Left
                                       toEdge:leftEdge
                                       ofView:left
                                    withInset:leftOffset]];
        
        [self.view addConstraint:[lab pinEdge:LayoutEdge_Right
                                       toEdge:rightEdge
                                       ofView:right
                                    withInset:rightOffset]];
        
        [self.view addConstraint:[lab pinWidthProportionateToSuperview:widthMultiplier]];
        [self.view addConstraint:[lab pinEdge:LayoutEdge_Top toSuperviewEdge:LayoutEdge_Top]];
        [self.view addConstraint:[lab pinEdge:LayoutEdge_Bottom toSuperviewEdge:LayoutEdge_Bottom]];
        
    }

}

- (void)setupPitchLabelConstraints
{
    CGFloat stepLabelsHeight = self.stepLabelsView.bounds.size.height + self.controlsView.bounds.size.height;
    CGFloat labHeight = (self.pitchLabelsView.bounds.size.height - stepLabelsHeight - OUTERPADDING * 2.0)/DEFAULT_PITCHES;
    CGFloat heightMultiplier = labHeight/self.pitchLabelsView.bounds.size.height;
    UIView *top = nil;
    LayoutEdge topEdge;
    CGFloat topOffset = 0;
    UIView *bottom = nil;
    LayoutEdge bottomEdge;
    CGFloat bottomOffset = 0;
    
    for (int i = 0; i < DEFAULT_PITCHES; i ++) {
        if (i == 0) {
            top = self.pitchLabelsView;
            topEdge = LayoutEdge_Top;
            topOffset = OUTERPADDING + stepLabelsHeight;
        }else{
            top = self.pitchLabels[i-1];
            topEdge = LayoutEdge_Bottom;
            topOffset = 0;
        }
        
        if (i == (DEFAULT_PITCHES - 1)) {
            bottom = self.pitchLabelsView;
            bottomEdge = LayoutEdge_Bottom;
            bottomOffset = -OUTERPADDING;
        }else{
            bottom = self.pitchLabels[i+1];
            bottomEdge = LayoutEdge_Top;
            bottomOffset = 0;
        }
        
        int pitch = DEFAULT_PITCHES - 1 - 12 - i;
        NSLog(@"add label with pitch %d",pitch);
        UILabel *lab = self.pitchLabels[i];
        lab.text = [NSString stringWithFormat:@"%d",pitch];
        [self.view addConstraint:[lab pinEdge:LayoutEdge_Top
                                       toEdge:topEdge
                                       ofView:top
                                    withInset:topOffset]];
        [self.view addConstraint:[lab pinEdge:LayoutEdge_Bottom
                                       toEdge:bottomEdge
                                       ofView:bottom
                                    withInset:bottomOffset]];
        
        [self.view addConstraint:[lab pinHeightProportionateToSuperview:heightMultiplier]];
        [self.view addConstraint:[lab pinEdge:LayoutEdge_Left toSuperviewEdge:LayoutEdge_Left]];
        [self.view addConstraint:[lab pinEdge:LayoutEdge_Right toSuperviewEdge:LayoutEdge_Right]];
        
    }
}

- (void)commonInit
{
    self.containerView = [UIView new];
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.containerView];
    
    self.pitchLabelsView = [UIView new];
    self.pitchLabelsView.translatesAutoresizingMaskIntoConstraints = NO;
    self.pitchLabelsView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.pitchLabelsView];
    [self setupPitchLabelsView];
    
    self.controlsView = [[UIView alloc]init];
    self.controlsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.controlsView];
    [self setupControlsView];
    
    self.stepLabelsView = [[UIView alloc]init];
    self.stepLabelsView.translatesAutoresizingMaskIntoConstraints = NO;
    self.stepLabelsView.backgroundColor = [UIColor clearColor];
    [self.containerView addSubview:self.stepLabelsView];
    [self setupStepLabelsView];
    
    self.buttonView = [[ModPitchEditorButtonView alloc]init];
    self.buttonView.translatesAutoresizingMaskIntoConstraints = NO;
    self.buttonView.backgroundColor = [UIColor clearColor];
    self.buttonView.numSteps = DEFAULT_STEPS;
    self.buttonView.numPitches = DEFAULT_PITCHES;
    self.buttonView.mainColor = [UIColor orangeColor];
    self.buttonView.innerPadding = INNERPADDING;
    self.buttonView.outerPadding = OUTERPADDING;
    self.buttonView.delegate = self;
    [self.containerView addSubview:self.buttonView];
    
}

- (void)configureConstraints
{
    [self.view addConstraint:[self.pitchLabelsView pinEdge:LayoutEdge_Left
                                                    toEdge:LayoutEdge_Left
                                                    ofView:self.view
                                                 withInset:20]];
    [self.view addConstraint:[self.pitchLabelsView pinEdge:LayoutEdge_Top
                                                    toEdge:LayoutEdge_Top
                                                    ofView:self.view
                                                 withInset:20]];
    
    [self.view addConstraint:[self.pitchLabelsView pinEdge:LayoutEdge_Bottom
                                                    toEdge:LayoutEdge_Bottom
                                                    ofView:self.view
                                                 withInset:-20]];
    
    [self.view addConstraint:[self.pitchLabelsView pinWidth:50]];
    
    [self.view addConstraint:[self.containerView pinEdge:LayoutEdge_Left
                                                      toEdge:LayoutEdge_Right
                                                      ofView:self.pitchLabelsView
                                                   withInset:0]];
    
    [self.view addConstraint:[self.containerView pinEdge:LayoutEdge_Top
                                                      toEdge:LayoutEdge_Top
                                                      ofView:self.view
                                                   withInset:20]];
    
    [self.view addConstraint:[self.containerView pinEdge:LayoutEdge_Right
                                                      toEdge:LayoutEdge_Right
                                                      ofView:self.view
                                                   withInset:-20]];
    
    [self.view addConstraint:[self.containerView pinEdge:LayoutEdge_Bottom
                                                      toEdge:LayoutEdge_Bottom
                                                      ofView:self.view
                                                   withInset:-20]];
    
    [self.view addConstraint:[self.controlsView pinEdge:LayoutEdge_Top toSuperviewEdge:LayoutEdge_Top]];
    [self.view addConstraint:[self.controlsView pinEdge:LayoutEdge_Left toSuperviewEdge:LayoutEdge_Left]];
    [self.view addConstraint:[self.controlsView pinEdge:LayoutEdge_Right toSuperviewEdge:LayoutEdge_Right]];
    [self.view addConstraint:[self.controlsView pinHeight:80]];
    
    [self.view addConstraint:[self.stepLabelsView pinEdge:LayoutEdge_Left toSuperviewEdge:LayoutEdge_Left]];
    [self.view addConstraint:[self.stepLabelsView pinEdge:LayoutEdge_Right toSuperviewEdge:LayoutEdge_Right]];
    [self.view addConstraint:[self.stepLabelsView pinEdge:LayoutEdge_Top toEdge:LayoutEdge_Bottom ofView:self.controlsView withInset:0]];
    [self.view addConstraint:[self.stepLabelsView pinHeight:20]];
    
    [self.view addConstraint:[self.buttonView pinEdge:LayoutEdge_Left toSuperviewEdge:LayoutEdge_Left]];
    [self.view addConstraint:[self.buttonView pinEdge:LayoutEdge_Right toSuperviewEdge:LayoutEdge_Right]];
    [self.view addConstraint:[self.buttonView pinEdge:LayoutEdge_Bottom toSuperviewEdge:LayoutEdge_Bottom]];
    [self.view addConstraint:[self.buttonView pinEdge:LayoutEdge_Top toEdge:LayoutEdge_Bottom ofView:self.stepLabelsView withInset:0]];

    [self.view layoutIfNeeded];
    
    [self.buttonView setupButtonsNumSteps:DEFAULT_STEPS numPitches:DEFAULT_PITCHES];
    [self.buttonView configureConstraints];
    [self setupPitchLabelConstraints];
    [self setupStepLabelConstraints];
    [self setupControlsConstraints];

    [self.view layoutIfNeeded];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
    [self configureConstraints];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
