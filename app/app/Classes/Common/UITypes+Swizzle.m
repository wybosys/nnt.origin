
# import "Common.h"
# import "UITypes+Swizzle.h"
# import "Objc+Extension.h"
# import "AppDelegate+Extension.h"

@protocol UIResponseSwizzle <NSObject>

- (void)SWIZZLE_CALLBACK(touches_begin):(NSSet*)touches withEvent:(UIEvent*)event;
- (void)SWIZZLE_CALLBACK(touches_end):(NSSet*)touches withEvent:(UIEvent*)event;
- (void)SWIZZLE_CALLBACK(touches_cancel):(NSSet*)touches withEvent:(UIEvent*)event;
- (void)SWIZZLE_CALLBACK(touches_moved):(NSSet*)touches withEvent:(UIEvent*)event;

- (void)SWIZZLE_CALLBACK(motion_begin):(UIEventSubtype)st withEvent:(UIEvent*)event;
- (void)SWIZZLE_CALLBACK(motion_end):(UIEventSubtype)st withEvent:(UIEvent*)event;
- (void)SWIZZLE_CALLBACK(motion_cancel):(UIEventSubtype)st withEvent:(UIEvent*)event;

- (void)SWIZZLE_CALLBACK(focuse_got);
- (void)SWIZZLE_CALLBACK(focuse_lost);

@end

extern BOOL kUITouched;

@implementation UIResponder (swizzle)

static objc_swizzle_t __gs_uirespn_touchbegin, __gs_uirespn_touchend, __gs_uirespn_touchcancel, __gs_uirespn_touchmoved;

- (void)__swizzle_touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    kUITouched = YES;
    
    objc_swizzle_t os = __gs_uirespn_touchbegin;
    ((void(*)(id, SEL, NSSet*, UIEvent*))os.pimpl)(self, os.psel, touches, event);
    
    [(id<UIResponseSwizzle>)self SWIZZLE_CALLBACK(touches_begin):touches withEvent:event];
}

- (void)__swizzle_touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    kUITouched = NO;
    
    objc_swizzle_t os = __gs_uirespn_touchcancel;
    ((void(*)(id, SEL, NSSet*, UIEvent*))os.pimpl)(self, os.psel, touches, event);
    
    [(id<UIResponseSwizzle>)self SWIZZLE_CALLBACK(touches_cancel):touches withEvent:event];
}

- (void)__swizzle_touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    objc_swizzle_t os = __gs_uirespn_touchmoved;
    ((void(*)(id, SEL, NSSet*, UIEvent*))os.pimpl)(self, os.psel, touches, event);
    
    [(id<UIResponseSwizzle>)self SWIZZLE_CALLBACK(touches_moved):touches withEvent:event];
}

- (void)__swizzle_touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    kUITouched = NO;
    
    objc_swizzle_t os = __gs_uirespn_touchend;
    ((void(*)(id, SEL, NSSet*, UIEvent*))os.pimpl)(self, os.psel, touches, event);
    
    [(id<UIResponseSwizzle>)self SWIZZLE_CALLBACK(touches_end):touches withEvent:event];
}

static objc_swizzle_t __gs_uirespn_motionBegan, __gs_uirespn_motionEnded, __gs_uirespn_motionCancelled;

- (void)__swizzle_motionBegan:(UIEventSubtype)st withEvent:(UIEvent*)event {
    objc_swizzle_t os = __gs_uirespn_motionBegan;
    ((void(*)(id, SEL, UIEventSubtype, UIEvent*))os.pimpl)(self, os.psel, st, event);
    
    [(id<UIResponseSwizzle>)self SWIZZLE_CALLBACK(motion_begin):st withEvent:event];
}

- (void)__swizzle_motionEnded:(UIEventSubtype)st withEvent:(UIEvent*)event {
    objc_swizzle_t os = __gs_uirespn_motionEnded;
    ((void(*)(id, SEL, UIEventSubtype, UIEvent*))os.pimpl)(self, os.psel, st, event);
    
    [(id<UIResponseSwizzle>)self SWIZZLE_CALLBACK(motion_end):st withEvent:event];
}

