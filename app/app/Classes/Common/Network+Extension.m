
# import "Common.h"
# import "Network+Extension.h"
# include <sys/socket.h>
# include <sys/sysctl.h>
# include <net/if.h>
# include <net/if_dl.h>
# include <netinet/ip.h>
# include <arpa/inet.h>
# include <SystemConfiguration/SystemConfiguration.h>

@interface NSNetworkInterface ()
{
    @public
    int _cbOn;
}

@property (nonatomic, assign) SCNetworkReachabilityRef hdl;

@end

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
	NSAutoreleasePool* pool = [NSAutoreleasePool new];
    
    NSNetworkInterface* ro = (NSNetworkInterface*)info;
    const BOOL reachable = ro.reachable;
    if (ro->_cbOn != reachable)
    {
        ro->_cbOn = reachable;
        [ro.signals emit:kSignalNetworkReachabilityChanged withResult:@(reachable)];
        
        if (reachable)
            [ro.signals emit:kSignalNetworkReachabilityOn];
        else
            [ro.signals emit:kSignalNetworkReachabilityOff];
        
        LOG("%s 连接状态发生改变 %s", objc_getClassName(ro), TRIEXPRESS(reachable, "ON", "OFF"));
    }
    
	[pool drain];
}

static void ReachabilityStart(NSNetworkInterface* r)
{
    SCNetworkReachabilityRef ref = r.hdl;
    SCNetworkReachabilityContext ctx = {0, r, NULL, NULL, NULL};
    if (SCNetworkReachabilitySetCallback(ref, ReachabilityCallback, &ctx))
    {
        if (SCNetworkReachabilityScheduleWithRunLoop(ref,
                                                     CFRunLoopGetCurrent(),
                                                     kCFRunLoopDefaultMode))
        {
            INFO("启动网络 %s 监听成功", r.name.UTF8String);
        }
        else
        {
            INFO("启动网络状态监听失败");
        }
    }
    else
    {
        FATAL("启动网络状态监听失败");
    }
}

static void ReachabilityStop(NSNetworkInterface* r)
{
    SCNetworkReachabilityRef ref = r.hdl;
    SCNetworkReachabilityUnscheduleFromRunLoop(ref,
                                               CFRunLoopGetCurrent(),
                                               kCFRunLoopDefaultMode);
}

enum
{
	kNotReachable = 0, // Apple's code depends upon 'NotReachable' being the same value as 'NO'.
	kReachableViaWWAN, // Switched order from Apple's enum. WWAN is active before WiFi.
	kReachableViaWiFi
	
};
typedef	uint32_t NetworkStatus;

const SCNetworkReachabilityFlags kSCNetworkReachabilityFlagsFlagsConnectionDown =
kSCNetworkReachabilityFlagsConnectionRequired |
kSCNetworkReachabilityFlagsTransientConnection;

