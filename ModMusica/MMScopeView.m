//
//  MMScopeView.m
//  ModMusica
//
//  Created by Travis Henspeter on 10/27/14.
//  Copyright (c) 2014 birdSound. All rights reserved.
//

#import "MMScopeView.h"
#import "UIColor+HBVHarmonies.h"
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

- (void)animateLineDrawingWithPoints:(NSArray *)points width:(CGFloat)lineWidth color:(UIColor *)lineColor duration:(NSTimeInterval)duration index:(NSInteger)index
{
    
    CAShapeLayer *shapeLayer = [self animateBezierPath:[self pathFromArray:points]
                                              duration:duration
                                                 color:lineColor
                                             lineWidth:lineWidth
                                                 index:index];
    
    if (shapeLayer == nil) {
        return;
    }
    
    static NSInteger rotate;
    rotate += 78;
    rotate = rotate%628;
    CGFloat angle = (CGFloat)rotate * 0.01;
    [self rotateShapeLayer:shapeLayer anchorPoint:[self anchorForPoints:points] angle:angle duration:duration];
    UIColor *oldColor = [UIColor colorWithCGColor:shapeLayer.strokeColor];
    [self changeColor:oldColor toNewColor:lineColor inShapeLayer:shapeLayer duration:duration];
}

- (CGPoint)anchorForPoints:(NSArray *)points
{
    if(!points){
        return self.layer.anchorPoint;
    }
    
    NSInteger middleIndex = points.count/2;
    NSValue *middleValue = points[middleIndex];
    CGPoint middlePoint = middleValue.CGPointValue;
    CGSize layerSize = self.layer.bounds.size;
    CGPoint anchorPoint;
    anchorPoint.x = middlePoint.x/layerSize.width;
    anchorPoint.y = middlePoint.y/layerSize.height;
    return anchorPoint;
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

- (UIBezierPath *)closedPathFromArray:(NSArray *)array
{
    UIBezierPath *result = nil;
    for (NSValue *value in array) {
        if (!result) {
            result = [UIBezierPath bezierPath];
            CGPoint pt;
            pt.x = CGRectGetMaxX(self.bounds);
            pt.y = CGRectGetMaxY(self.bounds);
            [result moveToPoint:pt];
            pt.x -= CGRectGetWidth(self.bounds);
            [result addLineToPoint:pt];
            [result addLineToPoint:[value CGPointValue]];
        }else{
            [result addLineToPoint:[value CGPointValue]];
        }
    }
    
    [result closePath];
    
    return result;
}

- (CAShapeLayer *)animateBezierPath:(UIBezierPath *)bezierPath duration:(CGFloat)duration color:(UIColor *)color lineWidth:(CGFloat)width index:(NSInteger)index;
{
    CAShapeLayer *bezier = [[CAShapeLayer alloc] init];
    bezier.path          = bezierPath.CGPath;
    bezier.lineWidth     = width;
    bezier.strokeStart   = 0.0;
    bezier.strokeEnd     = 1.0;
    
    if (index < self.layer.sublayers.count) {
        CAShapeLayer *shapeLayer = self.layer.sublayers[index];
        if (![shapeLayer isKindOfClass:[CAShapeLayer class]]) {
            return nil;
        }
        bezier.strokeColor = shapeLayer.fillColor;
        bezier.fillColor = shapeLayer.fillColor;
        [self.layer replaceSublayer:self.layer.sublayers[index] with:bezier];
        
    }else{
        UIColor *randomColor = [UIColor randomColor];
        bezier.strokeColor = randomColor.CGColor;
        bezier.fillColor = randomColor.CGColor;
        [self.layer addSublayer:bezier];
    }
    
    CABasicAnimation *animateStrokeEnd = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animateStrokeEnd.duration  = duration;
    animateStrokeEnd.fromValue = [NSNumber numberWithFloat:0.0f];
    animateStrokeEnd.toValue   = [NSNumber numberWithFloat:1.0f];
    [bezier addAnimation:animateStrokeEnd forKey:@"strokeEndAnimation"];
    
    return bezier;
}

- (void)rotateShapeLayer:(CAShapeLayer *)shapeLayer anchorPoint:(CGPoint)anchorPoint angle:(CGFloat)angle duration:(CGFloat)duration
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.duration = duration;
    animation.fromValue = [NSValue valueWithCATransform3D:shapeLayer.transform];
    CATransform3D new = CATransform3DRotate(shapeLayer.transform, angle, 0, 0, 1);
    animation.toValue = [NSValue valueWithCATransform3D:new];
    shapeLayer.anchorPoint = anchorPoint;
    [shapeLayer addAnimation:animation forKey:@"strokeRotation"];
    [shapeLayer setValue:animation.toValue forKey:@"transform"];
}

- (void)changeColor:(UIColor *)oldColor toNewColor:(UIColor*)newColor inShapeLayer:(CAShapeLayer *)layer duration:(CGFloat)duration
{
    CABasicAnimation *strokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
    strokeAnimation.fromValue  = (id) oldColor.CGColor;
    strokeAnimation.toValue = (id) newColor.CGColor;
    strokeAnimation.duration = duration;
    [layer addAnimation:strokeAnimation forKey:@"strokeAnimation"];
    layer.strokeColor = newColor.CGColor;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate touchesBeganInScopeView:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate touchesEndedInScopeView:self];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
