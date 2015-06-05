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

@interface MMVisualViewController : UIViewController <MMPlaybackDelegate>

- (void)setupFilter;
- (void)processImage;
- (GPUImageFilter *)makeFilter;
- (UIImage *)baseImage;

@property (nonatomic,strong)GPUImageFilter *filter;
@property (nonatomic,strong)GPUImageView *imageView;
@property (nonatomic,strong)GPUImagePicture *picture;

#pragma mark - MMPlaybackDelegate

- (void)playback:(id)sender clockDidChange:(NSInteger)clock;

@end
