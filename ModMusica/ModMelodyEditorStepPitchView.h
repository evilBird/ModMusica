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


@interface ModMelodyEditorStepPitchView : UIView

- (void)configureWithDelegate:(id<ModMelodyEditorStepPitchViewDelegate>)delegate
                   datasource:(id<ModEditorDatasource>)datasource;

- (void)buttonValueChanged:(id)sender;

@property (nonatomic,weak)          id<ModMelodyEditorStepPitchViewDelegate>                delegate;
@property (nonatomic,weak)          id<ModEditorDatasource>                                 datasource;

@property (nonatomic)               NSUInteger                                              activeSwitchTag;
@property (nonatomic,strong)        NSMutableArray                                          *switches;
@property (nonatomic,strong)        NSMutableArray                                          *switchesConstraints;
@property (nonatomic,strong)        NSMutableArray                                          *pitchLabels;
@property (nonatomic,strong)        NSMutableArray                                          *stepLabels;

@end
