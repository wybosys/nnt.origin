//
//  Recorder.h
//  voice
//
//  Created by wangfeng on 12-11-4.
//
//

#import <Foundation/Foundation.h>

#define RECORD_PROP_BGMUSIC         @"bgmusic"          // value is a NSString* for file name
#define RECORD_PROP_PODMUSIC        @"podmusic"          // value is a NSString* for file name，must like : ipod-library://item/item.mp3?id=6528798992644082038
#define RECORD_PROP_BGPLAY_VOLUME   @"bgplay_volume"    // value is a float for bgmusic volume
#define RECORD_PROP_BGMUSIC_LOOP    @"bgmusic_loop"     // value is int, 1: enabled, 0: disabled
#define RECORD_PROP_BGMIX_VOLUME    @"bgmix_volume"         // value is float, between 0.0 and 1.0, mix volume
#define RECORD_PROP_SETEFFECT       @"seteffect"        // value is a NSString* for file name
#define RECORD_PROP_DENOISE         @"denoise"          // value is int, 1: enabled, 0: disabled

@protocol RecorderDelegate;

typedef enum {
    kRecordTimeTriggerMin,
    kRecordTimeTriggerMax
}RecordTimeTrigger;

@interface Recorder : NSObject

@property (nonatomic, assign) id<RecorderDelegate> delegate;
@property (nonatomic, readonly) BOOL recording;
@property (readonly, nonatomic) NSString *fileName;

@property (assign, nonatomic) int tag;                  //由调用方填充

@property (readonly, getter = getPeakPower)     float peakPower;
@property (readonly, getter = getAveragePower)  float averagePower;
@property (readonly, getter = getCurrentTime)   NSTimeInterval currentTime;
@property (readonly, getter = getDuration)      NSTimeInterval duration;

@property (assign, nonatomic)                   BOOL enableMeters;

@property (assign, nonatomic)                   NSTimeInterval minRecordTime;
@property (assign, nonatomic)                   NSTimeInterval maxRecordTime;

+ (void)stop:(BOOL)keepSilent;
+ (BOOL)isRecording;

- (BOOL)start:(NSString *)aFileName format:(NSUInteger)format sampleRate:(Float64)sampleRate channels:(int)channels;
- (void)stop;
- (void)setProperty:(NSObject*)value for:(NSString*)propName;

- (void)doAfterStart;
- (void)doAfterStop:(BOOL)successfully;

@end


@protocol RecorderDelegate <NSObject>
@optional
- (void)didStartRecord:(Recorder*)recorder;
- (void)didFinishRecord:(Recorder *)recorder successfully:(BOOL)flag duration:(int)duration;

- (void)didTriggerRecordTime:(RecordTimeTrigger)trigger;

@end
