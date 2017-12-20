
# import "Common.h"
# import "RTEResponse.h"

@implementation RTEResponse

- (id)init {
    self = [super init];
    
    _type = RTE_RESPONSE;
    
    return self;
}

- (void)dealloc {
    SUPER_DEALLOC;
}

@end

@implementation RTEResponseSuccess

@dynamic packetId;

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    SUPER_DEALLOC;
}

- (void)setPacketId:(int)packetId {
    _packetId = packetId;
}

- (int)packetId {
    return _packetId;
}

- (BOOL)fillData:(NSMutableDictionary *)dict {
    if ([super fillData:dict] == NO)
        return NO;
    
    [dict setInt:0 forKey:@"EC"];
    [dict setValue:@"Success" forKey:@"EM"];
    
    return YES;
}

@end
