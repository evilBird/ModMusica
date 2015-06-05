//
//  BSDFractalFilter.h
//  SimpleImageFilter
//
//  Created by Travis Henspeter on 12/4/14.
//  Copyright (c) 2014 Cell Phone. All rights reserved.
//

#import "GPUImage.h"

@interface BSDFractalFilter : GPUImageFilter
{
    GLint iGlobalTimeUniform, iResolutionUniform;
}

@property (nonatomic)CGFloat iGlobalTime;
@property (nonatomic)CGSize iResolution;
@property (nonatomic,strong)NSDate *startDate;

- (void)incrementTimer;

@end
