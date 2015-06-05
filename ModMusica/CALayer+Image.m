//
//  CALayer+Image.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/5/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "CALayer+Image.h"

@implementation CALayer (Image)

- (UIImage *)asImage
{
    UIGraphicsBeginImageContext(self.frame.size);
    [self renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
