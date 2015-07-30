//
//  ModMusicaDefs.h
//  ModMusica
//
//  Created by Travis Henspeter on 7/22/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#ifndef ModMusica_ModMusicaDefs_h
#define ModMusica_ModMusicaDefs_h

#define kProductIDKey                       @"com.birdSound.modmusica.sk.id"
#define kProductTitleKey                    @"com.birdSound.modmusica.sk.title"
#define kProductPurchasedKey                @"com.birdSound.modmusica.sk.purchased"
#define kProductPriceKey                    @"com.birdSound.modmusica.sk.price"
#define kProductDescriptionKey              @"com.birdSound.modmusica.sk.description"
#define kProductFormattedPriceKey           @"com.birdSound.modmusica.sk.formatted.price"
#define kProductContentPathKey              @"com.birdSound.modmusica.sk.content.path"

#define kMarioProductId                     @"com.birdSound.modmusica.mario"
#define kFantasyProductId                   @"com.birdSound.modmusica.fantasy"
#define kGushiesProductId                   @"com.birdSound.modmusica.gushies"
#define kMegaProductId                      @"com.birdSound.modmusica.mega"
#define kMenaceProductId                    @"com.birdSound.modmusica.menace"
#define kFunkProductId                      @"com.birdSound.modmusica.funk"
#define kSadProductId                       @"com.birdSound.modmusica.sad"
#define kMajesticProductId                  @"com.birdSound.modmusica.majestic"
#define kHappyProductId                     @"com.birdSound.modmusica.happy"

#define kPackagePlistName                   @"ContentInfo.plist"
#define kPackagePlistSectionCountKey        @"SectionCount"
#define kPackagePlistPatchNameKey           @"PatchName"
#define kPackagePlistDrumSamplesKey         @"DrumSamples"
#define kDrumSamplesKickSamplesKey          @"KickSamples"
#define kDrumSamplesSnareSamplesKey         @"SnareSamples"
#define kDrumSamplesPercSamplesKey          @"PercussionSamples"
#define kPackagePlistOtherSamplesKey        @"OtherSamples"

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

#define LOAD_KICK_SAMPLE                    @"loadKickSample"
#define LOAD_SNARE_SAMPLE                   @"loadSnareSample"
#define LOAD_PERC_SAMPLE                    @"loadPercSample"
#define LOAD_OTHER_SAMPLE                   @"loadOtherSample"

#define KICK_ARRAY_NAME                     @"kickArray"
#define SNARE_ARRAY_NAME                    @"snareArray"
#define PERC_ARRAY_NAME                     @"percArray"

#define DRUMTABLE_FORMAT_STRING             @"%@-%@%@"
#define PATCH_NAME_FORMAT_STRING            @"%@_%@.pd"
#define PATCH_FILE_EXTENSION                @".pd"
#define SAMPLE_FLAG_READ                    @"read"
#define SAMPLE_FLAG_RESIZE                  @"-resize"
#define SAMPLE_FLAG_SAMPLE                  @"sample"
#define SAMPLE_FLAG_BEATS                   @"beats"

#define DEFAULT_PATCH                       @"modmusica_1.pd"
#define PATCH_BASE                          @"modmusica"

#define BUNDLE_PATH_FORMAT_STRING           @"%@/bundle"
#define PLIST_PATH_FORMAT_STRING            @"%@/bundle/ContentInfo.plist"
#define CONTENTS_PATH_FORMAT_STRING         @"%@/bundle/Contents"
#define PATCH_PATH_FORMAT_STRING            @"%@/bundle/Contents/modmusica_%@.pd"
#define DRUMSAMPLES_PATH_FORMAT_STRING      @"%@/bundle/Contents/DrumSamples"
#define KICKSAMPLES_PATH_FORMAT_STRING      @"%@/bundle/Contents/DrumSamples/Kicks"
#define SNARESAMPLES_PATH_FORMAT_STRING     @"%@/bundle/Contents/DrumSamples/Snares"
#define PERCSAMPLES_PATH_FORMAT_STRING      @"%@/bundle/Contents/DrumSamples/Percussion"
#define OTHERSAMPLES_PATH_FORMAT_STRING     @"%@/bundle/Contents/OtherSamples"

#ifdef CONFIGURATION_DEBUG
#define SAMPLE_RATE                         44100
#define TICKS_PER_BUFFER                    64
#else
#define SAMPLE_RATE                         44100
#define TICKS_PER_BUFFER                    64
#endif

#define kDrumVolume                         0.7
#define kBassVolume                         0.55
#define kSynthVolume                        0.75
#define kSamplerVolume                      0.75

#define kProbPatternChangeDefault           10
#define kProbSectionChangeNoneDefault       75
#define kProbSectionChangeNextDefault       20
#define kProbSectionChangePreviousDefault   5

#endif
