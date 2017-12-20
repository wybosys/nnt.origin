
# ifndef __VARIANT_A54DB49C5C3E4E12928C98A9F29FDB30_H_INCLUDED
# define __VARIANT_A54DB49C5C3E4E12928C98A9F29FDB30_H_INCLUDED

# import "Compiler.h"

@interface Variant : NSObject <NSCopying> {
    id _refobj;
    void* _ptrobj;
}

+ (Variant*)variantWithObject:(id)obj;
+ (Variant*)variantWithPtr:(void*)obj;

- (id)initWithObject:(id)obj;
- (id)initWithPtr:(void*)obj;

// 绑定的对象
- (id)object;

// 其他标准数据
@property (nonatomic, assign) any_number number;

@end

# endif
