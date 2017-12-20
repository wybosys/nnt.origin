
# ifndef __RTEAUTHREQUEST_F3E2A4F79CCA4E0A84C13AFCADD0F6DD_H_INCLUDED
# define __RTEAUTHREQUEST_F3E2A4F79CCA4E0A84C13AFCADD0F6DD_H_INCLUDED

# import "RTExchangeObject.h"

@interface RTEAuthRequest : RTExchangeObject {
    NSString* _version;

    NSInteger _authType;
    NSInteger _accountId;
    NSString* _cookie;
    
}

@property (nonatomic, copy) NSString *version;
@property (nonatomic, assign) NSInteger authType;
@property (nonatomic, assign) NSInteger accountId;
@property (nonatomic, copy) NSString* cookie;

@end

enum { RTE_AUTHREQUEST = 6 };

extern NSString *RTE_VERSION();

# endif
