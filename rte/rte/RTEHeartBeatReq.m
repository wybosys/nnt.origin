
# import "Common.h"
# import "RTEHeartBeatReq.h"

@implementation RTEHeartBeatReq

- (id)init {
    self = [super init];
    
    _type = RTE_HEARTBEATREQ;
    
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_ct);
    
    SUPER_DEALLOC;
}

- (BOOL)readData:(NSDictionary *)dict {
    if ([super readData:dict] == NO)
        return NO;
 
    self.ct = [dict getString:@"CT"];
    
    return YES;
}

@end