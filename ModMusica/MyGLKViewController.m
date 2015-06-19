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

#define NUM_POINTS 100
#define NUM_TABLES 4
#define SAMPLE_RATE 44100
#define BLOCK_SIZE 64
#define TICKS 64
#define TABLE_SIZE 2048

typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

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
    GLuint _vertexBuffer;
    Vertex Vertices[(NUM_POINTS * NUM_TABLES)];
    NSArray *kTables;
    BOOL kUpdating;
    float _rotation;
    float _scale;
    GLuint Indices[(NUM_POINTS-1) * (NUM_TABLES - 1) * 6];
    GLuint _indexBuffer;
    GLfloat colors[((NUM_TABLES + 1) * 3)];
    int kClock;
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property (strong, nonatomic) MMPlaybackController *playbackController;

@end

@implementation MyGLKViewController

#pragma mark - setup

- (void)setupGL {
    
    [EAGLContext setCurrentContext:self.context];
    self.effect = [[GLKBaseEffect alloc]init];
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_DYNAMIC_DRAW);
    
    init_indices(Indices);
    
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
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
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
}

- (void)setupViews
{
    random_rgb(colors,(NUM_TABLES+1));
    self.currentModName = @"Mario";
    [self setupLabels];
    [self updateLabelText];
}

#pragma mark - Tear down

- (void)tearDownGL {
    
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteBuffers(1, &_indexBuffer);
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
    [self setupGL];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)showDetails {}

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


#pragma mark - MMPlaybackControllerDelegate
- (void)playbackBegan:(id)sender
{
    random_rgb(colors,(NUM_TABLES+1));
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
        random_rgb(colors,(NUM_TABLES+1));
    }
}

- (void)playback:(id)sender detectedUserTempo:(double)tempo {

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
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), aspect, 1.0f, 100.0f);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -3.5f);
    _rotation += 10 * self.timeSinceLastUpdate;
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(-90), 1, 0, 0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(_rotation), 0, 1, 0);
    static double coeff;
    
    if (!coeff) {
        coeff = 0.1;
    }
    
    if (_scale > 4.0 && coeff > 0) {
        coeff = -0.1;
    }else if (_scale < 0.2 && coeff < 0){
        coeff = 0.1;
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
    
    glClearColor(r, g, b, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
