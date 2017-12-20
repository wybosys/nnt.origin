
# import "Common.h"
# import "RTObjectExchangeService.h"
# import "RTExchangeObject.h"
# import "NSTypes+Extension.h"
# import "RTEResponse.h"
# import "RTEContentMessageList.h"
# import "NSDataArchiver.h"
# import "RTEHeartBeatResp.h"
# import "RTEHeartBeatReq.h"

PRIVATE_IMPL_BEGIN(RTObjectExchangeService, NSObject,)

PRIVATE_IMPL(RTObjectExchangeService)

- (id)init {
    self = [super init];

    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)cbConnected {    
    [self receiveOnce];
}

- (void)cbDisconnected {
    [RTExchangeObject SetPacketId:0];
}

- (void)receiveOnce {
    LOG("等待接收 RTEObject");
    
    SocketStream* header = [[SocketStream alloc] init];
    header.length = [RTExchangeObject HeaderSize];
    
    // 接收到完整的头
    [header.signals connect:kSignalSocketBytesCompleted withSelector:@selector(cbHeaderReceived:) ofTarget:self];
    
    // 接收服务器上的数据
    [d_owner.connector receive:header];
    
    SAFE_RELEASE(header);
}

- (void)cbHeaderReceived:(SSlot*)s {
    SocketStream* header = (SocketStream*)s.sender;
    
    RTExchangeObject* tmpobj = [[RTExchangeObject alloc] init];
    if ([tmpobj readHeader:header.buf] == NO) {
        LOG("接收到的 RTE 头部信息错误");
        SAFE_RELEASE(tmpobj);
        return;
    }
    
    if (tmpobj.length >= 0xFFFFF) {
        LOG("接收到得 RTE 长度信息超出限定长度 %d[%x], 跳过", tmpobj.length, tmpobj.length);
        SAFE_RELEASE(tmpobj);
        return;
    }
    
    // 接受body
    SocketStream* body = [[SocketStream alloc] init];
    body.length = tmpobj.length;
    [body.attachment.strong setObject:tmpobj forKey:@"TMPOBJ"];
    [body.signals connect:kSignalSocketBytesCompleted withSelector:@selector(cbBodyReceived:) ofTarget:self];
    
    // 开始接收数据
    [d_owner.connector receive:body];
    
    SAFE_RELEASE(body);
    SAFE_RELEASE(tmpobj);
}

- (void)cbBodyReceived:(SSlot*)s {
    SocketStream* body = (SocketStream*)s.sender;
    RTExchangeObject* tmpobj = (RTExchangeObject*)[body.attachment.strong objectForKey:@"TMPOBJ"];
    NSData* bodydata = body.buf;
    
    if (tmpobj.format == kRTEFormatGZip) {
        //INFO("RTE Body GZip Stream");
        bodydata = [NSGzip Decompress:bodydata];
    }
    
# ifdef DEBUG_MODE
    {
        NSString* tmpstr = [[NSString alloc] initWithData:bodydata encoding:NSUTF8StringEncoding];
        LOG("RTEBody <= %s", tmpstr.prettyString.UTF8String);
        SAFE_RELEASE(tmpstr);
    }
# endif
    
    RTExchangeObject* rteobj = [d_owner instanceObject:tmpobj.type fromData:bodydata];
    if (rteobj) {
        
        // 启动信号
        [d_owner.signals emit:kSignalRTEReceivedObject withResult:rteobj];
        
        // 开始内部处理
        LOG("收到 RTEObject 对象 %s", objc_getClassName(rteobj));
     
        // 发送反馈消息
        switch (rteobj.type)
        {
            default: break;
                
            case RTE_CONTENTMESSAGELIST: {
                
                RTEResponseSuccess* respn = [[RTEResponseSuccess alloc] init];
                respn.packetId = rteobj.packetId;
                [d_owner sendObject:respn];
                SAFE_RELEASE(respn);
                
            } break;
                
            case RTE_HEARTBEATREQ: {
                
                RTEHeartBeatReq* req = (RTEHeartBeatReq*)rteobj;
                RTEHeartBeatResp* respn = [[RTEHeartBeatResp alloc] init];
                respn.packetId = req.packetId;
                respn.ct = req.ct;
                [d_owner sendObject:respn];
                SAFE_RELEASE(respn);
                
            } break;
                
        }
        
    } else {
        LOG("从 data 转换 RTEObject 失败, 类型 %d", tmpobj.type);
    }
    
    // 继续获得下一条记录
    [self receiveOnce];
}

PRIVATE_IMPL_END()

@interface RTObjectExchangeService ()

@end

@implementation RTObjectExchangeService

@synthesize connector = _connector;

- (id)init {
    self = [super init];
    PRIVATE_CONSTRUCT(RTObjectExchangeService);
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_connector);
    
    PRIVATE_DESTROY();    
    [super dealloc];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalRTEReceivedObject);
SIGNALS_END

- (void)setConnector:(AsyncSocketConnector *)connector {
    if (connector == _connector)
        return;
    
    [_connector.signals disconnectToTarget:d_ptr];
    
    PROPERTY_RETAIN(_connector, connector);
    
    [_connector.signals connect:kSignalSocketConnected withSelector:@selector(cbConnected) ofTarget:d_ptr];
    [_connector.signals connect:kSignalSocketDisconnected withSelector:@selector(cbDisconnected) ofTarget:d_ptr];
}

- (void)sendObject:(RTExchangeObject *)obj {
    LOG("发送 RTEObject 对象 %s", objc_getClassName(obj));
    
    NSMutableData* data = obj.dataFull;
    SocketStream* stm = [[SocketStream alloc] init];
    stm.buf = data;
    [_connector send:stm];
    SAFE_RELEASE(stm);
}

- (RTExchangeObject*)instanceObject:(NSInteger)type fromData:(NSData *)data {
    return nil;
}

@end
