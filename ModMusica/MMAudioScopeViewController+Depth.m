//
//  MMAudioScopeViewController+Depth.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/11/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMAudioScopeViewController+Depth.h"
#import "MMAudioScopeViewController+Layer.h"

@implementation MMAudioScopeViewController (Depth)

- (void)setupDepthOfField
{
    [self setEyePosition:EYE_POSITION];
    self.depthManager = [[MMScopeDepthManager alloc]initWithDelegate:self];
}

- (void)startUpdatingDepth
{
    [self.depthManager startUpdates];
}

- (void)stopUpdatingDepth
{
    [self.depthManager endUpdates];
}

- (void)setEyePosition:(double)eyePosition
{
    CATransform3D perspective = CATransform3DIdentity;
    perspective.m34 = -1.0/eyePosition;
    // Apply the transform to a parent layer.
    self.contentView.layer.sublayerTransform = perspective;
}

- (CGFloat)wrapValue:(CGFloat)value minimum:(CGFloat)min maximum:(CGFloat)max
{
    if (value < min) {
        value = max;
    }
    
    if (value > max) {
        value = min;
    }
    
    return value;
}

#pragma mark - MMScopeDepthManager
- (double)animationDuration
{
    return DEPTH_ANIM_DURATION;
}

- (double)minZPosition
{
    return kMinZPosition;
}

- (double)maxZPosition
{
    return kMaxZPosition;
}

- (NSArray *)shapeLayersForDepthManager:(id)sender
{
    return self.shapeLayers;
}

- (void)depthManager:(id)sender animateLayerAtIndex:(NSUInteger)index
{
    if (!self.shapeLayers || !self.shapeLayers.count || index >= self.shapeLayers.count) {
        return;
    }
    
    CAShapeLayer *layer = self.shapeLayers[index];
    NSUInteger coin = arc4random_uniform(2);
    CGFloat reflect = 1.0;
    if (coin) {
        reflect = -1.0;
    }
    CGFloat padding = (reflect * 50.0/(CGFloat)self.shapeLayers.count);
    CGFloat offset = reflect * 25.0;
    CGFloat vert = (((CGFloat)index * padding) - offset);
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [self animateLayerZPosition:layer duration:DEPTH_ANIM_DURATION];
        layer.affineTransform = CGAffineTransformMakeTranslation((arc4random_uniform(10)-5),vert);
    }];
}

@end
