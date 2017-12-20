
# ifndef __UILAYOUT_12BB9EE5A57D48049F3C67D23588CC9F_H_INCLUDED
# define __UILAYOUT_12BB9EE5A57D48049F3C67D23588CC9F_H_INCLUDED

@class UIVBox;
@class UIHBox;
@class UIHFlow;

@interface UILayout : NSObject

- (id)initWithRect:(CGRect)rc withSpacing:(CGFloat)space;

// 初始参数设置
@property (nonatomic, assign) CGRect rect;
@property (nonatomic, readonly) CGPoint position;
@property (nonatomic, assign) CGMargin margin;
@property (nonatomic, assign) CGPadding padding;
@property (nonatomic, copy) void(^setblock)(CGRect rc);
@property (nonatomic, assign) CGFloat minFlexValue;

// 把 layout 设置到这个 view 之内，可以使之后的 layout 布局按照 inView 的 bounds 来进行
@property (nonatomic, assign) UIView* inView;

// 重设
- (void)reset;

// 增加大小
- (id)addFlex:(CGFloat)flex toView:(UIView*)view;
- (id)addPixel:(CGFloat)pixel toView:(UIView*)view;

// 增加大小，但是不更改view大小，使用回调后处理
- (id)addFlex:(CGFloat)flex toView:(UIView*)view set:(void(^)(CGRect rc, UIView* view))block;
- (id)addPixel:(CGFloat)pixel toView:(UIView*)view set:(void(^)(CGRect rc, UIView* view))block;

- (id)addFlex:(CGFloat)flex withSpacing:(CGFloat)space VBox:(void(^)(UIVBox* box))block;
- (id)addFlex:(CGFloat)flex withSpacing:(CGFloat)space HBox:(void(^)(UIHBox* box))block;
- (id)addFlex:(CGFloat)flex withSpacing:(CGFloat)space HFlow:(void(^)(UIHFlow* box))block;

- (id)addFlex:(CGFloat)flex VBox:(void(^)(UIVBox* box))block;
- (id)addFlex:(CGFloat)flex HBox:(void(^)(UIHBox* box))block;
- (id)addFlex:(CGFloat)flex HFlow:(void(^)(UIHFlow* box))block;

- (id)addFlex:(CGFloat)flex withSpacing:(CGFloat)space VBox:(void(^)(UIVBox* box))block set:(void(^)(CGRect rc))block;
- (id)addFlex:(CGFloat)flex withSpacing:(CGFloat)space HBox:(void(^)(UIHBox* box))block set:(void(^)(CGRect rc))block;
- (id)addFlex:(CGFloat)flex withSpacing:(CGFloat)space HFlow:(void(^)(UIHFlow* box))block set:(void(^)(CGRect rc))block;

- (id)addFlex:(CGFloat)flex VBox:(void(^)(UIVBox* box))block set:(void(^)(CGRect rc))block;
- (id)addFlex:(CGFloat)flex HBox:(void(^)(UIHBox* box))block set:(void(^)(CGRect rc))block;
- (id)addFlex:(CGFloat)flex HFlow:(void(^)(UIHFlow* box))block set:(void(^)(CGRect rc))block;

// 以固定像素长度布局
- (id)addPixel:(CGFloat)pixel withSpacing:(CGFloat)space VBox:(void(^)(UIVBox* box))block;
- (id)addPixel:(CGFloat)pixel withSpacing:(CGFloat)space HBox:(void(^)(UIHBox* box))block;
- (id)addPixel:(CGFloat)pixel withSpacing:(CGFloat)space HFlow:(void(^)(UIHFlow* box))block;

- (id)addPixel:(CGFloat)pixel VBox:(void(^)(UIVBox* box))block;
- (id)addPixel:(CGFloat)pixel HBox:(void(^)(UIHBox* box))block;
- (id)addPixel:(CGFloat)pixel HFlow:(void(^)(UIHFlow* box))block;

- (id)addPixel:(CGFloat)pixel withSpacing:(CGFloat)space VBox:(void(^)(UIVBox* box))block set:(void(^)(CGRect rc))block;
- (id)addPixel:(CGFloat)pixel withSpacing:(CGFloat)space HBox:(void(^)(UIHBox* box))block set:(void(^)(CGRect rc))block;
- (id)addPixel:(CGFloat)pixel withSpacing:(CGFloat)space HFlow:(void(^)(UIHFlow* box))block set:(void(^)(CGRect rc))block;

- (id)addPixel:(CGFloat)pixel VBox:(void(^)(UIVBox* box))block set:(void(^)(CGRect rc))block;
- (id)addPixel:(CGFloat)pixel HBox:(void(^)(UIHBox* box))block set:(void(^)(CGRect rc))block;
- (id)addPixel:(CGFloat)pixel HFlow:(void(^)(UIHFlow* box))block set:(void(^)(CGRect rc))block;

// 增加以长宽比作为指标的大小
- (id)addAspectWithX:(CGFloat)x andY:(CGFloat)y toView:(UIView*)view;
- (id)addAspectWithX:(CGFloat)x andY:(CGFloat)y toView:(UIView*)view set:(void(^)(CGRect rc, UIView* view))block;
- (id)addAspectWithX:(CGFloat)x andY:(CGFloat)y withSpacing:(CGFloat)space VBox:(void(^)(UIVBox* box))block;
- (id)addAspectWithX:(CGFloat)x andY:(CGFloat)y withSpacing:(CGFloat)space HBox:(void(^)(UIHBox* box))block;
- (id)addAspectWithX:(CGFloat)x andY:(CGFloat)y VBox:(void(^)(UIVBox* box))block;
- (id)addAspectWithX:(CGFloat)x andY:(CGFloat)y HBox:(void(^)(UIHBox* box))block;

// 应用当前布局到绑定的对象
- (void)apply;

@end

@interface UIBox : UILayout

+ (id)boxWithRect:(CGRect)rc withSpacing:(CGFloat)space;
+ (id)boxWithRect:(CGRect)rc;

@end

@interface UIVBox : UIBox

+ (id)boxWithRect:(CGRect)rc withSpacing:(CGFloat)space;

@end

@interface UIHBox : UIBox

+ (id)boxWithRect:(CGRect)rc withSpacing:(CGFloat)space;

@end

typedef enum {
    kUIFlowOptionNull = 0,
    kUIFlowOptionFix = 1,
} UIFlowOption;

@interface UIHFlow : UILayout

@property (nonatomic, readonly) NSUInteger row;

// 是否填充整行，默认为 NO
@property (nonatomic, assign) BOOL fillMode;

+ (id)flowWithRect:(CGRect)rc;
+ (id)flowWithRect:(CGRect)rc withSpacing:(CGFloat)spacing;

- (id)addSize:(CGSize)size toView:(UIView*)view;
- (id)addSize:(CGSize)size toView:(UIView*)view withOptions:(UIFlowOption)options;
- (id)addSize:(CGSize)size toView:(UIView*)view set:(void(^)(CGRect rc, UIView* view))block;
- (id)addSize:(CGSize)size toView:(UIView*)view withOptions:(UIFlowOption)options set:(void (^)(CGRect, UIView *))block;

@end

# endif
