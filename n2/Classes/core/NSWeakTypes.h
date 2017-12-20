
# ifndef __NSWEAKTYPES_0048CD2A5D264887830155847C0AADDC_H_INCLUDED
# define __NSWEAKTYPES_0048CD2A5D264887830155847C0AADDC_H_INCLUDED

/** 对填入的元素不使用引用计数 */
@interface NSWeakArray : NSObject

- (void)addObject:(id)obj;
- (void)foreach:(BOOL(^)(id each))block;
- (void)removeAllObjects;
- (void)removeObject:(id)obj;
- (NSUInteger)count;

@end

/** 对填入的元素不使用引用计数 */
@interface NSWeakSet : NSObject

- (void)addObject:(id)obj;
- (void)foreach:(BOOL(^)(id each))block;
- (void)removeAllObjects;
- (void)removeObject:(id)obj;
- (NSUInteger)count;

@end

/** 直接保存指针 */
@interface NSRawObjectVector : NSObject

- (void*)allocObject:(size_t)size;
- (void*)objectAtIndex:(NSUInteger)idx;
- (NSUInteger)count;
- (void)removeAllObjects;

@end

# endif
