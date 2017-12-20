
# import "Common.h"
# import "AsyncSocketConnector.h"
# import "AsyncSocket.h"
# import "AppDelegate+Extension.h"

# define SOCKETLOG(msg, args...) LOG(msg, ## args)

@interface AsyncSocketConnector ()

@property (nonatomic, assign) SocketState state;

@end

PRIVATE_IMPL_BEGIN(AsyncSocketConnector, NSObject <AsyncSocketDelegate>,
                   NSMutableDictionary* _streams;
                   int _tag;
)

@property (readonly) AsyncSocket *aio;

PRIVATE_IMPL(AsyncSocketConnector)

@synthesize aio;

- (id)init {
    self = [super init];
    
    aio = [[AsyncSocket alloc] initWithDelegate:self];
    [aio setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    
    _streams = [[NSMutableDictionary alloc] init];
    _tag = 0;
    
    [[UIAppDelegate shared].signals connect:kSignalAppDeactived withSelector:@selector(cbDeactived) ofTarget:self];
    
    return self;
}

- (void)dealloc {
    [aio setDelegate:nil];
    [aio disconnect];
    SAFE_RELEASE(aio);
    SAFE_RELEASE(_streams);
    [super dealloc];
}

- (void)send:(SocketStream*)stm withTimeout:(NSTimeInterval)timeout {
    [self addStream:stm];
    
    [aio writeData:stm.buf withTimeout:timeout tag:stm.tag];
    
    SOCKETLOG("Socket 序列 [%d] 发送数据 %d", stm.tag, stm.buf.length);
}

- (void)read:(SocketStream*)stm withTimeout:(NSTimeInterval)timeout {
    [self addStream:stm];
    
    [aio readDataToLength:stm.length withTimeout:timeout buffer:stm.buf bufferOffset:0 tag:stm.tag];
    
    SOCKETLOG("Socket 序列 [%d] 等待接收 %d 数据", stm.tag, stm.length);
}

- (void)addStream:(SocketStream*)stm {
    if (stm.tag != 0)
        return;
        
    stm.tag = self.makeTag;
    
    SYNCHRONIZED_BEGIN
    [_streams setObject:stm forInt:stm.tag];
    SYNCHRONIZED_END
}

- (SocketStream*)findStream:(NSInteger)tag {
    SocketStream* stm = nil;
    SYNCHRONIZED_BEGIN
    stm = [_streams objectForInt:tag];
    SYNCHRONIZED_END
    return stm;
}

- (SocketStream*)popStream:(NSInteger)tag {
    SocketStream* stm = nil;
    SYNCHRONIZED_BEGIN
    stm = [[_streams objectForInt:tag] consign];
    [_streams removeObjectForInt:tag];
    SYNCHRONIZED_END
    return stm;
}

- (void)clearStreams {
    SYNCHRONIZED_BEGIN
    [_streams removeAllObjects];
    SYNCHRONIZED_END
}

- (NSInteger)makeTag {
    return ++_tag;
}

- (void)cbDeactived {
    if (d_owner.backgroundMode == NO)
        [d_owner close];
}

# pragma mark AIO

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
    SOCKETLOG("Socket 即将断开连接");
    
    [err log];

    d_owner.state = kSocketStateDisconnecting;
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
    SOCKETLOG("Socket 已经断开连接");
    
    // 清空streams
    [self clearStreams];
    _tag = 0;
    
    // 发送信号
    d_owner.state = kSocketStateDisconnected;
    [d_owner.signals emit:kSignalSocketDisconnected];
}

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket {
    SOCKETLOG("Socket 已经接受了一个连接");
}

