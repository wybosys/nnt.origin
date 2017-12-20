
# ifndef __SOCKETSTREAM_9F57ECFD63D44AC3A64C24B6141A0C8F_H_INCLUDED
# define __SOCKETSTREAM_9F57ECFD63D44AC3A64C24B6141A0C8F_H_INCLUDED

@interface SocketStream : NSObject {
    
    NSMutableData *_buf;
    NSUInteger _length;
    NSInteger _tag;
    
}

SIGNALS;

@property (nonatomic, retain) NSMutableData *buf;
@property (nonatomic, assign) NSUInteger length;
@property (nonatomic, assign) NSInteger tag;

- (void)reset;

@end

SIGNAL_DECL(kSignalSocketBytesAvailable) @"::socket::bytes::available";
SIGNAL_DECL(kSignalSocketBytesCompleted) @"::socket::bytes::completed";

# endif
