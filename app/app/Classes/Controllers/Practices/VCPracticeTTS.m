
# import "app.h"
# import "VCPracticeTTS.h"
# import "VCPracticeWidgets.h"
# import "NSSystemFeatures.h"

@interface VPracticeTTS : UIViewExt

@property (nonatomic, readonly) UITextViewExt *inpText;
@property (nonatomic, readonly) VPracticeButton *btnSpeak;

@end

@implementation VPracticeTTS

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:BLOCK_RETURN({
        _btnSpeak = [VPracticeButton temporary];
        _btnSpeak.text = @"SPEAK";
        return _btnSpeak;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _inpText = [UITextViewExt temporary];
        return _inpText;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox* box = [UIVBox boxWithRect:rect withSpacing:5];
    [box addPixel:30 toView:_btnSpeak];
    [box addFlex:1 toView:_inpText];
    [box apply];
}

@end

@implementation VCPracticeTTS

- (void)onInit {
    [super onInit];
    self.classForView = [VPracticeTTS class];
}

- (void)onLoaded {
    [super onLoaded];
    VPracticeTTS* view = (id)self.view;
    [view.btnSpeak.signals connect:kSignalClicked withSelector:@selector(actSpeak) ofTarget:self];
    
    self.navigationItem.rightBarButtonItem = BLOCK_RETURN({
        UIBarButtonItem* btn = [UIBarButtonItem itemWithTitle:@"结束编辑"];
        [btn.signals connect:kSignalClicked withBlock:^(SSlot *s) {
            [UIKeyboardExt Close];
        }];
        return btn;
    });
}

- (void)actSpeak {
    VPracticeTTS* view = (id)self.view;
    NSString* txt = view.inpText.text;
    [[NSTTSService shared] speak:txt];
}

@end
