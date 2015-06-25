//
//  MyGLKDefs.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/24/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#ifndef ModMusica_MyGLKDefs_h
#define ModMusica_MyGLKDefs_h

#define SAMPLES_PER_TABLE 100
#define NUM_TABLES 4
#define VERTICES_PER_SAMPLE 2
#define SAMPLE_RATE 44100
#define BLOCK_SIZE 64
#define TICKS 64
#define TABLE_SIZE 2048
#define SCALE_COEFF 0.05
#define SCALE_MIN 0.1
#define SCALE_MAX 10.0
#define ZOOM_INIT -3.5
#define DEBUG_GL 0
#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

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
