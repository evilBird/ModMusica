//
//  MMAudioScopeViewController+Layer.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/6/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMAudioScopeViewController+Layer.h"
#import "UIColor+HBVHarmonies.h"

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

- (void)randomizeColorsInShapeLayers:(NSArray *)shapeLayers
{
    for (CAShapeLayer *layer in shapeLayers) {
        UIColor *randomColor = [UIColor randomColor];
        UIColor *myColor = [randomColor adjustAlpha:0.1333];
        layer.fillColor = myColor.CGColor;
        layer.strokeColor = randomColor.CGColor;
        layer.lineWidth = (arc4random_uniform(4) + 2)/2.0;
    }
}

- (void)randomizeAlphasInShapeLayers:(NSArray *)shapeLayers coefficient:(CGFloat)coeff
{
    for (CAShapeLayer *layer in shapeLayers) {
        CGFloat randomAlpha = arc4random_uniform(100) * 0.01 * coeff;
        CGColorRef col = layer.fillColor;
        UIColor *prevColor = [UIColor colorWithCGColor:col];
        UIColor *adjustedColor = [prevColor adjustAlpha:randomAlpha];
        layer.fillColor = adjustedColor.CGColor;
    }
}

- (void)animateLayer:(CAShapeLayer *)shapeLayer
             newPath:(UIBezierPath *)newPath
             oldPath:(UIBezierPath *)oldPath
            duration:(CGFloat)duration
{
    
    if (!oldPath) {
        shapeLayer.path = newPath.CGPath;
        return;
    }
    
    CABasicAnimation *anim = [[CABasicAnimation alloc]init];
    anim.keyPath = @"path";
    anim.fromValue = (__bridge id)(oldPath.CGPath);
    anim.toValue = (__bridge id)(newPath.CGPath);
    anim.duration = duration;
    [shapeLayer addAnimation:anim forKey:@"scopeData"];
}

- (void)animateLayer:(CAShapeLayer *)shapeLayer
           transform:(CGAffineTransform)transform
            duration:(CGFloat)duration
{
    CABasicAnimation *anim = [[CABasicAnimation alloc]init];
    anim.keyPath = @"affineTransform";
    anim.fromValue = [NSValue valueWithCGAffineTransform:shapeLayer.affineTransform];
    anim.toValue = [NSValue valueWithCGAffineTransform:transform];
    anim.duration = duration;
    anim.removedOnCompletion = NO;
    shapeLayer.affineTransform = transform;
    [shapeLayer addAnimation:anim forKey:@"scopeData"];
}


- (void)addGradientToLayer:(CALayer *)layer
                withColors:(NSArray *)colors
                 locations:(NSArray *)locations
{
    /*
    if (!colors.count || !locations.count || colors.count != locations.count) {
        return;
    }
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSMutableArray *myColors = [NSMutableArray array];
    NSArray *gradientColors = nil;
    for (UIColor *color in colors) {
        
    }
    
    [NSArray arrayWithObjects:
                               (id)[UIColor blueColor].CGColor,
                               (id)gradientColor.CGColor,
                               (id)[UIColor redColor].CGColor, nil];
    CGFloat gradientLocations[] = {0, 0.5, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)gradientColors, gradientLocations);
    
    gradientLayer.colors = (__bridge NSArray *)(gradient);
    
    gradientLayer.startPoint = CGPointMake(0.0,0.7);
    gradientLayer.endPoint = CGPointMake(1,-0.1);
    [self.layer addSublayer:gradientLayer];
    gradientLayer.mask = arc;
     */
}

@end
