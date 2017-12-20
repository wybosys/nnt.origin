
# import "app.h"
# import "VCPracticeContent.h"

@interface VPracticeContent : UIViewExt

@end

@implementation VPracticeContent

- (void)onInit {
    [super onInit];
}

- (void)onFin {
    [super onFin];
}

@end

@implementation VCPracticeContent

- (void)onInit {
    [super onInit];
    self.classForView = [VPracticeContent class];
}

- (void)onFin {
    [super onFin];
}

@end
