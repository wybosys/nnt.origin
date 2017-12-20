
# ifndef __SNSPLATFORMS_CAB65B84F23344D5950C8F42DADB29D0_H_INCLUDED
# define __SNSPLATFORMS_CAB65B84F23344D5950C8F42DADB29D0_H_INCLUDED

/** @brief 用来承载分享的数据对象
 @note 业务层需要子类化自身业务需要的内容，之后所有的 send 都使用业务子类化的 content 来处理
 */
@interface SnsContent : NSObjectExt

/** 文字信息 */
@property (nonatomic, copy) NSString *text;

/** 简单提示 */
@property (nonatomic, copy) NSString *hint;

/** 分享出去的图片 */
@property (nonatomic, copy) NSDataSource *image;

/** 缩略图 */
@property (nonatomic, copy) NSDataSource *thumb;

/** 分享出去的语音 */
@property (nonatomic, copy) NSDataSource *voice;

/** 分享出去后，好友可以将依照该 url 进行跳转 */
@property (nonatomic, copy) NSString *url;

/** 提供给程序用来判断该内容是否是多媒体内容，很多平台多媒体和纯文字会走不通的流程 */
@property (nonatomic, readonly) BOOL isMultimedia;

/** 如果设置了callback，则某些分享渠道可以直接跳回业务 app，如果好友没有安装 app，则会导向该地址下载 */
@property (nonatomic, copy) NSString *apphome;

/** 从其他程序会跳到当前程序时带的数据，通常是附带在 openurl 后面传送回来 */
@property (nonatomic, copy) NSString *callback;

@end

@class SnsPlatform;
/** @brief 业务层需要实现改协议的内容
 @note 基础的 SNS 各个平台将通过回调 service 的功能来达到解耦合的目的
 */
@protocol SnsService <NSObject>

/** 保存和第三方交换的数据 */
- (void)saveTokens:(NSDictionary*)data platform:(SnsPlatform*)platform;

/** 读取持久化层中保存的该平台历史授权的数据 */
- (NSDictionary*)loadTokens:(SnsPlatform*)platform;

/** 清空持久化层中该平台的历史数据 */
- (void)clearTokens:(SnsPlatform*)platform;

@optional

/** 该平台是否已经绑定过 */
- (BOOL)isBinded:(SnsPlatform*)platform;

/** 连接一个平台处理的数据，当业务类实例化 SnsPlatform 时调用，来进行初始化的操作 */
- (void)attach:(SnsPlatform*)platform;

/** 使用服务端来进行分享 */
- (void)shareByServer:(SnsContent*)content platform:(SnsPlatform*)platform;

@end

/** @brief SNS 服务，需要业务层子类化来实现具体的业务
 @code
 @interface AppSnsService : AppSnsService @end
 .... [[AppSnsService shared] SetAsDefault] ...
 */
@interface SnsService : NSObjectExt

/** 设置为默认，和 SnsPlatform::SetDefaultService 功能相同 */
+ (void)SetAsDefault;

@end

/** @brief 第三方平台的基类 */
@interface SnsPlatform : NSObjectExt

/** 设置成默认的 Service
 必须在如下情况是业务层实现自己的service
 1，需要在登录后和服务器交换数据
 2，采用服务器端分享
 */
+ (void)SetDefaultService:(Class)cls;

/** 是否已经绑定 */
@property (nonatomic, readonly) BOOL isBinded;

/** 平台的标记 */
@property (nonatomic, copy, readonly) NSString *platformid;

/** 是否通过服务器发送 */
@property (nonatomic, assign) BOOL shareByServer;

/** 绑定 */
- (void)bind;

/** 保存当前的授权数据到持久化 */
- (void)save;

/** 从持久化层中读取授权数据 */
- (void)load;

/** 清空持久化层中的授权数据 */
- (void)clear;

/** 绑定成功后调用回调 */
- (void)bind:(void(^)())success;

/** 向第三方平台分享数据，content 在业务层中需要为业务子类化的实体 */
- (void)share:(SnsContent*)content;

@end

SIGNAL_DECL(kSignalSnsBindSucceed) @"::sns::bind::success";
SIGNAL_DECL(kSignalSnsBindFailed) @"::sns::bind::failed";
SIGNAL_DECL(kSignalSnsShareSucceed) @"::sns::share::success";
SIGNAL_DECL(kSignalSnsShareFailed) @"::sns::share::failed";
SIGNAL_DECL(kSignalSnsSsoLogined) @"::sns::ssologin::done";

SIGNAL_DECL(kSignalRequestShare) @"::sns::share::request";
SIGNAL_DECL(kSignalSnsUserInfo) @"::sns::api::userinfo";

extern NSString* kSnsPlatformBindedKey;

@interface SnsQQ : SnsPlatform

/** 注册的 appid，如果不设置将使用从 Infoplist 重探知的 id */
@property (nonatomic, retain) NSString *clientid;

/** 获得用户信息 */
- (void)userinfo;

/** 是否可用 */
+ (BOOL)isAvaliable;

@end

extern NSString* kWeiboAppRedirectURI;

@interface SnsWeibo : SnsPlatform

/** 注册的 appkey，如果不设置将使用从 Infoplist 重探知的 key */
@property (nonatomic, retain) NSString *appkey;

/** 获得用户信息 */
- (void)userinfo;

@end

@interface SnsWeixin : SnsPlatform

/** 注册的 appkey，如果不设置将使用从 Infoplist 重探知的 key */
@property (nonatomic, retain) NSString *appkey;

/** 发送到朋友圈 */
- (void)sendToCircle:(SnsContent*)content;

/** 发送给朋友 */
- (void)sendToFriend:(SnsContent*)content;

/** 收藏到微信 */
- (void)sendToCollection:(SnsContent*)content;

@end

@interface SnsUser : NSObjectExt

@property (nonatomic, copy) NSString *uid, *nickname, *username, *avatar;
@property (nonatomic, assign) int gender;

@end

# endif
