
# ifndef __UISCROLLABLE_EXTENSION_BFC1061107F74F07B420323FB7C26A43_H_INCLUDED
# define __UISCROLLABLE_EXTENSION_BFC1061107F74F07B420323FB7C26A43_H_INCLUDED

@interface UIPullableView : UIScrollViewExt

SIGNALS;

@end

@class UIPagedView;

@protocol UIPagedViewDataSource <NSObject>

/** 页面的数目 */
- (NSInteger)numberOfPagesInPagedView:(UIPagedView*)view;

/** 初始化 page */
- (void)pagedView:(UIPagedView*)view page:(id)page atIndex:(NSInteger)idx;

@optional

/** 获得指定下标的 page 对象，可以为 view，也可以为 vc，只要实现了 view 方法就可以 */
- (id)pagedView:(UIPagedView*)view pageAtIndex:(NSInteger)idx;

/** 获得为了实现指定下标，而是用的类型 */
- (Class)pagedView:(UIPagedView*)view typeForPageAtIndex:(NSInteger)idx;

/** 即将显示页面 */
- (void)pagedView:(UIPagedView*)view willDisplayPage:(id)page atIndex:(NSInteger)idx;

/** 页面已经显示 */
- (void)pagedView:(UIPagedView*)view didDisplayPage:(id)page atIndex:(NSInteger)idx;

/** 即将隐藏页面 */
- (void)pagedView:(UIPagedView*)view willUndisplayPage:(id)page atIndex:(NSInteger)idx;

/** 页面已经隐藏 */
- (void)pagedView:(UIPagedView*)view didUndisplayPage:(id)page atIndex:(NSInteger)idx;

@end

@interface UIPagedView : UIScrollViewExt

/** 数据源 */
@property (nonatomic, assign) id<UIPagedViewDataSource> dataSource;

/** 当前选中的页面的下标 */
@property (nonatomic, assign) NSInteger selectedIndex;

/** 重新加载 */
- (void)reloadData;

@end

enum {
    kUIPagedOptionAutomatic = 0x10, // 自动
    kUIPagedOptionContinued = 0x20, // 循环
    kUIPagedOptionForward = 0x0, // 往前
    kUIPagedOptionBackward = 0x1, // 往后
    kUIPagedOptionAutomicContinued = kUIPagedOptionAutomatic | kUIPagedOptionContinued | kUIPagedOptionForward,
    kUIPagedOptionInfinite = kUIPagedOptionContinued | kUIPagedOptionForward, // 无限手动滚动
};
typedef NSUInteger UIPagedOption;

/** 承载一堆页面，并提供滑动切换的功能 */
@interface UIPagedViewController : UIViewControllerExt
<UIPagedViewDataSource>

/** 所有的 pages 页面 */
@property (nonatomic, retain) NSArray *pages;

/** 用来生成子页面用的类型，默认为 nil，如果设置了改类型，则会自动实例化页面 */
@property (nonatomic, assign) Class classForPage;

/** 当前选中的页面 */
@property (nonatomic, assign) NSInteger selectedIndex;

/** 页面可以为 View 也可以为 VC，内部会自动处理 */
@property (nonatomic, readonly) id selectedPage;

/** 配置类型，默认为0 */
@property (nonatomic, assign) UIPagedOption option;

/** 修改当前选中的页面，带信号通知 */
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;

/** 修改当前选中的页面，不会引起信号 */
- (void)changeSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;

/** 重新载入数据 */
- (void)reloadData;

/** 滚动到下一个(上一个)页面，如果到底(到首)，则自动调整以实现无限循环滚动的目的 */
- (void)scrollToNext;
- (void)scrollToPrevious;

/** 实现用的 view */
@property (nonatomic, readonly) UIPagedView* pagedView;

@end

/** 包裹了普通的 Scrollview 用来对应某些业务中不能使用 ScrollViewExt 的情况 */
@interface UIScrollViewWrapper : UIViewWrapper

@property (nonatomic, retain) UIScrollView *scrollView;

@end

# endif