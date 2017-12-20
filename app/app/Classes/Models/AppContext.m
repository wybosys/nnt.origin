
# import "Common.h"
# import "AppContext.h"
# import "UserLogin.h"
# import "UserLogout.h"
# import "ApiSession.h"
# import "FileSystem+Extension.h"
# import "RTEContentMessageList.h"
# import "RTESysCMDDisconnect.h"
# import "RTEHeartBeatReq.h"
# import "RTEHeartBeatResp.h"
# import "NetDefine.h"
# import "UserSetdevicetoken.h"
# import "AppDelegate+Extension.h"
# import "UserVersion.h"
# import "Network+Extension.h"

@interface AppContext ()

@property (nonatomic, readonly) NSMutableArray* receivedAvatars;

@end

@implementation AppContext

SHARED_IMPL;

- (id)init {
    self = [super init];
    
# ifdef DEVELOP_MODE
    SITE_MODE = [[NSStorageExt shared] getIntegerForKey:@"::app::site::mode" def:SITE_MODE_PRIVATE];
# endif
    
    _curApp = [[App alloc] init];
    _curUser = [[UserData alloc] init];
    _curDevice = [[Device alloc] init];
    _curPerferences = [[Perferences alloc] init];
    _curBeep = [[Beep alloc] init];
        
    // 读取上次登录用的用户信息
    _curUser.username = [[NSStorageExt shared] getStringForKey:@"::app::login::name" def:@""];
    _curUser.passwd = [[NSStorageExt shared] getStringForKey:@"::app::login::passwd" def:@""];
    
    // 绑定额外的处理
    [self.signals connect:kSignalUserLogined withSelector:@selector(requestDeviceTokens:) ofTarget:self];
    
    // 第一次注册
    [self.signals connect:kSignalUserNeedCompleteInfo withSelector:@selector(requestDeviceTokens:) ofTarget:self];

    // 获得到设备号
    [[UIAppDelegate shared].signals connect:kSignalDeviceTokenGot withSelector:@selector(cbDeviceTokensGot:) ofTarget:self];
    
    [[ApiSession shared].signals connect:kSignalApiFailed withSelector:@selector(cbApiFailed:) ofTarget:self].priority = -1;
    
    // 设置访问的标记
    [ApiSession shared].httpAgent = [NSString stringWithFormat:@"Strong:%@/%d;os:iOS/%@;hardware:%@/%@;net:%@/%@;e:%@;",
                                     _curApp.version, _curApp.idChannel,
                                     _curDevice.sysversion,
                                     _curDevice.cellbrand, _curDevice.cellmodel,
                                     _curDevice.carrier.urlencode, @"ni",
                                     _curDevice.equipid];
    
    // 其他数据
    _receivedAvatars = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)dealloc {    
    ZERO_RELEASE(_curApp);
    ZERO_RELEASE(_curUser);
    ZERO_RELEASE(_curDevice);
    ZERO_RELEASE(_curPerferences);
    ZERO_RELEASE(_curBeep);
    
    [[ApiSession shared].signals disconnectToTarget:self];
    
    ZERO_RELEASE(_receivedAvatars);
    SUPER_DEALLOC;
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalUserNeedCompleteInfo);
SIGNAL_ADD(kSignalUserAutoLoginFailed);
SIGNAL_ADD(kSignalUserLogined)
SIGNAL_ADD(kSignalUserLogout)
SIGNAL_ADD(kSignalMessageReceived)
SIGNAL_ADD(kSignalMessageSkipped)
SIGNAL_ADD(kSignalManyMessagesReceived)
SIGNAL_ADD(kSignalManyMessagesSkipped)
SIGNAL_ADD(kSignalRpcReceived)
SIGNAL_ADD(kSignalXpChangedNotification)
SIGNALS_END

- (void)login {
    UserLogin* ul = [[UserLogin alloc] init];
    
    ul.in_appid = [AppContext shared].curApp.idApp;
    ul.in_channelid = [AppContext shared].curApp.idChannel;
    ul.in_equipmentid = [AppContext shared].curDevice.equipid;
    ul.in_applicationversion = [AppContext shared].curApp.version;
    ul.in_cellbrand = [AppContext shared].curDevice.cellbrand;
    ul.in_cellmodel = [AppContext shared].curDevice.cellmodel;
    ul.in_mac = [AppContext shared].curDevice.macaddr;
    ul.in_name = [AppContext shared].curUser.username;
    ul.in_password = [AppContext shared].curUser.passwd;
    ul.mcFlush = YES;
    
    [[ApiSession shared] fetch:ul with:^(SNetObj *m) {
        m.showWaiting = YES;
        
        [m.signals connect:kSignalApiRequesting withSelector:@selector(ShowProgress) ofClass:[UIHud class]];
        [m.signals connect:kSignalApiProcessed withSelector:@selector(HideProgress) ofClass:[UIHud class]];
        
        [m.signals connect:kSignalApiSucceed withSelector:@selector(cbLogin:) ofTarget:self];
        [m.signals connect:kSignalApiFailed withSelector:@selector(cbLoginFailed:) ofTarget:self];
    }];
    
    SAFE_RELEASE(ul);
}

