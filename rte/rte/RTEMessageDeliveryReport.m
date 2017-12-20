
# import "Common.h"
# import "RTEMessageDeliveryReport.h"

@implementation RTEMessageDeliveryReport

- (id)init {
    self = [super init];
    
    _type = RTE_MESSAGEDELIVERYREPORT;
    
    return self;
}

- (void)dealloc {
    SUPER_DEALLOC;
}

@end
