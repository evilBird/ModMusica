//
//  MMScrollView.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/29/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMScrollView.h"

@implementation MMScrollView

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    NSLog(@"\ntouch in content view with tag: %@\n",@(view.tag));

    CGPoint point = [touches.allObjects.lastObject locationInView:view];
    NSUInteger tag = [view hitTest:point withEvent:event].tag;
    NSLog(@"\ntouch in view with tag: %@\n",@(tag));
    if (tag == 1001) {
        return YES;
    }
    
    return NO;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    NSLog(@"\ncancel touch in content view with tag: %@\n",@(view.tag));
    if (view.tag == 1001) {
        return NO;
    }
    
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
