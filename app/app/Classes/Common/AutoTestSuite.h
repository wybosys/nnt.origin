
/** 单次的动作 */
@interface AutoTestAction : NSObjectExt

/** 位置相关 */
@property (nonatomic, retain) NSPoint *position;

/** 大小相关 */
@property (nonatomic, retain) NSSize *size;

/** 同时引发的信号 */
@property (nonatomic, retain) SSignal *signal;

/** 依赖的类 */
@property (nonatomic, assign) Class type;

/** 重现 */
- (void)play;

@end

/** 录制的单次测试脚本 */
@interface AutoTestProfile : NSObjectExt

@property (nonatomic, retain) NSString *name; // 名称
@property (nonatomic, retain) NSDate *time; // 创建时间
@property (nonatomic, readonly, retain) NSString *path; // 路径

/** 加载该脚本 */
- (void)load;

/** 释放 */
- (void)unload;

/** 开始录制 */
- (void)record;

/** 结束录制 */
- (void)stop;

/** 播放 */
- (void)play;

@end

@interface AutoTestSuite : NSObjectExt

/** 启动自动测试环境 */
+ (void)Launch;

/** 打开 */
- (void)start;

/** 当前存在的测试脚本 */
@property (nonatomic, readonly) NSArray *profiles;

/** 录制 */
- (AutoTestProfile*)record;

/** 正在录制的脚本 */
@property (nonatomic, readonly, retain) AutoTestProfile *recordingProfile;

@end
