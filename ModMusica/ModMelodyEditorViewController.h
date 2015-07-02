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

@interface ModMelodyEditorViewController : UIViewController

@property (nonatomic,weak)                                  id<ModEditorDatasource>                     datasource;
@property (nonatomic,weak)                                  id<ModEditorViewControllerDelegate>         delegate;

@property (strong, nonatomic) IBOutlet                      ModMelodyEditorStepPitchView                *pitchView;
@property (strong, nonatomic) IBOutletCollection(UIButton)  NSArray                                     *buttons;


@property (nonatomic,strong)                                UIColor                                     *mainColor;
@property (nonatomic,readonly)                              NSArray                                     *editedData;

//Contains the tag of the currently selected pitch in each step, if there is one, else value is -1.
@property (nonatomic)                                       NSUInteger                                  minPitch;
@property (nonatomic)                                       NSUInteger                                  maxPitch;
@property (nonatomic,strong)                                NSMutableArray                              *stepPitchTags;

- (void)stepPitchTagsDidChange;

@end
