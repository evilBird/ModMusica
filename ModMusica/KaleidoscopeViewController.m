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

- (UIImage *)baseImage
{
    return [UIImage imageNamed:@"Icon"];
}

- (void)playback:(id)sender clockDidChange:(NSInteger)clock
{
    if (clock%4 == 0) {
        BSDKaleidoscopeFilter *k = (BSDKaleidoscopeFilter *)self.filter;
        k.sides = clock%6 + 2;
        k.tau = (clock%4)/4;
        [self setupFilter];
    }
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
