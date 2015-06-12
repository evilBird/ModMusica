//
//  MMScopeDepthManager.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/11/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MMScopeDepthManagerDelegate <NSObject>

- (double)animationDuration;
- (double)minZPosition;
- (double)maxZPosition;
- (NSArray *)shapeLayersForDepthManager:(id)sender;
- (void)depthManager:(id)sender animateLayerAtIndex:(NSUInteger)index;

@end

@interface MMScopeDepthManager : NSObject

@property (nonatomic,weak)                  id<MMScopeDepthManagerDelegate>     delegate;
@property (nonatomic,getter=isUpdating)     BOOL                                updating;

- (instancetype)initWithDelegate:(id<MMScopeDepthManagerDelegate>)delegate;
- (void)startUpdates;
- (void)endUpdates;

@end
