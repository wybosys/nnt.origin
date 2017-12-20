
# ifndef __RTEHEARBEATREQ_A0D9D4E2B5D843D1B9590D7689252E92_H_INCLUDED
# define __RTEHEARBEATREQ_A0D9D4E2B5D843D1B9590D7689252E92_H_INCLUDED

# import "RTExchangeObject.h"

@interface RTEHeartBeatReq : RTExchangeObject

@property (nonatomic, copy) NSString* ct;

@end

enum { RTE_HEARTBEATREQ = 4 };

# endif
