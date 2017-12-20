
# ifndef __RTOBJECTEXCHANGESERVICE_7C4867E15AD6425487E77D81B4D7CC33_H_INCLUDED
# define __RTOBJECTEXCHANGESERVICE_7C4867E15AD6425487E77D81B4D7CC33_H_INCLUDED

# import "Architect.h"
# import "AsyncSocketConnector.h"

@class RTExchangeObject;

PRIVATE_CLASS_DECL(RTObjectExchangeService);

@interface RTObjectExchangeService : NSObject {
    PRIVATE_DECL(RTObjectExchangeService);
    
    AsyncSocketConnector* _connector;
}

SIGNALS;

@property (nonatomic, retain) AsyncSocketConnector* connector;

- (void)sendObject:(RTExchangeObject*)obj;
- (RTExchangeObject*)instanceObject:(NSInteger)type fromData:(NSData*)data;

@end

SIGNAL_DECL(kSignalRTEReceivedObject) @"::rte::object::received";

# endif
