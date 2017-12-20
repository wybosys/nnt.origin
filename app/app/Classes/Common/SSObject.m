
# import "Common.h"
# import "SSObject.h"
# import "NSTypes+Extension.h"
# import "NSWeakTypes.h"

static bool SIGNALSLOT_VERBOSE = false;

@interface SSignals ()

@property (nonatomic, assign) NSObject* owner;
@property (nonatomic, readonly) NSWeakSet* reflectslots;

@end

@implementation NSObject (SignalSlot)

static void* __s_nsobject_signals_key;

- (SSignals*)doGetSignals {
    SSignals* sigs = nil;
    BOOL init = NO;
    SYNCHRONIZED_BEGIN
    sigs = objc_getAssociatedObject(self, &__s_nsobject_signals_key);
    if (sigs == nil) {
        sigs = [[SSignals alloc] init];
        sigs.owner = self;
        objc_setAssociatedObject(self, &__s_nsobject_signals_key, sigs, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        SAFE_RELEASE(sigs);
        init = YES;
    }
    SYNCHRONIZED_END
    if (init == YES) {
        [self initSignals];
    }
    return sigs;
}

- (SSignals*)signals {
    return [self doGetSignals];
}

- (SSignals*)touchSignals {
    return objc_getAssociatedObject(self, &__s_nsobject_signals_key);
}

- (void)initSignals {
    PASS;
}

@end

@implementation SSlotTunnel

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_data);
    [super dealloc];
}

- (void)veto {
    _vetoed = YES;
}

@end

@interface SSlot () {
    NSOperationQueue *_queueParallel, *_queueInterval;
}

@property (nonatomic, assign) NSObject* sender;
@property (atomic, assign) int countEmiting;
@property (nonatomic, readonly) NSOperationQueue *queueParallel, *queueInterval;

@end

uint kSSlotPriorityDefault = 100;
uint kSSlotPriorityHigh = 90, kSSlotPriorityLow = 110;

@implementation SSlot

@synthesize queueInterval = _queueInterval;

- (id)init {
    self = [super init];
    
    _boundaryEmit = -1;
    _parallel = -1;
    _fps = 0;
    _fpswaiting = NO;
    _interval = 0;
    _delay = 0;
    _thread = kSSlotMainThread;
    _priority = kSSlotPriorityDefault;
    
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_origin);
    ZERO_RELEASE(_redirect);
    ZERO_RELEASE(_cbBlock);
    ZERO_RELEASE(_cbTargetBlock);
    ZERO_RELEASE(_data);
    ZERO_RELEASE(_tunnel);
    ZERO_RELEASE(_queueParallel);
    ZERO_RELEASE(_queueInterval);
    
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    SSlot* ret = [[SSlot alloc] init];
    
# ifdef DEBUG_MODE
    ret.slots = _slots;
# endif
    
    ret.origin = _origin;
    ret.boundaryEmit = _boundaryEmit;
    ret.redirect = _redirect;
    ret.cbBlock = _cbBlock;
    ret.cbTargetBlock = _cbTargetBlock;
    ret.target = _target;
    ret.selector = _selector;
    ret.classs = _classs;
    ret.sender = _sender;
    ret.data = _data;
    ret.parallel = _parallel;
    ret.fps = _fps;
    ret.interval = _interval;
    ret.delay = _delay;
    ret.tunnel = _tunnel;
    ret.thread = _thread;
    ret.priority = _priority;
    
    return ret;
}

- (NSOperationQueue*)queueParallel {
    SYNCHRONIZED_BEGIN
    if (_queueParallel == nil) {
        _queueParallel = [[NSOperationQueue alloc] init];
        _queueParallel.maxConcurrentOperationCount = self.parallel;
    }
    SYNCHRONIZED_END
    return _queueParallel;
}

- (NSOperationQueue*)queueInterval {
    SYNCHRONIZED_BEGIN
    if (_queueInterval == nil) {
        _queueInterval = [[NSOperationQueue alloc] init];
        _queueInterval.maxConcurrentOperationCount = 1;
    }
    SYNCHRONIZED_END
    return _queueInterval;
}

- (SSlot*)oneshot {
    _boundaryEmit = 1;
    return self;
}

- (SSlot*)single {
    _parallel = 1;
    return self;
}

