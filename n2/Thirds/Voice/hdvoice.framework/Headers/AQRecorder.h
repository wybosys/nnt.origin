//
//  VoiceRecorder.h
//  SpeakHere
//
//  Created by  on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "VoiceCommon.h"
#import "Recorder.h"
#define NUM_BUFFERS         3

@interface AQRecorder : Recorder

+(AQRecorder*)sharedInstance;
@end

