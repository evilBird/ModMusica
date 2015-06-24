//
//  MyGLKFunctions.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/24/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#ifndef ModMusica_MyGLKFunctions_h
#define ModMusica_MyGLKFunctions_h
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "MyGLKDefs.h"
#import "PdBase.h"

void make_mesh_indices(GLuint indices[], int x, int y)
{
    if (x < 2|| y < 2) {
        return;
    }
    
    int numRows = (x - 1);
    int numCols = (y - 1);
    int meshIdx = 0;
    int vertexIdx = 0;
    
    for (int i = 0; i<numCols; i++) {
        
        for (int j = 0; j<numRows; j++) {
            
            vertexIdx = ((i * x) + j);

            indices[meshIdx] = (GLuint)vertexIdx;
            meshIdx++;
            vertexIdx++;
            indices[meshIdx] = (GLuint)vertexIdx;
            meshIdx++;
            vertexIdx+=x;
            indices[meshIdx] = (GLuint)vertexIdx;
            meshIdx++;
            
            vertexIdx = ((i * x) + j);
            
            indices[meshIdx] = (GLuint)vertexIdx;
            meshIdx++;
            vertexIdx+=(x + 1);
            indices[meshIdx] = (GLuint)vertexIdx;
            meshIdx++;
            vertexIdx--;
            indices[meshIdx] = (GLuint)vertexIdx;
            meshIdx++;
        }
    }
}

void get_samples(NSArray *tables, float samples[], int samplesPerTable)
{
    [PdBase sendBangToReceiver:@"updateScopes"];
    
    for (int i = 0; i < tables.count; i++) {
        NSString *table = tables[i];
        int tableSize = [PdBase arraySizeForArrayNamed:table];
        float *temp = malloc(sizeof(float)*tableSize);
        [PdBase copyArrayNamed:table withOffset:0 toArray:temp count:tableSize];
        float stepSize = (float)tableSize/(float)(samplesPerTable - 1);
        for (int j = 0; j < tableSize; j++) {
            int tableIdx = round((double)(j * stepSize));
            float sample = temp[tableIdx];
            if (sample!=sample) {
                sample = 0.0;
            }
            int sampleIdx = ((i * samplesPerTable) + j);
            samples[sampleIdx] = sample;
        }
        
        free(temp);
    }
}

void update_vertices_with_samples(Vertex vertices[],float samples[],int numVertices, int numSamples)
{
    int verticesPerSample = numVertices/numSamples;
    
    for (int i = 0; i < numVertices; i ++) {
        
        int sampleIdx = i/verticesPerSample;
        int tableIdx = i/numSamples;
        
        float sample = samples[sampleIdx];
        
        GLfloat samp = (GLfloat)sample;
        if (samp!=samp) {
            samp = 0.0;
        }
        GLfloat normSample = (GLfloat)((samp + 1.0)/2.0);
        
        double rads = (GLfloat)((float)sampleIdx * ((2.0 * M_PI)/(float)(numSamples-1)));
        
        GLfloat x = cos(rads) + cos(rads) * fabs(sample);
        GLfloat y = (GLfloat)(((float)tableIdx/(float)(verticesPerSample - 1.0) * 2.0) - 1.0);
        GLfloat z = sin(rads) + sin(rads) * fabs(sample);
        
        vertices[i].Position[0] = x;
        vertices[i].Position[1] = y;
        vertices[i].Position[2] = z;
        vertices[i].Color[0] = normSample;
        vertices[i].Color[1] = normSample;
        vertices[i].Color[2] = normSample;
        vertices[i].Color[3] = 1.0;
    }
}

GLfloat wrap_float(GLfloat myFloat, GLfloat min, GLfloat max)
{
    if (myFloat > max) {
        return max;
    }else if (myFloat < min){
        return min;
    }
    return myFloat;
}

GLfloat clamp_float(GLfloat myFloat, GLfloat min, GLfloat max)
{
    if (myFloat > max) {
        return max;
    }else if (myFloat < min){
        return min;
    }
    return myFloat;
}

GLfloat jitter_float(GLfloat myFloat, GLfloat percent)
{
    GLfloat jit = (GLfloat)((arc4random_uniform(200) - 100) * percent * 0.01);
    return clamp_float((myFloat + jit),0.0,1.0);
}

void jitter_rgb(GLfloat rgb[], GLfloat result[], GLfloat jitter, int table)
{
    int tableIndex = table * 3;
    for (int i = 0; i<3; i++) {
        int idx = (tableIndex + i);
        GLfloat component = rgb[idx];
        result[i] = jitter_float(component, jitter);
    }
}

void random_rgb(GLfloat rgb[], int n)
{
    for (int i = 0; i < (n*3); i ++) {
        rgb[i] = (GLfloat)(arc4random_uniform(1000) * 0.001);
    }
}

#endif
