//
//  BSOscilloscope.h
//  BirdStepperV.2
//
//  Created by Travis Henspeter on 5/1/13.
//  Copyright (c) 2013 Travis Henspeter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BSOscilloscope : UIView

@property(nonatomic)CGFloat lineWidth;
@property(nonatomic)CGFloat lineWidthRatio;
@property(nonatomic,strong) UIColor *mainColor;
@property(nonatomic,strong) UIColor *fadedColor1;
@property(nonatomic,strong) UIColor *fadedColor2;
@property(nonatomic,strong) UIColor *fadedColor3;
@property(nonatomic,strong) UIColor *fadedColor4;
@property(nonatomic,strong) UIBezierPath *currentPath;
@property(nonatomic,strong) UIBezierPath *previousPath1;
@property(nonatomic,strong) UIBezierPath *previousPath2;
@property(nonatomic,strong) UIBezierPath *previousPath3;
@property(nonatomic,strong) UIBezierPath *previousPath4;
@property(nonatomic)CGFloat animationDuration;
@property(nonatomic,getter = isAnimated)BOOL animated;
@property(nonatomic,getter = isRunning)BOOL running;
@property(nonatomic)CGFloat xOffset;
@property(nonatomic)CGFloat yOffset;
@property(nonatomic)NSInteger numberOfPoints;
@property(nonatomic)CGFloat rootMeanSquare;
@property (nonatomic)BOOL isDisplaying;

-(void)start;
-(void)stop;
-(void)displayData;

@end
