
# ifndef __RTERESPONSE_C48BF8096CBA4D79BF600B86BF338D67_H_INCLUDED
# define __RTERESPONSE_C48BF8096CBA4D79BF600B86BF338D67_H_INCLUDED

# import "RTExchangeObject.h"

@interface RTEResponse : RTExchangeObject

@end

@interface RTEResponseSuccess : RTEResponse

@property (nonatomic, assign) int packetId;

@end

enum { RTE_RESPONSE = 3 };

# endif
