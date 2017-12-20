
# ifndef __SSOBJECT_7D80F1C60D1C459198AD214DFCFAB4D4_H_INCLUDED
# define __SSOBJECT_7D80F1C60D1C459198AD214DFCFAB4D4_H_INCLUDED

# import "Variant.h"

typedef NSString SSignal;

@class SSlot;

typedef void (^SSlotCallbackBlock)(SSlot*s);
typedef void (^SSlotTargetCallbackBlock)(SSlot*s, id target);

/** 用于穿透所有 ss 调用的对象 */
@interface SSlotTunnel : NSObject

/** 否决控制，如果 == YES，则之后的 slot 都将被跳过
 @note 如果 slot 为并行激发（激活于不同多线程）则 vetoed 的表现不可知（undefined)
 */
@property (nonatomic, assign) BOOL vetoed;

/** 显式附带一个数据，其他数据可以通过 attachment 隐式添加 */
@property (nonatomic, retain) Variant *data;

/** 直接设置 vetoed = YES */
- (void)veto;

@end

enum {
    kSSlotCurrentThread = 0x1000, // 在当前线程中激活 slot
    kSSlotMainThread = 0x2000, // 在主线程中激活
    kSSlotBackgroudThread = 0x3000, // 在背景线程中激活
};

typedef uint SSlotThreadType;

@class SSlots;

@interface SSlot : NSOperation <NSCopying>

# ifdef DEBUG_MODE
@property (nonatomic, assign) SSlots* slots;
# endif

/** 源 slot */
@property (nonatomic, retain) SSlot* origin;

/** emit 次数上线，当 boundaryEmit == 0 时会被断开与 signal 的连接，默认为不限制 -1 */
@property (nonatomic, assign) NSInteger boundaryEmit;

/** 重新定向到的 signal
@note 当本 slot 激活时，将会重定向激活 target 上的该信号
 */
@property (nonatomic, retain) SSignal* redirect;

/** 回调 */
@property (nonatomic, copy) SSlotCallbackBlock cbBlock;
@property (nonatomic, copy) SSlotTargetCallbackBlock cbTargetBlock;

/** 回调、重定向等依赖的目标对象 */
@property (nonatomic, assign) NSObject* target;

/** 回调用的 sel */
@property (nonatomic, assign) SEL selector;

/** 回调到 类 的 静态函数 
 @note 此时 SEL selector 将对应到静态函数上
 */
@property (nonatomic, assign) Class classs;

/** 发送者
 @note 代表激活 signal 的对象
 */
@property (nonatomic, readonly, assign) NSObject* sender;

/** 传递的数据 */
@property (nonatomic, retain) Variant* data;

/** 可以并发运行的次数，超过的将放到队列里面处理
 @note slot => slot => slot
 */
@property (nonatomic, assign) int parallel;

/** 每秒钟可以执行的次数，超过的将被丢弃 */
@property (nonatomic, assign) float eps;
@property (nonatomic, assign) BOOL epsWaiting;

/** 多次 emit 所引发的回调的间隔
 @note slot => interval => slot => interval
 */
@property (nonatomic, assign) float interval;

/** 延迟多久回调
 @note slot => slot
           delay
             callback
 */
@property (nonatomic, assign) NSTimeInterval delay;

/** 所有 slot 都含有的统一的对象，可以用来控制流程等 */
@property (nonatomic, retain) SSlotTunnel* tunnel;

/** slot 回调应该位于的线程模型 */
@property (nonatomic, assign) SSlotThreadType thread;

/** 优先级，越小的越靠前, 默认为 kSSlotPriorityDefault */
@property (nonatomic, assign) uint priority;

/** 激活这个slot运行 */
- (void)emit;

/** 设置该slot为仅运行一次 */
- (instancetype)oneshot;

/** 设置为只能同时运行一个 */
- (instancetype)single;

/** 当 function 调用时从 stack（寄存器）中获得对象，仅适合当 callback 为 sel 的形式（即不为 sel:sslot*）时调用 */
//+ (instancetype)PopFromStack;

/** 使用 data 实例化一个 slot */
+ (instancetype)slotWithData:(Variant*)data;

@end

