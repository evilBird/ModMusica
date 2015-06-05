//
//  MMVisualViewController.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/5/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMVisualViewController.h"
#import "GPUImage.h"
#import "UIView+Layout.h"

@interface MMVisualViewController ()

@property (nonatomic,strong)GPUImageFilter *filter;
@property (nonatomic,strong)GPUImageView *imageView;
@property (nonatomic,strong)GPUImagePicture *picture;

@end

@implementation MMVisualViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView = [[GPUImageView alloc]init];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.imageView];
    [self.view addConstraints:[self.imageView pinEdgesToSuperWithInsets:UIEdgeInsetsZero]];
    [self.view layoutIfNeeded];
    UIImage *image = [UIImage imageNamed:@"Icon"];
    [self setupFilterWithImage:image];
    // Do any additional setup after loading the view.
}

- (void)setupFilterWithImage:(UIImage *)image
{
    if (self.picture) {
        [self.picture removeAllTargets];
    }
    if (!self.filter) {
        self.filter = [self makeFilter];
    }
    
    self.picture = [[GPUImagePicture alloc]initWithImage:image];
    [self.filter forceProcessingAtSize:self.picture.outputImageSize];
    [self.picture addTarget:self.filter];
    [self.filter addTarget:self.imageView];
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

- (void)processImage
{
    [self.filter useNextFrameForImageCapture];
    [self.picture processImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
