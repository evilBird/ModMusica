//
//  MyGLKViewController.m
//  GLKitStuff
//
//  Created by Travis Henspeter on 6/12/15.
//  Copyright (c) 2015 birdSound LLC. All rights reserved.
//

#import "MyGLKViewController.h"
#import "MMScopeDataSource.h"
#import "MMPlaybackController.h"
#import "MyGLKViewController+Labels.h"
#import "OpenGLHelper.h"

#define NUM_POINTS 100
#define NUM_TABLES 8
#define SAMPLE_RATE 44100
#define BLOCK_SIZE 64
#define TICKS 64
#define TABLE_SIZE 2048
#define SCALE_COEFF 0.05
#define SCALE_MIN 0.1
#define SCALE_MAX 10.0
#define ZOOM_INIT -3.5

typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

typedef struct
{
    char *Name;
    GLint Location;
}Uniform;

static NSString *const vertShader = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 varying highp vec2 textureCoordinate;
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );

static NSString *const fragShader = SHADER_STRING
(
 precision highp float;
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);
 void main()
 {
     float luminance = dot(texture2D(inputImageTexture, textureCoordinate).rgb, W);
     highp vec3 col = vec3(0.5,0.5,0.5);
     gl_FragColor = vec4(col, 1.0);
 }
 );

static GLfloat wrap_float(GLfloat myFloat)
{
    GLfloat result = 0.0;
    if (myFloat > 1.0) {
        result = (myFloat - 1.0);
    }else if (myFloat < 0.0){
        result = (1.0 - myFloat);
    }else{
        result = myFloat;
    }
    
    return myFloat;
}

static GLfloat clamp_float(GLfloat myFloat)
{
    if (myFloat > 1.0) {
        return 1.0;
    }else if (myFloat < 0.0){
        return 0.0;
    }
    return myFloat;
}

static GLfloat jitter_float(GLfloat myFloat, GLfloat percent)
{
    GLfloat jit = (GLfloat)((arc4random_uniform(200) - 100) * percent * 0.01);
    return clamp_float((myFloat + jit));
}

static void jitter_rgb(GLfloat rgb[], GLfloat result[], GLfloat jitter, int table)
{
    int tableIndex = table * 3;
    for (int i = 0; i<3; i++) {
        int idx = (tableIndex + i);
        GLfloat component = rgb[idx];
        result[i] = jitter_float(component, jitter);
    }
}

static void random_rgb(GLfloat rgb[], int n)
{
    for (int i = 0; i < (n*3); i ++) {
        rgb[i] = (GLfloat)(arc4random_uniform(1000) * 0.001);
    }
}

static void init_indices(GLuint indices[])
{
    int drawIndex = 0;
    int rows = (NUM_POINTS - 1);
    int cols = (NUM_TABLES - 1);
    
    for (int i = 0; i < rows; i++) {
        
        for (int j = 0; j < cols; j++) {
            
            indices[drawIndex] = (GLuint)((j * NUM_POINTS) + i);
            drawIndex++;
            indices[drawIndex] = (GLuint)((j * NUM_POINTS) + (i + 1));
            drawIndex++;
            indices[drawIndex] = (GLuint)(((j + 1) * NUM_POINTS) + i);
            drawIndex++;
        }
        
        for (int j = 0; j < cols; j++) {
            GLubyte idx = cols - 1 - j;
            indices[drawIndex] = (GLuint)(((idx + 1) * NUM_POINTS) + i);
            drawIndex++;
            indices[drawIndex] = (GLuint)(((idx + 1) * NUM_POINTS) + (i + 1));
            drawIndex++;
            indices[drawIndex] = (GLuint)((idx * NUM_POINTS) + (i + 1));
            drawIndex++;
        }
        
    }
}

