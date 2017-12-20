
# import "Common.h"
# import "NSCron.h"
# import "NSMemCache.h"

@interface NSCronSettingItem : NSObject

@property (nonatomic, readonly) NSMutableArray *values;

@end

@implementation NSCronSettingItem

- (id)init {
    self = [super init];
    _values = [[NSMutableArray alloc] init];
    return self;
}

- (id)initWithString:(NSString*)str withMax:(int)max {
    self = [self init];
    if ([self parseString:str withMax:max] == NO) {
        ZERO_RELEASE(self);
        return nil;
    }
    return self;
}

+ (id)itemWithString:(NSString*)str withMax:(int)max {
    return [[[self alloc] initWithString:str withMax:max] autorelease];
}

- (void)dealloc {
    ZERO_RELEASE(_values);
    [super dealloc];
}

- (BOOL)parseString:(NSString*)string withMax:(int)max {
    // 拆分逗点
    NSArray *arrDots = [string componentsSeparatedByString:@","];
    for (NSString* each in arrDots) {
        if (![self parseComponent:each withMax:max])
            return NO;
    }
    return YES;
}

- (BOOL)parseComponent:(NSString*)string withMax:(int)max {
    // 分为 / 和 - 以及 立即数 的形式
    // 0-12/2 0-12 1 */2
    if ([string rangeOfString:@"/"].location != NSNotFound) {
        // 0-12/2 */2
        NSArray* seps = [string componentsSeparatedByString:@"/"];
        if (seps.count != 2)
            return NO;
        NSString* left = seps.firstObject;
        NSString* right = seps.secondObject;
        
        // */2
        if ([left isEqualToString:@"*"]) {
            int step = right.intValue;
            for (int i = 0; i <= max; i += step) {
                [_values addObject:@(i + 1)];
            }
            return YES;
        }
        
        // 0-12/2
        if ([left rangeOfString:@"-"].location != NSNotFound) {
            NSArray* seps = [left componentsSeparatedByString:@"-"];
            if (seps.count != 2)
                return NO;
            int lbd = [seps.firstObject intValue];
            int hbd = [seps.secondObject intValue];
            int step = right.intValue;
            for (int i = lbd; i < hbd; i += step) {
                [_values addObject:@(i + 1)];
            }
            return YES;
        }
        
        return NO;
    }
    
    // 0-12
    if ([string rangeOfString:@"-"].location != NSNotFound) {
        NSArray* seps = [string componentsSeparatedByString:@"-"];
        if (seps.count != 2)
            return NO;
        int lbd = [seps.firstObject intValue];
        int hbd = [seps.secondObject intValue];
        for (int i = lbd; i < hbd; ++i) {
            [_values addObject:@(i + 1)];
        }
        return YES;
    }
    
    // *
    if ([string isEqualToString:@"*"]) {
        //for (int i = 0; i <= max; i += 1) {
        //    [_values addObject:@(i)];
        //}
        // 因为主要跑在客户端，所以修改 cron 的原始按照24小时定点的特性为按照时间间隔来运行
        return YES;
    }
    
    // 1 2 3
    int val = [string intValue];
    [_values addObject:@(val)];
    return YES;
}

@end

@interface NSCronTime : NSObject

@property (nonatomic, assign) int value, current, interval;

@end

@implementation NSCronTime

- (id)init {
    self = [super init];
    _value = _current = _interval = 0;
    return self;
}

- (id)initWithValue:(int)value {
    self = [self init];
    self.value = value;
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)setValue:(int)value {
    _value = value;
    _current = value;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[NSCronTime class]] == NO)
        return NO;
    NSCronTime* r = (NSCronTime*)object;
    return
    r.value == _value &&
    r.interval == _interval;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"<NSCronTime> value: %d; current: %d; interval: %d;", _value, _current, _interval];
}

@end

@interface NSCronItem ()

@property (nonatomic, readonly) NSMutableArray* times;

- (BOOL)parse:(NSString*)str;
- (void)checkRun:(NSTimeInterval)time;

@end

@implementation NSCronItem

- (id)init {
    self = [super init];
    
    _times = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_times);
    
    [super dealloc];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalCronActive)
SIGNALS_END

+ (id)itemWith:(NSString *)def {
    NSCronItem* ret = [[[self class] alloc] init];
    if ([ret parse:def] == NO) {
        SAFE_RELEASE(ret);
        return nil;
    }
    return [ret autorelease];
}

