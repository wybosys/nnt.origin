
# import "app.h"
# import "AppDelegate.h"
# import "VCAppIndex.h"
# import "VCPracticeToolbox.h"
# import "PracticeSnsPlatform.h"
# import "NSSystemFeatures.h"

NSString* kAppIdOnAppstore = @"739706213";
NSString* kAppHomeURL = @"http://www.gamexhb.com";

@implementation AppDelegate

- (void)onLoaded {
    [super onLoaded];

    // 设置业务层的 sns 服务
    [PracticeSnsService SetAsDefault];
    
    // 需要自定义 back 按钮，可以激活 AT 的绑定    
    [UINavigationController SetNavigationItemHook:^(UINavigationController *navi, UIViewController *vc, UINavigationItem *item) {
        if (navi.viewControllers.count > 1)
        {
            item.leftBarButtonItem = BLOCK_RETURN({
                UIBarButtonItem* btn = [UIBarButtonItem itemWithTitle:@"< 返回"];
                [btn.signals connect:kSignalClicked withSelector:@selector(goBack) ofTarget:vc];
                return btn;
            });
        }
    }];
    
    self.rootViewController.view.layer.shadow = [[CGShadow LeftEdge] shadowWithOpacity:1 radius:5];
    
    [self.rootViewController pushViewControllerNoAnimated:[VCAppIndex temporary]];
    [self.container pushViewController:[VCPracticeToolbox temporary]];
    
    [self.container.signals connect:kSignalFloatingUpdating withSelector:@selector(cbFloatingUpdating:) ofTarget:self];
    [self.container.signals connect:kSignalFloatingFinaling withBlock:^(SSlot *s) {
        UIAppFloatingContainerTransiting* obj = s.data.object;
        if (obj.percent.x > .2)
            [obj complete];
        else
            [obj cancel];
    }];
}

- (void)cbFloatingUpdating:(SSlot*)s {
    UIAppFloatingContainerTransiting* obj = s.data.object;
    CGFloat percent = obj.percent.x;
    if (percent > 0.4)
        percent = 0.4;
    if (percent > 1)
        percent = 1;
    if (percent < 0)
        percent = 0;

    CGPoint pos = CGPointZero;
    CGRect rc = self.container.view.bounds;
    pos.x = rc.size.width * percent;
    
    /*
    CGAffineTransform mat = CGAffineTransformIdentity;
    mat = CGAffineTransformTranslate(mat, pos.x, 0);
    mat = CGAffineTransformScale(mat, 1 - percent * .3, 1 - percent * .3);
     */
    
    CATransform3D mat3d = CATransform3DIdentity;
    mat3d = CATransform3DTranslate(mat3d, pos.x, 0, 0);
    mat3d = CATransform3DScale(mat3d, 1 - percent * .3, 1 - percent * .3, 1);
    mat3d = CATransform3DRotate(mat3d, M_2PI * percent / 0.4, 0, 1, 1);
    
    obj.to.view.layer.zPosition = -1000;
    [UIView animateWithDuration:.3 animations:^{
        //obj.from.view.transform = mat;
        obj.from.view.layer.transform = mat3d;
    }];
    
    obj.percent = CGPointMake(percent, 0);
}

- (void)onActived {
    [super onActived];    
    ++[NSAppBadgeService shared].value;
}

@end
