//
//  MMModEditorViewController.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/29/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ModMelodyEditorViewController.h"
#import "ModMelodyEditorViewController+Layout.h"
#import "ModMelodyEditorViewController+Setup.h"
#import "ModMelodyEditorViewController+Controls.h"
#import "ModMelodyEditorSwitch.h"
#import "UIColor+HBVHarmonies.h"

@interface ModMelodyEditorViewController () 


@end

@implementation ModMelodyEditorViewController

- (void)setupWithDatasource:(id<ModEditorDatasource>)datasource completion:(void(^)(void))completion
{
    self.datasource = datasource;
    if (self.datasource) {
        __weak ModMelodyEditorViewController *weakself = self;
        dispatch_async(dispatch_get_main_queue(),^{
            [weakself commonInitCompletion:completion];
        });
    }
}

- (void)commonInitCompletion:(void(^)(void))completion;
{
    [self setupViews];
    self.pitchView.delegate = self;
    [self configureConstraints];
    if (completion) {
        completion();
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ModMelodyEditorStepPitchViewDelegate

- (UIColor *)mainColor
{
    return [UIColor orangeColor];
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
