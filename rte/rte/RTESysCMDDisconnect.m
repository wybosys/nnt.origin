
# import "Common.h"
# import "RTESysCMDDisconnect.h"

@implementation RTESysCMDDisconnect

@synthesize type = _type;

- (void)dealloc {
    ZERO_RELEASE(_message);
    SUPER_DEALLOC;
}

- (BOOL)readData:(NSDictionary *)dict {
    
    _type = [dict getInt:@"EC"];
    
    switch (_type) {
            
        default: {
            self.message = [dict getString:@"EM"];
        } break;
            
        case kRTESysCMDDisconnectTypeAuthFailed: {
            self.message = @"认证失败";
        } break;
            
        case kRTESysCMDDisconnectTypeLoginedOnAnotherDevice: {
            self.message = @"在另外一台设备上登录";            
        } break;
            
        case kRTESysCMDDisconnectTypeServerIsBusy: {
            self.message = @"服务器正忙，请稍后再尝试连接";
        } break;
            
    }
    
    return YES;
}

@end