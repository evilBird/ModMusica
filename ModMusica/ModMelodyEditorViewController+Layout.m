//
//  ModEditorViewController+Layout.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/30/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ModMelodyEditorViewController+Layout.h"
#import "UIView+Layout.h"


@implementation ModMelodyEditorViewController (Layout)

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
    
    [self.view addConstraint:[self.pitchView pinEdge:LayoutEdge_Left toSuperviewEdge:LayoutEdge_Left]];
    [self.view addConstraint:[self.pitchView pinEdge:LayoutEdge_Right toSuperviewEdge:LayoutEdge_Right]];
    [self.view addConstraint:[self.pitchView pinEdge:LayoutEdge_Bottom toSuperviewEdge:LayoutEdge_Bottom]];
    [self.view addConstraint:[self.pitchView pinEdge:LayoutEdge_Top toEdge:LayoutEdge_Bottom ofView:self.stepLabelsView withInset:0]];
    
    [self.view layoutIfNeeded];
    
    [self.pitchView configureWithDelegate:self datasource:self.datasource];
    [self setupPitchLabelConstraints];
    [self setupStepLabelConstraints];
    [self setupControlsConstraints];
    
    [self.view layoutIfNeeded];
    
}

- (void)setupControlsConstraints
{
    CGFloat padWidth = self.controlsView.bounds.size.width * 0.1;
    CGFloat numControls = (CGFloat)self.controls.count;
    CGFloat controlWidth = (self.controlsView.bounds.size.width - padWidth * (numControls + 1))/numControls;
    CGFloat widthMultiplier = controlWidth/self.controlsView.bounds.size.width;
    
    UIView *view = nil;
    LayoutEdge viewEdge;
    LayoutEdge myEdge;
    CGFloat offset = 0;
    
    UIView *right = nil;
    LayoutEdge rightEdge = LayoutEdge_Right;
    CGFloat rightOffset = 0;
    
    for (NSUInteger i = 0; i < self.controls.count; i ++) {
        UIView *control = self.controls[i];
        [self.view addConstraint:[control pinWidthProportionateToSuperview:widthMultiplier]];
        
        if (i == 0) {
            view = self.controlsView;
            viewEdge = LayoutEdge_Left;
            myEdge = LayoutEdge_Left;
            offset = padWidth;
        }else{
            view = self.controls[i-1];
            viewEdge = LayoutEdge_Right;
            myEdge = LayoutEdge_Left;
            offset = padWidth;
        }
        
        if (i == (self.controls.count - 1)) {
            right = self.controlsView;
            rightEdge = LayoutEdge_Right;
            rightOffset = -padWidth;
        }
        

        [self.view addConstraint:[control pinEdge:LayoutEdge_Top toEdge:LayoutEdge_Top ofView:self.controlsView withInset:10]];
        [self.view addConstraint:[control pinEdge:LayoutEdge_Bottom toEdge:LayoutEdge_Bottom ofView:self.controlsView withInset:-10]];
        [self.view addConstraint:[control pinWidthProportionateToSuperview:widthMultiplier]];
        
        
        [self.view addConstraint:[control pinEdge:myEdge
                                           toEdge:viewEdge
                                           ofView:view
                                        withInset:offset]];
        if (right) {
            [self.view addConstraint:[control pinEdge:LayoutEdge_Right
                                               toEdge:rightEdge
                                               ofView:right
                                            withInset:rightOffset]];
        }
        
    }
    
}

- (void)setupStepLabelConstraints
{
    CGFloat labWidth = (self.stepLabelsView.bounds.size.width - OUTERPADDING * 2.0)/[self.datasource numSteps];
    CGFloat widthMultiplier = labWidth/self.stepLabelsView.bounds.size.width;
    UIView *left = nil;
    LayoutEdge leftEdge;
    CGFloat leftOffset = 0;
    UIView *right = nil;
    LayoutEdge rightEdge;
    CGFloat rightOffset = 0;
    
    for (int i = 0; i < [self.datasource numSteps]; i ++) {
        if (i == 0) {
            left = self.stepLabelsView;
            leftEdge = LayoutEdge_Left;
            leftOffset = OUTERPADDING;
        }else{
            left = self.stepLabels[i-1];
            leftEdge = LayoutEdge_Right;
            leftOffset = 0;
        }
        
        if (i == ([self.datasource numSteps] - 1)) {
            right = self.stepLabelsView;
            rightEdge = LayoutEdge_Right;
            rightOffset = -OUTERPADDING;
        }else{
            right = self.stepLabels[i+1];
            rightEdge = LayoutEdge_Left;
            rightOffset = 0;
        }
        
        int step = i+1;
        UILabel *lab = self.stepLabels[i];
        int stepsPerMeasure = (int)([self.datasource numSteps]/[self.datasource numMeasures]);
        int beatsPerMeasure = (int)[self.datasource beatsPerMeasure];
        int divsPerBeat = (int)[self.datasource divsPerBeat];
        int labTextValue;
        
        if (i%stepsPerMeasure == 0) {
            lab.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
            labTextValue = (i/stepsPerMeasure)+1;
        }else if (i%beatsPerMeasure == 0){
            lab.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize] * 0.6];
            labTextValue = (i/beatsPerMeasure)+1;
        }else if (i%divsPerBeat == 0){
            lab.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize] * 0.5];
            labTextValue = step;
        }else{
            lab.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize] * 0.4];
            labTextValue = step;
        }
        
        lab.text = [NSString stringWithFormat:@"%d",labTextValue];
        
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

@end
