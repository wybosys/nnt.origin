
# import "Common.h"
# import "UIPopoverView.h"
# import "AppDelegate+Extension.h"

@interface UIPopoverDesktopView : UIDesktopView

@property (nonatomic, assign) UIPopoverView* popover;

@end

@implementation UIPopoverDesktopView

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor clearColor];
    [self.signals connect:kSignalClicked withSelector:@selector(close) ofTarget:self];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    CGRect tgtrc = self.popover.targetView.screenFrame;
    CGRect poprc = self.popover.frame;
    if (tgtrc.origin.y + tgtrc.size.height + poprc.size.height > rect.size.height) {
        poprc.origin.y = tgtrc.origin.y - poprc.size.height;
    } else {
        poprc.origin.y = tgtrc.origin.y + tgtrc.size.height;
    }
    if (poprc.size.width == 0)
        poprc.size.width = rect.size.width;
    self.popover.frame = poprc;
}

@end

@interface UIPopoverView ()
{
    BOOL _above;
    CGPoint _arrowPoint;
    UIView* _baseView;
    UIPopoverDesktopView* _desk;
    CGPadding _offpad; // 需要增加的偏移量
}

@property (nonatomic, retain) UIColor *viewColor;

@end

@implementation UIPopoverView

- (void)onInit {
    [super onInit];
    
    self.autoClose = YES;
    self.backgroundColor = [UIColor colorWithRGB:0xFFFFFF];
    self.contentMode = UIViewContentModeRedraw;
    self.paddingEdge = CGPaddingMake(10, 10, 10, 10);
    self.arrowHeight = 12;
    self.cornerRadius = 4;
    self.arrowCurvature = 6;
    self.arrowHorizontalPadding = 5;
    self.borderShadow = BLOCK_RETURN({
        CGShadow* sd = [CGShadow temporary];
        sd.color = [UIColor blackWithAlpha:0.4].CGColor;
        sd.offset = CGSizeMake(0, 1);
        sd.radius = 10;
        return sd;
    });
    
    _offpad = CGPaddingZero;
    _baseView = [UIAppDelegate shared].topmostViewController.view;
    
    [[UIKit shared].signals connect:kSignalClicked withSelector:@selector(anyClicked:) ofTarget:self];
    [[UIScrollView shared].signals connect:kSignalDraggingBegin withSelector:@selector(anyDragging:) ofTarget:self];
}

- (void)onFin {
    ZERO_RELEASE(_viewColor);
    ZERO_RELEASE(_borderShadow);
    [super onFin];
}

- (id)initWithContent:(UIView *)view {
    self = [super initWithZero];
    self.contentView = view;
    return self;
}

+ (instancetype)popoverContent:(UIView *)view {
    return [[(UIPopoverView*)[[self class] alloc] initWithContent:view] autorelease];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalClosed)
SIGNALS_END

- (void)setContentView:(UIView *)contentView {
    [_contentView removeFromSuperview];
    [self addSubview:contentView];
    _contentView = contentView;
    
    CGSize size = contentView.bounds.size;
    if (size.width == 0 || size.height == 0) {
        CGSize bstsz = contentView.bestSize;
        if (size.width == 0) {
            if (bstsz.width)
                size.width = bstsz.width;
            else
                size.width = kUIApplicationSize.width - 2*CGPaddingWidth(self.paddingEdge);
        }
        if (size.height == 0) {
            if (bstsz.height)
                size.height = bstsz.height;
            else
                size.height = kUIApplicationSize.height - 2*CGPaddingHeight(self.paddingEdge);
        }
    }
    
    // 调整大小
    if (size.width)
        size.width += CGPaddingWidth(self.paddingEdge);
    if (size.height)
        size.height += CGPaddingHeight(self.paddingEdge);
    
    // 应用到大小
    self.size = size;
    
    // content 可以通过信号来隐藏本界面
    [contentView.signals addSignal:kSignalRequestClose];
    [contentView.signals connect:kSignalRequestClose withSelector:@selector(dismiss) ofTarget:self];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    if (backgroundColor == [UIColor clearColor]) {
        [super setBackgroundColor:backgroundColor];
        return;
    }
    
    self.viewColor = backgroundColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.targetView == nil)
        return;
    
    _above = NO;
    
    CGRect rect = self.bounds;
    _arrowPoint = CGRectCenter(rect);
    
    // 计算箭头位置
    CGRect myrc = [self frameForView:_baseView]; // 自身相对于 base 的位置
    CGRect tgtrc = [self.targetView frameForView:_baseView]; // 目标相对于 base 的位置
    
    CGPoint mytc = CGRectTopCenter(myrc);
    CGPoint tgtc = CGRectTopCenter(tgtrc);
    
    // 计算附加的偏移
    _offpad = CGPaddingZero;
    if (tgtc.x < myrc.origin.x)
    {
        _arrowPoint.x = 0;
        _offpad.left = self.arrowHeight;
    }
    else if (tgtc.x > myrc.origin.x + myrc.size.width)
    {
        _arrowPoint.x = myrc.size.width - self.arrowHeight * 2;
    }
    else
    {
        _arrowPoint.x += tgtc.x - mytc.x;
    }
    
    CGPoint mybc = CGRectBottomCenter(myrc);
    if (tgtc.y < mybc.y)
    {
        _arrowPoint.y = 0;
        _offpad.top = self.arrowHeight;
    }
    else if (tgtc.y >= mybc.y)
    {
        _arrowPoint.y = rect.size.height;
        _offpad.bottom = self.arrowHeight;
        _above = YES;
    }
    
    // 移动 rect
    CGRect rc = self.bounds;
    rc = CGRectApplyPadding(rc, _offpad);
    rc = CGRectApplyPadding(rc, self.paddingEdge);
    self.contentView.frame = rc;
}

