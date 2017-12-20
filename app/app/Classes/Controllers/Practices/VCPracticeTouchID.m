
# import "app.h"
# import "VCPracticeTouchID.h"
# import "NSSystemFeatures.h"
# import "VCPracticeWidgets.h"

@interface VPracticeTouchID : UIViewExt

@property (nonatomic, readonly) VPracticeButton
*btnAuth
;

@end

@implementation VPracticeTouchID

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:BLOCK_RETURN({
        _btnAuth = [VPracticeButton temporary];
        _btnAuth.text = @"授权";
        return _btnAuth;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox* box = [UIVBox boxWithRect:rect withSpacing:5];
    [box addPixel:30 toView:_btnAuth];
    [box apply];
}

@end

@implementation VCPracticeTouchID

- (void)onInit {
    [super onInit];
    self.classForView = [VPracticeTouchID class];
}

- (void)onLoaded {
    [super onLoaded];
    
    if ([NSTouchIDService isAvaliable] == NO) {
        UILabelExt* lbl = [UILabelExt temporary];
        lbl.text = @"TouchID 不可用";
        lbl.backgroundColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentCenter;
        self.view.overlapWidget = lbl;
        return;
    }
    
    VPracticeTouchID* view = (id)self.view;
    [view.btnAuth.signals connect:kSignalClicked withSelector:@selector(actAuth) ofTarget:self];
}

- (void)actAuth {
    NSTouchIDService* ti = [NSTouchIDService shared];
    [ti.signals connect:kSignalSucceed withBlock:^(SSlot *s) {
        [UIHud Text:@"SUCCESSED"];
    }];
    [ti.signals connect:kSignalFailed withBlock:^(SSlot *s) {
        [UIHud Text:@"FAILED"];
    }];
    [ti.signals connect:kSignalTakeAction withBlock:^(SSlot *s) {
        [UIHud Text:@"请求输入密码"];
    }];
    [ti authorize];
}

@end
