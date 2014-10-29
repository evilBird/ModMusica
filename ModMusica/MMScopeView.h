//
//  MMScopeView.h
//  ModMusica
//
//  Created by Travis Henspeter on 10/27/14.
//  Copyright (c) 2014 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MMScopeViewDelegate <NSObject>

@end

@interface MMScopeView : UIView

@property(nonatomic)CGFloat lineWidth;
@property(nonatomic)CGFloat animateDuration;

- (void)animateLineDrawingWithPoints:(NSArray *)points width:(CGFloat)lineWidth color:(UIColor *)lineColor duration:(NSTimeInterval)duration index:(NSInteger)index;

@end
