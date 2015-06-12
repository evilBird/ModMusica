//
//  MMAudioScopeViewController+Random.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/11/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMAudioScopeViewController.h"

@interface MMAudioScopeViewController (Random)

- (void)randomizeColors;
- (void)randomizeColorsInShapeLayers:(NSArray *)shapeLayers;
- (void)randomizeAlphasInShapeLayers:(NSArray *)shapeLayers coefficient:(CGFloat)coeff;


@end
