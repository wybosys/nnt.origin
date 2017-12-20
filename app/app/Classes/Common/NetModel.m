
# import "Common.h"
# import "ASINetworkQueue.h"
# import "NetModel.h"
# import "NetObj.h"
# import "NetDefine.h"
# import "ApiSession.h"

#define kAlertMsgTimeoutError   @"超时"
#define kAlertMsgConnectionFailError    @"连接失败"
#define kAlertMsgAuthFailError          @"验证失败，请重新登陆"
#define kAlertMsgTooManyRedirect        @"重置连接过多"
#define kAlertMsgReqCancelledError      @"请求被取消"
#define kAlertMsgUnableCreateReqError   @"不能创建请求"
#define kAlertMsgUnableBuildReqError    @"不能初始化请求"
#define kAlertMsgUnableApplyCredError   @"验证失败"
#define kAlertMsgFileManageError        @"文件错误"
#define kAlertMsgUnhandledExcepError    @"未定义错误"
#define kAlertMsgCompressionError   @""
#define kAlertMsgGenericError       @""

#pragma GCC diagnostic ignored "-Wundeclared-selector"

#define API_REQUEST     0

static NSString *userAgent;
static CGFloat lastRequestSeconds;

@implementation NetModelDoUnDoRequest

@synthesize identifier;
@synthesize netModel;
@synthesize curOperation = _curOperation;
@synthesize nextOperation = _nextOperation;

-(void)goNextOperation
{
    if (_curOperation == NetModelDoUnDoOperationState_None) {
        _nextOperation = NetModelDoUnDoOperationState_None;
        _curOperation = NetModelDoUnDoOperationState_Do;
        //NSLog(@"_curOperation == NONE,Change _curOperation to %d",_curOperation);
    }
    else if(_curOperation == NetModelDoUnDoOperationState_Do ||
            _curOperation == NetModelDoUnDoOperationState_UnDo)
    {
        _nextOperation = _nextOperation==NetModelDoUnDoOperationState_Do?NetModelDoUnDoOperationState_UnDo:NetModelDoUnDoOperationState_Do;
        //NSLog(@"Change _nextOperation to %d , curOperation:%d",_nextOperation,_curOperation);
    }
}

-(BOOL)shouldDoOperation
{
    if (_nextOperation != NetModelDoUnDoOperationState_None && _nextOperation!= _curOperation) {
        return YES;
    }
    return NO;
}

-(void)dealloc
{
    [netModel release];
    [super dealloc];
}

@end

@interface NetModel (private)

- (void)dataRequestSuccessed:(ASIHTTPRequest *)request;
- (void)dataRequestFailed:(ASIHTTPRequest *)request;

- (NSString*)makeSelectorName:(NSString*)api forSuccess:(BOOL)success;

- (void)dispatchSuccessed:(JsonData*) data forApi:(NSString*)api;
- (void)dispatchFailed:(NSInteger)errNo withMsg:(NSString*)msg forApi:(NSString*)api;

@end


@implementation NetModel

@synthesize delegate;
@synthesize networkQueue = _networkQueue;
@synthesize from = _from;

+ (void)setUserAgent:(NSString *)newUserAgent {
    if (userAgent == nil) {
        userAgent = [newUserAgent copy];
    } else if (userAgent != newUserAgent) {
        [userAgent release];
        userAgent = [newUserAgent copy];
    }
}

-(id) init {
    self = [super init];
    if (self) {
        _networkQueue = [[ASINetworkQueue alloc] init];
        [_networkQueue reset];
        [_networkQueue setRequestDidFinishSelector:@selector(dataRequestSuccessed:)];
        [_networkQueue setRequestDidFailSelector:@selector(dataRequestFailed:)];
        
        _networkQueue.delegate = self;
        _networkQueue.showAccurateProgress = YES;
    }
    return self;
}


- (void)dealloc {
    
    for (ASIHTTPRequest *request in [self.networkQueue operations]) {
        request.delegate = nil;
        [request setDownloadProgressDelegate:nil];
    }
    [_networkQueue cancelAllOperations];
    [_networkQueue reset];
    [_networkQueue release];
    [_from release];
    [super dealloc];
}

