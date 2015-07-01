//
//  MMModEditorViewController.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/29/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModMelodyEditorStepPitchView.h"
#import "ModEditorDefs.h"

@interface ModMelodyEditorViewController : UIViewController <ModMelodyEditorStepPitchViewDelegate>

@property (nonatomic,weak)              id<ModEditorDatasource>                     datasource;
@property (nonatomic,weak)              id<ModEditorViewControllerDelegate>         delegate;
@property (nonatomic,strong)            NSMutableArray                              *pitchLabels;
@property (nonatomic,strong)            NSMutableArray                              *stepLabels;
@property (nonatomic,strong)            NSMutableArray                              *controls;

@property (nonatomic,strong)            ModMelodyEditorStepPitchView                *pitchView;
@property (nonatomic,strong)            UIView                                      *containerView;
@property (nonatomic,strong)            UIView                                      *pitchLabelsView;
@property (nonatomic,strong)            UIView                                      *stepLabelsView;
@property (nonatomic,strong)            UIView                                      *controlsView;
@property (nonatomic,strong)            UIColor                                     *mainColor;


- (void)loadDataForVoiceAtIndex:(NSUInteger)voiceIndex;

- (void)setupWithDelegate:(id<ModEditorViewControllerDelegate>)delegate
               datasource:(id<ModEditorDatasource>)datasource
               completion:(void(^)(void))completion;

@end
