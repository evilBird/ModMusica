//
//  ModEditorViewController+Setup.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/30/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ModMelodyEditorViewController+Setup.h"
#import "ModMelodyEditorViewController+Controls.h"

@implementation ModMelodyEditorViewController (Setup)

- (void)setupControlsView
{
    self.controlsView = [[UIView alloc]init];
    self.controlsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.controlsView];
    
    NSMutableArray *tempControls = [NSMutableArray array];
    UIButton *saveButton = [UIButton new];
    saveButton.translatesAutoresizingMaskIntoConstraints = NO;
    saveButton.tag = 0;
    saveButton.layer.cornerRadius = 2;
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton setTitleColor:self.mainColor forState:UIControlStateNormal];
    [saveButton setBackgroundColor:[self myMainColor]];
    [saveButton addTarget:self action:@selector(tapInControlButton:) forControlEvents:UIControlEventTouchUpInside];
    [tempControls addObject:saveButton];
    [self.controlsView addSubview:saveButton];
    
    UIButton *clearButton = [UIButton new];
    clearButton.translatesAutoresizingMaskIntoConstraints = NO;
    clearButton.tag = 1;
    clearButton.layer.cornerRadius = 2;
    [clearButton setTitle:@"Clear" forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(tapInControlButton:) forControlEvents:UIControlEventTouchUpInside];
    [clearButton setTitleColor:self.mainColor forState:UIControlStateNormal];
    [clearButton setBackgroundColor:[self myMainColor]];
    
    [tempControls addObject:clearButton];
    [self.controlsView addSubview:clearButton];
    
    UIButton *playButton = [UIButton new];
    playButton.translatesAutoresizingMaskIntoConstraints = NO;
    playButton.tag = 2;
    [playButton setTitle:@"Play" forState:UIControlStateNormal];
    [playButton setTitle:@"Stop" forState:UIControlStateSelected];
    [playButton setTitleColor:self.mainColor forState:UIControlStateNormal];
    [playButton setBackgroundColor:[self myMainColor]];
    playButton.layer.cornerRadius = 2;
    [playButton addTarget:self action:@selector(tapInControlButton:) forControlEvents:UIControlEventTouchUpInside];
    [tempControls addObject:playButton];
    [self.controlsView addSubview:playButton];
    
    UIButton *closeButton = [UIButton new];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    closeButton.tag = 3;
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [closeButton setTitleColor:self.mainColor forState:UIControlStateNormal];
    [closeButton setBackgroundColor:[self myMainColor]];
    closeButton.layer.cornerRadius = 2;
    [closeButton addTarget:self action:@selector(tapInControlButton:) forControlEvents:UIControlEventTouchUpInside];
    [tempControls addObject:closeButton];
    [self.controlsView addSubview:closeButton];
    
    self.controls = tempControls;
}

- (void)setupStepLabelsView
{

    self.stepLabelsView = [[UIView alloc]init];
    self.stepLabelsView.translatesAutoresizingMaskIntoConstraints = NO;
    self.stepLabelsView.backgroundColor = [UIColor clearColor];
    [self.containerView addSubview:self.stepLabelsView];

    NSMutableArray *temp = [NSMutableArray array];
    
    for (int i = 0; i < [self.datasource numSteps]; i ++) {
        UILabel *lab = [UILabel new];
        lab.translatesAutoresizingMaskIntoConstraints = NO;
        lab.textAlignment = NSTextAlignmentCenter;
        lab.textColor = [self myMainColor];
        [self.stepLabelsView addSubview:lab];
        [temp addObject:lab];
    }
    
    self.stepLabels = temp;
}

- (void)setupPitchLabelsView
{
    
    self.pitchLabelsView = [UIView new];
    self.pitchLabelsView.translatesAutoresizingMaskIntoConstraints = NO;
    self.pitchLabelsView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.pitchLabelsView];
    
    NSMutableArray *temp = [NSMutableArray array];
    
    for (int i = 0; i < DEFAULT_PITCHES; i ++) {
        UILabel *lab = [UILabel new];
        lab.translatesAutoresizingMaskIntoConstraints = NO;
        lab.textAlignment = NSTextAlignmentRight;
        lab.textColor = [self myMainColor];
        [self.pitchLabelsView addSubview:lab];
        [temp addObject:lab];
    }
    
    self.pitchLabels = temp;
}

- (void)setupContainerView
{
    self.containerView = [[UIView alloc]init];
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.containerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.containerView];
}

- (void)setupPitchView
{
    self.pitchView = [[ModMelodyEditorStepPitchView alloc]init];
    self.pitchView.translatesAutoresizingMaskIntoConstraints = NO;
    self.pitchView.backgroundColor = [UIColor clearColor];
    
    [self.containerView addSubview:self.pitchView];
}

- (void)setupViews
{
    [self setupContainerView];
    [self setupPitchLabelsView];
    [self setupStepLabelsView];
    [self setupControlsView];
    [self setupPitchView];
}

@end
