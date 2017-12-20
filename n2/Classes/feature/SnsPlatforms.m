
# import "Common.h"
# import "SnsPlatforms.h"
# import "AppDelegate+Extension.h"

# import <TencentOpenAPI/TencentApiInterface.h>
# import <TencentOpenAPI/QQApiInterface.h>
# import <TencentOpenAPI/TencentOAuth.h>
# import <TencentOpenAPI/TencentOAuthObject.h>
# import <Weibo/WeiboSDK.h>
# import <Weibo/WeiboUser.h>
# import <WeChat/WXApi.h>

NSString* kSnsPlatformBindedKey = @"::sns::platform::key::binded";

@implementation SnsContent

- (void)onInit {
    [super onInit];
    self.url = kAppHomeURL;
    self.apphome = kAppHomeURL;
    self.thumb = [NSDataSource dsWithBundle:[[UIScreen namedForAppIcon] stringByAppendingString:@".png"]];
    self.hint = @"";
    self.text = @"";
}

- (void)onFin {
    ZERO_RELEASE(_text);
    ZERO_RELEASE(_hint);
    ZERO_RELEASE(_image);
    ZERO_RELEASE(_thumb);
    ZERO_RELEASE(_voice);
    ZERO_RELEASE(_url);
    ZERO_RELEASE(_apphome);
    ZERO_RELEASE(_callback);
    [super onFin];
}

- (BOOL)isMultimedia {
    if (_image || _thumb || _voice)
        return YES;
    return NO;
}

@end

@interface SnsService ()
<SnsService>
@end

@implementation SnsService

SHARED_IMPL;

+ (void)SetAsDefault {
    [SnsPlatform SetDefaultService:[self class]];
}

- (void)saveTokens:(NSDictionary*)data platform:(SnsPlatform*)platform {
    PASS;
}

- (NSDictionary*)loadTokens:(SnsPlatform*)platform {
    return nil;
}

- (void)clearTokens:(SnsPlatform*)platform {
    PASS;
}

- (BOOL)isBinded:(SnsPlatform*)platform {
    NSDictionary* data = [self loadTokens:platform];
    BOOL ret = [data getBool:kSnsPlatformBindedKey];
    return ret;
}

- (void)attach:(SnsPlatform*)platform {
    PASS;
}

- (void)shareByServer:(SnsContent*)content platform:(SnsPlatform*)platform {
    PASS;
}

@end

@interface SnsPlatform ()
{
    NSBlockObject *_block_success;
}

@property (nonatomic, readonly) NSMutableDictionary *data;
@property (nonatomic, copy) NSString *platformid;

- (void)shareBySDK:(SnsContent*)content;
- (void)shareByServer:(SnsContent*)content;

@end

@implementation SnsPlatform

static SnsService<SnsService>* __gs_service = nil;

+ (void)SetDefaultService:(Class)cls {
    if ([__gs_service isMemberOfClass:cls])
        return;
    __gs_service = [cls shared];
}

- (void)onInit {
    [super onInit];
    
    _data = [[NSMutableDictionary alloc] init];
    _block_success = [[NSBlockObject alloc] init];
    _shareByServer = NO;
    
    // 连接后处理
    [__gs_service attach:self];
}

- (void)onFin {
    ZERO_RELEASE(_data);
    ZERO_RELEASE(_block_success);
    ZERO_RELEASE(_platformid);
    [super onFin];
}

- (void)setPlatformid:(NSString *)platformid {
    PROPERTY_COPY(_platformid, platformid);
    [self load];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalSnsBindSucceed)
SIGNAL_ADD(kSignalSnsBindFailed)
SIGNAL_ADD(kSignalSnsShareSucceed)
SIGNAL_ADD(kSignalSnsShareFailed)
SIGNAL_ADD(kSignalSnsSsoLogined)
SIGNAL_ADD(kSignalSnsUserInfo)
SIGNALS_END

- (void)bind {
    PASS;
}

- (void)bind:(void (^)())success {
    if (self.isBinded) {
        success();
        return;
    }
    
    _block_success.block = success;
    [self.signals connect:kSignalSnsBindSucceed withSelector:@selector(__cb_bindsuccess) ofTarget:self];
    [self.signals connect:kSignalSnsBindFailed withSelector:@selector(__cb_bindfailed) ofTarget:self];

    [self bind];
}

