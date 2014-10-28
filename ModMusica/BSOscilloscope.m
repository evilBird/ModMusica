//
//  BSOscilloscope.m
//  BirdStepperV.2
//
//  Created by Travis Henspeter on 5/1/13.
//  Copyright (c) 2013 Travis Henspeter. All rights reserved.
//

#import "BSOscilloscope.h"
#import "PdBase.h"
#import <QuartzCore/QuartzCore.h>


@interface BSOscilloscope ()

@property(nonatomic,strong) NSMutableArray *points;
@property(nonatomic)CGFloat norm;
@property(nonatomic,strong) NSTimer *transformTimer;
@property(nonatomic,strong) NSMutableArray *renderOrder;

@end

typedef void (^Render)(void);



@implementation BSOscilloscope

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self initialize];
        
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self initialize];
    }
    
    return self;
}



-(void)initialize
{
    _lineWidthRatio = 1.2;
    self.numberOfPoints = 50;
    self.renderOrder = [@[@0,@1,@2,@3]mutableCopy];
    
    if (!self.animationDuration) {
        self.animationDuration = 0.3f;
    }

}

-(void)start{
    /*
    if (!self.timer) {
        
        //self.timer = [NSTimer scheduledTimerWithTimeInterval:self.animationDuration target:self selector:@selector(displayData) userInfo:nil repeats:YES];
    }
    if (!self.timer.isValid) {
        //[self.timer fire];
    }
     */
    self.running = YES;
    NSInteger arraySize = [PdBase arraySizeForArrayNamed:@"scopeArray"];
    NSLog(@"array size: %d",(int)arraySize);
}

-(void)stop{
    
    //[self.timer invalidate];
    //self.timer = nil;
    self.running = NO;
    [PdBase sendBangToReceiver:@"clearScope"];
    [self setNeedsDisplay];
    
}

-(void)setAnimated:(BOOL)animated
{
    
    _animated = animated;
    
    if (animated) {
        
        self.previousPath1 = [UIBezierPath bezierPath];
        self.previousPath2 = [UIBezierPath bezierPath];
        self.previousPath3 = [UIBezierPath bezierPath];
        self.previousPath4 = [UIBezierPath bezierPath];
    }else{
        
        self.previousPath1 = nil;
        self.previousPath2 = nil;
        self.previousPath3 = nil;
        self.previousPath4 = nil;
        
    }
    
    
    
}

-(void)setLineWidth:(CGFloat)lineWidth
{
    
    _lineWidth = lineWidth;
    //self.layer.borderWidth = lineWidth;
    
    
}

-(void)setMainColor:(UIColor *)mainColor
{
    
    _mainColor = mainColor;
    //self.layer.borderColor = mainColor.CGColor;
    
}

- (void)setIsDisplaying:(BOOL)isDisplaying
{
    _isDisplaying = isDisplaying;
    

}

