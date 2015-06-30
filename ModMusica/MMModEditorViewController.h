//
//  MMModEditorViewController.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/29/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModPitchEditorButtonView.h"

@interface MMModEditorViewController : UIViewController

@property (nonatomic,strong)        UIColor                     *mainColor;
@property (nonatomic,strong)        ModPitchEditorButtonView    *buttonView;


- (void)configureConstraints;

@end
