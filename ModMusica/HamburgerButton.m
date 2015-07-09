//
//  HamburgerButton.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "HamburgerButton.h"
#import "UIColor+HBVHarmonies.h"

@implementation HamburgerButton

- (void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
    self.tintColor = [UIColor clearColor];
    self.clearsContextBeforeDrawing = YES;
    _mainColor = [UIColor blueColor];
    self.alpha = 0.8;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)setMainColor:(UIColor *)mainColor
{
    _mainColor = [mainColor setAlpha:0.7];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *background = [UIBezierPath bezierPathWithRect:self.bounds];
    [[UIColor clearColor]setFill];
    [background fill];
    
    [self.mainColor setFill];
    [self.mainColor setStroke];
    
    CGFloat sectionHt = self.bounds.size.height;
    CGFloat kPad = 4;
    CGFloat totalPad = kPad*4;
    CGFloat filledHt = sectionHt - totalPad;
    CGFloat rectHt = filledHt/3;
    
    for (NSInteger i = 0; i < 3; i ++) {
        
        CGRect sectionRect;
        sectionRect.origin.x = 0;
        sectionRect.origin.y = i * rectHt + ((i + 1) * kPad);
        sectionRect.size.width = self.bounds.size.width;
        sectionRect.size.height = rectHt;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:sectionRect cornerRadius:1];
        [path stroke];
        [path fill];
    }
    
}

@end
