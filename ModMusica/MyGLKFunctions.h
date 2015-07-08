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

void reverse_vertices(Vertex vertices[], int count) {
    Vertex buffer[count];
    int maxCount = count - 1;
    for (int i = 0; i < count; i++) {
        
        if (i < count/2) {
            buffer[i] = vertices[i];
            vertices[i] = vertices[maxCount - i];
        }else{
            vertices[i] = buffer[(i - count/2)];
        }

    }
}

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

void _randomRGBInRange(GLfloat rgb[], GLfloat min, GLfloat max,int n)
{
    GLfloat range = max - min;
    uint32_t upperBound = (uint32_t)(range * 1000);
    
    for (int i = 0; i < (n*3); i ++) {
        GLfloat random = (GLfloat)(arc4random_uniform(upperBound));
        
        rgb[i] = (GLfloat)(random * 0.001);
    }
}

void _makeMeshIndices(GLuint indices[], int x, int y)
{
    if (x < 2|| y < 2) {
        return;
    }
    
    int numRows = (x - 1);
    int numCols = (y - 1);
    int meshIdx = 0;
    int anchorIdx = 0;
    int vertexIdx = 0;
    
    for (int i = 0; i<y; i++) {
        
        for (int j = 0; j<numRows; j++) {
            
            anchorIdx = ((i%numCols * x) + j);
            
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

void _getSamples(NSArray *tables, float samples[], int samplesPerTable, int wrap)
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

Vertex _newVertex()
{
    Vertex vertex;
    vertex.Position[0] = 0.0;
    vertex.Position[1] = 0.0;
    vertex.Position[2] = 0.0;
    vertex.Normal[0] = 0.0;
    vertex.Normal[1] = 0.0;
    vertex.Normal[2] = 0.0;
    vertex.Color[0] = 0.0;
    vertex.Color[1] = 0.0;
    vertex.Color[2] = 0.0;
    vertex.Color[3] = 1.0;
    vertex.TexCoord[0] = 0.0;
    vertex.TexCoord[1] = 0.0;
    
    for (int i = 0; i < 12; i ++) {
        vertex.Neighbors[i] = 0;
    }
    vertex.numNeighbors = 0;
    
    return vertex;
}

void _initVertices(Vertex vertices[], int numVertices)
{
    for (int i = 0; i < numVertices; i ++) {
        vertices[i] = _newVertex();
    }
}

void _assignVertexNeighbors(Vertex vertices[],GLuint indices[],int numIndices)
{
    int numTriangles = numIndices/3;
    
    for (int i = 0; i<numTriangles;i++) {
        
        int outerIdx = (i * 3);
        
        for (int j = 0; j < 3; j++) {
            int innerIdx = outerIdx + j;
            GLuint vertexIdx = indices[innerIdx];
            int numNeighbors = vertices[vertexIdx].numNeighbors;
            int neighbor1,neighbor2;
            GLuint n1,n2;
            switch (j) {
                case 0:
                    neighbor1 = innerIdx+1;
                    neighbor2 = innerIdx+2;
                    break;
                case 1:
                    neighbor1 = innerIdx-1;
                    neighbor2 = innerIdx+1;
                    break;
                case 2:
                    neighbor1 = innerIdx-2;
                    neighbor2 = innerIdx-1;
                    break;
                default:
                    break;
            }
            
            n1 = indices[neighbor1];
            n2 = indices[neighbor2];
            
            vertices[vertexIdx].Neighbors[numNeighbors] = n1;
            numNeighbors++;
            vertices[vertexIdx].Neighbors[numNeighbors] = n2;
            numNeighbors++;
            
            vertices[vertexIdx].numNeighbors = numNeighbors;
        }
    }
}

void _vert2pos(Vertex vertex,GLfloat result[])
{
    result[0] = vertex.Position[0];
    result[1] = vertex.Position[1];
    result[2] = vertex.Position[2];
}

void _subtractPos(GLfloat pos1[], GLfloat pos2[], GLfloat result[])
{
    result[0] = pos1[0] - pos2[0];
    result[1] = pos1[1] - pos2[1];
    result[2] = pos2[2] - pos2[2];
}

void _calculateNormal(Vertex vertex1, Vertex vertex2, Vertex vertex3, GLfloat result[])
{
    GLfloat p1[3],p2[3],p3[3];
    _vert2pos(vertex1, p1);
    _vert2pos(vertex2, p2);
    _vert2pos(vertex3, p3);
    
    GLfloat v1[3],v2[3];
    _subtractPos(p2, p1, v1);
    _subtractPos(p3, p1, v2);
    
    result[0] = v1[1] * v2[2] - v1[2] * v2[1];
    result[1] = v1[1] * v2[1] - v1[0] * v2[2];
    result[2] = v1[0] * v2[1] - v1[1] * v2[0];
    
    //result[0]/=1.0;
    //result[1]/=1.0;
    //result[2]/=1.0;
}


void _calculateNormalAtIndex(Vertex vertices[],int idx)
{
    Vertex vertex1,vertex2,vertex3;
    GLuint index = (GLuint)idx;
    vertex1 = vertices[index];
    if (vertex1.numNeighbors < 2 || vertex1.numNeighbors > 12) {
        vertex1.numNeighbors = 0;
        return;
    }
    
    GLfloat normalSum[3] = {0,0,0};
    
    int numTriangles = vertex1.numNeighbors/2;
    
    for (int i = 0; i < numTriangles; i++) {
        GLuint neighborIdx = (GLuint)(i*2);
        vertex2 = vertices[vertex1.Neighbors[neighborIdx]];
        neighborIdx++;
        vertex3 = vertices[vertex1.Neighbors[neighborIdx]];
        GLfloat currentNormal[3];
        _calculateNormal(vertex1, vertex2, vertex3, currentNormal);
        normalSum[0]+=currentNormal[0];
        normalSum[1]+=currentNormal[1];
        normalSum[2]+=currentNormal[2];
    }
    
    vertex1.Normal[0] = normalSum[0]/(float)(numTriangles);
    vertex1.Normal[1] = normalSum[1]/(float)(numTriangles);
    vertex1.Normal[2] = normalSum[2]/(float)(numTriangles);
}

void _updateVertexNormals(Vertex vertices[],int numVertices)
{
    for (int i = 0; i < numVertices; i++) {
        _calculateNormalAtIndex(vertices, i);
    }
}

static int calls = 0;
static BOOL newCols = NO;
GLfloat cols[3];

void _setMainVertexColor(GLfloat color[])
{
    cols[0] = color[0];
    cols[1] = color[1];
    cols[2] = color[2];
    calls = 0;
}

void _updateVertices(Vertex vertices[], float samples[], int numTables, int samplesPerTable, int verticesPerSample)
{
#if DEBUG_GL
    NSLog(@"\n*****************************************\n");
#endif
    int numCols = numTables * verticesPerSample;
    int numSamples = numTables * samplesPerTable;
    
    if ((calls%2400) == 0) {
        newCols = YES;
    }
    calls++;

    for (int i = 0; i < numCols; i++) {
        
        int myIdx = i/verticesPerSample;
        GLfloat myCols[3];
        if (newCols) {
            myCols[0] = _jitterFloat(cols[0],0.2,0.0,1.0);
            myCols[1] = _jitterFloat(cols[1],0.2,0.0,1.0);
            myCols[2] = _jitterFloat(cols[2],0.2,0.0,1.0);
        }
        
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
            double x = cos(rads) + cos(rads) * weightedSample * -1.0;//fabs(weightedSample);
            double y = (double)i/(double)(numCols - 1.0) * 2.0 - 1.0;
            double z = sin(rads) + sin(rads) * weightedSample * -1.0;//fabs(weightedSample);
            
            GLfloat normalizedSample = (GLfloat)((weightedSample * 2.0) + 1.0) * 0.8 + 0.1;

            vertices[vertexIdx].Position[0] = (GLfloat)(x * DRAWING_SCALE_X);
            vertices[vertexIdx].Position[1] = (GLfloat)(y * DRAWING_SCALE_Y);
            vertices[vertexIdx].Position[2] = (GLfloat)(z * DRAWING_SCALE_Z);

            if (newCols) {
                vertices[vertexIdx].Color[0] = (GLfloat)(normalizedSample * myCols[0]);
                vertices[vertexIdx].Color[1] = (GLfloat)(normalizedSample * myCols[1]);
                vertices[vertexIdx].Color[2] = (GLfloat)(normalizedSample * myCols[2]);
                vertices[vertexIdx].Color[3] = 1.0;
            }


            
#if USE_NORMALS
            
            double dir = 1.0;
            if (weightedSample < 0) {
                dir = -1.0;
            }
            
            vertices[vertexIdx].Normal[0] = cos(rads) + cos(rads) * vertices[vertexIdx].Normal[0];
            vertices[vertexIdx].Normal[1] = cos(rads) + cos(rads) * vertices[vertexIdx].Normal[1];
            vertices[vertexIdx].Normal[2] = sin(rads) + sin(rads) * vertices[vertexIdx].Normal[2];
#endif
            
#if DEBUG_GL
            NSLog(@"\ni = %d, j = %d, vertexIdx = %d, sampleIdx = %d, sample = %.2f, neighborIdx = %d, neighbor = %.2f, neighbor wt = %.2f, weighted sample = %.2f, x = %.2f, y = %.2f, z = %.2f",i,j,vertexIdx,sampleIdx,sample,neighborIdx,neighbor,neighbor_wt,weightedSample,x,y,z);
#endif
        }
    }
    
    //reverse_vertices(vertices, numVertices);
    
    
#if DEBUG_GL
    NSLog(@"\n++++++++++++++++++++++++++++++++\n\n");
#endif
}


#endif
