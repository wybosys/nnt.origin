
# ifndef __COMPILER_DCBD6572E80C4FBAAF9E371EDEB135B5_H_INCLUDED
# define __COMPILER_DCBD6572E80C4FBAAF9E371EDEB135B5_H_INCLUDED

# ifdef __cplusplus
#   define CXX_MODE
#   include <iostream>
#   define C_BEGIN extern "C" {
#   define C_END }
#   define LANG_NEED_CXX
#   define CXX_SYMBOL(sym) sym
#   define CXX_EXPRESS(exp) exp
# else
#   define C_BEGIN
#   define C_END
#   define LANG_NEED_CXX please rename to .mm
#   define CXX_SYMBOL(sym)
#   define CXX_EXPRESS(exp) {}
# endif

# if defined(__OBJC__) || defined(__OBJC2__)
#   define OBJC_MODE
#   import <Foundation/Foundation.h>
#   include <TargetConditionals.h>
#   if __has_feature(objc_arc) == 1
#     define OBJC_ARC 1
#   endif
#   ifdef OBJC_ARC
#     define OBJC_NEED_ARC
#   endif
#   define OBJC_SYMBOL(sym) sym
#   define OBJC_EXPRESS(exp) exp
# else
#   define OBJC_SYMBOL(sym)
#   define OBJC_EXPRESS(exp) {}
# endif

# if TARGET_OS_IPHONE
#   define IOS_DEVICE
#   if TARGET_IPHONE_SIMULATOR
#     define IOS_SIMULATOR
#   else
#     define IOS_PHY
#   endif
# else
#   define MAC_DEVICE
# endif

# define COMMA ,
# define PASS {}

# define _PRAGMA(X) _Pragma (#X)
# define CC_WARNING_PUSH _PRAGMA(GCC diagnostic push)
# define CC_WARNING_POP _PRAGMA(GCC diagnostic pop)
# define CC_WARNING_DISABLE(warn) _PRAGMA(GCC diagnostic ignored #warn)
# define CC_MESSAGE(msg) _PRAGMA(message msg)

# ifdef _LP64
#   define X64_MODE
#   define X64_SYMBOL(sym) sym
#   define X32_SYMBOL(sym)
CC_WARNING_DISABLE(-Wshorten-64-to-32) // 屏蔽64位下 long 到 int 的 warning，这种情况在业务中一般不会出错
# else
#   define X32_MODE
#   define X64_SYMBOL(sym)
#   define X32_SYMBOL(sym) sym
# endif

# define C_MODE

# if defined(_DEBUG) || defined(_DEBUG_) || defined(DEBUG)
#   define PRECOMP_DEBUG_MODE
# endif

# ifdef PRECOMP_DEBUG_MODE
#   define DEBUG_MODE
#   define DEBUG_EXPRESS(exp) exp
#   define RELEASE_EXPRESS(exp) {}
#   define DEBUG_SYMBOL(sym) sym
#   define RELEASE_SYMBOL(sym)
#   define TEST_EXPRESS(exp) exp
# else
#   define RELEASE_MODE
#   define DEBUG_EXPRESS(exp) {}
#   define RELEASE_EXPRESS(exp) exp
#   define DEBUG_SYMBOL(sym)
#   define RELEASE_SYMBOL(sym) sym
# endif

# if defined(DISTRIBUTION)
#   define DISTRIBUTION_MODE
#   define DISTRIBUTION_EXPRESS(exp) exp
#   define DISTRIBUTION_SYMBOL(sym) sym
#   define DEVELOP_EXPRESS(exp) {}
#   define DEVELOP_SYMBOL(sym)
# else
#   define DEVELOP_MODE
#   define DISTRIBUTION_EXPRESS(exp) {}
#   define DISTRIBUTION_SYMBOL(sym)
#   define DEVELOP_EXPRESS(exp) exp
#   define DEVELOP_SYMBOL(sym) sym
# endif

# define _LOG_SYNCHRONIZED_BEGIN \
@synchronized(self) { \
LOG("sync object:%x %s:%s:%d enter", self, __FILE__, __FUNCTION__, __LINE__); \

# define _LOG_SYNCHRONIZED_END \
LOG("sync object:%x %s:%s:%d leave", self, __FILE__, __FUNCTION__, __LINE__); \
}

