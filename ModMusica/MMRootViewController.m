//
//  BlameViewController.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/23/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMRootViewController.h"
#import "MMModuleViewController.h"
#import "MyGLKViewController.h"
#import "MMRootViewController+Mods.h"
#import "MMRootViewController+Touches.h"
#import "MMStepCounter.h"


@interface MMRootViewController ()

@property (nonatomic,strong)            MMStepCounter           *stepCounter;

@end

@implementation MMRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.paneViewController = [storyboard instantiateViewControllerWithIdentifier:@"MyGLKViewController"];
    MMModuleViewController *mm =[storyboard instantiateViewControllerWithIdentifier:@"DrawerViewController"];
    mm.delegate = self;
    mm.datasource = self;
    [self setDrawerViewController:mm forDirection:MSDynamicsDrawerDirectionLeft];
    [(MyGLKViewController *)self.paneViewController setCurrentModName:@"mario"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MyGLKViewController *)getGLKViewController
{
    return (MyGLKViewController *)(self.paneViewController);
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