-(void)displayData{
    
    
    [PdBase sendBangToReceiver:@"updateScope"];
    
    NSInteger scopeArrayLength = [PdBase arraySizeForArrayNamed:@"scopeArray"];
    NSInteger stepSize = 1;
    NSInteger array1Len = 0;

    if (scopeArrayLength>self.numberOfPoints) {
        
        array1Len = self.numberOfPoints;
        stepSize = scopeArrayLength/self.numberOfPoints;
        
        
    }else{
        
        array1Len = scopeArrayLength;
        stepSize = 1;
    }
    
    CGFloat x_increment = self.frame.size.width/(array1Len-1);
    CGFloat height = self.bounds.size.height;
    __block NSMutableArray *newPoints = [NSMutableArray array];
    
    void (^getDataAndDraw)(void)= ^(void){
        
        static CGFloat scale;
        if (scale == 0.0f) {
            scale = 1.0f;
        }
        static BOOL getSmall;
        if (!getSmall) {
            scale += 0.001;
        }else {
            scale -= 0.001f;
        }
        
        if (scale <= 1.0f) {
            getSmall = NO;
        }
        if (scale >= 4.0f) {
            getSmall = YES;
        }
        
        self.norm = scale/3.0f;
        
        CGFloat sampledPoints[array1Len];
                
        if (scopeArrayLength>array1Len) {
            
            CGFloat allPoints[scopeArrayLength];
            
            [PdBase copyArrayNamed:@"scopeArray" withOffset:0 toArray:allPoints count:scopeArrayLength];
            
            for (NSInteger i = 0; i< array1Len ; i++) {
                
                sampledPoints[i] = allPoints[i*stepSize];
                
            }

        }else{
            
            [PdBase copyArrayNamed:@"scopeArray" withOffset:0 toArray:sampledPoints count:scopeArrayLength];
            
        }

        
        [newPoints removeAllObjects];
        
        static CGFloat rotation;
        
        if (arc4random_uniform(100) > 80) {
            CGFloat randomValue = (CGFloat)arc4random_uniform(100);
            rotation = randomValue * 0.01 * 0.5 + self.rootMeanSquare * 0.3;
        }
        
        rotation += 0.001;
        if (rotation > 1.0f) {
            rotation += -1.0f;
        }
        
        CGFloat angle = rotation * M_PI * 2.0f;
        
                        
        CGFloat x,y, x_prime, y_prime;
        
            for(NSUInteger i = 0; i < array1Len; ++i){
                x = i*x_increment;
                y = height - (height*((sampledPoints[i]+1)*0.5));
                x_prime = x * cos(angle) - y * sin(angle);
                y_prime = y * cos(angle) + x * sin(angle);
                x_prime = wrapValue(x_prime, 0, self.bounds.size.width);
                y_prime = wrapValue(y_prime, 0, self.bounds.size.height);
                
                if (arc4random_uniform(100) > 40) {
                    [newPoints addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                } else {
                    [newPoints addObject:[NSValue valueWithCGPoint:CGPointMake(x_prime, y_prime)]];
                }
                

                //[newPoints addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
            }
        
        //memory leak?
        self.points = newPoints;
        
        //[self setNeedsDisplay];
        CGAffineTransform trans = CGAffineTransformMakeScale(scale, scale);
        self.transform = trans;
        
        newPoints = nil;
    
    };

    getDataAndDraw();
    
    [self drawAndAnimatePaths];
    
    CGFloat damping = (CGFloat)arc4random_uniform(100) * 0.01;
    CGFloat velocity = (CGFloat)arc4random_uniform(100) * 0.1;

    
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [UIView animateWithDuration:self.animationDuration delay:0.0f usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            CGFloat amount1 = self.rootMeanSquare * 0.7 + (CGFloat)arc4random_uniform(100) * 0.01 * 0.3 + 0.5;
            CGFloat amount2 = self.rootMeanSquare * 0.7 + (CGFloat)arc4random_uniform(100) * 0.01 * 0.3 + 0.5;
            CGFloat amount3 = self.rootMeanSquare * 0.7 + (CGFloat)arc4random_uniform(100) * 0.01 * 0.3 + 0.5;
            CATransform3D trans1 = CATransform3DMakeScale(amount1, amount2, amount3);
            
            amount1 = self.rootMeanSquare * 0.3 + (CGFloat)arc4random_uniform(100) * 0.01 * 0.7;
            amount2 = self.rootMeanSquare * 0.3 + (CGFloat)arc4random_uniform(100) * 0.01 * 0.7;
            amount3 = self.rootMeanSquare * 0.3 + (CGFloat)arc4random_uniform(100) * 0.01 * 0.7;
            CGFloat amount4 = (CGFloat)arc4random_uniform(100) * 0.01 * 2.0f * M_PI;
            CATransform3D trans2 = CATransform3DMakeRotation(amount4*0.01, amount1*0.1, amount2*0.1, amount3*0.1);
            self.layer.transform = CATransform3DConcat(trans1, trans2);
            
        } completion:^(BOOL finished) {
            
        }];
    }];
    

}