- (void)emit {
    if (self.interval != 0)
    {
        [_origin.queueInterval addOperation:self];
        return;
    }
    
    if (self.parallel != -1)
    {
        if (self.parallel <= _origin.countEmiting)
        {
            [_origin.queueParallel addOperation:self];
            return;
        }
        
        if (_origin.queueParallel.operationCount)
        {
            [_origin.queueParallel addOperation:self];
            return;
        }
    }
    
    // 启动
    [self main];
    //[self start]; // xcode 5.1 引起了 block 的崩溃，所以干脆直接启动
}

- (void)main {
    // 保护target, 会在main之后release
    SAFE_RETAIN(_target);
    
    // 开始执行
    if (self.delay == 0)
    {
        [self doMain];
    }
    else
    {
        DISPATCH_DELAY_BEGIN(self.delay)
        [self doMain];
        DISPATCH_DELAY_END
    }
    
    // 运行间隔
    if (self.interval)
        [NSTime SleepSecond:self.interval];
}

- (void)doMain {
    switch (self.thread) {
        case kSSlotMainThread: {
            if ([NSSyncLoop InMainThread]) {
                [self process];
            } else {
                // waituntildone不能设置为 YES，设置后会导致其他地方使用 DISPATH_ONMAIN 的时候形成 deadlock
                [self performSelectorOnMainThread:@selector(process) withObject:nil waitUntilDone:NO];
            }
        } break;
        case kSSlotCurrentThread: {
            [self process];
        } break;
        case kSSlotBackgroudThread: {
            if ([NSSyncLoop InMainThread] == NO) {
                [self process];
            } else {
                [self performSelectorInBackground:@selector(process) withObject:nil];
            }
        } break;
    }
}

- (void)doProcess {
    ++_origin.countEmiting;
    
    if (_target && _redirect) {
        [_target.signals emit:_redirect withVariant:_data];
    }
    
    if (_target && _selector) {
        [_target performSelector:_selector withObject:self];
    }
    
    if (_selector && _classs) {
        class_callMethod(_classs, _selector, self);
    }
    
    if (_cbBlock) {
        _cbBlock(self);
    }
    
    if (_cbTargetBlock && _target) {
        _cbTargetBlock(self, _target);
    }
    
    --_origin.countEmiting;
    
    // 去保
    SAFE_RELEASE(_target);
}

- (void)process {
    @try {
        [self doProcess];
    }
    @catch (NSException *exception) {
        [exception log:self.description];
    }
}

/*
+ (instancetype)PopFromStack {
    SSlot* ptr;
    asm("mov %%edi, %0" : "=r"(ptr));
    return ptr;
}
 */

+ (instancetype)slotWithData:(Variant *)data {
    SSlot* ret = [[self alloc] init];
    ret.data = data;
    return [ret autorelease];
}

- (NSString*)description {
    NSMutableString* str = [NSMutableString string];
    if (self.target) {
        [str appendFormat:@"%@", NSStringFromClass(self.target.class)];
        if (self.selector)
            [str appendFormat:@"::%@", NSStringFromSelector(self.selector)];
        if (self.redirect)
            [str appendFormat:@".signals.%@", self.redirect];
        if (self.cbBlock)
            [str appendFormat:@".block(%tx)", (ptrdiff_t)self.cbBlock];
        if (self.cbTargetBlock)
            [str appendFormat:@".targetblock(%tx)", (ptrdiff_t)self.cbTargetBlock];
    } else if (self.class) {
        [str appendFormat:@"%@", NSStringFromClass(self.class)];
        if (self.selector)
            [str appendFormat:@"::%@", NSStringFromSelector(self.selector)];
    }
    return str;
}

@end

@interface SSlot (private)

- (void)clearFpsWaiting;

@end

@implementation SSlot (private)

- (void)clearFpsWaiting {
    self.fpswaiting = NO;
}

@end

@interface SSlots ()

@property (nonatomic, readonly) NSMutableArray* store;

@end

@implementation SSlots

+ (SSlots*)slots {
    return [[[[self class] alloc] init] autorelease];
}

- (id)init {
    self = [super init];
    _store = [[NSMutableArray alloc] init];
    return self;
}

