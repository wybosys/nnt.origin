
# import "app.h"
# import "VCPracticeEffects.h"
# import "VCPracticeWidgets.h"
# import "VCPracticeBlur.h"
# import "VCPracticeAnimationProducer.h"
# import "VCPracticeSnapshot.h"
# import "VCPracticeMask.h"
# import "VCPracticePageTrans.h"

@interface VPracticeEffects : UIViewExt

@property (nonatomic, readonly) VPracticeButton
*btnSnapshot,
*btnBlur,
*btnAniPdr,
*btnMask,
*btnPageTrans
;

@end

@implementation VPracticeEffects

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:BLOCK_RETURN({
        _btnSnapshot = [VPracticeButton temporary];
        _btnSnapshot.text = @"Snapshot";
        return _btnSnapshot;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnBlur = [VPracticeButton temporary];
        _btnBlur.text = @"Blur";
        return _btnBlur;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnAniPdr = [VPracticeButton temporary];
        _btnAniPdr.text = @"Animation Producer";
        return _btnAniPdr;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnMask = [VPracticeButton temporary];
        _btnMask.text = @"Mask";
        return _btnMask;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnPageTrans = [VPracticeButton temporary];
        _btnPageTrans.text = @"PageTrans";
        return _btnPageTrans;
    })];
}

- (void)onFin {
    [super onFin];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox* box = [UIVBox boxWithRect:rect withSpacing:5];
    [box addPixel:30 toView:_btnSnapshot];
    [box addPixel:30 toView:_btnBlur];
    [box addPixel:30 toView:_btnAniPdr];
    [box addPixel:30 toView:_btnMask];
    [box addPixel:30 toView:_btnPageTrans];
    [box apply];
}

@end

@implementation VCPracticeEffects

- (void)onInit {
    [super onInit];
    self.classForView = [VPracticeEffects class];
}

- (void)onFin {
    [super onFin];
}

- (void)onLoaded {
    [super onLoaded];
    
    VPracticeEffects* view = (id)self.view;
    [view.btnSnapshot.signals connect:kSignalClicked withSelector:@selector(actSnapshot) ofTarget:self];
    [view.btnBlur.signals connect:kSignalClicked withSelector:@selector(actBlur) ofTarget:self];
    [view.btnAniPdr.signals connect:kSignalClicked withSelector:@selector(actAniPdr) ofTarget:self];
    [view.btnMask.signals connect:kSignalClicked withSelector:@selector(actMask) ofTarget:self];
    [view.btnPageTrans.signals connect:kSignalClicked withSelector:@selector(actPageTrans) ofTarget:self];
}

- (void)actSnapshot {
    VCPracticeSnapshot* ctlr = [VCPracticeSnapshot temporary];
    [self.navigationController pushViewController:ctlr];
}

- (void)actBlur {
    VCPracticeBlur* ctlr = [VCPracticeBlur temporary];
    [self.navigationController pushViewController:ctlr];
}

- (void)actAniPdr {
    VCPracticeAnimationProducer* ctlr = [VCPracticeAnimationProducer temporary];
    [self.navigationController pushViewController:ctlr];
}

- (void)actMask {
    VCPracticeMask* ctlr = [VCPracticeMask temporary];
    [self.navigationController pushViewController:ctlr];
}

- (void)actPageTrans {
    VCPracticePageTrans* ctlr = [VCPracticePageTrans temporary];
    [self.navigationController pushViewController:ctlr];
}

@end
