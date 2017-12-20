
# import "Common.h"
# import "SocketStream.h"

@implementation SocketStream

@synthesize buf = _buf;
@synthesize length = _length;
@synthesize tag = _tag;

- (id)init {
    self = [super init];
    
    _tag = 0;
    _length = 1024;
    _buf = [[NSMutableData alloc] init];
    
    return self;
}

- (void)dealloc {
    SAFE_RELEASE(_buf);
    
    [super dealloc];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalSocketBytesAvailable)
SIGNAL_ADD(kSignalSocketBytesCompleted)
SIGNALS_END

- (void)reset {
    self.buf = [NSMutableData data];
}

@end
