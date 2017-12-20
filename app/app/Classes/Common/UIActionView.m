
# import "Common.h"
# import "UIActionView.h"
# import "AppDelegate+Extension.h"
# import "UIPercentageWidgets.h"

enum UISwipeGestureState
{
    kUISwipeGestureStateNormal,
    kUISwipeGestureStateNormalAnimated,
    kUISwipeGestureStateLeft,
    kUISwipeGestureStateRight,
};

enum UISwipeState
{
    kUISwipeStateNormal,
    kUISwipeStateLeft,
    kUISwipeStateRight,
};

@interface UIGestureActivateView ()
<UIGestureRecognizerDelegate>
{
    CGPoint _pos;
    CGFloat _deta;
    SSignal *_toggled;
    BOOL _ani;
}

@property (nonatomic, readonly) UIPanGestureRecognizer *gesPan;

@end

@implementation UIGestureActivateView

- (void)onInit {
    [super onInit];
    
    _gesPan = [[UIPanGestureRecognizer alloc] init];
    _gesPan.delegate = self;
    [self addGestureRecognizer:_gesPan];
    SAFE_RELEASE(_gesPan);
    
    [_gesPan.signals connect:kSignalGestureBegan withSelector:@selector(__cbTouchesBegan:) ofTarget:self];
    [_gesPan.signals connect:kSignalGestureChanged withSelector:@selector(__cbTouchesMoved:) ofTarget:self];
    [_gesPan.signals connect:kSignalGestureEnded withSelector:@selector(__cbTouchesEnd:) ofTarget:self];
    [_gesPan.signals connect:kSignalGestureCancel withSelector:@selector(reset) ofTarget:self];
        
    [self.signals connect:kSignalLayoutBegin withSelector:@selector(__cbLayoutBegin:) ofTarget:self];
    [self.signals connect:kSignalLayoutEnd withSelector:@selector(__cbLayoutEnd:) ofTarget:self];
    [self.signals connect:kSignalLayouting withSelector:@selector(__cbLayouting:) ofTarget:self];
    
    // 设置为最先激活的点击信号
    [self.signals connect:kSignalClicked withSelector:@selector(__cbClicked:) ofTarget:self];
    SSlot* s = [[self.signals findSlots:kSignalClicked] findSelector:@selector(__cbClicked:) ofTarget:self];
    [[self.signals findSlots:kSignalClicked] setTopmost:s];
    
    self.gestureEnable = YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // 如果是平移，则不响应
    //if (CGDirectionIsHorizontal(self.gesPan.direction))
    //    return NO;
    
    // 如果是navi用来会退的手势
    if ([otherGestureRecognizer isKindOfClass:NSClassFromString(@"UINaviExtPanGestureRecognizer")])
        return NO;
    
    // 如果是container的ges，则也不响应
    if (otherGestureRecognizer == [UIAppDelegate shared].container.panGestureRecognizer)
        return NO;
    
    return YES;
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalGestureActivatedAny)
SIGNAL_ADD(kSignalGestureActivatedLeft)
SIGNAL_ADD(kSignalGestureActivatedRight)
SIGNALS_END

# define SET_VIEW(old, new) \
if (old == new) return; \
[old removeFromSuperview]; \
old = new; \
[self addSubview:new];

- (void)setViewLeft:(UIView *)viewLeft {
    SET_VIEW(_viewLeft, viewLeft);
    _widthLeft = _viewLeft.frame.size.width;
    [_viewLeft setWidth:0];
}

- (void)setViewRight:(UIView *)viewRight {
    SET_VIEW(_viewRight, viewRight);
    _widthRight = _viewRight.frame.size.width;
    [_viewRight setWidth:0];
}

- (void)__cbLayoutBegin:(SSlot*)s {
    NSRect* rc = (NSRect*)s.data.object;
    
    [self.viewLeft setHeight:rc.size.height];
    [self.viewRight setHeight:rc.size.height];
    
    if (_ani) {
        [UIView beginAnimations:nil context:nil];
    }
    
    self.viewLeft.positionX = rc.x - self.viewLeft.frame.size.width + _deta;
    self.viewRight.positionX = rc.x + rc.width + _deta;
    
    rc.x += _deta;
}

- (void)__cbLayouting:(SSlot*)s {
    PASS;
}

- (void)__cbLayoutEnd:(SSlot*)s {
    if (_ani) {
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(_cbAnimated)];
        [UIView commitAnimations];
    }
    _ani = NO;
}

- (void)__cbTouchesBegan:(SSlot*)s {
    _pos = self.extension.positionTouched;
    _ani = NO;
}

