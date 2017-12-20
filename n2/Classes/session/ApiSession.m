
# import "Common.h"
# import "ApiSession.h"
# import "NSTypes+Extension.h"
# import "NSMemCache.h"
# import "ASINetworkQueue.h"
# import "NetModel.h"
# import "NSStorage.h"
# import "AppDelegate+Extension.h"

@interface ASIFormDataRequest (memcache)

@end

@implementation ASIFormDataRequest (memcache)

- (NSString*)uniqueKey {
    NSMutableArray* values = [[NSMutableArray alloc] init];
    
    [values addObject:self.url.absoluteString];
    [values addObjectsFromArray:self.postData];
    
    NSString* ret = [values componentsJoinedByString:@"#||#"];
    
    SAFE_RELEASE(values);
    
    return ret;
}

@end

@interface NetModel ()

- (void)dataRequestSuccessed:(ASIHTTPRequest *)request;

@end

@interface NetModelExt : NetModel

@property (nonatomic, readonly) NSMutableDictionary *cookiesResponse;

- (void)dataRequestSuccessed:(ASIHTTPRequest *)request;

@end

@implementation NetModelExt

- (id)init {
    self = [super init];
    
    _cookiesResponse = [[NSMutableDictionary alloc] init];
    [self loadCookies];
    
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_cookiesResponse);
    
    [super dealloc];
}

- (void)dataRequestSuccessed:(ASIHTTPRequest *)request {
    if (request.responseCookies.count)
    {
        BOOL changed = NO;
        
        // 得到 cookie
        for (NSHTTPCookie* each in request.responseCookies)
        {
            NSHTTPCookie* old = [_cookiesResponse objectForKey:each.name];
            if ([old isEqual:each])
                continue;
            
            [_cookiesResponse setObject:each forKey:each.name];
            changed = YES;
            //if ([each.name isEqualToString:@"hd"])
            //    LOG("HD Cookie: %s", each.value.UTF8String);
        }
        
        if (changed)
            [self saveCookies];
    }
    
    [super dataRequestSuccessed:request];
}

- (ASIFormDataRequest*)beginRequest:(NSString *)url {
    ASIFormDataRequest* req = [super beginRequest:url];
    //req.useCookiePersistence = YES; 对于重新启动进程没用
    
    // 设置 cookie
    [req.requestCookies addObjectsFromArray:_cookiesResponse.allValues];
    
    return req;
}

- (void)encryptRequest:(ASIFormDataRequest *)request netobj:(id)netobj {
    PASS;
}

- (void)saveCookies {
    NSArray* arr = [_cookiesResponse.allValues arrayWithCollector:^id(NSHTTPCookie* l) {
        return l.properties;
    }];
    [[NSStorageExt shared] setObject:arr forKey:@"::api::session::http::cookies"];
}

- (void)loadCookies {
    NSArray* arr = [[NSStorageExt shared] getObjectForKey:@"::api::session::http::cookies" def:nil];
    if (arr.count == 0)
        return;
    arr = [arr arrayWithCollector:^id(NSDictionary* l) {
        return [NSHTTPCookie cookieWithProperties:l];
    }];
    for (NSHTTPCookie* each in arr) {
        [_cookiesResponse setObject:each forKey:each.name];
    }
}

+ (void)ClearCookies {
    [[NSStorageExt shared] setObject:[NSArray temporary] forKey:@"::api::session::http::cookies"];
}

+ (BOOL)HasCookies {
    NSArray* arr = [[NSStorageExt shared] getObjectForKey:@"::api::session::http::cookies" def:nil];
    return arr.count != 0;
}

@end

@interface NSObject (SNetObj)

@property (nonatomic, retain) SNetObj* __ext_dynamic_SNetObj;

// 重新定义 NSObject (memcache) 中设置的属性
@property (nonatomic, assign) BOOL mcUpdated;
@property (nonatomic, assign) time_t mcTimestamp;

@end

@implementation NSObject (SNetObj)

NSOBJECT_DYNAMIC_PROPERTY(NSObject_SNetObj, __ext_dynamic_SNetObj, set__ext_dynamic_SNetObj, RETAIN_NONATOMIC);

