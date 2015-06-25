//
//  MyGLKViewController.m
//  GLKitStuff
//
//  Created by Travis Henspeter on 6/12/15.
//  Copyright (c) 2015 birdSound LLC. All rights reserved.
//

#import "MyGLKViewController.h"
#import "MMPlaybackController.h"
#import "MyGLKViewController+Labels.h"
#import "MyGLKFunctions.h"

@interface MyGLKViewController () <MMPlaybackDelegate>
{
    GLuint _verticesVBO;
    GLuint _indicesVBO;
    
    Vertex Vertices[(SAMPLES_PER_TABLE * NUM_TABLES * VERTICES_PER_SAMPLE)];
    GLuint Indices[(SAMPLES_PER_TABLE - 1) * ((NUM_TABLES * VERTICES_PER_SAMPLE) - 1) * 6];
    float samples[(SAMPLES_PER_TABLE * NUM_TABLES)];
    GLfloat colors[((NUM_TABLES + 1) * 3)];
    
    int kClock;
    NSArray *kTables;
    BOOL kUpdating;
    float _rotation;
    float _zoom;
    float _scale;
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property (nonatomic)         double        tempo;

@end

@implementation MyGLKViewController



#pragma mark - setup

- (void)setupIvars
{
    _zoom = ZOOM_INIT;
    _scale = SCALE_MIN;
    _rotation = 0.0;
}

- (void)setupEffect
{
    self.effect = [[GLKBaseEffect alloc]init];
}

- (void)setupGL {
    
    [EAGLContext setCurrentContext:self.context];

    glGenBuffers(1, &_verticesVBO);
    glBindBuffer(GL_ARRAY_BUFFER, _verticesVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_DYNAMIC_DRAW);
    
    make_mesh_indices(Indices, SAMPLES_PER_TABLE, (NUM_TABLES * VERTICES_PER_SAMPLE));
    
    glGenBuffers(1, &_indicesVBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indicesVBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
}

- (void)setupPlayback
{
    self.playbackController = [[MMPlaybackController alloc]init];
    self.playbackController.delegate = self;
    
    NSArray *allTables = @[kSynthTable,kBassTable,kDrumTable,kSamplerTable,kDrumTable,kSynthTable,kSamplerTable,kBassTable];
    
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
    //view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    //view.drawableStencilFormat = GLKViewDrawableStencilFormat8;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    view.delegate = self;
    
    // Enable face culling and depth test
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);

}

- (void)setupViews
{
    [self randomizeColors];
    self.currentModName = @"";
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
    [self setupIvars];
    [self setupEffect];
    [self setupGL];
    [self playbackEnded:nil];
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
    self.paused = NO;
}

- (void)playbackEnded:(id)sender
{
    [self updateLabelText];
    [self showLabelsAnimated:YES];
    kUpdating = NO;
    [self setupIvars];
    //self.paused = YES;
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
    get_samples(kTables, samples,SAMPLES_PER_TABLE,1);
    update_vertices(Vertices, samples, NUM_TABLES, SAMPLES_PER_TABLE, VERTICES_PER_SAMPLE);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_DYNAMIC_DRAW);
}

- (void)updateModelViewMatrix
{
    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), aspect, 1.0, 100.0);
    self.effect.transform.projectionMatrix = projectionMatrix;
    _zoom += ZOOM_DIFF * self.timeSinceLastUpdate;
    if (_zoom > MAX_ZOOM) {
        _zoom = ZOOM_INIT;
    }
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, _zoom);
    _rotation += ROTATION * self.timeSinceLastUpdate;
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(-90), 1, 0, 0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(_rotation), 0.001, 1, 0.001);
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
    
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]),GL_UNSIGNED_INT, 0);
}


#pragma mark - GLKViewControllerDelegate

- (void)update {

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
