
# import "AVCamCaptureManager.h"

@class AVCamRecorder;

@interface AVCamRecorderManager : AVCamCaptureManager {
}

@property (nonatomic, retain) AVCamRecorder *recorder;

- (void)startRecording;
- (void)stopRecording;

@end
