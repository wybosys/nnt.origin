
# ifndef __SYSTEMFEATURES_DC49D78552B84DAD9ACCED4F294FF6BF_H_INCLUDED
# define __SYSTEMFEATURES_DC49D78552B84DAD9ACCED4F294FF6BF_H_INCLUDED

/** 地理位置信息 */
@interface NSLocationInfo : NSObjectExt

@property (nonatomic, readonly) CLLocation *locationValue, *fromLocation;

/** 反向解析出来的位置附加信息 
 @note 市、省、街道、门牌、地址、行政区、商业区
 */
@property (nonatomic, readonly) NSString *city, *province, *street, *number, *address, *district, *business;

@end

/** 位置服务
 @note
 提供功能：
 获取当前的位置
 跟踪当前位置的变化
 附带位置的可读信息
 */
@interface NSLocationService : NSObjectExt

/** 获取一次数据
 @note 会通过 kSignalLocationChanged 信号返回
 */
- (void)fetch;

/** 启动服务 */
- (void)start;

/** 关闭服务 */
- (void)stop;

/** 是否反向解析地址信息，默认为 NO */
@property (nonatomic, assign) BOOL decodesInfo;

/** 是否进行火星坐标转换，默认为 NO */
@property (nonatomic, assign) BOOL offsetChina;

/** 是否正在运行 */
@property (nonatomic, readonly) BOOL running;

/** 反向解析地址 */
- (void)decode:(CLLocationCoordinate2D)location;

@end

SIGNAL_DECL(kSignalLocationChanged) @"::ui::location::changed";
SIGNAL_DECL(kSignalDecodeSucceed) @"::ns::decoded::succeed";
SIGNAL_DECL(kSignalDecodeFailed) @"::ns::decoded::failed";

/** 推送服务 */
@interface NSApnsService : NSObjectExt

@property (nonatomic, assign) BOOL badge, sound, alert;
@property (nonatomic, readonly) BOOL running;

- (void)start;
- (void)stop;

@end

/** app在 home 界面中的角标服务 */
@interface NSAppBadgeService : NSObjectExt

@property (nonatomic, assign) int value;

@end

/** 用于不同APP之间分享数据 */
@interface NSIpcService : NSObjectExt

/** 名字
 @note 不同 app 中只有设置一样才能获得到同一个数据
 */
@property (nonatomic, copy) NSString* name;

/** 操作对象 */
- (void)setObject:(id<NSCoding>)obj forKey:(id<NSCopying>)key;
- (id)objectForKey:(id)key;

/** 清空 */
- (void)removeAllObjects;

/** 用来拿数据的字典 */
@property (nonatomic, readonly) NSDictionary* objects;

@end

/** 对对应于联系人中取得的每一个数据 */
@interface NSAddressBookContact : NSObjectExt

@property (nonatomic, retain) NSString
*firstname,
*lastname,
*middlename,
*nickname;

@property (nonatomic, retain) NSMutableArray* phones; // NSPair, first:key, second:phone.
@property (nonatomic, readonly) NSString *primaryPhone, *primaryPhoneLabel;

@end

/** 联系人列表 */
@interface NSAddressBook : NSObjectExt

/** 是否可用 */
+ (BOOL)isAvaliable;

/** 读取所有的联系人, 返回 NSAddressBookContact 的数组 */
- (NSArray*)allContacts;

@end

/** 编辑短信 */
@interface NSComposeSMS : NSObjectExt

/** 是否存在短信功能 */
+ (BOOL)isAvaliable;

/** 发送短信 */
- (void)sendText:(NSString*)text to:(NSString*)phone;

/** 给同一个人的一组号码发短信 */
- (void)sendText:(NSString*)text phone:(NSArray*)phones;

/** 给好几个人发短信 */
- (void)sendTexts:(NSString*)text phones:(NSArray*)phones;

@end

/** 打电话 */
@interface NSDialPhone : NSObjectExt

/** 是否存在电话功能 */
+ (BOOL)isAvaliable;

/** 打电话，传入电话号码 */
- (void)dial:(NSString*)phone;

@end

/** TouchID验证 */
@interface NSTouchIDService : NSObjectExt

/** 请求授权时的提示 */
@property (nonatomic, retain) NSString* message;

/** 是否能存在TouchID的功能 */
+ (BOOL)isAvaliable;

/** 授权 */
- (void)authorize;

@end

/** 文本朗读 */
@interface NSTTSService : NSObjectExt

/** 是否可以TTS */
+ (BOOL)isAvaliable;

/** 朗读文本 */
- (void)speak:(NSString*)string;

@end

extern NSTimeInterval kNSPostureServiceDefaultDuration;

/** 姿态服务 */
@interface NSPostureService : NSObjectExt

/** 刷新的间隔 */
@property (nonatomic, assign) NSTimeInterval durationAccelerometer, durationGyro;

