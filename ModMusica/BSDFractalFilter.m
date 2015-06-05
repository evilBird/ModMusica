//
//  BSDFractalFilter.m
//  SimpleImageFilter
//
//  Created by Travis Henspeter on 12/4/14.
//  Copyright (c) 2014 Cell Phone. All rights reserved.
//

#import "BSDFractalFilter.h"
/*
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageFractalFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform lowp float iGlobalTime;
 
 uniform lowp vec3 iResolution;
 
 void main()
 {
     lowp vec2 p = -1.0 + 2.0 * gl_FragCoord.xy / iResolution.xy;
     p.x *= iResolution.x/iResolution.y;
     
     //float zoo = 1.0/250.0;
     
     lowp float zoo = 1.0/250.0;
     
     zoo = 1.0/(400.0 - 150.0*sin(0.15*iGlobalTime-0.3));
     
     lowp vec2 cc = vec2(-0.533516,0.526141) + p*zoo;
     
     lowp vec2 t2c = vec2(-0.5,2.0);
     t2c += 0.5*vec2( cos(0.13*(iGlobalTime-10.0)), sin(0.13*(iGlobalTime-10.0)) );
     
     // iterate
     lowp vec2 z  = vec2(0.0);
     lowp vec2 dz = vec2(0.0);
     lowp float trap1 = 0.0;
     lowp float trap2 = 1e20;
     lowp float co2 = 0.0;
     for( int i=0; i<128; i++ )
     {
         if( dot(z,z)>1024.0 ) continue;
         
         // Z' -> 2·Z·Z' + 1
         dz = 2.0*vec2(z.x*dz.x-z.y*dz.y, z.x*dz.y + z.y*dz.x ) + vec2(1.0,0.0);
         
         // Z -> Z² + c
         z = cc + vec2( z.x*z.x - z.y*z.y, 2.0*z.x*z.y );
         
         // trap 1
         lowp float d1 = abs(dot(z-vec2(0.0,1.0),vec2(0.707)));
         lowp float ff = step( d1, 1.0 );
         co2 += ff;
         trap1 += ff*d1;
         
         //trap2
         trap2 = min( trap2, dot(z-t2c,z-t2c) );
     }
     
     // distance, d(c) = |Z|·log|Z|/|Z'|
     lowp float d = sqrt( dot(z,z)/dot(dz,dz) )*log(dot(z,z));
     
     lowp float c1 = pow( clamp( 2.00*d/zoo,    0.0, 1.0 ), 0.5 );
     lowp float c2 = pow( clamp( 1.5*trap1/co2, 0.0, 1.0 ), 2.0 );
     lowp float c3 = pow( clamp( 0.4*trap2, 0.0, 1.0 ), 0.25 );
     
     lowp vec3 col1 = 0.5 + 0.5*sin( 3.0 + 4.0*c2 + vec3(0.0,0.5,1.0) );
     lowp vec3 col2 = 0.5 + 0.5*sin( 4.1 + 2.0*c3 + vec3(1.0,0.5,0.0) );
     lowp vec3 col = 2.0*sqrt(c1*col1*col2);
     
     gl_FragColor = vec4( col, 1.0 );
 }
 );
#else

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageFractalFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform lowp float iGlobalTime;
 
 uniform lowp vec3 iResolution;
 
 void main()
 {
     mediump vec2 p = -1.0 + 2.0 * gl_FragCoord.xy / iResolution.xy;
     p.x *= iResolution.x/iResolution.y;
     
     // animation
     mediump float tz = 0.5 - 0.5*cos(0.225*iGlobalTime);
     mediump float zoo = pow( 0.5, 13.0*tz );
     mediump vec2 c = vec2(-0.05,.6805) + p*zoo;
     
     // iterate
     mediump vec2 z  = vec2(0.0);
     mediump float m2 = 0.0;
     mediump vec2 dz = vec2(0.0);
     for( int i=0; i<256; i++ )
     {
         if( m2>1024.0 ) continue;
         
         // Z' -> 2·Z·Z' + 1
         dz = 2.0*vec2(z.x*dz.x-z.y*dz.y, z.x*dz.y + z.y*dz.x) + vec2(1.0,0.0);
         
         // Z -> Z² + c
         z = vec2( z.x*z.x - z.y*z.y, 2.0*z.x*z.y ) + c;
         
         m2 = dot(z,z);
     }
     
     // distance
     // d(c) = |Z|·log|Z|/|Z'|
     mediump float d = 0.5*sqrt(dot(z,z)/dot(dz,dz))*log(dot(z,z));
     
     
     // do some soft coloring based on distance
     d = clamp( 8.0*d/zoo, 0.0, 1.0 );
     d = pow( d, 0.25 );
     mediump vec3 col = vec3( d );
     
     gl_FragColor = vec4( col, 1.0 );
 }
 );
#else

NSString *const kGPUImageFractalFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform mediump float iGlobalTime;
 
 uniform highp vec3 iResolution;
 
 void main()
 {
     mediump vec2 p = -1.0 + 2.0 * gl_FragCoord.xy / iResolution.xy;
     p.x *= iResolution.x/iResolution.y;
     
     // animation
     mediump float tz = 0.5 - 0.5*cos(0.225*iGlobalTime);
     mediump float zoo = pow( 0.5, 13.0*tz );
     mediump vec2 c = vec2(-0.05,.6805) + p*zoo;
     
     // iterate
     mediump vec2 z  = vec2(0.0);
     mediump float m2 = 0.0;
     mediump vec2 dz = vec2(0.0);
     for( int i=0; i<256; i++ )
     {
         if( m2>1024.0 ) continue;
         
         // Z' -> 2·Z·Z' + 1
         dz = 2.0*vec2(z.x*dz.x-z.y*dz.y, z.x*dz.y + z.y*dz.x) + vec2(1.0,0.0);
         
         // Z -> Z² + c
         z = vec2( z.x*z.x - z.y*z.y, 2.0*z.x*z.y ) + c;
         
         m2 = dot(z,z);
     }
     
     // distance
     // d(c) = |Z|·log|Z|/|Z'|
     mediump float d = 0.5*sqrt(dot(z,z)/dot(dz,dz))*log(dot(z,z));
     
     
     // do some soft coloring based on distance
     d = clamp( 8.0*d/zoo, 0.0, 1.0 );
     d = pow( d, 0.25 );
     mediump vec3 col = vec3( d );
     
     gl_FragColor = vec4( col, 1.0 );
 }
 );
#endif
*/
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageFractalFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform lowp float iGlobalTime;
 
 uniform lowp vec3 iResolution;
 
 void main()
 {
     mediump vec2 p = -1.0 + 2.0 * gl_FragCoord.xy / iResolution.xy;
     p.x *= iResolution.x/iResolution.y;
     
     // animation
     mediump float tz = 0.5 - 0.5*cos(0.225*iGlobalTime);
     mediump float zoo = pow( 0.5, 13.0*tz );
     mediump vec2 c = vec2(-0.05,.6805) + p*zoo;
     
     // iterate
     mediump vec2 z  = vec2(0.0);
     mediump float m2 = 0.0;
     mediump vec2 dz = vec2(0.0);
     for( int i=0; i<256; i++ )
     {
         if( m2>1024.0 ) continue;
         
         // Z' -> 2·Z·Z' + 1
         dz = 2.0*vec2(z.x*dz.x-z.y*dz.y, z.x*dz.y + z.y*dz.x) + vec2(1.0,0.0);
         
         // Z -> Z² + c
         z = vec2( z.x*z.x - z.y*z.y, 2.0*z.x*z.y ) + c;
         
         m2 = dot(z,z);
     }
     
     // distance
     // d(c) = |Z|·log|Z|/|Z'|
     mediump float d = 0.5*sqrt(dot(z,z)/dot(dz,dz))*log(dot(z,z));
     
     
     // do some soft coloring based on distance
     d = clamp( 8.0*d/zoo, 0.0, 1.0 );
     d = pow( d, 0.25 );
     mediump vec3 col = vec3( d );
     
     gl_FragColor = vec4( col, 1.0 );
 }
 );