- (void)drawAndAnimatePaths
{

    self.backgroundColor = [UIColor clearColor];
    [self.layer removeAllAnimations];
    self.alpha = 1.0f;
    self.layer.cornerRadius = 5.0;
    if (self.currentPath==nil) {
        self.currentPath = [UIBezierPath bezierPath];
    }
    
    self.previousPath4 = nil;
    self.previousPath4 = [self.previousPath3 copy];
    self.previousPath3 = nil;
    self.previousPath3 = [self.previousPath2 copy];
    self.previousPath2 = nil;
    self.previousPath2 = [self.previousPath1 copy];
    self.previousPath1 = nil;
    self.previousPath1 = [self.currentPath copy];
    
    [self.currentPath removeAllPoints];
    
    if (self.isRunning) {
        
        NSArray *arr = [_points objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, ([_points count]-1))]];
        [self.currentPath setLineWidth:_lineWidth];
        [self.currentPath moveToPoint:[_points[0]CGPointValue]];
        
        if (self.mainColor==nil) {
            self.mainColor = [UIColor blackColor];
        }
        
        for (NSValue *aPoint in arr) {
            if ([aPoint CGPointValue].x == [aPoint CGPointValue].x && [aPoint CGPointValue].y == [aPoint CGPointValue].y) {
                [self.currentPath addLineToPoint:[aPoint CGPointValue]];
            }
        }
    }
    
    
    if (self.isAnimated&&self.isRunning) {
        
        
        Render Render4  = ^{
            [self animateBezierPath:self.previousPath4 duration:self.animationDuration color:self.fadedColor4 lineWidth:self.lineWidth*powf(self.lineWidthRatio, 2.3) index:1];
            //[self.fadedColor4 setStroke];
            //self.previousPath4.lineWidth = self.lineWidth*powf(self.lineWidthRatio, 2.3 );
            //[self.previousPath4 stroke];
        };
        
        Render Render3 = ^{
            
            [self animateBezierPath:self.previousPath3 duration:self.animationDuration color:self.fadedColor3 lineWidth:self.lineWidth*powf(self.lineWidthRatio, 1.8 ) index:2];
            //[self.fadedColor3 setStroke];
            //self.previousPath3.lineWidth = self.lineWidth*powf(self.lineWidthRatio, 1.8 );
            //[self.previousPath3 stroke];
        };
        
        Render Render2 = ^{
            
            [self animateBezierPath:self.previousPath2 duration:self.animationDuration color:self.fadedColor2 lineWidth:self.lineWidth*powf(self.lineWidthRatio, 1.2) index:3];
            //[self.fadedColor2 setStroke];
            //self.previousPath2.lineWidth = self.lineWidth*powf(self.lineWidthRatio, 1.2 );
            //[self.previousPath2 stroke];
        };
        
        Render Render1 = ^{
            [self animateBezierPath:self.previousPath1 duration:self.animationDuration color:self.fadedColor1 lineWidth:self.lineWidth*self.lineWidthRatio index:4];
            //[self.fadedColor1 setStroke];
            //self.previousPath1.lineWidth = self.lineWidth*self.lineWidthRatio;
            //[self.previousPath1 stroke];
        };
        
        NSMutableArray *renders = [@[Render1,Render2,Render3, Render4]mutableCopy];
        
        
        if (arc4random_uniform(100) <= 10) {
            NSInteger i = 0;
            while (renders.count > 0) {
                NSInteger idx = arc4random_uniform((int)renders.count);
                self.renderOrder[i] = [NSNumber numberWithInteger:idx];
                
                Render render = renders[idx];
                [renders removeObject:render];
                render();
            }
            
            
        } else {
            for (NSNumber *index in self.renderOrder) {
                NSInteger idx = [index integerValue];
                if (idx < renders.count) {
                    
                    Render render = renders[idx];
                    render();
                    
                }
                
            }
        }
        
        [self animateBezierPath:self.currentPath duration:self.animationDuration color:self.mainColor lineWidth:self.lineWidth index:0];
        
        /*
         
         [self.fadedColor4 setStroke];
         self.previousPath4.lineWidth = self.lineWidth*powf(self.lineWidthRatio, 1.9 );
         [self.previousPath4 stroke];
         
         [self.fadedColor3 setStroke];
         self.previousPath3.lineWidth = self.lineWidth*powf(self.lineWidthRatio, 1.7 );
         [self.previousPath3 stroke];
         
         
         [self.fadedColor2 setStroke];
         self.previousPath2.lineWidth = self.lineWidth*powf(self.lineWidthRatio, 1.5 );
         [self.previousPath2 stroke];
         
         
         [self.fadedColor1 setStroke];
         self.previousPath1.lineWidth = self.lineWidth*self.lineWidthRatio;
         [self.previousPath1 stroke];
         */
        
    }
    
    //[self.mainColor setStroke];
    //self.currentPath.lineWidth = self.lineWidth;
    //[self.currentPath stroke];

}