@interface MyGLKViewController () <MMPlaybackDelegate>
{
    GLuint _verticesVBO;
    Vertex Vertices[(NUM_POINTS * NUM_TABLES)];
    NSArray *kTables;
    BOOL kUpdating;
    float _rotation;
    float _zoom;
    float _scale;
    GLuint Indices[(NUM_POINTS-1) * (NUM_TABLES - 1) * 6];
    GLuint _indicesVBO;
    GLfloat colors[((NUM_TABLES + 1) * 3)];
    int kClock;
    GLuint _program;
    Uniform* _uniformArray;
    int _uniformArraySize;
    GLuint _VAO;
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property (nonatomic)         double        tempo;

@end

@implementation MyGLKViewController



#pragma mark - setup

- (void)setupEffect
{
    self.effect = [[GLKBaseEffect alloc]init];
}

- (void)setupGL {
    
    [EAGLContext setCurrentContext:self.context];
    _zoom = ZOOM_INIT;
    _scale = SCALE_MIN;
    _rotation = 0.0;
    glGenBuffers(1, &_verticesVBO);
    glBindBuffer(GL_ARRAY_BUFFER, _verticesVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    init_indices(Indices);
    
    glGenBuffers(1, &_indicesVBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indicesVBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

}

- (void)setupPlayback
{
    self.playbackController = [[MMPlaybackController alloc]init];
    self.playbackController.delegate = self;
    
    NSArray *allTables = @[kSynthTable,kBassTable,kDrumTable,kSamplerTable,kFuzzTable,kSynthTable1,kTremeloTable,kSynthTable2];
    NSRange indexRange;
    indexRange.location = 0;
    indexRange.length = NUM_TABLES;
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:indexRange];
    kTables = [allTables objectsAtIndexes:indexSet];
}

- (void)setupContext
{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    
    // Enable face culling and depth test
    glEnable( GL_DEPTH_TEST );
    glEnable( GL_CULL_FACE  );
    
    // Set up the viewport
    int width = view.bounds.size.width;
    int height = view.bounds.size.height;
    glViewport(0, 0, width, height);
}

- (void)setupViews
{
    [self randomizeColors];
    self.currentModName = @"Mario";
    [self setupLabels];
    [self updateLabelText];
}

#pragma mark - Tear down

- (void)tearDownGL {
    
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_verticesVBO);
    glDeleteBuffers(1, &_indicesVBO);
    self.effect = nil;
}

- (void)dealloc
{
    [self tearDownGL];
    if ([EAGLContext currentContext] == _context) {
        [EAGLContext setCurrentContext:nil];
    }
    _context = nil;
}

#pragma mark - ViewController Life cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setupViews];
    [self setupPlayback];
    [self setupContext];
    [self setupEffect];
    [self setupGL];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)showDetails {
    
    NSString *tempoInfo = [NSString stringWithFormat:@"%.f beats/min",self.tempo];
    [self showTempoInfo:tempoInfo];
}

- (void)randomizeColors
{
    random_rgb(colors,(NUM_TABLES+1));
    [self updateLabelColors];
}

#pragma mark - Property accessors

- (void)setPlaying:(BOOL)playing
{
    BOOL old = _playing;
    _playing = playing;
    if (_playing != old) {
        if (_playing) {
            [self.playbackController startPlayback];
            [self playbackBegan:nil];
        }else{
            [self.playbackController stopPlayback];
            [self playbackEnded:nil];
        }
    }
}

- (void)setCurrentModName:(NSString *)currentModName
{
    NSString *prevModName = _currentModName;
    _currentModName = currentModName;
    
    if (![currentModName isEqualToString:prevModName]) {
        [self updateLabelText];
        [self showDetails];
    }
}

#pragma mark - MMPlaybackControllerDelegate
- (void)playbackBegan:(id)sender
{
    [self randomizeColors];
    [self updateLabelText];
    [self hideLabelsAnimated:YES];
    kUpdating = YES;
}

- (void)playbackEnded:(id)sender
{
    [self updateLabelText];
    [self showLabelsAnimated:YES];
    kUpdating = NO;
}

- (void)playback:(id)sender clockDidChange:(NSInteger)clock
{
    kClock = (int)clock;
    if (kClock == 0) {
        [self randomizeColors];
    }
}

- (void)playback:(id)sender detectedUserTempo:(double)tempo {

    self.tempo = tempo;
    NSString *tempoInfo = [NSString stringWithFormat:@"%.f beats/min",tempo];
    [self showTempoInfo:tempoInfo];
}

#pragma mark - Update vertices

- (void)updateVertexData
{
    int maxIdx = self.timeSinceLastUpdate * SAMPLE_RATE;
    
    if (maxIdx >= TABLE_SIZE) {
        maxIdx = (TABLE_SIZE - 1);
    }
    
    [PdBase sendBangToReceiver:@"updateScopes"];
    
    for (int i = 0; i < NUM_TABLES; i++) {
        NSString *kTable = kTables[i];
        GLfloat y = (GLfloat)(((float)i/(float)(NUM_TABLES - 1.0) * 2.0) - 1.0);
        [MMScopeDataSource sampleArray:NUM_POINTS maxIndex:maxIdx fromTable:kTable completion:^(float data[], int n) {
            if (data != NULL) {
                for (int j = 0; j < NUM_POINTS; j ++) {
                    int idx = (int)((i * NUM_POINTS) + j);
                    Vertex v = Vertices[idx];
                    float sample = data[j];
                    GLfloat d = (GLfloat)sample;
                    if (d!=d) {
                        d = 0.0;
                    }
                    
                    GLfloat normSample = ((d + 1)/2.0);
                    
                    double rads = (GLfloat)((float)j * ((2.0 * M_PI)/(float)(NUM_POINTS-1)));
                    
                    GLfloat x = cos(rads) + cos(rads) * fabs(sample);
                    GLfloat z = sin(rads) + sin(rads) * fabs(sample);
                    
                    v.Position[0] = x;
                    v.Position[1] = y;
                    v.Position[2] = z;
                    
                    GLfloat jitteredColors[3];
                    jitter_rgb(colors, jitteredColors, 5.0, i);
                    int colorIdx = i * NUM_TABLES;
                    GLfloat c = colors[colorIdx];
                    v.Color[0] = (c * normSample);
                    colorIdx++;
                    c = colors[colorIdx];
                    v.Color[1] = (c * normSample);
                    colorIdx++;
                    c = colors[colorIdx];
                    v.Color[2] = (c * normSample);
                    v.Color[3] = 1.0;
                    Vertices[idx] = v;
                }
            }
        }];
        
    }
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
}

