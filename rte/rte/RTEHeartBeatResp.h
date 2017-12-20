
# ifndef __RTEHEARBEATRESP_45CB7223CDA14F749EA7B47EC02B2BB8_H_INCLUDED
# define __RTEHEARBEATRESP_45CB7223CDA14F749EA7B47EC02B2BB8_H_INCLUDED

# import "RTExchangeObject.h"

@interface RTEHeartBeatResp : RTExchangeObject

@property (nonatomic, copy) NSString *ct;
@property (nonatomic, assign) int packetId;

@end

enum { RTE_HEARTBEATRESP = 5 };

# endif
