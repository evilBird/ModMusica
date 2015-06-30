//
//  ModMelodyEditorStepPitchView+Setup.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/30/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ModMelodyEditorStepPitchView+Setup.h"

@implementation ModMelodyEditorStepPitchView (Setup)

- (void)tearDownSwitches
{
    [self removeConstraints:self.switchesConstraints];
    
    for (ModMelodyEditorSwitch *button in self.switches) {
        [button removeTarget:self action:@selector(buttonValueChanged:) forControlEvents:UIControlEventValueChanged];
        [button removeFromSuperview];
    }
    
    self.switches = nil;
}

- (void)setupSwitches
{
    NSUInteger numSteps = [self.datasource numSteps];
    NSUInteger numPitches = [self.datasource numPitches];
    
    if (!numSteps || !numPitches) {
        return;
    }
    
    [self tearDownSwitches];
    
    NSMutableArray *tempButtons = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < numPitches; i ++) {
        
        for (NSUInteger j = 0; j < numSteps; j ++) {
            
            ModMelodyEditorSwitch *button = [ModMelodyEditorSwitch new];
            button.translatesAutoresizingMaskIntoConstraints = NO;
            button.tag = (i * numSteps) + j;
            button.backgroundColor = [UIColor clearColor];
            button.value = 0;
            button.layer.borderWidth = 0.5;
            button.layer.borderColor = [UIColor blackColor].CGColor;
            button.layer.cornerRadius = 2.0;
            button.mainColor = [self.delegate mainColor];
            button.userInteractionEnabled = NO;
            [button addTarget:self action:@selector(buttonValueChanged:) forControlEvents:UIControlEventValueChanged];
            if (button) {
                [tempButtons addObject:button];
                [self addSubview:button];
            }
        }
    }
    
    self.switches = tempButtons;
}

@end
