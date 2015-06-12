//
//  MMAudioScopeViewController+Label.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMAudioScopeViewController+Label.h"
#import "UIColor+HBVHarmonies.h"
#import "UIView+Layout.h"


static NSString *kLabelTextBase = @"press & hold to";
static NSString *kStart = @"start";
static NSString *kStop = @"stop";
static NSTimeInterval kTime = 10;

@implementation MMAudioScopeViewController (Label)

- (NSString *)defaultLabelText
{
    NSString *text = nil;
    if (self.isUpdating) {
        text = [NSString stringWithFormat:@"%@ %@",kLabelTextBase,kStop];
    }else{
        text = [NSString stringWithFormat:@"%@ %@",kLabelTextBase,kStart];
    }
    
    return text;
}

- (void)configureLabels
{
    self.label = [UILabel new];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    self.label.numberOfLines = 8;
    self.label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:[UIFont labelFontSize]];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.textColor = [[self.view.backgroundColor complement]jitterWithPercent:5];
    self.label.text = [self defaultLabelText];
    
    self.titleLabel = [UILabel new];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:[UIFont labelFontSize]*2.7];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [self.view.backgroundColor complement];
    self.titleLabel.text = NSLocalizedString(@"ModMusica", nil);
    self.titleLabel.contentMode = UIViewContentModeTop;
    
    self.nowPlayingLabel = [UILabel new];
    self.nowPlayingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.nowPlayingLabel.textAlignment = NSTextAlignmentCenter;
    self.nowPlayingLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:[UIFont labelFontSize]];
    self.nowPlayingLabel.textColor = [self.titleLabel.textColor jitterWithPercent:5];
    
    [self.contentView addSubview:self.label];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.nowPlayingLabel];
    
    [self showAll];
}

- (void)configureLabelConstraints
{
    [self.view addConstraint:[self.label alignCenterXToSuperOffset:0]];
    [self.view addConstraint:[self.label pinEdge:LayoutEdge_Bottom
                                          toEdge:LayoutEdge_Bottom
                                          ofView:self.view
                                       withInset:-20]];
    [self.view addConstraint:[self.titleLabel alignCenterXToSuperOffset:0]];
    
    [self.view addConstraint:[self.titleLabel pinEdge:LayoutEdge_Top
                                               toEdge:LayoutEdge_Top
                                               ofView:self.view
                                            withInset:20]];
    [self.view addConstraint:[self.nowPlayingLabel pinEdge:LayoutEdge_Top
                                                    toEdge:LayoutEdge_Bottom
                                                    ofView:self.titleLabel
                                                 withInset:8]];
    [self.view addConstraint:[self.nowPlayingLabel alignCenterXToSuperOffset:0]];
    
    [self.view layoutIfNeeded];
}

- (void)hideNowPlaying
{
    self.nowPlayingLabel.alpha = 0.0;
}

- (void)hideTitle
{
    self.titleLabel.alpha = 0.0;
}

- (void)hideLabel
{
    self.label.alpha = 0.0;
    self.label.text = [self defaultLabelText];
}

- (void)showStepsPerMinute
{
    NSString *text = [NSString stringWithFormat:@"%.f steps/min",self.stepsPerMinute];
    self.label.text = text;
    self.label.alpha = 1.0;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideLabel) object:nil];
    [self performSelector:@selector(hideLabel) withObject:nil afterDelay:kTime];
}

- (void)showBeatsPerMinute
{
    NSString *text = [NSString stringWithFormat:@"%.f beats/min",self.beatsPerMinute];
    self.label.text = text;
    self.label.alpha = 1.0;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideLabel) object:nil];
    [self performSelector:@selector(hideLabel) withObject:nil afterDelay:kTime];
}

- (void)showNowPlaying
{
    self.nowPlayingLabel.text = [NSString stringWithFormat:@"now playing: %@",self.nowPlaying];
    self.nowPlayingLabel.alpha = 1.0;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideNowPlaying) object:nil];
    [self performSelector:@selector(hideNowPlaying) withObject:nil afterDelay:kTime];
}


- (void)showAll
{
    self.titleLabel.alpha = 1.0;
    self.nowPlayingLabel.alpha = 1.0;
    self.label.text = [self defaultLabelText];
    self.label.alpha = 1.0;
    self.hamburgerButton.alpha = 0.8;
}

- (void)showAllForDuration:(NSTimeInterval)duration
{
    [self showAll];
    [self hideAllAfterDelay:duration];
}

- (void)hideAll
{
    self.titleLabel.alpha = 0.0;
    self.nowPlayingLabel.alpha = 0.0;
    self.label.alpha = 0.0;
    self.hamburgerButton.alpha = 0.0;
    self.label.text = [self defaultLabelText];
}

- (void)hideAllAfterDelay:(NSTimeInterval)duration
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideAll) object:nil];
    [self performSelector:@selector(hideAll) withObject:nil afterDelay:duration];
}


@end
