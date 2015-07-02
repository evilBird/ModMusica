//
//  ModMelodyEditorStepPitchView+Setup.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/30/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ModMelodyEditorStepPitchView+Setup.h"
#import "UIView+Layout.h"

@implementation ModMelodyEditorStepPitchView (Setup)

- (void)tearDownSwitches
{
    [self removeConstraints:self.switchesConstraints];
    
    for (ModMelodyEditorSwitch *button in self.switches) {
        [button removeTarget:self action:@selector(buttonValueChanged:) forControlEvents:UIControlEventValueChanged];
        [button removeFromSuperview];
    }
    
}

- (void)setupSwitches
{
    NSUInteger numSteps = [self.datasource numSteps];
    NSUInteger numPitches = [self.datasource numPitches];
    
    if (!numSteps || !numPitches) {
        return;
    }
    
    if (self.switches.count) {
        [self tearDownSwitches];
        self.switches = nil;
    }
    
    if (self.switchesConstraints.count) {
        [self removeConstraints:self.switchesConstraints];
        self.switchesConstraints = nil;
    }
    
    NSMutableArray *tempButtons = [NSMutableArray array];
    NSMutableArray *tempHorizontalSpacers = [NSMutableArray array];
    NSMutableArray *tempVerticalSpacers = [NSMutableArray array];
    NSMutableArray *tempConstraints = [NSMutableArray array];
    NSMutableArray *tempStepLabels = [NSMutableArray array];
    NSMutableArray *tempPitchLabels = [NSMutableArray array];
    NSMutableArray *tempViews = [NSMutableArray array];
    
    UIView *anchorView = nil;
    UIView *referenceView = nil;
    
    UIView *verticalSpacerAnchor = [UIView new];
    verticalSpacerAnchor.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:verticalSpacerAnchor];
    
    [tempConstraints addObject:[verticalSpacerAnchor pinEdge:LayoutEdge_Left
                                             toSuperviewEdge:LayoutEdge_Left]];
    [tempConstraints addObject:[verticalSpacerAnchor pinEdge:LayoutEdge_Top
                                             toSuperviewEdge:LayoutEdge_Top]];
    [tempConstraints addObject:[verticalSpacerAnchor pinEdge:LayoutEdge_Bottom
                                             toSuperviewEdge:LayoutEdge_Bottom]];
    [tempConstraints addObject:[verticalSpacerAnchor pinWidthProportionateToSuperview:0.005]];
    
    [tempVerticalSpacers addObject:verticalSpacerAnchor];
    
    UIView *horizontalSpacerAnchor = [UIView new];
    horizontalSpacerAnchor.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:horizontalSpacerAnchor];
    [tempConstraints addObject:[horizontalSpacerAnchor pinEdge:LayoutEdge_Left
                                               toSuperviewEdge:LayoutEdge_Left]];
    [tempConstraints addObject:[horizontalSpacerAnchor pinEdge:LayoutEdge_Top
                                               toSuperviewEdge:LayoutEdge_Top]];
    [tempConstraints addObject:[horizontalSpacerAnchor pinEdge:LayoutEdge_Right
                                               toSuperviewEdge:LayoutEdge_Right]];
    [tempConstraints addObject:[horizontalSpacerAnchor pinHeightProportionateToSuperview:0.005]];
    
    [tempHorizontalSpacers addObject:horizontalSpacerAnchor];
    
    for (NSUInteger i = 0; i <= numPitches; i ++)
    {
        UIView *horizontalSpacer = nil;
        
        if(i < tempHorizontalSpacers.count){
            horizontalSpacer = tempHorizontalSpacers[i];
        }else {
            
            horizontalSpacer = [UIView new];
            
            horizontalSpacer.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:horizontalSpacer];
            
            [tempConstraints addObject:[horizontalSpacer pinEdge:LayoutEdge_Top
                                                          toEdge:LayoutEdge_Bottom
                                                          ofView:anchorView
                                                       withInset:0]];
            
            [tempConstraints addObject:[horizontalSpacer pinEdge:LayoutEdge_Left
                                                 toSuperviewEdge:LayoutEdge_Left]];
            
            [tempConstraints addObject:[horizontalSpacer pinEdge:LayoutEdge_Right
                                                 toSuperviewEdge:LayoutEdge_Right]];
            
            [tempConstraints addObject:[horizontalSpacer pinHeightEqualToView:tempHorizontalSpacers.firstObject]];
            [tempHorizontalSpacers addObject:horizontalSpacer];
            
        }
        
        for (NSUInteger j = 0; j <= numSteps; j ++) {
            
            UIView *newView = nil;
            
            if (i == 0 && j > 0) {
                UILabel *newLabel = [UILabel new];
                newLabel.translatesAutoresizingMaskIntoConstraints = NO;
                newLabel.textColor = [self.delegate myMainColor];
                newLabel.text = [self.delegate textForStepLabelAtIndex:j];
                newLabel.textAlignment = NSTextAlignmentCenter;
                newLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin"
                                                size:[UIFont smallSystemFontSize] * [self.delegate fontScaleForStepLabelAtIndex:j]];
                [tempStepLabels addObject:newLabel];
                newView = newLabel;
            }else if (j == 0 && i > 0){
                UILabel *newLabel = [UILabel new];
                newLabel.translatesAutoresizingMaskIntoConstraints = NO;
                newLabel.textColor = [self.delegate myMainColor];
                newLabel.text = [self.delegate textForPitchLabelAtIndex:i];
                newLabel.adjustsFontSizeToFitWidth = YES;
                newLabel.minimumScaleFactor = 0.2;
                newLabel.textAlignment = NSTextAlignmentRight;
                newLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:[UIFont smallSystemFontSize]];
                [tempPitchLabels addObject:newLabel];
                newView = newLabel;
            }else if (j > 0 && i > 0){
                ModMelodyEditorSwitch *newSwitch = [ModMelodyEditorSwitch new];
                newSwitch.translatesAutoresizingMaskIntoConstraints = NO;
                newSwitch.tag = ((i - 1) * numSteps) + (j + 1);
                newSwitch.backgroundColor = [UIColor clearColor];
                newSwitch.mainColor = [self.delegate myMainColor];
                newSwitch.value = [self.delegate initialValueForSwitchWithTag:newSwitch.tag];
                newSwitch.layer.borderWidth = 0.5;
                newSwitch.layer.borderColor = [self.delegate myMainColor].CGColor;
                newSwitch.layer.cornerRadius = 2.0;
                newSwitch.userInteractionEnabled = NO;
                [newSwitch addTarget:self action:@selector(buttonValueChanged:) forControlEvents:UIControlEventValueChanged];
                [tempButtons addObject:newSwitch];
                newView = newSwitch;
                
            }else{
                newView = [UIView new];
                newView.translatesAutoresizingMaskIntoConstraints = NO;
            }
            
            UIView *verticalSpacer = nil;
            
            if (j < tempVerticalSpacers.count) {
                verticalSpacer = tempVerticalSpacers[j];
            }else{
                
                verticalSpacer = [UIView new];
                verticalSpacer.translatesAutoresizingMaskIntoConstraints = NO;
                [self addSubview:verticalSpacer];
                
                [tempConstraints addObject:[verticalSpacer pinEdge:LayoutEdge_Left
                                                            toEdge:LayoutEdge_Right
                                                            ofView:tempViews.lastObject
                                                         withInset:0]];
                
                [tempConstraints addObject:[verticalSpacer pinEdge:LayoutEdge_Top
                                                   toSuperviewEdge:LayoutEdge_Top]];
                
                [tempConstraints addObject:[verticalSpacer pinEdge:LayoutEdge_Bottom
                                                   toSuperviewEdge:LayoutEdge_Bottom]];
                
                [tempConstraints addObject:[verticalSpacer pinWidthEqualToView:tempVerticalSpacers.firstObject]];
                [tempVerticalSpacers addObject:verticalSpacer];
            }
            
            [self addSubview:newView];
            [tempViews addObject:newView];
            
            if (!referenceView) {
                referenceView = newView;
                anchorView = newView;
            }else if (j == 0){
                anchorView = newView;
                [tempConstraints addObject:[anchorView pinHeightEqualToView:referenceView]];
                [tempConstraints addObject:[anchorView pinWidthEqualToView:referenceView]];
            }else{
                [tempConstraints addObject:[newView pinWidthEqualToView:referenceView]];
                [tempConstraints addObject:[newView pinHeightEqualToView:referenceView]];
            }
            
            [tempConstraints addObject:[newView pinEdge:LayoutEdge_Left
                                                 toEdge:LayoutEdge_Right
                                                 ofView:verticalSpacer
                                              withInset:0]];
            
            [tempConstraints addObject:[newView pinEdge:LayoutEdge_Top
                                                 toEdge:LayoutEdge_Bottom
                                                 ofView:tempHorizontalSpacers.lastObject
                                              withInset:0]];
            
        }
    }
    
    UIView *verticalSpacer = [UIView new];
    verticalSpacer.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:verticalSpacer];
    [tempVerticalSpacers addObject:verticalSpacer];
    
    [tempConstraints addObject:[verticalSpacer pinEdge:LayoutEdge_Left
                                                toEdge:LayoutEdge_Right
                                                ofView:tempButtons.lastObject
                                             withInset:0]];
    
    [tempConstraints addObject:[verticalSpacer pinEdge:LayoutEdge_Right
                                       toSuperviewEdge:LayoutEdge_Right]];
    
    [tempConstraints addObject:[verticalSpacer pinEdge:LayoutEdge_Top
                                       toSuperviewEdge:LayoutEdge_Top]];
    [tempConstraints addObject:[verticalSpacer pinEdge:LayoutEdge_Bottom
                                       toSuperviewEdge:LayoutEdge_Bottom]];
    
    [tempConstraints addObject:[verticalSpacer pinWidthEqualToView:tempVerticalSpacers.firstObject]];
    
    UIView *hortizontalSpacer = [UIView new];
    hortizontalSpacer.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:hortizontalSpacer];
    
    [tempConstraints addObject:[hortizontalSpacer pinEdge:LayoutEdge_Top
                                                   toEdge:LayoutEdge_Bottom
                                                   ofView:tempButtons.lastObject
                                                withInset:0]];
    [tempConstraints addObject:[hortizontalSpacer pinEdge:LayoutEdge_Bottom
                                          toSuperviewEdge:LayoutEdge_Bottom]];
    [tempConstraints addObject:[hortizontalSpacer pinEdge:LayoutEdge_Left
                                          toSuperviewEdge:LayoutEdge_Left]];
    [tempConstraints addObject:[hortizontalSpacer pinEdge:LayoutEdge_Right
                                          toSuperviewEdge:LayoutEdge_Right]];
    [tempConstraints addObject:[hortizontalSpacer pinHeightEqualToView:tempHorizontalSpacers.firstObject]];
    
    [self addConstraints:tempConstraints];
    self.pitchLabels = tempPitchLabels;
    self.stepLabels = tempStepLabels;
    self.switchesConstraints = tempConstraints;
    self.switches = tempButtons;
}


@end
