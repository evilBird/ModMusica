//
//  MMModEditorViewController.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/29/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ModMelodyEditorViewController.h"
#import "ModMelodyEditorViewController+Setup.h"
#import "ModMelodyEditorViewController+Controls.h"
#import "ModMelodyEditorViewController+Switches.h"
#import "ModMelodyEditorViewController+Data.h"
#import "ModMelodyEditorViewController+Util.h"

@interface ModMelodyEditorViewController () 
{
    BOOL kInitialized;
}

@end

@implementation ModMelodyEditorViewController

- (BOOL)setupViewsAndData
{
    if (!self.datasource || !self.delegate) {
        return NO;
    }
    
    [self setupStepPitchTags];
    [self.pitchView configureWithDelegate:self datasource:self.datasource];
    
    return YES;
}

- (void)setMainColor:(UIColor *)mainColor;
{
    _mainColor = mainColor;
    self.view.backgroundColor = mainColor;
    [self updateButtonColors];
}

- (void)setDatasource:(id<ModEditorDatasource>)datasource
{
    _datasource = datasource;
    if (!kInitialized) {
        kInitialized = [self setupViewsAndData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    kInitialized = NO;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateButtonColors];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)stepPitchTagsDidChange
{
    NSArray *newData = [self editedData];
    [self printNew:newData old:[self getSavedData]];
    [self.delegate updatePatternData:newData atVoiceIndex:[self.delegate currentVoiceIndex]];
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