- (void)__swizzle_motionCancelled:(UIEventSubtype)st withEvent:(UIEvent*)event {
    objc_swizzle_t os = __gs_uirespn_motionCancelled;
    ((void(*)(id, SEL, UIEventSubtype, UIEvent*))os.pimpl)(self, os.psel, st, event);
    
    [(id<UIResponseSwizzle>)self SWIZZLE_CALLBACK(motion_cancel):st withEvent:event];
}

NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR(UIResponder, isResponding, setIsResponding, BOOL, @(val), [val boolValue], RETAIN_NONATOMIC);

static objc_swizzle_t __gs_uirespn_focusegot, __gs_uirespn_focuselost;

- (BOOL)__swizzle_focuseGot {
    if ([self canBecomeFirstResponder]) {
        [(id<UIResponseSwizzle>)self SWIZZLE_CALLBACK(focuse_got)];
    }
    
    objc_swizzle_t os = __gs_uirespn_focusegot;
    BOOL ret = ((BOOL(*)(id, SEL))os.pimpl)(self, os.psel);
    if (ret)
        self.isResponding = YES;
    return ret;
}

- (BOOL)__swizzle_focuseLost {
    if ([self canResignFirstResponder]) {
        [(id<UIResponseSwizzle>)self SWIZZLE_CALLBACK(focuse_lost)];
    }

    objc_swizzle_t os = __gs_uirespn_focuselost;
    BOOL ret = ((BOOL(*)(id, SEL))os.pimpl)(self, os.psel);
    if (ret)
        self.isResponding = NO;
    return ret;
}

+ (void)Swizzles {
    Class cls = [UIResponder class];
    
    [cls SwizzleMethod:@selector(touchesBegan:withEvent:) with:@selector(__swizzle_touchesBegan:withEvent:) with:&__gs_uirespn_touchbegin];
    [cls SwizzleMethod:@selector(touchesEnded:withEvent:) with:@selector(__swizzle_touchesEnded:withEvent:) with:&__gs_uirespn_touchend];
    [cls SwizzleMethod:@selector(touchesCancelled:withEvent:) with:@selector(__swizzle_touchesCancelled:withEvent:) with:&__gs_uirespn_touchcancel];
    [cls SwizzleMethod:@selector(touchesMoved:withEvent:) with:@selector(__swizzle_touchesMoved:withEvent:) with:&__gs_uirespn_touchmoved];
    
    [cls SwizzleMethod:@selector(motionBegan:withEvent:) with:@selector(__swizzle_motionBegan:withEvent:) with:&__gs_uirespn_motionBegan];
    [cls SwizzleMethod:@selector(motionEnded:withEvent:) with:@selector(__swizzle_motionEnded:withEvent:) with:&__gs_uirespn_motionEnded];
    [cls SwizzleMethod:@selector(motionCancelled:withEvent:) with:@selector(__swizzle_motionCancelled:withEvent:) with:&__gs_uirespn_motionCancelled];
    
    [cls SwizzleMethod:@selector(becomeFirstResponder) with:@selector(__swizzle_focuseGot) with:&__gs_uirespn_focusegot];
    [cls SwizzleMethod:@selector(resignFirstResponder) with:@selector(__swizzle_focuseLost) with:&__gs_uirespn_focuselost];
}

@end

@protocol UIViewSwizzle <NSObject>

- (void)SWIZZLE_CALLBACK(layout_subviews);

- (void)SWIZZLE_CALLBACK(draw_rect):(CGRect)rc;
- (void)SWIZZLE_CALLBACK(set_frame):(CGRect)rc;
- (void)SWIZZLE_CALLBACK(set_center):(CGPoint)pt;
- (void)SWIZZLE_CALLBACK(layer_drawing):(CALayer*)layer inContext:(CGContextRef)ctx;
- (void)SWIZZLE_CALLBACK(layer_drawed):(CALayer*)layer inContext:(CGContextRef)ctx;

