
# import "app.h"
# import "VCPracticeAPPRlt.h"
# import "NSSystemFeatures.h"

@interface VPracticeAppRlt : UIViewExt

@property (nonatomic, readonly) UIWebViewController *ctlrWeb;

@end

@implementation VPracticeAppRlt

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubcontroller:BLOCK_RETURN({
        _ctlrWeb = [UIWebViewController temporary];
        _ctlrWeb.simulateNativeApp = YES;
        _ctlrWeb.enableContainerGesture = NO;
        return _ctlrWeb;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    UIVBox* box = [UIVBox boxWithRect:rect];
    [box addFlex:1 toView:_ctlrWeb.view];
    [box apply];
}

@end

@implementation VCPracticeAPPRlt

- (void)onInit {
    [super onInit];
    self.classForView = [VPracticeAppRlt class];
}

- (BOOL)enableContainerGesture {
    return NO;
}

- (BOOL)panToBack {
    return NO;
}

- (void)onLoaded {
    [super onLoaded];
    
    VPracticeAppRlt* view = (id)self.view;
    view.ctlrWeb.requestURL = [NSBundle URLForFileNamed:@"apprlt.bundle/index.html"];
    [view.ctlrWeb.signals connect:kSignalContentLoaded withSelector:@selector(cbLoaded) ofTarget:self];
}

- (void)cbLoaded {
    // 获得到经纬度，绘制到球面
    NSLocationService* ls = [NSLocationService temporary];
    [ls.signals connect:kSignalLocationChanged withSelector:@selector(cbLocation:) ofTarget:self];
    [ls fetch];
}

- (void)cbLocation:(SSlot*)s {
    NSLocationInfo* li = s.data.object;
    VPracticeAppRlt* view = (id)self.view;
    [view.ctlrWeb.webView runJavascript:[NSString stringWithFormat:@"addHot(%f, %f)", li.locationValue.coordinate.longitude, li.locationValue.coordinate.latitude]];
}

@end
