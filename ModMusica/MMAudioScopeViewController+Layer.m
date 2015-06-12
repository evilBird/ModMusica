//
//  MMAudioScopeViewController+Layer.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/6/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMAudioScopeViewController+Layer.h"
#import "UIColor+HBVHarmonies.h"
#import "MMAudioScopeViewController+Depth.h"

@implementation MMAudioScopeViewController (Layer)

- (CAShapeLayer *)newShapeLayer
{
    CAShapeLayer *shapeLayer = nil;
    shapeLayer = [[CAShapeLayer alloc]init];
    shapeLayer.frame = self.view.bounds;
    shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    return shapeLayer;
}

- (void)animateLayer:(CAShapeLayer *)shapeLayer
                path:(UIBezierPath *)path
            duration:(CGFloat)duration
{
    CABasicAnimation *anim = [[CABasicAnimation alloc]init];
    anim.keyPath = @"path";
    CAShapeLayer *presentationLayer = shapeLayer.presentationLayer;
    anim.fromValue = (__bridge id)(presentationLayer.path);
    anim.toValue = (__bridge id)(path.CGPath);
    anim.duration = duration;
    anim.removedOnCompletion = YES;
    [shapeLayer addAnimation:anim forKey:@"scopeDataPath"];
    shapeLayer.path = path.CGPath;
}

- (void)animateLayer:(CAShapeLayer *)shapeLayer toIdentityFromTransform:(CGAffineTransform)transform duration:(CGFloat)duration
{
    NSString *key = @"affineTransform";
    CAShapeLayer *temp = [CAShapeLayer layer];
    temp.affineTransform = transform;
    CABasicAnimation *anim = [[CABasicAnimation alloc]init];
    anim.keyPath = key;
    anim.fromValue = [NSValue valueWithCGAffineTransform:transform];
    anim.duration = duration;
    temp.affineTransform = CGAffineTransformIdentity;
    anim.toValue = [NSValue valueWithCGAffineTransform:CGAffineTransformIdentity];
    anim.removedOnCompletion = YES;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [shapeLayer addAnimation:anim forKey:@"layerOffset"];
    shapeLayer.affineTransform = transform;
}

- (void)animateLayerZPosition:(CAShapeLayer *)shapeLayer
            duration:(CGFloat)duration
{
    NSString *key = @"zPosition";
    CABasicAnimation *anim = [[CABasicAnimation alloc]init];
    anim.keyPath = key;
    anim.toValue = @(kMinZPosition);
    anim.fromValue = @(kMaxZPosition);
    anim.duration = duration;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    anim.removedOnCompletion = YES;
    [shapeLayer addAnimation:anim forKey:@"perspective"];
    shapeLayer.zPosition = kMinZPosition;
}

- (void)animateLayer:(CAShapeLayer *)shapeLayer
               opacity:(CGFloat)opacity
            duration:(CGFloat)duration
{
    NSString *key = @"opacity";
    CABasicAnimation *anim = [[CABasicAnimation alloc]init];
    anim.keyPath = key;
    CAShapeLayer *presentationLayer = shapeLayer.presentationLayer;
    anim.fromValue = [presentationLayer valueForKey:key];
    anim.toValue = @(opacity);
    anim.duration = duration;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [shapeLayer addAnimation:anim forKey:@"layerOpacity"];
    shapeLayer.opacity = opacity;
}

- (void)animateLayer:(CAShapeLayer *)shapeLayer
           transform:(CGAffineTransform)transform
            duration:(CGFloat)duration
{
    NSString *key = @"affineTransform";
    CABasicAnimation *anim = [[CABasicAnimation alloc]init];
    CAShapeLayer *presentationLayer = shapeLayer.presentationLayer;
    anim.keyPath = @"affineTransform";
    anim.fromValue = [presentationLayer valueForKey:key];
    CAShapeLayer *tempLayer = [[CAShapeLayer alloc]init];
    tempLayer.affineTransform = transform;
    anim.toValue = [tempLayer valueForKey:key];
    anim.duration = duration;
    anim.removedOnCompletion = NO;
    [shapeLayer addAnimation:anim forKey:@"scopeDataTransform"];
    shapeLayer.affineTransform = transform;
}




@end