// 默认为 100
extern uint kSSlotPriorityDefault;
// 其他优先级别
extern uint kSSlotPriorityHigh, kSSlotPriorityLow;

@class SSignals;

/** slot 的管理数组 */
@interface SSlots : NSObject <NSCopying>

/** 所有者 */
@property (nonatomic, readonly, assign) NSObject* owner;

# ifdef DEBUG_MODE
@property (nonatomic, retain) NSString* signal;
@property (nonatomic, assign) SSignals* source;
# endif

/** 实例化一个slots */
+ (SSlots*)slots;

/** 添加 */
- (void)add:(SSlot*)s;

/** 清空 */
- (void)clear;

/** 断开连接 */
- (void)disconnectTarget:(NSObject*)target;
- (void)disconnectType:(Class)type;
- (void)disconnect:(SEL)sel ofTarget:(NSObject*)target;

/** 查找已经绑定的slot */
- (SSlot*)findSelector:(SEL)sel ofTarget:(NSObject*)target;
- (SSlot*)findSelector:(SEL)sel ofClass:(Class)cls;
- (SSlot*)findBlock:(SSlotCallbackBlock)block;
- (SSlot*)findBlock:(SSlotTargetCallbackBlock)block ofTarget:(NSObject*)target;
- (SSlot*)findRedirectSignal:(SSignal*)sig ofTarget:(NSObject*)target;

/** 将该插槽置于最顶，会被第一个激活 */
- (void)setTopmost:(SSlot*)s;

/** 获得到连接的数量 */
- (NSUInteger)count;

/** 遍历所有的slot */
- (void)foreach:(BOOL(^)(SSlot* s))block;

/** 运行一遍 */
- (SSlots*)run;

@end

/** 复合信号 
 @note 如果需要多个信号有联系的调用，则使用改类对信号进行封装
 */
@interface SComplexSignal : NSObject

/** 信号之间如果有一个信号被激活，则忽略其他信号的激活 */
+ (instancetype)Or:(SSignal*)sig, ...;

@end

@class NSAtomicCounter;

/** 对信号进行设置，以便于全局处理信号的表现 */
@interface SSignalSetting : NSObject

/** 阻塞的计数器 */
@property (nonatomic, assign) int isblocked;

/** 同 slot 的 eps */
@property (nonatomic, assign) float eps;
@property (nonatomic, readonly) NSAtomicCounter *epsWaiting;

/** 阻塞、解阻塞信号，如果信号阻塞，则激活该信号的请求将被忽略 */
- (void)block;
- (void)unblock;

@end

@protocol SSignals <NSObject>

/** 当信号被connect成功后回调 */
- (void)signals:(NSObject*)object signalConnected:(SSignal*)sig slot:(SSlot*)slot;

@optional

/** 当断开信号时回调
 @note clear 不会引起改回调 
 */
- (void)signals:(NSObject*)object signalDisconnected:(SSignal*)sig;

@end

/** 信号类 */
@interface SSignals : NSObject

/** 所有者 */
@property (nonatomic, readonly, assign) NSObject* owner;

/** 会将所有的 signal 激活转发到 redirect 对象上，需要注意必须保证 redirect 上同样具有被激活的信号 */
@property (nonatomic, assign) NSObject* redirect;

/** delegate 后处理 */
@property (nonatomic, assign) id<SSignals> delegate;

/** 根据参数断开 slot */
- (void)disconnect;
- (void)disconnectToTarget:(NSObject*)target;
- (void)disconnectWithSelector:(SEL)sel ofTarget:(NSObject*)target;
- (void)disconnect:(SSignal*)sig withSelector:(SEL)sel ofTarget:(NSObject*)target;
- (void)disconnect:(SSignal*)sig ofTarget:(NSObject*)target;
- (void)disconnect:(SSignal*)sig ofType:(Class)type;
- (void)disconnect:(SSignal*)sig;

/** 注册一个信号 */
- (SSignals*)addSignal:(SSignal*)sig;

/** 是否含有该信号 */
- (BOOL)hasSignal:(SSignal*)sig;

/** 查找该信号的设置，所有 slot 在激活时会根据该设置来初始化调用 */
- (SSignalSetting*)settingForSignal:(NSString*)sig;

