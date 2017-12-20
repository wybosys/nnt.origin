
# import "app.h"
# import "VCPracticeSegment.h"
# import "VCPracticeScroll.h"

@interface VPracticeSegmentButton : UISegmentTabButton

@end

@implementation VPracticeSegmentButton

- (void)onInit {
    [super onInit];
    self.textColor = [UIColor whiteColor];
    self.selectedTextColor = [UIColor redColor];
}

- (void)setIsSelection:(BOOL)isSelection {
    [super setIsSelection:isSelection];
    self.selected = isSelection;
}

@end

@implementation VCPracticeSegment

- (void)onInit {
    [super onInit];
    self.classForButton = [VPracticeSegmentButton class];
    self.tabsOnScreen = 3;
    self.tabHeight = 40;
}

- (void)onLoaded {
    [super onLoaded];
    
    VCPracticeSimpleScroll* s0 = [VCPracticeSimpleScroll new];
    VCPracticeSimpleScroll* s1 = [VCPracticeSimpleScroll new];
    VCPracticeSimpleScroll* s2 = [VCPracticeSimpleScroll new];
    
    s0.title = @"S0";
    s1.title = @"S1";
    s2.title = @"S2";
    
    ((UIScrollView*)s0.view).skipsNavigationBarInsetsAdjust = YES;
    ((UIScrollView*)s1.view).skipsNavigationBarInsetsAdjust = YES;
    ((UIScrollView*)s2.view).skipsNavigationBarInsetsAdjust = YES;
    
    self.viewControllers = @[
                             s0,
                             s1,
                             s2
                             ];
    self.tabbar.selectedIndex = 0;
}

@end
