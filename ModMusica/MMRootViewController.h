//
//  BlameViewController.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/23/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMShaderViewController.h"
#import "MMPlaybackController+ResourceLoader.h"

@interface MMRootViewController : UIViewController

@property (nonatomic)                               double                                  tempo;
@property (nonatomic,strong)                        NSString                                *modName;
@property (nonatomic,getter=isPlaying)              BOOL                                    playing;
@property (nonatomic,strong)                        UIColor                                 *mainColor;
@property (nonatomic)                               double                                  scale;
@property (nonatomic)                               double                                  rotation;

@property (strong, nonatomic)                       MMPlaybackController                    *playbackController;
@property (strong, nonatomic)                       MMShaderViewController                  *shaderViewController;

@end
