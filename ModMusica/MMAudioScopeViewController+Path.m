//
//  MMAudioScopeViewController+Path.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/6/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMAudioScopeViewController+Path.h"

@implementation MMAudioScopeViewController (Path)

- (NSArray *)setupPathBuffers:(NSInteger)count
{
    NSMutableArray *oldPaths = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < count; i ++) {
        [oldPaths addObject:[UIBezierPath bezierPath]];
    }
    
    return oldPaths;
}

- (UIBezierPath *)pathWithScopeData:(NSArray *)data
{
    CGSize mySize = self.view.bounds.size;
    double x_scale = mySize.width/(double)data.count;
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint point = CGPointZero;
    point.y = self.view.bounds.size.height/2;
    [path moveToPoint:point];
    double sum = 0;
    for (NSUInteger i = 0; i < data.count; i ++) {
        NSNumber *sample = data[i];
        float val = sample.floatValue * 0.8333;
        double norm = (val+1.0 * 0.5);
        sum+=val;
        point.x = x_scale * (double)i;
        point.y = mySize.height - (norm * mySize.height);
        

        [path addLineToPoint:point];
    }
    point.x = self.view.bounds.size.width;
    point.y = self.view.bounds.size.height/2;
    [path addLineToPoint:point];
    
    if (sum == 0) {
        return nil;
    }
    
    return path;
}

@end