- (void)SWIZZLE_CALLBACK(set_hide):(BOOL)obj;
- (void)SWIZZLE_CALLBACK(set_userinteraction):(BOOL)obj;
- (void)SWIZZLE_CALLBACK(moving_to_window):(UIWindow*)window;
- (void)SWIZZLE_CALLBACK(moving_to_superview):(UIView*)superview;
- (void)SWIZZLE_CALLBACK(moved_to_window);
- (void)SWIZZLE_CALLBACK(moved_to_superview);

- (void)SWIZZLE_CALLBACK(add_view):(UIView*)view;

@end

@implementation UIView (swizzle)

static objc_swizzle_t __gs_uiview_layoutsubviews;

- (void)__swizzle_layoutsubviews {
    objc_swizzle_t os = __gs_uiview_layoutsubviews;
    ((void(*)(id, SEL))os.pimpl)(self, os.psel);
    
    [(id<UIViewSwizzle>)self SWIZZLE_CALLBACK(layout_subviews)];
}

static objc_swizzle_t __gs_uiview_drawlayer, __gs_uiview_drawrect;

- (void)__swizzle_drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    [(id<UIViewSwizzle>)self SWIZZLE_CALLBACK(layer_drawing):layer inContext:ctx];
    
    objc_swizzle_t os = __gs_uiview_drawlayer;
    ((void(*)(id, SEL, CALayer*, CGContextRef))os.pimpl)(self, os.psel, layer, ctx);
    
    [(id<UIViewSwizzle>)self SWIZZLE_CALLBACK(layer_drawed):layer inContext:ctx];
}

- (void)__swizzle_drawrect:(CGRect)rc {
    objc_swizzle_t os = __gs_uiview_drawrect;
    ((void(*)(id, SEL, CGRect))os.pimpl)(self, os.psel, rc);
    
    [(id<UIViewSwizzle>)self SWIZZLE_CALLBACK(draw_rect):rc];
}

static objc_swizzle_t __gs_uiview_setframe, __gs_uiview_setcenter;

- (void)__swizzle_setframe:(CGRect)rc {
    objc_swizzle_t os = __gs_uiview_setframe;
    ((void(*)(id, SEL, CGRect))os.pimpl)(self, os.psel, rc);
    
    [(id<UIViewSwizzle>)self SWIZZLE_CALLBACK(set_frame):rc];
}

- (void)__swizzle_setcenter:(CGPoint)pt {
    objc_swizzle_t os = __gs_uiview_setcenter;
    ((void(*)(id, SEL, CGPoint))os.pimpl)(self, os.psel, pt);
    
    [(id<UIViewSwizzle>)self SWIZZLE_CALLBACK(set_center):pt];
}

static objc_swizzle_t __gs_uiview_visible;

- (void)__swizzle_sethide:(BOOL)obj {
    if (self.hidden == obj)
        return;
    
    objc_swizzle_t os = __gs_uiview_visible;
    ((void(*)(id, SEL, BOOL))os.pimpl)(self, os.psel, obj);
    
    [(id<UIViewSwizzle>)self SWIZZLE_CALLBACK(set_hide):obj];
}

static objc_swizzle_t __gs_uiview_userinteraction;

- (void)__swizzle_setuserinteraction:(BOOL)obj {
    if (self.userInteractionEnabled == obj)
        return;
    
    objc_swizzle_t os = __gs_uiview_userinteraction;
    ((void(*)(id, SEL, BOOL))os.pimpl)(self, os.psel, obj);
    
    [(id<UIViewSwizzle>)self SWIZZLE_CALLBACK(set_userinteraction):obj];
}

static objc_swizzle_t __gs_uiview_movingtowindow, __gs_uiview_movingtosuperview, __gs_uiview_movedtowindow, __gs_uiview_movedtosuperview;

- (void)__swizzle_movingtowindow:(UIWindow*)window {
    objc_swizzle_t os = __gs_uiview_movingtowindow;
    ((void(*)(id, SEL, UIWindow*))os.pimpl)(self, os.psel, window);
    
    [(id<UIViewSwizzle>)self SWIZZLE_CALLBACK(moving_to_window):window];
}

