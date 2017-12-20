
# import "Common.h"
# import "NSDataArchiver.h"
# import "ASIDataCompressor.h"
# import "ASIDataDecompressor.h"

@interface NSGzip ()

@property (nonatomic, readonly) ASIDataCompressor *compc;
@property (nonatomic, readonly) ASIDataDecompressor *compd;

@end

@implementation NSGzip

- (id)init {
    self = [super init];
    
    _compc = [[ASIDataCompressor alloc] init];
    _compd = [[ASIDataDecompressor alloc] init];
    
    [_compc setupStream];
    [_compd setupStream];
    
    return self;
}

- (void)dealloc {
    [_compc closeStream];
    [_compd closeStream];
    
    ZERO_RELEASE(_compc);
    ZERO_RELEASE(_compd);
    
    [super dealloc];
}

- (NSData*)compress:(NSData*)da {
    NSError* err = nil;
    NSData* ret = [_compc compressBytes:(Bytef*)da.bytes length:da.length error:&err shouldFinish:YES];
    if (err)
        [err log];
    return ret;
}

+ (NSData*)Compress:(NSData*)da {
    NSError* err = nil;
    NSData* ret = [ASIDataCompressor compressData:da error:&err];
    if (err) {
        [err log];
    }
    return ret;
}

- (NSData*)decompress:(NSData*)da {
    NSError* err = nil;
    NSData* ret = [_compd uncompressBytes:(Bytef*)da.bytes length:da.length error:&err];
    if (err) {
        [err log];
    }
    return ret;
}

+ (NSData*)Decompress:(NSData *)da {
    NSError* err = nil;
    NSData* ret = [ASIDataDecompressor uncompressData:da error:&err];
    if (err) {
        [err log];
    }
    return ret;
}

@end
