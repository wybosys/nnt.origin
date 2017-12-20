
# ifndef __NETWORK_058CDEFFB9814E38B596B8D583A20499_H_INCLUDED
# define __NETWORK_058CDEFFB9814E38B596B8D583A20499_H_INCLUDED

@interface NSNetworkInterface : NSObject

+ (NSNetworkInterface*)Wifi;
+ (NSNetworkInterface*)Any;

+ (void)Listen;

@property (nonatomic, readonly) BOOL reachable;
@property (nonatomic, readonly) NSString *name;

@end

SIGNAL_DECL(kSignalNetworkReachabilityChanged) @"::ni::reachability::changed";
SIGNAL_DECL(kSignalNetworkReachabilityOn) @"::ni::reachability::on";
SIGNAL_DECL(kSignalNetworkReachabilityOff) @"::ni::reachability::off";

# endif
