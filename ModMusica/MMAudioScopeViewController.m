//
//  MMAudioScopeViewController.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/5/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMAudioScopeViewController.h"
#import "UIColor+HBVHarmonies.h"

@interface MMAudioScopeViewController ()

@property (nonatomic,strong)        NSMutableArray          *scopeDataSources;
@property (nonatomic,strong)        NSMutableArray          *shapeLayers;
@property (nonatomic,strong)        NSMutableArray          *oldPaths;
@property (nonatomic,strong)        NSMutableArray          *oldColors;

@end

@implementation MMAudioScopeViewController

- (void)beginUpdates
{
    for (MMScopeDataSource *source in self.scopeDataSources) {
        [source beginUpdates];
    }
}

- (void)endUpdates
{
    for (MMScopeDataSource *source in self.scopeDataSources) {
        [source endUpdates];
    }
}

- (CAShapeLayer *)newShapeLayer
{
    CAShapeLayer *shapeLayer = nil;
    shapeLayer = [[CAShapeLayer alloc]init];
    shapeLayer.frame = self.view.bounds;
    shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    return shapeLayer;
}

- (void)randomizeColors
{
    for (CAShapeLayer *layer in self.shapeLayers) {
        UIColor *randomColor = [UIColor randomColor];
        UIColor *myColor = [randomColor adjustAlpha:0.1];
        layer.fillColor = myColor.CGColor;
        layer.strokeColor = randomColor.CGColor;
        layer.lineWidth = arc4random_uniform(10)/2.0;
    }
    
    self.view.backgroundColor = [UIColor randomColor];
}

- (MMScopeDataSource *)newScopeDataSource:(NSString *)table
{
    MMScopeDataSource *scopeData = [[MMScopeDataSource alloc]initWithUpdateInterval:0.1 sourceTable:table];
    scopeData.dataConsumer = self;
    return scopeData;
}

- (void)configureLayersAndData
{
    self.scopeDataSources = [NSMutableArray array];
    self.shapeLayers = [NSMutableArray array];
    NSArray *scopeNames = [MMScopeDataSource allTableNames];
    [self setupPathBuffers:scopeNames.count];
    for (NSString *name in scopeNames) {
        MMScopeDataSource *datasource = [self newScopeDataSource:name];
        [self.scopeDataSources addObject:datasource];
        CAShapeLayer *layer = [self newShapeLayer];
        [self.shapeLayers addObject:layer];
        [self.view.layer addSublayer:layer];
    }
}

- (void)setupPathBuffers:(NSInteger)count
{
    self.oldColors = [NSMutableArray array];
    self.oldPaths = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < count; i ++) {
        [self.oldColors addObject:[UIColor whiteColor]];
        [self.oldPaths addObject:[UIBezierPath bezierPath]];
    }
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureLayersAndData];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)animateLayer:(CAShapeLayer *)shapeLayer
           newPath:(UIBezierPath *)newPath
             oldPath:(UIBezierPath *)oldPath
            duration:(CGFloat)duration
{
    
    if (!oldPath) {
        shapeLayer.path = newPath.CGPath;
        return;
    }
    
    CABasicAnimation *anim = [[CABasicAnimation alloc]init];
    anim.keyPath = @"path";
    anim.fromValue = (__bridge id)(oldPath.CGPath);
    anim.toValue = (__bridge id)(newPath.CGPath);
    anim.duration = duration;
    [shapeLayer addAnimation:anim forKey:@"scopeData"];

}

- (UIBezierPath *)pathWithScopeData:(NSArray *)data
{
    CGSize mySize = self.view.bounds.size;
    double x_scale = mySize.width/(double)data.count;
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint point = CGPointZero;
    double sum = 0;
    
    for (NSUInteger i = 0; i < data.count; i ++) {
        NSNumber *sample = data[i];
        float val = sample.floatValue * 0.5;
        double norm = (val+1.0 * 0.5);
        sum+=val;
        point.x = x_scale * (double)i;
        point.y = mySize.height - (norm * mySize.height);
        
        if (i == 0) {
            [path moveToPoint:point];
        }else{
            [path addLineToPoint:point];
        }
    }
    point.x = self.view.bounds.size.width;
    [path addLineToPoint:point];
    point.y = self.view.bounds.size.height;
    //[path addLineToPoint:point];
    point.x = 0;
    //[path addLineToPoint:point];
    //[path closePath];
    
    if (sum == 0) {
        return nil;
    }
    
    return path;
}

#pragma mark - MMScopeDataConsumer

- (void)scopeData:(id)sender receivedData:(NSArray *)data
{
    if (!self.scopeDataSources || ![self.scopeDataSources containsObject:sender]) {
        return;
    }
    MMScopeDataSource *source = sender;
    NSUInteger index = [self.scopeDataSources indexOfObject:source];
    CAShapeLayer *layer = self.shapeLayers[index];
    
    UIBezierPath *newPath = [self pathWithScopeData:data];
    if (newPath == nil) {
        return;
    }
    
    UIBezierPath *oldPath = nil;
    
    if (self.oldPaths) {
        oldPath = self.oldPaths[index];
    }
    
    [self animateLayer:layer
               newPath:newPath
               oldPath:oldPath
              duration:source.interval];
    
    self.oldPaths[index] = newPath;
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