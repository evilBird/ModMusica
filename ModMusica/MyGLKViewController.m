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
    GLuint      _verticesVBO;
    GLuint      _indicesVBO;
    
    Vertex      Vertices        [(SAMPLES_PER_TABLE * NUM_TABLES * VERTICES_PER_SAMPLE)];
    GLuint      Indices         [(SAMPLES_PER_TABLE - 1) * ((NUM_TABLES * VERTICES_PER_SAMPLE) - 1) * 6];
    float       Samples         [(SAMPLES_PER_TABLE * NUM_TABLES)];
    GLfloat     Colors          [((NUM_TABLES + 1) * 3)];
    
    float       _rotation_y;
    float       _zoom;
    float       _scale;
    
    float       _d_rotation_y;
    float       _d_scale;
    float       _d_zoom;
}

@property (strong, nonatomic)   EAGLContext         *context;
@property (strong, nonatomic)   GLKBaseEffect       *effect;
@property (strong, nonatomic)   NSArray             *tables;
@property (strong, nonatomic)   NSTimer             *labelUpdateTimer;

@property (nonatomic,strong)    NSDate              *lastSampleUpdate;
@property (nonatomic,readonly)  NSTimeInterval      timeSinceLastSampleUpdate;

@property (nonatomic)           double              tempo;
@property (nonatomic)           double              clock;

@end

@implementation MyGLKViewController

#pragma mark - Public Methods

- (void)showDetails {
    
    NSString *tempoInfo = [NSString stringWithFormat:@"%.f beats/min",self.tempo];
    [self showTempoInfo:tempoInfo];
}

- (void)randomizeColors
{
    random_rgb(Colors,(NUM_TABLES+1));
    [self updateLabelColors];
}

#pragma mark - Property accessors

- (void)setPlaying:(BOOL)playing
{
    BOOL old = _playing;
    _playing = playing;
    if (_playing != old) {
        if (_playing) {
            self.labelUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                                     target:self
                                                                   selector:@selector(handleLabelUpdateTimer:)
                                                                   userInfo:nil
                                                                    repeats:NO];
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
    
    int colorIdx = (NUM_TABLES-1) * 3;
    
    GLfloat r = Colors[colorIdx];
    colorIdx++;
    GLfloat g = Colors[colorIdx];
    colorIdx++;
    GLfloat b = Colors[colorIdx];
    
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

    if ([self timeSinceLastSampleUpdate] > [self minimumSampleUpdateInterval]) {
        [self updateVertexData];
    }
    [self updateModelViewMatrix];
}

#pragma mark - Update Methods

- (void)updateVertexData
{
    get_samples(self.tables, Samples,SAMPLES_PER_TABLE,1);
    update_vertices(Vertices, Samples, NUM_TABLES, SAMPLES_PER_TABLE, VERTICES_PER_SAMPLE);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_DYNAMIC_DRAW);
    self.lastSampleUpdate = [NSDate date];
}

- (GLKMatrix4)getUpdatedTranslationMatrix
{
    if (_zoom >= MAX_ZOOM || _zoom <= MIN_ZOOM) {
        _d_zoom *= -1.0;
    }
    
    _zoom += _d_zoom * self.timeSinceLastUpdate;
    
    return GLKMatrix4MakeTranslation(0.0f, 0.0f, _zoom);
}

- (GLKMatrix4)updateRotationMatrix:(GLKMatrix4)matrix
{
    
    _rotation_y += D_ROTATION_Y * self.timeSinceLastUpdate;
    matrix = GLKMatrix4Rotate(matrix, GLKMathDegreesToRadians(INIT_ROTATION_X), 1, 0, 0);
    matrix = GLKMatrix4Rotate(matrix, GLKMathDegreesToRadians(_rotation_y), 0.001, 1, 0.001);
    return matrix;
}

- (GLKMatrix4)updateScaleMatrix:(GLKMatrix4)matrix
{
    if (_scale >= MAX_SCALE || _scale <= MIN_SCALE) {
        _d_scale *= -1.0;
    }
    
    _scale += _d_scale * self.timeSinceLastUpdate;
    matrix = GLKMatrix4Scale(matrix, 1, _scale, 1);
    return matrix;
}

- (void)updateModelViewMatrix
{
    GLKMatrix4 modelViewMatrix = [self getUpdatedTranslationMatrix];
    modelViewMatrix = [self updateRotationMatrix:modelViewMatrix];
    modelViewMatrix = [self updateScaleMatrix:modelViewMatrix];
    self.effect.transform.modelviewMatrix = modelViewMatrix;
}

#pragma mark - setup

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


- (void)setupEffect
{
    self.effect = [[GLKBaseEffect alloc]init];
    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), aspect, 1.0, 100.0);
    self.effect.transform.projectionMatrix = projectionMatrix;
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
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    view.drawableStencilFormat = GLKViewDrawableStencilFormat8;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    view.delegate = self;
    
    // Enable face culling and depth test
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    
}

- (void)setupSampleTables
{
    NSArray *allTables = @[kSynthTable,kBassTable,kDrumTable,kSamplerTable,kDrumTable,kSynthTable,kSamplerTable,kBassTable];
    
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
}

- (void)setupPlayback
{
    self.playbackController = [[MMPlaybackController alloc]init];
    self.playbackController.delegate = self;
    self.currentModName = @"mario";
}

#pragma mark - Helpers

- (NSTimeInterval)minimumSampleUpdateInterval
{
    return 1.0/self.framesPerSecond;
}


#pragma mark - MMPlaybackControllerDelegate

- (void)playbackBegan:(id)sender
{
    [self randomizeColors];
    [self updateLabelText];
    [self hideLabelsAnimated:YES];
}

- (void)playbackEnded:(id)sender
{
    [self updateLabelText];
    [self showLabelsAnimated:YES];
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
    NSString *tempoInfo = [NSString stringWithFormat:@"%.f beats/min",tempo];
    if (!self.labelUpdateTimer.isValid) {
        [self showTempoInfo:tempoInfo];
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
    [self setupEffect];
    [self setupGL];
    [self playbackEnded:nil];
    // Do any additional setup after loading the view.
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
