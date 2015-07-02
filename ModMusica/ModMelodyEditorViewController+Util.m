//
//  ModMelodyEditorViewController+Util.m
//  ModMusica
//
//  Created by Travis Henspeter on 7/2/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ModMelodyEditorViewController+Util.h"

@implementation ModMelodyEditorViewController (Util)

- (void)printNew:(NSArray *)newData old:(NSArray *)oldData
{
    NSMutableString *log = [[NSMutableString alloc]initWithString:@"\nPRINT DATA\n"];
    NSEnumerator *newDataEnumerator = newData.objectEnumerator;
    for (NSNumber *oldPitch in oldData) {
        NSNumber *newPitch = [newDataEnumerator nextObject];
        NSString *appendToLog = [NSString stringWithFormat:@"\n%@ -> %@",oldPitch,newPitch];
        [log appendString:appendToLog];
    }
    
    NSLog(@"%@\n",log);
}

@end
