
# ifndef __UIGESTUREVIEW_55EAE99A59EA4353842B4C72969A1020_H_INCLUDED
# define __UIGESTUREVIEW_55EAE99A59EA4353842B4C72969A1020_H_INCLUDED

/** 使用手势激活绑定的左边或者右边的元素 */
@interface UIGestureActivateView : UIViewExt

/** 通过滑动激活的左边、右边的view */
@property (nonatomic, retain) UIView *viewLeft, *viewRight;

/** 左右两个view对应的原始长度 */
@property (nonatomic, assign) CGFloat widthLeft, widthRight;

/** 是否响应手势，默认为YES */
@property (nonatomic, assign) BOOL gestureEnable;

/** 重置，会关掉打开的左右view */
- (void)reset;
- (void)reset:(BOOL)animated;

/** 手动打开左右的view */
- (void)openLeft;
- (void)openRight;
- (void)openLeft:(BOOL)animated;
- (void)openRight:(BOOL)animated;

@end

// 激活任一一个
SIGNAL_DECL(kSignalGestureActivatedAny) @"::ui::action::gestureactivateview::activated";

// 激活左边的
SIGNAL_DECL(kSignalGestureActivatedLeft) @"::ui::action::gestureactivateview::left";

// 激活右边的
SIGNAL_DECL(kSignalGestureActivatedRight) @"::ui::action::gestureactivateview::right";

/** 根据手势缩放、平移的图片view */
@interface UIGestureImageView : UIScrollViewExt

/** 显示图片的view */
@property (nonatomic, readonly) UIImageViewExt *imageView;

/** 将会被传递到datasource中，代表源文件、缩略图 */
@property (nonatomic, copy) id file, thumb;

@end

@interface UIView (actionView)

- (void)actionViewBleach:(CGFloat)ratio;
- (void)actionViewBleach;

@end

# endif