/** 数据 */
@property (nonatomic, readonly, retain) NSPoint3d *accelerometer, *gyro, *magneto;

/** 是否打开接近传感器，默认为 NO */
@property (nonatomic, readonly, assign) BOOL neared;

/** 获得数据的百分数 */
@property (nonatomic, readonly) CGPoint3d percentAccelerometer, percentGyro;

/** 全部启用
@note 因为接近传感器启动会导致靠近时屏幕黑掉，所以默认启动所有时不包括启动接近传感器
 */
- (void)start;

/** 停止服务 */
- (void)stop;

/** 加速度是否可用 */
- (BOOL)isAccelerometerAvailable;

/** 加速度服务是否正在运行 */
- (BOOL)isAccelerometerRunning;

/** 陀螺仪是否可用 */
- (BOOL)isGyroAvailable;

/** 陀螺仪服务是否正在运行 */
- (BOOL)isGyroRunning;

/** 磁场传感器 */
- (BOOL)isMagnetoAvailable;

/** 磁场传感器是否正在运行 */
- (BOOL)isMagnetoRunning;

/** 启动加速度 */
- (void)startAccelerometer;
- (void)stopAccelerometer;

/** 启动陀螺仪 */
- (void)startGyro;
- (void)stopGyro;

/** 启动磁场强度计 */
- (void)startMagneto;
- (void)stopMagneto;

/** 启动接近传感器 */
- (void)startNear;
- (void)stopNear;

@end

SIGNAL_DECL(kSignalAccelerometerStarted) @"::ns::accelerometer::started";
SIGNAL_DECL(kSignalAccelerometerStopped) @"::ns::accelerometer::stopped";
SIGNAL_DECL(kSignalAccelerometerChanged) @"::ns::accelerometer::changed";
SIGNAL_DECL(kSignalGyroStarted) @"::ns::gyro::started";
SIGNAL_DECL(kSignalGyroStopped) @"::ns::gyro::stopped";
SIGNAL_DECL(kSignalGyroChanged) @"::ns::gyro::changed";
SIGNAL_DECL(kSignalMagnetoStarted) @"::ns::magneto::started";
SIGNAL_DECL(kSignalMagnetoStopped) @"::ns::magneto::stopped";
SIGNAL_DECL(kSignalMagnetoChanged) @"::ns::magneto::changed";
SIGNAL_DECL(kSignalNearGot) @"::ns::near::got";
SIGNAL_DECL(kSignalNearLost) @"::ns::near::lost";
SIGNAL_DECL(kSignalNearChagned) @"::ns::near::changed";

/** 计步器数据 */
@interface NSWalkerInfo : NSObjectExt

/** 楼层 */
@property (nonatomic, assign) float floor;

/** 米 */
@property (nonatomic, assign) float distance;

/** 走了多少步 */
@property (nonatomic, assign) NSInteger steps;

@end

/** 计步器服务 */
@interface NSWalkerService : NSObjectExt

/** 统计数据 */
@property (nonatomic, readonly) NSWalkerInfo *info;

/** 全部传感器 */
- (void)start;
- (void)stop;

/** 计步器服务 */
- (BOOL)isStepCountAvailable;
- (BOOL)isStepCountRunning;
- (void)startStepCount;
- (void)stopStepCount;

/** 里程计服务 */
- (BOOL)isPedometerAvailable;
- (BOOL)isPedometerRunning;
- (void)startPedometer;
- (void)stopPedometer;

@end

SIGNAL_DECL(kSignalWalkerStepStarted) @"::ns::walker::step::started";
SIGNAL_DECL(kSignalWalkerStepStopped) @"::ns::walker::step::stopped";
SIGNAL_DECL(kSignalWalkerStepChanged) @"::ns::walker::step::changed";
SIGNAL_DECL(kSignalPedometerStarted) @"::ns::pedometer::started";
SIGNAL_DECL(kSignalPedometerStopped) @"::ns::pedometer::stopped";
SIGNAL_DECL(kSignalPedometerChanged) @"::ns::pedometer::changed";

@interface NSSystemLogRecord : NSObjectExt

@end

/** 系统日志服务 */
@interface NSSystemLogService : NSObjectExt

typedef enum {
    kNSSystemLogLevelEmerg = 0,
    kNSSystemLogLevelAlert,
    kNSSystemLogLevelCrit,
    kNSSystemLogLevelErr,
    kNSSystemLogLevelWarning,
    kNSSystemLogLevelNotice,
    kNSSystemLogLevelInfo,
    kNSSystemLogLevelDebug,
    kNSSystemLogLevelCount, // 标记有多少个而已
    kNSSystemLogLevelAll = -1, // 全部日志
} NSSystemLogLevel;

/** 查询指定等级的日志 */
- (NSArray*)logsForLevel:(NSSystemLogLevel)level;

@end

# endif
