//
//  MMModEditorButton.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/29/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMModEditorButton.h"

@implementation MMModEditorButton

- (void)setValue:(NSUInteger)value
{
    NSUInteger prevValue = _value;
    _value = value;
    if (value != prevValue) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        if (_value) {
            self.backgroundColor = self.mainColor;
        }else{
            self.backgroundColor = [UIColor clearColor];
        }
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
