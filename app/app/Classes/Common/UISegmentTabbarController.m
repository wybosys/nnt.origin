
# import "Common.h"
# import "UISegmentTabbarController.h"
# import "AppDelegate+Extension.h"

@interface UISegmentTabbar () {
    NSUInteger _count;
    CGFloat _tabsOnScreen;
    CGFloat _widthForItem;
}

@end

@implementation UISegmentTabbar

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    self.showsScrollIndicator = NO;
    
    _items = [[NSMutableArray alloc] init];
}


- (void)onFin {
    ZERO_RELEASE(_items);
    ZERO_RELEASE(_edgeShadow);
    
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalSelectionChanged)
SIGNALS_END

- (void)didMoveToSuperview {
    if (self.superview == nil)
        return;
    
    [super didMoveToSuperview];
    [self reloadData];
}

- (void)reloadData {
    [_items removeAllObjects:^(id each) {
        [each removeFromSuperview];
    }];
    
    _count = [self.dataSource numbersForSegmentTabbar:self];
    _tabsOnScreen = [self.dataSource numbersOnScreenForSegmentTabbar:self];
    
    // 创建按钮
    for (NSUInteger i = 0; i < _count; ++i) {
        // 实例化按钮
        UIView<UISelection>* item = [self.delegate itemForSegmentTabbar:self atIndex:i];
        [item.signals connect:kSignalClicked withSelector:@selector(actItemSelected:) ofTarget:self];
        [_items addObject:item];
        
        // 初始化按钮
        if ([self.delegate respondsToSelector:@selector(segmentTabbar:item:atIndex:)])
            [self.delegate segmentTabbar:self item:item atIndex:i];
        
        [self.viewContent addSubview:item];
    }
    
    [self setNeedsLayout];
}

- (void)actItemSelected:(SSlot*)s {
    UIView<UISelection>* item = (id)s.sender;
    [self setSelectedItem:item];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    UIView<UISelection>* item = [self.items objectAtIndex:selectedIndex def:nil];
    if (item == nil)
        WARN("Tab 越界");
    
    self.selectedItem = item;
}

- (void)setSelectedItem:(UIView<UISelection> *)item {
    _selectedItem = item;
    if (item.isSelection == YES)
        return;
    
    [_items foreachWithIndex:^BOOL(UIView<UISelection>* obj, NSInteger idx) {
        if (obj != item) {
            obj.isSelection = NO;
        } else {
            obj.isSelection = YES;
            _selectedIndex = idx;
        }
        return YES;
    }];
    
    // 如果 item 不在显示范围内，则调整到完全显示
    {
        CGRect rc = self.visibledBounds;
        CGFloat dx = 0;
        if (item.rightTop.x > CGRectGetMaxX(rc)) {
            dx = item.rightTop.x - CGRectGetMaxX(rc);
        } else if (item.leftTop.x < CGRectGetMinX(rc)) {
            dx = item.leftTop.x - CGRectGetMinX(rc);
        }
        CGFloat x = self.contentOffsetX;
        x += dx;
        [self setContentOffsetX:x animated:YES];
    }
    
    // 通知业务层
    if ([self.delegate respondsToSelector:@selector(segmentTabbar:selectedChanged:ofItem:)])
        [self.delegate segmentTabbar:self selectedChanged:_selectedIndex ofItem:item];
    [self.signals emit:kSignalSelectionChanged withResult:item];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    if (_count && _tabsOnScreen) {
        CGRect rc = self.rectForLayout;
        _widthForItem = CGFloatIntegral(rc.size.width / _tabsOnScreen);
        self.contentWidth = _widthForItem * _count;
    }
    
    UIHBox* box = [UIHBox boxWithRect:rect];
    for (UIView* each in _items) {
        if ([each conformsToProtocol:@protocol(UISelection)] == NO)
            continue;
        [box addPixel:_widthForItem toView:each];
    }
    [box apply];
    
    // 设置阴影
    if (self.edgeShadow) {
        CALayer* lyr = self.layer;
        CGRect rc = lyr.bounds;
        
        [self.edgeShadow setIn:lyr];
        CGRect shadowPath = CGRectMake(rc.origin.x - 10, rc.size.height - 6,
                                       rc.size.width + 20, 5);
        lyr.shadowPath = [UIBezierPath bezierPathWithRect:shadowPath].CGPath;
    }
}

@end

@interface UISegmentTabView () {
    BOOL _pagesPoped;
}

@property (nonatomic, retain) UIPageViewControllerExt* ctlrPages;

@end

@implementation UISegmentTabView

