//
//  ModMusicaDefs.h
//  ModMusica
//
//  Created by Travis Henspeter on 7/22/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#ifndef ModMusica_ModMusicaDefs_h
#define ModMusica_ModMusicaDefs_h

#define kProductTitleKey                    @"com.birdSound.modmusica.sk.title"
#define kProductPurchasedKey                @"com.birdSound.modmusica.sk.purchased"
#define kProductPriceKey                    @"com.birdSound.modmusica.sk.price"
#define kProductDescriptionKey              @"com.birdSound.modmusica.sk.description"
#define kProductFormattedPriceKey           @"com.birdSound.modmusica.sk.formatted.price"
#define kProductContentPathKey              @"com.birdSound.modmusica.sk.content.path"


#define DETECTED_TEMPO                      @"detectedTempo"
#define DETECTED_INTERVAL                   @"interval"
#define DETECTED_BEAT                       @"beat"
#define CLOCK                               @"clock"
#define ON_OFF                              @"onOff"

#define INPUT_VOL                           @"inputVolume"
#define ALLOW_RANDOM                        @"allowRandom"
#define LOCK_TEMPO                          @"lockTempo"
#define TAP_TEMPO                           @"tapTempo"
#define AUDIO_SWITCH                        @"audioSwitch"
#define OUTPUT_VOL                          @"outputVolume"
#define DRUM_VOL                            @"drumsVolume"
#define SYNTH_VOL                           @"synthVolume"
#define SAMPLER_VOL                         @"samplerVolume"
#define BASS_VOL                            @"bassVolume"

#define DEFAULT_PATCH                       @"modmusica_1.pd"
#define PATCH_BASE                          @"modmusica"

#define kDrumVolume                         0.45
#define kBassVolume                         0.26
#define kSynthVolume                        0.25
#define kSamplerVolume                      0.30

#define kProbPatternChangeDefault           10
#define kProbSectionChangeNoneDefault       66
#define kProbSectionChangeNextDefault       25
#define kProbSectionChangePreviousDefault   9

#endif
