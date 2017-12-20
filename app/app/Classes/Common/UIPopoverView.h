
# ifndef __UIPOPOVERVIEW_4B6E1F612B1A4B64BF1DE96FF8D37FC3_H_INCLUDED
# define __UIPOPOVERVIEW_4B6E1F612B1A4B64BF1DE96FF8D37FC3_H_INCLUDED

@interface UIPopoverView : UIViewExt

// 箭头的大小
@property (nonatomic, assign) CGFloat arrowHeight;
@property (nonatomic, assign) CGFloat arrowCurvature;
@property (nonatomic, assign) CGFloat arrowHorizontalPadding;

// 阴影
@property (nonatomic, retain) CGShadow *borderShadow;

// 圆角的大小
@property (nonatomic, assign) CGFloat cornerRadius;

// 显示到依赖的 view 旁
@property (nonatomic, assign) UIView *targetView;

// 内容的 view
@property (nonatomic, retain) UIView *contentView;

// 自动隐藏，默认为 YES
@property (nonatomic, assign) BOOL autoClose;

// 初始化
- (id)initWithContent:(UIView*)view;
+ (instancetype)popoverContent:(UIView*)view;

// 弹开显示
- (void)popoverForView:(UIView*)view;
- (void)showForView:(UIView*)view inView:(UIView*)inview;

// 隐藏
- (void)dismiss;

@end

# endif
