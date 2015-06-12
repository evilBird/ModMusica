//
//  MMAudioScopeViewController+Layer.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/6/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMAudioScopeViewController.h"

@interface MMAudioScopeViewController (Layer)

- (CAShapeLayer *)newShapeLayer;

- (void)animateLayer:(CAShapeLayer *)shapeLayer
           transform:(CGAffineTransform)transform
            duration:(CGFloat)duration;

- (void)animateLayer:(CAShapeLayer *)shapeLayer
                path:(UIBezierPath *)path
            duration:(CGFloat)duration;

- (void)animateLayer:(CAShapeLayer *)shapeLayer toIdentityFromTransform:(CGAffineTransform)transform duration:(CGFloat)duration;

- (void)animateLayerZPosition:(CAShapeLayer *)shapeLayer
            duration:(CGFloat)duration;

- (void)animateLayer:(CAShapeLayer *)shapeLayer
             opacity:(CGFloat)opacity
            duration:(CGFloat)duration;


@end
