
# import "Common.h"
# import "AppDelegate+Extension.h"
# import "NSCron.h"
# import "Objc+Extension.h"
# import "UITypes+Swizzle.h"
# import "NSTypes+Swizzle.h"
# import "CATypes+Swizzle.h"
# import "FileSystem+Extension.h"
# import "Network+Extension.h"
# import "SDWebImageManager.h"
# import "AppContext.h"
# import "AppSpoor.h"
# import <AssetsLibrary/AssetsLibrary.h>

# ifdef DEVELOP_MODE
# import "AutoTestSuite.h"
# endif

CGFloat kUIStatusBarFontSize = 11.5;

@interface UIStatusBarExtOperation : NSObject

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) UIView *content;
@property (nonatomic, assign) CGFloat duration;

@end

@implementation UIStatusBarExtOperation

- (void)dealloc {
    ZERO_RELEASE(_text);
    ZERO_RELEASE(_content);
    [super dealloc];
}

@end

@interface UIStatusBarExt ()
{
    NSMutableArray* _sckHiddens;
}

@property (nonatomic, readonly) NSMutableArray *operations;

@end

@implementation UIStatusBarExt

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    _operations = [[NSMutableArray alloc] init];
    _sckHiddens = [[NSMutableArray alloc] init];
    // 最初的状态是显示电池栏
    [_sckHiddens push:@(YES)];
    
    _labelTitle = [[UILabelExt alloc] init];
    [self addSubview:_labelTitle];
    SAFE_RELEASE(_labelTitle);
    
    _labelTitle.textFont = [UIFont boldSystemFontOfSize:kUIStatusBarFontSize];
    _labelTitle.textAlignment = NSTextAlignmentCenter;
    
    // 判断一下有没有在 plist 中打开响应控制的选项
# ifdef IOS8_FEATURES
    if (kIOS8Above) {
        NSDictionary *dictInfo = [[NSBundle mainBundle] infoDictionary];
        if ([dictInfo exists:@"UIViewControllerBasedStatusBarAppearance"] == NO)
            FATAL("iOS8 需要在 Info.plist 里面写一个 UIViewControllerBasedStatusBarAppearance 的 FALSE，用来打开手动控制电池栏外观的功能");
    }
# endif
    
    self.userInteractionEnabled = NO;
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_operations);
    ZERO_RELEASE(_sckHiddens);
    [super dealloc];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize bsz = _labelTitle.bestSize;
    CGRect rc = self.bounds;
    rc.size.height = bsz.height;
    rc.origin.y += 3;
    
    UIHBox* box = [UIHBox boxWithRect:rc];
    [box addFlex:1 toView:nil];
    [box addPixel:[@"XX:XX AM" sizeWithFont:_labelTitle.textFont].width toView:nil];
    [box addFlex:1 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_labelTitle];
        [box addPixel:50 toView:nil];
    }];
    [box apply];
}

- (void)addOperation:(UIStatusBarExtOperation*)operation {
    SYNCHRONIZED_BEGIN
    [_operations addObject:operation];
    
    if (_operations.count == 1)
        [self doOperation:_operations.firstObject];
    SYNCHRONIZED_END
}

- (void)show:(NSString*)text duration:(NSTimeInterval)duration {
    UIStatusBarExtOperation* ope = [UIStatusBarExtOperation temporary];
    ope.text = text;
    ope.duration = duration;
    [self addOperation:ope];
}

- (void)display:(UIView*)view duration:(NSTimeInterval)duration {
    UIStatusBarExtOperation* ope = [UIStatusBarExtOperation temporary];
    ope.content = view;
    ope.duration = duration;
    [self addOperation:ope];
}