#else

NSString *const kGPUImageFractalFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform mediump float iGlobalTime;
 
 uniform highp vec3 iResolution;
 
 void main()
 {
     mediump vec2 p = -1.0 + 2.0 * gl_FragCoord.xy / iResolution.xy;
     p.x *= iResolution.x/iResolution.y;
     
     // animation
     mediump float tz = 0.5 - 0.5*cos(0.225*iGlobalTime);
     mediump float zoo = pow( 0.5, 13.0*tz );
     mediump vec2 c = vec2(-0.05,.6805) + p*zoo;
     
     // iterate
     mediump vec2 z  = vec2(0.0);
     mediump float m2 = 0.0;
     mediump vec2 dz = vec2(0.0);
     for( int i=0; i<256; i++ )
     {
         if( m2>1024.0 ) continue;
         
         // Z' -> 2·Z·Z' + 1
         dz = 2.0*vec2(z.x*dz.x-z.y*dz.y, z.x*dz.y + z.y*dz.x) + vec2(1.0,0.0);
         
         // Z -> Z² + c
         z = vec2( z.x*z.x - z.y*z.y, 2.0*z.x*z.y ) + c;
         
         m2 = dot(z,z);
     }
     
     // distance
     // d(c) = |Z|·log|Z|/|Z'|
     mediump float d = 0.5*sqrt(dot(z,z)/dot(dz,dz))*log(dot(z,z));
     
     
     // do some soft coloring based on distance
     d = clamp( 8.0*d/zoo, 0.0, 1.0 );
     d = pow( d, 0.25 );
     mediump vec3 col = vec3( d );
     
     gl_FragColor = vec4( col, 1.0 );
 }
 );
#endif

@interface BSDFractalFilter (){

}

@end

@implementation BSDFractalFilter

- (id)init;
{
    if (!(self = [self initWithFragmentShaderFromString:kGPUImageFractalFragmentShaderString]))
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
    
    iGlobalTimeUniform = [filterProgram uniformIndex:@"iGlobalTime"];
    iResolutionUniform = [filterProgram uniformIndex:@"iResolution"];
    self.iGlobalTime = 0.0;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.iResolution = CGSizeMake(screenSize.width * 2.0, screenSize.height * 2.0);
    
    return self;
}

- (void)setIGlobalTime:(CGFloat)iGlobalTime
{
    _iGlobalTime = iGlobalTime;
    [self setFloat:iGlobalTime forUniform:iGlobalTimeUniform program:filterProgram];
}

- (void)setIResolution:(CGSize)iResolution
{
    _iResolution = iResolution;
    
    GPUVector3 vec;
    vec.one = _iResolution.width;
    vec.two = _iResolution.height;
    vec.three = 1.0;
    
    [self setVec3:vec forUniform:iResolutionUniform program:filterProgram];
}

- (void)incrementTimer
{
    if (!self.startDate) {
        return;
    }
    NSDate *now = [NSDate date];
    NSTimeInterval elapsed = [now timeIntervalSinceDate:self.startDate];
    self.iGlobalTime = elapsed;
}


@end
