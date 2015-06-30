//
//  ModEditorButtonView.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/29/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ModEditorButtonViewDelegate <NSObject>



@end

@interface ModPitchEditorButtonView : UIView

- (void)setupButtonsNumSteps:(NSUInteger)numSteps numPitches:(NSUInteger)numPitches;
- (void)configureConstraints;

@property (nonatomic,weak)          id<ModEditorButtonViewDelegate>             delegate;

@property (nonatomic)               NSUInteger                                  numSteps;
@property (nonatomic)               NSUInteger                                  numPitches;
@property (nonatomic,strong)        UIColor                                     *mainColor;
@property (nonatomic)               CGFloat                                     innerPadding;
@property (nonatomic)               CGFloat                                     outerPadding;

@end
