//
//  MMModEditorButton.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/29/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ModMelodyEditorSwitch.h"

@implementation ModMelodyEditorSwitch

- (NSUInteger)stepIndexForPatternLength:(NSUInteger)patternLength
{
    int myTag = (int)self.tag;
    int theLength = (int)patternLength;
    int result = myTag%theLength;
    
    return (NSUInteger)result;
}

- (void)setInitialValue:(NSUInteger)initValue
{
    _value = initValue;
    if (_value) {
        self.backgroundColor = self.mainColor;
    }else{
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)setValue:(NSUInteger)value
{
    NSUInteger prevValue = _value;
    _value = value;
    if (_value) {
        self.backgroundColor = self.mainColor;
    }else{
        self.backgroundColor = [UIColor clearColor];
    }
    if (value != prevValue) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
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