// 连接 slot
/** 激发时调用 target 的 sel 方法 */
- (SSlot*)connect:(SSignal*)sig withSelector:(SEL)sel;
- (SSlot*)connect:(SSignal*)sig withSelector:(SEL)sel ofTarget:(NSObject*)target;
/** 激发时调用 class 的 sel 静态方法 */
- (SSlot*)connect:(SSignal*)sig withSelector:(SEL)sel ofClass:(Class)cls;
/** 激发时调用 block，需要自己维护和block有关系的状态 */
- (SSlot*)connect:(SSignal*)sig withBlock:(SSlotCallbackBlock)block;
/** 激发时调用 block，如果在 block 中使用 self，会存在当位于 非arc 环境下编译，self 会自动 retain 而不释放，这就会导致代码臃肿或者运行错误（死链），所以此时可以把 self（或其他会引起死链的对象）通过 oftarget 传出，再在 block 中使用 target，即可避免这种问题 */
- (SSlot*)connect:(SSignal*)sig withBlock:(SSlotTargetCallbackBlock)block ofTarget:(NSObject*)target;
/** 激发时将会自动激活 target 上的 redirect-signal 信号 */
- (SSlot*)connect:(SSignal*)sig redirectTo:(SSignal*)sig2 ofTarget:(NSObject*)target;
- (SSlot*)connect:(SSignal*)sig ofTarget:(NSObject*)target;

/** 复合连接 */
- (SSlot*)connects:(SComplexSignal*)sigs withBlock:(SSlotCallbackBlock)block;

/** 重定向一组 sigs 到另外一个对象，需要保证 target 身上具有将被激活的信号 */
- (void)redirects:(NSArray*)sigs toTarget:(NSObject*)target;

/** 激活信号 */
- (SSignals*)emit:(SSignal*)sig;
- (SSignals*)emit:(SSignal*)sig withResult:(NSObject*)result;
- (SSignals*)emit:(SSignal*)sig withData:(void*)data;
- (SSignals*)emit:(SSignal*)sig withVariant:(Variant*)variant;
- (SSignals*)emit:(SSignal*)sig withTunnel:(SSlotTunnel*)tunnel;
- (SSignals*)emit:(SSignal*)sig withResult:(NSObject*)result withTunnel:(SSlotTunnel*)tunnel;
- (SSignals*)emit:(NSString *)sig withVariant:(Variant *)variant withTunnel:(SSlotTunnel*)tunnel;

/** 查找信号对应的 slots */
- (SSlots*)findSlots:(SSignal*)sig;

/** 是否存在连接到该信号上的插槽 */
- (BOOL)isConnected:(SSignal*)sig;

/** 阻塞、解阻塞所有的 slots */
- (void)block;
- (void)unblock;

@end

@interface NSObject (SignalSlot)

/** 通用对象的 signals 初始化 
 @note 如果内部没有对 signals 进行 instance，则返回 nil
 */
- (SSignals*)signals;

/** 直接获取内部的 signals 对象
 @note 不确保是否已经 instance 
 */
- (SSignals*)touchSignals;

/** 初始化 signals 
 @note 不要直接调用，是用来给宏使用的
 */
- (void)initSignals;

@end

# define SIGNAL_DECL(key) static SSignal* const key =
//# define SIGNAL_EXTERN(key) static SSignal* const key;

# define SIGNALS \
- (void)initSignals;

# define SIGNALS_BEGIN \
- (void)initSignals { \
[super initSignals];

# define SIGNALS_END }

# define SIGNAL_ADD(sig) \
[self.touchSignals addSignal:sig];

/*
# define SIGNAL_ADD_EXPRESS(sig, express) \
SIGNAL_ADD(sig); \
[self.signals connect:sig withBlock:^(SSlot* s){ express; }];
 */

# define SIGNAL_ADD_SLOT(sig, slot) \
SIGNAL_ADD(sig); \
[self.signals connect:sig withSelector:slot ofTarget:self];

// 标记为 outlet 的函数，代表这个函数内部没有 connect，是为提供到外部进行 connect 操作
// 例如： - outlet(Test); 外部既可以 obj.signals connect:sig withSelector:@selector(outletTest) ....
# define outlet(func) (void)outlet##func

# endif