// 由位于 memcache 中的实现
@dynamic mcUpdated, mcTimestamp;

@end

@implementation SNetObj

- (id)init {
    self = [super init];
    return self;
}

- (id)initWith:(NSObject<NetObj>*)netobj {
    self = [self init];
    self.netobj = netobj;
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_data);
    // 其他地方有可能会连接对象，保护清空
    [self.attachment removeAllObjects];
    [super dealloc];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalApiRequesting)
SIGNAL_ADD(kSignalApiSucceed)
SIGNAL_ADD(kSignalApiFailed)
SIGNAL_ADD(kSignalApiProcessed);
SIGNAL_ADD(kSignalApiSendProgress)
SIGNAL_ADD(kSignalApiReceiveProgress)
SIGNALS_END

- (void)setNetobj:(NSObject<NetObj>*)netobj {
    if (netobj == _netobj)
        return;
    netobj.__ext_dynamic_SNetObj = self;
    _netobj = netobj;
}

- (void)setErrorMessage:(NSString *)errorMessage {
    _netobj.errorMessage = errorMessage;
}

- (NSString*)errorMessage {
    return _netobj.errorMessage;
}

// 缓存设置转至netobj

- (void)setMcFlush:(BOOL)mcFlush {
    _netobj.mcFlush = mcFlush;
}

- (BOOL)mcFlush {
    return _netobj.mcFlush;
}

- (void)setMcTimestamp:(time_t)mcTimestamp {
    _netobj.mcTimestamp = mcTimestamp;
}

- (time_t)mcTimestamp {
    return _netobj.mcTimestamp;
}

- (void)setMcTimestampOverdue:(time_t)mcTimestampOverdue {
    _netobj.mcTimestampOverdue = mcTimestampOverdue;
}

- (time_t)mcTimestampOverdue {
    return _netobj.mcTimestampOverdue;
}

- (void)setMcUpdated:(BOOL)mcUpdated {
    _netobj.mcUpdated = mcUpdated;
}

- (BOOL)mcUpdated {
    return _netobj.mcUpdated;
}

- (void)setUniqueKey:(NSString *)uniqueKey {
    _netobj.uniqueKey = uniqueKey;
}

- (NSString*)uniqueKey {
    return _netobj.uniqueKey;
}

- (void)setUniqueKeyAddition:(NSString *)uniqueKeyAddition {
    _netobj.uniqueKeyAddition = uniqueKeyAddition;
}

- (NSString*)uniqueKeyAddition {
    return _netobj.uniqueKeyAddition;
}

- (void)setUniqueValue:(id)uniqueValue {
    _netobj.uniqueValue = uniqueValue;
}

- (id)uniqueValue {
    return _netobj.uniqueValue;
}

@end

@interface SNetObjs () {
    int _pos;
    bool _failed;
}

@property (nonatomic, assign) ApiSession *session;

@end

@implementation SNetObjs

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_errorMessage);
    ZERO_RELEASE(_netobjs);
    
    [super dealloc];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalApiRequesting)
SIGNAL_ADD(kSignalApiSucceed)
SIGNAL_ADD(kSignalApiFailed)
SIGNAL_ADD(kSignalApiProcessed);
SIGNALS_END

- (void)execute {
    _pos = 0;
    _failed = false;
    
    id no = [self.netobjs objectAtIndex:_pos def:nil];
    if (no == nil)
        return;
    
    [self.signals emit:kSignalApiRequesting withResult:self.netobjs];
    
    __block BOOL sw = self.showWaiting;
    [self.session fetch:no with:^(SNetObj *m) {
        m.showWaiting = sw;
        [m.signals connect:kSignalApiSucceed withSelector:@selector(__multis_success:) ofTarget:self];
        [m.signals connect:kSignalApiFailed withSelector:@selector(__multis_failed:) ofTarget:self];
        [m.signals connect:kSignalApiProcessed withSelector:@selector(__multis_processed:) ofTarget:self];
    }];
    
    SAFE_RETAIN(self);
}

