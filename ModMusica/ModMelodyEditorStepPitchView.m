//
//  ModEditorButtonView.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/29/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ModMelodyEditorStepPitchView.h"
#import "ModMelodyEditorSwitch.h"
#import "ModMelodyEditorStepPitchView+Layout.h"
#import "ModMelodyEditorStepPitchView+Touches.h"
#import "ModMelodyEditorStepPitchView+Setup.h"


@interface ModMelodyEditorStepPitchView ()

@end

@implementation ModMelodyEditorStepPitchView

- (void)buttonValueChanged:(id)sender
{
    if ([sender isKindOfClass:[ModMelodyEditorSwitch class]]) {
        ModMelodyEditorSwitch *button = sender;
        NSLog(@"\nbutton with tag %@ has value %@\n",@(button.tag),@(button.value));
    }
}


- (void)configureWithDelegate:(id<ModMelodyEditorStepPitchViewDelegate>)delegate datasource:(id<ModEditorDatasource>)datasource
{
    self.delegate = delegate;
    self.datasource = datasource;
    [self setupSwitches];
    [self configureConstraints];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