- (void)__swizzle_movingtosuperview:(UIView*)superview {
    objc_swizzle_t os = __gs_uiview_movingtosuperview;
    ((void(*)(id, SEL, UIView*))os.pimpl)(self, os.psel, superview);
    
    [(id<UIViewSwizzle>)self SWIZZLE_CALLBACK(moving_to_superview):superview];
}

- (void)__swizzle_movedtowindow {
    objc_swizzle_t os = __gs_uiview_movedtowindow;
    ((void(*)(id, SEL))os.pimpl)(self, os.psel);
    
    [(id<UIViewSwizzle>)self SWIZZLE_CALLBACK(moved_to_window)];
}

- (void)__swizzle_movedtosuperview {
    objc_swizzle_t os = __gs_uiview_movedtosuperview;
    ((void(*)(id, SEL))os.pimpl)(self, os.psel);
    
    [(id<UIViewSwizzle>)self SWIZZLE_CALLBACK(moved_to_superview)];
}

static objc_swizzle_t __gs_uiview_addview;

- (void)__swizzle_addview:(UIView*)view {
    // 当 [_UINavigationParallaxTransition animateTransition:] 被某些情况调用时，会导致 add self as subview 的异常
    if (view == self)
        return;
    
    objc_swizzle_t os = __gs_uiview_addview;
    ((void(*)(id, SEL, UIView*))os.pimpl)(self, os.psel, view);
    
    [(id<UIViewSwizzle>)self SWIZZLE_CALLBACK(add_view):view];
}

+ (void)Swizzles {
    Class cls = [UIView class];
    [cls SwizzleMethod:@selector(layoutSubviews) with:@selector(__swizzle_layoutsubviews) with:&__gs_uiview_layoutsubviews];
    [cls SwizzleMethod:@selector(drawLayer:inContext:) with:@selector(__swizzle_drawLayer:inContext:) with:&__gs_uiview_drawlayer];
    [cls SwizzleMethod:@selector(drawRect:) with:@selector(__swizzle_drawrect:) with:&__gs_uiview_drawrect];
    [cls SwizzleMethod:@selector(setFrame:) with:@selector(__swizzle_setframe:) with:&__gs_uiview_setframe];
    [cls SwizzleMethod:@selector(setCenter:) with:@selector(__swizzle_setcenter:) with:&__gs_uiview_setcenter];
    [cls SwizzleMethod:@selector(setHidden:) with:@selector(__swizzle_sethide:) with:&__gs_uiview_visible];
    [cls SwizzleMethod:@selector(setUserInteractionEnabled:) with:@selector(__swizzle_setuserinteraction:) with:&__gs_uiview_userinteraction];
    [cls SwizzleMethod:@selector(willMoveToWindow:) with:@selector(__swizzle_movingtowindow:) with:&__gs_uiview_movingtowindow];
    [cls SwizzleMethod:@selector(willMoveToSuperview:) with:@selector(__swizzle_movingtosuperview:) with:&__gs_uiview_movingtosuperview];
    [cls SwizzleMethod:@selector(didMoveToWindow) with:@selector(__swizzle_movedtowindow) with:&__gs_uiview_movedtowindow];
    [cls SwizzleMethod:@selector(didMoveToSuperview) with:@selector(__swizzle_movedtosuperview) with:&__gs_uiview_movedtosuperview];
    [cls SwizzleMethod:@selector(addSubview:) with:@selector(__swizzle_addview:) with:&__gs_uiview_addview];
}

@end

@implementation UIControl (swizzle)

+ (void)Swizzles {
    PASS;
}

@end

@protocol UIScrollViewSwizzle <NSObject>

@end

@implementation UIScrollView (swizzle)

static objc_swizzle_t __gs_scroll_touchbegin, __gs_scroll_touchend, __gs_scroll_touchcancel, __gs_scroll_touchmoved;