- (void)__multis_success:(SSlot*)s {
    ++_pos;
    
    if (_pos == self.netobjs.count) {
        // all success.
        [self.signals emit:kSignalApiSucceed withResult:self.netobjs];
        return;
    }
    
    id no = [self.netobjs objectAtIndex:_pos def:nil];
    if (no == nil)
        return;
    
    __block BOOL sw = self.showWaiting;
    [self.session fetch:no with:^(SNetObj *m) {
        m.showWaiting = sw;
        [m.signals connect:kSignalApiSucceed withSelector:@selector(__multis_success:) ofTarget:self];
        [m.signals connect:kSignalApiFailed withSelector:@selector(__multis_failed:) ofTarget:self];
        [m.signals connect:kSignalApiProcessed withSelector:@selector(__multis_processed:) ofTarget:self];
    }];
}

- (void)__multis_failed:(SSlot*)s {
    SNetObj* no = (SNetObj*)s.sender;
    self.errorMessage = no.errorMessage;
    [self.signals emit:kSignalApiFailed withResult:self.netobjs];
    [self.signals emit:kSignalApiProcessed withResult:self.netobjs];
    _failed = true;
}

- (void)__multis_processed:(SSlot*)s {
    if (_pos == self.netobjs.count) {
        [self.signals emit:kSignalApiProcessed withResult:self.netobjs];
        SAFE_RELEASE(self);
        return;
    }
    
    if (_failed)
        SAFE_RELEASE(self);
}

@end

@interface ApiSession () {
    NetModelExt* _nm;
}

@end

@interface ApiSession (pirvate)

@end

@implementation ApiSession (private)

- (void)request:(SNetObj*)obj {
    // 开始发送的信号
    [self.signals emit:kSignalApiRequesting withResult:obj.netobj];
    [obj.signals emit:kSignalApiRequesting withResult:obj.netobj];
    
    // 使用 netmodel 层来处理数据传输
    [_nm request_s:obj];
}

@end

@implementation ApiSession

- (id)init {
    self = [super init];
    
    _nm = [[NetModelExt alloc] init];
    _nm.networkQueue.maxConcurrentOperationCount = 3;
    _nm.delegate = self;
    
    // 连接到 processed 以判断是不是队列已经执行完毕
    [self.signals connect:kSignalApiProcessed withSelector:@selector(__cb_processed) ofTarget:self];
    
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_nm);
    ZERO_RELEASE(_httpAgent);
    
    [super dealloc];
}

SHARED_IMPL;

- (void)setHttpAgent:(NSString *)httpAgent {
    PROPERTY_COPY(_httpAgent, httpAgent);
    [NetModel setUserAgent:httpAgent];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalApiAllCompleted)
SIGNAL_ADD(kSignalApiRequesting)
SIGNAL_ADD(kSignalApiSucceed)
SIGNAL_ADD(kSignalApiFailed)
SIGNAL_ADD(kSignalApiProcessed)
SIGNALS_END

- (void)__cb_processed {
    if (_nm.networkQueue.operationCount == 0) {
        [self.signals emit:kSignalApiAllCompleted];
    }
}