# define _SYNCHRONIZED_BEGIN @synchronized(self) {
# define _SYNCHRONIZED_END }
# define SYNCHRONIZED_EXPRESS(target, exp) @synchronized(target) { exp; }
# define SYNCHRONIZED_BEGIN _SYNCHRONIZED_BEGIN
# define SYNCHRONIZED_END _SYNCHRONIZED_END

# ifdef CXX_MODE
#   define NS_BEGIN(ns) namespace ns {
#   define NS_END }
#   define C_BEGIN extern "C" {
#   define C_END }
#   define NS_USING(ns) using namespace ns;
#   define CXXTYPE(cls) cls
namespace nnt {};
#   define CXX_MODBEGIN(ns) namespace nnt { namespace ns {
#   define CXX_MODEND }}
# else
#   define C_BEGIN
#   define C_END
typedef struct {} cxxclass_t;
#   define CXXTYPE(cls) cxxclass_t
# endif

# ifdef __IPHONE_6_0
#   define IOS_SDK_6 1
# endif

# ifdef __IPHONE_7_0
#   define IOS_SDK_7 1
# endif

# ifdef __IPHONE_8_0
#   define IOS_SDK_8 1
# endif

# ifdef __IPHONE_9_0
#   define IOS_SDK_9 1
# endif

# ifdef __IPHONE_10_0
#   define IOS_SDK_10 1
# endif

# define EXTERN extern 

# define IOS6_FEATURES
# if !defined(IOS_SDK_6) && defined(IOS6_FEATURES)
#   undef IOS6_FEATURES
# endif

# define IOS7_FEATURES
# if !defined(IOS_SDK_7) && defined(IOS7_FEATURES)
#   undef IOS7_FEATURES
# endif

# define IOS8_FEATURES
# if !defined(IOS_SDK_8) && defined(IOS8_FEATURES)
#   undef IOS8_FEATURES
# endif

# define IOS9_FEATURES
# if !defined(IOS_SDK_9) && defined(IOS9_FEATURES)
#   undef IOS9_FEATURES
# endif

# define IOS10_FEATURES
# if !defined(IOS_SDK_10) && defined(IOS10_FEATURES)
#  undef IOS10_FEATURES
# endif

# define IOS7_MINIMUM 7
# define IOS_MINIMUM IOS7_MINIMUM

C_BEGIN

extern void __debug_vlog(char const*, va_list);
extern void __debug_vinfo(char const*, va_list);
extern void __debug_vnoti(char const*, va_list);
extern void __debug_vfatal(char const*, va_list);
extern void __debug_vwarn(char const*, va_list);

extern void __debug_log(char const*, ...);
extern void __debug_info(char const*, ...);
extern void __debug_noti(char const*, ...);
extern void __debug_fatal(char const*, ...);
extern void __debug_warn(char const*, ...);

static const bool kDebugMode = DEBUG_SYMBOL(true) RELEASE_SYMBOL(false);
static const bool kReleaseMode = DEBUG_SYMBOL(false) RELEASE_SYMBOL(true);
static const bool kDevelopMode = DEVELOP_SYMBOL(true) DISTRIBUTION_SYMBOL(false);
static const bool kDistributionMode = DEVELOP_SYMBOL(false) DISTRIBUTION_SYMBOL(true);

inline void __space_express() {}

C_END

# define SPACE {}
# define LOG(...) DEBUG_SYMBOL(__debug_log(__VA_ARGS__)) RELEASE_SYMBOL(__space_express())
# define INFO(...) DEBUG_SYMBOL(__debug_info(__VA_ARGS__)) RELEASE_SYMBOL(__space_express())
# define NOTI(...) DEBUG_SYMBOL(__debug_noti(__VA_ARGS__)) RELEASE_SYMBOL(__space_express())
# define FATAL(...) DEBUG_SYMBOL(__debug_fatal(__VA_ARGS__)) RELEASE_SYMBOL(__space_express())
# define WARN(...) DEBUG_SYMBOL(__debug_warn(__VA_ARGS__)) RELEASE_SYMBOL(__space_express())