- (NetModelDoUnDoRequest*)beginDuDRequest:(NSString*)api {
    NSString *urlStr = [SERVER_URL() stringByAppendingString:api];
    if (_from && [_from length] > 0) {
        urlStr = [urlStr stringByAppendingFormat:@"?_from=%@", _from];
        self.from = nil;
    }
    NSURL *url = [NSURL URLWithString:urlStr];
    NetModelDoUnDoRequest *request = [NetModelDoUnDoRequest requestWithURL:url];
    
    NSString *agent = nil;
    if (lastRequestSeconds < 0.001) {
        agent = userAgent;
    }
    else {
        agent = [NSString stringWithFormat:@"%@ ta(%.3f)", userAgent, lastRequestSeconds];
    }
    [request setUserAgent:agent];
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:api, @"api", [NSDate date], @"timestamp", nil]];
    [request setTag:API_REQUEST];         //0代表api访问
    [request setTimeOutSeconds:10];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    [request setShouldContinueWhenAppEntersBackground:YES];
#endif
    return request;
}

- (ASIFormDataRequest*)beginRequest:(NSString*)api {
    NSString *urlStr = @"";
    if ([api notEmpty]) {
        NSURL* url = [NSURL URLWithString:api];
        if (url.scheme.notEmpty) {
            urlStr = api;
        } else {
            urlStr = [SERVER_URL() stringByAppendingString:api];
        }
    }
    
    if (_from && [_from length] > 0) {
        urlStr = [urlStr stringByAppendingFormat:@"?_from=%@", _from];
        self.from = nil;
    }
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    NSString *agent = nil;
    if (lastRequestSeconds < 0.001) {
        agent = userAgent;
    }
    else {
        agent = [NSString stringWithFormat:@"%@ ta(%.3f)", userAgent, lastRequestSeconds];
    }
    [request setUserAgent:agent];
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:api, @"api", [NSDate date], @"timestamp", nil]];
    [request setTag:API_REQUEST];         //0代表api访问
    [request setTimeOutSeconds:10];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    [request setShouldContinueWhenAppEntersBackground:YES];
#endif
    
    return request;
}

- (ASIFormDataRequest*)beginRequest:(NSString*)api AndNotificationId:(int)idValue {
    NSString *urlStr = [SERVER_URL() stringByAppendingString:api];
    if (_from && [_from length] > 0) {
        urlStr = [urlStr stringByAppendingFormat:@"?_from=%@", _from];
        self.from = nil;
    }
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    NSString *agent = nil;
    if (lastRequestSeconds < 0.001) {
        agent = userAgent;
    }
    else {
        agent = [NSString stringWithFormat:@"%@ ta(%.3f)", userAgent, lastRequestSeconds];
    }
    [request setUserAgent:agent];
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:api, @"api", [NSDate date], @"timestamp", nil]];
    [request setTag:API_REQUEST];         //0代表api访问
    [request setTimeOutSeconds:10];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    [request setShouldContinueWhenAppEntersBackground:YES];
#endif
    return request;
}


