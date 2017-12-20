
# import "app.h"
# import "VCPracticeiBeacon.h"
# import "MapEnhance.h"
# import "VCPracticeWidgets.h"

@interface VPracticeiBeacon : UIViewExt

@property (nonatomic, readonly) VPracticeButton
*btnStart,
*btnLook
;

@end

@implementation VPracticeiBeacon

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:BLOCK_RETURN({
        _btnStart = [VPracticeButton temporary];
        _btnStart.text = @"Start";
        return _btnStart;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnLook = [VPracticeButton temporary];
        _btnLook.text = @"Look";
        return _btnLook;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox* box = [UIVBox boxWithRect:rect withSpacing:5];
    [box addPixel:30 toView:_btnStart];
    [box addPixel:30 toView:_btnLook];
    [box apply];
}

@end

@implementation VCPracticeiBeacon

- (void)onInit {
    [super onInit];
    self.classForView = [VPracticeiBeacon class];
}

- (void)onLoaded {
    [super onLoaded];
    
    VPracticeiBeacon* view = (id)self.view;
    [view.btnStart.signals connect:kSignalClicked withSelector:@selector(actStart) ofTarget:self];
    [view.btnLook.signals connect:kSignalClicked withSelector:@selector(actLook) ofTarget:self];
}

- (void)actStart {
    [iBeaconService shared].proximityid = @"646202FE-E20B-4647-98F5-AAEBA2CE2B33";
    [iBeaconService shared].identifier = @"com.hoodinn.hdapp";
    [[iBeaconService shared] listen];
}

- (void)actLook {
    [[iBeaconService shared] look];
}

@end
