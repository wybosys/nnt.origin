
# import "app.h"
# import "VCPractice3DX.h"
# import "VCRlt3d.h"

@interface VPractice3DX : UIViewExt

@property (nonatomic, retain) VCRlt3d *rlt;

@end

@implementation VPractice3DX

- (void)onInit {
    [super onInit];
}

- (void)onFin {
    ZERO_RELEASE(_rlt);
    [super onFin];
}

- (void)setRlt:(VCRlt3d *)rlt {
    if (_rlt == rlt)
        return;
    
    [self removeSubcontroller:_rlt];
    PROPERTY_RETAIN(_rlt, rlt);
    [self addSubcontroller:_rlt];
    
    _rlt.view.frame = self.rectForLayout;
}

@end

@implementation VCPractice3DX

- (void)onInit {
    [super onInit];
    self.classForView = [VPractice3DX class];
    self.enableContainerGesture = NO;
}

- (void)onFin {
    [super onFin];
}

- (void)onLoaded {
    [super onLoaded];
    self.view.backgroundImage = [UIImage bundleNamed:@"apprlt.bundle/bg.jpg"];
    //[self.view.signals connect:kSignalClicked withSelector:@selector(actClicked) ofTarget:self];
    
    self.navigationItem.rightBarButtonItem = BLOCK_RETURN({
        UIBarButtonItem* btn = [UIBarButtonItem itemWithTitle:@"新开一个"];
        [btn.signals connect:kSignalClicked withSelector:@selector(actNew) ofTarget:self];
        return btn;
    });
    
    [self.view.unifiedGestureTouches addGestureRecognizer:BLOCK_RETURN({
        UIPinchGestureRecognizer* ges = [UIPinchGestureRecognizer temporary];
        return ges;
    })];
    
    [self.view.unifiedGestureTouches addGestureRecognizer:BLOCK_RETURN({
        UIPanGestureRecognizer* ges = [UIPanGestureRecognizer temporary];
        ges.minimumNumberOfTouches = ges.maximumNumberOfTouches = 2;
        return ges;
    })];
    
    [self.view.unifiedGestureTouches.signals connect:kSignalStart withSelector:@selector(cbTouchsBegan) ofTarget:self];
    [self.view.unifiedGestureTouches.signals connect:kSignalDone withSelector:@selector(cbTouchsEnd) ofTarget:self];
    [self.view.unifiedGestureTouches.signals connect:kSignalTouchesMoved withSelector:@selector(cbTouchsMoved) ofTarget:self];
    [self.view.unifiedGestureTouches.signals connect:kSignalGestureRecognized withSelector:@selector(cbGestureRec:) ofTarget:self];
}

- (void)onAppearing {
    [super onAppearing];
    VPractice3DX* view = (id)self.view;
    view.rlt = [VCRlt3d temporary];
    [view.rlt start];
}

- (void)onDisappearing {
    [super onDisappearing];
    VPractice3DX* view = (id)self.view;
    [view.rlt stop];
    [view.rlt removeScene];
    view.rlt = nil;
}

- (void)actNew {
    // 先得停下当前的
    VPractice3DX* view = (id)self.view;
    [view.rlt stop];
    [view.rlt removeScene];
    view.rlt = nil;
    
    // 再推入新的
    UIViewController* ctlr = [self.class temporary];
    [self.navigationController pushViewController:ctlr];
}

// 单点触摸
- (void)cbTouchsBegan {
    VPractice3DX* view = (id)self.view;
    [view.rlt pause];
    [CAAnimationProducer Stop:@"earth"];
}

- (void)cbTouchsEnd {
    VPractice3DX* view = (id)self.view;
    CGPoint velo = self.view.extension.velocityTouched;
    if (CGPointEqualToPoint(velo, CGPointZero)) {
        [view.rlt resume];
    } else {
        // 手指离开后，继续向原方向滚动
        [CAAnimationProducer animates:^(CAAnimationProducer *ap) {
            ap.keyname = @"earth";
            ap.timefunction = kCAMediaTimingFunctionEaseIn;
            //ap.timefunction = kCAMediaTimingFunctionSpring;
            ap.duration = 1;
        } progress:^(float p, float d) {
            [view.rlt rotateScene:CGPointMake(velo.x * d, velo.y * d)];
        } completion:^{
            [view.rlt resume];
        }];
    }
}

// 移动手指来滚动地球
- (void)cbTouchsMoved {
    VPractice3DX* view = (id)self.view;
    CGPoint pt = self.view.extension.deltaTouched;
    [view.rlt rotateScene:pt];
}

// 手势触摸，支持：放大、缩放
- (void)cbGestureRec:(SSlot*)s {
    VPractice3DX* view = (id)self.view;
    UIGestureRecognizer* rec = s.data.object;
    if ([rec isKindOfClass:[UIPinchGestureRecognizer class]])
    {
        UIPinchGestureRecognizer* ges = (id)rec;
        [view.rlt zoomScene:ges.zoom];
    }
    else if ([rec isKindOfClass:[UIPanGestureRecognizer class]])
    {
        UIPanGestureRecognizer* ges = (id)rec;
        [view.rlt moveScene:ges.delta];
    }
}

// 点击一下，定位中心点到上海，属于测试代码
- (void)actClicked {
    VPractice3DX* view = (id)self.view;
    [view.rlt centerScene:CGPointMake(121, 31)];
}

@end
