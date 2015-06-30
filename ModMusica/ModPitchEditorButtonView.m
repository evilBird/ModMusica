//
//  ModEditorButtonView.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/29/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ModPitchEditorButtonView.h"
#import "MMModEditorButton.h"
#import "UIView+Layout.h"

@interface ModPitchEditorButtonView ()

@property (nonatomic)               NSUInteger              activeButtonTag;
@property (nonatomic,strong)        NSMutableArray          *buttons;
@property (nonatomic,strong)        NSMutableArray          *buttonsConstraints;

@end

@implementation ModPitchEditorButtonView

- (void)handleTouches:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [touches.allObjects.lastObject locationInView:self];
    CGFloat buttonWidth,buttonHeight;
    buttonWidth = (self.bounds.size.width - ((self.outerPadding- self.innerPadding) * 2.0))/(CGFloat)(self.numSteps);
    buttonHeight = (self.bounds.size.height - ((self.outerPadding - self.innerPadding) * 2.0))/(CGFloat)(self.numPitches);
    
    CGFloat minX = (self.outerPadding - self.innerPadding);
    CGFloat minY = (self.outerPadding - self.innerPadding);
    CGFloat maxX = (self.bounds.size.width - (self.outerPadding - self.innerPadding));
    CGFloat maxY = (self.bounds.size.height - (self.outerPadding - self.innerPadding));
    
    if (point.x < minX || point.x > maxX || point.y < minY || point.y > maxY) {
        return;
    }
    
    point.x-=((self.outerPadding - self.innerPadding) * 2.0);
    point.y-=((self.outerPadding - self.innerPadding) * 2.0);
    
    double step = round(point.x/buttonWidth);
    double pitch = round(point.y/buttonHeight);
    
    NSUInteger index = (NSUInteger)(pitch * self.numSteps + step);
    if (index >= self.buttons.count) {
        return;
    }
    
    NSLog(@"\ntouch in step %@, pitch %@\n",@(step),@(pitch));
    MMModEditorButton *button = nil;
    button = self.buttons[index];
    
    if (button.tag != self.activeButtonTag) {
        button.value = 1 - button.value;
    }
    
    self.activeButtonTag = button.tag;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handleTouches:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handleTouches:touches withEvent:event];

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handleTouches:touches withEvent:event];

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handleTouches:touches withEvent:event];

}

- (void)commonInit
{
    self.mainColor = [UIColor orangeColor];
    [self setupButtonsNumSteps:self.numSteps numPitches:self.numPitches];
}

- (void)configureConstraints
{
    if (!self.buttons || !self.buttons.count) {
        return;
    }
    
    [self tearDownButtonsConstraints];
    [self setupConstraintsInButtons:self.buttons numSteps:self.numSteps numPitches:self.numPitches];
}

- (void)buttonValueChanged:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        MMModEditorButton *button = sender;
        NSLog(@"\nbutton with tag %@ has value %@\n",@(button.tag),@(button.value));
    }
}

- (void)tearDownButtonsConstraints
{
    if (!self.buttonsConstraints) {
        return;
    }
    
    [self removeConstraints:self.buttonsConstraints];
    self.buttonsConstraints = nil;
}

- (void)tearDownButtons
{
    [self removeConstraints:self.buttonsConstraints];
    
    for (MMModEditorButton *button in self.buttons) {
        [button removeTarget:self action:@selector(buttonValueChanged:) forControlEvents:UIControlEventValueChanged];
        [button removeFromSuperview];
    }
    
    self.buttons = nil;
}

- (void)setupButtonsNumSteps:(NSUInteger)numSteps numPitches:(NSUInteger)numPitches
{
    if (!numSteps || !numPitches) {
        return;
    }
    
    [self tearDownButtons];
    
    NSMutableArray *tempButtons = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < numPitches; i ++) {
        
        for (NSUInteger j = 0; j < numSteps; j ++) {
            
            MMModEditorButton *button = [MMModEditorButton new];
            button.translatesAutoresizingMaskIntoConstraints = NO;
            button.tag = (i * numSteps) + j;
            button.backgroundColor = [UIColor clearColor];
            button.value = 0;
            button.layer.borderWidth = 0.5;
            button.layer.borderColor = [UIColor blackColor].CGColor;
            button.layer.cornerRadius = 2.0;
            button.mainColor = self.mainColor;
            button.userInteractionEnabled = NO;
            [button addTarget:self action:@selector(buttonValueChanged:) forControlEvents:UIControlEventValueChanged];
            if (button) {
                [tempButtons addObject:button];
                [self addSubview:button];
            }
        }
    }
    
    self.buttons = tempButtons;
}