- (void)doOperation:(UIStatusBarExtOperation*)operation {
    if (operation == nil)
        return;
    
    CGRect rc = [UIApplication sharedApplication].statusBarFrame;
    self.frame = rc;
    
    UIColor *textColor = nil, *bkgColor = nil;
    switch ([UIApplication sharedApplication].statusBarStyle)
    {
        case UIStatusBarStyleLightContent: {
            textColor = [UIColor whiteColor];
            bkgColor = [UIColor blackColor];
        } break;
        default: {
            textColor = [UIColor blackColor];
            bkgColor = [UIColor whiteColor];
        } break;
    }
    
    //[self makeKeyAndVisible];
    self.visible = YES;
    
    if (operation.text)
    {
        self.labelTitle.textColor = textColor;
        self.labelTitle.text = operation.text;
        self.labelTitle.visible = YES;
        self.alpha = 1.f;
        self.backgroundColor = [UIColor clearColor];
    
        [self doAnimated:self.labelTitle operation:operation];
    }
    else
    {
        self.labelTitle.hidden = YES;
        self.backgroundColor = bkgColor;
        
        UIView* content = operation.content;
        if ([content respondsToSelector:@selector(setTextColor:)]) {
            if ([content performSelector:@selector(textColor)] == [UIColor clearColor])
                [content performSelector:@selector(setTextColor:) withObject:textColor];
        }
        
        content.frame = self.bounds;
        [self addSubview:operation.content];
    
        [self doAnimated:self operation:operation];
    }
}

- (void)doAnimated:(UIView*)view operation:(UIStatusBarExtOperation*)operation {
    view.alpha = 0.f;
    [UIView animateWithDuration:kCAAnimationDuration
                     animations:^{
                         view.alpha = 1;
                     } completion:^(BOOL finished) {
                         DISPATCH_DELAY_BEGIN(operation.duration)
                         [UIView animateWithDuration:kCAAnimationDuration
                                          animations:^{
                                              view.alpha = 0;
                                          } completion:^(BOOL finished) {
                                              [operation.content removeFromSuperview];
                                              [self.operations removeObject:operation];
                                              [self doOperation:self.operations.firstObject];
                                          }];
                         DISPATCH_DELAY_END
                     }];    
}

- (void)pushHidden:(BOOL)hidden animated:(BOOL)animated {
    if (animated)
        [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
    else
        [UIApplication sharedApplication].statusBarHidden = hidden;
    [_sckHiddens push:@(hidden)];
}

- (BOOL)popHiddenWithAnimated:(BOOL)animated {
    id cur = [_sckHiddens pop];
    if (cur == nil)
        return [UIApplication sharedApplication].statusBarHidden;
    id nxt = [_sckHiddens top];
    if (animated)
        [[UIApplication sharedApplication] setStatusBarHidden:[nxt boolValue] withAnimation:UIStatusBarAnimationFade];
    else
        [UIApplication sharedApplication].statusBarHidden = [nxt boolValue];
    return [cur boolValue];
}

@end

@interface UIAppFloatingContainerTransiting ()

@property (nonatomic, assign) UIAppFloatingContainer* container;

@end

@implementation UIAppFloatingContainerTransiting

- (void)dealloc {
    ZERO_RELEASE(_from);
    ZERO_RELEASE(_to);
    [super dealloc];
}

- (void)complete {
    [_container open];
}

- (void)cancel {
    [_container close];
}

@end

@interface UIAppFloatingContainerView : UIViewExt

@property (nonatomic, assign) UIViewController* rootViewController;

@end

@implementation UIAppFloatingContainerView

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [_rootViewController.view setSize:self.bounds.size];
}

- (void)setRootViewController:(UIViewController *)root {
    _rootViewController = root;
    [_rootViewController.view setSize:self.bounds.size];
}

@end

@interface UIAppFloatingContainer ()
<UIGestureRecognizerDelegate>
{
    NSMutableArray* _viewControllers;
    BOOL _isopened;
    CGPoint _percent;
}

@end

@implementation UIAppFloatingContainer

@synthesize viewControllers = _viewControllers;

- (void)onInit {
    [super onInit];
    self.classForView = [UIAppFloatingContainerView class];
    
    _viewControllers = [[NSMutableArray alloc] init];
}

- (void)onFin {
    ZERO_RELEASE(_viewControllers);
    [super onFin];
}

- (void)setRootViewController:(UINavigationControllerExt *)root {
    if (_rootViewController == root)
        return;
    
    [self removeSubcontroller:_rootViewController];
    _rootViewController = root;
    [self addSubcontroller:_rootViewController];
    
    ((UIAppFloatingContainerView*)self.view).rootViewController = _rootViewController;
}

