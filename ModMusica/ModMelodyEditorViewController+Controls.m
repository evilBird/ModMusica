//
//  ModEditorViewController+Controls.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/30/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ModMelodyEditorViewController+Controls.h"

@implementation ModMelodyEditorViewController (Controls)

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
            NSLog(@"Play");
            button.selected = (BOOL)(1-(int)button.isSelected);
            break;
        default:
            break;
    }
}

@end
