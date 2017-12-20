
# import "app.h"
# import "VCPracticeFeatures.h"
# import "VCPracticeWidgets.h"

# import "VCPracticeAddressBook.h"
# import "VCPracticePosture.h"
# import "VCPracticeiBeacon.h"
# import "VCPracticeToday.h"
# import "VCPracticeTouchID.h"
# import "VCPracticePhotos.h"
# import "VCPracticeStorageProvider.h"
# import "VCPracticeHomeKit.h"
# import "VCPracticeHealthKit.h"
# import "VCPracticeTTS.h"
# import "VCPracticeOpenURL.h"
# import "VCPracticeSystemLog.h"
# import "VCPracticeAppDownload.h"

@interface VPracticeFeatures : UIScrollViewExt

@property (nonatomic, readonly) VPracticeButton
*btnOpenURL,
*btnAddbok,
*btnPosture,
*btniBeacon,
*btnToday,
*btnTouchid,
*btnKeyboard,
*btnAction,
*btnShare,
*btnPhotos,
*btnFileSync,
*btnStorageProvider,
*btnHomekit,
*btnHealthkit,
*btnAppDownload,
*btnSyslog,
*btnTTS
;

@end

@implementation VPracticeFeatures

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:BLOCK_RETURN({
        _btnOpenURL = [VPracticeButton temporary];
        _btnOpenURL.text = @"OpenURL";
        return _btnOpenURL;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnAddbok = [VPracticeButton temporary];
        _btnAddbok.text = @"AddressBook";
        return _btnAddbok;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnPosture = [VPracticeButton temporary];
        _btnPosture.text = @"Posture";
        return _btnPosture;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btniBeacon = [VPracticeButton temporary];
        _btniBeacon.text = @"iBeacon";
        return _btniBeacon;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnToday = [VPracticeButton temporary];
        _btnToday.text = @"Today";
        return _btnToday;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnTouchid = [VPracticeButton temporary];
        _btnTouchid.text = @"TouchID";
        return _btnTouchid;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnKeyboard = [VPracticeButton temporary];
        _btnKeyboard.text = @"Keyboard";
        return _btnKeyboard;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnAction = [VPracticeButton temporary];
        _btnAction.text = @"Action";
        return _btnAction;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnShare = [VPracticeButton temporary];
        _btnShare.text = @"Share";
        return _btnShare;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnPhotos = [VPracticeButton temporary];
        _btnPhotos.text = @"Photos";
        return _btnPhotos;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnFileSync = [VPracticeButton temporary];
        _btnFileSync.text = @"FileSync";
        return _btnFileSync;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnStorageProvider = [VPracticeButton temporary];
        _btnStorageProvider.text = @"Storage Provider";
        return _btnStorageProvider;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnHomekit = [VPracticeButton temporary];
        _btnHomekit.text = @"HomeKit";
        return _btnHomekit;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnHealthkit = [VPracticeButton temporary];
        _btnHealthkit.text = @"HealthKit";
        return _btnHealthkit;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnSyslog = [VPracticeButton temporary];
        _btnSyslog.text = @"Syslog";
        return _btnSyslog;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnAppDownload = [VPracticeButton temporary];
        _btnAppDownload.text = @"AppDownload";
        return _btnAppDownload;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnTTS = [VPracticeButton temporary];
        _btnTTS.text = @"TTS";
        return _btnTTS;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox* box = [UIVBox boxWithRect:rect withSpacing:5];
    [box addPixel:30 toView:_btnOpenURL];
    [box addPixel:30 toView:_btnAddbok];
    [box addPixel:30 toView:_btnPosture];
    [box addPixel:30 toView:_btniBeacon];
    [box addPixel:30 toView:_btnToday];
    [box addPixel:30 toView:_btnTouchid];
    [box addPixel:30 toView:_btnKeyboard];
    [box addPixel:30 toView:_btnAction];
    [box addPixel:30 toView:_btnShare];
    [box addPixel:30 toView:_btnPhotos];
    [box addPixel:30 toView:_btnFileSync];
    [box addPixel:30 toView:_btnStorageProvider];
    [box addPixel:30 toView:_btnHomekit];
    [box addPixel:30 toView:_btnHealthkit];
    [box addPixel:30 toView:_btnSyslog];
    [box addPixel:30 toView:_btnAppDownload];
    [box addPixel:30 toView:_btnTTS];
    [box apply];
}

@end

@implementation VCPracticeFeatures

- (void)onInit {
    [super onInit];
    self.title = @"FEATURES";
    self.hidesBottomBarWhenPushed = YES;
    self.classForView = [VPracticeFeatures class];
}

- (void)onLoaded {
    [super onLoaded];
    
    VPracticeFeatures* view = (id)self.view;
    [view.btnOpenURL.signals connect:kSignalClicked withSelector:@selector(actOpenURL) ofTarget:self];
    [view.btnAddbok.signals connect:kSignalClicked withSelector:@selector(actAB) ofTarget:self];
    [view.btnPosture.signals connect:kSignalClicked withSelector:@selector(actPosture) ofTarget:self];
    [view.btniBeacon.signals connect:kSignalClicked withSelector:@selector(actiBeacon) ofTarget:self];
    [view.btnToday.signals connect:kSignalClicked withSelector:@selector(actToday) ofTarget:self];
    [view.btnTouchid.signals connect:kSignalClicked withSelector:@selector(actTouchid) ofTarget:self];
    [view.btnPhotos.signals connect:kSignalClicked withSelector:@selector(actPhotos) ofTarget:self];
    [view.btnHomekit.signals connect:kSignalClicked withSelector:@selector(actHomeKit) ofTarget:self];
    [view.btnHealthkit.signals connect:kSignalClicked withSelector:@selector(actHealthKit) ofTarget:self];
    [view.btnStorageProvider.signals connect:kSignalClicked withSelector:@selector(actStorageProvider) ofTarget:self];
    [view.btnSyslog.signals connect:kSignalClicked withSelector:@selector(actSyslog) ofTarget:self];
    [view.btnAppDownload.signals connect:kSignalClicked withSelector:@selector(actAppDownload) ofTarget:self];
    [view.btnTTS.signals connect:kSignalClicked withSelector:@selector(actTTS) ofTarget:self];
}

- (void)actOpenURL {
    VCPracticeOpenURL* ctlr = [VCPracticeOpenURL temporary];
    [self.navigationController pushViewController:ctlr];
}

- (void)actAB {
    VCPracticeAddressBook* ctlr = [VCPracticeAddressBook temporary];
    [self.navigationController pushViewController:ctlr];
}

- (void)actPosture {
    VCPracticePosture* ctlr = [VCPracticePosture temporary];
    [self.navigationController pushViewController:ctlr];
}

- (void)actiBeacon {
    [self.navigationController pushViewController:[VCPracticeiBeacon temporary]];
}

- (void)actToday {
    [self.navigationController pushViewController:[VCPracticeToday temporary]];
}

- (void)actTouchid {
    [self.navigationController pushViewController:[VCPracticeTouchID temporary]];
}

- (void)actPhotos {
    [self.navigationController pushViewController:[VCPracticePhotos temporary]];
}

- (void)actStorageProvider {
    [self.navigationController pushViewController:[VCPracticeStorageProvider temporary]];
}

- (void)actHomeKit {
    [self.navigationController pushViewController:[VCPracticeHomeKit temporary]];
}

- (void)actHealthKit {
    [self.navigationController pushViewController:[VCPracticeHealthKit temporary]];
}

- (void)actSyslog {
    [self.navigationController pushViewController:[VCPracticeSystemLog temporary]];
}

- (void)actAppDownload {
    [self.navigationController pushViewController:[VCPracticeAppDownload temporary]];
}

- (void)actTTS {
    VCPracticeTTS* ctlr = [VCPracticeTTS temporary];
    [self.navigationController pushViewController:ctlr];
}

@end