- (void)dealloc {
    // 清空
    [self clear];
    
    // 释放
    SAFE_RELEASE(_store);
    
# ifdef DEBUG_MODE
    ZERO_RELEASE(_signal);
# endif
    
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    SSlots* ret = [[[self class] alloc] init];
    
    SYNCHRONIZED_BEGIN
    
    for (SSlot* each in _store) {
        SSlot* s = [each copy];
        s.origin = each;
        
        [ret add:s];
        
        SAFE_RELEASE(s);
    }
    
    SYNCHRONIZED_END
    
# ifdef DEBUG_MODE
    ret.source = _source;
    ret.signal = _signal;
# endif
    
    return ret;
}

- (void)add:(SSlot*)s {
    SYNCHRONIZED_BEGIN
    
    // 添加了一个slot
    [_store addObject:s];
    
    // 调整次序
    [_store sortUsingComparator:^NSComparisonResult(SSlot* obj1, SSlot* obj2) {
        if (obj1.priority < obj2.priority)
            return NSOrderedAscending;
        else if (obj1.priority == obj2.priority)
            return NSOrderedSame;
        return NSOrderedDescending;
    }];
    
    // 添加映射
    if (s.target)
        [s.target.signals.reflectslots addObject:self];
    
# ifdef DEBUG_MODE
    s.slots = self;
# endif
  
    SYNCHRONIZED_END
}

- (NSUInteger)count {
    SYNCHRONIZED_BEGIN
    return _store.count;
    SYNCHRONIZED_END
}

- (void)foreach:(BOOL (^)(SSlot *))block {
    NSArray* dup = nil;
    
    SYNCHRONIZED_BEGIN
    dup = [[NSArray alloc] initWithArray:_store];
    SYNCHRONIZED_END
    
    for (SSlot* each in dup) {
        if (block(each) == NO)
            break;
    }
    
    SAFE_RELEASE(dup);
}

- (void)clear {
    SYNCHRONIZED_BEGIN
    
    for (SSlot* each in _store) {
        if (each.target) {
            [each.target.touchSignals.reflectslots removeObject:self];
        }
    }
    
    [_store removeAllObjects];
    
    SYNCHRONIZED_END
}

- (void)disconnectTarget:(NSObject *)target {
    SYNCHRONIZED_BEGIN
    
    NSMutableArray* removed = [NSMutableArray array];
    for (SSlot* each in _store)
    {
        if (each.target == target)
        {
            [target.touchSignals.reflectslots removeObject:self];
            [removed addObject:each];
        }
    }
    
    [_store removeObjectsInArray:removed];
    
    SYNCHRONIZED_END
}

- (void)disconnectType:(Class)type {
    SYNCHRONIZED_BEGIN
    
    NSMutableArray* removed = [NSMutableArray array];
    for (SSlot* each in _store)
    {
        if ([each.target isKindOfClass:type])
        {
            [each.target.touchSignals.reflectslots removeObject:self];
            [removed addObject:each];
        }
    }

    [_store removeObjectsInArray:removed];

    SYNCHRONIZED_END
}

- (void)disconnect:(SEL)sel ofTarget:(NSObject*)target {
    SYNCHRONIZED_BEGIN
    
    NSMutableArray* removed = [NSMutableArray array];
    
    for (SSlot* each in _store)
    {
        if (each.target == target &&
            each.selector == sel)
        {
            [each.target.touchSignals.reflectslots removeObject:self];
            [removed addObject:each];
        }
    }
    
    [_store removeObjectsInArray:removed];
    
    SYNCHRONIZED_END
}

- (void)setTopmost:(SSlot*)s {
    SYNCHRONIZED_BEGIN
    
    SAFE_RETAIN(s);
    [_store removeObject:s];
    [_store insertObject:s atIndex:0];
    SAFE_RELEASE(s);
    
    SYNCHRONIZED_END
}

- (SSlot*)findSelector:(SEL)sel ofTarget:(NSObject *)target {
    SSlot* ret = nil;
    SYNCHRONIZED_BEGIN
    for (SSlot* each in _store) {
        if (each.target == target &&
            each.selector == sel)
        {
            ret = each;
            break;
        }
    }
    SYNCHRONIZED_END
    return ret;
}

- (SSlot*)findSelector:(SEL)sel ofClass:(Class)cls {
    SSlot* ret = nil;
    SYNCHRONIZED_BEGIN
    for (SSlot* each in _store) {
        if (each.classs == cls &&
            each.selector == sel)
        {
            ret = each;
            break;
        }
    }
    SYNCHRONIZED_END
    return ret;
}

