//
//  MyGLKMathFunctions.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/26/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#ifndef ModMusica_MyGLKMathFunctions_h
#define ModMusica_MyGLKMathFunctions_h
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

GLfloat _wrapFloat(GLfloat myFloat, GLfloat min, GLfloat max)
{
    if (myFloat > max) {
        return max;
    }else if (myFloat < min){
        return min;
    }
    return myFloat;
}

GLfloat _clampFloat(GLfloat myFloat, GLfloat min, GLfloat max)
{
    if (myFloat > max) {
        return max;
    }else if (myFloat < min){
        return min;
    }
    return myFloat;
}

GLfloat _jitterFloat(GLfloat myFloat, GLfloat jitter, GLfloat min, GLfloat max)
{
    u_int32_t base;
    double direction;
    if (arc4random_uniform(2)) {
        base = (u_int32_t)(((myFloat - min) * jitter) * 1000.0);
        direction = -1.0;
    }else{
        base = (u_int32_t)(((max - myFloat) * jitter) * 1000.0);
        direction = 1.0;
    }
    
    GLfloat diff = (GLfloat)((arc4random_uniform(base)) * 0.001 * direction);
    myFloat+=diff;
    
    return myFloat;
}

void _randomRGB(GLfloat rgb[], int n)
{
    for (int i = 0; i < (n*3); i ++) {
        rgb[i] = (GLfloat)(arc4random_uniform(1000) * 0.001);
    }
}

#endif