# define TODO(msg) \
NOTI("计划实现 %s, %s:%s:%d", msg, __FILE__, __FUNCTION__, __LINE__); \
CC_MESSAGE("TODO 计划实现 " msg);

# define NEEDIMPL(msg) \
DEVELOP_EXPRESS([UIHud Text:@msg]); \
TODO(msg);

# define THROW(msg) DEBUG_EXPRESS(@throw [NSException exceptionWithName:@"fatal" reason:msg userInfo:nil]);

# define ASSERT_ALWAYS(exp, msg) \
{if ((exp) == NO) { \
NSString* str = [NSString stringWithFormat:@"Assert: Failed check [%s] \n line:%d \n function:%s \n file:%s \n message:%@", #exp, __LINE__, __FUNCTION__, __FILE__, msg]; \
THROW(str); \
}}

# define ASSERTMSG(exp, msg) DEBUG_EXPRESS(ASSERT_ALWAYS(exp, msg))
# define ASSERT(exp) ASSERTMSG(exp, @"")

# define TRIEXPRESS(cond, expt, expf) ((cond) ? (expt) : (expf))
# define VALUEXCP(v0, v1) TRIEXPRESS(v0, v0, v1)
# define VALUEAPP(v0, exp) TRIEXPRESS(v0, (v0 exp), v0)

// 用以优化长变量名的区间判断问题
# define BETWEEN(l, v, h) ((l v) && (v h))

extern bool kDeviceRunningSimulator;
extern bool kDeviceRunningOniPAD;

# define SIMULATOR_EXPRESS(exp) \
{if (kDeviceRunningSimulator) {exp;}}

# define SIMULATOR_DEXPRESS(exp) \
DEBUG_EXPRESS(SIMULATOR_EXPRESS(exp))

# define SIMULATOR_VALUE(v0, v1) \
(kDeviceRunningSimulator ? (v0) : (v1))

# ifdef OBJC_MODE

@interface NSError (dbg)

// 打印日志
- (void)log;

@end

@interface NSException (dbg)

// 打印日志
- (void)log;

// 附带提示信息的打印日志
- (void)log:(NSString*)str;

@end

# endif

// 类似于 i++ 的后操作
# define ATOMIC_INC(x, v) __sync_fetch_and_add(&x, v)
# define ATOMIC_DEC(x, v) __sync_fetch_and_sub(&x, v)

// 类似于 ++i 的前操作
# define ATOMIC_ADD(x, v) __sync_add_and_fetch(&x, v)
# define ATOMIC_SUB(x, v) __sync_sub_and_fetch(&x, v)

# define MIN_SUB(x, v, min) (((x) - (v) < (min)) ? (min) : (x) - (v))
# define MAX_ADD(x, v, max) (((x) + (v) > (max)) ? (max) : (x) + (v))

# define NEED // 必要参数
# define IN // 输入参数
# define OUT // 输入参数
# define INOUT // 输入、输出参数
# define OPTIONAL // 可选参数（可以不传）
# define OPTMUST // 可选但是必须传一个的参数

# define with(obj, exp) { typeof(obj) it = (obj); while (it) { exp; break; } }

typedef struct _int_b8 {
    char _0;
    char _1;
    char _2;
    char _3;
} int_b8;

typedef struct _short_b8 {
    char _0;
    char _1;
} short_b8;

typedef struct _char_b4 {
    int _0:4;
    int _1:4;
} char_b4;

typedef struct _int_b4 {
    int _0:4;
    int _1:4;
    int _2:4;
    int _3:4;
    int _4:4;
    int _5:4;
    int _6:4;
    int _7:4;
} int_b4;

typedef struct _short_b4 {
    int _0:4;
    int _1:4;
    int _2:4;
    int _3:4;
} short_b4;

typedef unsigned char byte;
typedef long long longlong;
typedef unsigned long long ulonglong;

# include <math.h>

# ifndef REAL_DEFINED
# define REAL_DEFINED
typedef X64_SYMBOL(double) X32_SYMBOL(float) real;
extern real fabsr(real v);
# endif

typedef union any_number {
    char sc;
    unsigned char uc;
    short ss;
    unsigned short us;
    int si;
    unsigned int ui;
    long sl;
    unsigned long usl;
    float f;
    double d;
    long long sll;
    unsigned long long ull;
} any_number;

# endif