- (SSlot*)findBlock:(SSlotCallbackBlock)block {
    SSlot* ret = nil;
    SYNCHRONIZED_BEGIN
    for (SSlot* each in _store) {
        if (each.cbBlock == block)
        {
            ret = each;
            break;
        }
    }
    SYNCHRONIZED_END
    return ret;
}

- (SSlot*)findBlock:(SSlotTargetCallbackBlock)block ofTarget:(NSObject *)target {
    SSlot* ret = nil;
    SYNCHRONIZED_BEGIN
    for (SSlot* each in _store) {
        if (each.cbTargetBlock == block &&
            each.target == target)
        {
            ret = each;
            break;
        }
    }
    SYNCHRONIZED_END
    return ret;
}

- (SSlot*)findRedirectSignal:(NSString *)sig ofTarget:(NSObject *)target {
    SSlot* ret = nil;
    SYNCHRONIZED_BEGIN
    for (SSlot* each in _store) {
        if ([each.redirect isEqualToString:sig])
        {
            ret = each;
            break;
        }
    }
    SYNCHRONIZED_END
    return ret;
}

- (SSlots*)run {
    SYNCHRONIZED_BEGIN
    
    NSMutableArray* removed = [NSMutableArray array];
    
    for (SSlot* s in _store)
    {
        if (s.boundaryEmit != -1 &&
            s.boundaryEmit-- == 0)
        {
            // 避免当共用时下一次因为==-1造成信号不匹配次数限制的规则
            s.boundaryEmit = 0;
            
            // 需要移除
            [s.target.touchSignals.reflectslots removeObject:self];
            [removed addObject:s];
            continue;
        }
    }
    
    [_store removeObjectsInArray:removed];
    
    SYNCHRONIZED_END
    
    return self;
}

@end

@interface SComplexSignal ()

@property (nonatomic, readonly) NSMutableArray *sigs;

@end

@implementation SComplexSignal

- (id)init {
    self = [super init];
    _sigs = [[NSMutableArray alloc] init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_sigs);
    [super dealloc];
}

+ (instancetype)Or:(NSString *)sig, ... {
    SComplexSignal* ret = [self temporary];
    [ret.sigs addObject:sig];
    va_list va;
    va_start(va, sig);
    [ret.sigs addObjectsFromV:va];
    va_end(va);
    return ret;
}

@end

@implementation SSignalSetting

- (id)init {
    self = [super init];
    
    _isblocked = 0;
    _fps = 0;
    
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_fpsWaiting);
    
    [super dealloc];
}

- (void)block {
    ++_isblocked;
}

- (void)unblock {
    --_isblocked;
}

- (void)setFps:(float)fps {
    _fps = fps;
    
    if (_fpsWaiting == nil)
        _fpsWaiting = [[NSAtomicCounter alloc] init];
}

@end

@interface SSignals ()
{
    NSMutableDictionary* _sigslots;
    NSMutableDictionary* _sigsets;
    NSObject* _owner;
}

@end

@implementation SSignals

@synthesize owner = _owner;

- (id)init {
    self = [super init];
    
    _sigslots = [[NSMutableDictionary alloc] init];
    _sigsets = [[NSMutableDictionary alloc] init];
    _reflectslots = [[NSWeakSet alloc] init];
    
    return self;
}

- (void)dealloc {
    //LOG("signals dealloc %x, owner %x", self, self.owner);
        
    // 注销
    [_reflectslots foreach:^BOOL(SSlots* each) {
        [each foreach:^BOOL(SSlot *s) {
            if (s.target == self.owner) {                
                // 以为使用 objc 的 Associate Object 机制，此时 self.owner 已经被析构，所以需要置空，以防止当 SSlots 析构时因断开反射连接而崩溃
                s.target = nil;
            }
            return YES;
        }];
        // 断开反射连接
        [each disconnectTarget:nil];
        return YES;
    }];
    ZERO_RELEASE(_reflectslots);
    
    // 清空信号集
    ZERO_RELEASE(_sigslots);
    ZERO_RELEASE(_sigsets);
    
    [super dealloc];
}

