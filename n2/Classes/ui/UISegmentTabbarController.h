
# ifndef __UISEGMENTTAB_CD86113713EC422BA1ED7E320AD03640_H_INCLUDED
# define __UISEGMENTTAB_CD86113713EC422BA1ED7E320AD03640_H_INCLUDED

@class UISegmentTabbar;

@protocol UISegmentTabbarDataSource <NSObject>

/** 标签的个数 */
- (NSUInteger)numbersForSegmentTabbar:(UISegmentTabbar*)tabbar;

/** 在屏幕上至多显示几个标签，超过的标签将使用手势滑入 */
- (CGFloat)numbersOnScreenForSegmentTabbar:(UISegmentTabbar*)tabbar;

@end

@protocol UISegmentTabbarDelegate <UIScrollViewDelegate>

/** 返回下标对应的view对象 */
- (UIView<UISelection>*)itemForSegmentTabbar:(UISegmentTabbar*)tabbar atIndex:(NSUInteger)index;

@optional

/** 初始化按钮的数据 */
- (void)segmentTabbar:(UISegmentTabbar*)tabbar item:(id)item atIndex:(NSUInteger)index;

/** 当选中时回调 */
- (void)segmentTabbar:(UISegmentTabbar*)tabbar selectedChanged:(NSUInteger)index ofItem:(id<UISelection>)item;

@end

/** 操作按钮区 */
@interface UISegmentTabbar : UIScrollViewExt

/** 数据源 */
@property (nonatomic, assign) id<UISegmentTabbarDataSource> dataSource;

/** 动作代理 */
@property (nonatomic, assign) id<UISegmentTabbarDelegate> delegate;

/** 所有的位于 toolbar 中的按钮 */
@property (nonatomic, readonly) NSMutableArray* items;

/** 当前选中的tab */
@property (nonatomic, assign) UIView<UISelection>* selectedItem;

/** 当前选中的序列号 */
@property (nonatomic, assign) NSUInteger selectedIndex;

/** 边缘的阴影 */
@property (nonatomic, retain) CGShadow *edgeShadow;

/** 重新加载数据 */
- (void)reloadData;

@end

@interface UISegmentTabView : UIViewExt 

/** 实现使用的tab对象 */
@property (nonatomic, readonly) UISegmentTabbar* tabbar;

/** 当前选中的 vc */
@property (nonatomic, retain, readonly) UIViewController* selectedViewController;

/** 从view中提取出pages，用来添加到其他界面之内 */
- (UIPageViewControllerExt*)popPageController;

@end

@interface UISegmentTabbarController : UIViewControllerExt
<UISegmentTabbarDataSource, UISegmentTabbarDelegate>

/** 实现tab对应的button的类型，默认为 UISegmentTabButton */
@property (nonatomic, assign) Class classForButton;

/** 实现使用的tab对象 */
@property (nonatomic, readonly) UISegmentTabbar* tabbar;

/** 对应于每一个tab的vc页面 */
@property (nonatomic, retain) NSArray* viewControllers;

/** tab对象的高度 */
@property (nonatomic, assign) CGFloat tabHeight;

/** 最大同时显示在屏幕上的元素个数 */
@property (nonatomic, assign) CGFloat tabsOnScreen;

/** 当前选中的tab对应的vc */
@property (nonatomic, retain, readonly) UIViewController* selectedViewController;

/** 选中页面 */
- (void)setViewControllers:(NSArray *)viewControllers selectAtIndex:(NSInteger)idx;

@end

/** 默认的用来实现 tab 对应的按钮的类 */
@interface UISegmentTabButton : UIButtonExt <UISelection>
@end

# endif