- (void)__cb_bindsuccess {
    if (_block_success) {
        _block_success.block();
        _block_success.block = nil;
    }
}

- (void)__cb_bindfailed {
    _block_success.block = nil;
}

- (void)save {
    [__gs_service saveTokens:_data platform:self];
}

- (void)load {
    [_data setObjectsFromDictionary:[__gs_service loadTokens:self]];
}

- (void)clear {
    [_data removeAllObjects];
    [self save];
    [__gs_service clearTokens:self];
}

- (BOOL)isBinded {
    return [__gs_service isBinded:self];
}

- (void)share:(SnsContent *)content {
    if (self.shareByServer)
        [self shareByServer:content];
    else
        [self shareBySDK:content];
}

- (void)shareBySDK:(SnsContent *)content {
    PASS;
}

- (void)shareByServer:(SnsContent *)content {
    [__gs_service shareByServer:content platform:self];
}

@end

@interface SnsQQ ()
<TencentSessionDelegate, QQApiInterfaceDelegate, TencentLoginDelegate>
{
    TencentOAuth* _oauth;
}

@end

@implementation SnsQQ

static NSString* __gs_qqappid = nil;

- (void)onInit {
    [super onInit];
    
    DISPATCH_ONCE_EXPRESS({
        NSArray* schemes = [UIApplication shared].appSchemes;
        __gs_qqappid = [[schemes objectWithQuery:^id(NSString* l) {
            if ([l hasPrefix:@"tencent"])
                return [l substringFromIndex:7];
            return nil;
        }] copy];
    });
    
    self.clientid = __gs_qqappid;
    self.platformid = @"QQ";
    _oauth = [[TencentOAuth alloc] initWithAppId:self.clientid andDelegate:self];
    
    [[UIAppDelegate shared].signals connect:kSignalAppUrlGot withSelector:@selector(cbOpenURL:) ofTarget:self];
}

- (void)onFin {
    ZERO_RELEASE(_clientid);
    ZERO_RELEASE(_oauth);
    [super onFin];
}

- (void)setShareByServer:(BOOL)shareByServer {
    [super setShareByServer:NO];
}

- (void)cbOpenURL:(SSlot*)s {
    NSURL* url = s.data.object;
    if ([[url scheme] isEqualToString:[NSString stringWithFormat:@"tencent%@", self.clientid]]) {
        [TencentOAuth HandleOpenURL:url];
    }
    [s.tunnel veto];
}

- (void)authFailed {
    [self.data setBool:false forKey:kSnsPlatformBindedKey];
    [self save];
    [self.signals emit:kSignalSnsBindFailed];
}

- (void)isOnlineResponse:(NSDictionary *)response {
    PASS;
}

- (void)tencentDidLogin {
    [self.data setObject:_oauth.accessToken forKey:@"access_token" def:nil];
    [self.data setObject:_oauth.expirationDate forKey:@"expiration_date" def:nil];
    [self.data setObject:_oauth.openId forKey:@"userid" def:nil];
    [self.data setBool:true forKey:kSnsPlatformBindedKey];
    [self save];
    [self.signals emit:kSignalSnsBindSucceed withResult:self.data];
    
    // 释放
    SAFE_RELEASE(self);
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    [self authFailed];
    SAFE_RELEASE(self);
}

- (void)tencentDidNotNetWork {
    [self.signals emit:kSignalSnsBindFailed];
    SAFE_RELEASE(self);
}

- (void)tencentDidLogout {
    LOG("QQ logout");
}

- (void)onReq:(QQBaseReq *)req {
    PASS;
}

- (void)onResp:(QQBaseResp *)resp {
    PASS;
}