- (void)__swizzle_touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    kUITouched = YES;
    
    objc_swizzle_t os = __gs_scroll_touchbegin;
    ((void(*)(id, SEL, NSSet*, UIEvent*))os.pimpl)(self, os.psel, touches, event);
    
    [(id<UIResponseSwizzle>)self SWIZZLE_CALLBACK(touches_begin):touches withEvent:event];
}

- (void)__swizzle_touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    kUITouched = NO;
    
    objc_swizzle_t os = __gs_scroll_touchcancel;
    ((void(*)(id, SEL, NSSet*, UIEvent*))os.pimpl)(self, os.psel, touches, event);
    
    [(id<UIResponseSwizzle>)self SWIZZLE_CALLBACK(touches_cancel):touches withEvent:event];
}

- (void)__swizzle_touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    objc_swizzle_t os = __gs_scroll_touchmoved;
    ((void(*)(id, SEL, NSSet*, UIEvent*))os.pimpl)(self, os.psel, touches, event);
    
    [(id<UIResponseSwizzle>)self SWIZZLE_CALLBACK(touches_moved):touches withEvent:event];
}

- (void)__swizzle_touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    kUITouched = NO;
    
    objc_swizzle_t os = __gs_scroll_touchend;
    ((void(*)(id, SEL, NSSet*, UIEvent*))os.pimpl)(self, os.psel, touches, event);
    
    [(id<UIResponseSwizzle>)self SWIZZLE_CALLBACK(touches_end):touches withEvent:event];
}

+ (void)Swizzles {
    Class cls = [UIScrollView class];
    
    // 造成了scrollview透过点击时无法点击的问题
    [cls SwizzleMethod:@selector(touchesBegan:withEvent:) with:@selector(__swizzle_touchesBegan:withEvent:) with:&__gs_scroll_touchbegin];
    [cls SwizzleMethod:@selector(touchesEnded:withEvent:) with:@selector(__swizzle_touchesEnded:withEvent:) with:&__gs_scroll_touchend];
    [cls SwizzleMethod:@selector(touchesCancelled:withEvent:) with:@selector(__swizzle_touchesCancelled:withEvent:) with:&__gs_scroll_touchcancel];
    [cls SwizzleMethod:@selector(touchesMoved:withEvent:) with:@selector(__swizzle_touchesMoved:withEvent:) with:&__gs_scroll_touchmoved];
}

@end

@protocol UIViewControllerSwizzle <NSObject>

- (void)SWIZZLE_CALLBACK(view_loaded);
- (void)SWIZZLE_CALLBACK(appearing):(BOOL)animated;
- (void)SWIZZLE_CALLBACK(appeared):(BOOL)animated;
- (void)SWIZZLE_CALLBACK(disappearing):(BOOL)animated;
- (void)SWIZZLE_CALLBACK(disappeared):(BOOL)animated;
- (void)SWIZZLE_CALLBACK(navi_item):(UINavigationItem*)item;
- (void)SWIZZLE_CALLBACK(will_layout);
- (void)SWIZZLE_CALLBACK(did_layout);

@end

@implementation UIViewController (swizzle)

static objc_swizzle_t
__gs_vc_viewloaded,
__gs_vc_willappear,
__gs_vc_didappear,
__gs_vc_willdisappear,
__gs_vc_diddisappear,
__gs_vc_naviitem,
__gs_vc_willlayout,
__gs_vc_didlayout
;

- (void)__swizzle_vc_viewloaded {
    objc_swizzle_t os = __gs_vc_viewloaded;
    ((void(*)(id, SEL))os.pimpl)(self, os.psel);

    if (self.isViewLoaded)
        [(id<UIViewControllerSwizzle>)self SWIZZLE_CALLBACK(view_loaded)];
}

- (void)__swizzle_vc_willappear:(BOOL)animated {
    objc_swizzle_t os = __gs_vc_willappear;
    ((void(*)(id, SEL, BOOL))os.pimpl)(self, os.psel, animated);
    
    [(id<UIViewControllerSwizzle>)self SWIZZLE_CALLBACK(appearing):animated];
}

