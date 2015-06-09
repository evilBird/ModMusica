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

- (void)randomizeColorsInShapeLayers:(NSArray *)shapeLayers;
- (void)randomizeAlphasInShapeLayers:(NSArray *)shapeLayers coefficient:(CGFloat)coeff;

- (void)animateLayer:(CAShapeLayer *)shapeLayer
             newPath:(UIBezierPath *)newPath
             oldPath:(UIBezierPath *)oldPath
            duration:(CGFloat)duration;



- (void)addGradientToLayer:(CALayer *)layer
                withColors:(NSArray *)colors
                 locations:(NSArray *)locations;



@end
