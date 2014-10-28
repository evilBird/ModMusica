//
//  MMScopeView.m
//  ModMusica
//
//  Created by Travis Henspeter on 10/27/14.
//  Copyright (c) 2014 birdSound. All rights reserved.
//

#import "MMScopeView.h"
typedef void (^Render)(void);

@interface MMScopeView ()


@end

@implementation MMScopeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _lineWidth = 2;
        _animateDuration = 1;
    }
    return self;
}

-(void)displayData:(NSArray *)data{
    
    UIBezierPath *path = [self pathFromArray:data];
    [self animateBezierPath:path duration:self.animateDuration color:[UIColor redColor] lineWidth:2 index:0];
}

- (UIBezierPath *)pathFromArray:(NSArray *)array
{
    UIBezierPath *result = nil;
    for (NSValue *value in array) {
        if (!result) {
            result = [UIBezierPath bezierPath];
            [result moveToPoint:[value CGPointValue]];
        }else{
            [result addLineToPoint:[value CGPointValue]];
        }
    }
    
    return result;
}


- (void)animateBezierPath:(UIBezierPath *)bezierPath duration:(CGFloat)duration color:(UIColor *)color lineWidth:(CGFloat)width index:(NSInteger)index;
{
    CAShapeLayer *bezier = [[CAShapeLayer alloc] init];
    
    bezier.path          = bezierPath.CGPath;
    bezier.strokeColor   = color.CGColor;
    bezier.fillColor     = [UIColor clearColor].CGColor;
    bezier.lineWidth     = width;
    bezier.strokeStart   = 0.0;
    bezier.strokeEnd     = 1.0;
    if (index < self.layer.sublayers.count) {
        
        [self.layer replaceSublayer:self.layer.sublayers[index] with:bezier];
        
    }else{
        
        [self.layer addSublayer:bezier];
    }
    
    CABasicAnimation *animateStrokeEnd = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animateStrokeEnd.duration  = duration;
    animateStrokeEnd.fromValue = [NSNumber numberWithFloat:0.0f];
    animateStrokeEnd.toValue   = [NSNumber numberWithFloat:1.0f];
    [bezier addAnimation:animateStrokeEnd forKey:@"strokeEndAnimation"];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
