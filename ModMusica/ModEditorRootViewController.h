//
//  ModEditorRootViewController.h
//  ModMusica
//
//  Created by Travis Henspeter on 6/30/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModEditorDefs.h"

@interface ModEditorRootViewController : UIViewController <ModMelodyEditorViewControllerDelegate>

@property (nonatomic,weak)          id<ModEditorDatasource>             datasource;

#pragma mark - ModMelodyEditorViewControllerDelegate
- (void)editor:(id)sender playbackChanged:(float)playback;
- (void)editorDidSave:(id)sender;
- (void)editorDidClear:(id)sender;
- (void)editorDidRevertToSaved:(id)sender;
- (void)editorShouldClose:(id)sender completion:(void(^)(void))completion;

@end
