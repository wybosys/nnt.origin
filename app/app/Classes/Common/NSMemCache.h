
# ifndef __NSMEMCACHE_B95556DFE2124F86BE0D2D4BC45A828B_H_INCLUDED
# define __NSMEMCACHE_B95556DFE2124F86BE0D2D4BC45A828B_H_INCLUDED

@interface NSObject (memcache)

// 强制刷新缓存, 默认为 NO.
@property (nonatomic, assign) BOOL mcFlush;

// 是否缓存发生更新
@property (nonatomic, readonly, assign) BOOL mcUpdated;

// 缓存的时间
@property (nonatomic, readonly, assign) time_t mcTimestamp;

// 缓存的过期时间
@property (nonatomic, assign) time_t mcTimestampOverdue;

// 缓存的唯一编号
@property (nonatomic, copy) NSString* uniqueKey;

// 附加在唯一编号之后，以用来识别同一uniquekey下的不同实现
@property (nonatomic, copy) NSString* uniqueKeyAddition;

// 缓存的值，不实现的话即为 self.
@property (nonatomic, assign) id uniqueValue;

// 是否已经过期
- (BOOL)mcOverdued;

// 永不过期
@property (nonatomic, assign) BOOL mcForever;

// 全尺寸的唯一码
- (NSString*)fullUniqueKey;

@end

enum {
    
    TM_SECOND_5 = 5,
    TM_SECOND_10 = 10,
    TM_SECOND_15 = 15,
    TM_SECOND_30 = 30,
    
    TM_MINUTE = 60,
    TM_MINUTE_5 = TM_MINUTE * 5,
    TM_MINUTE_10 = TM_MINUTE * 10,
    TM_MINUTE_15 = TM_MINUTE_5 + TM_MINUTE_10,
    TM_MINUTE_20 = TM_MINUTE * 20,
    TM_MINUTE_30 = TM_MINUTE * 30,
    
    TM_HOUR = TM_MINUTE * 60,
    TM_HOUR_2 = TM_HOUR * 2,
    TM_HOUR_3 = TM_HOUR * 3,
    TM_HOUR_6 = TM_HOUR * 6,
    TM_HOUR_12 = TM_HOUR * 12,
    
    TM_DAY = TM_HOUR * 24,
    TM_DAY_2 = TM_DAY * 2,
    TM_DAY_3 = TM_DAY * 3,
    TM_DAY_7 = TM_DAY * 7,
    
    TM_MONTH = TM_DAY * 30,
    TM_MONTH_6 = TM_MONTH * 6,
    
    TM_YEAR = TM_DAY * 365,
    
};

@interface NSMemCacheInfo : NSObject

@property (nonatomic, assign) NSULongLong size;

@end

@interface NSMemCache : NSObject

- (id)initWithPath:(NSString*)path;
+ (id)memcacheWithPath:(NSString*)path;

// 设置成默认的 Cache
- (void)makeDefaults;
+ (NSMemCache*)defaults;
+ (void)SetDefaults:(NSMemCache*)mc;

// 对象控制
- (void)addObject:(id)obj;
- (void)addObject:(id)obj withKey:(NSString*)key;
- (id)getObject:(NSString*)key;
- (void)removeObjectForKey:(NSString*)key;
- (id)getObjectDirect:(NSString*)key;

// 清空
- (void)clear;
- (void)clearOverdues;

// 键锁
//- (void)keyLock:(NSString*)key;
//- (void)keyUnlock:(NSString*)key;

// 缓存信息
@property (nonatomic, readonly) NSMemCacheInfo *info;

// 是否自动清理过期缓存，默认为NO
@property (nonatomic, assign) BOOL autoCleanOverdues;

@end

// 基本的对象缓存，不进行流量控制，只是一个 key-value 的管理结构
@interface NSObjectsCache : NSObjectExt

// 添加一个对象
- (void)addObject:(id)obj withKey:(id<NSCopying>)key;

// 获得到对象
- (id)objectForKey:(id<NSCopying>)key;

// 删除并弹出一个对象
- (id)popForKey:(id<NSCopying>)key;

// 删除 key 对应的对象
- (void)removeObjectForKey:(id<NSCopying>)key;

// 使用实例化方法来添加对象，如果存在，则直接返回现有对象
- (id)addInstance:(id(^)())obj withKey:(id<NSCopying>)key;

// 总数目
@property (nonatomic, readonly) NSInteger count;

// 清空
- (void)clear;

@end

// 使用流控的内存对象池
@interface NSFlymakeCache : NSObjectsCache

// 数量控制(使用最多、最近使用)，默认为100，当达到限制后，启动清理工作
@property (nonatomic, assign) NSInteger threshold, thresholdFifo;

// 清理的步进，默认为 threshold 的1/3
@property (nonatomic, assign) NSInteger stepTop, stepFifo;

@end

# endif
