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
#import "MyGLKViewController+Button.h"
#import "MyGLKFunctions.h"

@interface MyGLKViewController () <MMPlaybackDelegate>
{
    GLuint      _verticesVBO;
    GLuint      _indicesVBO;
    
    Vertex      Vertices        [(SAMPLES_PER_TABLE * NUM_TABLES * VERTICES_PER_SAMPLE)];
    GLuint      Indices         [(SAMPLES_PER_TABLE - 1) * ((NUM_TABLES * VERTICES_PER_SAMPLE)) * 6];
    float       Samples         [(SAMPLES_PER_TABLE * NUM_TABLES)];
    GLfloat     Colors          [3];
    
    float       _rotation_y;

    
    float       _d_rotation_y;
    float       _d_scale;
    float       _d_zoom;
    
    CMMotionManager *_motionMgr;

}


@property (strong, nonatomic)   NSArray             *tables;
@property (strong, nonatomic)   NSTimer             *labelUpdateTimer;

@property (nonatomic,strong)    NSDate              *lastSampleUpdate;

@end

@implementation MyGLKViewController

#pragma mark - Public Methods

- (void)changeScale:(CGFloat)deltaScale
{
    _scale = 0.1+deltaScale;
}

- (void)showDetailsFade:(BOOL)shouldFade
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showLabelsAnimated:) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideLabelsAnimated:) object:nil];
    [self showLabelsAnimated:YES];
    if (shouldFade) {
        __weak MyGLKViewController *weakself = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakself hideLabelsAnimated:YES];
        });
    }
}

- (void)randomizeColors
{
    _randomRGBInRange(Colors, 0.1, 0.6, 1);
    self.mainColor = [UIColor colorWithRed:Colors[0] green:Colors[1] blue:Colors[2] alpha:1.0];
    _setMainVertexColor(Colors);
    [self updateLabelColors];
    [self updateHamburgerButtonColor];
}

#pragma mark - Property accessors

- (void)setPlaying:(BOOL)playing
{
    BOOL wasPlaying = _playing;
    _playing = playing;
    if (playing && !wasPlaying) {
        [self.playbackController startPlayback];
        [self playbackBegan:nil];
        [self showDetailsFade:YES];
    }else if (playing && wasPlaying){
        [self showDetailsFade:YES];
    }else if (!playing && wasPlaying){
        [self.playbackController stopPlayback];
        [self playbackEnded:nil];
        [self showDetailsFade:NO];
    }
}

- (void)setCurrentModName:(NSString *)currentModName
{
    _currentModName = currentModName;
    [self randomizeColors];
    [self updateLabelText];
    [self showDetailsFade:self.isPlaying];
}

#pragma mark - Private Methods

- (NSTimeInterval)timeSinceLastSampleUpdate
{
    if (!self.lastSampleUpdate) {
        return 1e06;
    }
    
    return [[NSDate date]timeIntervalSinceDate:self.lastSampleUpdate];
}

#pragma mark - Drawing
#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    glClearColor(Colors[0], Colors[1], Colors[2], 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindBuffer(GL_ARRAY_BUFFER, _verticesVBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indicesVBO);
    
    [self.effect prepareToDraw];
    
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]),GL_UNSIGNED_INT, 0);
}

#pragma mark - Update Methods
#pragma mark - GLKViewControllerDelegate

- (void)update {
    
    if (self.isPlaying) {
        [self updateVertexData];
    }
    
    [self updatePerspective];
}

- (void)updateVertexData
{
    _getSamples(self.tables, Samples,SAMPLES_PER_TABLE,1);
    _updateVertices(Vertices, Samples, NUM_TABLES, SAMPLES_PER_TABLE, VERTICES_PER_SAMPLE);
    int numVertices = [self numVertices];
    _updateVertexNormals(Vertices, numVertices);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_DYNAMIC_DRAW);
    self.lastSampleUpdate = [NSDate date];
}

