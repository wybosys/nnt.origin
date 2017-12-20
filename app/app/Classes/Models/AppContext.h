
# ifndef __APPCONTEXT_D1EF5ACC931B4ECA92FEA1ECDC15B3A6_H_INCLUDED
# define __APPCONTEXT_D1EF5ACC931B4ECA92FEA1ECDC15B3A6_H_INCLUDED

# import "ModelTypes.h"

@interface AppContext : NSObject

SIGNALS;

@property (nonatomic, readonly) App* curApp;
@property (nonatomic, readonly) UserData* curUser;
@property (nonatomic, readonly) Device* curDevice;
@property (nonatomic, readonly) Perferences* curPerferences;
@property (nonatomic, readonly) Beep* curBeep;

+ (AppContext*)shared;

// 登录
- (void)login;
- (void)autologin;

- (void)loginByData:(LoginOutputData*)m;
- (void)logout;

@end

SIGNAL_DECL(kSignalUserNeedCompleteInfo) @"::user::need::complete::info";
SIGNAL_DECL(kSignalUserLogined) @"::user::logined";
SIGNAL_DECL(kSignalUserAutoLoginFailed) @"::user::auto::login::failed";
SIGNAL_DECL(kSignalUserLogout) @"::user::logout";
SIGNAL_DECL(kSignalMessageReceived) @"::ctx::rte::message::received";
SIGNAL_DECL(kSignalMessageSkipped) @"::ctx::rte::message::skipped";
SIGNAL_DECL(kSignalManyMessagesReceived) @"::ctx::rte::messages::many::received";
SIGNAL_DECL(kSignalManyMessagesSkipped) @"::ctx::rte::messages::many::skipped";
SIGNAL_DECL(kSignalRpcReceived) @"::ctx::rte::rpc::received";
SIGNAL_DECL(kSignalXpChangedNotification) @"::ctx::rte::xpchanged";

# endif
