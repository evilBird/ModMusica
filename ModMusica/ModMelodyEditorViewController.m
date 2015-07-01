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

- (void)loadDataForVoiceAtIndex:(NSUInteger)voiceIndex
{
    [self setupStepPitchTags:[self getSavedDataVoice:voiceIndex]];
}

- (NSArray *)getSavedData
{
    return [self getSavedDataVoice:[self.datasource currentVoiceIndex]];
}

- (NSArray *)getSavedDataVoice:(NSUInteger)voiceIndex
{
    if (!self.datasource) {
        return nil;
    }
    
    NSArray *allData = [self.datasource patternData];
    if (!allData) {
        return nil;
    }
    
    NSMutableArray *rawData = [allData[voiceIndex]mutableCopy];
    [rawData removeObjectAtIndex:0];
    NSArray *data = [NSArray arrayWithArray:rawData];
    
    return data;
}

- (NSUInteger)maxPitchInData:(NSArray *)data
{
    NSNumber *max = [data valueForKeyPath:@"@max.self"];
    return max.unsignedIntegerValue;
}

- (NSUInteger)minPitchInData:(NSArray *)data
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"self > 0"];
    NSArray *filteredData = [data filteredArrayUsingPredicate:pred];
    NSNumber *min = [filteredData valueForKeyPath:@"@min.self"];
    return min.unsignedIntegerValue;
}

- (void)setupStepPitchTags
{
    [self setupStepPitchTags:[self getSavedData]];
}

- (void)setupStepPitchTags:(NSArray *)data
{
    self.minPitch = [self minPitchInData:data];
    self.maxPitch = [self maxPitchInData:data];
    self.stepPitchTags = [self stepPitchTagsWithData:data].mutableCopy;
}

- (NSInteger)switchIndexFromPitch:(NSUInteger)pitch step:(NSUInteger)step
{
    if (pitch == 0) {
        return -1;
    }
    
    NSUInteger offsetPitch = pitch - self.minPitch;
    NSUInteger maxRow = [self.datasource numPitches] - 1;
    NSUInteger reflectedPitch = maxRow - offsetPitch;
    NSUInteger switchIndex = reflectedPitch * [self.datasource numSteps] + step;
    return switchIndex;
}

- (NSInteger)pitchFromSwitchIndex:(NSInteger)index step:(NSUInteger)step
{
    if (index < 0) {
        return 0;
    }
    
    NSInteger row = index/[self.datasource numSteps];
    NSUInteger maxRow = [self.datasource numPitches] - 1;
    NSUInteger reflectedRow = maxRow - row;
    NSUInteger offsetPitch = reflectedRow + self.minPitch;

    return offsetPitch;
}

- (NSArray *)stepPitchTagsWithData:(NSArray *)data
{
    NSAssert(data.count == [self.datasource numSteps], @"num steps %@ doesn't match pattern length %@",@(data.count),@([self.datasource numSteps]));
    
    NSMutableArray *temp = [NSMutableArray array];
    NSEnumerator *dataEnum = data.objectEnumerator;
    
    for (NSUInteger i = 0; i < [self.datasource numSteps]; i++) {
        NSNumber *data = [dataEnum nextObject];
        
        if (!data) {
            temp[i] = @(-1);
        }else{
            NSInteger index = [self switchIndexFromPitch:data.integerValue step:i];
            temp[i] = @(index);
        }
    }
    
    return temp;
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
    NSUInteger i = 0;
    for (NSNumber *aTag in tags.mutableCopy) {
        NSInteger tagVal = aTag.integerValue;
        NSUInteger newPitch = [self pitchFromSwitchIndex:tagVal step:i];
        [temp addObject:@(newPitch)];
        i++;
    }
    
    [self printNew:temp old:[self getSavedData]];
    [self.datasource updatePatternData:temp];
}

- (void)printNew:(NSArray *)newData old:(NSArray *)oldData
{
    NSMutableString *log = [[NSMutableString alloc]initWithString:@"\nPRINT DATA\n"];
    NSEnumerator *newDataEnumerator = newData.objectEnumerator;
    for (NSNumber *oldPitch in oldData) {
        NSNumber *newPitch = [newDataEnumerator nextObject];
        NSString *appendToLog = [NSString stringWithFormat:@"\n%@ -> %@",oldPitch,newPitch];
        [log appendString:appendToLog];
    }
    
    NSLog(@"%@\n",log);
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
