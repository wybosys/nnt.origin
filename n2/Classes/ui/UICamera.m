
# import "Common.h"
# import "UICamera.h"
# import "AVCamSnapshotManager.h"

@interface UICameraView ()
{
    UILabelExt *_tipsLabel;
}

@property (nonatomic, readonly) AVCamSnapshotManager *captureManager;
@property (nonatomic, assign) AVCaptureVideoPreviewLayer* layerCapture;

@end

@implementation UICameraView

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    _captureManager = [[AVCamSnapshotManager alloc] init];
    [_captureManager setupSession];
    
    _layerCapture = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureManager.session];
    AVCaptureConnection* connection = _layerCapture.connection;
    if (connection.isVideoOrientationSupported)
        connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    _layerCapture.videoGravity = AVLayerVideoGravityResizeAspectFill;

    
    // 添加摄像机实现视图
    self.layer.masksToBounds = YES;
    [self.layer addSublayer:_layerCapture];
    
    [self addSubview:BLOCK_RETURN({
        _tipsLabel = [UILabelExt temporary];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.text = @"不能使用照相机";
        _tipsLabel.visible = ![self isAvaliable];
        return _tipsLabel;
    })];
}

- (void)onFin {
    if (_captureManager)
        _captureManager.delegate = nil;
    SAFE_RELEASE(_layerCapture);
    SAFE_RELEASE(_captureManager);
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalSnapshot)
SIGNALS_END

- (BOOL)isAvaliable {
    if (kDeviceRunningSimulator)
        return NO;
    return _layerCapture.connection != nil;
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    if (_tipsLabel)
        _tipsLabel.frame = rect;
    if (_layerCapture)
        _layerCapture.frame = rect;
}

- (void)start {
    if (_captureManager)
        [_captureManager startSession];
}

- (void)stop {
    if (_captureManager)
        [_captureManager stopSession];
}

- (void)snapshot {
    if (_captureManager)
        [_captureManager snapshot];
}

@end

@interface UICamera () <AVCamCaptureManagerDelegate>
@end

@implementation UICamera

- (void)onInit {
    [super onInit];
    self.classForView = [UICameraView class];
}

- (void)onFin {
    [super onFin];
}

- (void)onLoaded {
    [super onLoaded];
    UICameraView* view = (id)self.view;
    view.captureManager.delegate = self;
}

- (void)onAppeared {
    [super onAppeared];
    UICameraView* view = (id)self.view;
    [view start];
}

- (void)onDisappeared {
    [super onDisappeared];
    UICameraView* view = (id)self.view;
    [view stop];
}

- (void)snapshot {
    UICameraView* view = (id)self.view;
    [view snapshot];
}

// delegate
- (void)captureManagerSnapshotImageCompleted:(AVCamCaptureManager *)captureManager image:(UIImage *)image {
    [self.signals emit:kSignalSnapshot withData:image];
}

@end