- (void)updateModelViewMatrix
{
    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), aspect, 1.0f, 20.0f);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    
    _zoom += 0.01 * self.timeSinceLastUpdate;
    if (_zoom < -0.5) {
        _zoom = ZOOM_INIT;
    }
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, _zoom);
    _rotation += 10 * self.timeSinceLastUpdate;
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(-90), 1, 0, 0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(_rotation), 0, 1, 0);
    static double coeff;
    
    if (!coeff) {
        coeff = SCALE_COEFF;
    }
    
    if (_scale > SCALE_MAX && coeff > 0) {
        coeff = -SCALE_COEFF;
    }else if (_scale < SCALE_MIN && coeff < 0){
        coeff = SCALE_COEFF;
    }
    
    _scale += coeff * self.timeSinceLastUpdate;
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 1, _scale, 1);
    
    self.effect.transform.modelviewMatrix = modelViewMatrix;
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    int colorIdx = (NUM_TABLES-1) * 3;
    GLfloat r = colors[colorIdx];
    colorIdx++;
    GLfloat g = colors[colorIdx];
    colorIdx++;
    GLfloat b = colors[colorIdx];
    
    self.mainColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    
    glClearColor(r, g, b, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindBuffer(GL_ARRAY_BUFFER, _verticesVBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indicesVBO);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Position));
    
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Color));
    
    [self.effect prepareToDraw];
    
    glDrawElements(GL_TRIANGLE_STRIP, sizeof(Indices)/sizeof(Indices[0]),GL_UNSIGNED_INT, 0);
}


#pragma mark - GLKViewControllerDelegate

- (void)update {
    
    if (!kUpdating) {
        return;
    }
    
    [self updateVertexData];
    [self updateModelViewMatrix];

}

#pragma mark - Utils

- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType
{
    // Load the shader in memory
    NSString *shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if(!shaderString)
    {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    // Create the shader inside openGL
    GLuint shaderHandle = glCreateShader(shaderType);
    
    // Give that shader the source code loaded in memory
    const char *shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // Compile the source code
    glCompileShader(shaderHandle);
    
    // Get the error messages in case the compiling has failed
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLint logLength;
        glGetShaderiv(shaderHandle, GL_INFO_LOG_LENGTH, &logLength);
        if(logLength > 0)
        {
            GLchar *log = (GLchar *)malloc(logLength);
            glGetShaderInfoLog(shaderHandle, logLength, &logLength, log);
            NSLog(@"Shader compile log:\n%s", log);
            free(log);
        }
        exit(1);
    }
    
    return shaderHandle;
}

-(void)createProgram
{
    // Compile both shaders
    GLuint vertexShader = [self compileShader:VERTEX_SHADER withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:FRAGMENT_SHADER withType:GL_FRAGMENT_SHADER];
    
    // Create the program in openGL, attach the shaders and link them
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    // Get the error message in case the linking has failed
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE)
    {
        GLint logLength;
        glGetProgramiv(programHandle, GL_INFO_LOG_LENGTH, &logLength);
        if(logLength > 0)
        {
            GLchar *log = (GLchar *)malloc(logLength);
            glGetProgramInfoLog(programHandle, logLength, &logLength, log);
            NSLog(@"Program link log:\n%s", log);
            free(log);
        }
        exit(1);
    }
    
    _program = programHandle;
}

-(void)getUniforms
{
    GLint maxUniformLength;
    GLint numberOfUniforms;
    char *uniformName;
    
    // Get the number of uniforms and the max length of their names
    glGetProgramiv(_program, GL_ACTIVE_UNIFORMS, &numberOfUniforms);
    glGetProgramiv(_program, GL_ACTIVE_UNIFORM_MAX_LENGTH, &maxUniformLength);
    
    _uniformArray = malloc(numberOfUniforms * sizeof(Uniform));
    _uniformArraySize = numberOfUniforms;
    
    for(int i = 0; i < numberOfUniforms; i++)
    {
        GLint size;
        GLenum type;
        GLint location;
        // Get the Uniform Info
        uniformName = malloc(sizeof(char) * maxUniformLength);
        glGetActiveUniform(_program, i, maxUniformLength, NULL, &size, &type, uniformName);
        _uniformArray[i].Name = uniformName;
        // Get the uniform location
        location = glGetUniformLocation(_program, uniformName);
        _uniformArray[i].Location = location;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
