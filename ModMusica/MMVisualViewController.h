//
//  MMVisualViewController.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/5/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"
#import "MMPlaybackController.h"
#import "CALayer+Image.h"

@interface MMVisualViewController : UIViewController <MMPlaybackDelegate>

- (void)setupFilter;
- (void)processImage;
- (GPUImageFilter *)makeFilter;
- (UIImage *)initialSourceImage;

- (UIBezierPath *)pathWithScopeData:(NSArray *)data;
- (void)animateScopePath:(UIBezierPath *)path duration:(CGFloat)duration;

@property (nonatomic,strong)        UIImage             *mySourceImage;
@property (nonatomic,strong)        GPUImageFilter      *filter;
@property (nonatomic,strong)        GPUImageView        *imageView;
@property (nonatomic,strong)        GPUImagePicture     *picture;
@property (nonatomic,strong)        CAShapeLayer        *shapeLayer;

#pragma mark - MMPlaybackDelegate

- (void)playback:(id)sender clockDidChange:(NSInteger)clock;

@end
