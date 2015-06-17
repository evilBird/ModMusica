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

#define NUM_POINTS 30
#define NUM_TABLES 3
#define SAMPLE_RATE 44100
#define BLOCK_SIZE 64
#define TICKS 64
#define TABLE_SIZE 2048

typedef struct {
    float Position[3];
    float Color[4];
} Vertex;



static void init_indices(GLubyte indices[])
{
    int drawIndex = 0;
    int rows = (NUM_POINTS - 1);
    int cols = (NUM_TABLES - 1);
    
    for (int i = 0; i < rows; i++) {
        
        for (int j = 0; j < cols; j++) {
            
            indices[drawIndex] = (GLubyte)((j * NUM_POINTS) + i);
            drawIndex++;
            indices[drawIndex] = (GLubyte)((j * NUM_POINTS) + (i + 1));
            drawIndex++;
            indices[drawIndex] = (GLubyte)(((j + 1) * NUM_POINTS) + i);
            drawIndex++;
        }
        
        for (int j = 0; j < cols; j++) {
            GLubyte idx = cols - 1 - j;
            indices[drawIndex] = (GLubyte)(((idx + 1) * NUM_POINTS) + i);
            drawIndex++;
            indices[drawIndex] = (GLubyte)(((idx + 1) * NUM_POINTS) + (i + 1));
            drawIndex++;
            indices[drawIndex] = (GLubyte)((idx * NUM_POINTS) + (i + 1));
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
    GLubyte Indices[(NUM_POINTS-1) * (NUM_TABLES - 1) * 6];
    GLuint _indexBuffer;
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property (strong, nonatomic) MMPlaybackController *playbackController;

@end

@implementation MyGLKViewController

- (void)setupGL {
    
    [EAGLContext setCurrentContext:self.context];
    
    self.effect = [[GLKBaseEffect alloc] init];
    
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_DYNAMIC_DRAW);
    
    init_indices(Indices);
    
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
}

- (void)tearDownGL {
    
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteBuffers(1, &_indexBuffer);
    self.effect = nil;
}

#pragma mark - ScopeData config

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //NSInteger tbs = SAMPLE_RATE/TABLE_SIZE;
    //NSInteger fps = 1000/tbs;
    
    //self.preferredFramesPerSecond = 30;
    
    self.playbackController = [[MMPlaybackController alloc]init];
    self.playbackController.delegate = self;
    
    kTables = @[kDrumTable,kSynthTable,kBassTable];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    [self setupGL];
    [self.playbackController startPlayback];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self tearDownGL];
    if ([EAGLContext currentContext] == _context) {
        [EAGLContext setCurrentContext:nil];
    }
    _context = nil;
}

- (void)showDetails
{
    
}

- (void)beginUpdates
{
    kUpdating = YES;
}

- (void)endUpdates
{
    kUpdating = NO;
}

#pragma mark - MMPlaybackControllerDelegate
#pragma mark - MMVisualPlaybackDelegate
- (void)playbackBegan:(id)sender
{
    [self beginUpdates];
}

- (void)playbackEnded:(id)sender
{
    [self endUpdates];
}

- (void)playback:(id)sender clockDidChange:(NSInteger)clock
{
    //[self update];
}

- (void)playback:(id)sender detectedUserTempo:(double)tempo
{
    
}

#pragma mark - MMScopeDataConsumer

- (BOOL)shouldDraw
{
    if ((self.timeSinceLastDraw * SAMPLE_RATE) < TABLE_SIZE) {
        return NO;
    }
    
    return YES;
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Position));
    
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Color));
    
    [self.effect prepareToDraw];
    
    glDrawElements(GL_TRIANGLE_STRIP, sizeof(Indices)/sizeof(Indices[0]),GL_UNSIGNED_BYTE, 0);
}

#pragma mark - GLKViewControllerDelegate

- (void)update {
    
    if (!kUpdating) {
        return;
    }
    
    int maxIdx = self.timeSinceLastUpdate * SAMPLE_RATE;
    
    if (maxIdx >= TABLE_SIZE) {
        maxIdx = (TABLE_SIZE - 1);
    }
    
    [PdBase sendBangToReceiver:@"updateScopes"];
    for (int i = 0; i < NUM_TABLES; i++) {
        NSString *kTable = kTables[i];
        GLfloat normY = (GLfloat)(1.0 - ((float)i/(float)(NUM_TABLES - 1.0) * 2.0));
        [MMScopeDataSource sampleArray:NUM_POINTS maxIndex:maxIdx fromTable:kTable completion:^(float data[], int n) {
            if (data != NULL) {
                for (int j = 0; j < NUM_POINTS; j ++) {
                    int idx = (int)((i * NUM_POINTS) + j);
                    Vertex v = Vertices[idx];
                    v.Position[0] = (GLfloat)(((float)j/(float)NUM_POINTS) * 2.0 - 1.0);
                    GLfloat d = (GLfloat)data[j];
                    if (d!=d) {
                        d = 0.0;
                    }
                    v.Position[1] = normY;
                    v.Position[2] = d;
                    v.Color[0] = (d + 1.0 * 0.5);
                    v.Color[1] = 1.0 - ((normY + 1.0) * 0.5);
                    v.Color[2] = ((normY + 1.0) * 0.5);
                    v.Color[3] = 0.5;
                    Vertices[idx] = v;
                }
            }
        }];
        
    }

    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);


    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), aspect, 1.0f, 100.0f);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -3.5f);
    _rotation -= 5 * self.timeSinceLastUpdate;
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(_rotation), 1, 0, 0);
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 1, 1, 1);
    
    self.effect.transform.modelviewMatrix = modelViewMatrix;
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
