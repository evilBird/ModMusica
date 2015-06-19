//
//  MyGLKViewController.h
//  GLKitStuff
//
//  Created by Travis Henspeter on 6/12/15.
//  Copyright (c) 2015 birdSound LLC. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface MyGLKViewController : GLKViewController

@property (nonatomic,getter=isPlaying)              BOOL                playing;

@property (nonatomic,strong)                        NSString            *currentModName;
@property (nonatomic,strong)                        UILabel             *titleLabel;
@property (nonatomic,strong)                        UILabel             *nowPlayingLabel;
@property (nonatomic,strong)                        UILabel             *infoLabel;

- (void)showDetails;

@end
