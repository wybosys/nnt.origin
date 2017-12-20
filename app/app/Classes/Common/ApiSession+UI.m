
# import "Common.h"
# import "ApiSession+UI.h"

static void (^__gsfun_scroll_workingidentifier_instance)(UIScrollView*) = nil;

@implementation UIScrollView (netobj_working)

+ (void)SetIdentifierWorkingInstanceCallback:(void (^)(UIScrollView *))block {
    BLOCK_RETAIN(__gsfun_scroll_workingidentifier_instance, block);
}

@end

@implementation SNetObj (ui)

- (void)setScrollView:(UIScrollView *)scrollView {
    [self.attachment.strong setObject:scrollView forKey:@"::according::scrollview"];
    
    if (scrollView) {
        [self.signals connect:kSignalApiSucceed withSelector:@selector(__snetobj_workdone:) ofTarget:self].priority = kSSlotPriorityLow;
        [self.signals connect:kSignalApiFailed withSelector:@selector(__snetobj_workstop:) ofTarget:self].priority = kSSlotPriorityLow;
    }
    
    if (scrollView.workingIdentifier == nil && __gsfun_scroll_workingidentifier_instance)
        __gsfun_scroll_workingidentifier_instance(scrollView);
    scrollView.workingIdentifier.visible = YES;
}

- (UIScrollView*)scrollView {
    return [self.attachment.strong objectForKey:@"::according::scrollview"];
}

- (void)__snetobj_workdone:(SSlot*)s {
    UIScrollView* scroll = self.scrollView;
    scroll.workState = kNSWorkStateDone;
    
    if (scroll.workingIdentifier && scroll.workingIdentifier.visible)
        scroll.workingIdentifier.hidden = YES;
    
    scroll.identifierBottom.disabled = NO;

    // 判断api是否已经取得了最后一页
    id apiobj = s.data.object;    
    id obj = [apiobj valueForKeyPath:@"data.lastpage" def:nil];
    if (obj && [obj respondsToSelector:@selector(boolValue)] && [obj boolValue] == NO)
        return;

    scroll.identifierBottom.disabled = YES;
}

- (void)__snetobj_workstop:(SSlot*)s {
    UIScrollView* scroll = self.scrollView;
    scroll.workState = kNSWorkStateDone;
    scroll.workingIdentifier.hidden = YES;
}

@end

@implementation SNetObjs (ui)

- (void)setScrollView:(UIScrollView *)scrollView {
    [self.attachment.weak setObject:scrollView forKey:@"::according::scrollview"];
    
    if (scrollView.workingIdentifier == nil && __gsfun_scroll_workingidentifier_instance)
        __gsfun_scroll_workingidentifier_instance(scrollView);
    scrollView.workingIdentifier.visible = YES;
    
    if (scrollView) {
        [self.signals connect:kSignalApiSucceed withSelector:@selector(__snetobjs_workdone:) ofTarget:self].priority = kSSlotPriorityLow;
        [self.signals connect:kSignalApiFailed withSelector:@selector(__snetobjs_workstop:) ofTarget:self].priority = kSSlotPriorityLow;
    }
}

- (UIScrollView*)scrollView {
    return [self.attachment.weak objectForKey:@"::according::scrollview"];
}

- (void)__snetobjs_workdone:(SSlot*)s {
    UIScrollView* scroll = self.scrollView;
    scroll.workState = kNSWorkStateDone;
    
    scroll.identifierBottom.disabled = NO;
    
    if (scroll.workingIdentifier && scroll.workingIdentifier.visible)
        scroll.workingIdentifier.hidden = YES;

    for (id each in s.data.object) {
        id obj = [each valueForKeyPath:@"data.lastpage" def:nil];
        if (obj == nil)
            continue;
        if ([obj boolValue] == NO)
            return;
    }
    
    scroll.identifierBottom.disabled = YES;
}

- (void)__snetobjs_workstop:(SSlot*)s {
    UIScrollView* scroll = self.scrollView;
    scroll.workState = kNSWorkStateDone;
    scroll.workingIdentifier.hidden = YES;
}

@end
