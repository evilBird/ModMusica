//
//  MMModEditorButton.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/29/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModMelodyEditorSwitch : UIControl

@property (nonatomic)               NSUInteger      value;
@property (nonatomic,strong)        UIColor         *mainColor;

- (NSUInteger)stepIndexForPatternLength:(NSUInteger)patternLength;
- (void)setInitialValue:(NSUInteger)initValue;
@end
