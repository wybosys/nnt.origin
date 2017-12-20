
# import "app.h"
# import "VCPracticeOpenURL.h"

@interface VPracticeOpenURL : UIViewExt

@property (nonatomic, readonly) UITextViewExt *inpUrl;
@property (nonatomic, readonly) VPracticeButton
*btnCheck,
*btnOpen,
*btnDownload;

@end

@implementation VPracticeOpenURL

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:BLOCK_RETURN({
        _inpUrl = [UITextViewExt temporary];
        _inpUrl.placeholder = @"URL";
        _inpUrl.text = @"https://itunes.apple.com/cn/app/you-xi-xiao-huo-ban/id739706213?mt=8";
        return _inpUrl;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnCheck = [VPracticeButton temporary];
        _btnCheck.text = @"Check";
        return _btnCheck;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnOpen = [VPracticeButton temporary];
        _btnOpen.text = @"Open";
        return _btnOpen;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnDownload = [VPracticeButton temporary];
        _btnDownload.text = @"Download";
        return _btnDownload;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    UIVBox *box = [UIVBox boxWithRect:rect withSpacing:5];
    [box addPixel:100 toView:_inpUrl];
    [box addPixel:30 toView:_btnCheck];
    [box addPixel:30 toView:_btnOpen];
    [box addPixel:30 toView:_btnDownload];
    [box apply];
}

@end

@implementation VCPracticeOpenURL

- (void)onInit {
    [super onInit];
    self.attributes.navigationBarDodge = YES;
    self.classForView = [VPracticeOpenURL class];
}

- (void)onLoaded {
    [super onLoaded];
    VPracticeOpenURL* view = (id)self.view;
    [view.btnCheck.signals connect:kSignalClicked withSelector:@selector(actCheck) ofTarget:self];
    [view.btnOpen.signals connect:kSignalClicked withSelector:@selector(actOpen) ofTarget:self];
    [view.btnDownload.signals connect:kSignalClicked withSelector:@selector(actDownload) ofTarget:self];
}

- (void)actCheck {
    VPracticeOpenURL* view = (id)self.view;
    NSString* inp = view.inpUrl.text;
    if ([[UIApplication sharedApplication] canOpenURLString:inp]) {
        [UIHud Success:@"Ok"];
    } else {
        [UIHud Failed:@"Failed"];
    }
}

- (void)actOpen {
    VPracticeOpenURL* view = (id)self.view;
    NSString* inp = view.inpUrl.text;
    [[UIApplication sharedApplication] openURLString:inp];
}

- (void)actDownload {
    VPracticeOpenURL* view = (id)self.view;
    NSString* inp = view.inpUrl.text;
    NSRegularExpression* rx = [NSRegularExpression AppUrlOnAppstore];
    if ([rx isMatchs:inp])
    {
        NSArray* res = [rx capturesInString:inp];
        [[UIApplication sharedApplication] goAppstoreHome:res.secondObject];
    }
    else
    {
        [UIHud Noti:@"不符合 appstore 的默认格式，直接打开"];
        [[UIApplication sharedApplication] openURLString:inp];
    }
}

@end
