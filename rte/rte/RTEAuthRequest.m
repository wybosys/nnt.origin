
# import "Common.h"
# import "RTEAuthRequest.h"
# import "NSTypes+Extension.h"

@implementation RTEAuthRequest

@synthesize version = _version;
@synthesize authType = _authType;
@synthesize accountId = _accountId;
@synthesize cookie = _cookie;

- (id)init {
    self = [super init];
    
    _type = RTE_AUTHREQUEST;
    
    // 初始化
    self.version = RTE_VERSION();
    self.authType = 0;
    self.cookie = @"cookie";
    
    return self;
}

- (void)dealloc {
    SAFE_RELEASE(_version);
    SAFE_RELEASE(_cookie);
    
    SUPER_DEALLOC;
}

- (BOOL)fillData:(NSMutableDictionary *)dict {
    [super fillData:dict];
    
    [dict setObject:_version forKey:@"V"];
    [dict setInt:_authType forKey:@"AT"];
    
    NSMutableDictionary* ap = [[NSMutableDictionary alloc] init];
    [ap setInt:_accountId forKey:@"ID"];
    [ap setObject:_cookie forKey:@"COOKIE"];
    [dict setObject:[ap jsonString] forKey:@"AP"];
    SAFE_RELEASE(ap);
    
    return YES;
}

@end