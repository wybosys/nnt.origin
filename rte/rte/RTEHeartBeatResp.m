
# import "Common.h"
# import "RTEHeartBeatResp.h"

@implementation RTEHeartBeatResp

- (id)init {
    self = [super init];
    
    _type = RTE_HEARTBEATRESP;
    
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_ct);
    
    SUPER_DEALLOC;
}

- (BOOL)fillData:(NSMutableDictionary *)dict {
    if ([super fillData:dict] == NO)
        return NO;
  
    [dict setObject:self.ct forKey:@"CT"];
    
    return YES;
}

@dynamic packetId;

- (void)setPacketId:(int)packetId {
    _packetId = packetId;
}

- (int)packetId {
    return _packetId;
}

@end