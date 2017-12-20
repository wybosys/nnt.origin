
# ifndef __HARDWAREINFO_5FC7911015C54C929A61CE8A37DF92DE_H_INCLUDED
# define __HARDWAREINFO_5FC7911015C54C929A61CE8A37DF92DE_H_INCLUDED

@interface HardwareUtility : NSObject

// MAC地址
+ (NSString*)NetMACAddress;

// 设备型号
+ (NSString*)Platform;

// 设备型号转义
+ (NSString*)PlatformString;

// 运营商
+ (NSString*)CarrierName;

// 通信类型
+ (NSString*)Brand;

@end

# endif
