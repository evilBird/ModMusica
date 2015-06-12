//
//  MMAudioScopeViewController+Path.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/6/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMAudioScopeViewController+Path.h"

@implementation MMAudioScopeViewController (Path)


- (UIBezierPath *)pathWithScopeData:(NSArray *)data
{
    CGSize mySize = self.view.bounds.size;
    double x_scale = mySize.width/(double)data.count;
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint point = CGPointZero;
    point.y = self.view.bounds.size.height/2;
    [path moveToPoint:point];
    for (NSUInteger i = 0; i < data.count; i ++) {
        NSNumber *sample = data[i];
        float val = sample.floatValue * 1;
        double norm = (val+1.0 * 0.5);
        norm += (double)(arc4random_uniform(100) * 0.001);
        point.x = x_scale * (double)i;
        point.y = mySize.height - (norm * mySize.height);
        [path addLineToPoint:point];
    }
    point.x = self.view.bounds.size.width;
    point.y = self.view.bounds.size.height/2;
    [path addLineToPoint:point];
    
    return path;
}

@end