
# ifndef __APISESSION_405E7951BBE84A51B1B038A84285E4DB_H_INCLUDED
# define __APISESSION_405E7951BBE84A51B1B038A84285E4DB_H_INCLUDED

# import "NetObj.h"
# import "NSMemCache.h"

@interface SNetObj : NSObject

@property (nonatomic, assign) BOOL showWaiting;
@property (nonatomic, copy) NSString *errorMessage;
@property (nonatomic, assign) NSObject<NetObj>* netobj;
@property (nonatomic, retain) NSDictionary* data;

- (SNetObj*)initWith:(NSObject<NetObj>*)netobj;

SIGNALS;

@end

// 正在请求数据
SIGNAL_DECL(kSignalApiRequesting) @"::netobj::api::requesting";

// Api 调用成功
SIGNAL_DECL(kSignalApiSucceed) @"::netobj::api::succeed";

// Api 调用失败
SIGNAL_DECL(kSignalApiFailed) @"::netobj::api::failed";

// Api 调用结束（失败或成功都会激活，可以在这里面进行回收到操作）
SIGNAL_DECL(kSignalApiProcessed) @"::netobj::api::processed";

// Api 将数据发送到服务器的进度
SIGNAL_DECL(kSignalApiSendProgress) @"::netobj::api::progress::send";

// Api 从服务器获取数据返回的进度
SIGNAL_DECL(kSignalApiReceiveProgress) @"::netobj::api::progress::receive";

# ifdef DEBUG_MODE
#   define kSignalApiTest kSignalApiProcessed
# endif

@interface SNetObjs : NSObject

@property (nonatomic, assign) BOOL showWaiting;
@property (nonatomic, copy) NSString *errorMessage;
@property (nonatomic, retain) NSArray *netobjs;

@end

extern int ApiReferrer;

@interface ApiSession : NSObject

// 获得对象
+ (ApiSession*)shared;

// 是否打开缓存支持，默认为YES
@property (nonatomic, assign) BOOL enableCache;

// 各种获取函数，注意后面的回调都是立即回调，成功、失败的都是通过 signals 途径处理
- (void)fetch:(id<NetObj>)obj with:(void(^)(SNetObj* s))block;
- (void)fetch:(id<NetObj>)obj withSelector:(SEL)sel withTarget:(id)target;
- (void)send:(id<NetObj>)obj;

// 投递，会veto掉failed消息
- (void)post:(id<NetObj>)obj;
- (void)post:(id<NetObj>)obj with:(void(^)(SNetObj* s))block;

// 同步获取接口返回的数据，会强制打开wait
- (BOOL)get:(id<NetObj>)obj;

// 一次性获取多个api
- (void)fetchs:(NSArray*)objs with:(void(^)(SNetObjs* s))block;

@property (nonatomic, readonly) NSString *sessionid;
@property (nonatomic, readonly) NSArray *cookies;
@property (nonatomic, copy) NSString *httpAgent;

// 清空cookie
- (void)clearCookies;

// 是否有cookie
+ (BOOL)HasCookies;

@end

SIGNAL_DECL(kSignalApiAllCompleted) @"::apisession::allcompleted";

# define APISESSION_FETCH(ul, exp) \
{ \
SNetObj* m = [[SNetObj alloc] initWith:ul]; \
exp; \
[[ApiSession shared] fetch:m]; \
SAFE_RELEASE(m); \
}

# endif