- (void)onPaint:(CGGraphic *)graphic {
    CGRect frame = graphic.bounds;
    frame = CGRectApplyPadding(frame, _offpad);
    
    CGPoint ptMin = CGRectGetMinPoint(frame);
    CGPoint ptMax = CGRectGetMaxPoint(frame);
    
    CGFloat radius = self.cornerRadius;
    CGFloat cpOffset = radius * .3;
    
    /*
     LT2            RT1
     LT1⌜⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⌝RT2
     |               |
     |    popover    |
     |               |
     LB2⌞_______________⌟RB1
     LB1           RB2
     
     Traverse rectangle in clockwise order, starting at LT1
     L = Left
     R = Right
     T = Top
     B = Bottom
     1,2 = order of traversal for any given corner
     
     */
    CGBezier* rgn = [CGBezier temporary];
    
    // LT1
    [rgn move:CGPointOffset(ptMin, 0, radius)];
    
    // LT2
    [rgn curve:CGPointOffset(ptMin, radius, 0)
             a:CGPointOffset(ptMin, 0, radius - cpOffset)
             b:CGPointOffset(ptMin, radius - cpOffset, 0)];
    
    //If the popover is positioned below (!above) the arrowPoint, then we know that the arrow must be on the top of the popover.
    //In this case, the arrow is located between LT2 and RT1
    if(self.targetView && !_above)
    {
        // left side
        [rgn line:CGPointMake(_arrowPoint.x - self.arrowHeight, ptMin.y)];
        // arrow point
        [rgn curve:_arrowPoint
                 a:CGPointMake(_arrowPoint.x - self.arrowHeight + self.arrowCurvature, ptMin.y)
                 b:_arrowPoint];
        // right side
        [rgn curve:CGPointMake(_arrowPoint.x + self.arrowHeight, ptMin.y)
                 a:_arrowPoint
                 b:CGPointMake(_arrowPoint.x + self.arrowHeight - self.arrowCurvature, ptMin.y)];
    }
    
    // RT1
    [rgn line:CGPointMake(ptMax.x - radius, ptMin.y)];
    
    // RT2
    [rgn curve:CGPointMake(ptMax.x, ptMin.y + radius)
             a:CGPointMake(ptMax.x - radius + cpOffset, ptMin.y)
             b:CGPointMake(ptMax.x, ptMin.y + radius - cpOffset)];
    
    // RB1
    [rgn line:CGPointMake(ptMax.x, ptMax.y - radius)];

    // RB2
    [rgn curve:CGPointMake(ptMax.x - radius, ptMax.y)
             a:CGPointMake(ptMax.x, ptMax.y - radius + cpOffset)
             b:CGPointMake(ptMax.x - radius + cpOffset, ptMax.y)];
    
    //If the popover is positioned above the arrowPoint, then we know that the arrow must be on the bottom of the popover.
    //In this case, the arrow is located somewhere between LB1 and RB2
    if(self.targetView && _above) {
        // right side
        [rgn line:CGPointMake(_arrowPoint.x + self.arrowHeight, ptMax.y)];
        // arrow point
        [rgn curve:_arrowPoint
                 a:CGPointMake(_arrowPoint.x + self.arrowHeight - self.arrowCurvature, ptMax.y)
                 b:_arrowPoint];
        // right side
        [rgn curve:CGPointMake(_arrowPoint.x - self.arrowHeight, ptMax.y)
                 a:_arrowPoint
                 b:CGPointMake(_arrowPoint.x - self.arrowHeight + self.arrowCurvature, ptMax.y)];
    }
    
    // LB1
    [rgn line:CGPointMake(ptMin.x + radius, ptMax.y)];
    
    // LB2
    [rgn curve:CGPointMake(ptMin.x, ptMax.y - radius)
             a:CGPointMake(ptMin.x + radius - cpOffset, ptMax.y)
             b:CGPointMake(ptMin.x, ptMax.y - radius + cpOffset)];
    
    // 画出来    
    [graphic layer:^(CGGraphic *graphic) {
        [rgn commit];
        [rgn clip];
        [graphic rect:self.bounds pen:nil brush:[CGSolidBrush Brush:self.viewColor.CGColor]];
    } shadow:self.borderShadow];
}

