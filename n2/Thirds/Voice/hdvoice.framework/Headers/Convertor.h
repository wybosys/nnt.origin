//
//  Convertor.h
//  voice
//
//  Created by wangfeng on 12-11-11.
//
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "VoiceCommon.h"

/*
 *  Sample rate
 */
#define     CONVERT_PROP_SAMPLE   @"convert_prop_sample_rate"

/*
 *  Convert type 
 *  key : CONVERT_PROP_TYPE
 *  value : 3
 */
#define CONVERT_PROP_TYPE                   @"convert_type"
#define CONVERT_PROP_TYPE_GVERB             @"convert_type_geverb"
#define CONVERT_PROP_TYPE_DENOISING         @"convert_type_denoising"
#define CONVERT_PROP_TYPE_VOICECHANGE       @"convert_type_voicechange"

/*
 *  Convert type : GVerb parameters
 *  key : GV_PROP_TYPE
 *  value : 6
 */
#define GV_PROP_TYPE                        @"gverb_type"
#define GV_PROP_TYPE_DEFALUT                @"gverb_type_default"
#define GV_PROP_TYPE_BRIGHT_SMALL_HALL      @"gverb_type_bsh"
#define GV_PROP_TYPE_NICE_HALL_EFFECT       @"gverb_type_nhe"
#define GV_PROP_TYPE_SINGING_IN_THE_SEWER   @"gverb_type_sits"
#define GV_PROP_TYPE_LAS_ROW_CHURCH         @"gverb_type_lrc"
#define GV_PROP_TYPE_ELECTRIC_GUITAR_BASS   @"gverb_type_egb"

/*
 *  Convert type : VoiceChange parameters
 */
#define VV_PROP_TEMP            @"temp_change"
#define VV_PROP_SMEI            @"pitch_semi_tones"
#define VV_PROP_PITCH           @"pitch"
#define VV_PROP_TEMPO           @"tempo"
#define VV_PROP_RATE            @"rate_change"

@protocol ConvertorDelegate;
@interface Convertor : NSObject

@property (assign, nonatomic) id<ConvertorDelegate> delegate;
@property (nonatomic, readonly, getter = isConverting) BOOL converting;

+(Convertor*)sharedInstance;
- (BOOL)start:(NSString*)aFromFileName toFile:(NSString*)aToFileName;
- (void)cancel;
- (void)setProperty:(NSObject*)value for:(NSString*)propName;
@end


@protocol ConvertorDelegate <NSObject>
@optional
- (void)didStartConvert:(Convertor*)player;
- (void)didFinishConvert:(Convertor *)player duration:(int)duration;
- (void)convertProgress:(Convertor *)convertor progress:(float)progress;


@end