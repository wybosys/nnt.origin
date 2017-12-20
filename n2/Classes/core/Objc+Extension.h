
# ifndef __OBJCEXTENSION_655B709462CC494A8F774719202373E0_H_INCLUDED
# define __OBJCEXTENSION_655B709462CC494A8F774719202373E0_H_INCLUDED

# import "Compiler.h"
# import <objc/objc.h>
# import <objc/runtime.h>

# ifdef OBJC_ARC

# define OBJC_ARC_SYMBOL(sym) sym
# define OBJC_NOARC_SYMBOL(sym)

# define ZERO_RELEASE(obj) obj = nil;
# define SAFE_RELEASE(obj) {}
# define SUPER_DEALLOC {}

# define SAFE_COPY(obj, val) obj = [val copy];
# define SAFE_RETAIN(obj) ^id() { return obj; } ();
# define SAFE_RELEASE(obj) {}
# define ZERO_RELEASE(obj) obj = nil;
# define SAFE_AUTORELEASE(obj) {}

# define PROPERTY_ASSIGN(_old, _new) _old = _new;
# define PROPERTY_ASSIGN_RELEASE(_val) {}
# define PROPERTY_RETAIN(_old, _new) _old = _new;
# define PROPERTY_RETAIN_RELEASE(_val) {}
# define PROPERTY_COPY(_old, _new) _old = [_new copy];

# else

# define OBJC_ARC_SYMBOL(sym)
# define OBJC_NOARC_SYMBOL(sym) sym

# define SUPER_DEALLOC [super dealloc];

# define SAFE_COPY(obj, val) \
{ \
id tmp = [val copy]; \
obj = tmp; \
SAFE_RELEASE(tmp); \
}

# define SAFE_RETAIN(obj) [obj retain]

# define SAFE_RELEASE(obj) \
{ \
int const rc = (int)[obj retainCount]; \
[obj release]; \
if (rc == 1) \
{ \
obj = nil; \
} \
}

# define ZERO_RELEASE(obj) \
{ \
[obj release]; \
obj = nil; \
}

# define SAFE_AUTORELEASE(obj) [obj autorelease]

# define PROPERTY_ASSIGN(_old, _new) \
if (_old != _new) \
{ \
_old = _new; \
}

# define PROPERTY_ASSIGN_RELEASE(_val) \
PASS

# define PROPERTY_RETAIN(_old, _new) \
if (_old != _new) \
{ \
[_old release]; \
_old = [_new retain]; \
}

# define PROPERTY_RETAIN_RELEASE(_val) \
SAFE_RELEASE(_val);

# define PROPERTY_COPY(_old, _new) \
if (_old != _new) \
{ \
[_old release]; \
_old = [_new copy]; \
}

# endif

# define OBJC_BRIDGE OBJC_ARC_SYMBOL(__bridge)

# define PROPERTY_COPY_RELEASE \
PROPERTY_RETAIN_RELEASE

# define BLOCK_RETAIN(_old, _new) \
if (_old != _new) { \
Block_release(_old); \
_old = Block_copy(_new); \
}

# define BLOCK_WEAK_NAMED(name, obj) OBJC_NOARC_SYMBOL(__block) typeof(obj) OBJC_ARC_SYMBOL(__weak) name = obj;
# define BLOCK_WEAK_EXT(obj) BLOCK_WEAK_NAMED(weak_##obj, obj)
# define BLOCK_WEAK_SELF() BLOCK_WEAK_EXT(self)

# define BLOCK_STRONG_EXT(obj) typeof(obj) OBJC_ARC_SYMBOL(__strong) strong_##obj = weak_##obj;
# define BLOCK_STRONG_SELF() BLOCK_STRONG_EXT(self)

EXTERN id class_callMethod(Class cls, SEL sel, ...);
EXTERN BOOL class_existMethod(Class cls, SEL sel);
EXTERN void class_swizzleMethod(Class c, SEL origs, SEL news);
EXTERN IMP class_getImplementation(Class cls, SEL sel);

typedef struct _objc_swizzle_t
{
    Class cls; // 类
    IMP impl; // 当前的实现
    IMP pimpl; // 原始的实现
    SEL sel; // 当前的实现
    SEL psel; // 原始的 sel
} objc_swizzle_t;

# define SWIZZLE_CALLBACK(which) __swizzle_callback_##which

EXTERN char const* objc_getClassName(id obj);

// 获得到属性的对象
EXTERN id object_getProperty(id obj, objc_property_t prop);

// 获得到属性对象，如果该属性不是 id 类型，则返回 nil
EXTERN id object_getPropertyObject(id obj, objc_property_t prop);

// 判断 property 是否是只读的
EXTERN BOOL property_isReadonly(objc_property_t prop);

// 运行sel
//EXTERN id object_invokeSelector(id obj, SEL sel, id argu);
//EXTERN id object_syncInvokeSelector(id obj, SEL sel, id argu);

@interface NSObject (swizzle)

+ (BOOL)SwizzleMethod:(SEL)sel with:(SEL)tosel with:(objc_swizzle_t*)data;
+ (void)Swizzles;

@end

# ifdef OBJC_ARC
# define AUTORELEASE_BEGIN {
# define AUTORELEASE_END }
# else
# define AUTORELEASE_BEGIN  @autoreleasepool {
# define AUTORELEASE_END }
# endif
# define AUTORELEASE_EXPRESS(exp) AUTORELEASE_BEGIN exp; AUTORELEASE_END

# define REPEATE_EXPRESS(count, exp) \
for (int i = count; i != 0; --i) { exp; }

# define DISPATCH_DELAY_BEGIN(sec) { \
dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(sec * NSEC_PER_SEC)); \
dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
# define DISPATCH_DELAY_END });}
# define DISPATCH_DELAY(sec, exp) \
DISPATCH_DELAY_BEGIN(sec) exp; DISPATCH_DELAY_END

# define DISPATCH_ONCE_BEGIN \
{ static dispatch_once_t __once; \
dispatch_once(&__once, ^ {
# define DISPATCH_ONCE_END }); }
# define DISPATCH_ONCE_EXPRESS(exp) DISPATCH_ONCE_BEGIN exp; DISPATCH_ONCE_END;

# define DISPATCH_ASYNC_ONMAIN(exp) \
{dispatch_async(dispatch_get_main_queue(), ^{@autoreleasepool{ \
exp; \
}});}

# define DISPATCH_ASYNC_BEGIN \
{dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{@autoreleasepool{
# define DISPATCH_ASYNC_END \
}});}

# define DISPATCH_ASYNC(exp) \
DISPATCH_ASYNC_BEGIN \
exp; \
DISPATCH_ASYNC_END

# define DISPATCH_ONMAIN(exp) \
{if ([NSThread isMainThread]) {@autoreleasepool{ exp; }} else { \
dispatch_sync(dispatch_get_main_queue(), ^{@autoreleasepool{ exp; }}); \
}}

# define NSCLASS_SUBCLASS(name, from) \
@interface name : from @end \
@implementation name @end

# define BLOCK_RETURN(exp) ^id(){ exp }()

# define NSOBJECT_EXPDEF(exp, def) \
BLOCK_RETURN({ \
id o = exp; \
if (o == nil) \
return def; \
return o; \
})

# define OBJC_NOEXCEPTION(exp) @try { exp; } @catch (...) {}

# define TYPE_EXPRESS(obj, type, exp) \
if ([obj isKindOfClass:[type class]]) { type* val = (id)obj; exp; }

# endif
