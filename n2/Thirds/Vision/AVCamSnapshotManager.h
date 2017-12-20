
# import "AVCamCaptureManager.h"

@interface AVCamSnapshotManager : AVCamCaptureManager <AVCaptureVideoDataOutputSampleBufferDelegate> {
    @private
    BOOL _snapshot;
}

@property (nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, retain) AVCaptureVideoDataOutput *snapshotOutput;

- (void)captureStillImage;
- (void)snapshot;

@end