- (void)__cbTouchesMoved:(SSlot*)s {
    if (CGDirectionIsHorizontal(self.gesPan.direction) == NO)
        return;
    
    CGPoint pt = self.extension.positionTouched;
    
    if (_gestureEnable)
        _deta += pt.x - _pos.x;
    
    if (_deta < 0 && self.viewRight == nil) {
        _deta = 0;
    } else if (_deta > 0 && self.viewLeft == nil) {
        _deta = 0;
    }
    
    _pos = pt;
    
    [self _updateViewsSize];
    
    [self setNeedsLayout];
    [s.tunnel veto];
}

- (void)_updateViewsSize {
    // 设置大小
    if (_deta > 0) {
        [self.viewLeft setWidth:_deta];
        [self.viewRight setWidth:0 anchorPoint:kCGAnchorPointRT];
    } else if (_deta < 0) {
        [self.viewLeft setWidth:0];
        [self.viewRight setWidth:-_deta anchorPoint:kCGAnchorPointRT];
    } else {
        [self.viewLeft setWidth:_deta];
        [self.viewRight setWidth:_deta anchorPoint:kCGAnchorPointRT];
    }
    
    [self.viewLeft actionViewBleach];
    [self.viewRight actionViewBleach];
}

- (void)__cbTouchesEnd:(SSlot*)s {
    // 计算动画
    if (_deta > _widthLeft) {
        _deta = _widthLeft;
        _toggled = kSignalGestureActivatedLeft;
        _ani = YES;
    } else if (_deta < -_widthRight) {
        _deta = -_widthRight;
        _toggled = kSignalGestureActivatedRight;
        _ani = YES;
    } else if (_deta == 0) {
        //_ani = NO;
    } else {
        _deta = 0;
        _ani = YES;
    }
    
    // 调整界面
    [self _updateViewsSize];
    [self setNeedsLayout];
    
    // 初始颜色
    [self.viewLeft actionViewBleach:0];
    [self.viewRight actionViewBleach:0];
}

- (void)openLeft:(BOOL)animated {
    _ani = animated;
    _deta = _widthLeft;
    _toggled = kSignalGestureActivatedLeft;
    [self _updateViewsSize];
    [self setNeedsLayout];
    [self.viewLeft actionViewBleach:0];
}

- (void)openRight:(BOOL)animated {
    _ani = animated;
    _deta = -_widthRight;
    _toggled = kSignalGestureActivatedRight;
    [self _updateViewsSize];
    [self setNeedsLayout];
    [self.viewRight actionViewBleach:0];
}

- (void)_cbAnimated {
    id ani = nil;
    if (_deta > 0) {
        ani = [CAKeyframeAnimation WabbleNeg];
    } else if (_deta < 0) {
        ani = [CAKeyframeAnimation Wabble];
    } else if (_toggled == kSignalGestureActivatedLeft) {
        ani = [CAKeyframeAnimation WabbleNeg];
    } else if (_toggled == kSignalGestureActivatedRight) {
        ani = [CAKeyframeAnimation Wabble];
    }
    
    if (ani) {
        for (CALayer* each in self.layer.sublayers) {
            if (each == self.viewLeft.layer ||
                each == self.viewRight.layer) {
                continue;
            }
            [each addAnimation:ani forKey:nil];
        }
    }
    
    if (_toggled) {
        [self.signals emit:kSignalGestureActivatedAny];
        [self.signals emit:_toggled];
        _toggled = nil;
    }
}

- (void)reset {
    [self reset:YES];
}

- (void)reset:(BOOL)animated {
    if (_deta == 0)
        return;
    
    _deta = 0;
    _ani = animated;
    [self setNeedsLayout];
}

- (void)__cbClicked:(SSlot*)s {
    if (_deta != 0) {
        [s.tunnel veto];
    }
    
    // 关闭
    [self reset:_deta != 0];
}

- (void)openLeft {
    [self openLeft:YES];
}

- (void)openRight {
    [self openRight:YES];
}

@end

@interface UIGestureImageView ()
{
    CGSize _imageSize, _bestSize;
}

@end

@implementation UIGestureImageView

- (void)onInit {
    [super onInit];

    [self addSubview:BLOCK_RETURN({
        _imageView = [UIImageViewExt temporary];
        _imageView.classForFetchingIdentifier = [UIRingPercentageIndicator class];
        return _imageView;
    })];
    
    [_imageView.signals connect:kSignalImageChanged withSelector:@selector(cbImageChanged:) ofTarget:self];
    
    // 双击进行动画切换
    [self.imageView.signals connect:kSignalClicked ofTarget:self];
    [self.imageView.signals connect:kSignalDbClicked withSelector:@selector(actScale) ofTarget:self];
    
    // 不能显示放大后的滑动提示条
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.maximumZoomScale = 10;
}