- (void)autologin {
    UserVersion* uv = [[UserVersion alloc] init];
    uv.in_appid = [AppContext shared].curApp.idApp;
    uv.in_channelid = [AppContext shared].curApp.idChannel;
    uv.in_equipmentid = [AppContext shared].curDevice.equipid;
    uv.in_applicationversion = [AppContext shared].curApp.version;
    uv.in_cellbrand = [AppContext shared].curDevice.cellbrand;
    uv.in_cellmodel = [AppContext shared].curDevice.cellmodel;
    uv.in_mac = [AppContext shared].curDevice.macaddr;
    uv.in_systemversion = [AppContext shared].curDevice.sysversion;
    uv.mcTimestampOverdue = TM_SECOND_5;
    
    [[ApiSession shared] fetch:uv with:^(SNetObj *m) {
        m.showWaiting = YES;
        
        [m.signals connect:kSignalApiRequesting withSelector:@selector(ShowProgress) ofClass:[UIHud class]];
        [m.signals connect:kSignalApiProcessed withSelector:@selector(HideProgress) ofClass:[UIHud class]];
        
        [m.signals connect:kSignalApiSucceed withSelector:@selector(cbLogin:) ofTarget:self];
        [m.signals connect:kSignalApiFailed withSelector:@selector(cbLoginFailed:) ofTarget:self];
    }];
    SAFE_RELEASE(uv);
    
    // 如果没有网络（具体流程见，doc/离线流程.graffle)，需要在网络联通时进行隐性登录
    if ([NSNetworkInterface Any].reachable == NO) {
        [[[NSNetworkInterface Any].signals connect:kSignalNetworkReachabilityOn withBlock:^(SSlot *s, AppContext* target) {
            [target slientlogin];
        } ofTarget:self] oneshot];
    }
}

- (void)slientlogin {
    UserVersion* uv = [[UserVersion alloc] init];
    uv.in_appid = [AppContext shared].curApp.idApp;
    uv.in_channelid = [AppContext shared].curApp.idChannel;
    uv.in_equipmentid = [AppContext shared].curDevice.equipid;
    uv.in_applicationversion = [AppContext shared].curApp.version;
    uv.in_cellbrand = [AppContext shared].curDevice.cellbrand;
    uv.in_cellmodel = [AppContext shared].curDevice.cellmodel;
    uv.in_mac = [AppContext shared].curDevice.macaddr;
    uv.in_systemversion = [AppContext shared].curDevice.sysversion;
    uv.mcTimestampOverdue = TM_SECOND_5;
    [[ApiSession shared] fetch:uv with:^(SNetObj *m) {
        m.showWaiting = YES;
        [m.signals connect:kSignalApiFailed withSelector:@selector(logout) ofTarget:self];
    }];
    SAFE_RELEASE(uv);
}

- (void)doLogin {
    INFO("登录成功");
    
    // 设置登录状态
    _curUser.logined = YES;
    
    // 记住用户、密码
    [[NSStorageExt shared] setString:_curUser.username forKey:@"::app::login::name"];
    [[NSStorageExt shared] setString:_curUser.passwd forKey:@"::app::login::passwd"];
    
    // 初始化设置表
    _curPerferences.db = _curUser.storage;
    
    // 初始化音效
    [_curBeep loadBundle:[_curUser.storage getStringForKey:@"::app::soundset" def:@"visions.bundle"]];
    
    // 进入完善信息流程
    // 判断是否需要补充(完善个人信息)数据
    // 后来改变了流程：直接先登录成功，之后再去检查是不是需要补全数据
    BOOL needCompleteCI = _curUser.status == 1;
    //needCompleteCI = YES; // 测试用
    
    if (needCompleteCI == NO) {
        if (_curUser.nickname.notEmpty == NO)
            needCompleteCI = YES;
    }

    if (needCompleteCI) {
        // 补充完数据，发送登录成功的信号
        // 修改为直接登录，完善信息的窗口直接覆盖在appindex之上
        //[ctlr.signals connect:kSignalViewDismissing redirectTo:kSignalUserLogined ofTarget:self];
        [self.signals emit:kSignalUserNeedCompleteInfo];
    }
    else
    {
        // 抛出已经登录成功的信号
        [self.signals emit:kSignalUserLogined];
    }
}

