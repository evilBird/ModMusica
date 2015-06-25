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
    int anchorIdx = 0;
    int vertexIdx = 0;
    
    for (int i = 0; i<numRows; i++) {
        
        for (int j = 0; j<numCols; j++) {
            
            anchorIdx = ((j * x) + i);
            
            vertexIdx = anchorIdx;
            
            indices[meshIdx] = (GLuint)vertexIdx;
            meshIdx++;
            //vertexIdx++;
            vertexIdx = anchorIdx + 1;
            
            indices[meshIdx] = (GLuint)vertexIdx;
            meshIdx++;
            //vertexIdx+=x;
            vertexIdx = anchorIdx + x;
            indices[meshIdx] = (GLuint)vertexIdx;
            meshIdx++;
            /*
            vertexIdx = anchorIdx + 1;
            
            indices[meshIdx] = (GLuint)vertexIdx;
            meshIdx++;
            //vertexIdx+=(x + 1);
            vertexIdx = anchorIdx + x + 1;
            indices[meshIdx] = (GLuint)vertexIdx;
            meshIdx++;
            //vertexIdx--;
            vertexIdx = anchorIdx + x;
            indices[meshIdx] = (GLuint)vertexIdx;
            meshIdx++;
             */
        }
        
        for (int j = 0; j<numCols; j++) {
            int idx = (numCols - 1 - j);
            indices[meshIdx] = (GLuint)((idx * x) + (i + 1));
            meshIdx++;
            indices[meshIdx] = (GLuint)(((idx + 1) * x) + (i + 1));
            meshIdx++;
            indices[meshIdx] = (GLuint)(((idx + 1) * x) + i);
            meshIdx++;
        }

    }
}

void get_samples(NSArray *tables, float samples[], int samplesPerTable, int wrap)
{
    [PdBase sendBangToReceiver:@"updateScopes"];
    
    for (int i = 0; i < tables.count; i++) {
        NSString *table = tables[i];
        int tableSize = [PdBase arraySizeForArrayNamed:table];
        float *temp = malloc(sizeof(float)*tableSize);
        [PdBase copyArrayNamed:table withOffset:0 toArray:temp count:tableSize];
        float stepSize = (float)tableSize/(float)(samplesPerTable - 1);
        int sampleIdx = 0;
        for (int j = 0; j < samplesPerTable; j++) {
            int tableIdx = round((double)(j * stepSize));
            float sample = temp[tableIdx];
            if (sample!=sample) {
                sample = 0.0;
            }
            sampleIdx = ((i * samplesPerTable) + j);
            samples[sampleIdx] = sample;
        }
        if (wrap) {
            samples[(i * samplesPerTable)] = samples[sampleIdx];
        }
        
        free(temp);
    }
}

void update_vertices_with_samples(Vertex vertices[],float samples[], int numSamples, int numTables, int numVertices)
{
    int verticesPerSample = numVertices/numSamples;
    int samplesPerTable = numSamples/numTables;
    int verticesPerTable = numVertices/numTables;
    
    for (int i = 0; i < numVertices; i ++) {
        
        int sampleArrayIndex = i/verticesPerSample;
        int sampleTableIndex = sampleArrayIndex%samplesPerTable;
        int tableIdx = i/(samplesPerTable * verticesPerSample);
        int vertexIdx = i/samplesPerTable;
        float sample = samples[sampleArrayIndex];
        double distance = (double)vertexIdx/(double)(verticesPerTable);
        double w1 = 1.0 - distance;
        double w2 = distance;
        
        if (samplesPerTable > 1){
            
            sample = samples[sampleArrayIndex];
            int neighborIdx;
            if (tableIdx < (numTables - 1)) {
                neighborIdx = sampleArrayIndex + samplesPerTable;
            }else{
                neighborIdx = sampleArrayIndex - samplesPerTable;
            }
            
            float neighbor = samples[neighborIdx];
            sample = (sample * w1 + neighbor * w2);
            
        }
        
        GLfloat samp = (GLfloat)sample;
        if (samp!=samp) {
            samp = 0.0;
        }
        
        GLfloat normSample = (GLfloat)((samp + 1.0)/2.0);
        
        double rads = (GLfloat)((float)sampleTableIndex * ((2.0 * M_PI)/(float)(samplesPerTable - 1)));
        
        GLfloat x = cos(rads) + cos(rads) * fabs(sample);
        
        GLfloat y = (GLfloat)((float)vertexIdx/(float)(numTables * verticesPerTable) * 2.0 - 1.0);
        //GLfloat y = (GLfloat)(((float)(tableIdx + w2)/(float)(numTables - 1.0) * 2.0) - 1.0);
        
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
