//
//  MMVisualViewController.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/5/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMVisualViewController.h"
#import "UIView+Layout.h"
#import "CALayer+Image.h"
#import "UIColor+HBVHarmonies.h"

@interface MMVisualViewController ()


@end

@implementation MMVisualViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView = [[GPUImageView alloc]init];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.imageView];
    [self.view addConstraints:[self.imageView pinEdgesToSuperWithInsets:UIEdgeInsetsZero]];
    [self.view layoutIfNeeded];
    self.mySourceImage = [self initialSourceImage];
    [self setupFilter];
    [self processImage];
    
    self.shapeLayer = [[CAShapeLayer alloc]init];
    [self.view.layer addSublayer:self.shapeLayer];
    self.shapeLayer.frame = self.view.bounds;
    self.shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.shapeLayer.fillColor = [UIColor greenColor].CGColor;
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)setupFilter
{
    if (self.picture) {
        [self.picture removeAllTargets];
        self.picture = nil;
    }
    if (!self.filter) {
        self.filter = [self makeFilter];
    }
    
    self.picture = [[GPUImagePicture alloc]initWithImage:self.mySourceImage];
    [self.filter forceProcessingAtSize:self.picture.outputImageSize];
    [self.picture addTarget:self.filter];
    [self.filter addTarget:self.imageView];
    [self.filter useNextFrameForImageCapture];
}

- (void)tearDownFilter
{
    if (self.picture) {
        [self.picture removeAllTargets];
    }
    
    if (self.filter) {
        [self.filter removeAllTargets];
    }
    
    self.picture = nil;
    self.filter = nil;
}

- (GPUImageFilter *)makeFilter
{
    return nil;
}

- (UIImage *)initialSourceImage
{
    return nil;
}

- (void)processImage
{
    [self.picture processImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)animateScopePath:(UIBezierPath *)path duration:(CGFloat)duration
{
    static UIBezierPath *prevPath;
    static UIColor *prevColor;
    UIColor *randomColor = [UIColor randomColor];
    if (!prevPath) {
        self.shapeLayer.fillColor = randomColor.CGColor;
        self.shapeLayer.path = path.CGPath;
        prevPath = path;
        prevColor = randomColor;
        return;
    }
    
    UIColor *newcolor = [prevColor jitterWithPercent:10.0];
    CABasicAnimation *anim = [[CABasicAnimation alloc]init];
    anim.keyPath = @"path";
    anim.fromValue = (__bridge id)(prevPath.CGPath);
    anim.toValue = (__bridge id)(path.CGPath);
    anim.duration = duration;
    [self.shapeLayer addAnimation:anim forKey:@"scopeData"];
    
    CABasicAnimation *col = [[CABasicAnimation alloc]init];
    col.keyPath = @"fillColor";
    col.fromValue = (__bridge id)(prevColor.CGColor);
    col.toValue = (__bridge id)(newcolor.CGColor);
    col.duration = duration;
    [self.shapeLayer addAnimation:col forKey:@"randomColor"];
}

- (UIBezierPath *)pathWithScopeData:(NSArray *)data
{
    CGSize mySize = self.view.bounds.size;
    double x_scale = mySize.width/(double)data.count;
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint point = CGPointZero;
    for (NSUInteger i = 0; i < data.count; i ++) {
        NSNumber *sample = data[i];
        float val = sample.floatValue;
        double norm = (val+1.0 * 0.5);
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
    [path addLineToPoint:point];
    point.x = 0;
    [path addLineToPoint:point];
    [path closePath];
    
    return path;
}

#pragma mark - MMPlaybackDelegate
- (void)playback:(id)sender clockDidChange:(NSInteger)clock
{
    [self processImage];
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
