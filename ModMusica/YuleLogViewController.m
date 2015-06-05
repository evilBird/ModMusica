//
//  YuleLogViewController.m
//  ModMusica
//
//  Created by Travis Henspeter on 12/21/14.
//  Copyright (c) 2014 birdSound. All rights reserved.
//

#import "YuleLogViewController.h"
#import "GPUImage.h"
#import "YuleLogAudioController.h"
#import "BSDFireShader.h"
#import "BSDKaleidoscopeFilter.h"

CGFloat time2rad(CGFloat time)
{
    NSInteger norm = (NSInteger)(time*100.0)%100;
    CGFloat bnorm = (CGFloat)norm * 0.01;
    return bnorm*3.14159*2.0;
}

CGFloat time2sine(CGFloat time)
{
    CGFloat rad = time2rad(time);
    return cos(rad);
}

CGFloat norm_sine(CGFloat sine)
{
    return (sine + 1.0) * 0.5;
}

CGFloat val4time(CGFloat time, CGFloat min, CGFloat max)
{
    CGFloat nsine = norm_sine(time2sine(time));
    CGFloat range = max-min;
    return min + (nsine * range);
}

@interface YuleLogViewController ()
{
    NSTimer *kAnimationTimer;
    NSTimeInterval kTime;
}


@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) YuleLogAudioController *audioController;

@property (strong, nonatomic) IBOutlet GPUImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet GPUImageView *foregroundImageView;
@property (strong, nonatomic) IBOutlet GPUImageView *kaleidoscopeImageView;

@property (strong, nonatomic) GPUImagePicture *backgroundPicture;
@property (strong, nonatomic) GPUImagePicture *foregroundPicture;
@property (strong, nonatomic) GPUImagePicture *kaleidoscopePicture;

@property (strong, nonatomic) GPUImageFilter *foregroundFilter;
@property (strong, nonatomic) GPUImageFilter *backgroundFilter;
@property (strong, nonatomic) BSDKaleidoscopeFilter *kaleidoscopeFilter;

- (IBAction)handleTapGesture:(id)sender;

@end

@implementation YuleLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.audioController = [[YuleLogAudioController alloc]init];
    [self setupBackgroundFilter];
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupForegroundFilter
{
    if (self.foregroundPicture) {
        [self.foregroundPicture removeAllTargets];
    }
    if (!self.foregroundFilter) {
        self.foregroundFilter = [[BSDFireShader alloc]init];
    }
    
    UIImage *image = [self imageFromLayer:self.view.layer];
    self.foregroundPicture = [[GPUImagePicture alloc]initWithImage:image];
    [self.foregroundFilter forceProcessingAtSize:self.foregroundPicture.outputImageSize];
    [self.foregroundPicture addTarget:self.foregroundFilter];
    [self.foregroundFilter useNextFrameForImageCapture];
    [self.foregroundFilter addTarget:self.foregroundImageView];
    [(BSDFireShader *)self.foregroundFilter setGlobalTime:0.0];
    [self.foregroundPicture processImage];
}

- (void)setupBackgroundFilter
{
    if (self.backgroundPicture) {
        [self.backgroundPicture removeAllTargets];
    }
    
    if (!self.backgroundFilter) {
        self.backgroundFilter = (GPUImageFilter *)[[GPUImageSmoothToonFilter alloc]init];
    }
    
    UIImage *image = [UIImage imageNamed:@"log5"];
    self.backgroundPicture = [[GPUImagePicture alloc]initWithImage:image];
    [self.backgroundFilter forceProcessingAtSize:self.backgroundPicture.outputImageSize];
    [self.backgroundPicture addTarget:self.backgroundFilter];
    [self.backgroundFilter useNextFrameForImageCapture];
    [self.backgroundFilter addTarget:self.backgroundImageView];
    [self.backgroundPicture processImage];
}

- (void)setupKaleidoscopeFilterWithImage:(UIImage *)image
{
    if (self.kaleidoscopePicture) {
        [self.kaleidoscopePicture removeAllTargets];
        if (!image) {
            image = [UIImage imageNamed:@"log5"];
        }
        self.kaleidoscopePicture = [[GPUImagePicture alloc]initWithImage:image smoothlyScaleOutput:YES];
        self.kaleidoscopeImageView.alpha = 0.2;
    }
    
    if (!self.kaleidoscopeFilter) {
        self.kaleidoscopeFilter = [[BSDKaleidoscopeFilter alloc]init];
        [self.kaleidoscopePicture addTarget:self.kaleidoscopeFilter];
        [self.kaleidoscopeFilter addTarget:self.kaleidoscopeImageView];
        [self.kaleidoscopeFilter forceProcessingAtSize:self.kaleidoscopePicture.outputImageSize];
        [self.kaleidoscopeFilter useNextFrameForImageCapture];
    }
    
    
}

- (void)incrementTimer
{
    kTime+=0.01;
    [(BSDFireShader *)self.foregroundFilter setGlobalTime:kTime * 3.33];
    self.foregroundImageView.alpha = val4time(kTime, 0.65, 0.85);
    [self.foregroundPicture processImage];
    
    [(GPUImageSmoothToonFilter *)self.backgroundFilter setThreshold:val4time(kTime*0.66, 0.15, 0.35)];
    [(GPUImageSmoothToonFilter *)self.backgroundFilter setQuantizationLevels:val4time(kTime*0.0833, 4, 20)];
    [self.backgroundPicture processImage];
}

- (IBAction)handleTapGesture:(id)sender {
    if (!self.foregroundFilter) {
        self.foregroundImageView.alpha = 0.0;
        [self setupForegroundFilter];
    }

    if (!self.audioController.isPlaying) {
        self.titleLabel.text = NSLocalizedString(@"Tap to stop", nil);
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                self.foregroundImageView.alpha = 0.65;
            }];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.51 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.audioController startPlayback];
            kAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:0.066 target:self selector:@selector(incrementTimer) userInfo:nil repeats:YES];
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.titleLabel.alpha = 0.0f;
        });
        
    }else{
        [self.audioController stopPlayback];
        [kAnimationTimer invalidate];
        kAnimationTimer = nil;
        kTime = 0.0;
        self.titleLabel.text = NSLocalizedString(@"Tap to play", nil);
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.2 animations:^{
                self.foregroundImageView.alpha = 0.0;
                self.titleLabel.alpha = 1.0;
            }];
        });
    }
}

- (UIImage *)imageFromLayer:(CALayer *)layer
{
    UIGraphicsBeginImageContext(layer.bounds.size);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
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
