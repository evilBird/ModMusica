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

#define NUM_POINTS 500
#define NUM_TABLES 13

typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

@interface MyGLKViewController () <MMPlaybackDelegate>
{
    GLuint _vertexBuffer;
    Vertex Vertices[NUM_POINTS * NUM_TABLES];
    NSArray *kTables;
    BOOL kUpdating;
    float scale;
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
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
}

- (void)tearDownGL {
    
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    self.effect = nil;
}

#pragma mark - ScopeData config

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.playbackController = [[MMPlaybackController alloc]init];
    self.playbackController.delegate = self;
    
    kTables = @[kDrumTable,kSynthTable,kBassTable,kSamplerTable,kInputTable,kSnareTable,kPercTable,kTremeloTable,kFuzzTable,kKickTable,kSynthTable1,kSynthTable2,kSynthTable3];
    
    scale = 0.5;
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
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

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self.effect prepareToDraw];
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Position));
    
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Color));
    
    glDrawArrays(GL_LINE_LOOP, 0, NUM_POINTS * NUM_TABLES);
}

#pragma mark - GLKViewControllerDelegate

- (void)update {
    
    if (kUpdating) {
        
        for (int i = 0; i< NUM_TABLES; i ++) {
            [MMScopeDataSource getRawScopeDataFromTable:kDrumTable length:NUM_POINTS completion:^(float data[]) {
                for (int j = 0; j < NUM_POINTS; j ++) {
                    int idx = (i*j)+j;
                    Vertex v = Vertices[idx];
                    v.Position[0] = ((float)j/(float)NUM_POINTS) * 2.0 - 1.0;
                    v.Position[1] = data[j];
                    v.Position[2] = (arc4random_uniform(200)-100)*0.01;
                    v.Color[i%3] = 1;
                    Vertices[idx] = v;
                }
            }];
        }
        /*
        float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
        GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 4.0f, 10.0f);
        self.effect.transform.projectionMatrix = projectionMatrix;
        float s = scale + 0.1 * self.timeSinceLastUpdate;
        GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -6.0f);
        modelViewMatrix = GLKMatrix4Scale(modelViewMatrix,
                                          s, s, s);
        self.effect.transform.modelviewMatrix = modelViewMatrix;
        scale = s;
         */
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