- (void)onLoaded {
    [super onLoaded];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [UIApplication sharedApplication].statusBarStyle = self.preferredStatusBarStyle;
    self.wantsFullScreenLayout = YES;
    
    _panGestureRecognizer = [UIPanGestureRecognizer temporary];
    _panGestureRecognizer.delegate = self;
    [_panGestureRecognizer.signals connect:kSignalGesture withSelector:@selector(__appcontainer_panges:) ofTarget:self];
    [self.view addGestureRecognizer:_panGestureRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    UIView* view = touch.view;
    UIViewController* vc = view.headViewController;
    if (vc && vc.enableContainerGesture == NO)
        return NO;
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == _panGestureRecognizer) {
        return _viewControllers.count != 0;
    }
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (kIOS7Above)
        return UIStatusBarStyleDefault;
    return UIStatusBarStyleLightContent;
}

- (void)__appcontainer_panges:(SSlot*)s {
    UIAppFloatingContainerTransiting* evtobj = [UIAppFloatingContainerTransiting temporary];
    evtobj.container = self;
    evtobj.from = self.rootViewController;
    evtobj.to = _viewControllers.firstObject;
    evtobj.isopening = !_isopened;
    
    CGPoint pt = _panGestureRecognizer.delta;
    CGRect rc = self.view.bounds;
    pt.x = pt.x / rc.size.width;
    pt.y = pt.y / rc.size.height;
    _percent = CGPointAddPoint(_percent, pt);
    evtobj.percent = _percent;
    
    switch (_panGestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan: {
        } break;
        case UIGestureRecognizerStateChanged: {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationsEnabled:NO];
            [self.touchSignals emit:kSignalFloatingUpdating withResult:evtobj];
            [UIView setAnimationsEnabled:YES];
            [UIView commitAnimations];
        } break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            [self.touchSignals emit:kSignalFloatingFinaling withResult:evtobj];
        } break;
        default: break;
    }
    
    _percent = evtobj.percent;
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalFloatingUpdating)
SIGNAL_ADD(kSignalFloatingFinaling)
SIGNALS_END

- (void)open {
    UIAppFloatingContainerTransiting* evtobj = [UIAppFloatingContainerTransiting temporary];
    evtobj.container = self;
    evtobj.percent = CGPointMake(1, 1);
    evtobj.from = self.rootViewController;
    evtobj.to = _viewControllers.firstObject;
    evtobj.isopening = YES;
    [self.touchSignals emit:kSignalFloatingUpdating withResult:evtobj];
    _isopened = YES;
    _percent = evtobj.percent;
}

- (void)close {
    UIAppFloatingContainerTransiting* evtobj = [UIAppFloatingContainerTransiting temporary];
    evtobj.container = self;
    evtobj.percent = CGPointZero;
    evtobj.from = self.rootViewController;
    evtobj.to = _viewControllers.firstObject;
    evtobj.isopening = NO;
    [self.touchSignals emit:kSignalFloatingUpdating withResult:evtobj];
    _isopened = NO;
    _percent = evtobj.percent;
}

- (void)toggle {
    if (_isopened)
        [self close];
    else
        [self open];
}

- (void)pushViewController:(UIViewController *)vc {
    [_viewControllers addObject:vc];

    vc.view.frame = self.rootViewController.view.frame;
    [self addSubcontroller:vc];
    [self.rootViewController.view bringUp];
}

- (UIViewController*)popViewController {
    id ret = [_viewControllers.lastObject consign];
    [_viewControllers removeObjectAtRIndex:0];
    [self removeSubcontroller:ret];
    return ret;
}

@end

static UIAppDelegate* __gs_appdelegate = nil;
static void __gs_unhandle_exception(NSException*);
static NSUncaughtExceptionHandler *__gs_previous_unhandle_exception = NULL;
static NSString* kUIAppUnhandleExceptionKey = @"::app::unhandle_exception::data";

@interface UIAppDelegate ()
<SSignals>

// 显示动态启动图片
- (void)showOpeningImage;

@end

@implementation UIAppDelegate

@synthesize window;

