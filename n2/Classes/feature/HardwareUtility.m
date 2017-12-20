
# import "Common.h"
# import "HardwareUtility.h"
# import "AppDelegate+Extension.h"
# import "Network+Extension.h"

# include <sys/socket.h>
# include <sys/sysctl.h>
# include <net/if.h>
# include <net/if_dl.h>

# import <CoreTelephony/CTCarrier.h>
# import <CoreTelephony/CTTelephonyNetworkInfo.h>

@implementation HardwareUtility

+ (NSString*)NetMACAddress {
    if (kIOSMajorVersion < 7)
        return [HardwareUtility IOS6NetMACAddress];
    return [HardwareUtility IOS7NetMACAddress];
}

+ (NSString*)IOS7NetMACAddress {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

+ (NSString*)IOS6NetMACAddress {
    int                    mib[6];
    size_t                len;
    char                *buf;
    unsigned char        *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl    *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        //printf("Error: if_nametoindex error/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        //printf("Error: sysctl, take 1/n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        //printf("Could not allocate memory. error!/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        //printf("Error: sysctl, take 2");
        if(buf != NULL)
            free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    // NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    return [outstring uppercaseString];
}

+ (NSString*)Platform {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

+ (NSString*)PlatformString {
    NSString *platform = [HardwareUtility Platform];
    if ([platform isEqualToString:@"iPhone1,1"])
        return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])
        return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])
        return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])
        return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])
        return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])
        return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])
        return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])
        return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])
        return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"])
        return @"iPhone 5C";
    if ([platform isEqualToString:@"iPhone5,4"])
        return @"iPhone 5C";
    if ([platform isEqualToString:@"iPhone6,1"])
        return @"iPhone 5S";
    if ([platform isEqualToString:@"iPhone6,2"])
        return @"iPhone 5S";
    if ([platform isEqualToString:@"iPod1,1"])
        return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])
        return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])
        return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])
        return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPad1,1"])
        return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])
        return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,2"])
        return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])
        return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,4"])
        return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])
        return @"iPad mini";
    if ([platform isEqualToString:@"iPad2,6"])
        return @"iPad mini";
    if ([platform isEqualToString:@"iPad2,7"])
        return @"iPad mini";
    if ([platform isEqualToString:@"iPad3,1"])
        return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,2"])
        return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,3"])
        return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])
        return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,5"])
        return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])
        return @"iPad 4";
    if ([platform isEqualToString:@"iPad4,1"])
        return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,2"])
        return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"])
        return @"iPad mini 2";
    if ([platform isEqualToString:@"iPad4,5"])
        return @"iPad mini 2";
    if ([platform isEqualToString:@"i386"] || [platform isEqualToString:@"x86_64"])
        return@"iPhone Simulator";
    return platform;
}

+ (NSString*)CarrierName {
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    NSString *carrierName = [carrier carrierName];
    if (carrierName.notEmpty == NO)
        carrierName = @"none";
    SAFE_RELEASE(netinfo);
    return carrierName;
}

+ (NSString*)Brand {
    if ([NSNetworkInterface Wifi].reachable)
        return @"WIFI";
    return @"WAN";
}

@end