- (void)popoverForView:(UIView*)view {
    // 需要计算一下需要偏移的位置
    CGRect sfrc = self.frame; // 自己的位置
    CGRect ssfrc = CGRectMakeWithSize(kUIApplicationSize); // 屏幕的位置，判断有没有超出屏幕
    CGRect desrc = view.frame; // 目标的位置
    // 先和目标同轴
    sfrc.origin.x = desrc.origin.x;
    // 尝试居中
    sfrc.origin.x += (CGRectGetWidth(desrc) - CGRectGetWidth(sfrc))*0.5f;
    // 如果超出了大小，则往回移动
    if (CGRectGetMaxX(sfrc) > CGRectGetMaxX(ssfrc)) {
        sfrc.origin.x -= CGRectGetMaxX(sfrc) - CGRectGetMaxX(ssfrc);
    }
    self.frame = sfrc;
    
    // 使用desktop来显示
    _desk = [[UIPopoverDesktopView alloc] initWithZero];
    [_desk addSubview:self];
    _desk.popover = self;
    self.targetView = view;
    [_desk open];
    SAFE_RELEASE(_desk);
    
    // 需要自动继承一下 navigation，否则必须业务层手动设置
    self.navigationController = view.navigationController;
}

- (void)showForView:(UIView*)view inView:(UIView*)inview {
    if (inview == nil)
        inview = [UIAppDelegate shared].topmostViewController.view;
    
    self.targetView = view;
    _baseView = inview;
    
    [inview addSubview:self];
    
    CGRect tgtrc = [self.targetView frameForView:inview];
    CGRect poprc = self.frame;
    CGRect rect = inview.bounds;
    
    if (poprc.size.width == 0)
        poprc.size.width = rect.size.width;
    if (poprc.size.height == 0)
        poprc.size.height = rect.size.height;    
    
    // 调整y位置
    if (tgtrc.origin.y + tgtrc.size.height + poprc.size.height > rect.origin.y + rect.size.height) {
        poprc.origin.y = tgtrc.origin.y - poprc.size.height;
    } else {
        poprc.origin.y = tgtrc.origin.y + tgtrc.size.height;
    }
    
    // 调整x位置
    if (poprc.origin.x + poprc.size.width + self.arrowHeight < tgtrc.origin.x + tgtrc.size.width) {
        if (tgtrc.origin.x + poprc.size.width + self.arrowHeight < rect.origin.x + rect.size.width)
            poprc.origin.x = tgtrc.origin.x - poprc.size.width * .5f;
        else
            poprc.origin.x = rect.origin.x + rect.size.width - poprc.size.width;
    }
    
    self.frame = poprc;
    
    [self.layer addAnimation:[CAKeyframeAnimation FadeIn] forKey:nil];
    
    // 需要自动继承一下 navigation，否则必须业务层手动设置
    self.navigationController = view.navigationController;
}

- (void)dismiss {
    if (_desk)
    {
        [_desk close];
    }
    else
    {
        [UIView animateWithDuration:.35f
                         animations:^{
                             self.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             [self removeFromSuperview];
                         }];
    }
    
    [self.signals emit:kSignalClosed];
}

- (void)anyClicked:(SSlot*)s {
    if (_autoClose == NO)
        return;
    
    UIView* v = s.data.object;
    if ([v hasSuperView:self] == NO) {
        [self dismiss];
        [s.tunnel veto];
    }
}

- (void)anyDragging:(SSlot*)s {
    [self dismiss];
}

@end
