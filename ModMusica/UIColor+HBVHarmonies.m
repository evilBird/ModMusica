//
//  UIColor+HBVHarmonies.m
//  Herbivore
//
//  Created by Travis Henspeter on 3/5/14.
//  Copyright (c) 2014 Herbivore. All rights reserved.
//

#import "UIColor+HBVHarmonies.h"

@implementation UIColor (HBVHarmonies)

#pragma mark - Public methods

- (UIColor *)jitterWithPercent:(CGFloat)percent
{
    UIColor *result = nil;
    CGFloat newComponents[3];
    for (NSInteger index = 0; index < 3; index ++) {
        CGFloat oldComponent = CGColorGetComponents(self.CGColor)[index];
        CGFloat random = ((CGFloat)arc4random_uniform(200) - 100.0f) * 0.01;
        CGFloat newComponent = oldComponent + random * percent * 0.01;
        newComponents[index] = [UIColor clipValue:newComponent withMin:0 max:1.0f];
    }
    
    result = [UIColor colorWithRed:newComponents[0] green:newComponents[1] blue:newComponents[2] alpha:1.0];
    return result;
}

- (UIColor *)complement
{
    return [self colorHarmonyWithExpression:^CGFloat(CGFloat value) {
       return 1.0f - value;
    } alpha:1.0];
}

+ (UIColor *)randomColor
{
    CGFloat red = (CGFloat)arc4random_uniform(255)/255.0f;
    CGFloat green = (CGFloat)arc4random_uniform(255)/255.0f;
    CGFloat blue = (CGFloat)arc4random_uniform(255)/255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

- (UIColor *)colorHarmonyWithExpression:(CGFloat(^)(CGFloat value))expression alpha:(CGFloat)alpha
{
    UIColor *result = nil;
    CGFloat newComponents[3];
    for (NSInteger index = 0; index < 3; index ++) {
        CGFloat oldComponent = CGColorGetComponents(self.CGColor)[index];
        CGFloat expressionResult = expression(oldComponent);
        newComponents[index] = [UIColor clipValue:expressionResult withMin:0 max:1.0f];
    }
    
    result = [UIColor colorWithRed:newComponents[0] green:newComponents[1] blue:newComponents[2] alpha:alpha];
    return result;
}

- (UIColor *)colorHarmonyWithExpressionOnComponents:(CGFloat*(^)(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha))componentsExpression;
{
    UIColor *result = nil;
    CGFloat oldComponents[4];
    for (NSInteger index = 0; index < 4; index ++) {
        CGFloat oldComponent = CGColorGetComponents(self.CGColor)[index];
        oldComponents[index] = oldComponent;
    }
    
    CGFloat *expressionResult = malloc(sizeof(CGFloat) * 4);
    expressionResult = componentsExpression(oldComponents[0],oldComponents[1],oldComponents[2],oldComponents[3]);
    CGFloat newComponents[4];
    for (NSInteger index = 0; index < 4; index ++) {
        newComponents[index] = [UIColor clipValue:expressionResult[index] withMin:0.0 max:1.0];
    }
    
    result = [UIColor colorWithRed:newComponents[0] green:newComponents[1] blue:newComponents[2] alpha:newComponents[3]];
    return result;
}

- (UIColor *)colorHarmonyWithComponentArray:(NSArray*(^)(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha))componentsExpression
{
    UIColor *result = nil;
    CGFloat oldComponents[4];
    for (NSInteger index = 0; index < 4; index ++) {
        CGFloat oldComponent = CGColorGetComponents(self.CGColor)[index];
        oldComponents[index] = oldComponent;
    }
    
    NSArray *expressionResult = componentsExpression(oldComponents[0],oldComponents[1],oldComponents[2],oldComponents[3]);
    CGFloat newComponents[4];
    for (NSInteger index = 0; index < expressionResult.count; index++) {
        newComponents[index] = [expressionResult[index] doubleValue];
    }
    
    result = [UIColor colorWithRed:newComponents[0] green:newComponents[1] blue:newComponents[2] alpha:newComponents[3]];
    return result;
}

- (UIColor *)adjustAlpha:(CGFloat)alpha
{
    UIColor *result = nil;
    CGFloat newComponents[4];
    for (NSInteger index = 0; index < 3; index ++) {
        CGFloat newComponent = CGColorGetComponents(self.CGColor)[index];
        newComponents[index] = newComponent;
    }
    
    newComponents[3] = alpha;
    result = [UIColor colorWithRed:newComponents[0] green:newComponents[1] blue:newComponents[2] alpha:newComponents[3]];
    return result;
}

#pragma mark - Private methods

+ (CGFloat)clipValue:(CGFloat)value withMin:(CGFloat)min max:(CGFloat)max
{
    CGFloat result;
    if (value < min) {
        result = min;
    } else if (value > max) {
        result = max;
    } else {
        result = value;
    }
    return result;
}

- (UIColor *)blendColor1:(UIColor *)color1 withColor2:(UIColor *)color2 usingExpression:(CGFloat*(^)(CGFloat color1[],CGFloat color2[]))expression
{
    CGFloat color1Components[4];
    CGFloat color2Components[4];
    
    for (NSInteger i = 0; i < 4; i ++) {
        color1Components[i] = CGColorGetComponents(color1.CGColor)[i];
        color2Components[i] = CGColorGetComponents(color2.CGColor)[i];
    }
    
    CGFloat newComponents[4];
    for (NSInteger i = 0; i < 4; i++) {
        newComponents[i] = expression(color1Components,color2Components)[i];
    }
    UIColor *result = nil;
    
    result = [UIColor colorWithRed:newComponents[0] green:newComponents[1] blue:newComponents[2] alpha:newComponents[3]];
    
    return result;
}

@end
