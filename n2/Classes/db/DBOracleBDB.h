
# ifndef __DBORACLEBDB_A532147F56964779B167C4BB3595155E_H_INCLUDED
# define __DBORACLEBDB_A532147F56964779B167C4BB3595155E_H_INCLUDED

# import "DBConfig.h"

@interface OracleBDBInfo : NSObject

@property (nonatomic, assign) NSULongLong size;

@end

@interface OracleBDB : NSObject

- (id)init;
- (id)initWithConfig:(DBConfig*)cfg;

// 打开数据库
+ (OracleBDB*)dbWithConfig:(DBConfig*)cfg;

// 打开数据库
- (BOOL)open:(DBConfig*)cfg;

// 关闭
- (void)close;

// 同步
- (void)sync;

// 清空
- (void)clear;

// 是否存在key
- (BOOL)exist:(NSString*)key;

// 值操作相关
- (BOOL)setBool:(bool)v forKey:(NSString*)key;
- (BOOL)setInteger:(NSInteger)v forKey:(NSString*)key;
- (BOOL)setObject:(id)v forKey:(NSString *)key;

- (id)objectForKey:(NSString*)key;
- (BOOL)removeForKey:(NSString*)key;

// 遍历
- (void)foreach:(BOOL(^)(id k, id v))block;

// 数据库信息
@property (nonatomic, readonly) OracleBDBInfo *info;

@end

# endif