- (void)disconnect {
    SYNCHRONIZED_BEGIN
    
    for (SSlots* sls in _sigslots.allValues) {
        [sls clear];
    }
    
    SYNCHRONIZED_END
    
    if (_delegate && [_delegate respondsToSelector:@selector(signals:signalDisconnected:)]) {
        for (SSignal* each in _sigslots.allKeys) {
            [_delegate signals:_owner signalDisconnected:each];
        }
    }
}

- (void)disconnectToTarget:(NSObject*)target {
    SYNCHRONIZED_BEGIN
    
    for (SSlots* sls in _sigslots.allValues) {
        [sls disconnectTarget:target];
    }
    
    SYNCHRONIZED_END
    
    if (_delegate && [_delegate respondsToSelector:@selector(signals:signalDisconnected:)]) {
        for (SSignal* each in _sigslots.allKeys) {
            [_delegate signals:_owner signalDisconnected:each];
        }
    }
}

- (void)disconnectWithSelector:(SEL)sel ofTarget:(NSObject*)target {
    SYNCHRONIZED_BEGIN
    
    for (SSlots* sls in _sigslots.allValues) {
        [sls disconnect:sel ofTarget:target];
    }
    
    SYNCHRONIZED_END
    
    if (_delegate && [_delegate respondsToSelector:@selector(signals:signalDisconnected:)]) {
        for (SSignal* each in _sigslots.allKeys) {
            [_delegate signals:_owner signalDisconnected:each];
        }
    }
}

- (void)disconnect:(SSignal*)sig withSelector:(SEL)sel ofTarget:(NSObject*)target {
    SYNCHRONIZED_BEGIN
    
    SSlots* sls = [_sigslots objectForKey:sig];
    if (sls == nil) {
        WARN("没有找到信号 %s", sig.UTF8String);
    } else {
        [sls disconnect:sel ofTarget:target];
    }
    
    SYNCHRONIZED_END
    
    if (_delegate && [_delegate respondsToSelector:@selector(signals:signalDisconnected:)]) {
        [_delegate signals:_owner signalDisconnected:sig];
    }
}

- (void)disconnect:(SSignal*)sig ofTarget:(NSObject *)target {
    SYNCHRONIZED_BEGIN
    
    SSlots* sls = [_sigslots objectForKey:sig];
    if (sls == nil) {
        WARN("没有找到信号 %s", sig.UTF8String);
    } else {
        [sls disconnectTarget:target];
    }
    
    SYNCHRONIZED_END
    
    if (_delegate && [_delegate respondsToSelector:@selector(signals:signalDisconnected:)]) {
        [_delegate signals:_owner signalDisconnected:sig];
    }
}

- (void)disconnect:(SSignal*)sig ofType:(Class)type {
    SYNCHRONIZED_BEGIN
    
    SSlots* sls = [_sigslots objectForKey:sig];
    if (sls == nil) {
        WARN("没有找到信号 %s", sig.UTF8String);
    } else {
        [sls disconnectType:type];
    }
    
    SYNCHRONIZED_END
    
    if (_delegate && [_delegate respondsToSelector:@selector(signals:signalDisconnected:)]) {
        [_delegate signals:_owner signalDisconnected:sig];
    }
}

- (void)disconnect:(SSignal*)sig {
    SYNCHRONIZED_BEGIN
    
    SSlots* sls = [_sigslots objectForKey:sig];
    if (sls == nil) {
        WARN("没有找到信号 %s", sig.UTF8String);
    } else {
        [sls clear];
    }
    
    SYNCHRONIZED_END
    
    if (_delegate && [_delegate respondsToSelector:@selector(signals:signalDisconnected:)]) {
        [_delegate signals:_owner signalDisconnected:sig];
    }
}

- (SSignals*)addSignal:(SSignal*)sig {
    SYNCHRONIZED_BEGIN
    
    id ret = [_sigslots objectForKey:sig];
    if (ret == nil) {
        
        SSlots* ss = [[SSlots alloc] init];
        [_sigslots setObject:ss forKey:sig];
        [_sigsets setObject:[SSignalSetting temporary] forKey:sig];
        
# ifdef DEBUG_MODE
        ss.source = self;
        ss.signal = sig;
# endif
        
        SAFE_RELEASE(ss);
        
    } else {
        //LOG("信号 %s 已经存在", sig.UTF8String);
    }
    
    SYNCHRONIZED_END
    
    return self;
}

