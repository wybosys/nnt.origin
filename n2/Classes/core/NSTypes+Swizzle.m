
# import "Common.h"
# import "NSTypes+Swizzle.h"

@protocol NSMutableURLRequestSwizzle <NSObject>

- (void)SWIZZLE_CALLBACK(setValue):(NSString*)value forHTTPHeaderField:(NSString*)field;

@end

@implementation NSMutableURLRequest (swizzle)

static objc_swizzle_t __gs_mur_setvalue4field;

- (NSString*)SWIZZLE_CALLBACK(value):(NSString*)value forHTTPHeaderField:(NSString*)field {
    return value;
}

- (void)__swizzle_setvalue:(NSString*)value forHTTPHeaderField:(NSString*)field {
    value = [self SWIZZLE_CALLBACK(value):value forHTTPHeaderField:field];
    
    objc_swizzle_t os = __gs_mur_setvalue4field;
    ((void(*)(id, SEL, NSString*, NSString*))os.pimpl)(self, os.psel, value, field);
    
    [(id<NSMutableURLRequestSwizzle>)self SWIZZLE_CALLBACK(setValue):value forHTTPHeaderField:field];
}

+ (void)Swizzles {
    Class cls = [NSMutableURLRequest class];
    
    [cls SwizzleMethod:@selector(setValue:forHTTPHeaderField:) with:@selector(__swizzle_setvalue:forHTTPHeaderField:) with:&__gs_mur_setvalue4field];
}

@end

@implementation NSTypes

+ (void)Swizzles {
    [NSMutableURLRequest Swizzles];
}

@end
