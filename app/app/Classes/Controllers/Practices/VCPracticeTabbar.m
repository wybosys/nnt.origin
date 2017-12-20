
# import "app.h"
# import "VCPracticeTabbar.h"
# import "VCPracticeTable.h"

@implementation VCPracticeTabbar

- (void)onInit {
    [super onInit];
    
    self.hidesTopBarWhenPushed = YES;
    
    VCPracticeSimpleTable *tb0 = [VCPracticeSimpleTable temporary];
    VCPracticeSimpleTable *tb1 = [VCPracticeSimpleTable temporary];
    VCPracticeSimpleTable *tb2 = [VCPracticeSimpleTable temporary];
    
    tb0.title = @"tb0";
    tb1.title = @"tb1";
    tb2.title = @"tb2";
    
    UINavigationControllerExt *nav0 = [UINavigationControllerExt navigationWithController:tb0];
    UINavigationControllerExt *nav1 = [UINavigationControllerExt navigationWithController:tb1];
    UINavigationControllerExt *nav2 = [UINavigationControllerExt navigationWithController:tb2];
    
    nav0.tabBarItem = [UITabBarItem itemWithTitle:tb0.title];
    nav1.tabBarItem = [UITabBarItem itemWithTitle:tb1.title];
    nav2.tabBarItem = [UITabBarItem itemWithTitle:tb2.title];
    
    self.viewControllers = @[nav0,
                             nav1,
                             nav2
                             ];
}

- (void)onLoaded {
    [super onLoaded];
    self.tabBar.edgeShadow = [CGShadow TopEdge];
    [self.signals connect:kSignalSelectionChanged withBlock:^(SSlot *s) {
        UIViewController* ctlr = s.data.object;
        ctlr.tabBarItem.badgeValue = @(ctlr.tabBarItem.badgeValue.intValue + 1).stringValue;
    }];
}

@end
