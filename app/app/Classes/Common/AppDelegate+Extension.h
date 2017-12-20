
# ifndef __APPDELEGATEEXTENSION_16C277A500704273B82A1479A2EB47CF_H_INCLUDED
# define __APPDELEGATEEXTENSION_16C277A500704273B82A1479A2EB47CF_H_INCLUDED

# import "SSObject.h"
# import "UITypes+Extension.h"

/** 状态栏的封装，可以提供额外的功能 */
@interface UIStatusBarExt : UIWindow

/** 用来显示文字的 title */
@property (nonatomic, readonly) UILabelExt *labelTitle;

/** 显示一段文字 */
- (void)show:(NSString*)text duration:(NSTimeInterval)duration;

/** 显示一个自定义的 view */
- (void)display:(UIView*)view duration:(NSTimeInterval)duration;

/** 使用堆栈来维护显示、隐藏的状态 */
- (void)pushHidden:(BOOL)hidden animated:(BOOL)animated;
- (BOOL)popHiddenWithAnimated:(BOOL)animated;

@end

extern CGFloat kUIStatusBarFontSize;

/** 可以自定义 app 容器的切换动画 */
@interface UIAppFloatingContainerTransiting : NSObject

@property (nonatomic, retain) UIViewController *from, *to;
@property (nonatomic, assign) CGPoint percent;
@property (nonatomic, assign) BOOL isopening; // 是否为打开的模式，用来业务那边做动画用

- (void)complete;
- (void)cancel;

@end

/** APP 根容器 */
@interface UIAppFloatingContainer : UIViewControllerExt

@property (nonatomic, retain) UINavigationControllerExt *rootViewController;
@property (nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;

/** vcs栈 */
@property (nonatomic, readonly) NSArray* viewControllers;
- (void)pushViewController:(UIViewController*)vc;
- (UIViewController*)popViewController;

/** 打开最上方的 */
- (void)open;

/** 关闭 */
- (void)close;

/** 自动 open 或者 close */
- (void)toggle;

@end

SIGNAL_DECL(kSignalFloatingUpdating) @"::ui::floating::updating";
SIGNAL_DECL(kSignalFloatingFinaling) @"::ui::floating::finaling";

/** 业务层的 APPDELEGATE 需要集成该类来实现 app 功能 */
@interface UIAppDelegate : NSObject
<UIApplicationDelegate>

/** 最外层的容器，可以用来制作全局的手势打开额外设置参数界面的功能 */
@property (nonatomic, readonly) UIAppFloatingContainer *container;

/** 根navi，默认的所有业务界面都是 root 的子 vc */
@property (nonatomic, readonly) UINavigationControllerExt *rootViewController;

/** 获取到可以自定义的电池栏 */
@property (nonatomic, readonly) UIStatusBarExt* statusBar;

/** 打印环境信息 */
- (void)logEnvironmentInfo;

/** 初始化基础架构 */
- (void)foundationInit;

/** 初始化root */
- (void)rootInit;

/** 初始化
@note 顺序 onBoot -> onLoading -> onLoaded
 */
- (void)onBoot:(NSDictionary*)opts;
- (BOOL)onLoading;
- (void)onLoaded;

/** 展示其他VC */
- (UIViewController*)topmostViewController;
- (void)dismissAllModalViewControllers;
- (void)dismissAllModalViewControllersAnimated:(BOOL)animated;
- (void)presentModalViewController:(UIViewController *)modalViewController;
- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated;
- (void)dismissModalViewController;
- (void)dismissModalViewControllerAnimated:(BOOL)animated;
- (void)pushViewController:(UIViewController*)vc;
- (void)pushViewController:(UIViewController*)vc animated:(BOOL)animated;

/** 默认的 statusbar 样式 */
- (UIStatusBarStyle)preferredStatusBarStyle;

/** 下载启动图 */
- (void)fetchOpeningImage:(NSString*)url;

/** 退出 
 @note 默认为杀进程，业务层可以重写该函数来提供其他退出的方式
 */
- (void)exit;

/** 状态回调 */
- (void)onActiving;
- (void)onActived;
- (void)onDeactiving;
- (void)onDeactived;

/** 打开程序在 APPStore 的主页 */
- (void)goAppstoreHome;
- (NSString*)appstoreURL;

/** 打开程序点评页面 */
- (void)goRateApp;

/** 处理未定义异常 */
- (void)onException:(NSSerializableException*)exp;
- (void)onPreviousException:(NSSerializableException*)exp;

@end

// 设备是否已经 root
extern BOOL kDeviceIsRoot;

// app 的 id
extern NSString* kAppIdOnAppstore;

// app 的老家地址
extern NSString* kAppHomeURL;

// 通常程序会在首页加载完成后才算是进入，所以此时需要业务层向 appdelegate 发送此信号进行通知
// 这个信号要格外注意
SIGNAL_DECL(kSignalAppEntered) @"::app::entered";

// 程序启动时激活
SIGNAL_DECL(kSignalAppLaunched) @"::app::launched";

// 程序从后台激活时激活
SIGNAL_DECL(kSignalAppActiving) @"::app::activing";
SIGNAL_DECL(kSignalAppActived) @"::app::actived";

// 程序切换到后台
SIGNAL_DECL(kSignalAppDeactiving) @"::app::deactiving";
SIGNAL_DECL(kSignalAppDeactived) @"::app::deactived";

// 程序被干掉
SIGNAL_DECL(kSignalAppTerminated) @"::app::terminated";

// 外部激活本程序的时候传递的参数
SIGNAL_DECL(kSignalAppHandleUrl)   @"::app::handleurl";
SIGNAL_DECL(kSignalAppOpenUrl)   @"::app::openurl";
// app 收到了一个 url 的请求
SIGNAL_DECL(kSignalAppUrlGot)    @"::app::url::got";

// 获得到APNS使用的tokens
SIGNAL_DECL(kSignalDeviceTokenGot) @"::app::devicetoken::got";
SIGNAL_DECL(kSignalDeviceTokenGetFailed) @"::app::devicetoken::get::failed";

// 本地推送
SIGNAL_DECL(kSignalNotificationLocal) @"::app::notification::local";

// 远程推送
SIGNAL_DECL(kSignalNotificationRemote) @"::app::notification::remote";
// 处于激活状态的推送
SIGNAL_DECL(kSignalNotificationActivedRemote) @"::app::notification::remote::actived";

// 程序设置发生改变
SIGNAL_DECL(kSignalNotificationSettingsChanged) @"::app::notification::settings::changed";

// 程序资源发生改变（相片里面增删图片、视频等）
SIGNAL_DECL(kSignalNotificationAssetsChanged) @"::app::notification::assets::changed";

// 如果收到了一个未处理的异常
SIGNAL_DECL(kSignalUnhandleException) @"::app::unhandle_exception";

// 前一次的未处理异常
SIGNAL_DECL(kSignalUnhandleExceptionPrevious) @"::app::unhandle_exception::previous";

// 内存警告
SIGNAL_DECL(kSignalMemoryWarning) @"::app::memory::warning";

# endif
