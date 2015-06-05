//
//  YuleLogAudioController.m
//  ModMusica
//
//  Created by Travis Henspeter on 12/21/14.
//  Copyright (c) 2014 birdSound. All rights reserved.
//

#import "YuleLogAudioController.h"
#import "PdBase.h"
#import "PdDispatcher.h"
#import "MMPatternLoader.h"

@interface YuleLogAudioController ()<PdListener>
{
    BOOL kPlaying;
    NSInteger kSongCounter;
}

@property (nonatomic,strong)PdDispatcher *dispatcher;
@property (nonatomic,strong)MMPatternLoader *patternLoader;
@property void *patch;
@end

@implementation YuleLogAudioController

void expr_tilde_setup(void);
void fiddle_tilde_setup(void);
void expr_setup(void);
void helmholtz_tilde_setup(void);
void bonk_tilde_setup(void);

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initializeAudio];
    }
    
    return self;
}

- (BOOL)isPlaying
{
    return kPlaying;
}

- (void)startPlayback
{
    [PdBase sendBangToReceiver:@"resetClock"];
    [self setInstrumentLevels];
    [PdBase sendFloat:1 toReceiver:@"audioSwitch"];
    [PdBase sendFloat:1 toReceiver:@"onOff"];
    kPlaying = YES;
    [self.patternLoader playSection:0];
}

- (void)stopPlayback
{
    [PdBase sendFloat:0 toReceiver:@"audioSwitch"];
    kPlaying = NO;
    [self changePatch];
    [self changeSong];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self zeroInstrumentLevels];
        [PdBase sendFloat:0 toReceiver:@"onOff"];
    });
}

- (void)changeSong
{
    NSArray *patterns = @[@"als",@"gs",@"jb",@"ohn"];
    static NSInteger idx;
    NSString *pattern = patterns[idx%patterns.count];
    self.patternLoader.currentPattern = pattern;
    idx += 1;
}

- (void)changeSongSection
{
    [self.patternLoader playNextSection];
}

- (void)initializeAudio
{
    kPlaying = NO;
    self.dispatcher = [[PdDispatcher alloc]init];
    [PdBase setDelegate:self.dispatcher];
    
    expr_tilde_setup();
    fiddle_tilde_setup();
    expr_setup();
    bonk_tilde_setup();
    helmholtz_tilde_setup();
    
    [self.dispatcher addListener:self forSource:@"clock"];
    
    if (!self.patternLoader) {
        self.patternLoader = [[MMPatternLoader alloc]init];
    }
    
    [self stopPlayback];
}


- (void)changePatch
{
    NSInteger patchNumber = arc4random_uniform(4);
    if (_patch != nil) {
        [PdBase closeFile:_patch];
    }
    //NSString *patchName = [NSString stringWithFormat:@"modmusica_%@.pd",@((patchNumber + 2))];
    NSString *patchName = [NSString stringWithFormat:@"modmusica_%@.pd",@((2))];
    self.patch = [PdBase openFile:patchName path:[[NSBundle mainBundle]resourcePath]];
}

- (void)tearDown
{
    if (kPlaying) {
        [self stopPlayback];
    }
    
    [PdBase closeFile:_patch];
    free(_patch);
    [PdBase setDelegate:nil];
    self.dispatcher = nil;
    self.patternLoader = nil;
}

- (void)setInstrumentLevels
{
    [PdBase sendFloat:0.36 toReceiver:@"drumsVolume"];
    [PdBase sendFloat:0.3 toReceiver:@"synthVolume"];
    [PdBase sendFloat:0.3 toReceiver:@"bassVolume"];
}

- (void)zeroInstrumentLevels
{
    [PdBase sendFloat:0.0 toReceiver:@"drumsVolume"];
    [PdBase sendFloat:0.0 toReceiver:@"synthVolume"];
    [PdBase sendFloat:0.0 toReceiver:@"bassVolume"];
}

- (void)dealloc
{
    [self tearDown];
}

#pragma mark - PdListener

- (void)receiveFloat:(float)received fromSource:(NSString *)source
{
    
    if ([source isEqualToString:@"clock"] && received == 0) {
        kSongCounter += 1;
        if (kSongCounter%8 ==0) {
            [self changeSong];
            [self.patternLoader playSection:0];
        }else{
            [self changeSongSection];
        }
    }
}

@end
