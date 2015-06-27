//
//  MMModuleSwitchCellView.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/26/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMModuleSwitchCellView : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UISwitch *actionSwitch;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonTrailingEdgeConstraint;

@end
