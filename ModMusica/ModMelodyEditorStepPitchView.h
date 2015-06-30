//
//  ModEditorButtonView.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/29/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModMelodyEditorSwitch.h"
#import "ModEditorDefs.h"


@protocol ModMelodyEditorStepPitchViewDelegate <NSObject>

- (UIColor *)mainColor;

@end

@interface ModMelodyEditorStepPitchView : UIView

- (void)configureWithDelegate:(id<ModMelodyEditorStepPitchViewDelegate>)delegate
                   datasource:(id<ModEditorDatasource>)datasource;

@property (nonatomic,weak)          id<ModMelodyEditorStepPitchViewDelegate>                delegate;
@property (nonatomic,weak)          id<ModEditorDatasource>                                 datasource;

@property (nonatomic)               NSUInteger                                              activeSwitchTag;
@property (nonatomic,strong)        NSMutableArray                                          *switches;
@property (nonatomic,strong)        NSMutableArray                                          *switchesConstraints;

@end
