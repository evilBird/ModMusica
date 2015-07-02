//
//  ModEditorViewController+Controls.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/30/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ModMelodyEditorViewController+Controls.h"
#import "UIColor+HBVHarmonies.h"

@implementation ModMelodyEditorViewController (Controls)

- (IBAction)tapInButton:(id)sender {
    
    UIButton *button = sender;
    switch (button.tag) {
        case 0:
            NSLog(@"Save");
            break;
        case 1:
            NSLog(@"Clear");
            break;
            
        case 2:
            NSLog(@"Revert");
            break;
            
        case 3:
            NSLog(@"Play");
            button.selected = (BOOL)(1-(int)button.isSelected);
            [self.delegate editor:self playbackChanged:(float)button.isSelected];
            break;
            
        case 4:
            NSLog(@"Close");
            [self.delegate editorShouldClose:self completion:nil];
            break;
            
        default:
            break;
    }
}

- (void)updateButtonColors
{
    UIColor *complement = [self.mainColor complement];
    for (UIButton *button in self.buttons) {
        [button setBackgroundColor:complement];
        [button setTitleColor:self.mainColor forState:UIControlStateNormal];
        [button setTitleColor:self.mainColor forState:UIControlStateSelected];
        button.layer.cornerRadius = 5;
    }
}

@end
