
# import "app.h"
# import "VCPracticeAPPS.h"
# import "VCPracticeAPPRlt.h"

@interface VPracticeAPPS : UIScrollViewExt

@property (nonatomic, readonly) VPracticeButton
*btnRLT;

@end

@implementation VPracticeAPPS

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:BLOCK_RETURN({
        _btnRLT = [VPracticeButton temporary];
        _btnRLT.text = @"热力图";
        return _btnRLT;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    UIVBox* box = [UIVBox boxWithRect:rect withSpacing:5];
    [box addPixel:30 toView:_btnRLT];
    [box apply];
}

@end

@implementation VCPracticesAPPS

- (void)onInit {
    [super onInit];
    self.classForView = [VPracticeAPPS class];
}

- (void)onFin {
    [super onFin];
}

- (void)onLoaded {
    [super onLoaded];
    VPracticeAPPS* view = (id)self.view;
    [view.btnRLT.signals connect:kSignalClicked withSelector:@selector(actRLT) ofTarget:self];
}

- (void)actRLT {
    [self.navigationController pushViewController:[VCPracticeAPPRlt temporary]];
}

@end
