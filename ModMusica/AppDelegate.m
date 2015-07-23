//
//  AppDelegate.m
//  ModMusica
//
//  Created by Travis Henspeter on 10/27/14.
//  Copyright (c) 2014 birdSound. All rights reserved.
//

#import "AppDelegate.h"
#import <PdAudioController.h>
#import "MMPlaybackController.h"
#import "MMModuleManager.h"
#import "MMPurchaseManager.h"

#define SAMPLE_RATE 22050
#define TICKS_PER_BUFFER 64

@interface AppDelegate ()

@property (nonatomic,strong)PdAudioController *audioController;
@property (nonatomic,getter=isPlaying) BOOL playing;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [MMModuleManager setupDefaultMods];
    [[MMPurchaseManager sharedInstance]getProductsCompletion:nil];
    //[[UIApplication sharedApplication]setIdleTimerDisabled:YES];
    self.audioController = [[PdAudioController alloc]init];
    [self.audioController configurePlaybackWithSampleRate:SAMPLE_RATE numberChannels:2 inputEnabled:YES mixingEnabled:YES];
    [self.audioController configureTicksPerBuffer:TICKS_PER_BUFFER];
    self.audioController.active = YES;
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlaybackDidChange:) name:kPlaybackDidChangeNotification object:nil];
    return YES;
}

- (void)handlePlaybackDidChange:(NSNotification *)notification
{
    NSDictionary *obj = notification.userInfo;
    self.playing = [obj[@"playback"]boolValue];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if (!self.isPlaying) {
        self.audioController.active = NO;
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    self.audioController.active = YES;
    [[MMPurchaseManager sharedInstance]getProductsCompletion:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    self.audioController.active = NO;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kPlaybackDidChangeNotification object:nil];
}

@end