- (void)animateBezierPath:(UIBezierPath *)bezierPath duration:(CGFloat)duration color:(UIColor *)color lineWidth:(CGFloat)width index:(NSInteger)index;
{
    CAShapeLayer *bezier = [[CAShapeLayer alloc] init];
    
    bezier.path          = bezierPath.CGPath;
    bezier.strokeColor   = color.CGColor;
    bezier.fillColor     = [UIColor clearColor].CGColor;
    bezier.lineWidth     = width;
    bezier.strokeStart   = 0.0;
    bezier.strokeEnd     = 1.0;
    if (index < self.layer.sublayers.count) {
        
        [self.layer replaceSublayer:self.layer.sublayers[index] with:bezier];
        
    }else{
        
      [self.layer addSublayer:bezier];
    }
    
    CABasicAnimation *animateStrokeEnd = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animateStrokeEnd.duration  = duration;
    animateStrokeEnd.fromValue = [NSNumber numberWithFloat:0.0f];
    animateStrokeEnd.toValue   = [NSNumber numberWithFloat:1.0f];
    [bezier addAnimation:animateStrokeEnd forKey:@"strokeEndAnimation"];

}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*
- (void)drawRect:(CGRect)rect
{
    // Drawing code
 
    self.alpha = 1.0f;
    
    self.layer.cornerRadius = 5.0;
    
    
    if (self.currentPath==nil) {
        self.currentPath = [UIBezierPath bezierPath];
    }
    
    self.previousPath4 = nil;
    self.previousPath4 = [self.previousPath3 copy];
    self.previousPath3 = nil;
    self.previousPath3 = [self.previousPath2 copy];
    self.previousPath2 = nil;
    self.previousPath2 = [self.previousPath1 copy];
    self.previousPath1 = nil;
    self.previousPath1 = [self.currentPath copy];
    
    [self.currentPath removeAllPoints];
    
    if (self.isRunning) {
        
        NSArray *arr = [_points objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, ([_points count]-1))]];
        [self.currentPath setLineWidth:_lineWidth];
        [self.currentPath moveToPoint:[_points[0]CGPointValue]];
        
        if (self.mainColor==nil) {
            self.mainColor = [UIColor blackColor];
        }
        
        for (NSValue *aPoint in arr) {
            if ([aPoint CGPointValue].x == [aPoint CGPointValue].x && [aPoint CGPointValue].y == [aPoint CGPointValue].y) {
                [self.currentPath addLineToPoint:[aPoint CGPointValue]];
            }
        }
    }
    
    
    if (self.isAnimated&&self.isRunning) {
        

        Render Render4  = ^{
            [self.fadedColor4 setStroke];
            self.previousPath4.lineWidth = self.lineWidth*powf(self.lineWidthRatio, 2.3 );
            [self.previousPath4 stroke];
        };

        Render Render3 = ^{
            
            [self.fadedColor3 setStroke];
            self.previousPath3.lineWidth = self.lineWidth*powf(self.lineWidthRatio, 1.8 );
            [self.previousPath3 stroke];
        };
        
        Render Render2 = ^{
            
            [self.fadedColor2 setStroke];
            self.previousPath2.lineWidth = self.lineWidth*powf(self.lineWidthRatio, 1.2 );
            [self.previousPath2 stroke];
        };
        
        Render Render1 = ^{
            
            [self.fadedColor1 setStroke];
            self.previousPath1.lineWidth = self.lineWidth*self.lineWidthRatio;
            [self.previousPath1 stroke];
        };

        NSMutableArray *renders = [@[Render1,Render2,Render3, Render4]mutableCopy];

        
        if (arc4random_uniform(100) <= 10) {
            NSInteger i = 0;
            while (renders.count > 0) {
                NSInteger idx = arc4random_uniform((int)renders.count);
                self.renderOrder[i] = [NSNumber numberWithInteger:idx];
    
                Render render = renders[idx];
                [renders removeObject:render];
                render();
            }
            
            
        } else {
            for (NSNumber *index in self.renderOrder) {
                NSInteger idx = [index integerValue];
                if (idx < renders.count) {
                    
                    Render render = renders[idx];
                    render();

                }

            }
        }
        
 
        [self.fadedColor4 setStroke];
        self.previousPath4.lineWidth = self.lineWidth*powf(self.lineWidthRatio, 1.9 );
        [self.previousPath4 stroke];

        [self.fadedColor3 setStroke];
        self.previousPath3.lineWidth = self.lineWidth*powf(self.lineWidthRatio, 1.7 );
        [self.previousPath3 stroke];

        
        [self.fadedColor2 setStroke];
        self.previousPath2.lineWidth = self.lineWidth*powf(self.lineWidthRatio, 1.5 );
        [self.previousPath2 stroke];

        
        [self.fadedColor1 setStroke];
        self.previousPath1.lineWidth = self.lineWidth*self.lineWidthRatio;
        [self.previousPath1 stroke];
 

    }
    
    [self.mainColor setStroke];
    self.currentPath.lineWidth = self.lineWidth;
    [self.currentPath stroke];

    
}

*/


@end
