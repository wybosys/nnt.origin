//
//  AFRecorder.h
//  voice
//
//  Created by wangfeng on 12-11-9.
//
//
#import <AVFoundation/AVFoundation.h>
#import "Recorder.h"

@interface AFRecorder : Recorder<AVAudioRecorderDelegate>

+(AFRecorder*)sharedInstance;
@end
