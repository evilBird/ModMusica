//
//  MMAudioScopeViewController+Path.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/6/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMAudioScopeViewController.h"

@interface MMAudioScopeViewController (Path)

- (NSArray *)setupPathBuffers:(NSInteger)count;
- (UIBezierPath *)pathWithScopeData:(NSArray *)data;

@end
