
# import "Common.h"
# import "RTExchangeObject.h"
# import "NSTypes+Extension.h"

@implementation RTExchangeObject

@synthesize length = _length;
@synthesize type = _type;
@synthesize format = _format;
@synthesize packetId = _packetId;

static int __packetId = 0;

- (id)init {
    self = [super init];
    
    _format = kRTEFormatPlain;
    
    SYNCHRONIZED_BEGIN
    _packetId = ++__packetId;
    SYNCHRONIZED_END
    
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_message);
    
    SUPER_DEALLOC;
}

+ (void)SetPacketId:(int)val {
    __packetId = val;
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalRTEResponseSucceed)
SIGNAL_ADD(kSignalRTEResponseFailed)
SIGNALS_END

+ (NSUInteger)HeaderSize {
    static NSUInteger HEADERSIZE = sizeof(int) + sizeof(Byte) + sizeof(Byte) + strlen("\r\n");
    return HEADERSIZE;
}

- (BOOL)fillData:(NSMutableDictionary *)dict {
    [dict setInt:_packetId forKey:@"I"];
    return YES;
}

- (BOOL)readData:(NSDictionary *)dict {
    _packetId = [dict getInt:@"I"];
    
    if ([dict exists:@"EC"]) {
        self.code = [dict getInt:@"EC"];
        if (self.code != 0)
        {
            self.message = [dict getString:@"EM"];
            LOG("RTE 错误 %d %s", self.code, self.message.UTF8String);
        }
    }
    
    return YES;
}

- (NSMutableData*)dataHeader:(NSData *)data {
    NSMutableData* ret = [NSMutableData data];
    [ret appendInt:htonl(data.length)];
    [ret appendByte:_type];
    [ret appendByte:_format];
    [ret appendCString:"\r\n"];
    return ret;
}

- (NSMutableData*)dataBody {
    NSMutableData* ret = [NSMutableData data];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    if ([self fillData:dict])
    {
        NSString* jstr = [dict jsonString];
        [ret appendString:jstr encoding:NSUTF8StringEncoding];
    }
    SAFE_RELEASE(dict);
    return ret;
}

- (NSMutableData*)dataFull {
    NSMutableData* ret = [NSMutableData data];
    NSData* body = self.dataBody;
    NSData* header = [self dataHeader:body];
    [ret appendData:header];
    [ret appendData:body];
    
# ifdef DEBUG_MODE
    NSString* str = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
    LOG("RTEBody => %s", str.prettyString.UTF8String);
    SAFE_RELEASE(str);
# endif
    
    return ret;
}

- (BOOL)readHeader:(NSData *)data {
    NSStreamData* sd = [[NSStreamData alloc] initWithData:data];
    
    if ([sd readInt:&_length] == NO)
    {
        SAFE_RELEASE(sd);
        return NO;
    }
    _length = ntohl(_length);
    
    if ([sd readByte:&_type] == NO)
    {
        SAFE_RELEASE(sd);
        return NO;
    }
    
    Byte format;
    if ([sd readByte:&format] == NO)
    {
        SAFE_RELEASE(sd);
        return NO;
    }
    _format = format;
    
    SAFE_RELEASE(sd);
    return YES;
}

- (NSData*)readBodyData:(NSData *)data {
    NSStreamData* sd = [[NSStreamData alloc] initWithData:data];
    
    if ([sd readInt:&_length] == NO)
    {
        SAFE_RELEASE(sd);
        return nil;
    }
    _length = ntohl(_length);
    
    sd.offset = [RTExchangeObject HeaderSize];
    
    NSData* ret = [sd readData:_length];
    
    SAFE_RELEASE(sd);
    
    return ret;
}

- (BOOL)readBody:(NSData *)data {
    NSString* jstr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary* dict = [jstr jsonObject];
    SAFE_RELEASE(jstr);
    
    if (dict == nil)
        return NO;
    
    return [self readData:dict];
}

@end