static NetworkStatus ConvertFlagsToStatus(SCNetworkReachabilityFlags flags, bool wifi)
{
    if (flags & kSCNetworkReachabilityFlagsReachable)
    {
		// Local WiFi -- Test derived from Apple's code: -localWiFiStatusForFlags:.
		if (wifi)
        {
			// Reachability Flag Status: xR xxxxxxd Reachable.
			return (flags & kSCNetworkReachabilityFlagsIsDirect) ? kReachableViaWiFi : kNotReachable;
		}
		
		// Observed WWAN Values:
		// WWAN Active:              Reachability Flag Status: WR -t-----
		// WWAN Connection required: Reachability Flag Status: WR ct-----
		//
		// Test Value: Reachability Flag Status: WR xxxxxxx
		if (flags & kSCNetworkReachabilityFlagsIsWWAN)
        {
            return kReachableViaWWAN;
        }
		
		// Clear moot bits.
		flags &= ~kSCNetworkReachabilityFlagsReachable;
		flags &= ~kSCNetworkReachabilityFlagsIsDirect;
		flags &= ~kSCNetworkReachabilityFlagsIsLocalAddress; // kInternetConnection is local.
		
		// Reachability Flag Status: -R ct---xx Connection down.
		if (flags == kSCNetworkReachabilityFlagsFlagsConnectionDown)
        {
            return kNotReachable;
        }
		
		// Reachability Flag Status: -R -t---xx Reachable. WiFi + VPN(is up) (Thank you Ling Wang)
		if (flags & kSCNetworkReachabilityFlagsTransientConnection)
        {
            return kReachableViaWiFi;
        }
        
		// Reachability Flag Status: -R -----xx Reachable.
		if (flags == 0)
        {
            return kReachableViaWiFi;
        }
		
		// Apple's code tests for dynamic connection types here. I don't.
		// If a connection is required, regardless of whether it is on demand or not, it is a WiFi connection.
		// If you care whether a connection needs to be brought up,   use -isConnectionRequired.
		// If you care about whether user intervention is necessary,  use -isInterventionRequired.
		// If you care about dynamically establishing the connection, use -isConnectionIsOnDemand.
        
		// Reachability Flag Status: -R cxxxxxx Reachable.
		if (flags & kSCNetworkReachabilityFlagsConnectionRequired)
        {
            return kReachableViaWiFi;
        }
        
    }
    
    return kNotReachable;
}

static NetworkStatus CheckStatus(NSNetworkInterface* r, bool wifi)
{
    NetworkStatus ret = kNotReachable;
    
    SCNetworkReachabilityFlags flags = 0;
    SCNetworkReachabilityRef ref = r.hdl;
    
    if (SCNetworkReachabilityGetFlags(ref, &flags))
    {
        ret = ConvertFlagsToStatus(flags, wifi);
    }
    
    return ret;
}

@interface NSNetworkInterfaceWifi : NSNetworkInterface
@end

@implementation NSNetworkInterfaceWifi

SHARED_IMPL;

- (id)init {
    self = [super init];
    
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_len = sizeof(addr);
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
    
    self.hdl = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (struct sockaddr*)&addr);
    
    ReachabilityStart(self);
    
    return self;
}

- (void)dealloc {
    ReachabilityStop(self);

    [super dealloc];
}

- (BOOL)reachable {
    NetworkStatus status = CheckStatus(self, true);
    return (kNotReachable != status);
}

- (NSString*)name {
    return @"WIFI";
}

@end

@interface NSNetworkInterfaceAny : NSNetworkInterface
@end

@implementation NSNetworkInterfaceAny

SHARED_IMPL;

- (id)init {
    self = [super init];
    
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_len = sizeof(addr);
    addr.sin_family = AF_INET;
    
    self.hdl = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (struct sockaddr*)&addr);
    
    ReachabilityStart(self);
    
    return self;
}

- (void)dealloc {
    ReachabilityStop(self);
    
    [super dealloc];
}

- (BOOL)reachable {
    NetworkStatus status = CheckStatus(self, false);
    return (kNotReachable != status);
}

- (NSString*)name {
    return @"通用";
}

@end

@implementation NSNetworkInterface

+ (NSNetworkInterface*)Wifi {
    return [NSNetworkInterfaceWifi shared];
}

+ (NSNetworkInterface*)Any {
    return [NSNetworkInterfaceAny shared];
}

- (id)init {
    self = [super init];
    _cbOn = -1;
    return self;
}

- (void)dealloc {
    if (_hdl)
        CFRelease((SCNetworkReachabilityRef)_hdl);
    [super dealloc];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalNetworkReachabilityChanged)
SIGNAL_ADD(kSignalNetworkReachabilityOn)
SIGNAL_ADD(kSignalNetworkReachabilityOff)
SIGNALS_END

+ (void)Listen {
    [NSNetworkInterface Any];
    [NSNetworkInterface Wifi];
}

- (NSString*)name {
    return @"未知";
}

@end
