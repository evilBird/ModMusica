//
//  KaleidoscopeViewController.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/5/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "KaleidoscopeViewController.h"
#import "BSDKaleidoscopeFilter.h"

@interface KaleidoscopeViewController ()

@end

@implementation KaleidoscopeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (GPUImageFilter *)makeFilter
{
    return [[BSDKaleidoscopeFilter alloc]init];
}

- (UIImage *)initialSourceImage
{
    return [UIImage imageNamed:@"Icon"];
}

- (void)playback:(id)sender clockDidChange:(NSInteger)clock
{
    BSDKaleidoscopeFilter *k = (BSDKaleidoscopeFilter *)self.filter;
    k.sides = arc4random_uniform(16)+1;
    k.tau = clock%2 + 2;
    [self processImage];
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