- (void)cbLogin:(SSlot*)s {
    UserLogin* ul = s.data.object;
    
    // 执行登录数据处理
    [self loginByData:ul.data];

# if defined(DEBUG_MODE) && 0
    [self populateRTEMessage];
# endif
    
    _curUser.platform = kUserPlatformXHB;
}

ThreadAvatar *ACCOUNT_ACTIVITY_CENTER = nil,
*ACCOUNT_HELPER = nil,
*ACCOUNT_KEFU = nil;

- (void)loginByData:(LoginOutputData*)data {
    // 设置其他数据
    PROPERTY_RETAIN(ACCOUNT_ACTIVITY_CENTER, data.threads.act);
    PROPERTY_RETAIN(ACCOUNT_HELPER, data.threads.helper);
    PROPERTY_RETAIN(ACCOUNT_KEFU, data.threads.kf);
    
    // 设置用户信息
    _curUser.accountId = data.accountid;
    _curUser.nickname = data.nickname;
    _curUser.introduction = data.introduction;
    _curUser.bindplatformlist = data.bindplatformlist;
    _curUser.status = data.status;
    _curUser.gender = data.gender;
    _curUser.prefix = DEV_PREFIX();
    _curUser.prefs = data.prefs;
    _curUser.nativeplace = data.nativeplace;
    _curUser.inviteseq = data.inviteseq;
    _curUser.suggestAvatars = data.defaultavatarcount;
    _curUser.malenickname = data.malenickname;
    _curUser.femalenickname = data.femalenickname;
    _curUser.currentNotice = data.notice;
    _curUser.updateInfo = data.update;
    
    // 设置应用信息
    _curApp.hasMall = DEBUG_SYMBOL(YES) RELEASE_SYMBOL(data.shopshow);
    
    // 设置积分墙信息
    _curApp.hasJiFeng = data.idfaurl;
    if ((data.idfashow == 0) && kReleaseMode)
        _curApp.hasJiFeng = nil;
    
    // 下载启动图
    [[UIAppDelegate shared] fetchOpeningImage:data.screenimageurl];
    
    // 检查更新
    if (data.update.needupdate != AUTOUPDATE_NONE) {
        [self.signals connect:kSignalUserLogined withSelector:@selector(actUpdate) ofTarget:self];
    }
    
    // 登录
    [self doLogin];
}

- (void)actUpdate {
    UIAlertViewExt* alert = [[UIAlertViewExt alloc] init];
    alert.title = @"发现新版本";
    
    UILabelExt* lbl = [UILabelExt temporary];
    lbl.multilines = YES;
    lbl.text = self.curUser.updateInfo.updatedesc;
    alert.contentView = lbl;

    [[alert addItem:@"去更新"].signals connect:kSignalClicked withBlock:^(SSlot *s) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.curUser.updateInfo.updateurl]];
    }];
    if (self.curUser.updateInfo.needupdate != AUTOUPDATE_FORCE)
        [alert addItem:@"取消"];
    [alert show];
    SAFE_RELEASE(alert);
}

- (void)cbLoginFailed:(SSlot*)s {
    if ([self.signals findSlots:kSignalUserAutoLoginFailed])
    {
        [self.signals emit:kSignalUserAutoLoginFailed];
    }
    else
    {
        SNetObj* no = (SNetObj*)s.sender;
        [UIHud Text:no.errorMessage];
    }
}

- (void)logout {
    UserLogout* ul = [[UserLogout alloc] init];
    ul.mcFlush = YES;
    [[ApiSession shared] fetch:ul with:^(SNetObj *m) {
        m.showWaiting = YES;
        [m.signals connect:kSignalApiSucceed withSelector:@selector(cbLogout) ofTarget:self];
    }];
    SAFE_RELEASE(ul);
}

- (void)cbLogout {
    INFO("退出登录");
    
    // 设置当前用户为未登录
    _curUser.logined = NO;
    
    // 清理数据
    _curPerferences.db = nil;
    
    // 发送信号
    [self.signals emit:kSignalUserLogout];
}

- (void)cbApiFailed:(SSlot*)s {
    [UIHud Text:[s.data.object errorMessage]];
}

- (void)requestDeviceTokens:(SSlot*)s {
    NSUInteger flag = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:flag];
}

- (void)cbDeviceTokensGot:(SSlot*)s {
    NSData* deviceData = s.data.object;
    
    NSString* deviceToken = [deviceData description];
    if (![deviceToken notEmpty])
        return;

    deviceToken = [[[deviceToken stringByReplacingOccurrencesOfString: @"<" withString: @""]
                    stringByReplacingOccurrencesOfString: @">" withString: @""]
                   stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    UserSetdevicetoken* m = [[UserSetdevicetoken alloc] init];
    m.in_devicetoken = deviceToken;
    [[ApiSession shared] send:m];
    SAFE_RELEASE(m);
}

@end
