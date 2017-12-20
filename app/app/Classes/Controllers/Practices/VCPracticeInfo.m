
# import "app.h"
# import "VCPracticeInfo.h"

@interface VPracticeInfo : UITextViewExt

@end

@implementation VPracticeInfo

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
}

@end

@implementation VCPracticeInfo

- (void)onInit {
    [super onInit];
    self.classForView = [VPracticeInfo class];
}

- (void)onFirstAppeared {
    [super onFirstAppeared];
    VPracticeInfo* view = (id)self.view;
    NSMutableString* str = [NSMutableString string];
    
    [str appendFormat:@"DeviceIdr: %@", [UIDevice UniqueIdentifier]];
    [str appendString:@"\n"];
    
    view.text = str;
}

@end
