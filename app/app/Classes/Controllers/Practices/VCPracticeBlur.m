
# import "app.h"
# import "VCPracticeBlur.h"

@interface VPracticeBlur : UIViewExt

@property (nonatomic, readonly) UIImageViewExt *imgImage, *imgBlur;
@property (nonatomic, readonly) UIButtonExt *btnAni;
@property (nonatomic, readonly) UISlider *sldRadius, *sldSaut;
@property (nonatomic, readonly) UISyncBlurView *vBlur;

@end

@implementation VPracticeBlur

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:BLOCK_RETURN({
        _imgImage = [UIImageViewExt temporary];
        _imgImage.contentMode = UIViewContentModeScaleAspectFill;
        _imgImage.imageDataSource = @"http://image.zcool.com.cn/2013/16/26/1371454149868.jpg";
        return _imgImage;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _imgBlur = [UIImageViewExt temporary];
        _imgBlur.contentMode = UIViewContentModeScaleAspectFill;
        _imgBlur.imageDataSource = @"http://image.zcool.com.cn/2013/16/26/1371454149868.jpg";
        _imgBlur.imageBlur = [CGBlur Dark];
        return _imgBlur;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnAni = [UIButtonExt temporary];
        _btnAni.backgroundColor = [UIColor randomColor];
        _btnAni.text = @"ANI";
        return _btnAni;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _sldRadius = [UISlider temporary];
        _sldRadius.minimumValue = 0;
        _sldRadius.maximumValue = 100;
        _sldRadius.value = 20;
        return _sldRadius;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _sldSaut = [UISlider temporary];
        _sldSaut.minimumValue = 0;
        _sldSaut.maximumValue = 10;
        _sldSaut.value = 1;
        return _sldSaut;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _vBlur = [UISyncBlurView temporary];
        _vBlur.frame = CGRectMake(0, 100, 100, 100);
        _vBlur.layer.border = [CGLine lineWithWidth:2];
        _vBlur.blur = [CGBlur Dark];
        //_vBlur.viewForBlur = _imgImage;
        [[UIDragManager shared] add:_vBlur];
        return _vBlur;
    })];
}

- (void)onFin {
    [[UIDragManager shared] remove:_vBlur];
    [super onFin];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox* box = [UIVBox boxWithRect:rect withSpacing:5];
    [box addFlex:1 toView:_imgBlur];
    [box addFlex:1 toView:_imgImage];
    [box addPixel:30 toView:_sldRadius];
    [box addPixel:30 toView:_sldSaut];
    [box addPixel:30 toView:_btnAni];
    [box apply];
}

@end

@implementation VCPracticeBlur

- (void)onInit {
    [super onInit];
    self.classForView = [VPracticeBlur class];
    self.enableContainerGesture = NO;
}

- (void)onLoaded {
    [super onLoaded];
    
    VPracticeBlur* view = (id)self.view;
    view.vBlur.belongViewController = self;
    
    [view.sldRadius.signals connect:kSignalValueChanged withSelector:@selector(actBlurChagned:) ofTarget:self];
    [view.sldSaut.signals connect:kSignalValueChanged withSelector:@selector(actBlurChagned:) ofTarget:self];
    [view.btnAni.signals connect:kSignalClicked withSelector:@selector(actAni) ofTarget:self];
}

- (void)actBlurChagned:(SSlot*)s {
    VPracticeBlur* view = (id)self.view;
    CGBlur* br = [CGBlur temporary];
    br.tintColor = [UIColor colorWithWhite:1 alpha:.3].CGColor;
    br.radius = view.sldRadius.value;
    br.saturation = view.sldSaut.value;
    view.imgImage.imageBlur = br;
}

- (void)actAni {
    VPracticeBlur* view = (id)self.view;
    CGBlur* br = [CGBlur temporary];
    br.tintColor = [UIColor colorWithWhite:1 alpha:.3].CGColor;
    br.saturation = view.sldSaut.value;
    
    CAAnimationProducer* ap = [CAAnimationProducer new];
    ap.duration = 0.3;
    [ap.signals connect:kSignalValueChanged withBlock:^(SSlot *s) {
        float r = [s.data.object floatValue];
        br.radius = view.sldRadius.value * r;
        
        [NSPerformanceMeasure measure:^{
            view.imgImage.imageBlur = br;
        }];
    }];
    [ap start];
}

@end