- (NSRunLoop *)onSocket:(AsyncSocket *)sock wantsRunLoopForNewSocket:(AsyncSocket *)newSocket {
    return [NSRunLoop currentRunLoop];
}

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock {
    SOCKETLOG("Socket 正在准备连接");
    
    d_owner.state = kSocketStateConnecting;
    [d_owner.signals emit:kSignalSocketConnecting];
    return YES;
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    SOCKETLOG("Socket 已经连接 %s:%d", host.UTF8String, port);
    
    d_owner.state = kSocketStateConnected;
    [d_owner.signals emit:kSignalSocketConnected];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    SOCKETLOG("Socket 序列 [%d] 接收到 %d 长度数据", tag, data.length);

    [d_owner.signals emit:kSignalSocketBytesAvailable];
    
    SocketStream* stm = [self findStream:tag];
    
    [stm.signals emit:kSignalSocketBytesAvailable];
    [stm.signals emit:kSignalSocketBytesCompleted];
    
    [self popStream:tag];
}

- (void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
    SOCKETLOG("Socket 序列 [%d] 接收了部分长度 %d 数据", tag, partialLength);
    
    [d_owner.signals emit:kSignalSocketBytesAvailable];
    
    SocketStream* stm = [self findStream:tag];
    
    [stm.signals emit:kSignalSocketBytesAvailable];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
    SOCKETLOG("Socket 序列 [%d] 发送数据完成", tag);
    
    [d_owner.signals emit:kSignalSocketBytesWritten];
    [self popStream:tag];
}

- (void)onSocket:(AsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
    SOCKETLOG("Socket 序列 [%d] 发送部分 %d 数据", tag, partialLength);
    
    [d_owner.signals emit:kSignalSocketBytesWritten];
}

- (NSTimeInterval)onSocket:(AsyncSocket *)sock
shouldTimeoutReadWithTag:(long)tag
elapsed:(NSTimeInterval)elapsed
bytesDone:(NSUInteger)length {
    return 0;
}

- (NSTimeInterval)onSocket:(AsyncSocket *)sock
shouldTimeoutWriteWithTag:(long)tag
elapsed:(NSTimeInterval)elapsed
bytesDone:(NSUInteger)length {
    return 0;
}

PRIVATE_IMPL_END()

@implementation AsyncSocketConnector

@synthesize host = _host, port = _port;
@synthesize state = _state;

- (id)init {
    self = [super init];
    PRIVATE_CONSTRUCT(AsyncSocketConnector);
    return self;
}

- (void)dealloc {
    PRIVATE_DESTROY();
    [super dealloc];
}

SIGNALS_BEGIN

SIGNAL_ADD(kSignalSocketConnecting)

SIGNAL_ADD(kSignalSocketBytesAvailable)
SIGNAL_ADD(kSignalSocketBytesWritten)

SIGNAL_ADD_SLOT(kSignalSocketConnected, @selector(cbSocketConnected))
SIGNAL_ADD_SLOT(kSignalSocketDisconnected, @selector(cbSocketDisconnected))

SIGNALS_END

- (void)cbSocketConnected {
    LOG("Socket 成功连接 %s:%d", _host.UTF8String, _port);
}

- (void)cbSocketDisconnected {
    LOG("Socket 已经断开");
}

- (BOOL)open {
    // 只有断开连接或者不知道连接状态的情况下才允许连接
    if (self.disconnected == NO)
        return NO;
    
    NSError* err = nil;
    _state = kSocketStateConnecting;
    BOOL suc = [d_ptr.aio connectToHost:_host onPort:_port error:&err];
    if (suc == NO) {
        [err log];
        _state = kSocketStateDisconnected;
    }
    
    return suc;
}

/*
- (BOOL)reopen {
    return [self open];
}
 */

- (void)send:(SocketStream *)stm {
    [d_ptr send:stm withTimeout:-1];
}

- (void)receive:(SocketStream *)stm {
    [d_ptr read:stm withTimeout:-1];
}

- (void)close {
    [d_ptr.aio disconnect];
}

- (BOOL)disconnected {
    BOOL ret = YES;
    switch (self.state) {
        case kSocketStateConnecting:
        case kSocketStateConnected: {
            ret = NO;
        } break;
        default: break;
    }
    return ret;
}

@end