- (void)onFin {
    ZERO_RELEASE(_file);
    ZERO_RELEASE(_thumb);
    
    [super onFin];
}

- (CGRect)bestBehalfRegion:(CGSize)sz {
    CGRect rc = CGRectMakeWithSize(_bestSize);
    rc = CGRectSetCenter(rc, CGRectCenter(self.bounds));
    return rc;
}

- (void)setFile:(id)file {
    PROPERTY_RETAIN(_file, file);
    _imageView.imageDataSource = file;
}

- (void)setThumb:(id)thumb {
    PROPERTY_RETAIN(_thumb, thumb);
    _imageView.imageDataSource = thumb;
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    // 初始化默认的大小
    if (CGRectEqualToRect(_imageView.frame, CGRectZero))
    {
        // 初始化最佳大小
        _bestSize = [_imageView bestSize:rect.size];
        _imageView.size = _bestSize;
        _imageView.center = CGRectCenter(self.availableBounds);
    }
}

- (void)cbImageChanged:(SSlot*)s {
    UIImage* img = s.data.object;
    _imageSize = img.size;
    
    // 初始化最佳大小
    _bestSize = [_imageView bestSize:self.bounds.size];

    // 重置大小
    [_imageView setSize:_bestSize];
    self.contentSize = self.bounds.size;
    self.contentOffset = CGPointZero;
    _imageView.center = CGRectCenter(self.availableBounds);
}

- (void)doScale:(CGFloat)sc atPoint:(CGPoint)pt animated:(BOOL)animated {
    if (sc <= 1)
    {
        // 不能缩的比最小的尺寸小, 否则恢复最佳大小
        [self setZoomScale:1 animated:animated];
        
        // 回归了原始大小，则链接为放大
        [self.imageView.signals disconnect:kSignalDbClicked ofTarget:self];
        [self.imageView.signals connect:kSignalDbClicked withSelector:@selector(actScale) ofTarget:self];
    }
    else
    {
        // 计算目标区域
        CGRect brc = self.bounds;
        CGRect vrc = self.imageView.frame;
        
        CGRect tgtrc;
        tgtrc.size.width = brc.size.width / sc;
        tgtrc.size.height = brc.size.width / sc;
        pt.x -= tgtrc.size.width/2;
        pt.y -= tgtrc.size.height/2;
        if (pt.x < vrc.origin.x) pt.x = vrc.origin.x;
        if (pt.y < vrc.origin.y) pt.y = vrc.origin.y;
        if (pt.x > CGRectGetMaxX(vrc) - tgtrc.size.width) pt.x = CGRectGetMaxX(vrc) - tgtrc.size.width;
        if (pt.y > CGRectGetMaxY(vrc) - tgtrc.size.height) pt.y = CGRectGetMaxY(vrc) - tgtrc.size.height;
        tgtrc.origin = pt;
        
        // 放大到指定比例
        [self zoomToRect:tgtrc animated:animated];
        
        // 如果有缩放，则双击默认为回归原始大小
        [self.imageView.signals disconnect:kSignalDbClicked ofTarget:self];
        [self.imageView.signals connect:kSignalDbClicked withSelector:@selector(actUnScale) ofTarget:self];
    }
}

/*
- (void)cbPinch:(SSlot*)s {
    UIPinchGestureRecognizer* regr = (UIPinchGestureRecognizer*)s.sender;
    [self doScale:regr.scale atPoint:[regr locationInView:self.imageView] animated:NO];
}
 */

- (void)actScale {
    [self.imageView.signals disconnect:kSignalDbClicked ofTarget:self];
    [self.imageView.signals connect:kSignalDbClicked withSelector:@selector(actUnScale) ofTarget:self];
    
    CGPoint pt = [self.imageView.extension positionTouchedIn:self.viewContent];
    [self doScale:2 atPoint:pt animated:YES];
}

- (void)actUnScale {
    [self.imageView.signals disconnect:kSignalDbClicked ofTarget:self];
    [self.imageView.signals connect:kSignalDbClicked withSelector:@selector(actScale) ofTarget:self];

    CGPoint pt = [self.imageView.extension positionTouchedIn:self.viewContent];
    [self doScale:1 atPoint:pt animated:YES];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.viewContent;
}

@end

@implementation UIView (actionView)

- (void)actionViewBleach {
    CGRect src = self.frame;
    CGRect prc = self.superview.frame;
    if (prc.size.width == 0)
        return;
    
    CGFloat rt = src.size.width / (prc.size.width * .8f);
    rt = 1 - rt;
    
    [self actionViewBleach:rt];
}

- (void)actionViewBleach:(CGFloat)ratio {
    UIColor* color = self.motifColor;
    if (ratio != 0)
        color = [color bleachWithValue:ratio];
    self.backgroundColor = color;
}

@end
