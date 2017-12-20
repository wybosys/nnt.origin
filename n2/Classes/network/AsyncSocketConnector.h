
# ifndef __ASYNCSOCKETCONNECTOR_681B29622E1641389AD4C082C0119F7F_H_INCLUDED
# define __ASYNCSOCKETCONNECTOR_681B29622E1641389AD4C082C0119F7F_H_INCLUDED

# import "SocketStream.h"

PRIVATE_CLASS_DECL(AsyncSocketConnector);

typedef enum
{
    kSocketStateUnknown,
    kSocketStateConnecting,
    kSocketStateConnected,
    kSocketStateDisconnecting,
    kSocketStateDisconnected,
}
SocketState;

@interface AsyncSocketConnector : NSObject {
    PRIVATE_DECL(AsyncSocketConnector);
    
    NSString* _host;
    NSInteger _port;
    
    SocketState _state;
}

@property (nonatomic, copy) NSString* host;
@property (nonatomic, assign) NSInteger port;
@property (nonatomic, readonly) SocketState state;

// 是否后台连接，默认为 NO，将会在切到后台是断开socket连接
@property (nonatomic, assign) BOOL backgroundMode;

SIGNALS;

// 打开端口
- (BOOL)open;

// 重新连接
// - (BOOL)reopen;

// 发送数据
- (void)send:(SocketStream*)stm;

// 接受数据
- (void)receive:(SocketStream*)stm;

// 关闭
- (void)close;

// 是否已经连接上
- (BOOL)disconnected;

@end

SIGNAL_DECL(kSignalSocketConnecting) @"::socket::connecting";
SIGNAL_DECL(kSignalSocketConnected) @"::socket::connected";
SIGNAL_DECL(kSignalSocketDisconnected) @"::socket::disconnected";
SIGNAL_DECL(kSignalSocketBytesWritten) @"::socket::bytes::written";

# endif