- (BOOL)hasSignal:(SSignal*)sig {
    BOOL suc = YES;
    SYNCHRONIZED_BEGIN
    suc = [_sigslots objectForKey:sig] != nil;
    SYNCHRONIZED_END
    return suc;
}

- (SSignalSetting*)settingForSignal:(SSignal*)sig {
    return [_sigsets objectForKey:sig];
}

- (void)_connectSlot:(SSlot*)s forSignal:(SSignal*)sig {
    // 添加一个新的 slot，可以在这里进行 filter 或者调整
    SYNCHRONIZED_BEGIN
    
    SSlots* sls = (SSlots*)[_sigslots objectForKey:sig];
    [sls add:s];
    
    SYNCHRONIZED_END
    
    if (_delegate) {
        [_delegate signals:_owner signalConnected:sig slot:s];
    }
}

- (SSlot*)connect:(SSignal*)sig withSelector:(SEL)sel {
    return [self connect:sig withSelector:sel ofTarget:_owner];
}

- (SSlot*)connect:(SSignal*)sig withSelector:(SEL)sel ofTarget:(NSObject*)target {
# ifdef DEBUG_MODE
    if ([self hasSignal:sig] == NO) {
        WARN("没有找到名为 %s 的信号 %s", sig.UTF8String, objc_getClassName(_owner));
        return nil;
    }
# endif
    
    SSlot* ret = [self _findSlot:sig withSelector:sel ofTarget:target];
    if (ret != nil)
        return ret;
    
    ret = [[SSlot alloc] init];
    ret.target = target;
    ret.selector = sel;
    
    [self _connectSlot:ret forSignal:sig];
    
    SAFE_RELEASE(ret);
    
    return ret;
}

- (SSlot*)_findSlot:(SSignal*)sig withSelector:(SEL)sel ofTarget:(NSObject*)target {
    SSlot* ret = nil;
    SYNCHRONIZED_BEGIN
    
    SSlots* sls = (SSlots*)[_sigslots objectForKey:sig];
    ret = [sls findSelector:sel ofTarget:target];
    
    SYNCHRONIZED_END
    return ret;
}

- (SSlot*)connect:(SSignal*)sig withSelector:(SEL)sel ofClass:(Class)cls {
# ifdef DEBUG_MODE
    if ([self hasSignal:sig] == NO) {
        WARN("没有找到名为 %s 的信号 %s", sig.UTF8String, objc_getClassName(_owner));
        return nil;
    }
# endif
    
    SSlot* ret = [self _findSlot:sig withSelector:sel ofClass:cls];
    if (ret != nil)
        return ret;
    
    ret = [[SSlot alloc] init];
    ret.classs = cls;
    ret.selector = sel;
    
    [self _connectSlot:ret forSignal:sig];
    
    SAFE_RELEASE(ret);
    
    return ret;
}

- (SSlot*)_findSlot:(SSignal*)sig withSelector:(SEL)sel ofClass:(Class)cls {
    SSlot* ret = nil;
    SYNCHRONIZED_BEGIN
    
    SSlots* sls = (SSlots*)[_sigslots objectForKey:sig];
    ret = [sls findSelector:sel ofClass:cls];
    
    SYNCHRONIZED_END
    return ret;
}

- (SSlot*)connect:(SSignal*)sig withBlock:(SSlotCallbackBlock)block {
# ifdef DEBUG_MODE
    if ([self hasSignal:sig] == NO) {
        WARN("没有找到名为 %s 的信号 %s", sig.UTF8String, objc_getClassName(_owner));
        return nil;
    }
# endif
    
    SSlot* ret = [self _findSlot:sig withBlock:block];
    if (ret != nil)
        return ret;
    
    ret = [[SSlot alloc] init];
    ret.cbBlock = block;
    
    [self _connectSlot:ret forSignal:sig];
    
    SAFE_RELEASE(ret);
    
    return ret;
}

- (SSlot*)_findSlot:(SSignal*)sig withBlock:(SSlotCallbackBlock)block {
    SSlot* ret = nil;
    SYNCHRONIZED_BEGIN
    
    SSlots* sls = (SSlots*)[_sigslots objectForKey:sig];
    ret = [sls findBlock:block];
    
    SYNCHRONIZED_END
    return ret;
}

