//
//  MMPlaybackController+ResourceLoader.h
//  ModMusica
//
//  Created by Travis Henspeter on 7/22/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMPlaybackController.h"

@interface MMPlaybackController (ResourceLoader)

- (void)openPatch;
- (void)closePatch;
- (void)loadResourcesForModName:(NSString *)modName completion:(void(^)(void))completion;

@end
