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
    
    UIColor *color = lineColor;
    if (index%2 == 1) {
        color = [lineColor complement];
    }
    
    CAShapeLayer *shapeLayer = [self animateBezierPath:[self pathFromArray:points]
                                              duration:duration
                                                 color:color
                                             lineWidth:lineWidth
                                                 index:index];
    
    if (shapeLayer == nil) {
        return;
    }
    
    CGFloat progress = (CGFloat)index/(CGFloat)self.layer.sublayers.count;
    CGFloat remaining = 1.0f - progress;
    CGFloat angle = remaining * 6.28318;
    angle -= 3.14159;
    NSInteger layers = self.layer.sublayers.count;
    if (layers > 1) {
        [self rotateShapeLayer:shapeLayer
                   anchorPoint:[self anchorForPoints:points]
                         angle:angle duration:duration
                         index:index
                         count:layers];
    }
    UIColor *oldColor = [UIColor colorWithCGColor:shapeLayer.strokeColor];
    [self changeColor:oldColor toNewColor:lineColor inShapeLayer:shapeLayer duration:duration];
}

- (CGPoint)anchorForPoints:(NSArray *)points
{
    if(!points){
        return self.layer.anchorPoint;
    }
    
    static NSInteger idx;
    idx += 1;
    NSInteger i = idx%4;
    CGRect bounds = self.bounds;
    CGPoint origin = bounds.origin;
    switch (i) {
        case 0:
            return origin;
            break;
            case 1:
            origin.x += CGRectGetWidth(bounds);
            return origin;
            break;
            case 2:
            origin.x += CGRectGetWidth(bounds);
            origin.y += CGRectGetHeight(bounds);
            return origin;
            break;
            case 3:
            origin.y += CGRectGetHeight(bounds);
            break;
            
        default:
            break;
    }
    
    return origin;
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
    CGFloat rand = arc4random_uniform(100) * 0.01;
    CGFloat val = (CGFloat)(rand  > 0.5);
    bezier.strokeStart   = val;
    bezier.strokeEnd     = 1.0 - val;
    bezier.strokeColor = color.CGColor;
    bezier.fillColor = color.CGColor;
    
    if (index < self.layer.sublayers.count) {
        CAShapeLayer *shapeLayer = self.layer.sublayers[index];
        if ([shapeLayer isKindOfClass:[CAShapeLayer class]]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.animateDuration * 0.000001 * 1.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [shapeLayer removeFromSuperlayer];
            });
        }
    }
    
    [self.layer addSublayer:bezier];
    
    CABasicAnimation *animateStrokeEnd = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animateStrokeEnd.duration  = duration;
    animateStrokeEnd.fromValue = [NSNumber numberWithFloat:val];
    animateStrokeEnd.toValue   = [NSNumber numberWithFloat:1.0f - val];
    [bezier addAnimation:animateStrokeEnd forKey:@"strokeEndAnimation"];
    
    return bezier;
}

- (void)rotateShapeLayer:(CAShapeLayer *)shapeLayer anchorPoint:(CGPoint)anchorPoint angle:(CGFloat)angle duration:(CGFloat)duration index:(NSInteger)index count:(NSInteger)count
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.duration = duration + (self.animateDuration * 0.000001 * 1.2);
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
    
    CABasicAnimation *fillAnimation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
    fillAnimation.fromValue  = (id) oldColor.CGColor;
    fillAnimation.toValue = (id) newColor.CGColor;
    fillAnimation.duration = duration;
    [layer addAnimation:strokeAnimation forKey:@"fillAnimation"];
    layer.fillColor = newColor.CGColor;
    
}
/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate touchesBeganInScopeView:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate touchesEndedInScopeView:self];
}
*/

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
