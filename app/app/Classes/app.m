
# import "app.h"
# import "UIPercentageWidgets.h"

@implementation UIButtonExt (hdapp)

+ (instancetype)button {
    UIButtonExt* ret = [UIButtonExt temporary];
    ret.backgroundColor = [UIColor randomColor];
    ret.textColor = [UIColor randomColor];
    return ret;
}

@end

@implementation VPracticeButton

- (void)onInit {
    [super onInit];
    
    CGLine* edl = [CGLine lineWithColor:[UIColor blackColor].CGColor];
    self.textColor = [UIColor blackColor];
    self.layer.border = edl;
}

@end

@implementation VPracticeImage

- (void)onInit {
    [super onInit];
    self.classForFetchingIdentifier = [UIRingPercentageIndicator class];
}

@end
