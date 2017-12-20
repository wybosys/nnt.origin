
# ifndef __UITYPES_SWIZZLE_264D91719A12489AAEDF1F76C2F57E82_H_INCLUDED
# define __UITYPES_SWIZZLE_264D91719A12489AAEDF1F76C2F57E82_H_INCLUDED

@interface UIResponder (swizzle)

@property (nonatomic, assign) BOOL isResponding;

@end

@interface UIView (swizzle)

@end

@interface UIControl (swizzle)

@end

@interface UIScrollView (swizzle)

@end

@interface UIViewController (swizzle)

@end

@interface UITableView (swizzle)

@end

@interface UINavigationItem (swizzle)

@end

@interface UINavigationBar (swizzle)

@end

@interface UINavigationController (swizzle)

@end

@interface UITypes : NSObject

+ (void)Swizzles;

@end

# define UIVIEWS_SWIZZLE_IMPL_TOUCHES \
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { \
[super touchesBegan:touches withEvent:event]; \
[self performSelector:@selector(SWIZZLE_CALLBACK(touches_begin):withEvent:) withObject:touches withObject:event]; \
} \
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event { \
[super touchesCancelled:touches withEvent:event]; \
[self performSelector:@selector(SWIZZLE_CALLBACK(touches_cancel):withEvent:) withObject:touches withObject:event]; \
} \
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event { \
[super touchesEnded:touches withEvent:event]; \
[self performSelector:@selector(SWIZZLE_CALLBACK(touches_end):withEvent:) withObject:touches withObject:event]; \
} \
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event { \
[super touchesMoved:touches withEvent:event]; \
[self performSelector:@selector(SWIZZLE_CALLBACK(touches_moved):withEvent:) withObject:touches withObject:event]; \
}

// 必须写一下，不然调用不到swizzle
# define UISWIZZLE_HAS_DRAW \
- (void)drawRect:(CGRect)rect { \
[super drawRect:rect]; \
}

# endif
