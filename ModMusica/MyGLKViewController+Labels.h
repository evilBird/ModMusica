//
//  MyGLKViewController+Labels.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/19/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MyGLKViewController.h"

@interface MyGLKViewController (Labels)

- (void)setupLabels;
- (void)hideLabelsAnimated:(BOOL)animated;
- (void)showLabelsAnimated:(BOOL)animated;
- (void)showTempoInfo:(NSString *)tempoInfo;
- (void)updateLabelText;
- (void)updateLabelColors;
@end
