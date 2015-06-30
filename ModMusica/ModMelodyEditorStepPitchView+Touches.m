//
//  ModMelodyEditorStepPitchView+Touches.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/30/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ModMelodyEditorStepPitchView+Touches.h"

@implementation ModMelodyEditorStepPitchView (Touches)

- (void)handleTouches:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [touches.allObjects.lastObject locationInView:self];
    CGFloat buttonWidth,buttonHeight;
    buttonWidth = (self.bounds.size.width - ((OUTERPADDING- INNERPADDING) * 2.0))/(CGFloat)([self.datasource numSteps]);
    buttonHeight = (self.bounds.size.height - ((OUTERPADDING - INNERPADDING) * 2.0))/(CGFloat)([self.datasource numPitches]);
    
    CGFloat minX = (OUTERPADDING - INNERPADDING);
    CGFloat minY = (OUTERPADDING - INNERPADDING);
    CGFloat maxX = (self.bounds.size.width - (OUTERPADDING - INNERPADDING));
    CGFloat maxY = (self.bounds.size.height - (OUTERPADDING - INNERPADDING));
    
    if (point.x < minX || point.x > maxX || point.y < minY || point.y > maxY) {
        return;
    }
    
    point.x-=((OUTERPADDING - INNERPADDING) * 2.0);
    point.y-=((OUTERPADDING - INNERPADDING) * 2.0);
    
    double step = round(point.x/buttonWidth);
    double pitch = round(point.y/buttonHeight);
    
    NSUInteger index = (NSUInteger)(pitch * [self.datasource numSteps] + step);
    
    if (index >= self.switches.count) {
        return;
    }
    
    NSLog(@"\ntouch in step %@, pitch %@\n",@(step),@(pitch));
    ModMelodyEditorSwitch *button = nil;
    button = self.switches[index];
    
    if (button.tag != self.activeSwitchTag) {
        button.value = 1 - button.value;
    }
    
    self.activeSwitchTag = button.tag;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handleTouches:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handleTouches:touches withEvent:event];
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handleTouches:touches withEvent:event];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handleTouches:touches withEvent:event];
    
}


@end