- (void)setupConstraintsInButtons:(NSMutableArray *)buttons numSteps:(NSUInteger)numSteps numPitches:(NSUInteger)numPitches
{
    if (!buttons || !buttons.count) {
        return;
    }
    
    NSInteger left_neighbor, top_neighbor, right_neighbor, bottom_neighbor;
    NSUInteger maxPitch = numPitches - 1;
    NSUInteger maxStep = numSteps - 1;
    CGFloat buttonWidthMultiplier,buttonHeightMultiplier;
    
    buttonWidthMultiplier = ((self.bounds.size.width - self.outerPadding * 2.0 - self.innerPadding * (numSteps - 1))/(CGFloat)numSteps)/self.bounds.size.width;
    buttonHeightMultiplier = ((self.bounds.size.height - self.outerPadding * 2.0 - self.innerPadding * (numPitches - 1))/numPitches)/self.bounds.size.height;
    
    NSMutableArray *tempConstraints = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < numPitches; i ++) {
        
        for (NSUInteger j = 0; j < numSteps; j ++) {
            
            NSUInteger buttonTag = (i * numSteps) + j;
            
            if (i == 0) {
                top_neighbor = -1;
            }else{
                top_neighbor = buttonTag - numSteps;
            }
            
            if (i == maxPitch) {
                bottom_neighbor = -1;
            }else{
                bottom_neighbor = buttonTag + numSteps;
            }
            
            if (j == 0) {
                left_neighbor = -1;
            }else{
                left_neighbor = buttonTag - 1;
            }
            
            if (j == maxStep) {
                right_neighbor = -1;
            }else{
                right_neighbor = buttonTag+1;
            }
            
            MMModEditorButton *button = buttons[buttonTag];
            
            [tempConstraints addObject:[button pinHeightProportionateToSuperview:buttonHeightMultiplier]];
            [tempConstraints addObject:[button pinWidthProportionateToSuperview:buttonWidthMultiplier]];
            
            UIView *left = nil;
            LayoutEdge leftEdge;
            CGFloat leftPad = 0;
            if (left_neighbor >= 0) {
                left = buttons[left_neighbor];
                leftPad = self.innerPadding;
                leftEdge = LayoutEdge_Right;
            }else{
                left = button.superview;
                leftPad = self.outerPadding;
                leftEdge = LayoutEdge_Left;
            }
            
            [tempConstraints addObject:[button pinEdge:LayoutEdge_Left
                                                toEdge:leftEdge
                                                ofView:left
                                             withInset:leftPad]];
            
            UIView *top = nil;
            LayoutEdge topEdge;
            CGFloat topPad = 0;
            if (top_neighbor >= 0) {
                top = buttons[top_neighbor];
                topPad = self.innerPadding;
                topEdge = LayoutEdge_Bottom;
            }else{
                top = button.superview;
                topPad = self.outerPadding;
                topEdge = LayoutEdge_Top;
            }
            
            [tempConstraints addObject:[button pinEdge:LayoutEdge_Top
                                                toEdge:topEdge
                                                ofView:top
                                             withInset:topPad]];
            
            UIView *right = nil;
            LayoutEdge rightEdge;
            CGFloat rightPad = 0;
            if (right_neighbor >= 0) {
                right = buttons[right_neighbor];
                rightPad = -self.innerPadding;
                rightEdge = LayoutEdge_Left;
            }else{
                right = button.superview;
                rightPad = -self.innerPadding;
                rightEdge = LayoutEdge_Right;
            }
            
            [tempConstraints addObject:[button pinEdge:LayoutEdge_Right
                                                toEdge:rightEdge
                                                ofView:right
                                             withInset:rightPad]];
            
            
            UIView *bottom = nil;
            LayoutEdge bottomEdge;
            CGFloat bottomPad = 0;
            if (bottom_neighbor >= 0) {
                bottom = buttons[bottom_neighbor];
                bottomPad = -self.innerPadding;
                bottomEdge = LayoutEdge_Top;
            }else{
                bottom = button.superview;
                bottomPad = -self.outerPadding;
                bottomEdge = LayoutEdge_Bottom;
            }
            
            [tempConstraints addObject:[button pinEdge:LayoutEdge_Bottom
                                                toEdge:bottomEdge
                                                ofView:bottom
                                             withInset:bottomPad]];
            
        }
    }
    
    self.buttonsConstraints = tempConstraints;
    [self addConstraints:tempConstraints];
}

- (instancetype)initWithSteps:(NSUInteger)numSteps pitches:(NSUInteger)numPitches
{
    self = [super init];
    if (self) {
        _numSteps = numSteps;
        _numPitches = numPitches;
        
        [self commonInit];
    }
    
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