- (void)updatePerspective
{
    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), aspect, 1.0f, 20.0f);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    _zoom += _d_zoom * self.timeSinceLastUpdate;

    if (_zoom < MIN_ZOOM || _zoom > MAX_ZOOM) {
        _d_zoom *= -1.0;
    }
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, _zoom);
    
    _rotation_y += D_ROTATION_Y * self.timeSinceLastUpdate/4;
    
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(INIT_ROTATION_X), 1, 0, 0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(_rotation_y), 0, 1, 0);
    
    _scale += _d_scale * self.timeSinceLastUpdate;
    
    if (_scale < MIN_SCALE || _scale < MAX_SCALE) {
        _d_scale *= -1.0;
    }
    
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, _scale, _scale, _scale);
    modelViewMatrix = [self updateMotionManager:modelViewMatrix];
    self.effect.transform.modelviewMatrix = modelViewMatrix;
}

- (GLKMatrix4)updateMotionManager:(GLKMatrix4)baseModelViewMatrix
{
    if ([_motionMgr isDeviceMotionAvailable])
    {
        CMDeviceMotion *motion = [_motionMgr deviceMotion];
        
        CMAttitude *attitude = motion.attitude;
        
        if (!self.referenceFrame)
        {
            NSLog(@"reference frame is nil...setting it to the current attitude.");
            self.referenceFrame = motion.attitude;
        }
        else
        {
            [attitude multiplyByInverseOfAttitude:self.referenceFrame];
        }
        
        GLfloat pitchAngle  = 2.0 * attitude.pitch;
        GLfloat rollAngle   = 2.0 * attitude.roll;
        
        GLKMatrix4 rollMatrix   = GLKMatrix4MakeYRotation(rollAngle);
        GLKMatrix4 pitchMatrix  = GLKMatrix4MakeXRotation(pitchAngle);
        
        GLKMatrix4 modelViewMatrix = rollMatrix;
        modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, pitchMatrix);
        modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
        return modelViewMatrix;
    }
    
    return baseModelViewMatrix;
}

#pragma mark - setup

- (void)setupMotionManager
{
    _motionMgr = [[CMMotionManager alloc] init];
    if ([_motionMgr isDeviceMotionAvailable])
    {
        [_motionMgr startDeviceMotionUpdates];
    }
    
    self.referenceFrame = nil;
}

- (void)setupGL {
    
    [EAGLContext setCurrentContext:self.context];
    
    glGenBuffers(1, &_verticesVBO);
    glBindBuffer(GL_ARRAY_BUFFER, _verticesVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_DYNAMIC_DRAW);
    
    _makeMeshIndices(Indices, SAMPLES_PER_TABLE, (NUM_TABLES * VERTICES_PER_SAMPLE));
    _initVertices(Vertices,(SAMPLES_PER_TABLE * NUM_TABLES * VERTICES_PER_SAMPLE));
    _assignVertexNeighbors(Vertices, Indices, [self numIndices]);
    _updateVertexNormals(Vertices, [self numVertices]);
    
    glGenBuffers(1, &_indicesVBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indicesVBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
    //Position
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Position));
    
    // Color
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Color));
#if USE_NORMALS
    // Normals
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *)offsetof(Vertex, Normal)); // for model, normals, and texture
#endif
}

- (void)setupBaseEffect
{
    self.effect = [[GLKBaseEffect alloc]init];
    self.effect.transform.projectionMatrix = [self defaultProjectionMatrix];
    self.effect.transform.modelviewMatrix = [self defaultModelViewMatrix];
}

- (void)setupContext
{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
        return;
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.drawableStencilFormat = GLKViewDrawableStencilFormat8;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    view.delegate = self;
    
    // Enable face culling and depth test
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
}

