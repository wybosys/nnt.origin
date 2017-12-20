
# import "Common.h"
# import "UIScrollableWidgets.h"
# import "NSCron.h"

@implementation UIPullableView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.bounces = YES;
    self.alwaysBounceVertical = YES;
    self.alwaysBounceHorizontal = NO;
    
    return self;
}

- (void)dealloc {
    [super dealloc];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalPullFlush)
SIGNAL_ADD(kSignalPullMore)
SIGNALS_END

@end

@interface UIPagedViewPage : NSObjectExt

@property (nonatomic, retain) id page;
@property (nonatomic, assign) NSInteger index;

@end

@implementation UIPagedViewPage

- (void)onFin {
    ZERO_RELEASE(_page);
    [super onFin];
}

- (BOOL)isEqual:(UIPagedViewPage*)r {
    return _index == r.index;
}

- (NSUInteger)hash {
    return _index;
}

@end

@interface UIPagedView ()

@property (nonatomic, assign) NSInteger cntPages;
@property (nonatomic, assign) UIPagedOption option;

// 正在显示的页面组
@property (nonatomic, readonly) NSMutableDictionary *visibledPages;

// 用于重用的页面
@property (nonatomic, readonly) NSMutableDictionary *reusedPages;

// 是否是循环模式
@property (nonatomic, readonly) BOOL isLoopMode;

// 是否可以调整位置
@property (nonatomic, readonly) BOOL canAdjustPosition;

@end

@implementation UIPagedView

SIGNALS_BEGIN
SIGNAL_ADD(kSignalSelectionChanged)
SIGNALS_END

- (void)onInit {
    [super onInit];
    
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.pagingEnabled = YES;
    
    _reusedPages = [[NSMutableDictionary alloc] init];
    _visibledPages = [[NSMutableDictionary alloc] init];
    
    [self.signals connect:kSignalDeceleratingEnd withSelector:@selector(cbDidDecelerated:) ofTarget:self];
}

- (void)onFin {
    ZERO_RELEASE(_reusedPages);
    ZERO_RELEASE(_visibledPages);
    [super onFin];
}

- (BOOL)canAdjustPosition {
    if (_cntPages == 0)
        return NO;
    return YES;
}

- (void)reloadData {
    _cntPages = [self.dataSource numberOfPagesInPagedView:self];
    if (_cntPages <= _selectedIndex)
        _selectedIndex = 0;
    
    if (self.canAdjustPosition == NO)
        return;
    
    // 设置整体的宽度
    // +2的原因详见 setselectedindex
    self.contentWidth = self.frame.size.width * (_cntPages + TRIEXPRESS(self.isLoopMode, 2, 0));
    
    // 刷新一下
    [self updateSelectedIndex];
    [self updateOffset:NO];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (self.canAdjustPosition == NO)
        return;
    
    // 设置整体的宽度
    // +2的原因详见 setselectedindex    if (_cntPages != 0)
    self.contentWidth = self.frame.size.width * (_cntPages + TRIEXPRESS(self.isLoopMode, 2, 0));
    
    // 调整一下偏移
    [self updateSelectedIndex];
    [self updateOffset:NO];
}

