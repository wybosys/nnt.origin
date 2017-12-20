
# ifndef __AUDIO_EXTENSION_D98B6A38D9C140398CEB28F720A7CF1D_H_INCLUDED
# define __AUDIO_EXTENSION_D98B6A38D9C140398CEB28F720A7CF1D_H_INCLUDED

# import <CoreAudio/CoreAudioTypes.h>

@interface SystemAudio : NSObjectExt

+ (void)Vibration;

@end

SIGNAL_DECL(kSignalVibration) @"::sa::vibration";

@class MMAudioPlayer;
@class MMAudioRecorder;

@interface MMAudioSession : NSObjectExt

// 停止录音、播放
- (void)stop;

// 停止录音
- (void)stopRecorders;

// 停止播放
- (void)stopPlayers;

// 播放文件，player 和 url 为以一一对应，而且 url 只能为本地的文件
- (MMAudioPlayer*)playerWithLocalFile:(NSURL*)url;

@end

@interface MMAudioFormat : NSObjectExt

// 格式
@property (nonatomic, assign) int format;

// 文件名后缀
@property (nonatomic, copy) NSString *ext;

// 波特率
@property (nonatomic, assign) int samplerate;

// 通道
@property (nonatomic, assign) int channel;

// 为录音准备
+ (instancetype)Recorder;

@end

// 某一个帧的信息
@interface MMAudioSample : NSObjectExt

// 音量
@property (nonatomic, assign) float peakPower, averagePower;

@end

@interface MMAVObject : NSObjectExt

// 启动
- (void)start;

// 停止
- (void)stop;

// 取样
- (BOOL)sample:(MMAudioSample*)amp;

// 是否在运行
@property (nonatomic, readonly, assign) BOOL running;

// 是否可用
@property (nonatomic, assign) BOOL enable;

@end

@interface MMAudioRecorder : MMAVObject

// 最小录制时间, 默认 == 0, 不限制
@property (nonatomic, assign) CGFloat timeMinimum;

// 最大录制时间, 默认 == 0, 不限制
@property (nonatomic, assign) CGFloat timeMaximum;

// 当达到最大值时，自动停止录音， 默认为YES
@property (nonatomic, assign) BOOL limitTimeMaximum;

// 格式
@property (nonatomic, retain) MMAudioFormat *format;

// 录音的文件
@property (nonatomic, retain) NSURL *localFile;

// 当前已经录制的时间
@property (nonatomic, readonly) float time;

@end

@interface MMAudioPlayer : MMAVObject

// 播放的录音，高优先级
@property (nonatomic, retain) NSURL *localFile;

// 或者，是录音的对象
@property (nonatomic, retain) MMAudioRecorder *recorder;

// 播放的位置
@property (nonatomic, retain) NSPercentage *percent;

@end

typedef enum {
    MMVI_TYPE_GENERAL,
    MMVI_TYPE_POI, // 地名
    MMVI_TYPE_SONG, // 歌曲
    MMVI_TYPE_MOVIETV, // 影视
    MMVI_TYPE_MEDICAL, // 医疗
} MMVI_TYPE;

typedef enum {
    MMVI_LANG_CHINESE,
    MMVI_LANG_ENGLISH,
    MMVI_LANG_CANTONESE, // 粤语
} MMVI_LANG;

typedef enum {
    MMVI_SAMPLERATE_16k,
    MMVI_SAMPLERATE_8k,
    MMVI_SAMPLERATE_AUTO,
} MMVI_SAMPLERATE;

// 语音输入
@interface MMVoiceInput : NSObjectExt

@property (nonatomic, assign) MMVI_TYPE type;
@property (nonatomic, assign) MMVI_LANG lang;
@property (nonatomic, assign) MMVI_SAMPLERATE samplerate;

- (void)execute;

@end

# endif
