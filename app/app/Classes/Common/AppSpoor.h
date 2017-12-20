
# ifndef __APPSPOOR_1C8078D320284586A9BC77C8B269EE3F_H_INCLUDED
# define __APPSPOOR_1C8078D320284586A9BC77C8B269EE3F_H_INCLUDED

/** 程序的跟踪器 */
@interface AppSpoor : NSObject

/** 启动 */
+ (void)Launch;

/** 启动跟踪 */
- (void)start;

@end

/** 系统进程 */
@interface SystemProcesse : NSObject

@property (nonatomic, assign) int pid;
@property (nonatomic, copy) NSString *name, *path;

+ (NSArray*)MyProcesses;

@end

/** App 的包信息 */
@interface AppBundleInfo : NSObject

@property (nonatomic, retain) NSString *identifier, *name, *nickname, *process, *version, *home, *path;

@end

/** App 的 schemes 信息 */
@interface AppSchemesInfo : NSObject

@property (nonatomic, retain) NSArray* items;

@end

/** 系统应用 */
@interface SystemApplication : NSObject

@property (nonatomic, retain) AppBundleInfo *bundle;
@property (nonatomic, retain) AppSchemesInfo *schemes;

+ (NSArray*)AllInstalled;

@end

# endif
