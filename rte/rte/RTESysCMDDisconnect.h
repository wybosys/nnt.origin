
# ifndef __RTESYSCMDDISCONNECT_E42F816002E2456CA4B23FF9DC806F22_H_INCLUDED
# define __RTESYSCMDDISCONNECT_E42F816002E2456CA4B23FF9DC806F22_H_INCLUDED

# import "RTESysCMD.h"

typedef enum {
    kRTESysCMDDisconnectTypeAuthFailed = -1,
    kRTESysCMDDisconnectTypeLoginedOnAnotherDevice = -2,
    kRTESysCMDDisconnectTypeServerIsBusy = -3,
} RTESysCMDDisconnectType;

@interface RTESysCMDDisconnect : RTESysCMDObject {
    RTESysCMDDisconnectType _type;
}

@property (nonatomic, readonly) RTESysCMDDisconnectType type;
@property (nonatomic, copy) NSString* message;

@end

enum { RTE_SYSCMD_DISCONNECT = 1 };

# endif