- (id)init {
    self = [super init];
    
# ifdef DEBUG_MODE
    
    // 打印环境信息
    [self logEnvironmentInfo];
    
# endif
    
    // 设置全局
    __gs_appdelegate = self;
    
    // 初始化未知错误捕获
    [self execptionInit];
    
    // 基础初始化
    [self foundationInit];
    
    // 启动任务
    [[NSCron shared] start];
    
    // 初始化 root
    [self rootInit];
    
    return self;
}

- (void)dealloc {
    __gs_appdelegate = nil;
    
    // 结束任务
    [[NSCron shared] stop];
    
    // 释放
    ZERO_RELEASE(_container);
    ZERO_RELEASE(_statusBar);
    ZERO_RELEASE(window);
    
    [super dealloc];
}

- (void)rootInit {
    _container = [[UIAppFloatingContainer alloc] init];
    UINavigationControllerExt* navi = [UINavigationControllerExt temporary];
    navi.navigationBarHidden = YES;
    _container.rootViewController = navi;
}

BOOL kUIScreenIsRetina = NO;
CGSize kUIApplicationSize = {0};
CGRect kUIApplicationBounds = {0};
CGRect kUIScreenBounds = {0};
float kUIScreenScale = 1;
int kIOSMajorVersion = 0;
BOOL kIOS8Above = NO;
BOOL kIOS7Above = NO;
BOOL kIOS6Above = NO;
BOOL kIOS5Above = YES;
BOOL kDeviceIsRoot = NO;
UIScreenSizeType kUIScreenSizeType = 0;
bool kDeviceRunningSimulator = NO;
bool kDeviceRunningOniPAD = NO;

float kUINavigationBarHeight = 44;
float kUINavigationBarItemHeight = 32;
float kUINavigationBarItemWidth = 42;
float kUINavigationBarDodgeHeight = 64;
float kUIStatusBarHeight = 20;
float kUIToolBarHeight = 40;
float kUITabBarHeight = 49;
float kUISearchBarHeight = 40;
float kUIDpFactor = 1;