- (void)updateSelectedIndex {
    // 当选中改变时，采用如下策略
    /*
     1，生成当前选中所需要的 selectedIndex 以及+-1的3个页面的索引
     2，和当前已经位于显示堆栈中的索引进行 minus 操作
     3，将不需显示的页面移除显示队列，并加入可以重用的列表
     4，生成需要增加显示的页面，调整位置
     */
    NSMutableArray* tgtvis = [NSMutableArray temporary];
    {
        NSInteger fixidx = [self getFixedIndex:_selectedIndex];
        // 获取真正的左、当前、右的 idx
        [tgtvis addInteger:[self getFixedIndex:fixidx - 1]];
        [tgtvis addInteger:fixidx];
        [tgtvis addInteger:[self getFixedIndex:fixidx + 1]];
    }
    
    NSArray* notinsck = [_visibledPages.allKeys arrayByRemoveObjects:tgtvis];
    NSArray* insck = [_visibledPages.allKeys arrayByRemoveObjects:notinsck];
    
    // 移除不显示的
    for (id each in notinsck) {
        NSInteger idx = [each integerValue];
        if (idx == -1)
            continue;
        id page = [_visibledPages popObjectForKey:each];
        
        if ([self.dataSource respondsToSelector:@selector(pagedView:willUndisplayPage:atIndex:)])
            [self.dataSource pagedView:self willUndisplayPage:page atIndex:idx];
        
        // 加入重用队列，并移除显示
        [_reusedPages pushQueObject:page forKey:NSStringFromClass([page class])];
        [self removeSub:page];
        
        if ([self.dataSource respondsToSelector:@selector(pagedView:didUndisplayPage:atIndex:)])
            [self.dataSource pagedView:self didUndisplayPage:page atIndex:idx];
    }
    
    // 生成需要显示的
    // 添加需要实例化的页面
    NSArray* needinsck = [tgtvis arrayByRemoveObjects:insck];
    for (id each in needinsck) {
        NSInteger idx = [each integerValue];
        if (idx == -1)
            continue;
        
        // 生成对应的页面
        id page = nil;
        if ([self.dataSource respondsToSelector:@selector(pagedView:pageAtIndex:)])
            page = [self.dataSource pagedView:self pageAtIndex:idx];
        if (page == nil)
            page = [self pageAtIndex:idx];

        if ([self.dataSource respondsToSelector:@selector(pagedView:willDisplayPage:atIndex:)])
            [self.dataSource pagedView:self willDisplayPage:page atIndex:idx];
        
        [_visibledPages setObject:page forKey:each];
        [self addSub:page];
    }
    
    if ([self.dataSource respondsToSelector:@selector(pagedView:didDisplayPage:atIndex:)]) {
        id page = [_visibledPages objectForKey:@(_selectedIndex)];
        [self.dataSource pagedView:self didDisplayPage:page atIndex:_selectedIndex];
    }
    
    // 调整显示位置
    /*
     如果支持循环，排列的方式为
     -1 0 1 2 3 4 -1，即左右两边各预留一个位置
     */
    NSInteger curidx = _selectedIndex + TRIEXPRESS(self.isLoopMode, 1, 0);
    CGFloat curoffx = self.bounds.size.width * curidx;
    
    // 将当前的 page 移动到对应位置
    CGRect currc = CGRectMakeWithPointAndSize(CGPointMake(curoffx, 0), self.bounds.size);
    id pageleft = [_visibledPages objectForKey:tgtvis.firstObject def:nil];
    id pagecur = [_visibledPages objectForKey:tgtvis.secondObject def:nil];
    id pageright = [_visibledPages objectForKey:tgtvis.thirdObject def:nil];
    [pagecur behalfView].frame = currc;
    [pageleft behalfView].frame = CGRectOffset(currc, -currc.size.width, 0);
    [pageright behalfView].frame = CGRectOffset(currc, currc.size.width, 0);
}

