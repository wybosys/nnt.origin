
# import "app.h"
# import "VCPracticeANimationProducer.h"
# import "VCPracticeWidgets.h"

@interface VPracticeAnimationProducer : UIViewExt

@property (nonatomic, readonly) VPracticeButton
*btnLinear,
*btnEout,
*btnEin,
*btnEinout,
*btnSpring,
*btnCustom
;

@property (nonatomic, readonly) UITextFieldExt *inpCustom;

@property (nonatomic, readonly) UISketchView* vSk;
@property (nonatomic, readonly) UIView *vIdr;

@end

@implementation VPracticeAnimationProducer

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:BLOCK_RETURN({
        _btnLinear = [VPracticeButton temporary];
        _btnLinear.text = @"Linear";
        return _btnLinear;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnEout = [VPracticeButton temporary];
        _btnEout.text = @"E out";
        return _btnEout;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnEin = [VPracticeButton temporary];
        _btnEin.text = @"E in";
        return _btnEin;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnEinout = [VPracticeButton temporary];
        _btnEinout.text = @"E in-out";
        return _btnEinout;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnSpring = [VPracticeButton temporary];
        _btnSpring.text = @"Spring";
        return _btnSpring;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnCustom = [VPracticeButton temporary];
        _btnCustom.text = @"Custom";
        return _btnCustom;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _inpCustom = [UITextFieldExt temporary];
        _inpCustom.borderStyle = UITextBorderStyleLine;
        _inpCustom.placeholder = @"x1 y1 x2 y2";
        return _inpCustom;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _vSk = [UISketchView temporary];
        return _vSk;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _vIdr = [UIView temporary];
        _vIdr.frame = CGRectMake(0, 0, 10, 10);
        _vIdr.backgroundColor = [UIColor blueColor];
        [_vIdr.layer roundlize];
        return _vIdr;
    })];
}

- (void)onFin {
    [super onFin];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox* box = [UIVBox boxWithRect:rect withSpacing:5];
    [box addPixel:30 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_btnLinear];
        [box addFlex:1 toView:_btnEout];
        [box addFlex:1 toView:_btnEin];
        [box addFlex:1 toView:_btnEinout];
    }];
    [box addPixel:30 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_btnSpring];
    }];
    [box addPixel:30 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_inpCustom];
        [box addPixel:100 toView:_btnCustom];
    }];
    [box addFlex:1 toView:_vSk];
    [box apply];
}

@end

@interface VCPracticeAnimationProducer ()
{
    CGPoint _pos;
    CGPrimitiveLine* _line;
}

@end

@implementation VCPracticeAnimationProducer

- (void)onInit {
    [super onInit];
    self.classForView = [VPracticeAnimationProducer class];
}

- (void)onLoaded {
    [super onLoaded];
    
    VPracticeAnimationProducer* view = (id)self.view;
    [view.btnLinear.signals connect:kSignalClicked withSelector:@selector(actLinear) ofTarget:self];
    [view.btnEout.signals connect:kSignalClicked withSelector:@selector(actEout) ofTarget:self];
    [view.btnEin.signals connect:kSignalClicked withSelector:@selector(actEin) ofTarget:self];
    [view.btnEinout.signals connect:kSignalClicked withSelector:@selector(actEinout) ofTarget:self];
    [view.btnSpring.signals connect:kSignalClicked withSelector:@selector(actSpring) ofTarget:self];
    [view.btnCustom.signals connect:kSignalClicked withSelector:@selector(actCustom) ofTarget:self];
    
    _line = [CGPrimitiveLine temporary];
    _line.pen = [CGPen Pen:[UIColor blackColor].CGColor width:1];
    [view.vSk.sketch add:_line];
}

- (void)actLinear {
    [CAAnimationProducer animates:^(CAAnimationProducer *ap) {
        [self clear];
        
        ap.duration = 1;
        ap.timefunction = kCAMediaTimingFunctionLinear;
    } progress:^(float p, float d) {
        [self cbAP:p];
    }];
}

- (void)actEout {
    [CAAnimationProducer animates:^(CAAnimationProducer *ap) {
        [self clear];
        
        ap.duration = 1;
        ap.timefunction = kCAMediaTimingFunctionEaseOut;
    } progress:^(float p, float d) {
        [self cbAP:p];
    }];
}

- (void)actEin {
    [CAAnimationProducer animates:^(CAAnimationProducer *ap) {
        [self clear];
        
        ap.duration = 1;
        ap.timefunction = kCAMediaTimingFunctionEaseIn;
    } progress:^(float p, float d) {
        [self cbAP:p];
    }];
}

- (void)actEinout {
    [CAAnimationProducer animates:^(CAAnimationProducer *ap) {
        [self clear];
        
        ap.duration = 1;
        ap.timefunction = kCAMediaTimingFunctionEaseInEaseOut;
    } progress:^(float p, float d) {
        [self cbAP:p];
    }];
}

- (void)actSpring {
    [CAAnimationProducer animates:^(CAAnimationProducer *ap) {
        [self clear];
        
        ap.keyname = @"spring";
        ap.duration = 1;
        ap.timefunction = kCAMediaTimingFunctionSpring;
    } progress:^(float p, float d) {
        [self cbAP:p];
    }];
}

- (void)actCustom {
    [CAAnimationProducer animates:^(CAAnimationProducer *ap) {
        [self clear];
        
        VPracticeAnimationProducer* view = (id)self.view;
        NSString* prop = view.inpCustom.text;
        NSArray* vals = [prop componentsSeparatedByString:@" "];
        ap.controlPointA = CGPointMake([vals.firstObject floatValue], [vals.secondObject floatValue]);
        ap.controlPointB = CGPointMake([vals.thirdObject floatValue], [vals.fourthObject floatValue]);
        
        ap.duration = 1;
        ap.timefunction = kCAMediaTimingFunctionCustom;
    } progress:^(float p, float d) {
        [self cbAP:p];
    }];
}

- (void)clear {
    [_line reset];
    _pos = CGPointZero;
}

- (void)cbAP:(float)p {
    VPracticeAnimationProducer* view = (id)self.view;
    CGRect rc = CGRectDeflate(view.vSk.bounds, 10, 50);
    
    _pos.x += rc.size.width / 60;
    _pos.y = rc.size.height - rc.size.height * p + 50;
    [_line add:_pos];
    [view.vSk setNeedsDisplay];
    
    CGPoint pt = view.vSk.position;
    pt = CGPointAddPoint(pt, CGPointMake(rc.size.width*p, rc.origin.y + rc.size.height/2));
    view.vIdr.position = pt;
}

@end