- (void)foundationInit {
    // 判断屏幕尺寸
    UIScreen* scr = [UIScreen mainScreen];
    if (scr.scale == 1) {
        kUIScreenIsRetina = NO;
    } else {
        kUIScreenIsRetina = YES;
    }
    kUIApplicationSize = scr.applicationFrame.size;
    kUIApplicationBounds = CGRectMakeWithSize(kUIApplicationSize);
    kUIScreenBounds = scr.bounds;
    kUIScreenScale = scr.scale;
    
    // 如果大于 320，则需要计算出dp的factor
    if (kUIScreenBounds.size.width > 320)
        kUIDpFactor = kUIScreenBounds.size.width / 320;
    
    // 判断屏幕的类型
    CGSize scrmodsz = scr.currentMode.size;
    if (scrmodsz.height < 1136)
        kUIScreenSizeType = kUIScreenSizeA;
    else if (scrmodsz.height < 1334)
        kUIScreenSizeType = kUIScreenSizeB;
    else if (scrmodsz.height < 2208)
        kUIScreenSizeType = kUIScreenSizeC;
    else
        kUIScreenSizeType = kUIScreenSizeD;

    // 判断设备的类型
    int flagDevice = [UIDevice DeviceType];
    kDeviceRunningSimulator = [NSMask Mask:kUIDeviceTypeSimulator Value:flagDevice];
    kDeviceRunningOniPAD = [NSMask Mask:kUIDeviceTypeIPad Value:flagDevice];
        
    // 判断系统版本
    NSString* sysver = [UIDevice currentDevice].systemVersion;
    NSArray* arrvers = [sysver componentsSeparatedByString:@"."];
    kIOSMajorVersion = [arrvers.firstObject intValue];
    kIOS8Above = kIOSMajorVersion >= 8;
    kIOS7Above = kIOSMajorVersion >= 7;
    kIOS6Above = kIOSMajorVersion >= 6;
    kDeviceIsRoot = [UIDevice IsRoot];
    
    // 启动网络监听
    [NSNetworkInterface Listen];
    
    // 置换类型
    [NSTypes Swizzles];
    [UITypes Swizzles];
    [CALayer Swizzles];
    
    // 初始化默认结构
    [UIKeyboardExt shared];
    
    // 加载自动测试环境
    DEVELOP_EXPRESS([AutoTestSuite Launch]);
    
    // 初始化图片缓存目录
    SDWebImageManager* manager = [SDWebImageManager sharedManager];
    manager.imageCache.diskCachePath = [[FSApplication shared] dirCache:@"images"];
    
    // IOS7 设置
# ifdef IOS7_FEATURES
    [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
# endif
}

SIGNALS_BEGIN

//self.signals.delegate = self;
SIGNAL_ADD(kSignalAppLaunched)
SIGNAL_ADD(kSignalAppEntered)
SIGNAL_ADD(kSignalAppActived)
SIGNAL_ADD(kSignalAppActiving)
SIGNAL_ADD(kSignalAppDeactived)
SIGNAL_ADD(kSignalAppDeactiving)
SIGNAL_ADD(kSignalAppTerminated)
SIGNAL_ADD(kSignalAppHandleUrl)
SIGNAL_ADD(kSignalAppOpenUrl)
SIGNAL_ADD(kSignalAppUrlGot)
SIGNAL_ADD(kSignalDeviceTokenGot)
SIGNAL_ADD(kSignalDeviceTokenGetFailed)
SIGNAL_ADD(kSignalNotificationLocal)
SIGNAL_ADD(kSignalNotificationRemote)
SIGNAL_ADD(kSignalNotificationActivedRemote)
SIGNAL_ADD(kSignalNotificationSettingsChanged)
SIGNAL_ADD(kSignalNotificationAssetsChanged)
SIGNAL_ADD(kSignalUnhandleException)
SIGNAL_ADD(kSignalUnhandleExceptionPrevious)
SIGNAL_ADD(kSignalMemoryWarning)

// 当程序进入后，需要进行一些后处理
[self.touchSignals connect:kSignalAppEntered withSelector:@selector(__appd_entered) ofTarget:self];

SIGNALS_END

- (UINavigationControllerExt*)rootViewController {
    return _container.rootViewController;
}

- (void)presentModalViewController:(UIViewController *)modalViewController {
    [self presentModalViewController:modalViewController animated:YES];
}

- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated {
    [[self topmostViewController] presentModalViewController:modalViewController animated:animated];
}

- (void)dismissModalViewController {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dismissModalViewControllerAnimated:(BOOL)animated {
    [[self topmostViewController] dismissModalViewControllerAnimated:animated];
}

- (UIViewController*)topmostViewController {
    UIViewController* vc = self.rootViewController;
    for (;vc;) {
        if (vc.presentedViewController == nil)
            break;
        UIViewController* tmp = vc.presentedViewController;
        if (tmp.isBeingDismissed)
            vc = vc.superViewController;
        else
            vc = tmp;
    }
    if (vc == nil)
        vc = self.rootViewController;
    return vc;
}

- (void)dismissAllModalViewControllersAnimated:(BOOL)animated {
    UIViewController* rt = self.rootViewController;
    [rt dismissModalViewControllerAnimated:animated];
}

- (void)dismissAllModalViewControllers {
    [self dismissAllModalViewControllersAnimated:NO];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self onBoot:launchOptions];
    
    // 设置状态栏
    _statusBar = [[UIStatusBarExt alloc] initWithZero];
    _statusBar.windowLevel = UIWindowLevelStatusBar + 100;
    
    // 初始化根 window
    window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.windowLevel = UIWindowLevelNormal;
    window.rootViewController = _container;
    [window makeKeyAndVisible];
    
    // 开始跟踪
    [AppSpoor Launch];
    
    // 保存一下上一次的推送信息
    NSDictionary* lastRN = [launchOptions getDictionary:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (lastRN)
        [[NSStorageExt shared] setObject:lastRN forKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    // 初始化失败
    if ([self onLoading] == NO) {
        FATAL("Application 初始化失败");
        return NO;
    }
    
    // 发送APP启动成功的消息
    [self.signals emit:kSignalAppLaunched];

    // 回调到引用
    [self onLoaded];
    
    // 注册一些额外的回调
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsLibraryChanged:) name:ALAssetsLibraryChangedNotification object:nil];
    
    return YES;
}

- (void)execptionInit {
    // 设置扑捉句柄
    __gs_previous_unhandle_exception = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(&__gs_unhandle_exception);
    
    // 查询是否上次已经遇到过未知异常
    NSSerializableException* exp = [[NSStorageExt shared] getObjectForKey:kUIAppUnhandleExceptionKey def:nil];
    if (exp) {
        [[NSStorageExt shared] setObject:nil forKey:kUIAppUnhandleExceptionKey];
        
        DEVELOP_EXPRESS({
            DISPATCH_DELAY(2, {
                [UIMessageBox Ok:@"上次崩溃" message:exp.description ok:@"好"];
            });
        });
        [self onPreviousException:exp];
        [self.signals emit:kSignalUnhandleExceptionPrevious withResult:exp];
    }
}

- (void)onBoot:(NSDictionary*)opts {
    PASS;
}

- (BOOL)onLoading {
    // 显示启动图片
    [self showOpeningImage];
    
    return YES;
}

- (void)onLoaded {
    PASS;
}

- (void)pushViewController:(UIViewController *)vc animated:(BOOL)animated {
    [self.rootViewController pushViewController:vc animated:animated];
}

- (void)pushViewController:(UIViewController*)vc {
    [self.rootViewController pushViewController:vc animated:YES];
}

- (void)logEnvironmentInfo {
# ifdef DEBUG_MODE
    NSBundle* bdlMain = [NSBundle mainBundle];
    LOG("APP运行目录 %s", bdlMain.bundlePath.UTF8String);
# endif
}

+ (id)shared {
    return __gs_appdelegate;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    INFO("App Deactiving");
    [self onDeactiving];
    [self.signals emit:kSignalAppDeactiving withResult:application];
}

- (void)onDeactiving {
    PASS;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    INFO("App Deactived");
    [self onDeactived];
    [self.signals emit:kSignalAppDeactived withResult:application];
}

- (void)onDeactived {
    PASS;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    INFO("App Activing");
    [self onActiving];
    [self.signals emit:kSignalAppActiving withResult:application];
}

- (void)onActiving {
    PASS;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    INFO("App Actived");
    [self onActived];
    [self.signals emit:kSignalAppActived withResult:application];
}

- (void)onActived {
    PASS;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    INFO("App Terminating");
    [self.signals emit:kSignalAppTerminated withResult:application];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    INFO("Local Notification: %s", notification.userInfo.jsonString.UTF8String);
    [self.signals emit:kSignalNotificationLocal withResult:notification.userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    INFO("Remote Notification: %s", userInfo.jsonString.UTF8String);
    UIApplicationState sta = application.applicationState;
    if (sta == UIApplicationStateActive) {
        [self.signals emit:kSignalNotificationActivedRemote withResult:userInfo];
        return;
    }
    [self.signals emit:kSignalNotificationRemote withResult:userInfo];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    INFO("Device Registered");
    [self.signals emit:kSignalDeviceTokenGot withResult:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [error log];
    [self.signals emit:kSignalDeviceTokenGetFailed withResult:error];
}

# ifdef IOS8_FEATURES
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [self.signals emit:kSignalNotificationSettingsChanged withResult:notificationSettings];
}
#endif

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    INFO("HandleOpenURL: %s", url.absoluteString.UTF8String);
    
    SSlotTunnel* tun = [SSlotTunnel temporary];
    [self.signals emit:kSignalAppHandleUrl withResult:url withTunnel:tun];
    if (!tun.vetoed)
        [self.signals emit:kSignalAppUrlGot withResult:url withTunnel:tun];
    return tun.vetoed;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    INFO("openURL: %s", url.absoluteString.UTF8String);

    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          url, @"url",
                          sourceApplication, @"sourceApplication",
                          annotation, @"annotation",
                          nil];
    SSlotTunnel* tun = [SSlotTunnel temporary];
    [self.signals emit:kSignalAppOpenUrl withResult:dict withTunnel:tun];
    if (!tun.vetoed)
        [self.signals emit:kSignalAppUrlGot withResult:url withTunnel:tun];
    return tun.vetoed;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    LOG("收到 APP 内存警告");
    [self.signals emit:kSignalMemoryWarning];
}