- (void)doFetch:(NSArray*)params {
    NSObject<NetObj>* netobj = params.firstObject;
    SNetObj* obj = params.secondObject;
    
    if (netobj == nil || obj == nil)
        return;
    
    // 是否需要显示waiting
    if (obj.showWaiting) {
        [obj.signals connect:kSignalApiRequesting withSelector:@selector(ShowProgress) ofClass:[UIHud class]];
        [obj.signals connect:kSignalApiProcessed withSelector:@selector(HideProgress) ofClass:[UIHud class]];
    }
    
    // 使用缓存
    NSMemCache* mc = [NSMemCache defaults];
    
    // 如果属于刷新用，则不适用缓存
    if (mc) {
        
        // 生成缓存使用的key
        // 注意由于 in_param 的改变会引起 key 的变化
        // 临时 asi 生成缓存 Key, 有可能输入的数值已经产生变动
        ASIFormDataRequest* tmpreq = [_nm beginRequest:[netobj getUrl]];
        [netobj initRequest:tmpreq];
        NSString* key = [tmpreq uniqueKey];
        obj.uniqueKey = key;
        
        if ([netobj mcTimestampOverdue] == 0) {
            
            if ([netobj mcFlush] == YES) {
                // 如果此次是刷新, 则取上一次缓存设置的过期时间
                id old = [mc getObject:key];
                if (old) {
                    [netobj setMcTimestampOverdue:[old mcTimestampOverdue]];
                }
                
                if (old == nil)
                    mc = nil;
                
            } else {
                // 如果没有设置过期时间，则不适用缓存
                mc = nil;
            }
        }
        
        // 此次是用来刷新
        if (mc && [netobj mcFlush])
            mc = nil;
        
    }
    
    if (mc == nil) {
        // 没有缓存
        [self request:obj];
        return;
    }
    
    // 取得全尺寸的uniquekey
    NSString* key = obj.fullUniqueKey;
    
    // 锁住缓存的对应键
    //[mc keyLock:key];
    
    // 拿到缓存中得数据
    id data = [[mc getObject:key] retain];
    
    // 判断缓存数据的失效期和当前的比对
    if ([data mcTimestampOverdue] > [netobj mcTimestampOverdue]) {
        [data setMcTimestampOverdue:[netobj mcTimestampOverdue]];
        if ([data mcOverdued]) {
            LOG("缓存中得数据比当前请求的数据失效期长，跳过缓存，重新获得数据");
            ZERO_RELEASE(data);
        }
    }
    
    // 缓存命中失败
    if (data == nil) {
        [self request:obj];
        return;
    }
    
    // 解锁缓存
    //[mc keyUnlock:key];
    netobj.isRequested = YES;
    
    // 模拟消息
    [self.signals emit:kSignalApiRequesting withResult:netobj];
    [obj.signals emit:kSignalApiRequesting withResult:netobj];
    
    // 解析数据
    [netobj parse:data];
    
    // 刷新过期管理信息
    [netobj setMcTimestamp:[data mcTimestamp]];
    [netobj setMcTimestampOverdue:[data mcTimestampOverdue]];
    [netobj setMcUpdated:[data mcUpdated]];
    
    // 成功的信号
    [self.signals emit:kSignalApiSucceed withResult:netobj];
    [obj.signals emit:kSignalApiSucceed withResult:netobj];
    [self.signals emit:kSignalApiProcessed withResult:netobj];
    [obj.signals emit:kSignalApiProcessed withResult:netobj];
    
    // 解保护
    ZERO_RELEASE(data);
}

- (void)fetch:(SNetObj *)obj {
    // 默认在工作线程中处理数据
    [self performSelectorInBackground:@selector(doFetch:) withObject:[NSArray arrayWithObjects:obj.netobj, obj, nil]];
}

- (void)fetch:(id<NetObj>)obj with:(void (^)(SNetObj *))block {
    SNetObj* m = [[SNetObj alloc] initWith:obj];
    block(m);
    [self fetch:m];
    SAFE_RELEASE(m);
}

- (void)fetch:(id<NetObj>)obj withSelector:(SEL)sel withTarget:(id)target {
    SNetObj* m = [[SNetObj alloc] initWith:obj];
    [target performSelector:sel withObject:m];
    [self fetch:m];
    SAFE_RELEASE(m);
}

- (void)send:(id<NetObj>)obj {
    [self fetch:obj with:^(SNetObj *m) {}];
}

- (void)post:(id<NetObj>)obj {
    [self fetch:obj with:^(SNetObj *m) {
        [m.signals connect:kSignalApiFailed withBlock:^(SSlot *s) {
            [s.tunnel veto];
        }];
    }];
}

- (void)post:(id<NetObj>)obj with:(void (^)(SNetObj *))block {
    [self fetch:obj with:^(SNetObj *m) {
        [m.signals connect:kSignalApiFailed withBlock:^(SSlot *s) {
            [s.tunnel veto];
        }];
        block(m);
    }];
}

