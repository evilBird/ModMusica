//
//  MyGLKDefs.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/24/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#ifndef ModMusica_MyGLKDefs_h
#define ModMusica_MyGLKDefs_h

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "PdBase.h"

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

#define SAMPLE_RATE                 44100
#define BLOCK_SIZE                  64
#define TICKS                       64

#define SAMPLES_PER_TABLE           100
#define VERTICES_PER_SAMPLE         100
#define NUM_TABLES                  8

#define SAMPLE_SCALAR               0.9
#define SAMPLE_UPDATES_PER_SEC      10.0

#define MIN_SCALE                   0.1
#define MAX_SCALE                   20.0
#define D_SCALE                     0.5

#define MIN_ZOOM                   -8.0
#define MAX_ZOOM                    0.1
#define D_ZOOM                      0.1

#define INIT_ROTATION_X            -90.0

#define INIT_ROTATION_Y              0.0
#define D_ROTATION_Y                10.0

#define DEBUG_GL 0

static NSString *kTableName = @"scopeArray";
static NSString *kBassTable = @"bassScope";
static NSString *kSynthTable = @"synthScope";
static NSString *kDrumTable = @"drumScope";
static NSString *kSamplerTable = @"samplerScope";
static NSString *kKickTable = @"kickScope";
static NSString *kSnareTable = @"snareScope";
static NSString *kPercTable = @"percScope";
static NSString *kSynthTable1 = @"synthScope1";
static NSString *kSynthTable2 = @"synthScope2";
static NSString *kSynthTable3 = @"synthScope3";
static NSString *kFuzzTable = @"fuzzScope";
static NSString *kTremeloTable = @"tremeloScope";
static NSString *kInputTable = @"inputScope";
static NSString *kRawInputTable = @"rawInputTable";
static NSString *kUpdateScopes = @"updateScopes";

typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

typedef struct {
    char *Name;
    GLint Location;
}Uniform;


#endif
