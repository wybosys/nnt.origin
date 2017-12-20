
# import "Common.h"
# import "UIFilesProjector.h"
# import "UIActionView.h"

/*
 用以弹出演示页面
 类逻辑为一个 paged 弹在 desktop 或推入
 放大的逻辑：
 1，获得界面上的 view 元素，获得大小并进行截图
 2，打开放大的界面，获得放大后的位置
 3，对截图做放大动画
 */

@interface UIFilesProjector ()
{
    UIDesktop* _desk;
}

@end

@implementation UIFilesProjector

- (void)onInit {
    [super onInit];
    self.hidesBottomBarWhenPushed = YES;
    
    self.option = kUIPagedOptionContinued;
    self.classForPage = [UIGestureImageView class];
}

- (void)onFin {
    ZERO_RELEASE(_files);
    ZERO_RELEASE(_thumbs);
    [super onFin];
}

- (void)onLoaded {
    [super onLoaded];
    
    if (_desk == nil) {
        // 不适用desk的模式
        self.view.backgroundColor = [UIColor blackColor];
        
        // 点击空白处要退回上一页
        [self.view.signals connect:kSignalClicked withSelector:@selector(close) ofTarget:self];
    }
}

- (NSInteger)numberOfPagesInPagedView:(UIPagedView *)view {
    return _files.count;
}

- (void)pagedView:(UIPagedView *)view page:(id)page atIndex:(NSInteger)idx {
    if ([page isKindOfClass:[UIGestureImageView class]] == NO)
        return;
    UIGestureImageView* pv = page;
    [pv.signals connect:kSignalClicked ofTarget:self.view];
    
    pv.thumb = [self.thumbs objectAtIndex:idx def:nil];
    pv.file = [self.files objectAtIndex:idx def:nil];
}

- (void)open {
    if (_desk) {
        LOG("已经显示");
        return;
    }
    
    // 刷新数据
    [self reloadData];
    
    // 创建用于显示的 desk
    _desk = [UIDesktop desktopWithContent:self];
    _desk.attributes.statusBarHidden = [NSNumber Yes];
    _desk.backgroundColor = [UIColor blackColor];
    [self.view.signals connect:kSignalClicked ofTarget:_desk.view];

    // 绑定用来生成打开动画的元素
    _desk.viewSource = self.viewSource;
    id curpage = self.selectedPage;
    if ([curpage isKindOfClass:[UIGestureImageView class]]) {
        UIGestureImageView* imgpage = curpage;
        _desk.viewDest = imgpage;
    }
    
    // 打开桌面，会有自动的过渡效果
    [_desk open];
}

- (void)close {
    if (_desk) {
        [_desk close];
        _desk = nil;
        return;
    }
    
    [self goBack];
}

@end