- (void)signals:(NSObject*)object signalConnected:(SSignal*)sig slot:(SSlot*)slot {
    PASS;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (kIOS7Above)
        return UIStatusBarStyleDefault;
    return UIStatusBarStyleLightContent;
}

- (void)assetsLibraryChanged:(NSNotification*)noti {
    [self.signals emit:kSignalNotificationAssetsChanged];
}

- (void)exit {
    exit(0);
}

- (void)__appd_entered {
    // 处理延迟加载的远程推送
    NSDictionary* delayRN = [[NSStorageExt shared] getObjectForKey:UIApplicationLaunchOptionsRemoteNotificationKey def:nil];
    if (delayRN) {
        [self application:[UIApplication sharedApplication] didReceiveRemoteNotification:delayRN];
        [[NSStorageExt shared] remove:UIApplicationLaunchOptionsRemoteNotificationKey];
    }
}

- (void)goAppstoreHome {
    [[UIApplication sharedApplication] goAppstoreHome:kAppIdOnAppstore];
}

- (NSString*)appstoreURL {
    return [[UIApplication sharedApplication] appstoreURL:kAppIdOnAppstore];
}

- (void)goRateApp {
    [[UIApplication sharedApplication] goReview:kAppIdOnAppstore];
}

- (void)onException:(NSSerializableException *)exp {
    PASS;
}

