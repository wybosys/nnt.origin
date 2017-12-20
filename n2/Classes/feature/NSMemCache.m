
# import "Common.h"
# import "NSMemCache.h"
# import "NSStorage.h"
# import "AppDelegate+Extension.h"
# import "FileSystem+Extension.h"

// 是否启动调整模式，默认应该注销，只在开发时使用
//# define TUNE_MODE

@implementation NSMemCacheInfo

@end

@implementation NSObject (memcache)

@dynamic mcFlush;
@dynamic mcTimestamp, mcTimestampOverdue, mcUpdated;
@dynamic uniqueValue;

static void* __nsobject_key_flush;

- (BOOL)mcFlush {
    return [objc_getAssociatedObject(self, &__nsobject_key_flush) boolValue];
}

- (void)setMcFlush:(BOOL)mcFlush {
    objc_setAssociatedObject(self, &__nsobject_key_flush, [NSNumber numberWithBool:mcFlush], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

NSOBJECT_DYNAMIC_PROPERTY(NSObject, uniqueKey, setUniqueKey, COPY_NONATOMIC);
NSOBJECT_DYNAMIC_PROPERTY(NSObject, uniqueKeyAddition, setUniqueKeyAddition, COPY_NONATOMIC)

static void* __nsobject_key_uniquevalue;

- (id)uniqueValue {
    id ret = objc_getAssociatedObject(self, &__nsobject_key_uniquevalue);
    if (ret == nil)
        return self;
    return ret;
}

- (void)setUniqueValue:(id)uniqueValue {
    objc_setAssociatedObject(self, &__nsobject_key_uniquevalue, uniqueValue, OBJC_ASSOCIATION_ASSIGN);
}

static void* __nsobject_key_mcupdated;

- (BOOL)mcUpdated {
    id ret = objc_getAssociatedObject(self, &__nsobject_key_mcupdated);
    if (ret == nil)
        return YES;
    return [ret boolValue];
}

- (void)setMcUpdated:(BOOL)mcUpdated {
    objc_setAssociatedObject(self, &__nsobject_key_mcupdated, [NSNumber numberWithBool:mcUpdated], OBJC_ASSOCIATION_RETAIN);
}

static void* __nsobject_key_mctimestamp;

- (time_t)mcTimestamp {
    id ret = objc_getAssociatedObject(self, &__nsobject_key_mctimestamp);
    if (ret == nil) {
        time_t tm = time(NULL);
        self.mcTimestamp = tm;
        return tm;
    }
    return [ret timestampValue];
}

- (void)setMcTimestamp:(time_t)mcTimestamp {
    objc_setAssociatedObject(self, &__nsobject_key_mctimestamp, [NSNumber numberWithTimestamp:mcTimestamp], OBJC_ASSOCIATION_RETAIN);
}

static void* __nsobject_key_mctimestampoverdue;

- (time_t)mcTimestampOverdue {
    return [objc_getAssociatedObject(self, &__nsobject_key_mctimestampoverdue) timestampValue];
}

- (void)setMcTimestampOverdue:(time_t)mcTimestampOverdue {
    objc_setAssociatedObject(self, &__nsobject_key_mctimestampoverdue, [NSNumber numberWithTimestamp:mcTimestampOverdue], OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)mcOverdued {
    if (self.mcTimestampOverdue < 0)
        return NO;
    
    time_t cur = time(NULL);
    time_t old = self.mcTimestamp + self.mcTimestampOverdue;
    return cur >= old;
}

- (void)setMcForever:(BOOL)mcForever {
    if (mcForever)
        self.mcTimestampOverdue = -1;
    else
        self.mcTimestampOverdue = 0;
}

- (BOOL)mcForever {
    return self.mcTimestampOverdue == -1;
}

- (NSString*)fullUniqueKey {
    NSString* uk = self.uniqueKey;
    NSString* uka = self.uniqueKeyAddition;
    if (uka == nil)
        return uk;
    if (uk == nil)
        return nil;
    return [NSString stringWithFormat:@"[uk:%@]-[uka:%@]", uk, uka];
}

@end

@interface NSMemCache () {
    NSMutableDictionary *_lockkeys;
}

@property (nonatomic, readonly) NSStorageExt* db;

@end

@implementation NSMemCache

- (id)init {
    self = [super init];
    
    self.autoCleanOverdues = NO;
    _lockkeys = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (id)initWithPath:(NSString *)path {
    self = [self init];
    
    _db = [[NSStorageExt alloc] initWithPath:path];
    //_db.autoSync = NO;
    
    // 切换到后台时同步一下
    [[UIAppDelegate shared].signals connect:kSignalAppDeactiving withSelector:@selector(sync) ofTarget:_db];
    
    return self;
}

+ (id)memcacheWithPath:(NSString *)path {
    return [[[NSMemCache alloc] initWithPath:path] autorelease];
}

- (void)dealloc {
    ZERO_RELEASE(_lockkeys);
    ZERO_RELEASE(_db);
    
    [super dealloc];
}

- (void)setAutoCleanOverdues:(BOOL)autoCleanOverdues {
    if (_autoCleanOverdues == autoCleanOverdues)
        return;
    
    [[UIAppDelegate shared].signals disconnectWithSelector:@selector(clearOverdues) ofTarget:self];
    
    if (_autoCleanOverdues) {
        [[UIAppDelegate shared].signals connect:kSignalAppDeactiving withSelector:@selector(clearOverdues) ofTarget:self];
    }
}

static NSMemCache* __gs_memcache_defaults = nil;

- (void)makeDefaults {
    PROPERTY_RETAIN(__gs_memcache_defaults, self);
}

+ (NSMemCache*)defaults {
    SYNCHRONIZED_BEGIN
    if (__gs_memcache_defaults == nil) {
        NSMemCache* mc = [NSMemCache memcacheWithPath:[[FSApplication shared] pathWritable:@"memcache.db"]];
        [mc makeDefaults];
        return mc;
    }
    SYNCHRONIZED_END
    return __gs_memcache_defaults;
}

+ (void)SetDefaults:(NSMemCache *)mc {
    PROPERTY_RETAIN(__gs_memcache_defaults, mc);
}

- (void)addObject:(id)obj {
    [self addObject:obj withKey:[obj uniqueKey]];
}

- (void)addObject:(id)obj withKey:(NSString *)key {
    // 存在更新
    [obj setMcUpdated:YES];
    
    NSMutableDictionary* da = [[NSMutableDictionary alloc] init];
    [da setObject:obj forKey:@"obj"];
    [da setTimestamp:[obj mcTimestamp] forKey:@"timestamp"];
    [da setTimestamp:[obj mcTimestampOverdue] forKey:@"overdue"];
    
    // 写入新数据
    [_db setObject:da forKey:key];
    
    SAFE_RELEASE(da);
}

- (id)getObject:(NSString*)key {
    id da = [_db getObjectForKey:key def:nil];
    if (da == nil) {
        LOG("缓存命中失败");
        return nil;
    }
    
    id ret = [da objectForKey:@"obj"];
    if (ret == nil) {
        LOG("缓存数据格式失败");
        return nil;
    }
    
    // 恢复
    [ret setMcTimestamp:[da getTimestamp:@"timestamp" def:0]];
    [ret setMcTimestampOverdue:[da getTimestamp:@"overdue" def:0]];
    
    // 判断是不是过期
    if ([ret mcOverdued]) {
        //[_db remove:key];
        LOG("缓存过期");
        return nil;
    }
    
    // 不存在更新
    [ret setMcUpdated:NO];
    
    LOG("缓存命中成功");
    
    return ret;
}

- (void)removeObjectForKey:(NSString *)key {
    [_db remove:key];
}

- (id)getObjectDirect:(NSString *)key {
    id da = [_db getObjectForKey:key def:nil];
    if (da == nil)
        return nil;
    
    id ret = [da objectForKey:@"obj"];
    
    // 不存在更新
    [ret setMcUpdated:NO];
    
    return ret;
}

- (NSMemCacheInfo*)info {
    NSMemCacheInfo* ret = [NSMemCacheInfo temporary];
    NSStorageInfo* dbinfo = _db.info;
    ret.size = dbinfo.size;
    return ret;
}

- (void)clear {
    [_db clear];
}

- (void)clearOverdues {
    [_db foreach:^BOOL(id k, id v) {
        if ([v mcOverdued]) {
            [_db setObject:nil forKey:k];
        }
        return YES;
    }];
}

/*
- (void)keyLock:(NSString *)key {
    NSObject<NSLocking>* lk = nil;
    
    SYNCHRONIZED_BEGIN
    
    lk = [_lockkeys objectForKey:key];
    if (lk == nil) {
        lk = [[NSMutex alloc] init];
        [_lockkeys setObject:lk forKey:key];
        SAFE_RELEASE(lk);
    }
    
    SYNCHRONIZED_END
    
    [lk lock];
    [lk retain];
}

- (void)keyUnlock:(NSString *)key {
    SYNCHRONIZED_BEGIN
    
    NSObject<NSLocking>* lk = [_lockkeys objectForKey:key];
    if (lk) {
        
        [lk unlock];
        
        SAFE_RELEASE(lk);
        
        if (lk.retainCount == 1) {
            [_lockkeys removeObjectForKey:key];
        }
        
    }
    
    SYNCHRONIZED_END
}
 */

@end

@interface NSObjectsCache ()

@property (nonatomic, readonly) NSMutableDictionary *store;

@end

@implementation NSObjectsCache

SHARED_IMPL;

- (void)onInit {
    [super onInit];
    _store = [[NSMutableDictionary alloc] init];
}

- (void)onFin {
    ZERO_RELEASE(_store);
    [super onFin];
}

- (id)addInstance:(id(^)())obj withKey:(id<NSCopying>)key {
    id ret = nil;
    ret = [self objectForKey:key];
    if (ret == nil) {
        ret = obj();
        if (ret) {
            [self addObject:ret withKey:key];
        }
    }
    return ret;
}

- (void)addObject:(id)obj withKey:(id<NSCopying>)key {
# ifdef DEBUG_MODE
    {
        id old = [_store objectForKey:key];
        if (old)
            WARN("正在 %s 中覆盖一个关键 key: %s", object_getClassName(self), ((NSObject*)key).description.UTF8String);
    }
# endif
    
    if (obj)
        [_store setObject:obj forKey:key];
}

- (id)objectForKey:(id<NSCopying>)key {
    return [_store objectForKey:key];
}

- (void)removeObjectForKey:(id<NSCopying>)key {
    [_store removeObjectForKey:key];
}

- (id)popForKey:(id<NSCopying>)key {
    id ret = [[self objectForKey:key] consign];
    if (ret)
        [self removeObjectForKey:key];
    return ret;
}

- (NSInteger)count {
    return _store.count;
}

- (void)clear {
    [_store removeAllObjects];
}

- (NSString*)description {
    return _store.description;
}

@end

@interface NSFlymakeObject : NSObjectExt

@property (nonatomic, retain) id object;
@property (nonatomic, assign) int refcnt;

@end

@implementation NSFlymakeObject

- (void)onInit {
    [super onInit];
    _refcnt = 1;
}

- (void)onFin {
    ZERO_RELEASE(_object);
    [super onFin];
}

- (void)incref {
    ++_refcnt;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"refcnt: %d", _refcnt];
}

@end

@interface NSFlymakeCache ()

@property (nonatomic, retain) NSMutableArray *arrFifo;

- (void)collect;

@end

@implementation NSFlymakeCache

SHARED_IMPL;

- (void)onInit {
    [super onInit];
    [[UIAppDelegate shared].signals connect:kSignalAppDeactiving withSelector:@selector(clear) ofTarget:self];
    [[UIAppDelegate shared].signals connect:kSignalMemoryWarning withSelector:@selector(clear) ofTarget:self];
}

- (void)onFin {
    ZERO_RELEASE(_arrFifo);
    [super onFin];
}

- (void)addObject:(id<NSCoding>)obj withKey:(id<NSCopying>)key {
    NSFlymakeObject* fo = [NSFlymakeObject temporary];
    fo.object = obj;
    [super addObject:fo withKey:key];
    
    // 判断是否启动流控
    if (_threshold) {
        // 压入 fifo 表，如果 fifo 触发条件，则开始 fifo 的收集
        // 如果总数目触发 top 的条件，则开始 top 收集
        // 如果 store 的对象不位于 fifo 和 top 表中，则从 store 中删除该对象
        if (_thresholdFifo)
            [_arrFifo addObject:obj];
        
        // 触发判断
        if (_arrFifo.count >= _thresholdFifo &&
            self.store.count >= _threshold)
        {
# ifdef TUNE_MODE
            [NSPerformanceMeasure measure:^{
                NSInteger cnt = self.count;
                [self collect];
                cnt = self.count - cnt;
                LOG("清理了 %d 个对象", cnt);
            }];
# else
            [self collect];
# endif
        }
    }
}

- (id)objectForKey:(id<NSCopying>)key {
    NSFlymakeObject* fo = [super objectForKey:key];
    ++fo.refcnt;
    return fo.object;
}

- (void)setThreshold:(NSInteger)threshold {
    _threshold = threshold;
    _stepTop = threshold / 3;
    
    // fifo 默认为tops的1/2大小，业务也可以之后独立设置
    self.thresholdFifo = threshold / 2;
}

- (void)setThresholdFifo:(NSInteger)thresholdFifo {
    _thresholdFifo = thresholdFifo;
    _stepFifo = thresholdFifo / 3;
    self.arrFifo = [NSMutableArray arrayWithCapacity:_stepFifo];
}

- (void)collect {
    NSArray* objs = self.store.allValues;
    
    // 按照使用次数排序，并压到 top 数组中
    NSArray* tops = [objs sortedArrayUsingComparator:^NSComparisonResult(NSFlymakeObject* obj1, NSFlymakeObject* obj2) {
        return obj1.refcnt < obj2.refcnt;
    }];
    
    NSArray* top_remain = [tops arrayToIndex:_threshold - _stepTop];
    NSArray* fifo_remain = [_arrFifo arrayFromIndex:_arrFifo.count - _thresholdFifo];
    
    // 清理结束后 fifo 应该只包含保留的对象
    [_arrFifo setArray:fifo_remain];
    
    // 清理不属于 remain 的对象
    NSArray* remain = [NSArray arrayWithArrays:top_remain, fifo_remain, nil];
    NSArray* dels = [objs arrayByRemoveObjects:remain];
    
    // 从 store 中移除对应的对象
    [self.store removeObjectByFilter:^BOOL(id k, id v) {
        return [dels containsObject:v];
    }];
}

- (void)clear {
    [super clear];
    [_arrFifo removeAllObjects];
}

@end
