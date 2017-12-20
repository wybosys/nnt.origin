
# import "app.h"
# import "VCPracticeSystemLog.h"
# import "NSSystemFeatures.h"

@interface VPracticeSystemLog : UIViewExt

@property (nonatomic, readonly) UITextViewExt *txtAll;

@end

@implementation VPracticeSystemLog

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:BLOCK_RETURN({
        _txtAll = [UITextViewExt temporary];
        _txtAll.readonly = YES;
        return _txtAll;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    _txtAll.frame = rect;
}

@end

@implementation VCPracticeSystemLog

- (void)onInit {
    [super onInit];
    self.classForView = [VPracticeSystemLog class];
}

- (void)onLoaded {
    [super onLoaded];
    
    NSArray* arr = [[NSSystemLogService shared] logsForLevel:kNSSystemLogLevelAll];
    VPracticeSystemLog* view = (id)self.view;
    view.txtAll.text = [arr componentsJoinedByString:@"\n"];
}

@end