- (SSlot*)connect:(SSignal*)sig withBlock:(SSlotTargetCallbackBlock)block ofTarget:(NSObject *)target {
# ifdef DEBUG_MODE
    if ([self hasSignal:sig] == NO) {
        WARN("没有找到名为 %s 的信号 %s", sig.UTF8String, objc_getClassName(_owner));
        return nil;
    }
# endif
    
    SSlot* ret = [self _findSlot:sig withBlock:block ofTarget:target];
    if (ret != nil)
        return ret;
    
    ret = [[SSlot alloc] init];
    ret.cbTargetBlock = block;
    ret.target = target;
    
    [self _connectSlot:ret forSignal:sig];
    
    SAFE_RELEASE(ret);
    
    return ret;
}

- (SSlot*)_findSlot:(SSignal*)sig withBlock:(SSlotTargetCallbackBlock)block ofTarget:(NSObject*)target {
    SSlot* ret = nil;
    SYNCHRONIZED_BEGIN
    
    SSlots* sls = (SSlots*)[_sigslots objectForKey:sig];
    ret = [sls findBlock:block ofTarget:target];
    
    SYNCHRONIZED_END
    return ret;
}

- (SSlot*)connect:(NSString *)sig redirectTo:(NSString *)sig2 ofTarget:(NSObject*)target {
# ifdef DEBUG_MODE
    if ([self hasSignal:sig] == NO) {
        WARN("没有找到名为 %s 的信号 %s", sig.UTF8String, objc_getClassName(_owner));
        return nil;
    }
# endif
    
    SSignals* tgtsigs = [[target performSelector:@selector(signals)] obeyClass:[SSignals class]];
    if (tgtsigs == nil)
        return nil;
    
    SSlot* ret = [self _findSlot:sig withRedirectSignal:sig2 ofTarget:target];
    if (ret != nil)
        return ret;
    
    ret = [[SSlot alloc] init];
    ret.redirect = sig2;
    ret.target = target;
    
    [self _connectSlot:ret forSignal:sig];

    SAFE_RELEASE(ret);
    
    return ret;
}

- (SSlot*)connect:(NSString *)sig ofTarget:(NSObject *)target {
    return [self connect:sig redirectTo:sig ofTarget:target];
}

- (SSlot*)_findSlot:(SSignal*)sig withRedirectSignal:(SSignal*)sig2 ofTarget:(NSObject*)target {
    SSlot* ret = nil;
    SYNCHRONIZED_BEGIN
    
    SSlots* sls = (SSlots*)[_sigslots objectForKey:sig];
    ret = [sls findRedirectSignal:sig2 ofTarget:target];
    
    SYNCHRONIZED_END
    return ret;
}

- (void)redirects:(NSArray*)sigs toTarget:(NSObject*)target {
    for (SSignal* each in sigs) {
        [self connect:each redirectTo:each ofTarget:target];
    }
}

- (SSignals*)emit:(NSString *)sig {
    return [self emit:sig withResult:nil];
}

- (SSignals*)emit:(NSString *)sig withTunnel:(SSlotTunnel *)tunnel {
    return [self emit:sig withResult:nil withTunnel:tunnel];
}

- (SSignals*)emit:(NSString *)sig withResult:(NSObject *)result {
    return [self emit:sig withVariant:[Variant variantWithObject:result]];
}

- (SSignals*)emit:(SSignal*)sig withData:(void*)data {
    return [self emit:sig withVariant:[Variant variantWithPtr:data]];
}

- (SSignals*)emit:(SSignal*)sig withResult:(NSObject*)result withTunnel:(SSlotTunnel*)tunnel {
    return [self emit:sig withVariant:[Variant variantWithObject:result] withTunnel:tunnel];
}

- (SSignals*)emit:(NSString *)sig withVariant:(Variant *)variant {
    SSlotTunnel* tunnel = [[SSlotTunnel alloc] init];
    SSignals* ret = [self emit:sig withVariant:variant withTunnel:tunnel];
    SAFE_RELEASE(tunnel);
    return ret;
}