- (void)bind {
    SAFE_RETAIN(self);
    
    NSArray * array = @[
                        kOPEN_PERMISSION_GET_USER_INFO,
                        kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                        //kOPEN_PERMISSION_ADD_ALBUM,
                        //kOPEN_PERMISSION_ADD_IDOL,
                        //kOPEN_PERMISSION_ADD_ONE_BLOG,
                        //kOPEN_PERMISSION_ADD_PIC_T,
                        kOPEN_PERMISSION_ADD_SHARE,
                        kOPEN_PERMISSION_ADD_TOPIC,
                        kOPEN_PERMISSION_CHECK_PAGE_FANS,
                        //kOPEN_PERMISSION_ADD_IDOL,
                        //kOPEN_PERMISSION_DEL_IDOL,
                        //kOPEN_PERMISSION_DEL_T,
                        //kOPEN_PERMISSION_GET_FANSLIST,
                        //kOPEN_PERMISSION_GET_IDOLLIST,
                        kOPEN_PERMISSION_GET_INFO,
                        kOPEN_PERMISSION_GET_OTHER_INFO,
                        //kOPEN_PERMISSION_GET_REPOST_LIST,
                        kOPEN_PERMISSION_LIST_ALBUM,
                        kOPEN_PERMISSION_UPLOAD_PIC,
                        kOPEN_PERMISSION_GET_VIP_INFO,
                        kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                        //kOPEN_PERMISSION_GET_INTIMATE_FRIENDS_WEIBO,
                        //kOPEN_PERMISSION_MATCH_NICK_TIPS_WEIBO
                        ];
    [_oauth authorize:array inSafari:!self.installed];
}

- (void)shareBySDK:(SnsContent *)content {
    QQApiObject* mo = nil;
    
    if (content.hint.notEmpty == NO)
        content.hint = @"分享";
    
    if (content.isMultimedia)
    {
        [UIHud ShowProgress];
        
        if (content.image.notEmpty)
        {
            UIImage* img = [UIImage imageWithContentOfDataSource:content.image];
            mo = [QQApiNewsObject objectWithURL:[NSURL URLWithString:content.url]
                                          title:content.hint
                                    description:content.text
                               previewImageData:UIImageJPEGRepresentation(img, 0.01)
                              targetContentType:QQApiURLTargetTypeNews];
        }
        else if (content.voice.notEmpty)
        {
            mo = [QQApiAudioObject objectWithURL:[NSURL URLWithDataSource:content.voice]
                                           title:content.hint
                                     description:content.text
                                previewImageData:[NSData dataWithContentsOfDataSource:content.thumb]];
        }
        
        [UIHud HideProgress];
    }
    
    if (mo == nil && content.url)
    {
        mo = [QQApiURLObject objectWithURL:[NSURL URLWithString:content.url]
                                     title:content.hint
                               description:content.text
                          previewImageData:[NSData dataWithContentsOfDataSource:content.thumb]
                         targetContentType:QQApiURLTargetTypeNews];
    }
    
    if (mo == nil) {
        mo = [QQApiTextObject objectWithText:content.text];
    }
        
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:mo];
    QQApiSendResultCode code = [QQApiInterface sendReq:req];
    if (code == EQQAPISENDSUCESS) {
        [self.signals emit:kSignalSnsShareSucceed withResult:content];
    } else {
        LOG("QQ 分享失败");
        [self.signals emit:kSignalSnsShareFailed];
    }
}

- (BOOL)installed {
    return [QQApiInterface isQQInstalled];
}

- (BOOL)supportapi {
    return [QQApiInterface isQQSupportApi];
}

- (void)userinfo {
    if ([_oauth getUserInfo]) {
        SAFE_RETAIN(self);
    } else {
        WARN("QQ 获取用户信息失败");
    }
}

- (void)getUserInfoResponse:(APIResponse*)response {
    NSDictionary* dict = response.jsonResponse;
    SnsUser* user = [SnsUser temporary];
    user.nickname = [dict valueForKey:@"nickname"];
    user.username = [dict valueForKey:@"nickname"];
    user.avatar = [dict valueForKey:@"figureurl_qq_1"];
    user.gender = [[dict valueForKey:@"gender"] isEqualToString:@"男"];
    user.uid = _oauth.openId;
    [self.signals emit:kSignalSnsUserInfo withResult:user];
    SAFE_RELEASE(self);
}

+ (BOOL)isAvaliable {
    return [QQApiInterface isQQInstalled] && [QQApiInterface isQQSupportApi];
}

@end

@interface SnsWeibo ()
<WeiboSDKDelegate>

@end

@implementation SnsWeibo

static NSString* __gs_wbappkey = nil;

