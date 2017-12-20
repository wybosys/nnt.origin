
# import "Common.h"
# import "Audio+Extension.h"
# import <AudioToolbox/AudioToolbox.h>
# import <hdvoice/AFPlayer.h>
# import <hdvoice/AFRecorder.h>
# import <hdvoice/VoiceManager.h>
# import "FileSystem+Extension.h"
# import "NSWeakTypes.h"
# import "AppDelegate+Extension.h"

real kSystemAudioDefaultFPS = 1.f;

@implementation SystemAudio

SHARED_IMPL;

SIGNALS_BEGIN

SIGNAL_ADD(kSignalVibration)
[self.signals connect:kSignalVibration withSelector:@selector(cbVibration) ofTarget:self].fps = kSystemAudioDefaultFPS;

SIGNALS_END

- (void)cbVibration {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

+ (void)Vibration {
    [[SystemAudio shared].signals emit:kSignalVibration];
}

@end

@interface MMAudioSession ()

@property (nonatomic, readonly) NSWeakSet *recorders;
@property (nonatomic, readonly) NSWeakSet *players;

// 保存文件和player的对照表
@property (nonatomic, readonly) NSMutableDictionary *fileplayers;

@end

@implementation MMAudioSession

SHARED_IMPL;

- (void)onInit {
    [super onInit];
    _recorders = [[NSWeakSet alloc] init];
    _players = [[NSWeakSet alloc] init];
    _fileplayers = [[NSMutableDictionary alloc] init];
}

- (void)onFin {
    ZERO_RELEASE(_fileplayers);
    ZERO_RELEASE(_recorders);
    ZERO_RELEASE(_players);
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalStart)
SIGNAL_ADD(kSignalStop)
SIGNAL_ADD(kSignalFailed)
SIGNAL_ADD(kSignalValueChanged)
SIGNALS_END

- (void)stop {
    //[VoiceManager stopAll:YES];
    [self stopRecorders];
    [self stopPlayers];
}

- (void)stopPlayers {
    [_players foreach:^BOOL(MMAudioPlayer* player) {
        [player stop];
        return YES;
    }];
}

- (void)stopRecorders {
    [_recorders foreach:^BOOL(MMAudioRecorder* recorder) {
        [recorder stop];
        return YES;
    }];
}

- (MMAudioPlayer*)playerWithLocalFile:(NSURL*)url {
    if (url.isFileURL == NO) {
        WARN("只能播放本地文件");
        return nil;
    }
    
    MMAudioPlayer* player = [_fileplayers objectForKey:url];
    if (player)
        return player;
    
    player = [MMAudioPlayer temporary];
    player.localFile = url;
    
    // 绑定player
    [player.signals connect:kSignalStart withSelector:@selector(__auses_playstart:) ofTarget:self];
    [player.signals connect:kSignalStop withSelector:@selector(__auses_playstop:) ofTarget:self];
    [player.signals connect:kSignalFailed withSelector:@selector(__auses_playfailed:) ofTarget:self];
    [player.signals connect:kSignalValueChanged withSelector:@selector(__auses_playing:) ofTarget:self];
    
    return player;
}

- (void)__auses_playstart:(SSlot*)s {
    MMAudioPlayer* player = (id)s.sender;
    [_fileplayers setObject:player forKey:player.localFile];
    [self.signals emit:kSignalStart withResult:player];
}

- (void)__auses_playstop:(SSlot*)s {
    MMAudioPlayer* player = (id)s.sender;
    [self.signals emit:kSignalStop withResult:player];
    [_fileplayers removeObjectForKey:player.localFile];
}

- (void)__auses_playfailed:(SSlot*)s {
    MMAudioPlayer* player = (id)s.sender;
    [self.signals emit:kSignalFailed withResult:player];
    [_fileplayers removeObjectForKey:player.localFile];
}

- (void)__auses_playing:(SSlot*)s {
    MMAudioPlayer* player = (id)s.sender;
    [self.signals emit:kSignalValueChanged withResult:player];
}

@end

@implementation MMAudioFormat

- (void)onInit {
    [super onInit];
}

- (void)onFin {
    ZERO_RELEASE(_ext);
    [super onFin];
}

- (NSString*)ext {
    if (_ext)
        return _ext;
    
    NSString* ret = @"caf";
    return ret;
}

+ (instancetype)Recorder {
    MMAudioFormat* af = [[self alloc] init];
    af.format = kAudioFormatiLBC;
    af.samplerate = 8000;
    af.channel = 1;
    return [af autorelease];
}

@end

@implementation MMAudioSample

@end

@interface MMAVObject ()

@property (nonatomic, assign) BOOL running;

@end

@implementation MMAVObject

- (void)onInit {
    [super onInit];
    _enable = YES;
    _running = NO;
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalEnabled)
SIGNAL_ADD(kSignalDisabled)
SIGNAL_ADD(kSignalEnableChanged)
SIGNALS_END

- (void)start {
    PASS;
}

- (void)stop {
    PASS;
}

- (BOOL)sample:(MMAudioSample *)amp {
    return NO;
}

- (void)setEnable:(BOOL)enable {
    if (_enable == enable)
        return;
    
    _enable = enable;
    if (_enable)
        [self.touchSignals emit:kSignalEnabled];
    else
        [self.touchSignals emit:kSignalDisabled];
    [self.touchSignals emit:kSignalEnableChanged withResult:[NSBoolean boolean:_enable]];
}

@end

@interface MMAudioRecorder ()
<RecorderDelegate>

@property (nonatomic, readonly) AFRecorder *recorder;

// 录音的计时器
@property (nonatomic, retain) NSTimer *tmrRecorder;

@end

@implementation MMAudioRecorder

- (void)onInit {
    [super onInit];
    
    self.format = [MMAudioFormat Recorder];
    self.limitTimeMaximum = YES;
    
    _recorder = [[AFRecorder alloc] init];
    _recorder.delegate = self;
    _recorder.enableMeters = kIOS5Above;
    
    [[MMAudioSession shared].recorders addObject:self];
}

- (void)onFin {
    [[MMAudioSession shared].recorders removeObject:self];
    
    // 停止录制
    [self stop];
    
    // 清除状态
    _recorder.delegate = nil;
    
    ZERO_RELEASE(_recorder);
    ZERO_RELEASE(_localFile);
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalStart)
SIGNAL_ADD(kSignalStop)
SIGNAL_ADD(kSignalFailed)
SIGNAL_ADD(kSignalSucceed)
SIGNAL_ADD(kSignalValueChanged)
SIGNAL_ADD(kSignalReachMin)
SIGNAL_ADD(kSignalReachMax)
SIGNALS_END

- (BOOL)running {
    return self.recorder.recording;
}

- (void)start {
    if (self.running)
        return;
    
    if ((self.timeMinimum || self.timeMaximum) && self.timeMinimum >= self.timeMaximum) {
        THROW(@"最大时间需要大于最小时间");
        return;
    }
    
    // 需要结束其他的声音
    [[MMAudioSession shared] stop];;
    
    // 清除当前录制的时间
    _time = 0;
    
    if (self.timeMinimum)
        self.recorder.minRecordTime = self.timeMinimum;
    if (self.timeMaximum)
        self.recorder.maxRecordTime = self.timeMaximum;
    
    // 临时的目录
    if (self.localFile == nil) {
        NSString* fp = [[FSApplication shared].pathTemporary stringByAppendingFormat:@".%@", self.format.ext];
        self.localFile = [NSURL fileURLWithPath:fp];
    }
    
    // 需要直接发送启动的信号，有可能会有其他流程需要进行录音准备
    [self.signals emit:kSignalStart];
    
    // 一补录音
    DISPATCH_ASYNC({
        BOOL suc = [self.recorder start:self.localFile.filePath
                                 format:self.format.format
                             sampleRate:self.format.samplerate
                               channels:self.format.channel];
        if (suc)
        {
            PASS;
        }
        else
        {
            LOG("启动录音失败");
            [self.signals emit:kSignalFailed];
            [self.signals emit:kSignalStop];
        }
    });
}

- (void)stop {
    if (!self.running)
        return;
    
    [self doStop];
}

- (BOOL)sample:(MMAudioSample *)amp {
    amp.peakPower = self.recorder.peakPower;
    amp.averagePower = self.recorder.averagePower;
    return YES;
}

- (void)doStop {
    [self.recorder stop];
    
    // 停止计时器
    [self.tmrRecorder invalidate];
    self.tmrRecorder = nil;
}

- (void)tmrUpdateRecorder {
    _time = self.recorder.currentTime;
    [self.signals emit:kSignalValueChanged withResult:@(_time)];
}

- (void)didStartRecord:(Recorder*)recorder {
    LOG("开始录音 %s", self.localFile.filePath.UTF8String);
    
    // 启动计时器
    DISPATCH_ASYNC_ONMAIN({
        self.tmrRecorder = [NSTimer scheduledTimerWithTimeInterval:.1f
                                                            target:self
                                                          selector:@selector(tmrUpdateRecorder)
                                                          userInfo:nil
                                                           repeats:YES];
    });
}

- (void)didFinishRecord:(Recorder *)recorder successfully:(BOOL)flag duration:(int)duration {
    LOG("结束录音 %s", self.localFile.filePath.UTF8String);
    
    // 停止计时器
    [self.tmrRecorder invalidate];
    self.tmrRecorder = nil;
    
    // 发送信号
    [self.signals emit:kSignalStop];

    // 失败
    if (!flag) {
        LOG("录音失败");
        [self.signals emit:kSignalFailed];
        return;
    }
    
    // 如果录音时长小于指定时长，则失败
    if (duration < self.timeMinimum) {
        LOG("因为录制的时间小于最小时间，所以录制失败");
        [self.signals emit:kSignalFailed];
        return;
    }
    
    [self.signals emit:kSignalSucceed];
}

- (void)didTriggerRecordTime:(RecordTimeTrigger)trigger {
    if (trigger == kRecordTimeTriggerMin)
    {
        LOG("录音达到最小值");
        [self.signals emit:kSignalReachMin];
    }
    else
    {
        LOG("录音超过最大值");
        [self.signals emit:kSignalReachMax];
        
        // 如果限制最大大小，则自动停止录音
        if (self.limitTimeMaximum)
            [self stop];
    }
}

@end

@interface MMAudioPlayer ()
<PlayerDelegate>

@property (nonatomic, readonly) AFPlayer *player;
@property (nonatomic, retain) NSTimer *tmrPlay;

@end

@implementation MMAudioPlayer

- (void)onInit {
    [super onInit];
    
    _player = [[AFPlayer alloc] init];
    _player.delegate = self;
    _player.enableMeters = kIOS5Above;
    
    [[MMAudioSession shared].players addObject:self];
}

- (void)onFin {
    [[MMAudioSession shared].players removeObject:self];
    
    // 停止播放
    [self stop];
    
    // 清除状态
    _player.delegate = nil;
    
    ZERO_RELEASE(_player);
    ZERO_RELEASE(_localFile);
    ZERO_RELEASE(_recorder);
    ZERO_RELEASE(_percent);
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalStart)
SIGNAL_ADD(kSignalStop)
SIGNAL_ADD(kSignalFailed)
SIGNAL_ADD(kSignalValueChanged)
SIGNALS_END

/*
 // 状态回调有问题，所以自己管理
- (BOOL)playing {
    return self.player.playing;
}
 */

- (NSString*)filepath {
    if (_localFile)
        return _localFile.filePath;
    if (self.recorder && self.recorder.localFile)
        return self.recorder.localFile.filePath;
    return @"";
}

- (void)start {
    if (self.running)
        return;
    
    if (self.filepath.notEmpty == NO) {
        LOG("因为没有传入文件路径所以不能播放");
        return;
    }
    
    // 需要结束其他的声音
    [[MMAudioSession shared] stop];
    
    // 需要直接发送启动的信号，有可能会有其他流程需要进行录音准备
    [self.signals emit:kSignalStart];
    
    DISPATCH_ASYNC({
        BOOL suc = [self.player start:self.filepath];
        if (suc)
        {
            PASS;
        }
        else
        {
            LOG("启动播放失败");
            [self.signals emit:kSignalFailed];
            [self.signals emit:kSignalStop];
        }
    });
}

- (void)stop {
    if (!self.running)
        return;
    
    // 停止计时器
    [self.tmrPlay invalidate];
    self.tmrPlay = nil;
    
    // 停止
    [self.player stop];
}

- (void)tmrUpdatePlay {
    NSTimeInterval all = self.player.duration;
    NSTimeInterval cur = self.player.currentTime;
    self.percent = [NSPercentage percentWithMax:all value:cur];
    [self.signals emit:kSignalValueChanged withResult:self.percent];
}

- (void)didStartPlay:(Player*)player {
    LOG("开始播放 %s", self.filepath.UTF8String);
    
    self.running = YES;
    
    // 启动计时器
    DISPATCH_ASYNC_ONMAIN({
        self.tmrPlay = [NSTimer scheduledTimerWithTimeInterval:.1f
                                                        target:self
                                                      selector:@selector(tmrUpdatePlay)
                                                      userInfo:nil
                                                       repeats:YES];
    });
}

- (void)didFinishPlay:(Player *)player interrupted:(BOOL)flag duration:(int)duration {
    if (self.running == NO) {
        // 根本没有播放过，属于底层的多余通知，所以要滤过
        return;
    }
    
    LOG("播放完成 %s", self.filepath.UTF8String);
    
    // 停止计时器
    [self.tmrPlay invalidate];
    self.tmrPlay = nil;
    
    // 设置状态
    self.running = NO;
    
    // 发送信号
    [self.signals emit:kSignalStop];
}

- (void)didWaveDataUpdated:(Player*)player {
    PASS;
}

@end

# if !defined(IOS_SIMULATOR) && 0
#   define HAS_YZS
# endif

# ifdef HAS_YZS
#  import "USCRecognizerDialog.h"
# endif

@interface MMVoiceInput ()
# ifdef HAS_YZS
<USCRecognizerDialogDelegate>

@property (nonatomic, readonly) USCRecognizerDialog *usc;

# endif
@end

@implementation MMVoiceInput

SHARED_IMPL;

- (void)onInit {
    [super onInit];
    
# ifdef HAS_YZS
    _usc = [[USCRecognizerDialog alloc] initWithAppKey:@"u44gycygksj644lp3fvyw3k3jiqxiaekaleblpy6"];
    _usc.delegate = self;
    [_usc setPunctuation:NO];
# endif
}

- (void)onFin {
# ifdef HAS_YZS
    ZERO_RELEASE(_usc);
# endif
    [super onFin];
}

- (void)execute {
# ifdef HAS_YZS
    
    switch (_type)
    {
        case MMVI_TYPE_GENERAL: [_usc setEngine:@"general"]; break;
        case MMVI_TYPE_POI: [_usc setEngine:@"poi"]; break;
        case MMVI_TYPE_SONG: [_usc setEngine:@"song"]; break;
        case MMVI_TYPE_MOVIETV: [_usc setEngine:@"movietv"]; break;
        case MMVI_TYPE_MEDICAL: [_usc setEngine:@"medical"]; break;
    }
    
    switch (_samplerate)
    {
        case MMVI_SAMPLERATE_16k: [_usc setSampleRate:16000]; break;
        case MMVI_SAMPLERATE_8k: [_usc setSampleRate:8000]; break;
        case MMVI_SAMPLERATE_AUTO: [_usc setSampleRate:400]; break;
    }
    
    switch (_lang)
    {
        case MMVI_LANG_CHINESE: [_usc setLanguage:@"chinese"]; break;
        case MMVI_LANG_ENGLISH: [_usc setLanguage:@"english"]; break;
        case MMVI_LANG_CANTONESE: [_usc setLanguage:@"cantonese"]; break;
    }
    
    UIView* view = [UIAppDelegate shared].topmostViewController.view;
    [_usc showInView:view];
    
    SAFE_RETAIN(self);
    return;
# endif
    
    [UIHud Text:@"此设备不支持这个功能"];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalValueChanged)
SIGNALS_END

- (void)onResult:(NSString *)result isLast:(BOOL)isLast {
    [self.signals emit:kSignalValueChanged withResult:result];
}

- (void)onEnd:(NSError *)error {
    [error log];
    
    // 延迟释放，不然会崩溃
    [self performSelector:@selector(release) withObject:self afterDelay:1];
}

@end