- (void)setupSampleTables
{
    NSArray *allTables = @[kSynthTable,kSynthTable,kRawInputTable,kRawInputTable,kSamplerTable,kSamplerTable,kBassTable,kBassTable,kPercTable,kPercTable,kSnareTable,kSnareTable,kDrumTable,kDrumTable];
    
    NSRange indexRange;
    indexRange.location = 0;
    indexRange.length = NUM_TABLES;
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:indexRange];
    
    self.tables = [allTables objectsAtIndexes:indexSet];
}

- (void)setupIvars
{
    _zoom = MIN_ZOOM;
    _d_zoom = D_ZOOM;

    _scale = MIN_SCALE;
    _d_scale = D_SCALE;
    
    _rotation_y = INIT_ROTATION_Y;
    _d_rotation_y = D_ROTATION_Y;
}

- (void)setupViews
{
    [self randomizeColors];
    [self setupLabels];
    [self updateLabelText];
    [self setupHamburgerButton];
    [self updateLabelColors];
}

- (void)setupPlayback
{
    self.playbackController = [[MMPlaybackController alloc]init];
    self.playbackController.delegate = self;
    self.playbackController.patternName = @"";
}

#pragma mark - Helpers

- (NSTimeInterval)minimumSampleUpdateInterval
{
    return 1.0/self.framesPerSecond/4.0;
}

- (int)numIndices
{
    int numIndices = (SAMPLES_PER_TABLE - 1) * ((NUM_TABLES * VERTICES_PER_SAMPLE)) * 6;
    return numIndices;
}

- (int)numVertices
{
    int numVertices = SAMPLES_PER_TABLE * NUM_TABLES * VERTICES_PER_SAMPLE;
    return numVertices;
}

- (GLKMatrix4)defaultModelViewMatrix
{
    GLKMatrix4 matrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, _zoom);
    matrix = GLKMatrix4Rotate(matrix, GLKMathDegreesToRadians(INIT_ROTATION_X), 1, 0, 0);
    return matrix;
}

- (GLKMatrix4)defaultProjectionMatrix
{
    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), aspect, 1.0, 100.0);
    return projectionMatrix;
}

#pragma mark - MMPlaybackControllerDelegate

- (void)playbackBegan:(id)sender
{
    [self randomizeColors];
    [self updateLabelText];
    self.paused = NO;
    [self resetReferenceFrame:nil];
    [self setupIvars];
}

- (void)playbackEnded:(id)sender
{
    [self updateLabelText];
    [self resetReferenceFrame:nil];
    [self setupIvars];
}

- (void)playback:(id)sender clockDidChange:(NSInteger)clock
{
    self.clock = (float)clock;
    if (self.clock == 0) {
        [self randomizeColors];
    }
}

- (void)playback:(id)sender detectedUserTempo:(double)tempo {
    
    self.tempo = tempo;
    [self updateLabelText];
    [self showDetailsFade:self.isPlaying];

}

- (void)playback:(id)sender didLoadModuleName:(NSString *)moduleName
{
    self.currentModName = moduleName;
    if (!self.playing) {
        self.playing = YES;
    }
}

#pragma mark - Reference Frame

- (void)resetReferenceFrame:(id)sender
{
    if ([_motionMgr isDeviceMotionActive])
    {
        self.referenceFrame = [[_motionMgr deviceMotion] attitude];
    }
}

#pragma mark - ViewController Life cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setupPlayback];
    [self setupViews];
    [self setupIvars];
    [self setupSampleTables];
    [self setupContext];
    [self setupBaseEffect];
    [self setupGL];
    [self updateVertexData];
    [self setupMotionManager];
    [self playbackEnded:nil];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.playing) {
        [self showDetailsFade:NO];
    }else{
        [self showDetailsFade:YES];
    }
}

- (void)dealloc
{
    [self tearDownGL];
    if ([EAGLContext currentContext] == _context) {
        [EAGLContext setCurrentContext:nil];
    }
    _context = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tear down

- (void)tearDownGL {
    
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_verticesVBO);
    glDeleteBuffers(1, &_indicesVBO);
    
    self.effect = nil;
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
