//
//  MyGLKViewController+Labels.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/19/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "UIView+Layout.h"
#import "MyGLKViewController+Labels.h"
#import "UIColor+HBVHarmonies.h"

@implementation MyGLKViewController (Labels)

static NSTimer *infoLabelTimer;

- (void)handleLabelUpdateTimer:(id)sender
{
    NSTimer *timer = sender;
    [timer invalidate];
}

- (void)handleInfoLabelTimer:(id)sender
{
    [self hideLabelsAnimated:YES];
    [infoLabelTimer invalidate];
}

- (void)showTempoInfo:(NSString *)tempoInfo
{
    self.infoLabel.text = tempoInfo;
    if (infoLabelTimer.isValid) {
        [infoLabelTimer invalidate];
    }else{
        [self showLabelsAnimated:NO];
    }
    
    infoLabelTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                      target:self
                                                    selector:@selector(handleInfoLabelTimer:)
                                                    userInfo:nil
                                                     repeats:NO];
}

- (void)updateLabelText
{
    NSString *nowPlayingString = [NSString stringWithFormat:@"Now playing: %@",self.currentModName];
    self.nowPlayingLabel.text = nowPlayingString;
    self.titleLabel.text = @"ModMusica";
    if (self.isPlaying) {
        self.infoLabel.text = @"Press and hold to stop";
    }else{
        self.infoLabel.text = @"Press and hold to start";
    }

}

- (void)updateLabelColors
{
    if (self.mainColor!=nil){
        self.nowPlayingLabel.textColor = [self.mainColor complement];
        self.titleLabel.textColor = [self.mainColor complement];
        self.infoLabel.textColor = [self.mainColor complement];
    }
}

- (void)hideLabelsAnimated:(BOOL)animated
{
    if (!animated) {
        self.titleLabel.alpha = 0.0;
        self.infoLabel.alpha = 0.0;
        self.nowPlayingLabel.alpha = 0.0;
        self.hamburgerButton.alpha = 0.0;
        return;
    }
    
    [UIView animateWithDuration:7.0
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.titleLabel.alpha = 0.0;
                         self.infoLabel.alpha = 0.0;
                         self.nowPlayingLabel.alpha = 0.0;
                         self.hamburgerButton.alpha = 0.0;
                     } completion:nil];
}

- (void)showLabelsAnimated:(BOOL)animated
{
    if (!animated) {
        self.titleLabel.alpha = 1.0;
        self.infoLabel.alpha = 1.0;
        self.nowPlayingLabel.alpha = 1.0;
        self.hamburgerButton.alpha = 1.0;
        return;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.titleLabel.alpha = 1.0;
        self.infoLabel.alpha = 1.0;
        self.nowPlayingLabel.alpha = 1.0;
        self.hamburgerButton.alpha = 1.0;
    }];
}

- (void)setupLabelConstraints
{
    [self.view addConstraint:[self.titleLabel alignCenterXToSuperOffset:0]];
    [self.view addConstraint:[self.titleLabel pinEdge:LayoutEdge_Top
                                               toEdge:LayoutEdge_Top
                                               ofView:self.view
                                            withInset:20]];
    [self.view addConstraint:[self.nowPlayingLabel alignCenterXToSuperOffset:0]];
    [self.view addConstraint:[self.nowPlayingLabel pinEdge:LayoutEdge_Top
                                                    toEdge:LayoutEdge_Bottom
                                                    ofView:self.titleLabel
                                                 withInset:6]];
    [self.view addConstraint:[self.infoLabel alignCenterXToSuperOffset:0]];
    [self.view addConstraint:[self.infoLabel pinEdge:LayoutEdge_Bottom
                                              toEdge:LayoutEdge_Bottom
                                              ofView:self.view
                                           withInset:-20]];
    
    [self.view layoutIfNeeded];
}

- (void)setupLabels
{
    self.titleLabel = [UILabel new];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.text = @"ModMusica";
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:[UIFont labelFontSize]*1.8];
    [self.view addSubview:self.titleLabel];
    
    self.nowPlayingLabel = [UILabel new];
    self.nowPlayingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.nowPlayingLabel.text = @"Now playing: Mario";
    self.nowPlayingLabel.textAlignment = NSTextAlignmentCenter;
    self.nowPlayingLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:[UIFont smallSystemFontSize]];
    [self.view addSubview:self.nowPlayingLabel];
    
    self.infoLabel = [UILabel new];
    self.infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.infoLabel.text = @"Press and hold to start";
    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    self.infoLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:[UIFont smallSystemFontSize]];
    [self.view addSubview:self.infoLabel];
    
    [self setupLabelConstraints];
}

@end
