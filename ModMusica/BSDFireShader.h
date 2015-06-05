//
//  BSDFireShader.h
//  ModMusica
//
//  Created by Travis Henspeter on 12/6/14.
//  Copyright (c) 2014 birdSound. All rights reserved.
//

#import "GPUImageFilter.h"

@interface BSDFireShader : GPUImageFilter
{
    GLint globalTimeUniform, resolutionUniform;
}

@property (nonatomic)CGFloat globalTime;

@end
