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

//Contains the tag of the currently selected pitch in each step, if there is one, else value is -1.
@property (nonatomic,strong)            NSMutableArray              *stepPitchTags;
@property (nonatomic)                   NSUInteger                  minPitch;
@property (nonatomic)                   NSUInteger                  maxPitch;

@end

@implementation ModMelodyEditorViewController

- (void)setupStepPitchTags
{
    if (!self.datasource) {
        return;
    }
    
    NSMutableArray *temp = [NSMutableArray array];
    NSArray *allData = [self.datasource patternData];
    if (!allData) {
        return;
    }
    
    NSMutableArray *rawData = [allData[[self.datasource currentVoiceIndex]]mutableCopy];
    [rawData removeObjectAtIndex:0];
    
    NSArray *data = [NSArray arrayWithArray:rawData];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"self > 0"];
    NSArray *filteredData = [data filteredArrayUsingPredicate:pred];
    
    NSNumber *min = [filteredData valueForKeyPath:@"@min.self"];
    self.minPitch = min.unsignedIntegerValue;
    NSNumber *max = [data valueForKeyPath:@"@max.self"];
    self.maxPitch = max.unsignedIntegerValue;
    
    NSAssert(data.count == [self.datasource numSteps], @"num steps %@ doesn't match pattern length %@",@(data.count),@([self.datasource numSteps]));
    
    NSEnumerator *dataEnum = data.objectEnumerator;
    
    for (NSUInteger i = 0; i < [self.datasource numSteps]; i++) {
        NSNumber *data = [dataEnum nextObject];
        if (!data || !data.integerValue) {
            temp[i] = @(-1);
        }else{
            NSUInteger pitch = [self.datasource numPitches] - 1 - ((data.unsignedIntegerValue - self.minPitch)%[self.datasource numPitches]);
            
            NSUInteger tag = pitch * [self.datasource numSteps] + i;
            temp[i] = @(tag);
        }
    }
    
    self.stepPitchTags = temp;
}

- (void)setupWithDelegate:(id<ModMelodyEditorViewControllerDelegate>)delegate
               datasource:(id<ModEditorDatasource>)datasource
               completion:(void(^)(void))completion
{
    self.datasource = datasource;
    self.delegate = delegate;
    if (self.datasource) {
        __weak ModMelodyEditorViewController *weakself = self;
        [self setupStepPitchTags];
        dispatch_async(dispatch_get_main_queue(),^{
            [weakself commonInitCompletion:^{
                if (completion) {
                    completion();
                }
            }];
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

- (void)setMainColor:(UIColor *)mainColor;
{
    _mainColor = mainColor;
    self.view.backgroundColor = mainColor;
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

- (UIColor *)myMainColor
{
    return [self.mainColor complement];
}

- (void)melodyEditor:(id)sender stepSwitch:(id)stepSwitch valueDidChange:(id)value
{
    ModMelodyEditorSwitch *theSwitch = stepSwitch;
    NSUInteger stepIndex = (NSUInteger)((int)theSwitch.tag)%((int)[self.datasource numSteps]);
    NSUInteger val = [value unsignedIntegerValue];
    if (val) {
        NSNumber *oldTag = self.stepPitchTags[stepIndex];
        if (oldTag.integerValue != -1 && oldTag.integerValue!=theSwitch.tag) {
            ModMelodyEditorSwitch *oldSwitch = self.pitchView.switches[oldTag.unsignedIntegerValue];
            oldSwitch.value = 0;
        }
        self.stepPitchTags[stepIndex] = @(theSwitch.tag);
    }else{
        self.stepPitchTags[stepIndex] = @(-1);
    }
    
    [self updatePatternWithTags:self.stepPitchTags];
}

- (NSUInteger)initialValueForSwitchWithTag:(NSUInteger)tag
{
    NSUInteger stepIndex = (NSUInteger)((int)tag)%((int)[self.datasource numSteps]);
    NSNumber *oldTag = self.stepPitchTags[stepIndex];
    if (tag == oldTag.unsignedIntegerValue) {
        return 1;
    }
    return 0;
}

- (void)updatePatternWithTags:(NSArray *)tags
{
    NSMutableArray *temp = [NSMutableArray array];
    __block NSUInteger i = 0;
    for (NSNumber *aTag in tags.mutableCopy) {
        NSInteger tagVal = aTag.integerValue;
        NSUInteger dataVal = [self.datasource numPitches] - 1 - (NSUInteger)((int)tagVal%((int)[self.datasource numPitches]));
        NSUInteger newPitch = self.minPitch + dataVal;
        [temp addObject:@(newPitch)];
        i++;
    }
    
    [self.datasource updatePatternData:temp];
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
