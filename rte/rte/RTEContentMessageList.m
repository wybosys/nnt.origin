
# import "Common.h"
# import "RTEContentMessageList.h"
# import "NSTypes+Extension.h"

@interface RTEContentMessageList ()

@property (nonatomic, retain) NSMutableArray* messages;

@end

@implementation RTEContentMessageList

@synthesize messages = _messages;

- (id)init {
    self = [super init];
    
    _type = RTE_CONTENTMESSAGELIST;
    
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_messages);
    
    SUPER_DEALLOC;
}

- (BOOL)readData:(NSDictionary *)dict {
    if ([super readData:dict] == NO)
        return NO;
    
    NSMutableDictionary* msgs = [[NSMutableDictionary alloc] init];
    
    /*
    NSArray* items = [dict getArray:@"M"];
    for (NSDictionary* each in items) {
        
        Message* msg = [[Message alloc] init];
        [msg parse:each];
        
        MessagePayload* pl = [[MessagePayload alloc] init];
        [pl parseJSON:msg.P];
        
        MessageItemPL* mi = [[MessageItemPL alloc] init];
        [mi readMessage:msg];
        [mi readPayload:pl];
        
        [msgs setObject:mi forKey:mi.messageid.value];
        
        SAFE_RELEASE(mi);
        SAFE_RELEASE(pl);
        SAFE_RELEASE(msg);
    }
     */
    
    self.messages = [NSMutableArray arrayWithArray:msgs.allValues];
    
    SAFE_RELEASE(msgs);
    
    return YES;
}

@end
