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
    
    UIColor *color = [lineColor jitterWithPercent:10];
    CAShapeLayer *shapeLayer = [self animateBezierPath:[self pathFromArray:points]
                                              duration:duration
                                                 color:color
                                             lineWidth:lineWidth
                                                 index:index];
    
    if (shapeLayer == nil) {
        return;
    }
    
    static NSInteger rotate;
    rotate += 78 * (CGFloat)(arc4random_uniform(100)<50);
    rotate = rotate%628;
    CGFloat angle = (CGFloat)rotate * 0.01;
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
    
    NSInteger count = self.layer.sublayers.count;
    if (count > 0) {
        CGFloat z = (CGFloat)index/(CGFloat)count;
        z *= z;
        shapeLayer.zPosition = z;
        CGFloat cz = (1.0 - z) * 0.5;
        cz *= cz;
        shapeLayer.shadowColor = [UIColor colorWithRed:cz * cz green:cz * cz blue:cz * cz alpha:1.0].CGColor;
        shapeLayer.shadowOpacity = cz;
        shapeLayer.shadowRadius = z;
    }
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
    
    BOOL jitter = YES;
    if (jitter) {
        anchorPoint.x += (arc4random_uniform(500) - 250);
        anchorPoint.y += (arc4random_uniform(500) - 250);
    }
    
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
    CGFloat rand = arc4random_uniform(100) * 0.01;
    CGFloat val = (CGFloat)(rand  > 0.5);
    bezier.strokeStart   = val;
    bezier.strokeEnd     = 1.0 - val;
    UIColor *randomColor = [UIColor randomColor];
    bezier.strokeColor = randomColor.CGColor;
    bezier.fillColor = randomColor.CGColor;
    [self.layer addSublayer:bezier];
    
    if (index < self.layer.sublayers.count) {
        CAShapeLayer *shapeLayer = self.layer.sublayers[index];
        if ([shapeLayer isKindOfClass:[CAShapeLayer class]]) {
            CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"fillColor"];
            fade.fromValue = [UIColor colorWithCGColor:shapeLayer.fillColor];
            fade.toValue = [fade.fromValue colorHarmonyWithExpression:^CGFloat(CGFloat value) {
                return value;
            } alpha:0.0];
            
            fade.duration = self.animateDuration * 0.004;
            [shapeLayer addAnimation:fade forKey:@"fadeOutAnimation"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(fade.duration * 1.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [shapeLayer removeFromSuperlayer];
            });
            
            CABasicAnimation *fade2 = [CABasicAnimation animationWithKeyPath:@"stokeColor"];
            fade2.fromValue = [UIColor colorWithCGColor:shapeLayer.strokeColor];
            fade2.toValue = [fade2.fromValue colorHarmonyWithExpression:^CGFloat(CGFloat value) {
                return value;
            } alpha:0.0];
            
            fade2.duration = self.animateDuration * 0.004;
            [shapeLayer addAnimation:fade2 forKey:@"fadeOutAnimation2"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(fade.duration * 1.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [shapeLayer removeFromSuperlayer];
            });
            
        }
    }
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
    animation.duration = duration * 1.1;
    animation.fromValue = [NSValue valueWithCATransform3D:shapeLayer.transform];
    CGFloat z = (CGFloat)index/(CGFloat)count;
    z *= z;
    CGFloat rand = (CGFloat)(arc4random_uniform(100) > 50);
    if (rand == 0) {
        rand = -1.0f;
    }
    CATransform3D new = CATransform3DRotate(shapeLayer.transform, z * rand, 0, 0, z * rand);
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