- (void)onInit {
    [super onInit];

    DISPATCH_ONCE_EXPRESS({
        NSArray* schemes = [UIApplication sharedApplication].appSchemes;
        __gs_wbappkey = [[schemes objectWithQuery:^id(NSString* l) {
            if ([l hasPrefix:@"wb"])
                return __gs_wbappkey = [[l substringFromIndex:2] copy];
            return nil;
        }] copy];
        
        [WeiboSDK enableDebugMode:kDevelopMode];
        if ([WeiboSDK registerApp:__gs_wbappkey] == NO)
            WARN("微博 SDK 注册失败");
        else
            INFO("微博 SDK 注册成功");
    });
    
    self.appkey = __gs_wbappkey;
    self.shareByServer = YES;
    self.platformid = @"WEIBO";
    
    [[UIAppDelegate shared].signals connect:kSignalAppUrlGot withSelector:@selector(cbOpenURL:) ofTarget:self];
}

- (void)onFin {
    ZERO_RELEASE(_appkey);
    [super onFin];
}

- (void)cbOpenURL:(SSlot*)s {
    NSURL* url = s.data.object;
    [WeiboSDK handleOpenURL:url delegate:self];
    [s.tunnel veto];
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    [WeiboSDK sendRequest:request];
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {    
    if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        if (response.statusCode < 0)
        {
            [self authFailed];
        }
        else
        {
            WBAuthorizeResponse* respn = (id)response;
            [self.data setObject:respn.accessToken forKey:@"access_token" def:nil];
            [self.data setObject:respn.expirationDate forKey:@"expiration_date" def:nil];
            [self.data setObject:respn.userID forKey:@"userid" def:nil];
            [self.data setObject:respn.refreshToken forKey:@"refresh_token" def:nil];
            [self.data setBool:true forKey:kSnsPlatformBindedKey];
            
            [self save];
            [self.signals emit:kSignalSnsBindSucceed withResult:self.data];
        }
    }
    
    SAFE_RELEASE(self);
}

- (void)authFailed {
    LOG("授权失败");
    [self.data setBool:false forKey:kSnsPlatformBindedKey];
    [self save];
    [self.signals emit:kSignalSnsBindFailed];
}

- (void)bind {
    SAFE_RETAIN(self);
    
    WBAuthorizeRequest* req = [WBAuthorizeRequest request];
    req.redirectURI = kWeiboAppRedirectURI;
    req.scope = @"all";
    [WeiboSDK sendRequest:req];
}

- (void)shareBySDK:(SnsContent *)content {
    [WBHttpRequest requestForShareAStatus:content.text
                        contatinsAPicture:nil
                             orPictureUrl:content.image.url.httpPath
                          withAccessToken:[self.data getString:@"access_token"]
                       andOtherProperties:nil
                                    queue:nil
                    withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                        if (error) {
                            [error log];
                            [self.signals emit:kSignalSnsShareFailed withResult:error];
                        } else {
                            LOG("分享成功");
                            [self.signals emit:kSignalSnsShareSucceed];
                        }
                    }];
}

- (void)userinfo {
    [WBHttpRequest requestForUserProfile:[self.data getString:@"userid"]
                         withAccessToken:[self.data getString:@"access_token"]
                      andOtherProperties:nil
                                   queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, WeiboUser* result, NSError *error) {
                                       if (error) {
                                           [error log];
                                       } else {
                                           SnsUser* user = [SnsUser temporary];
                                           user.uid = result.userID;
                                           user.nickname = result.screenName;
                                           user.username = result.name;
                                           user.avatar = result.profileImageUrl;
                                           user.gender = [result.gender isEqualToString:@"m"];
                                           [self.signals emit:kSignalSnsUserInfo withResult:user];
                                       }
                                   }];
}

@end

@implementation SnsWeixin

static NSString* __gs_wxappkey = nil;

- (void)onInit {
    [super onInit];
    
    DISPATCH_ONCE_EXPRESS({
        NSArray* schemes = [UIApplication sharedApplication].appSchemes;
        __gs_wxappkey = [[schemes objectWithQuery:^id(NSString* l) {
            if ([l hasPrefix:@"wx"])
                return l;
            return nil;
        }] copy];
        
        if ([WXApi registerApp:__gs_wxappkey])
            INFO("微信注册成功");
        else
            WARN("微信注册失败");
    
        [self checkWeixinEnable];
    });
    
    self.platformid = @"WEIXIN";
    self.appkey = __gs_wxappkey;
}

- (void)onFin {
    ZERO_RELEASE(_appkey);
    [super onFin];
}