- (void)updateOffset:(BOOL)animated {
    if (self.canAdjustPosition == NO)
        return;
    NSInteger curidx = _selectedIndex + TRIEXPRESS(self.isLoopMode, 1, 0);
    CGFloat curoffx = self.bounds.size.width * curidx;
    [self setContentOffset:CGPointMake(curoffx, 0) animated:animated];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated {
    // 当前选中的页面
    _selectedIndex = selectedIndex;
    
    if (self.canAdjustPosition == NO)
        return;
    
    // 刷新页面
    [self updateSelectedIndex];
    [self updateOffset:animated];
    
    // 设置一下真正的偏移
    _selectedIndex = [self getFixedIndex:selectedIndex];
    
    // 丢出去消息
    if (animated)
    {
        DISPATCH_DELAY_BEGIN(0.5)
        
        if (self.isLoopMode) {
            if (_selectedIndex == 0) {
                CGFloat offx = self.behalfView.bounds.size.width;
                [self setContentOffset:CGPointMake(offx, 0) animated:NO];
            } else if (_selectedIndex == _cntPages - 1) {
                CGFloat offx = self.behalfView.bounds.size.width * _cntPages;
                [self setContentOffset:CGPointMake(offx, 0) animated:NO];
            }
        }
        
        [self updateSelectedIndex];
        
        [self.signals emit:kSignalSelectionChanged withResult:@(_selectedIndex)];
        DISPATCH_DELAY_END
    }
    else
    {
        [self updateSelectedIndex];
        [self updateOffset:NO];

        [self.signals emit:kSignalSelectionChanged withResult:@(_selectedIndex)];
    }
}

- (void)changeSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated {
    [[self.signals settingForSignal:kSignalSelectionChanged] block];
    [self setSelectedIndex:selectedIndex animated:animated];
    [[self.signals settingForSignal:kSignalSelectionChanged] unblock];
}

- (void)scrollToNext {
    NSInteger idx = _selectedIndex + 1;
    if (self.isLoopMode == NO) {
        if (idx >= _cntPages)
            idx = 0;
    }
    [self setSelectedIndex:idx animated:YES];
}

- (void)scrollToPrev {
    NSInteger idx = _selectedIndex - 1;
    if (self.isLoopMode == NO) {
        if (idx < 0)
            idx = _cntPages - 1;
    }
    [self setSelectedIndex:idx animated:YES];
}

- (void)cbDidDecelerated:(SSlot *)s {
    CGFloat offx = self.contentOffset.x;
    
    NSInteger idx = offx / self.behalfView.bounds.size.width;
    if (self.isLoopMode)
        idx -= 1;
    idx = [self getFixedIndex:idx];
    
    if (idx != _selectedIndex)
    {
        _selectedIndex = idx;
    }
    else
    {
        // 没有改变
        return;
    }
    
    [self updateSelectedIndex];
    [self.signals emit:kSignalSelectionChanged withResult:@(_selectedIndex)];
    
    // 调整一下偏移
    if (self.isLoopMode) {
        if (_selectedIndex == 0) {
            CGFloat offx = self.behalfView.bounds.size.width;
            [self setContentOffset:CGPointMake(offx, 0) animated:NO];
        } else if (_selectedIndex == _cntPages - 1) {
            CGFloat offx = self.behalfView.bounds.size.width * _cntPages;
            [self setContentOffset:CGPointMake(offx, 0) animated:NO];
        }
    }
}

- (NSInteger)getFixedIndex:(NSInteger)index {
    if (_cntPages == 0)
        return -1;
    
    if (index < 0) {
        if (self.isLoopMode)
            return _cntPages - 1;
        return -1;
    }
    else if (index >= _cntPages) {
        if (self.isLoopMode)
            return 0;
        return -1;
    }

    return index;
}

- (BOOL)isLoopMode {
    if (_cntPages < 3)
        return NO;
    return [NSMask Mask:kUIPagedOptionContinued Value:_option];
}

- (id)pageAtIndex:(NSInteger)idx {
    // 使用类型和重用获取页面对象
    Class cls = [self.dataSource pagedView:self typeForPageAtIndex:idx];
    if (cls == nil)
        return nil;
    
    // 生成重用名
    NSString* reuseidr = NSStringFromClass(cls);
    
    // 看看有没有可以用的重用
    id obj = [_reusedPages popQueObjectForKey:reuseidr];
    if (obj == nil) {
        obj = [cls temporary];
    }
    
    // 初始化
    [self.dataSource pagedView:self page:obj atIndex:idx];
    
    // 刷新数据
    if ([obj isKindOfClass:[UIViewController class]]) {
        [obj updateData];
    }
    [[obj behalfView] updateData];
    
    return obj;
}

@end

@interface UIPagedViewController ()

// 用来自动滚动的计时器
@property (nonatomic, readonly) NSTimerExt *timer;

@end

@implementation UIPagedViewController

- (void)onInit {
    [super onInit];
    self.classForView = [UIPagedView class];
    
    // 计时器
    _timer = [[NSTimerExt scheduledTimerWithTimeInterval:3 repeats:YES start:NO] retain];
    [_timer.signals connect:kSignalTakeAction withSelector:@selector(autoScroll) ofTarget:self];
}

- (void)onFin {
    [self.touchSignals disconnect];
    
    ZERO_RELEASE(_timer);
    ZERO_RELEASE(_pages);
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalSelectionChanged)
SIGNALS_END

- (void)onLoaded {
    [super onLoaded];
    
    UIPagedView* view = self.pagedView;
    view.dataSource = self;
    
    [view.signals connect:kSignalSelectionChanged redirectTo:kSignalSelectionChanged ofTarget:self];
    [view.signals connect:kSignalDraggingBegin withSelector:@selector(stopAutoScroll) ofTarget:self];
    [view.signals connect:kSignalDraggingEnd withSelector:@selector(startAutoScroll) ofTarget:self];
}

- (void)cbSelectionChanged {
    [self.signals emit:kSignalSelectionChanged withResult:@(self.selectedIndex)];
}

- (void)onFirstAppeared {
    [super onFirstAppeared];
    [self reloadData];
}

- (void)onAppeared {
    [super onAppeared];
    [_timer setFireDate:[NSDate distantPast]];
}

- (void)onDisappeared {
    [_timer setFireDate:[NSDate distantFuture]];
    [super onDisappeared];
}

- (void)reloadData {
    [self.pagedView reloadData];
}

- (void)scrollToNext {
    NSInteger cntPages = self.pagedView.cntPages;
    if (kUIDragging || cntPages == 0)
        return;
    
    [self.pagedView scrollToNext];
}

- (void)scrollToPrevious {
    NSInteger cntPages = self.pagedView.cntPages;
    if (kUIDragging || cntPages == 0)
        return;
    
    [self.pagedView scrollToPrev];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated {
    [self.pagedView setSelectedIndex:selectedIndex animated:animated];
}

- (void)changeSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated {
    [self.pagedView changeSelectedIndex:selectedIndex animated:animated];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (NSInteger)selectedIndex {
    return self.pagedView.selectedIndex;
}

- (id)selectedPage {
    return [self.pagedView.visibledPages objectForKey:@(self.pagedView.selectedIndex) def:nil];
}

- (UIPagedView *)pagedView {
    return (UIPagedView *)self.view;
}

- (void)setOption:(UIPagedOption)option {
    _option = option;
    [self pagedView].option = option;
    if ([NSMask Mask:kUIPagedOptionAutomatic Value:_option]) {
        [self startAutoScroll];
    }
    else {
        [self stopAutoScroll];
    }
}

- (void)autoScroll {
    if ([NSMask Mask:kUIPagedOptionAutomatic Value:_option]) {
        if ([NSMask Mask:kUIPagedOptionBackward Value:_option]) {
            [self scrollToPrevious];
        }
        else {
            [self scrollToNext];
        }
    }
}

- (void)startAutoScroll {
    if ([NSMask Mask:kUIPagedOptionAutomatic Value:_option]) {
        [self.timer start];
    }
}

- (void)stopAutoScroll {
    if ([NSMask Mask:kUIPagedOptionAutomatic Value:_option]) {
        [self.timer stop];
    }
}

- (NSInteger)numberOfPagesInPagedView:(UIPagedView *)view {
    if (_pages)
        return _pages.count;
    return 0;
}

- (id)pagedView:(UIPagedView *)view pageAtIndex:(NSInteger)idx {
    if (_pages)
        return [_pages objectAtIndex:idx def:nil];
    
    return [view pageAtIndex:idx];
}

- (void)pagedView:(UIPagedView*)view willDisplayPage:(id)page atIndex:(NSInteger)idx {
    PASS;
}

- (void)pagedView:(UIPagedView*)view didDisplayPage:(id)page atIndex:(NSInteger)idx {
    PASS;
}

- (void)pagedView:(UIPagedView*)view willUndisplayPage:(id)page atIndex:(NSInteger)idx {
    PASS;
}

- (void)pagedView:(UIPagedView*)view didUndisplayPage:(id)page atIndex:(NSInteger)idx {
    PASS;
}

- (Class)pagedView:(UIPagedView*)view typeForPageAtIndex:(NSInteger)idx {
    return self.classForPage;
}

- (void)pagedView:(UIPagedView*)view page:(id)page atIndex:(NSInteger)idx {
    PASS;
}

@end

@interface UIScrollView ()

- (void)SWIZZLE_CALLBACK(didscroll);
- (void)SWIZZLE_CALLBACK(begindragging);
- (void)SWIZZLE_CALLBACK(enddragging:)(id)decelerate;
- (void)SWIZZLE_CALLBACK(begindeceleration);
- (void)SWIZZLE_CALLBACK(stopdeceleration);

@end

@interface UIScrollViewWrapper ()
<UIScrollViewDelegate>
@end

@implementation UIScrollViewWrapper

- (void)onInit {
    [super onInit];
    self.contentView = BLOCK_RETURN({
        UIScrollView *v = [UIScrollView temporary];
        v.delegate = self;
        return v;
    });
}

@dynamic scrollView;

- (void)setScrollView:(UIScrollView *)scrollView {
    self.contentView = scrollView;
}

- (UIScrollView*)scrollView {
    return (id)self.contentView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [scrollView performSelector:@selector(SWIZZLE_CALLBACK(didscroll))];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [scrollView performSelector:@selector(SWIZZLE_CALLBACK(begindragging))];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [scrollView performSelector:@selector(SWIZZLE_CALLBACK(enddragging:)) withObject:@(decelerate)];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [scrollView performSelector:@selector(SWIZZLE_CALLBACK(begindeceleration))];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [scrollView performSelector:@selector(SWIZZLE_CALLBACK(stopdeceleration))];
}

@end