- (void)__swizzle_vc_didappear:(BOOL)animated {
    objc_swizzle_t os = __gs_vc_didappear;
    ((void(*)(id, SEL, BOOL))os.pimpl)(self, os.psel, animated);
    
    [(id<UIViewControllerSwizzle>)self SWIZZLE_CALLBACK(appeared):animated];
}

- (void)__swizzle_vc_willdisappear:(BOOL)animated {
    objc_swizzle_t os = __gs_vc_willdisappear;
    ((void(*)(id, SEL, BOOL))os.pimpl)(self, os.psel, animated);
    
    [(id<UIViewControllerSwizzle>)self SWIZZLE_CALLBACK(disappearing):animated];
}

- (void)__swizzle_vc_diddisappear:(BOOL)animated {
    objc_swizzle_t os = __gs_vc_diddisappear;
    ((void(*)(id, SEL, BOOL))os.pimpl)(self, os.psel, animated);
    
    [(id<UIViewControllerSwizzle>)self SWIZZLE_CALLBACK(disappeared):animated];
}

- (UINavigationItem*)__swizzle_vc_naviitem {
    objc_swizzle_t os = __gs_vc_naviitem;
    UINavigationItem* ret = ((UINavigationItem*(*)(id, SEL))os.pimpl)(self, os.psel);
    
    [(id<UIViewControllerSwizzle>)self SWIZZLE_CALLBACK(navi_item):ret];
    return ret;
}

- (void)__swizzle_vc_willlayout {
    objc_swizzle_t os = __gs_vc_willlayout;
    ((void(*)(id, SEL))os.pimpl)(self, os.psel);
    
    [(id<UIViewControllerSwizzle>)self SWIZZLE_CALLBACK(will_layout)];
}

- (void)__swizzle_vc_didlayout {
    objc_swizzle_t os = __gs_vc_didlayout;
    ((void(*)(id, SEL))os.pimpl)(self, os.psel);

    [(id<UIViewControllerSwizzle>)self SWIZZLE_CALLBACK(did_layout)];
}

+ (void)Swizzles {
    Class cls = [UIViewController class];
    [cls SwizzleMethod:@selector(viewDidLoad) with:@selector(__swizzle_vc_viewloaded) with:&__gs_vc_viewloaded];
    [cls SwizzleMethod:@selector(viewWillAppear:) with:@selector(__swizzle_vc_willappear:) with:&__gs_vc_willappear];
    [cls SwizzleMethod:@selector(viewDidAppear:) with:@selector(__swizzle_vc_didappear:) with:&__gs_vc_didappear];
    [cls SwizzleMethod:@selector(viewWillDisappear:) with:@selector(__swizzle_vc_willdisappear:) with:&__gs_vc_willdisappear];
    [cls SwizzleMethod:@selector(viewDidDisappear:) with:@selector(__swizzle_vc_diddisappear:) with:&__gs_vc_diddisappear];
    [cls SwizzleMethod:@selector(navigationItem) with:@selector(__swizzle_vc_naviitem) with:&__gs_vc_naviitem];
    [cls SwizzleMethod:@selector(viewWillLayoutSubviews) with:@selector(__swizzle_vc_willlayout) with:&__gs_vc_willlayout];
    [cls SwizzleMethod:@selector(viewDidLayoutSubviews) with:@selector(__swizzle_vc_didlayout) with:&__gs_vc_didlayout];
}

@end

@implementation UITableView (swizzle)

static objc_swizzle_t __gs_tableview_layoutsubviews;

- (void)__swizzle_layoutsubviews {
    objc_swizzle_t os = __gs_tableview_layoutsubviews;
    ((void(*)(id, SEL))os.pimpl)(self, os.psel);
    
    [(id<UIViewSwizzle>)self SWIZZLE_CALLBACK(layout_subviews)];
}

static objc_swizzle_t __gs_tableview_touchbegin, __gs_tableview_touchend, __gs_tableview_touchcancel, __gs_tableview_touchmoved;