- (void)setShareByServer:(BOOL)shareByServer {
    [super setShareByServer:NO];
}

- (BOOL)checkWeixinEnable {
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        return YES;
    }
    else if (![WXApi isWXAppInstalled]) {
        [UIHud Text:@"没有安装微信"];
    }
    else if (![WXApi isWXAppSupportApi]) {
        [UIHud Text:@"当前微信版本不支持此操作,请更新至最新版本！"];
    }
    return NO;
}

- (void)shareBySDK:(SnsContent *)content {
    UIActionSheetExt* as = [UIActionSheetExt temporary];
    [[as addItem:@"用微信发给朋友"].signals connect:kSignalClicked withBlock:^(SSlot *s) {
        [self sendToFriend:content];
    }];
    [[as addItem:@"分享到微信朋友圈"].signals connect:kSignalClicked withBlock:^(SSlot *s) {
        [self sendToCircle:content];
    }];
    [[as addItem:@"收藏到微信"].signals connect:kSignalClicked withBlock:^(SSlot *s) {
        [self sendToCollection:content];
    }];
    [as addCancel:@"取消"];
    [as show];
}

- (SendMessageToWXReq*)wxmsgFromContent:(SnsContent*)content {
    SendMessageToWXReq* req = [SendMessageToWXReq temporary];
    if (content.isMultimedia)
    {
        [UIHud ShowProgress];
        
        // 发送图片分享
        if (content.image.notEmpty)
        {
            WXMediaMessage* msg = [WXMediaMessage message];
            UIImage* img = [UIImage imageWithContentOfDataSource:content.image];
            msg.thumbData = UIImageJPEGRepresentation(img, 0.01);
            msg.title = content.hint;
            msg.description = content.text;
            
            if (content.callback != nil)
            {
                WXAppExtendObject* waeo = [WXAppExtendObject object];
                waeo.url = content.apphome;
                waeo.extInfo = content.callback;
                msg.mediaObject = waeo;
            }
            else if (content.url.notEmpty)
            {
                WXWebpageObject* wpo = [WXWebpageObject object];
                wpo.webpageUrl = content.url;
                msg.mediaObject = wpo;
            }
            
            req.message = msg;
            req.bText = NO;
        }
        else
        {
            req.text = content.text;
            req.bText = YES;
        }
        
        [UIHud HideProgress];
    }
    else
    {
        req.bText = YES;
        req.text = content.text;
    }
    return req;
}

- (void)sendToFriend:(SnsContent*)content {
    SendMessageToWXReq* req = [self wxmsgFromContent:content];
    req.scene = WXSceneSession;
    
    if ([WXApi sendReq:req]) {
        [self.signals emit:kSignalSnsShareSucceed withResult:content];
    } else {
        LOG("分享失败");
        [self.signals emit:kSignalSnsShareFailed];
    }
}

- (void)sendToCircle:(SnsContent *)content {
    SendMessageToWXReq* req = [self wxmsgFromContent:content];
    req.scene = WXSceneTimeline;
    
    if ([WXApi sendReq:req]) {
        [self.signals emit:kSignalSnsShareSucceed withResult:content];
    } else {
        LOG("分享失败");
        [self.signals emit:kSignalSnsShareFailed];
    }
}

- (void)sendToCollection:(SnsContent *)content {
    SendMessageToWXReq* req = [self wxmsgFromContent:content];
    req.scene = WXSceneFavorite;
    
    if ([WXApi sendReq:req]) {
        [self.signals emit:kSignalSnsShareSucceed withResult:content];
    } else {
        LOG("分享失败");
        [self.signals emit:kSignalSnsShareFailed];
    }
}

- (void)onReq:(BaseReq*)req {
    LOG("WEIXIN Req");
}

- (void)onResp:(BaseResp*)resp {
    LOG("WEIXIN Resp");
}

- (BOOL)installed {
    return [WXApi isWXAppInstalled];
}

- (BOOL)supportapi {
    return [WXApi isWXAppSupportApi];
}

@end

@implementation SnsUser

- (void)onFin {
    ZERO_RELEASE(_uid);
    ZERO_RELEASE(_nickname);
    ZERO_RELEASE(_username);
    ZERO_RELEASE(_avatar);
    [super onFin];
}

@end
