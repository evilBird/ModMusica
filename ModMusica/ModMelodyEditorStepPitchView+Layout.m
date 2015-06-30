//
//  ModMelodyEditorStepPitchView+Layout.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/30/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ModMelodyEditorStepPitchView+Layout.h"
#import "UIView+Layout.h"

@implementation ModMelodyEditorStepPitchView (Layout)

- (void)configureConstraints
{
    if (!self.switches || !self.switches.count) {
        return;
    }
    
    [self tearDownButtonsConstraints];
    [self setupConstraintsInButtons:self.switches numSteps:[self.datasource numSteps] numPitches:[self.datasource numPitches]];
}

- (void)tearDownButtonsConstraints
{
    if (!self.switchesConstraints) {
        return;
    }
    
    [self removeConstraints:self.switchesConstraints];
    self.switchesConstraints = nil;
}

- (void)setupConstraintsInButtons:(NSMutableArray *)buttons numSteps:(NSUInteger)numSteps numPitches:(NSUInteger)numPitches
{
    if (!buttons || !buttons.count) {
        return;
    }
    
    NSInteger left_neighbor, top_neighbor, right_neighbor, bottom_neighbor;
    NSUInteger maxPitch = numPitches - 1;
    NSUInteger maxStep = numSteps - 1;
    CGFloat buttonWidthMultiplier,buttonHeightMultiplier;
    
    buttonWidthMultiplier = ((self.bounds.size.width - OUTERPADDING * 2.0 - INNERPADDING * (numSteps - 1))/(CGFloat)numSteps)/self.bounds.size.width;
    buttonHeightMultiplier = ((self.bounds.size.height - OUTERPADDING * 2.0 - INNERPADDING * (numPitches - 1))/numPitches)/self.bounds.size.height;
    
    NSMutableArray *tempConstraints = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < numPitches; i ++) {
        
        for (NSUInteger j = 0; j < numSteps; j ++) {
            
            NSUInteger buttonTag = (i * numSteps) + j;
            
            if (i == 0) {
                top_neighbor = -1;
            }else{
                top_neighbor = buttonTag - numSteps;
            }
            
            if (i == maxPitch) {
                bottom_neighbor = -1;
            }else{
                bottom_neighbor = buttonTag + numSteps;
            }
            
            if (j == 0) {
                left_neighbor = -1;
            }else{
                left_neighbor = buttonTag - 1;
            }
            
            if (j == maxStep) {
                right_neighbor = -1;
            }else{
                right_neighbor = buttonTag+1;
            }
            
            ModMelodyEditorSwitch *button = buttons[buttonTag];
            
            [tempConstraints addObject:[button pinHeightProportionateToSuperview:buttonHeightMultiplier]];
            [tempConstraints addObject:[button pinWidthProportionateToSuperview:buttonWidthMultiplier]];
            
            UIView *left = nil;
            LayoutEdge leftEdge;
            CGFloat leftPad = 0;
            if (left_neighbor >= 0) {
                left = buttons[left_neighbor];
                leftPad = INNERPADDING;
                leftEdge = LayoutEdge_Right;
            }else{
                left = button.superview;
                leftPad = OUTERPADDING;
                leftEdge = LayoutEdge_Left;
            }
            
            [tempConstraints addObject:[button pinEdge:LayoutEdge_Left
                                                toEdge:leftEdge
                                                ofView:left
                                             withInset:leftPad]];
            
            UIView *top = nil;
            LayoutEdge topEdge;
            CGFloat topPad = 0;
            if (top_neighbor >= 0) {
                top = buttons[top_neighbor];
                topPad = INNERPADDING;
                topEdge = LayoutEdge_Bottom;
            }else{
                top = button.superview;
                topPad = OUTERPADDING;
                topEdge = LayoutEdge_Top;
            }
            
            [tempConstraints addObject:[button pinEdge:LayoutEdge_Top
                                                toEdge:topEdge
                                                ofView:top
                                             withInset:topPad]];
            
            UIView *right = nil;
            LayoutEdge rightEdge;
            CGFloat rightPad = 0;
            if (right_neighbor >= 0) {
                right = buttons[right_neighbor];
                rightPad = -INNERPADDING;
                rightEdge = LayoutEdge_Left;
            }else{
                right = button.superview;
                rightPad = -INNERPADDING;
                rightEdge = LayoutEdge_Right;
            }
            
            [tempConstraints addObject:[button pinEdge:LayoutEdge_Right
                                                toEdge:rightEdge
                                                ofView:right
                                             withInset:rightPad]];
            
            
            UIView *bottom = nil;
            LayoutEdge bottomEdge;
            CGFloat bottomPad = 0;
            if (bottom_neighbor >= 0) {
                bottom = buttons[bottom_neighbor];
                bottomPad = -INNERPADDING;
                bottomEdge = LayoutEdge_Top;
            }else{
                bottom = button.superview;
                bottomPad = -INNERPADDING;
                bottomEdge = LayoutEdge_Bottom;
            }
            
            [tempConstraints addObject:[button pinEdge:LayoutEdge_Bottom
                                                toEdge:bottomEdge
                                                ofView:bottom
                                             withInset:bottomPad]];
            
        }
    }
    
    self.switchesConstraints = tempConstraints;
    [self addConstraints:tempConstraints];
}

@end