- (void)onPreviousException:(NSSerializableException *)exp {
    PASS;
}

static NSString *kAppOpeningImageUrlKey = @"::app::image::opening::url";
static NSString *kAppOpeningImageDataKey = @"::app::image::opening::data";

- (void)fetchOpeningImage:(NSString *)url {
    if (url.notEmpty == NO)
        return;
    
    // 如果没有变动，则不去下载
    if ([[[NSStorageExt shared] getStringForKey:kAppOpeningImageUrlKey def:@""] isEqualToString:url])
        return;
    
    // 下载图片
    NSURLConnectionExt* cnn = [NSURLConnectionExt connectionWithRequest:[NSURLRequest requestWithURLString:url]];
    [cnn.signals connect:kSignalDone withBlock:^(SSlot *s) {
        NSProgressValue* pv = s.data.object;
        [[NSStorageExt shared] setObject:pv.totoalbuffer forKey:kAppOpeningImageDataKey];
        [[NSStorageExt shared] setString:url forKey:kAppOpeningImageUrlKey];
        NOTI("保存新的启动图");
    }];
    [cnn start];
}

- (void)showOpeningImage {
    NSData* da = [[NSStorageExt shared] getDataForKey:kAppOpeningImageDataKey def:nil];
    if (da == nil)
        return;
    
    UIImageView* img = [UIImageView viewWithImage:[UIImage imageWithData:da]];
    img.frame = window.bounds;
    img.backgroundColor = [UIColor whiteColor];
    img.contentMode = UIViewContentModeScaleAspectFill;
    img.clipsToBounds = YES;
    [window addSubview:img];
    
    DISPATCH_DELAY_BEGIN(2)
    CAKeyframeAnimationExt* ani = [CAKeyframeAnimationExt SlideToLeft:img];
    ani.duration = .5;
    [img.layer addAnimation:ani
                 completion:^{
                     [img removeFromSuperview];
                 }];
    DISPATCH_DELAY_END
}

@end

void __gs_unhandle_exception(NSException* sysexp) {
    NSSerializableException* exp = sysexp.serializableException;
    
    // 回调，并可以在回调中附加一下异常参数
    [[UIAppDelegate shared] onException:exp];
    [[UIAppDelegate shared].signals emit:kSignalUnhandleException withResult:exp];
    
    // 保存到持久缓存，以便下一次启动时读取或其他操作
    [[NSStorageExt shared] setObject:exp forKey:kUIAppUnhandleExceptionKey];

    // 运行之前其他组件设定的函数
    if (__gs_previous_unhandle_exception)
        __gs_previous_unhandle_exception(sysexp);
    [sysexp log];
}
