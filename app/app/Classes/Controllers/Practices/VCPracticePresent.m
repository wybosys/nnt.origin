
# import "app.h"
# import "VCPracticePresent.h"
# import "VCPracticeWidgets.h"

@interface VPracticePresent : UIViewExt

@property (nonatomic, readonly) VPracticeButton
*btnPre,
*btnDisall,
*btnDt
;

@end

@implementation VPracticePresent

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:BLOCK_RETURN({
        _btnPre = [VPracticeButton new];
        _btnPre.text = @"Present";
        return _btnPre;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnDisall = [VPracticeButton new];
        _btnDisall.text = @"Dismiss All";
        return _btnDisall;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnDt = [VPracticeButton new];
        _btnDt.text = @"DT";
        return _btnDt;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox* box = [UIVBox boxWithRect:rect withSpacing:5];
    [box addPixel:30 toView:_btnPre];
    [box addPixel:30 toView:_btnDisall];
    [box addPixel:30 toView:_btnDt];
    [box apply];
}

@end

@implementation VCPracticePresent

- (void)onInit {
    [super onInit];
    self.classForView = [VPracticePresent class];
}

- (void)onLoaded {
    [super onLoaded];
    
    self.navigationItem.leftBarButtonItem = BLOCK_RETURN({
        UIBarButtonItem* btn = [UIBarButtonItem itemWithTitle:@"🔵"];
        [btn.signals connect:kSignalClicked withSelector:@selector(goBack) ofTarget:self];
        return btn;
    });
    
    VPracticePresent* view = (id)self.view;
    [view.btnPre.signals connect:kSignalClicked withSelector:@selector(actPresent) ofTarget:self];
    [view.btnDisall.signals connect:kSignalClicked withSelector:@selector(actDisall) ofTarget:self];
    [view.btnDt.signals connect:kSignalClicked withSelector:@selector(actDt) ofTarget:self];
}

- (void)actPresent {
    VCPracticePresent* ctlr = [VCPracticePresent temporary];
    UINavigationController* navi = [UINavigationController navigationWithController:ctlr];
    [[UIAppDelegate shared] presentModalViewController:navi];
}

- (void)actDisall {
    [[UIAppDelegate shared] dismissAllModalViewControllersAnimated:YES];
}

- (void)actDt {
    [self goBack];
    
    UIDatePicker* dp = [UIDatePicker temporary];
    dp.backgroundColor = [UIColor whiteColor];
    UIPopoverDesktop* desk = [UIPopoverDesktop desktopWithView:dp];
    [desk open];
}

@end
