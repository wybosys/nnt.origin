
# ifndef __RTEXCHANGEOBJECT_490B2959DC5E4D759963729A153B730E_H_INCLUDED
# define __RTEXCHANGEOBJECT_490B2959DC5E4D759963729A153B730E_H_INCLUDED

typedef enum
{
    kRTEFormatPlain = 0,
    kRTEFormatGZip = 1,
} RTEFormat;

@interface RTExchangeObject : NSObject {
    int _length;
    Byte _type;
    int _packetId;
    RTEFormat _format;
}

@property (nonatomic, readonly) int length;
@property (nonatomic, readonly) Byte type;
@property (nonatomic, assign) RTEFormat format;
@property (nonatomic, readonly) int packetId;
@property (nonatomic, copy) NSString* message;
@property (nonatomic, assign) int code;

+ (NSUInteger)HeaderSize;

- (BOOL)readHeader:(NSData*)data;
- (NSData*)readBodyData:(NSData*)data;
- (BOOL)readBody:(NSData*)data;

- (NSMutableData*)dataHeader:(NSData*)data;
- (NSMutableData*)dataBody;
- (NSMutableData*)dataFull;

- (BOOL)readData:(NSDictionary*)dict;
- (BOOL)fillData:(NSMutableDictionary*)dict;

+ (void)SetPacketId:(int)val;

@end

SIGNAL_DECL(kSignalRTEResponseSucceed) @"::rte::response::succeed";
SIGNAL_DECL(kSignalRTEResponseFailed) @"::rte::response::failed";

# endif