- (BOOL)parse:(NSString*)str {
    NSArray* comps = [str componentsSeparatedByString:@" "];
    if (comps.count != 3) {
        WARN("NSCronItem 配置解析失败: %s", str.UTF8String);
        return NO;
    }
    
    NSCronSettingItem *siSeconds = [NSCronSettingItem itemWithString:comps.firstObject withMax:59];
    if (siSeconds == nil)
        return NO;
    
    NSCronSettingItem *siMins = [NSCronSettingItem itemWithString:comps.secondObject withMax:59];
    if (siMins == nil)
        return NO;
    
    NSCronSettingItem *siHours = [NSCronSettingItem itemWithString:comps.thirdObject withMax:23];
    if (siHours == nil)
        return NO;
    
    if (siHours.values.count)
    {
        for (NSNumber* h in siHours.values)
        {
            int hour = h.intValue * TM_HOUR;
            
            if (siMins.values.count)
            {
                for (NSNumber* m in siMins.values)
                {
                    int min = m.intValue * TM_MINUTE;
                    
                    if (siSeconds.values.count)
                    {
                        for (NSNumber* s in siSeconds.values)
                        {
                            int sec = s.intValue;
                            
                            NSCronTime* ct = [[NSCronTime alloc] initWithValue:(hour + min + sec)];
                            ct.interval = TM_DAY;
                            [_times addObject:ct];
                            SAFE_RELEASE(ct);
                        }
                    } else {
                        return NO;
                    }
                }
            } else {
                return NO;
            }
        }
    }
    else
    {
        if (siMins.values.count) {
            for (NSNumber* m in siMins.values) {
                int min = m.intValue * TM_MINUTE;
                
                if (siSeconds.values.count) {
                    for (NSNumber* s in siSeconds.values) {
                        int sec = s.intValue;
                        
                        NSCronTime* ct = [[NSCronTime alloc] initWithValue:(min + sec)];
                        ct.interval = TM_HOUR;
                        [_times addObject:ct];
                        SAFE_RELEASE(ct);
                    }
                } else {
                    return NO;
                }
            }
        }
        else
        {
            if (siSeconds.values.count)
            {
                for (NSNumber* s in siSeconds.values)
                {
                    int sec = s.intValue;
                    
                    NSCronTime* ct = [[NSCronTime alloc] initWithValue:(sec)];
                    ct.interval = TM_MINUTE;
                    [_times addObject:ct];
                    SAFE_RELEASE(ct);
                }
            }
            else
            {
                return NO;
            }
        }
    }
    
    return YES;
}

- (void)checkRun:(NSTimeInterval)time {
    BOOL run = NO;
    
    for (NSCronTime* ct in _times)
    {
        ct.current -= time;
        
        if (ct.current <= 0)
        {
            run = YES;
            ct.current = ct.interval;
        }
    }
    
    if (run)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            //LOG("Cron Active");
            [self.signals emit:kSignalCronActive];
        });
    }
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[NSCronItem class]] == NO)
        return NO;
    NSCronItem* r = (NSCronItem*)object;
    if (self.times.count != r.times.count)
        return NO;
    BOOL suc = YES;
    for (int i = 0; i < self.times.count; ++i) {
        NSCronTime* lt = [self.times objectAtIndex:i];
        NSCronTime* rt = [r.times objectAtIndex:i];
        if ((suc &= [lt isEqual:rt]) == NO)
            break;
    }
    return suc;
}

@end

@interface NSCron ()
{
    BOOL _pause, _stop;
    NSTimeInterval _timeinv;
    unsigned long long timepassed;
    NSMutableArray* _items;
}

@end

@implementation NSCron

SHARED_IMPL;

- (id)init {
    self = [super init];
    
    _timeinv = 1;
    _items = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_items);
    
    [super dealloc];
}

- (void)start {
    if (_pause == YES) {
        _pause = NO;
        return;
    }
    
    timepassed = 0;
    _pause = NO;
    _stop = NO;

    [super start];
}

- (void)pause {
    if (_pause == YES)
        return;
    
    _pause = YES;
}

- (void)stop {
    if (_stop == YES)
        return;
    
    _stop = YES;
}

- (void)main {
    NSMutableArray* rmed = [[NSMutableArray alloc] init];
    while (_stop == NO)
    {
        if (_pause == NO)
        {
            SYNCHRONIZED_BEGIN
            
            for (NSCronItem* each in _items)
            {
                if ([each.signals findSlots:kSignalCronActive].count)
                {
                    // 检查一次，是不是可以运行
                    [each checkRun:_timeinv];
                }
                else
                {
                    [rmed addObject:each];
                }
            }
            
            [_items removeObjectsInArray:rmed];
            [rmed removeAllObjects];
            
            SYNCHRONIZED_END
            
            timepassed += _timeinv;
        }
        
        [NSTime SleepSecond:_timeinv];
    }
    SAFE_RELEASE(rmed);
}

- (NSCronItem*)add:(NSCronItem *)item {
    SYNCHRONIZED_BEGIN
    
    NSCronItem* found = nil;
    for (NSCronItem* each in _items) {
        if ([each isEqual:item]) {
            found = each;
            break;
        }
    }
    
    if (found == nil)
        [_items addObject:item];
    else
        item = found;
    
    SYNCHRONIZED_END
    return item;
}

- (NSCronItem*)addConfig:(NSString *)config {
    NSCronItem* item = [NSCronItem itemWith:config];
    if (item == nil)
        WARN("NSCron addConfig 失败");
    return [self add:item];
}

@end
