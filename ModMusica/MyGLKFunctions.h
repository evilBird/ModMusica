//
//  MyGLKFunctions.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/24/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#ifndef ModMusica_MyGLKFunctions_h
#define ModMusica_MyGLKFunctions_h
#import "MyGLKDefs.h"

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
    
    for (int i = 0; i<numCols; i++) {
        
        for (int j = 0; j<numRows; j++) {
            
            anchorIdx = ((i * x) + j);
            
            vertexIdx = anchorIdx + 1;
            indices[meshIdx] = (GLuint)vertexIdx;
            meshIdx++;
            
            vertexIdx = anchorIdx;
            indices[meshIdx] = (GLuint)vertexIdx;
            meshIdx++;
            
            vertexIdx = anchorIdx + x;
            indices[meshIdx] = (GLuint)vertexIdx;
            meshIdx++;
            
            vertexIdx = anchorIdx + x;
            indices[meshIdx] = (GLuint)vertexIdx;
            meshIdx++;
            
            vertexIdx = anchorIdx + x + 1;
            indices[meshIdx] = (GLuint)vertexIdx;
            meshIdx++;
            
            vertexIdx = anchorIdx + 1;
            indices[meshIdx] = (GLuint)vertexIdx;
            meshIdx++;
        }
    }
}

void get_samples(NSArray *tables, float samples[], int samplesPerTable, int wrap)
{
    [PdBase sendBangToReceiver:kUpdateScopes];
    
    for (int i = 0; i < tables.count; i++) {
        NSString *table = tables[i];
        int tableSize = [PdBase arraySizeForArrayNamed:table];
        float *temp = malloc(sizeof(float)*tableSize);
        [PdBase copyArrayNamed:table withOffset:0 toArray:temp count:tableSize];
        float stepSize = (float)tableSize/(float)(samplesPerTable - 1);
        int sampleIdx = 0;
        for (int j = 0; j < samplesPerTable; j++) {
            int tableIdx = (j * stepSize);
            float sample = temp[tableIdx];
            if (sample!=sample) {
                sample = 0.0;
            }
            if (sample < -1.0) {
                sample = -1.0;
            }
            
            if (sample > 1.0) {
                sample = 1.0;
            }
            
            sampleIdx = ((i * samplesPerTable) + j);
            samples[sampleIdx] = sample * SAMPLE_SCALAR;
        }
        if (wrap) {
            samples[(i * samplesPerTable)] = samples[sampleIdx];
        }
        
        free(temp);
    }
}

void update_vertices(Vertex vertices[], float samples[], int numTables, int samplesPerTable, int verticesPerSample)
{
#if DEBUG_GL
    NSLog(@"\n*****************************************\n");
#endif
    int numCols = numTables * verticesPerSample;
    int numSamples = numTables * samplesPerTable;
    for (int i = 0; i < numCols; i++) {
        int myIdx = i/verticesPerSample;
        
        for (int j = 0; j < samplesPerTable; j++) {
            int sampleIdx = myIdx * samplesPerTable + j;
            int vertexIdx = i * samplesPerTable + j;

            double sample = (double)samples[sampleIdx];
            int neighborIdx = 0;
            if ((sampleIdx + samplesPerTable)<numSamples) {
                neighborIdx = sampleIdx + samplesPerTable;
            }else{
                neighborIdx = sampleIdx - samplesPerTable;
            }
            
            double neighbor = (double)samples[neighborIdx];
            double neighbor_wt = (double)(i%verticesPerSample)/(double)verticesPerSample;
            double weightedSample = (sample * (1.0 - neighbor_wt) + neighbor * neighbor_wt);
            
            double rads = (double)((double)j * ((2.0 * M_PI)/(double)(samplesPerTable - 1)));
            double x = cos(rads) + cos(rads) * fabs(weightedSample);
            double z = sin(rads) + sin(rads) * fabs(weightedSample);
            
            double color = (double)i/(double)(numCols - 1.0);
            double y = color * 2.0 - 1.0;
            
            GLfloat normalizedSample = (GLfloat)((weightedSample * 2.0) + 1.0);

            Vertex vertex;
            vertex.Position[0] = (GLfloat)x;
            vertex.Position[1] = (GLfloat)y;
            vertex.Position[2] = (GLfloat)z;
            vertex.Color[0] = (GLfloat)(color * normalizedSample);
            vertex.Color[1] = (GLfloat)normalizedSample;
            vertex.Color[2] = (GLfloat)((1.0 - color) * normalizedSample);
            vertex.Color[3] = 1.0;
            vertices[vertexIdx] = vertex;
#if DEBUG_GL
            NSLog(@"\ni = %d, j = %d, vertexIdx = %d, sampleIdx = %d, sample = %.2f, neighborIdx = %d, neighbor = %.2f, neighbor wt = %.2f, weighted sample = %.2f, x = %.2f, y = %.2f, z = %.2f",i,j,vertexIdx,sampleIdx,sample,neighborIdx,neighbor,neighbor_wt,weightedSample,x,y,z);
#endif
        }
    }
#if DEBUG_GL
    NSLog(@"\n++++++++++++++++++++++++++++++++\n\n");
#endif
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
