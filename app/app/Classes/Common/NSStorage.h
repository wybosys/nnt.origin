
# ifndef __NSSTORAGE_4CF795D8E70E409B839DDD49A4F41CEF_H_INCLUDED
# define __NSSTORAGE_4CF795D8E70E409B839DDD49A4F41CEF_H_INCLUDED

@interface NSStorageInfo : NSObject

@property (nonatomic, assign) NSULongLong size;

@end

@interface NSStorageExt : NSObject

// 自动持久化，默认为 true
@property (nonatomic, assign) BOOL autoSync;

- (id)init;
- (id)initWithPath:(NSString*)path;

+ (NSStorageExt*)storageForPath:(NSString*)path;

// 通用的
+ (NSStorageExt*)shared;

// 保存读取的匹配函数
- (void)setBool:(bool)v forKey:(NSString*)key;
- (void)setInteger:(NSInteger)v forKey:(NSString*)key;
- (void)setFloat:(float)v forKey:(NSString*)key;
- (void)setDouble:(double)v forKey:(NSString*)key;
- (void)setString:(NSString*)v forKey:(NSString*)key;
- (void)setObject:(id<NSCoding>)v forKey:(NSString*)key;

- (bool)getBoolForKey:(NSString*)key def:(bool)def;
- (NSInteger)getIntegerForKey:(NSString*)key def:(int)def;
- (float)getFloatForKey:(NSString*)key def:(float)def;
- (double)getDoubleForKey:(NSString*)key def:(double)def;
- (NSString*)getStringForKey:(NSString*)key def:(NSString*)def;
- (id)getObjectForKey:(NSString*)key def:(id)def;
- (NSData*)getDataForKey:(NSString*)key def:(NSData*)def;

// 操作array
- (void)addObject:(id<NSCoding>)v arrayKey:(NSString*)key;
- (id)objectAtIndex:(NSUInteger)idx arrayKey:(NSString*)key def:(id)def;
- (id)objectAtIndex:(NSUInteger)idx arrayKey:(NSString*)key;

// 遍历所有的对象
- (void)foreach:(BOOL(^)(id k, id v))block;

// 是否存在key
- (BOOL)exists:(NSString*)key;

// 删除
- (BOOL)remove:(NSString*)key;

// 清空
- (void)clear;

// 持久化
- (void)sync;

// 数据库信息
@property (nonatomic, readonly) NSStorageInfo *info;

@end

// 持久化
@interface NSPersistentStorageService : NSObjectExt

- (void)setObject:(id<NSCoding>)obj forKey:(NSString*)key;
- (id)getObjectForKey:(NSString*)key def:(id)def;
- (BOOL)remove:(NSString*)key;
- (BOOL)exists:(NSString*)key;

@end

# endif