- (void)__swizzle_touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    kUITouched = YES;
    
    objc_swizzle_t os = __gs_tableview_touchbegin;
    ((void(*)(id, SEL, NSSet*, UIEvent*))os.pimpl)(self, os.psel, touches, event);
    
    [(id<UIResponseSwizzle>)self SWIZZLE_CALLBACK(touches_begin):touches withEvent:event];
}

- (void)__swizzle_touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    kUITouched = NO;

    objc_swizzle_t os = __gs_tableview_touchcancel;
    ((void(*)(id, SEL, NSSet*, UIEvent*))os.pimpl)(self, os.psel, touches, event);
    
    [(id<UIResponseSwizzle>)self SWIZZLE_CALLBACK(touches_cancel):touches withEvent:event];
}

- (void)__swizzle_touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    objc_swizzle_t os = __gs_tableview_touchmoved;
    ((void(*)(id, SEL, NSSet*, UIEvent*))os.pimpl)(self, os.psel, touches, event);
    
    [(id<UIResponseSwizzle>)self SWIZZLE_CALLBACK(touches_moved):touches withEvent:event];
}

- (void)__swizzle_touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    kUITouched = NO;

    objc_swizzle_t os = __gs_tableview_touchend;
    ((void(*)(id, SEL, NSSet*, UIEvent*))os.pimpl)(self, os.psel, touches, event);
    
    [(id<UIResponseSwizzle>)self SWIZZLE_CALLBACK(touches_end):touches withEvent:event];
}

+ (void)Swizzles {
    Class cls = [UITableView class];
    [cls SwizzleMethod:@selector(layoutSubviews) with:@selector(__swizzle_layoutsubviews) with:&__gs_tableview_layoutsubviews];
    
    [cls SwizzleMethod:@selector(touchesBegan:withEvent:) with:@selector(__swizzle_touchesBegan:withEvent:) with:&__gs_tableview_touchbegin];
    [cls SwizzleMethod:@selector(touchesEnded:withEvent:) with:@selector(__swizzle_touchesEnded:withEvent:) with:&__gs_tableview_touchend];
    [cls SwizzleMethod:@selector(touchesCancelled:withEvent:) with:@selector(__swizzle_touchesCancelled:withEvent:) with:&__gs_tableview_touchcancel];
    [cls SwizzleMethod:@selector(touchesMoved:withEvent:) with:@selector(__swizzle_touchesMoved:withEvent:) with:&__gs_tableview_touchmoved];
}

@end

@protocol UINavigationItemSwizzle <NSObject>

- (void)SWIZZLE_CALLBACK(set_titleview):(UIView*)view;

@end

@implementation UINavigationItem (swizzle)

static objc_swizzle_t __gs_navitem_settitileview;

- (void)__swizzle_settitleview:(UIView*)view {
    objc_swizzle_t os = __gs_navitem_settitileview;
    ((void(*)(id, SEL, UIView*))os.pimpl)(self, os.psel, view);
    
    [(id<UINavigationItemSwizzle>)self SWIZZLE_CALLBACK(set_titleview):view];
}

+ (void)Swizzles {
    Class cls = [UINavigationItem class];
    [cls SwizzleMethod:@selector(setTitleView:) with:@selector(__swizzle_settitleview:) with:&__gs_navitem_settitileview];
}

@end

@implementation UINavigationBar (swizzle)

static objc_swizzle_t __gs_navibar_layoutsubviews;

- (void)__swizzle_layoutsubviews {
    objc_swizzle_t os = __gs_navibar_layoutsubviews;
    ((void(*)(id, SEL))os.pimpl)(self, os.psel);
    
    [(id<UIViewSwizzle>)self SWIZZLE_CALLBACK(layout_subviews)];
}

+ (void)Swizzles {
    Class cls = [UINavigationBar class];
    [cls SwizzleMethod:@selector(layoutSubviews) with:@selector(__swizzle_layoutsubviews) with:&__gs_navibar_layoutsubviews];
}

