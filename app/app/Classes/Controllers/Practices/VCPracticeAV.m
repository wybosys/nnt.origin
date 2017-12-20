
# import "app.h"
# import "VCPracticeAV.h"
# import "Audio+Extension.h"
# import "VCPracticeWidgets.h"
# import "UICamera.h"

@interface VPracticeAV : UIScrollViewExt

@property (nonatomic, readonly) UILabelExt *btnAudio, *btnPlayAu;
@property (nonatomic, readonly) UIProgressView *prgPlay;
@property (nonatomic, readonly) UIActivityIndicatorView *actDoing;
@property (nonatomic, readonly) UITextFieldExt* inpVoice;
@property (nonatomic, readonly) UICamera* vCamera;

@end

@implementation VPracticeAV

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:BLOCK_RETURN({
        _btnAudio = [UILabelExt new];
        _btnAudio.backgroundColor = [UIColor blueColor];
        _btnAudio.textAlignment = NSTextAlignmentCenter;
        _btnAudio.textColor = [UIColor whiteColor];
        
        _btnAudio.states = @{
                             @"stop": [UIString string:@"Start Record"] COMMA
                             @"recording": [UIString string:@"Stop Record"]
                             };
        
        _btnAudio.currentState = @"stop";
        return _btnAudio;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnPlayAu = [UILabelExt new];
        _btnPlayAu.backgroundColor = [UIColor blueColor];
        _btnPlayAu.textAlignment = NSTextAlignmentCenter;
        _btnPlayAu.textColor = [UIColor whiteColor];
        
        _btnPlayAu.states = @{@"stop": [UIString string:@"Play"] COMMA
                              @"playing": [UIString string:@"Stop"]
                              };
        _btnPlayAu.currentState = @"stop";
        return _btnPlayAu;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _actDoing = [UIActivityIndicatorView Gray];
        return _actDoing;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _prgPlay = [UIProgressView Default];
        return _prgPlay;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _inpVoice = [UITextFieldExt temporary];
        _inpVoice.placeholder = @"语音输入";
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeInfoDark];
        btn.size = CGSizeMake(20, 20);
        btn.text = @"语音";
        _inpVoice.rightView = btn;
        _inpVoice.rightViewMode = UITextFieldViewModeAlways;
        return _inpVoice;
    })];
    
    [self addSub:BLOCK_RETURN({
        _vCamera = [UICamera temporary];
        return _vCamera;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox* box = [UIVBox boxWithRect:rect withSpacing:5];
    [box addPixel:30 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_btnAudio];
        [box addPixel:60 toView:_btnPlayAu];
    }];
    [box addPixel:20 HBox:^(UIHBox *box) {
        [box addAspectWithX:1 andY:1 toView:_actDoing];
        [box addFlex:1 toView:_prgPlay];
    }];
    [box addPixel:30 toView:_inpVoice];
    [box addFlex:1 toView:_vCamera.view];
    [box apply];
}

@end

@interface VCPracticeAV ()

@property (nonatomic, readonly) MMAudioRecorder *ar;
@property (nonatomic, readonly) MMAudioPlayer *ap;

@end

@implementation VCPracticeAV

- (void)onInit {
    [super onInit];
    self.hidesBottomBarWhenPushed = YES;
    self.title = @"Audio Video";
    self.classForView = [VPracticeAV class];
    
    _ar = [MMAudioRecorder new];
    _ar.timeMinimum = 5;
    _ar.timeMaximum = 10;
    
    _ap = [MMAudioPlayer new];
    _ap.recorder = _ar;
}

- (void)onLoaded {
    [super onLoaded];
    
    VPracticeAV* view = (id)self.view;
    [view.btnAudio.signals connect:kSignalClicked withSelector:@selector(start) ofTarget:_ar];
    [view.btnPlayAu.signals connect:kSignalClicked withSelector:@selector(start) ofTarget:_ap];
    
    [_ar.signals connect:kSignalStart withBlock:^(SSlot *s) {
        view.btnAudio.currentState = @"recording";
        view.actDoing.animating = YES;
        [view.btnAudio.signals disconnect:kSignalClicked withSelector:@selector(start) ofTarget:_ar];
        [view.btnAudio.signals connect:kSignalClicked withSelector:@selector(stop) ofTarget:_ar];
    }];
    
    [_ar.signals connect:kSignalStop withBlock:^(SSlot *s) {
        view.btnAudio.currentState = @"stop";
        view.actDoing.animating = NO;
        [view.btnAudio.signals disconnect:kSignalClicked withSelector:@selector(stop) ofTarget:_ar];
        [view.btnAudio.signals connect:kSignalClicked withSelector:@selector(start) ofTarget:_ar];
    }];
    
    [_ap.signals connect:kSignalStart withBlock:^(SSlot *s) {
        view.btnPlayAu.currentState = @"playing";
        [view.btnPlayAu.signals disconnect:kSignalClicked withSelector:@selector(start) ofTarget:_ap];
        [view.btnPlayAu.signals connect:kSignalClicked withSelector:@selector(stop) ofTarget:_ap];
    }];
    
    [_ap.signals connect:kSignalStop withBlock:^(SSlot *s) {
        view.btnPlayAu.currentState = @"stop";
        [view.btnPlayAu.signals disconnect:kSignalClicked withSelector:@selector(stop) ofTarget:_ap];
        [view.btnPlayAu.signals connect:kSignalClicked withSelector:@selector(start) ofTarget:_ap];
    }];
    
    [_ap.signals connect:kSignalValueChanged withBlock:^(SSlot *s) {
        view.prgPlay.percentage = s.data.object;
    }];
    
    [view.inpVoice.rightView.signals connect:kSignalClicked withSelector:@selector(actVoiceInput) ofTarget:self];
}

- (void)actVoiceInput {
    VPracticeAV* view = (id)self.view;
    MMVoiceInput* vi = [MMVoiceInput temporary];
    [vi.signals connect:kSignalValueChanged withBlock:^(SSlot *s) {
        view.inpVoice.text = s.data.object;
    }];
    [vi execute];
}

@end
