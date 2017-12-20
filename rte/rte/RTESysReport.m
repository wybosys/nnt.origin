
# import "Common.h"
# import "RTESysReport.h"

@implementation RTESysReport

- (id)init {
    self = [super init];
    
    _type = RTE_SYSREPORT;
    
    return self;
}

@end