@end

@protocol UINavigationControllerSwizzle <NSObject>

- (void)SWIZZLE_CALLBACK(pushing):(UIViewController*)vc animated:(BOOL)animated;
- (void)SWIZZLE_CALLBACK(push):(UIViewController*)vc animated:(BOOL)animated;
- (void)SWIZZLE_CALLBACK(pop):(UIViewController*)vc animated:(BOOL)animated;
- (void)SWIZZLE_CALLBACK(setViewControllers):(NSArray*)vcs animated:(BOOL)animated;

@end

@implementation UINavigationController (swizzle)

static objc_swizzle_t __gs_navi_push, __gs_navi_pop, __gs_navi_setvcs;

- (void)__swizzle_navi_push:(UIViewController*)vc animated:(BOOL)animated {
    if (vc == nil)
        return;
    
    if ([vc conformsToProtocol:@protocol(UIPushPop)]) {
        BOOL can = YES;
        if ([vc respondsToSelector:@selector(pushingInto:)]) {
            can = [(id<UIPushPop>)vc pushingInto:self];
        }
        if (can == NO)
            return;
    }

    [(id<UINavigationControllerSwizzle>)self SWIZZLE_CALLBACK(pushing):vc animated:animated];

    objc_swizzle_t os = __gs_navi_push;
    ((void(*)(id, SEL, UIViewController*, BOOL))os.pimpl)(self, os.psel, vc, animated);
    
    [(id<UINavigationControllerSwizzle>)self SWIZZLE_CALLBACK(push):vc animated:animated];
    
    if ([vc conformsToProtocol:@protocol(UIPushPop)]) {
        if ([vc respondsToSelector:@selector(pushInto:)]) {
            [(id<UIPushPop>)vc pushInto:self];
        }
    }
}

- (UIViewController*)__swizzle_navi_pop:(BOOL)animated {
    if (self.viewControllers.count <= 1)
        return nil;
        
    // 收掉键盘
    if ([UIKeyboardExt shared].visible)
        [UIKeyboardExt Close];
    
    objc_swizzle_t os = __gs_navi_pop;
    UIViewController* ret = ((UIViewController*(*)(id, SEL, BOOL))os.pimpl)(self, os.psel, animated);

    [(id<UINavigationControllerSwizzle>)self SWIZZLE_CALLBACK(pop):ret animated:animated];
    
    if ([ret conformsToProtocol:@protocol(UIPushPop)]) {
        if ([ret respondsToSelector:@selector(popFrom:)]) {
            [(id<UIPushPop>)ret popFrom:self];
        }
    }
    
    return ret;
}

- (void)__swizzle_navi_setvcs:(NSArray*)vcs animated:(BOOL)animated {
    objc_swizzle_t os = __gs_navi_setvcs;
    ((void(*)(id, SEL, NSArray*, BOOL))os.pimpl)(self, os.psel, vcs, animated);
    [(id<UINavigationControllerSwizzle>)self SWIZZLE_CALLBACK(setViewControllers):vcs animated:animated];
}

+ (void)Swizzles {
    Class cls = [UINavigationController class];
    [cls SwizzleMethod:@selector(pushViewController:animated:) with:@selector(__swizzle_navi_push:animated:) with:&__gs_navi_push];
    [cls SwizzleMethod:@selector(popViewControllerAnimated:) with:@selector(__swizzle_navi_pop:) with:&__gs_navi_pop];
    [cls SwizzleMethod:@selector(setViewControllers:animated:) with:@selector(__swizzle_navi_setvcs:animated:) with:&__gs_navi_setvcs];
}

@end

@implementation UITypes

+ (void)Swizzles {
    [UIResponder Swizzles];
    [UIView Swizzles];
    [UIControl Swizzles];
    [UIViewController Swizzles];
    [UITableView Swizzles];
    [UINavigationItem Swizzles];
    [UINavigationBar Swizzles];
    [UINavigationController Swizzles];
    [UIScrollView Swizzles];
}

@end
