//
//  MMModuleManager+Packages.m
//  ModMusica
//
//  Created by Travis Henspeter on 7/22/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMModuleManager+Packages.h"
#import "ModMusicaDefs.h"

@implementation MMModuleManager (Packages)

+ (NSArray *)getModResourceAtPath:(NSString *)path
{
    NSFileManager *fm = [NSFileManager defaultManager];
    if (!path || ![fm fileExistsAtPath:path]) {
        return nil;
    }
    NSError *err = nil;
    NSArray *contents = nil;
    contents = [fm contentsOfDirectoryAtPath:path error:&err];
    if (err) {
        NSLog(@"ERROR LOADING RESOURCE AT PATH %@: %@",path,err.debugDescription);
        return nil;
    }
    
    if (!contents.count) {
        return nil;
    }
    
    return contents;
}

+ (NSDictionary *)getMod:(NSString *)modName
{
    if (!modName || ![[MMModuleManager purchasedModNames]containsObject:modName]) {
        return nil;
    }
    
    return [MMModuleManager getMod:modName fromArray:[MMModuleManager purchasedMods]];
}

+ (NSString *)pathForResource:(NSString *)resourcePath
{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *result = [documentsPath stringByAppendingPathComponent:resourcePath];
    return result;
}

+ (NSString *)bundlePathModName:(NSString *)modName
{
    NSDictionary *mod = [MMModuleManager getMod:modName];
    if (!mod) {
        return nil;
    }
    
    return [MMModuleManager pathForResource:[NSString stringWithFormat:BUNDLE_PATH_FORMAT_STRING,mod[kProductIDKey]]];
}

+ (NSString *)contentPathModName:(NSString *)modName
{
    NSDictionary *mod = [MMModuleManager getMod:modName];
    if (!mod) {
        return nil;
    }
    
    return [MMModuleManager pathForResource:[NSString stringWithFormat:CONTENTS_PATH_FORMAT_STRING,mod[kProductIDKey]]];
}

+ (NSString *)drumSamplesPathModName:(NSString *)modName
{
    NSDictionary *mod = [MMModuleManager getMod:modName];
    if (!mod) {
        return nil;
    }
    
    return [MMModuleManager pathForResource:[NSString stringWithFormat:DRUMSAMPLES_PATH_FORMAT_STRING,mod[kProductIDKey]]];
}

+ (NSString *)kickSamplesPathModName:(NSString *)modName
{
    NSDictionary *mod = [MMModuleManager getMod:modName];
    if (!mod) {
        return nil;
    }
    
    return [MMModuleManager pathForResource:[NSString stringWithFormat:KICKSAMPLES_PATH_FORMAT_STRING,mod[kProductIDKey]]];
}

+ (NSString *)snareSamplesPathModName:(NSString *)modName

{
    NSDictionary *mod = [MMModuleManager getMod:modName];
    if (!mod) {
        return nil;
    }
    return [MMModuleManager pathForResource:[NSString stringWithFormat:SNARESAMPLES_PATH_FORMAT_STRING,mod[kProductIDKey]]];

}
+ (NSString *)percussionSamplesPathModName:(NSString *)modName
{
    NSDictionary *mod = [MMModuleManager getMod:modName];
    if (!mod) {
        return nil;
    }
    return [MMModuleManager pathForResource:[NSString stringWithFormat:PERCSAMPLES_PATH_FORMAT_STRING,mod[kProductIDKey]]];

}
+ (NSString *)otherSamplesPathModName:(NSString *)modName
{
    NSDictionary *mod = [MMModuleManager getMod:modName];
    if (!mod) {
        return nil;
    }
    return [MMModuleManager pathForResource:[NSString stringWithFormat:OTHERSAMPLES_PATH_FORMAT_STRING,mod[kProductIDKey]]];

}
+ (NSString *)plistPathModName:(NSString *)modName
{
    NSDictionary *mod = [MMModuleManager getMod:modName];
    if (!mod) {
        return nil;
    }
    
    return [MMModuleManager pathForResource:[NSString stringWithFormat:PLIST_PATH_FORMAT_STRING,mod[kProductIDKey]]];
}

+ (NSString *)patchPathModName:(NSString *)modName
{
    NSDictionary *mod = [MMModuleManager getMod:modName];
    if (!mod) {
        return nil;
    }
    
    return [MMModuleManager pathForResource:[NSString stringWithFormat:PATCH_PATH_FORMAT_STRING,mod[kProductIDKey],mod[kProductTitleKey]]];
}

@end
