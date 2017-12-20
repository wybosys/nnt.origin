
# import "app.h"
# import "VCPracticePercentage.h"
# import "UIPercentageWidgets.h"

@interface VPracticePercentage : UIViewExt
{
    int _cur;
}

@property (nonatomic, readonly) NSTimerExt *timer;
@property (nonatomic, readonly) UIProgressView *vProgIdr;
@property (nonatomic, readonly) UIProgressBar *vProgBarIdr, *vProgBarIdr2;
@property (nonatomic, readonly) UIActivityIndicatorExt *vActIdr;
@property (nonatomic, readonly) UIRingPercentageIndicator *vRingIdr;
@property (nonatomic, readonly) UIRingActivityIndicator *vRingAct;

@end

@implementation VPracticePercentage

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    _timer = [[NSTimerExt alloc] initWithRepeatInterval:1];
    [_timer.signals connect:kSignalTakeAction withSelector:@selector(actFire) ofTarget:self];
    
    [self addSubview:BLOCK_RETURN({
        _vProgIdr = [UIProgressView temporary];
        return _vProgIdr;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _vProgBarIdr = [UIProgressBar temporary];
        return _vProgBarIdr;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _vProgBarIdr2 = [UIProgressBar temporary];
        _vProgBarIdr2.brush = [CGSolidBrush Brush:[UIColor blueColor].CGColor];
        return _vProgBarIdr2;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _vActIdr = [UIActivityIndicatorExt temporary];
        return _vActIdr;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _vRingIdr = [UIRingPercentageIndicator temporary];
        return _vRingIdr;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _vRingAct = [UIRingActivityIndicator temporary];
        return _vRingAct;
    })];
}

- (void)onFin {
    ZERO_RELEASE(_timer);
    [super onFin];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    UIVBox* box = [UIVBox boxWithRect:rect];
    [box addPixel:_vProgIdr.bestHeight toView:_vProgIdr];
    [box addPixel:_vProgBarIdr.bestHeight toView:_vProgBarIdr];
    [box addPixel:_vProgBarIdr2.bestHeight toView:_vProgBarIdr2];
    [box addPixel:100 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_vActIdr];
        [box addFlex:1 toView:_vRingIdr];
        [box addFlex:1 toView:_vRingAct];
    }];
    [box apply];
}

- (void)actFire {
    int max = 10;
    if (++_cur > max)
        _cur = 1;
    NSPercentage* per = [NSPercentage percentWithMax:max value:_cur];
    
    [UIViewExt animateWithDuration:1 animations:^{
        _vProgIdr.percentage = per;
        _vProgBarIdr.percentage = per;
        _vRingIdr.percentage = per;
    }];
    
    _vProgBarIdr2.percentage = per;
}

@end

@implementation VCPracticePercentage

- (void)onInit {
    [super onInit];
    self.classForView = [VPracticePercentage class];
}

@end