- (void)onInit {
    [super onInit];
    
    [self addSubcontroller:BLOCK_RETURN({
        _ctlrPages = [[UIPageViewControllerExt alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                    navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                  options:nil];
        [_ctlrPages.signals connect:kSignalSelectionChanged withSelector:@selector(__st_pages_changed:) ofTarget:self];
        return _ctlrPages;
    })];

    [self addSubview:BLOCK_RETURN({
        _tabbar = [UISegmentTabbar temporary];
        return _tabbar;
    })];
}

- (void)onFin {
    ZERO_RELEASE(_ctlrPages);
    ZERO_RELEASE(_selectedViewController);
    [super onFin];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox* box = [UIVBox boxWithRect:rect withSpacing:0];
    
    // 滚动条
    CGFloat tabHeight = self.tabbar.bounds.size.height;
    [box addPixel:tabHeight toView:self.tabbar];
    
    if (_pagesPoped == NO)
        [box addFlex:1 toView:_ctlrPages.view];
    
    [box apply];
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController {
    if (_selectedViewController == selectedViewController)
        return;
    PROPERTY_RETAIN(_selectedViewController, selectedViewController);
    _ctlrPages.currentViewController = selectedViewController;
}

- (void)__st_pages_changed:(SSlot*)s {
    self.tabbar.selectedIndex = _ctlrPages.currentPage;
}

- (void)reloadData {
    [self.tabbar reloadData];
}

- (UIPageViewControllerExt*)popPageController {
    if (_pagesPoped)
        return _ctlrPages;
    
    [self removeSubcontroller:_ctlrPages];
    
    _pagesPoped = YES;
    [self setNeedsLayout];
    return _ctlrPages;
}

@end

@implementation UISegmentTabButton

@synthesize isSelection;

- (void)onInit {
    [super onInit];

    self.backgroundColor = [UIColor grayColor];
}

@end

@implementation UISegmentTabbarController

@dynamic tabbar;

- (void)onInit {
    [super onInit];
    self.classForView = [UISegmentTabView class];
    self.tabsOnScreen = 1;
    self.tabHeight = 40;
    self.classForButton = [UISegmentTabButton class];
}

- (void)dealloc {
    ZERO_RELEASE(_viewControllers);
    [super dealloc];
}

- (BOOL)panToBack {
    return NO;
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalSelectionChanged)
SIGNALS_END

- (void)onLoaded {
    [super onLoaded];
    
    UISegmentTabView* view = (id)self.view;
    
    view.tabbar.dataSource = self;
    view.tabbar.delegate = self;
    view.ctlrPages.pageViewControllers = self.viewControllers;
    
    [view.tabbar setHeight:self.tabHeight];
}

- (UISegmentTabbar*)tabbar {
    UISegmentTabView* view = (id)self.view;
    return view.tabbar;
}

- (NSUInteger)numbersForSegmentTabbar:(UISegmentTabbar*)tabbar {
    return self.viewControllers.count;
}

- (CGFloat)numbersOnScreenForSegmentTabbar:(UISegmentTabbar*)tabbar {
    return self.tabsOnScreen;
}

- (UIView<UISelection>*)itemForSegmentTabbar:(UISegmentTabbar*)tabbar atIndex:(NSUInteger)index {
    UISegmentTabButton* ret = [[[self.classForButton alloc] initWithZero] autorelease];
    UIViewController* vc = [self.viewControllers objectAtIndex:index];
    if ([ret respondsToSelector:@selector(setText:)])
        [ret performSelector:@selector(setText:) withObject:vc.title];
    return ret;
}

- (void)segmentTabbar:(UISegmentTabbar *)tabbar item:(id)item atIndex:(NSUInteger)index {
    PASS;
}

- (void)segmentTabbar:(UISegmentTabbar *)tabbar selectedChanged:(NSUInteger)index ofItem:(id<UISelection>)item {
    UIViewController* vc = [self.viewControllers objectAtIndex:index];
    UISegmentTabView* view = (id)self.view;
    view.selectedViewController = vc;
    [self.navigationItem setWithNavigationItem:view.selectedViewController.navigationItem];
    [self.signals emit:kSignalSelectionChanged withResult:vc];
}

- (void)setViewControllers:(NSArray *)viewControllers {
    PROPERTY_RETAIN(_viewControllers, viewControllers);
    UISegmentTabView* view = (id)self.view;
    view.ctlrPages.pageViewControllers = viewControllers;
    [view reloadData];
}

- (void)setViewControllers:(NSArray *)viewControllers selectAtIndex:(NSInteger)idx {
    PROPERTY_RETAIN(_viewControllers, viewControllers);
    UISegmentTabView* view = (id)self.view;
    [view.ctlrPages changePageViewControllers:viewControllers];
    [view reloadData];
    self.tabbar.selectedIndex = idx;
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController {
    UISegmentTabView* view = (id)self.view;
    view.selectedViewController = selectedViewController;
    [self.navigationItem setWithNavigationItem:view.selectedViewController.navigationItem];
}

- (UIViewController*)selectedViewController {
    UISegmentTabView* view = (id)self.view;
    return view.selectedViewController;
}

@end
