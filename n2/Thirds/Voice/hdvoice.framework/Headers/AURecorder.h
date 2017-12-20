//
//  AURecorder.h
//  voice
//
//  Created by  on 12-9-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

//#import "VoiceCommon.h"
#import "Recorder.h"




@interface AURecorder : Recorder


+(AURecorder*)sharedInstance;
-(void)setProperty:(NSObject*)value for:(NSString*)propName;



@end

