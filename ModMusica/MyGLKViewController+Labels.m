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

@interface MyGLKViewController ()


@end

@implementation MyGLKViewController (Labels)

- (void)updateLabelText
{
    
    self.titleLabel.text = @"ModMusica";
    
    NSString *playingString = nil;
    if (self.currentModName && self.currentModName.length) {
        NSString *verbString = nil;
        if (self.isPlaying) {
            verbString = @"playing ";
        }else{
            verbString = @"";
        }
        
        playingString = [NSString stringWithFormat:@"%@%@",verbString,self.currentModName];
        
    }else{
        playingString = @"headphones recommended";
    }
    
    self.nowPlayingLabel.text = playingString;
    
    if (self.isPlaying) {
        if (self.tempo > 0) {
            self.infoLabel.numberOfLines = 4;
            self.infoLabel.text = [NSString stringWithFormat:@"%.f beats per minute\ntap to set tempo",self.tempo];
        }else{
            self.infoLabel.text = @"Press and hold to stop";
        }
    }else{
        self.infoLabel.text = @"Press and hold to start";
    }

    
    [self.titleLabel sizeToFit];
    [self.nowPlayingLabel sizeToFit];
    [self.infoLabel sizeToFit];
    [self.view layoutIfNeeded];
    [self.view setNeedsDisplay];
    
}

- (void)updateLabelColors
{
    if (self.mainColor==nil){
        self.mainColor = [UIColor randomColor];
    }
    
    self.nowPlayingLabel.textColor = [self.mainColor complement];
    self.titleLabel.textColor = [self.mainColor complement];
    self.infoLabel.textColor = [self.mainColor complement];
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
    __weak MyGLKViewController *weakself = self;
    [UIView animateWithDuration:5.0
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         weakself.titleLabel.alpha = 0.0;
                         weakself.infoLabel.alpha = 0.0;
                         weakself.nowPlayingLabel.alpha = 0.0;
                         weakself.hamburgerButton.alpha = 0.0;
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
    __weak MyGLKViewController *weakself = self;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         weakself.titleLabel.alpha = 1.0;
                         weakself.infoLabel.alpha = 1.0;
                         weakself.nowPlayingLabel.alpha = 1.0;
                         weakself.hamburgerButton.alpha = 1.0;
                     } completion:nil];
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
    self.titleLabel.text = @"";
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:[UIFont labelFontSize]*1.8];
    [self.view addSubview:self.titleLabel];
    
    self.nowPlayingLabel = [UILabel new];
    self.nowPlayingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.nowPlayingLabel.text = @"";
    self.nowPlayingLabel.textAlignment = NSTextAlignmentCenter;
    self.nowPlayingLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:[UIFont labelFontSize]*0.8];
    [self.view addSubview:self.nowPlayingLabel];
    
    self.infoLabel = [UILabel new];
    self.infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.infoLabel.text = @"";
    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    self.infoLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:[UIFont labelFontSize]*0.6];
    [self.view addSubview:self.infoLabel];
    
    [self setupLabelConstraints];
}

@end
