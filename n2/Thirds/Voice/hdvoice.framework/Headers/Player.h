//
//  Player.h
//  voice
//
//  Created by wangfeng on 12-11-4.
//
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@protocol PlayerDelegate;

#define PLAY_PROP_ROUTE_TYPE            @"route_type"               // value is a NSString* for file name
#define PLAY_PROP_ROUTE_TYPE_HEAD       @"route_type_head"          // Headset or headphone
#define PLAY_PROP_ROUTE_TYPE_SPEAKER    @"route_type_speaker"       // Speaker
#define PLAY_PROP_ROUTE_TYPE_AUTO       @"route_type_auto"          // Auto switch

@interface Player : NSObject<UIAccelerometerDelegate>

@property (assign, nonatomic) id<PlayerDelegate> delegate;
@property (nonatomic, readonly) BOOL playing;
@property (readonly, nonatomic) NSString *fileName;     //当前正在播放的文件名
@property (assign, nonatomic) int tag;                  //由调用方填充
@property (assign, nonatomic) int fid;                  //由调用方填充

@property (readonly, getter = getPeakPower)     float peakPower;
@property (readonly, getter = getAveragePower)  float averagePower;
@property (readonly, getter = getCurrentTime)   NSTimeInterval currentTime;
@property (readonly, getter = getDuration)      NSTimeInterval duration;

@property (assign, nonatomic) BOOL enableMeters;

//以下为wavedata的生成
@property (assign, nonatomic) BOOL enableGenerateWaveData;
@property (assign, nonatomic) CGRect waveDataBound;
@property (readonly, nonatomic, getter = getWaveData) CGPoint *waveData;
@property (readonly, nonatomic) int currentSample;
@property (readonly, nonatomic) int totalSamples;

+ (void)stop:(BOOL)keepSilent;
+ (BOOL)isPlaying;

- (BOOL)start:(NSString*)aFileName;
- (void)stop;
- (void)setProperty:(NSObject*)value for:(NSString*)propName;

- (void)doAfterStart;
- (void)doAfterStop:(BOOL)interrupted;


@end


@protocol PlayerDelegate <NSObject>
@optional
- (void)didStartPlay:(Player*)player;
- (void)didFinishPlay:(Player *)player interrupted:(BOOL)flag duration:(int)duration;

- (void)didWaveDataUpdated:(Player*)player;


@end
