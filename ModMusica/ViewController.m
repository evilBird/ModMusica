//
//  ViewController.m
//  ModMusica
//
//  Created by Travis Henspeter on 10/27/14.
//  Copyright (c) 2014 birdSound. All rights reserved.
//

#import "ViewController.h"
#import "MMPlaybackController.h"

@interface ViewController ()

@property (nonatomic,strong)        MMPlaybackController            *playbackController;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.playbackController = [[MMPlaybackController alloc]init];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches began in vc");
}


@end
