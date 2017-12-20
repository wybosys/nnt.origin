
# ifndef __NSCRON_F3066F3612464C36A4BB2F6986EDBF91_H_INCLUDED
# define __NSCRON_F3066F3612464C36A4BB2F6986EDBF91_H_INCLUDED

/*
 类似于crontab(posix)，但根据ios的特点修改为 秒 分 时 的配置，去除 日 月 年 的设置
 时间起点为程序运行时起，而不是原版的按照标准系统时间来算
 */

@interface NSCronItem : NSObject

+ (id)itemWith:(NSString*)def;

@end

SIGNAL_DECL(kSignalCronActive) @"::cron::active";

@interface NSCron : NSThread

+ (NSCron*)shared;

// 控制函数
- (void)start;
- (void)pause;
- (void)stop;

// 条目
- (NSCronItem*)add:(NSCronItem*)item;
- (NSCronItem*)addConfig:(NSString*)config;

@end

# endif
