//
//  MMTapGestureRecognizer.m
//  ModMusica
//
//  Created by Travis Henspeter on 7/7/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMTapGestureRecognizer.h"
#import "MMLongPressGestureRecognizer.h"

static void * XXContext = &XXContext;

@interface MMTapGestureRecognizer () <UIGestureRecognizerDelegate>

@property (nonatomic)               NSUInteger                          taps;
@property (nonatomic,strong)        NSDate                              *prevDate;

@end

@implementation MMTapGestureRecognizer

- (instancetype)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if (self) {
        _taps = 0;
        self.delegate = self;
        [self addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:XXContext];
        
    }
    return self;
}

- (NSUInteger)tapCount
{
    return self.taps;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer isKindOfClass:[MMLongPressGestureRecognizer class]] || [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return NO;
    }
    
    return YES;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == XXContext) {
        NSNumber *value = change[@"new"];
        NSDate *now = [NSDate date];
        if (value.integerValue == 3) {
            if (self.prevDate) {
                NSTimeInterval time = [now timeIntervalSinceDate:self.prevDate];
                if (time > 5.0) {
                    self.taps = 0;
                }
            }
            
            self.taps++;
            self.prevDate = now;

        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"state" context:XXContext];
    
}

@end
