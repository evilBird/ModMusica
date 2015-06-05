//
//  BSDKaleidoscopeFilter.h
//  GPUImage
//
//  Created by Travis Henspeter on 12/4/14.
//  Copyright (c) 2014 Brad Larson. All rights reserved.
//

#import "GPUImageFilter.h"

@interface BSDKaleidoscopeFilter : GPUImageFilter

{
    GLint sidesUniform, tauUniform;
}

@property(readwrite, nonatomic) CGFloat sides;
@property(readwrite, nonatomic) CGFloat tau;

@end