- (BOOL)get:(id<NetObj>)obj {
    NSSyncLoop* loop = [NSSyncLoop temporary];
    __block BOOL ret = NO;
    [self fetch:obj with:^(SNetObj *m) {
        m.showWaiting = YES;
        [m.signals connect:kSignalApiSucceed withBlock:^(SSlot *s) {
            ret = YES;
        }];
        [m.signals connect:kSignalApiProcessed withSelector:@selector(continuee) ofTarget:loop];
    }];
    [loop wait];
    return ret;
}

# pragma mark NetModel Delegate

- (void)apiSuccessed:(NSObject<NetObj>*)netobj ForApi:(NSString*)api {
    SNetObj* sno = (SNetObj*)netobj.__ext_dynamic_SNetObj;
    if (sno == nil)
        return;

    netobj.isRequested = YES;
    [self.signals emit:kSignalApiSucceed withResult:sno.netobj];
    [sno.signals emit:kSignalApiSucceed withResult:sno.netobj];
    [self.signals emit:kSignalApiProcessed withResult:sno.netobj];
    [sno.signals emit:kSignalApiProcessed withResult:sno.netobj];
}

- (void)apiSuccessedWithDictionary:(NSDictionary*)dict ForApi:(NSString*) api {
# ifdef DEBUG_MODE
    
    NSString* msg = [dict jsonString].prettyString;
    msg = [NSString stringWithFormat:@"API %@ 返回 %@", api, msg];
    msg = msg.urldecode;
    if (msg) {
        LOG(msg.UTF8String);
    }
    
# endif
}

- (void)apiSuccessed:(id)netobj ForDictionary:(NSDictionary*)dict {
    SNetObj* sno = (SNetObj*)((NSObject*)netobj).__ext_dynamic_SNetObj;
    if (sno != nil)
    {
        // 缓存用的key
        NSString* key = sno.fullUniqueKey;
        
        if (key) {
        
            // 缓存数据
            NSMemCache* mc = [NSMemCache defaults];
            
            if (mc) {
            
                // 没有设置过期参数
                if ([(id)sno.netobj mcTimestampOverdue] == 0) {
                    mc = nil;
                }
            
                if (mc) {
            
                    dict.mcTimestamp = [NSTime Now];
                    dict.mcTimestampOverdue = [(id)sno.netobj mcTimestampOverdue];
                    [netobj setMcUpdated:dict.mcUpdated];
                    
                    // 插入数据
                    [mc addObject:dict withKey:key];
                    
                    // 解锁
                    //[mc keyUnlock:key];
            
                }
                
            }
            
        }
    }
    
    // 保存服务器返回的对象，以便后续处理
    sno.data = [dict objectForKey:@"data"];
}

- (void)apiFailed:(NSObject<NetObj>*)netobj WithMsg:(NSString *)msg {
    SNetObj* sno = (SNetObj*)netobj.__ext_dynamic_SNetObj;
    if (sno == nil)
        return;
    
    sno.errorMessage = msg;
    netobj.isRequested = YES;
    
    // 缓存数据
    NSMemCache* mc = [NSMemCache defaults];
    
    // 没有设置过期参数
    if ([(id)sno.netobj mcTimestampOverdue] == 0) {
        mc = nil;
    }
    
    // 是否可以从缓存中恢复
    BOOL retrFromCache = NO;
    
    NSString* key = sno.fullUniqueKey;
    if (mc && key) {
        // 虽然api访问失败，但是由于缓存的存在，可以从缓存中恢复之前的数据返回给界面处理
        id data = [mc getObjectDirect:key];
        
        // 解锁
        //[mc keyUnlock:key];
        
        if (data) {
            
            // 解析数据
            [sno.netobj parse:data];
            [(id)sno.netobj setMcUpdated:[data mcUpdated]];
            
            retrFromCache = YES;
        }
    }
    
    if (retrFromCache == NO) {
        
        // 可以通过tunnel技术来操作失败的流程
        SSlotTunnel* tun = [[SSlotTunnel alloc] init];
        
        // 失败的信号
        [sno.signals emit:kSignalApiFailed withResult:netobj withTunnel:tun];
        if (tun.vetoed == NO)
            [self.signals emit:kSignalApiFailed withResult:netobj];
        
        SAFE_RELEASE(tun);
        
        // processed 信号不会使用tun的特性，以防止数据泄露
        [sno.signals emit:kSignalApiProcessed withResult:netobj];
        [self.signals emit:kSignalApiProcessed withResult:netobj];
        
        // 显示一个错误提示
        LOG("ApiSession 收到错误返回: %s", msg.UTF8String);
        
    } else {
        
        // 成功的信号
        [self.signals emit:kSignalApiSucceed withResult:netobj];
        [sno.signals emit:kSignalApiSucceed withResult:netobj];
        [self.signals emit:kSignalApiProcessed withResult:netobj];
        [sno.signals emit:kSignalApiProcessed withResult:netobj];;
        
        LOG("API请求失败，但是从缓存中恢复了上一次API数据请求的结果");
    }
}

