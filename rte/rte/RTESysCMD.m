
# import "Common.h"
# import "RTESysCMD.h"
# import "RTESysCMDDisconnect.h"

@implementation RTESysCMDObject

- (BOOL)readData:(NSDictionary *)dict {
    return YES;
}

@end

@interface RTESysCMD ()

@property (nonatomic, retain) RTESysCMDObject* cmdobj;

@end

@implementation RTESysCMD

@synthesize command = _command;
@synthesize cmdobj = _cmdobj;

- (id)init {
    self = [super init];
    
    _type = RTE_SYSCMD;
    
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_cmdobj);
    
    SUPER_DEALLOC;
}

- (BOOL)readData:(NSDictionary *)dict {
    if ([super readData:dict] == NO)
        return NO;
    
    NSDictionary* p = [[dict getString:@"P"] jsonObject];
    if (p == nil)
        return YES;
    
    _command = [p getInt:@"CMD" def:-1];
    
    RTESysCMDObject* tmpobj = nil;
    
    switch (_command)
    {
        case RTE_SYSCMD_DISCONNECT: {
            tmpobj = [[RTESysCMDDisconnect alloc] init];
        } break;
    }
    
    [tmpobj readData:p];
    
    self.cmdobj = tmpobj;
    SAFE_RELEASE(tmpobj);
    
    return YES;
}

@end