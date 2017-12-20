
# import "app.h"
# import "VCPracticePosture.h"
# import "NSSystemFeatures.h"

@interface VPracticePosture : UIViewExt

@property (nonatomic, readonly) UIViewExt *idrBall, *idrStep;

@end

@implementation VPracticePosture

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:BLOCK_RETURN({
        _idrBall = [UIViewExt temporary];
        _idrBall.size = CGSizeMake(60, 60);
        _idrBall.backgroundColor = [UIColor blackColor];
        return _idrBall;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _idrStep = [UIViewExt temporary];
        _idrStep.size = CGSizeMake(60, 60);
        _idrStep.backgroundColor = [UIColor blackColor];
        return _idrStep;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    _idrBall.center = CGRectCenter(rect);
    _idrStep.rightTop = CGRectRightTop(rect);
}

@end

@interface VCPracticePosture ()

@property (nonatomic, readonly) NSPostureService *svcPosture;
@property (nonatomic, readonly) NSWalkerService *svcWalker;

@end

@implementation VCPracticePosture

- (void)onInit {
    [super onInit];
    self.classForView = [VPracticePosture class];
    
    _svcPosture = [[NSPostureService alloc] init];
    [_svcPosture.signals connect:kSignalValueChanged withSelector:@selector(cbPostureChanged) ofTarget:self];
    [_svcPosture start];
    [_svcPosture startNear];
    
    _svcWalker = [[NSWalkerService alloc] init];
    [_svcWalker.signals connect:kSignalWalkerStepChanged withSelector:@selector(cbWalkerChanged:) ofTarget:self];
    [_svcWalker startStepCount];
}

- (void)onLoaded {
    [super onLoaded];
}

- (void)cbPostureChanged {
    VPracticePosture* view = (id)self.view;
    CGPoint center = CGRectCenter(view.bounds);
    CGFloat radius = CGSizeSquare(view.bounds.size, kCGEdgeMin).width / 2;
    
    // 加速度，越大，球变得越小，往哪个方向加速度，则球去哪个方向
    CGPoint3d per = _svcPosture.percentAccelerometer;
    CGPoint offpt = {per.x * radius, per.y * radius};
    view.idrBall.center = CGPointOffsetByPoint(center, CGPointIntegral(offpt));
    
    // 陀螺仪方向将是当前页面产生偏角
    per = _svcPosture.gyro.point3d;
    view.layer.transform = CGTransform3DRotationFromPoint(per);
 
    // 如果靠近，背景变个颜色
    if (_svcPosture.neared) {
        view.backgroundColor = [UIColor redColor];
    } else {
        view.backgroundColor = [UIColor whiteColor];
    }
}

- (void)cbWalkerChanged:(SSlot*)s {
    NSWalkerInfo* wi = s.data.object;
    if (wi.steps) {
        VPracticePosture* view = (id)self.view;
        [view.idrStep.layer addAnimation:[CAKeyframeAnimation Twinkling:1]];
    }
}

@end
