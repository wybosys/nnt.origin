
# import "app.h"
# import "VCPracticeAppDownload.h"

@interface VPracticeAppDownload : UIViewExt

@property (nonatomic, readonly) UITextFieldExt *inpId;
@property (nonatomic, readonly) VPracticeButton *btnDownload;

@end

@implementation VPracticeAppDownload

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:BLOCK_RETURN({
        _inpId = [UITextFieldExt temporary];
        _inpId.text = @"739706213";
        _inpId.borderStyle = UITextBorderStyleLine;
        return _inpId;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnDownload = [VPracticeButton temporary];
        _btnDownload.text = @"DOWNLOAD";
        return _btnDownload;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    UIVBox* box = [UIVBox boxWithRect:rect withSpacing:5];
    [box addPixel:40 toView:_inpId];
    [box addPixel:30 toView:_btnDownload];
    [box apply];
}

@end

@implementation VCPracticeAppDownload

- (void)onInit {
    [super onInit];
    self.classForView = [VPracticeAppDownload class];
}

- (void)onFin {
    [super onFin];
}

- (void)onLoaded {
    [super onLoaded];
    VPracticeAppDownload* view = (id)self.view;
    [view.btnDownload.signals connect:kSignalClicked withSelector:@selector(actDownload) ofTarget:self];
}

- (void)actDownload {
    VPracticeAppDownload* view = (id)self.view;
    [[UIApplication shared] goAppstoreHome:view.inpId.text];
}

@end
