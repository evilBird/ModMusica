//
//  MyGLKDefs.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/24/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#ifndef ModMusica_MyGLKDefs_h
#define ModMusica_MyGLKDefs_h

typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

typedef NS_ENUM(int, MyGLKWindingDirection)
{
    MyGLKWindingDirection_CCW = 0,
    MyGLKWindingDirection_CW = 1
};

#endif
