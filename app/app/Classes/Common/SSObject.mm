
# import "Common.h"
# import "SSObject.h"
# import "NSTypes+Extension.h"
# import "NSWeakTypes.h"
# include <map>
# include <set>

static bool SIGNALSLOT_VERBOSE = false;

@interface SSignals ()
{
    NSObject* _owner;
}

@property (nonatomic, assign) NSObject* owner;
@property (nonatomic, readonly) NSMutableDictionary* sigslots;
@property (nonatomic, readonly) NSMutableDictionary* sigsets;

@end

@interface SSlots ()
{
    // 是否当清空时断开连接，默认为YES
    BOOL _disconnectWhileClear;
}

@property (nonatomic, assign) NSObject* owner;
@property (nonatomic, readonly) NSMutableArray* store;

@end

@interface NSObject (SignalSlot_hidden)

@property (nonatomic, retain) SSignals *sigsobject;

@end

@implementation NSObject (SignalSlot_hidden)

NSOBJECT_DYNAMIC_PROPERTY(NSObject, sigsobject, setSigsobject, RETAIN_NONATOMIC);

@end

NS_BEGIN(sigslot)

class Manager
{
public:
    ~Manager();
    
    // 唯一的管理器
    static Manager Instance;
    
    // 获得signals，如果没有存在，则初始化并绑定
    SSignals* signals(NSObject*);
    SSignals* touch_signals(NSObject*);
    
    // 添加映射
    void map(NSObject* a, NSObject* b);
    void unmap(NSObject* a, NSObject* b);
    void unmap(NSObject*);
    
protected:
    Manager();
    
    // 均为 weak
    ::std::map<id, SSignals*> _allsigs;
    ::std::map<id, ::std::set<id> > _allreflects;
};

Manager Manager::Instance;

Manager::Manager()
{
    PASS;
}

Manager::~Manager()
{
    PASS;
}

SSignals* Manager::signals(NSObject *obj)
{
    // 如果已经实例化，则直接返回
    if (obj.sigsobject)
        return obj.sigsobject;
    auto find = _allsigs.find(obj);
    if (find == _allsigs.end())
    {
        // 实例化
        SSignals* sigs = [SSignals temporary];
        sigs.owner = obj;
        obj.sigsobject = sigs;
        _allsigs[obj] = sigs;
        // 初始化信号
        [obj initSignals];
        return sigs;
    }
    else if (obj.sigsobject == nil)
    {
        /* 这种情况的出现代表了
         原来的object已经释放，但是映射表中该object对应的signals仍然存在
         属于一个错误异常，必须不能出现这种问题
        */
        FATAL("ss:manager 类型生命期错误");
    }
    return find->second;
}

SSignals* Manager::touch_signals(NSObject *obj)
{
    // 如果已经实例化，则直接返回
    if (obj.sigsobject)
        return obj.sigsobject;
    // 查找，如果没有实例化，则返回nil
    auto find = _allsigs.find(obj);
    if (find == _allsigs.end())
        return nil;
    return find->second;
}

/*
 a 的信号 connect 到 b
 当 b 析构时，需要清除 a 的 signals 中和自己相关的插槽
 */
void Manager::map(NSObject *a, NSObject *b)
{
    // 不登记自己连接自己的情况
    if (a == b)
        return;
    
# ifdef DEBUG_MODE
    if (!a || !b)
        FATAL("A 或者 B 不能为 nil");
# endif
    auto frfl = _allreflects.find(b);
    if (frfl == _allreflects.end())
    {
        _allreflects[b] = ::std::set<id>();
        frfl = _allreflects.find(b);
    }
    
    frfl->second.insert(a);
}

void Manager::unmap(NSObject *a, NSObject *b)
{
    // 不登记自己连接自己的情况
    if (a == b)
        return;

# ifdef DEBUG_MODE
    if (!a || !b)
        FATAL("A 或者 B 不能为 nil");
# endif

    auto frfl = _allreflects.find(b);
    
    // 没有找到a和b登记的关系
    if (frfl == _allreflects.end())
        return;
    
    // 移除ab关系
    frfl->second.erase(a);
}

void Manager::unmap(NSObject *obj)
{
# ifdef DEBUG_MODE
    if (!obj)
        FATAL("不能 unmap 一个空的对象");
# endif

    auto fsig = _allsigs.find(obj);
    // 已经移除了
    if (fsig == _allsigs.end())
        return;
    
    // 从sigs里面移除obj
    _allsigs.erase(obj);
    
    // 从登记的反射里面移除obj
    auto frfl = _allreflects.find(obj);
    if (frfl == _allreflects.end())
        return;
    
    // 移除插槽
    ::std::set<id>& rfs = frfl->second;
    for (auto i = rfs.begin(); i != rfs.end(); ++i)
    {
        // 查找对应signals
        auto fsig = _allsigs.find(*i);
        if (fsig == _allsigs.end())
            continue;
        
        SSignals* sigs = fsig->second;
        // 解绑
        for (SSlots* ss in sigs.sigslots.allValues)
        {
            [ss.store removeObjectsMatch:^BOOL(SSlot* s) {
                return s.target == obj;
            }];
        }
    }
    
    // 从登记表里面也移除
    _allreflects.erase(frfl);
}

NS_END

@implementation NSObject (SignalSlot)

- (SSignals*)signals {
    return sigslot::Manager::Instance.signals(self);
}

