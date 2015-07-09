//
//  MMAudioScopeViewController+Random.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/11/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMAudioScopeViewController+Random.h"
#import "UIColor+HBVHarmonies.h"

@implementation MMAudioScopeViewController (Random)

- (void)randomizeColors
{
    [self randomizeColorsInShapeLayers:self.shapeLayers.mutableCopy];
    [self randomizeAlphasInShapeLayers:self.shapeLayers coefficient:0.25];
    UIColor *baseColor = [UIColor randomColor];
    self.view.backgroundColor = [baseColor jitterWithPercent:2];
    self.contentView.backgroundColor = [baseColor jitterWithPercent:2];
    self.label.textColor = [[baseColor complement]jitterWithPercent:5];
    self.titleLabel.textColor = [[baseColor complement]jitterWithPercent:5];
    self.nowPlayingLabel.textColor = [[baseColor complement] jitterWithPercent:5];
    self.hamburgerButton.mainColor = self.titleLabel.textColor;
}

- (void)randomizeColorsInShapeLayers:(NSArray *)shapeLayers
{
    for (CAShapeLayer *layer in shapeLayers) {
        UIColor *randomColor = [UIColor randomColor];
        UIColor *myColor = randomColor;//[randomColor adjustAlpha:0.1333];
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
        UIColor *adjustedColor = [prevColor setAlpha:randomAlpha];
        layer.fillColor = adjustedColor.CGColor;
    }
}

@end
