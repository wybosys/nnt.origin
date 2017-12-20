
# import "app.h"
# import "PracticeSnsPlatform.h"

// 数据实现
# import "NetDefine.h"
# import "AppContext.h"
# import "UserSsologin.h"
# import "UserSsobind.h"
# import "ApiSession.h"
# import "ForwardSend.h"
# import "ForwardTransferlog.h"

NSString* kWeiboAppRedirectURI = @"http://api.gamexhb.com/callback/weibo";

@implementation PracticeSnsService

SHARED_IMPL;

- (void)attach:(SnsPlatform *)platform {
    [platform.signals connect:kSignalSnsBindSucceed withSelector:@selector(cbBindSucceed:) ofTarget:self];
    [platform.signals connect:kSignalSnsShareSucceed withSelector:@selector(cbShared:) ofTarget:self];
}

- (void)saveTokens:(NSDictionary *)data platform:(SnsPlatform *)platform {
    [[AppContext shared].curUser.storage setObject:data
                                            forKey:[NSString stringWithFormat:@"::snsplatform::%@::data", platform.platformid]];
}

- (NSDictionary*)loadTokens:(SnsPlatform*)platform {
    id obj = [[AppContext shared].curUser.storage getObjectForKey:[NSString stringWithFormat:@"::snsplatform::%@::data", platform.platformid] def:nil];
    return obj;
}

- (void)clearTokens:(SnsPlatform*)platform {
    [AppContext shared].curUser.bindplatformlist = [[AppContext shared].curUser.bindplatformlist arrayWithFilter:^BOOL(NSString* l) {
        return [l isEqualToString:platform.platformid] == NO;
    }];
}

- (BOOL)isBinded:(SnsPlatform *)platform {
    return [[AppContext shared].curUser isBinded:platform.platformid];
}

- (void)cbBindSucceed:(SSlot*)s {
    SnsPlatform* sp = (id)s.sender;
    NSDictionary* data = s.data.object;
    
    // 第三方登录
    if ([AppContext shared].curUser.logined == NO)
    {
        UserSsologin* usl = [UserSsologin temporary];
        usl.in_appid = [AppContext shared].curApp.idApp;
        usl.in_channelid = [AppContext shared].curApp.idChannel;
        usl.in_equipmentid = [AppContext shared].curDevice.equipid;
        usl.in_applicationversion = [AppContext shared].curApp.version;
        usl.in_cellbrand = [AppContext shared].curDevice.cellbrand;
        usl.in_cellmodel = [AppContext shared].curDevice.cellmodel;
        usl.in_mac = [AppContext shared].curDevice.macaddr;
        usl.in_systemversion = [AppContext shared].curDevice.sysversion;
        usl.in_platform = sp.platformid;
        
        if ([data objectForKey:@"access_token"])
            usl.in_accesstoken = [data getString:@"access_token"];
        if ([data objectForKey:@"access_secret"])
            usl.in_accesssecret = [data getString:@"access_secret"];
        if ([data objectForKey:@"expiration_date"])
            usl.in_expiretime = (long)[(NSDate*)[data objectForKey:@"expiration_date"] timestamp];
        if ([data objectForKey:@"refresh_token"])
            usl.in_refreshtoken = [data getString:@"refresh_token"];
        if ([data objectForKey:@"userid"])
            usl.in_uid = [data getString:@"userid"];
        if ([data objectForKey:@"username"])
            usl.in_username = [data getString:@"username"];
        
        [[ApiSession shared] fetch:usl with:^(SNetObj *m) {
            m.showWaiting = YES;
            [m.signals connect:kSignalApiSucceed withBlock:^(SSlot *s) {
                // 调用接口后即代表登录
                [sp.signals emit:kSignalSnsSsoLogined withResult:s.data.object];
                
                // 写入bindplatforms
                [[AppContext shared].curUser.bindplatformlist addObject:sp.platformid];
            }];
        }];
    }
    else
    {
        // 第三方绑定
        UserSsobind* usb = [UserSsobind temporary];
        usb.in_platform = sp.platformid;
        
        if ([data objectForKey:@"access_token"])
            usb.in_accesstoken = [data getString:@"access_token"];
        if ([data objectForKey:@"access_secret"])
            usb.in_accesssecret = [data getString:@"access_secret"];
        if ([data objectForKey:@"expiration_date"])
            usb.in_expiretime = (long)[(NSDate*)[data objectForKey:@"expiration_date"] timestamp];
        if ([data objectForKey:@"refresh_token"])
            usb.in_refreshtoken = [data getString:@"refresh_token"];
        if ([data objectForKey:@"userid"])
            usb.in_uid = [data getString:@"userid"];
        if ([data objectForKey:@"username"])
            usb.in_username = [data getString:@"username"];
        
        [[ApiSession shared] fetch:usb with:^(SNetObj *m) {
            m.showWaiting = YES;
            [m.signals connect:kSignalApiSucceed withBlock:^(SSlot *s) {
                // 写入bindplatforms
                [[AppContext shared].curUser.bindplatformlist addObject:sp.platformid];
            }];
        }];
    }
}

- (void)cbShared:(SSlot*)s {
    SnsPlatform* sp = (id)s.sender;
    PracticeSnsContent* sc = s.data.object;
    if (sc.resid.notEmpty == NO)
        return;
    ForwardTransferlog* ftl = [ForwardTransferlog temporary];
    ftl.in_platformlist = sp.platformid;
    ftl.in_resid = sc.resid;
    [[ApiSession shared] post:ftl];
}

- (void)shareByServer:(PracticeSnsContent *)content platform:(SnsPlatform *)platform {
    ForwardSend* fs = [ForwardSend temporary];
    fs.in_title = content.hint;
    fs.in_platformlist = platform.platformid;
    fs.in_voice = content.voice.url.absoluteString;
    fs.in_resid = content.resid;
    fs.in_picture = content.image.url.absoluteString;
    fs.in_comment = @"";
    fs.in_message = content.text;
    [[ApiSession shared] fetch:fs with:^(SNetObj *m) {
        m.showWaiting = YES;
        [m.signals connect:kSignalApiSucceed withBlock:^(SSlot *s) {
            [self.signals emit:kSignalSnsShareSucceed withResult:content];
        }];
        [m.signals connect:kSignalApiFailed withBlock:^(SSlot *s) {
            [self.signals emit:kSignalSnsShareFailed];
        }];
    }];
}

@end

@implementation PracticeSnsContent

- (void)onInit {
    [super onInit];
}

- (void)onFin {
    ZERO_RELEASE(_resid);
    [super onFin];
}

@end
