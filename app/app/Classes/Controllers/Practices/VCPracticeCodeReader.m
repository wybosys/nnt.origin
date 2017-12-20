
# import "app.h"
# import "VCPracticeCodeReader.h"

@interface VPracticeCodeReader : UIViewExt

@property (nonatomic, readonly) UIBarCodeScanner *coder;

@end

@implementation VPracticeCodeReader

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSub:BLOCK_RETURN({
        _coder = [UIBarCodeScanner new];
        return _coder;
    })];
    
    self.paddingEdge = CGPaddingMake(10, 10, 10, 10);
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    _coder.view.frame = rect;
}

@end

@implementation VCPracticeCodeReader

- (void)onInit {
    [super onInit];
    self.title = @"Code Reader";
    self.hidesBottomBarWhenPushed = YES;
    self.classForView = [VPracticeCodeReader class];
}

- (void)onLoaded {
    [super onLoaded];
    
    VPracticeCodeReader* view = (id)self.view;
    [view.coder.signals connect:kSignalValueChanged withBlock:^(SSlot *s) {
        for (NSBarCode* each in s.data.object) {
            LOG(each.data.UTF8String);
        }
        
        [view.coder start];
    }];
}

@end
