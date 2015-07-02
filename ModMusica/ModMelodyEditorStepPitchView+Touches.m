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
    UILabel *pitchLabel = self.pitchLabels.firstObject;
    UILabel *stepLabel = self.stepLabels.firstObject;
    
    CGFloat minX = pitchLabel.bounds.size.width;
    CGFloat minY = stepLabel.bounds.size.height;
    CGFloat maxX = (self.bounds.size.width - minX);
    CGFloat maxY = (self.bounds.size.height - minY);
    CGFloat activeWidth = self.bounds.size.width - (minX * 2.0);
    CGFloat activeHeight = self.bounds.size.height - (minY * 2.0);
    buttonWidth = activeWidth/(CGFloat)([self.datasource numSteps]);
    buttonHeight = activeHeight/(CGFloat)([self.datasource numPitches]);
    
    if (point.x < minX || point.x > maxX || point.y < minY || point.y > maxY) {
        return;
    }
    
    point.x-=(minX * 2.0);
    point.y-=(minY * 2.0);
    
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