- (SSignals*)touchSignals {
    return sigslot::Manager::Instance.touch_signals(self);
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
uint kSSlotPriorityHight = 90, kSSlotPriorityLow = 110;

@implementation SSlot

@synthesize queueInterval = _queueInterval;

- (id)init {
    self = [super init];
    
    _count = -1;
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
    ret.count = _count;
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
    _count = 1;
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
        //if ((_thread & kSSlotMutex) == kSSlotMutex) {
        //    [_target performSyncSelector:_selector withObject:self];
        //} else {
        [_target performSelector:_selector withObject:self];
        //}
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
            [str appendFormat:@".block(%x)", (ptrdiff_t)self.cbBlock];
        if (self.cbTargetBlock)
            [str appendFormat:@".targetblock(%x)", (ptrdiff_t)self.cbTargetBlock];
    } else if (self.class) {
        [str appendFormat:@"%@", NSStringFromClass(self.class)];
        if (self.selector)
            [str appendFormat:@"::%@", NSStringFromSelector(self.selector)];
    }
    return str;
}

@end

@interface SSlot (hidden)

- (void)clearFpsWaiting;

@end

@implementation SSlot (hidden)

- (void)clearFpsWaiting {
    self.fpswaiting = NO;
}

@end

@implementation SSlots

+ (SSlots*)slots {
    return [[[[self class] alloc] init] autorelease];
}

- (id)init {
    self = [super init];
    
    _store = [[NSMutableArray alloc] init];
    _disconnectWhileClear = YES;
    
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
    
    ret.owner = _owner;
    ret->_disconnectWhileClear = NO;
    
# ifdef DEBUG_MODE
    ret.source = _source;
    ret.signal = _signal;
# endif
    
    SYNCHRONIZED_BEGIN
    
    for (SSlot* each in _store) {
        SSlot* s = [each copy];
        s.origin = each;
        
        [ret add:s];
        
        SAFE_RELEASE(s);
    }
    
    SYNCHRONIZED_END
    
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
        sigslot::Manager::Instance.map(self.owner, s.target);
    
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
    
    if (_disconnectWhileClear) {
        for (SSlot* each in _store) {
            if (each.target) {
                sigslot::Manager::Instance.unmap(self.owner, each.target);
            }
        }
    }
    
    [_store removeAllObjects];
    
    SYNCHRONIZED_END
}

- (void)disconnectTarget:(NSObject *)target {
    if (target == nil) {
        WARN("ss:target 不能为 nil");
        return;
    }
    
    SYNCHRONIZED_BEGIN
    
    NSMutableArray* removed = [NSMutableArray array];
    for (SSlot* each in _store)
    {
        if (each.target == target)
        {
            sigslot::Manager::Instance.unmap(self.owner, target);
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
            sigslot::Manager::Instance.unmap(self.owner, each.target);
            [removed addObject:each];
        }
    }

    [_store removeObjectsInArray:removed];

    SYNCHRONIZED_END
}

- (void)disconnect:(SEL)sel ofTarget:(NSObject*)target {
    if (target == nil) {
        WARN("ss:target 不能为 nil");
        return;
    }
    
    SYNCHRONIZED_BEGIN
    
    NSMutableArray* removed = [NSMutableArray array];
    
    for (SSlot* each in _store)
    {
        if (each.target == target &&
            each.selector == sel)
        {
            sigslot::Manager::Instance.unmap(self.owner, target);
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
        if (s.count != -1 &&
            s.count-- == 0)
        {
            // 避免当共用时下一次因为==-1造成信号不匹配次数限制的规则
            s.count = 0;
            
            // 需要移除
            if (s.target)
                sigslot::Manager::Instance.unmap(self.owner, s.target);
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

- (void)setFps:(CGFloat)fps {
    _fps = fps;
    
    if (_fpsWaiting == nil)
        _fpsWaiting = [[NSAtomicCounter alloc] init];
}

@end

@implementation SSignals

@synthesize owner = _owner;

- (id)init {
    self = [super init];
    
    _sigslots = [[NSMutableDictionary alloc] init];
    _sigsets = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (void)dealloc {
    //LOG("signals dealloc %x, owner %x", self, self.owner);
    
    // 注销
    sigslot::Manager::Instance.unmap(_owner);
    
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

        ss.owner = self.owner;
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

- (SSlot*)connect:(SSignal*)sig withSelector:(SEL)sel ofTarget:(NSObject*)target {
    if ([self hasSignal:sig] == NO) {
        WARN("没有找到名为 %s 的信号 %s", sig.UTF8String, objc_getClassName(_owner));
        return nil;
    }
    
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
    if ([self hasSignal:sig] == NO) {
        WARN("没有找到名为 %s 的信号 %s", sig.UTF8String, objc_getClassName(_owner));
        return nil;
    }
    
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
    if ([self hasSignal:sig] == NO) {
        WARN("没有找到名为 %s 的信号 %s", sig.UTF8String, objc_getClassName(_owner));
        return nil;
    }
    
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
    if ([self hasSignal:sig] == NO) {
        WARN("没有找到名为 %s 的信号 %s", sig.UTF8String, objc_getClassName(_owner));
        return nil;
    }
    
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
    if ([self hasSignal:sig] == NO) {
        WARN("没有找到名为 %s 的信号 %s", sig.UTF8String, objc_getClassName(_owner));
        return nil;
    }
    
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
    return [self emit:sig withResult:self.owner];
}

- (SSignals*)emit:(NSString *)sig withTunnel:(SSlotTunnel *)tunnel {
    return [self emit:sig withResult:self.owner withTunnel:tunnel];
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