- (SSignals*)emit:(NSString *)sig withVariant:(Variant *)variant withTunnel:(SSlotTunnel*)tunnel {
    // 如果已经被 veto，则不发出信号
    if (tunnel.vetoed)
        return self;
    
    SSlots* slots_dup = nil;
    SSignalSetting* sigset = nil;
    
    SYNCHRONIZED_BEGIN
    
    // 判断信号状态
    sigset = (SSignalSetting*)[_sigsets objectForKey:sig];
    if (sigset) {
        if (sigset.isblocked > 0)
            return self;
    }
    
    // 复制运行用的 slots
    SSlots* osls = (SSlots*)[_sigslots objectForKey:sig];
    if (osls == nil)
    {
        WARN("没有找到对象 %x (%s) 含有的信号 %s", _owner, objc_getClassName(_owner), sig.UTF8String);
        return self;
    }
    else if (osls.count == 0)
    {
        // 没有对象期待这个信号
        return self;
    }
    else
    {
        // 筛除已经不能使用的
        [osls run];
        
        // 复制
        slots_dup = [osls copy];
    }
    
    SYNCHRONIZED_END
    
    if (SIGNALSLOT_VERBOSE)
        LOG("激活信号 %s 对象 %s 地址 %x", sig.UTF8String, objc_getClassName(_owner), _owner);
    
    // 因为业务层有可能在回调的处理中修改所带的data，所以需要进行累计
    __block Variant* lastvar = variant;
    
    // 激活
    [slots_dup foreach:^BOOL(SSlot *each) {
        
        // 终止运行，信号被取消
        if (tunnel.vetoed)
            return NO;
        
        // 设置共享对象
        each.tunnel = tunnel;
        
        // 判断fps
        if (each.fps)
        {
            if (each.origin.fpswaiting) {
                if (SIGNALSLOT_VERBOSE)
                    NOTI("对象 %s 信号 %s 等待冷却", objc_getClassName(_owner), sig.UTF8String);
                return YES;
            }
            
            each.origin.fpswaiting = YES;
            //DISPATCH_DELAY_BEGIN(1 / each.fps)
            //each.source.fpswaiting = NO;
            //DISPATCH_DELAY_END
            [each.origin performSelector:@selector(clearFpsWaiting) withObject:nil afterDelay:(1 / each.fps)];
        }
        else if (sigset.fps)
        {
            if (sigset.fpsWaiting.value) {
                if (SIGNALSLOT_VERBOSE)
                    NOTI("对象 %s 信号 %s 等待冷却", objc_getClassName(_owner), sig.UTF8String);
                return YES;
            }
            
            [sigset.fpsWaiting add];
            [sigset.fpsWaiting performSelector:@selector(sub) withObject:nil afterDelay:(1 / sigset.fps)];
        }

        // 绑定sender
        each.sender = _owner;
        
        // 绑定data
        each.data = lastvar;
        
        // 激活
        [each emit];
        
        // 重新设置一下 variant，因为业务层可以在cb中修改data
        lastvar = each.data;
        return YES;
    }];
    
    SAFE_RELEASE(slots_dup);
    
    // 判断是否需要转发
    if (_redirect != nil)
        [_redirect.signals emit:sig withVariant:variant];
    
    return self;
}

- (SSlots*)findSlots:(SSignal*)sig {
    return [_sigslots objectForKey:sig];
}

- (BOOL)isConnected:(SSignal*)sig {
    SSlots* ss = [self findSlots:sig];
    return ss.count != 0;
}

- (void)block {
    for (SSignalSetting* each in _sigsets.allValues) {
        [each block];
    }
}

- (void)unblock {
    for (SSignalSetting* each in _sigsets.allValues) {
        [each unblock];
    }
}

// 复合信号

- (SSlot*)connects:(SComplexSignal *)sigs withBlock:(SSlotCallbackBlock)block {
    if (sigs.sigs.count == 0)
        return nil;
    if (sigs.sigs.count == 1)
        return [self connect:sigs.sigs.firstObject withBlock:block];
    
    // 复合信号需要保证是第一次的连接
    for (SSignal* each in sigs.sigs) {
        SSlots* ss = [self findSlots:each];
        if ([ss findBlock:block]) {
            LOG("连接复合信号必须是第一次连接");
            return nil;
        }
    }
    
    SSlot* s = nil;
    for (SSignal* each in sigs.sigs) {
        // 连接第一个
        if (s == nil) {
            s = [self connect:each withBlock:block];
            continue;
        }
        
        // 连接其他
        SYNCHRONIZED_BEGIN
        SSlots* ss = [self findSlots:each];
        [ss add:s];
        SYNCHRONIZED_END
    }
    
    return s;
}

@end
