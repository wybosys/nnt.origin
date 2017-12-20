
# ifndef __ARCHITECT_3F8B291E5DB74BE7B4C351D7615CE901_H_INCLUDED
# define __ARCHITECT_3F8B291E5DB74BE7B4C351D7615CE901_H_INCLUDED

# import <objc/runtime.h>

# define PRIVATE_CLASS(cls) \
cls##_PrivateClass

# define PRIVATE_CLASS_DECL(cls) \
@class PRIVATE_CLASS(cls);

# define PRIVATE_DECL(cls) \
PRIVATE_CLASS(cls)* d_ptr;

# define PRIVATE_CONSTRUCT(cls) \
d_ptr = [PRIVATE_CLASS(cls) alloc]; \
d_ptr->d_owner = self; \
[d_ptr init];

# define PRIVATE_DESTROY() \
ZERO_RELEASE(d_ptr);

# define PRIVATE_IMPL_BEGIN(cls, sup, exp) \
@interface PRIVATE_CLASS(cls) : sup { \
exp \
@public \
cls* d_owner; \
}

# define PRIVATE_IMPL(cls) \
@end \
@implementation PRIVATE_CLASS(cls)

# define PRIVATE_IMPL_END() \
@end

extern Class PrivateClass_FromObject(id obj);

# define SHARED_IMPL_EXT(name) \
+ (id)name { \
static id obj = nil; \
DISPATCH_ONCE_BEGIN \
obj = [[self alloc] init]; \
if ([self respondsToSelector:@selector(onInstanceShared)]) [self performSelector:@selector(onInstanceShared)]; \
DISPATCH_ONCE_END \
DEBUG_EXPRESS({ \
if ([obj isMemberOfClass:[self class]] == NO) FATAL("错误的 shared 类型, 期望 %s，实际 %s", class_getName([self class]), objc_getClassName(obj)); }); \
return obj; }

# define SHARED_IMPL SHARED_IMPL_EXT(shared);

# endif
