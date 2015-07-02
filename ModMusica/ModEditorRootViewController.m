//
//  ModEditorRootViewController.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/30/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ModEditorRootViewController.h"
#import "ModMelodyEditorViewController.h"
#import "UIColor+HBVHarmonies.h"

@interface ModEditorRootViewController ()

- (IBAction)tapInCloseButton:(id)sender;

- (IBAction)tapInEditButton:(id)sender;

@property (nonatomic)               NSUInteger          currentVoice;

@end

@implementation ModEditorRootViewController

- (void)setMainColor:(UIColor *)mainColor
{
    _mainColor = mainColor;
    self.view.backgroundColor = mainColor;
    [self updateButtonColors];
}

- (void)updateButtonColors
{
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            button.backgroundColor = [self.mainColor complement];
            button.layer.cornerRadius = 4;
            [button setTitleColor:self.mainColor forState:UIControlStateNormal];
        }
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ModMelodyEditorViewController *dest = segue.destinationViewController;
    dest.mainColor = self.mainColor;
    dest.delegate = self;
    dest.datasource = self.datasource;
}

- (IBAction)tapInCloseButton:(id)sender {
    
    [self.delegate editorShouldClose:self completion:nil];
}

- (IBAction)tapInEditButton:(id)sender {
    
    UIButton *button = sender;
    self.currentVoice = button.tag;
    [self performSegueWithIdentifier:@"ShowPitchEditorSegue" sender:self];
}

#pragma mark - ModEditorViewControllerDelegate
- (void)editor:(id)sender playbackChanged:(float)playback
{
    [self.delegate editor:self playbackChanged:playback];
}

- (void)editorDidSave:(id)sender
{
    
}

- (void)editorDidRevertToSaved:(id)sender
{
    ModMelodyEditorViewController *editor = sender;
}

- (void)editorShouldClose:(id)sender completion:(void(^)(void))completion
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updatePatternData:(NSArray *)patternData atVoiceIndex:(NSUInteger)voiceIndex
{
    [self.delegate updatePatternData:patternData atVoiceIndex:voiceIndex];
}

- (NSUInteger)currentVoiceIndex{
    return self.currentVoice;
}

@end