static id __gs_apifailed_alertview = nil;

- (void)apiFailed:(NSDictionary*)dict WithMsg:(NSString*)msg WithCode:(NSNumber*)codeobj {
    if (__gs_apifailed_alertview)
        return;
    dict = [dict getDictionary:@"data"];
    int code = [codeobj intValue];
    switch (code)
    {
        case -3:
        {
            UIAlertViewExt* al = [UIAlertViewExt temporary];
            al.title = @"提示";
            al.message = msg;
            [[al addItem:@"确定"].signals connect:kSignalClicked withBlock:^(SSlot *s) {
                [[UIAppDelegate shared] exit];
                __gs_apifailed_alertview = nil;
            }];
            [al show];
            __gs_apifailed_alertview = al;
        } break;
            
        case -4:
        {
            UIAlertViewExt* al = [UIAlertViewExt temporary];
            al.title = @"更新提示";
            al.message = msg;
            [[al addItem:@"退出"].signals connect:kSignalClicked withBlock:^(SSlot *s) {
                [[UIAppDelegate shared] exit];
                __gs_apifailed_alertview = nil;
            }];
            [[al addItem:@"更新"].signals connect:kSignalClicked withBlock:^(SSlot *s) {
                NSString* url = [dict getString:@"updateurl" def:[UIAppDelegate shared].appstoreURL];
                [[UIApplication sharedApplication] openHttp:url];
                __gs_apifailed_alertview = nil;
            }];
            [al show];
            __gs_apifailed_alertview = al;
        } break;
            
        case -4004:
        {
            UIAlertViewExt* al = [UIAlertViewExt temporary];
            al.title = @"系统维护";
            al.message = msg;
            [[al addItem:@"退出"].signals connect:kSignalClicked withBlock:^(SSlot *s) {
                [[UIAppDelegate shared] exit];
                __gs_apifailed_alertview = nil;
            }];
            [al show];
            __gs_apifailed_alertview = al;
        } break;
            
        case -6:
        {
            UIAlertViewExt* al = [UIAlertViewExt temporary];
            al.title = @"提示";
            al.message = msg;
            [[al addItem:@"确定"].signals connect:kSignalClicked withBlock:^(SSlot *s) {
                __gs_apifailed_alertview = nil;
            }];
            [al show];
            __gs_apifailed_alertview = al;
        } break;
    }
}

- (NSString*)sessionid {
    NSHTTPCookie* cookie = [_nm.cookiesResponse objectForKey:@"hd"];
    if (cookie == nil)
        return @"";
    return cookie.value;
}

- (NSArray*)cookies {
    return _nm.cookiesResponse.allValues;
}

- (void)clearCookies {
    [NetModelExt ClearCookies];
    [_nm.cookiesResponse removeAllObjects];
}

+ (BOOL)HasCookies {
    return [NetModelExt HasCookies];
}

- (void)fetchs:(NSArray*)objs with:(void(^)(SNetObjs* m))block {
    SNetObjs* nos = [[SNetObjs alloc] init];
    nos.netobjs = objs;
    block(nos);
    nos.session = self;
    [nos execute];
    SAFE_RELEASE(nos);
}

@end
