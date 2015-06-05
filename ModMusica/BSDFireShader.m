//
//  BSDFireShader.m
//  ModMusica
//
//  Created by Travis Henspeter on 12/6/14.
//  Copyright (c) 2014 birdSound. All rights reserved.
//

#import "BSDFireShader.h"

NSString *const kGPUImageFireShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 uniform highp float globalTime;
 uniform highp vec3 resolution;
 
 highp float triangle(highp float t){
     return (fract(t)-.5) * sign(fract(t / 2.0)-.5);
 }
 
 highp vec3 grad(highp float t){
     highp vec3 p1 = max(vec3(0), (t-.5)*2.0*vec3(0, 1.2, 1));
     highp vec3 p2 = max(vec3(0), (t+.2)*1.3*vec3(.8, .2, 0));
     
     return p1+p2;
 }
 
 highp vec2 warp(highp vec2 uv){
     uv.x += (sin(uv.x/10.0-globalTime*10.0 + uv.y*10.0 * (sin(uv.x*20.0 + globalTime*.5)*.3+1.0))+1.0)*.03;
     return uv;
 }

 void main(void)
{
    highp vec2 uv = warp(textureCoordinate.xy / resolution.xy);
    highp float t = uv.x * 10.0;
    highp float Tt = triangle(t);
    highp float v  = -((uv.y-.8)*2.0 - (Tt * Tt)*sin(t+sin(globalTime)*-2.0))* ((sin(t*5.0+globalTime)+1.0) * .2 + .8);
    gl_FragColor = vec4(grad(v*.8), 0.1);
}
);

NSString *const kGPUImageFractalShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform mediump float globalTime;
 
 uniform mediump vec3 resolution;
 
 void main()
 {
     mediump vec2 p = -1.0 + 2.0 * textureCoordinate.xy / resolution.xy;
     p.x *= resolution.x/resolution.y;
     
     //float zoo = 1.0/250.0;
     
     mediump float zoo = 1.0/250.0;
     
     zoo = 1.0/(400.0 - 150.0*sin(0.15*globalTime-0.3));
     
     mediump vec2 cc = vec2(-0.533516,0.526141) + p*zoo;
     
     mediump vec2 t2c = vec2(-0.5,2.0);
     t2c += 0.5*vec2( cos(0.13*(globalTime-10.0)), sin(0.13*(globalTime-10.0)) );
     
     // iterate
     mediump vec2 z  = vec2(0.0);
     mediump vec2 dz = vec2(0.0);
     mediump float trap1 = 0.0;
     mediump float trap2 = 1e20;
     mediump float co2 = 0.0;
     for( int i=0; i<150; i++ )
     {
         if( dot(z,z)>1024.0 ) continue;
         
         // Z' -> 2·Z·Z' + 1
         dz = 2.0*vec2(z.x*dz.x-z.y*dz.y, z.x*dz.y + z.y*dz.x ) + vec2(1.0,0.0);
         
         // Z -> Z² + c
         z = cc + vec2( z.x*z.x - z.y*z.y, 2.0*z.x*z.y );
         
         // trap 1
         mediump float d1 = abs(dot(z-vec2(0.0,1.0),vec2(0.707)));
         mediump float ff = step( d1, 1.0 );
         co2 += ff;
         trap1 += ff*d1;
         
         //trap2
         trap2 = min( trap2, dot(z-t2c,z-t2c) );
     }
     
     // distance, d(c) = |Z|·log|Z|/|Z'|
     mediump float d = sqrt( dot(z,z)/dot(dz,dz) )*log(dot(z,z));
     
     mediump float c1 = pow( clamp( 2.00*d/zoo,    0.0, 1.0 ), 0.5 );
     mediump float c2 = pow( clamp( 1.5*trap1/co2, 0.0, 1.0 ), 2.0 );
     mediump float c3 = pow( clamp( 0.4*trap2, 0.0, 1.0 ), 0.25 );
     
     mediump vec3 col1 = 0.5 + 0.5*sin( 3.0 + 4.0*c2 + vec3(0.0,0.5,1.0) );
     mediump vec3 col2 = 0.5 + 0.5*sin( 4.1 + 2.0*c3 + vec3(1.0,0.5,0.0) );
     mediump vec3 col = 2.0*sqrt(c1*col1*col2);
     
     gl_FragColor = vec4( col, 1.0 );
 }
 );

NSString *const kGPUImageSnowShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 uniform mediump float globalTime;
 uniform mediump vec3 resolution;

#define LIGHT_SNOW // Comment this out for a blizzard
 
#ifdef LIGHT_SNOW
#define LAYERS 50
#define DEPTH .5
#define WIDTH .3
#define SPEED .6
#else // BLIZZARD
#define LAYERS 200
#define DEPTH .1
#define WIDTH .8
#define SPEED 1.5
#endif
 
 void main(void)
{
    const mediump mat3 p = mat3(13.323122,23.5112,21.71123,21.1212,28.7312,11.9312,21.8112,14.7212,61.3934);
    mediump vec4 iMouse = vec4(1.0);
    mediump vec2 uv = iMouse.xy/resolution.xy + vec2(1.,resolution.y/resolution.x)*gl_FragColor.xy / resolution.xy;
    mediump vec3 acc = vec3(0.0);
    mediump float dof = 5.*sin(globalTime*.1);
    for (int i=0;i<LAYERS;i++) {
        mediump float fi = float(i);
        mediump vec2 q = uv*(1.+fi*DEPTH);
        q += vec2(q.y*(WIDTH*mod(fi*7.238917,1.)-WIDTH*.5),SPEED*globalTime/(1.+fi*DEPTH*.03));
        mediump vec3 n = vec3(floor(q),31.189+fi);
        mediump vec3 m = floor(n)*.00001 + fract(n);
        mediump vec3 mp = (31415.9+m)/fract(p*m);
        mediump vec3 r = fract(mp);
        mediump vec2 s = abs(mod(q,1.)-.5+.9*r.xy-.45);
        s += .01*abs(2.*fract(10.*q.yx)-1.);
        mediump float d = .6*max(s.x-s.y,s.x+s.y)+max(s.x,s.y)-.01;
        mediump float edge = .005+.05*min(.5*abs(fi-5.-dof),1.);
        acc += vec3(smoothstep(edge,-edge,d)*(r.x/(1.+.02*fi*DEPTH)));
    }
    gl_FragColor = vec4(vec3(acc),1.0);
}
);

@implementation BSDFireShader

- (id)init;
{
    if (!(self = [self initWithFragmentShaderFromString:kGPUImageFireShaderString]))
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
    
    globalTimeUniform = [filterProgram uniformIndex:@"globalTime"];
    resolutionUniform = [filterProgram uniformIndex:@"resolution"];
    self.globalTime = 0.0;
    
    GPUVector3 res;
    res.one = 1.;
    res.two = 1.;
    res.three = 1.;
    [self setVec3:res forUniform:resolutionUniform program:filterProgram];
    
    return self;
}

- (void)setGlobalTime:(CGFloat)globalTime
{
    _globalTime = globalTime;
    [self setFloat:_globalTime forUniform:globalTimeUniform program:filterProgram];
}

@end