- (void)endRequest:(ASIFormDataRequest*)request {
    
# ifdef DEBUG_MODE
    {
        NSMutableArray* arr = [NSMutableArray array];
        for (NSMutableDictionary *dict in request.postData) {
            NSString *key = [dict objectForKey:@"key"];
            NSString *value = [dict objectForKey:@"value"];
            [arr addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
        }
        LOG("API 请求 %s <= %s", request.url.absoluteString.UTF8String, [arr componentsJoinedByString:@" & "].UTF8String);
    }
# endif
    
    @synchronized(self)
    {
        // 异步的时候Queue会很快的积累多个请求，导致下面的go被跳过，所以需要保护起来
        [_networkQueue addOperation:request];
        if ([_networkQueue requestsCount] == 1) {
            [_networkQueue go];
        }
    }
}

- (void)encryptRequest:(ASIFormDataRequest*)request netobj:(id)netobj {
    PASS;
}

- (void)request_s:(SNetObj*)no {
    id apiobj = no.netobj;
    ASIFormDataRequest *request = [self beginRequest:[apiobj getUrl]];
    
    // 如果关心进度，则需要额外设置一下 request 对象
    if ([no.touchSignals isConnected:kSignalApiSendProgress]) {
        NetModelProgressObserver* ob = [NetModelProgressObserver temporary];
        ob.marksignal = kSignalApiSendProgress;
        ob.sapi = no;
        [no.attachment.strong setObject:ob forKey:@"::apisession::observer::send"];
        [request setUploadProgressDelegate:ob];
    }
    if ([no.touchSignals isConnected:kSignalApiReceiveProgress]) {
        NetModelProgressObserver* ob = [NetModelProgressObserver temporary];
        ob.marksignal = kSignalApiReceiveProgress;
        ob.sapi = no;
        [no.attachment.strong setObject:ob forKey:@"::apisession::observer::receive"];
        [request setDownloadProgressDelegate:ob];
    }
    
    // 发送数据
    [apiobj initRequest:request];
    [self encryptRequest:request netobj:apiobj];
    [self endRequest:request];
}

- (void)request:(id)netModel
{
    ASIFormDataRequest *request = [self beginRequest:[netModel getUrl]];
    [netModel initRequest:request];
    [self encryptRequest:request netobj:netModel];
    [self endRequest:request];
}

- (void)request:(id)netModel AndNotificationId:(int)idValue
{
    ASIFormDataRequest *request = [self beginRequest:[netModel getUrl] AndNotificationId:idValue];
    request.tag = idValue;
    [netModel initRequest:request];
    [self encryptRequest:request netobj:netModel];
    [self endRequest:request];
}

- (void)request:(id)netModel AndDoUnDoIdentifier:(int)idValue
{
    NetModelDoUnDoRequest *curSameOperatoin = nil;
    for (id obj in [_networkQueue operations]) {
        if ([obj isKindOfClass:[NetModelDoUnDoRequest class]]) {
            curSameOperatoin = (NetModelDoUnDoRequest*)obj;
            break;
        }
    }
    if (!curSameOperatoin) {
        //NSLog(@"Found No , init new operation");
        curSameOperatoin = [self beginDuDRequest:[netModel getUrl]];
        curSameOperatoin.identifier = idValue;
        curSameOperatoin.netModel = netModel;
        [curSameOperatoin goNextOperation];
        [netModel initRequest:curSameOperatoin];
        [self encryptRequest:curSameOperatoin netobj:netModel];
        [self endRequest:curSameOperatoin];
    }
    else
    {
        //NSLog(@"Found operation");
        [curSameOperatoin goNextOperation];
    }
    
}

- (void)cancelAllOperations
{
    [_networkQueue cancelAllOperations];
}

- (void)dataRequestSuccessed:(ASIHTTPRequest *)request {
    NSString *api = [request.userInfo objectForKey:@"api"];
    NSDate *requestDate = [request.userInfo objectForKey:@"timestamp"];
    if (requestDate && [requestDate isKindOfClass:[NSDate class]]) {
        lastRequestSeconds = [[NSDate date] timeIntervalSinceDate:requestDate];
    }
    int notifyId = request.tag;
    if (notifyId > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%d",notifyId] object:nil];
    }
    
    //打印所有消息
    id jsonData = request.responseString.jsonObject;
    id class = [request.userInfo objectForKey:@"class"];
    NSInteger code = [jsonData intValue:@"code" default:-1];
    if ((jsonData && code == 0) || [class conformsToProtocol:@protocol(NetUrlObj)])
    {
        NSDictionary* dict = [NSDictionary restrict:jsonData];
        if (class) {
            [class parse:dict];
            if(delegate && [delegate respondsToSelector:@selector( apiSuccessedWithDictionary:ForApi:)])
            {
                [delegate performSelector:@selector(apiSuccessedWithDictionary:ForApi:) withObject:dict withObject:api];
            }
            if(delegate && [delegate respondsToSelector:@selector(apiSuccessed:ForDictionary:)])
            {
                [delegate performSelector:@selector(apiSuccessed:ForDictionary:) withObject:class withObject:dict];
            }
            if (delegate && [delegate respondsToSelector:@selector(apiSuccessed:ForApi:)]) {
                [delegate performSelector:@selector(apiSuccessed:ForApi:) withObject:class withObject:api];
            }
        }
    }
    else
    {
        NSString* msg = request.responseString;
        if (jsonData)
            msg = [jsonData strValue:@"message" default:@""];
        if (class)
        {
            NSDictionary* dict = [NSDictionary restrict:jsonData];
            [class parse:dict];
            if (delegate && [delegate respondsToSelector:@selector(apiFailed:WithMsg:)]) {
                [delegate performSelector:@selector(apiFailed:WithMsg:) withObject:class withObject:msg];
            }
            if (delegate && [delegate respondsToSelector:@selector(apiFailed:WithCode:)]) {
                [delegate performSelector:@selector(apiFailed:WithCode:) withObject:class withObject:[NSNumber numberWithInt:code]];
            }
            if (delegate && [delegate respondsToSelector:@selector(apiFailed:WithMsg:WithCode:)]) {
                [(id)delegate apiFailed:dict WithMsg:msg WithCode:@(code)];
            }
        }
        NOTI("API %s 请求失败 %s, 错误代码 %d", api.UTF8String, msg.UTF8String, code);
    }
}

- (void)apiFailed:(id)obj WithMsg:(id)msg WithCode:(id)code {}

- (void)dataRequestFailed:(ASIHTTPRequest *)request {
    NSString *message = NULL;
    
    NSError *error = [request error];
    switch ([error code])
    {
        case ASIRequestTimedOutErrorType:
            message = kAlertMsgTimeoutError;
            break;
        case ASIConnectionFailureErrorType:
            message = kAlertMsgConnectionFailError;
            break;
        case ASIAuthenticationErrorType:
            message = kAlertMsgAuthFailError;
            break;
        case ASITooMuchRedirectionErrorType:
            message = kAlertMsgTooManyRedirect;
            break;
        case ASIRequestCancelledErrorType:
            message = kAlertMsgReqCancelledError;
            break;
        case ASIUnableToCreateRequestErrorType:
            message = kAlertMsgUnableCreateReqError;
            break;
        case ASIInternalErrorWhileBuildingRequestType:
            message = kAlertMsgUnableBuildReqError;
            break;
        case ASIInternalErrorWhileApplyingCredentialsType:
            message = kAlertMsgUnableApplyCredError;
            break;
        case ASIFileManagementError:
            message = kAlertMsgFileManageError;
            break;
        case ASIUnhandledExceptionError:
            message = kAlertMsgUnhandledExcepError;
            break;
        case ASICompressionError:
            message = kAlertMsgCompressionError;
            break;
        default:
            message = kAlertMsgGenericError;
            break;
    }
    
    if (NULL != message)
    {
        
    }
    
    id class = [request.userInfo objectForKey:@"class"];
    if (class) {
        if ([delegate respondsToSelector:@selector(apiFailed:WithMsg:)]) {
            [delegate performSelector:@selector(apiFailed:WithMsg:) withObject:class withObject:message];
        }
    }
}

- (BOOL)didReceiveData:(JsonData*)data forApi:(NSString*)api {
    return FALSE;
}

- (void)dispatchSuccessed:(JsonData*)data forApi:(NSString*)api {
    BOOL modelHandled = [self didReceiveData:data forApi:api];
    
    if (modelHandled) {
        NSString *selectorName = [self makeSelectorName:api forSuccess:TRUE];
        SEL selector = NSSelectorFromString(selectorName);
        
        if (!delegate)
            return;
        if (delegate && [delegate respondsToSelector:selector]) {
            [delegate performSelector:selector withObject:self];
        } else if ([delegate respondsToSelector:@selector(apiSuccessed:forApi:)]) {
            [delegate performSelector:@selector(apiSuccessed:forApi:) withObject:self withObject:api];
        }
    } else {
        if (!delegate)
            return;
        if ([delegate respondsToSelector:@selector(didReceiveData:forApi:)]) {
            [delegate performSelector:@selector(didReceiveData:forApi:) withObject:data withObject:api];
        }
    }
}

- (void)dispatchFailed:(NSInteger)errNo withMsg:(NSString*)msg forApi:(NSString*)api {
    
    NSString *selectorName = [self makeSelectorName:api forSuccess:FALSE];
    SEL selector = NSSelectorFromString(selectorName);
    if (!delegate)
        return;
    if ([delegate respondsToSelector:selector]) {
        [delegate performSelector:selector withObject:[NSNumber numberWithInt:errNo] withObject:msg];
    } else if ([delegate respondsToSelector:@selector(apiFailed:withMsg:)]) {
        [delegate performSelector:@selector(apiFailed:withMsg:) withObject:[NSNumber numberWithInt:errNo] withObject:msg];
    }
}

- (NSString*)makeSelectorName:(NSString*)api forSuccess:(BOOL)success {
    if (!api)
        return nil;
    NSRange range = [api rangeOfString:@"/"];
    if (range.location == NSNotFound)
        return nil;
    NSString *controller = [api substringToIndex:range.location];
    NSString *action = [api substringFromIndex:range.location + 1];
    if (success)
        return [NSString stringWithFormat:@"%@%@%@Successed:", @"api", [controller capitalizedString], [action capitalizedString]];
    else
        return [NSString stringWithFormat:@"%@%@%@Failed:withMsg:", @"api", [controller capitalizedString], [action capitalizedString]];
    
}

@end

@implementation NetModelProgressObserver

- (void)setProgress:(float)newProgress {
    [self.sapi.signals emit:self.marksignal withResult:[NSPercentage percent:newProgress]];
}

@end
