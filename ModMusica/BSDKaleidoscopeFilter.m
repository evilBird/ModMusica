//
//  BSDKaleidoscopeFilter.m
//  GPUImage
//
//  Created by Travis Henspeter on 12/4/14.
//  Copyright (c) 2014 Brad Larson. All rights reserved.
//

#import "BSDKaleidoscopeFilter.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageKaleidoscopeFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform highp float sides;
 uniform highp float tau;

 void main()
 {
     mediump vec2 p = textureCoordinate - 0.5;
     
     // cartesian to polar coordinates
     mediump float r = length(p);
     mediump float a = atan(p.y, p.x);
     
     // kaleidoscope
     a = mod(a, tau/sides);
     a = abs(a - tau/sides/2.);
     
     // polar to cartesian coordinates
     p = r * vec2(cos(a), sin(a));
     
     // sample the image
     mediump vec4 color = texture2D(inputImageTexture, p + 0.5);
     if (color[0] < 0.1){
         color[0] = 0.9;
     }
     if (color[1] < 0.1){
         color[1] = 0.9;
     }
     if (color[2] < 0.1){
         color[2] = 0.9;
     }
     color[3] = 1.0;
     gl_FragColor = color;
 }
 );
#else
NSString *const kGPUImageKaleidoscopeFragmentShaderString = SHADER_STRING
(
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform mediump float sides;
 uniform mediump float tau;
 
 void main()
 {
     mediump vec2 p = textureCoordinate - 0.5;
     
     // cartesian to polar coordinates
     mediump float r = length(p);
     mediump float a = atan(p.y, p.x);
     
     // kaleidoscope
     //mediump float tau = 4. * 3.1416;
     a = mod(a, tau/sides);
     a = abs(a - tau/sides/2.);
     
     // polar to cartesian coordinates
     p = r * vec2(cos(a), sin(a));
     // sample the image
     mediump vec4 color = texture2D(inputImageTexture, p + 0.5);
     if (color[0] < 0.1){
         color[0] = 0.9;
     }
     if (color[1] < 0.1){
         color[1] = 0.9;
     }
     if (color[2] < 0.1){
         color[2] = 0.9;
     }
     color[3] = 1.0;
     gl_FragColor = color;
 }
 );
#endif

@implementation BSDKaleidoscopeFilter

- (id)init;
{
    if (!(self = [self initWithFragmentShaderFromString:kGPUImageKaleidoscopeFragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}

- (id)initWithFragmentShaderFromString:(NSString *)fragmentShaderString;
{
    if (!(self = [super initWithFragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }
    
    sidesUniform = [filterProgram uniformIndex:@"sides"];
    tauUniform = [filterProgram uniformIndex:@"tau"];
    
    self.sides = 6.;
    self.tau = 2.;
    return self;
}

- (void)setSides:(CGFloat)sides
{
    _sides = sides;
    [self setFloat:_sides forUniform:sidesUniform program:filterProgram];
}

- (void)setTau:(CGFloat)tau
{
    _tau = tau;
    
    CGFloat t = tau * 3.1416;
    [self setFloat:t forUniform:tauUniform program:filterProgram];
}

@end
