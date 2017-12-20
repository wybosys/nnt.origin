
# import "Common.h"
# import "AdsPlatform.h"
//# import <GoogleConversionTracking/ACTReporter.h>

# define ACTConversionID @"972827301"
# define ACTConversionLabel @"PVyyCOOB8BEQpdXwzwM"
# define ACTConversionValue @"1.000000"

@implementation GoogleACT

SHARED_IMPL;

- (void)onInit {
    [super onInit];
  
    /*
    [ACTConversionReporter reportWithConversionID:ACTConversionID
                                            label:ACTConversionLabel
                                            value:ACTConversionValue
                                     isRepeatable:NO];
     */
}

- (void)onFin {
    [super onFin];
}

@end
