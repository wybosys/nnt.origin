
# import "app.h"
# import "VCPracticePageTrans.h"

@interface VPracticePageTrans : UIViewExt

@property (nonatomic, readonly) UILabelButton *v0, *v1;

@end

@implementation VPracticePageTrans

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:BLOCK_RETURN({
        _v1 = [UILabelButton temporary];
        _v1.text = @"1";
        _v1.backgroundColor = [UIColor randomColor];
        [_v1.signals connect:kSignalClicked withBlock:^(SSlot *s) {
            [UIHud Text:@"1"];
        }];
        return _v1;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _v0 = [UILabelButton temporary];
        _v0.text = @"0";
        _v0.backgroundColor = [UIColor randomColor];
        [_v0.signals connect:kSignalClicked withBlock:^(SSlot *s) {
            [UIHud Text:@"0"];
        }];
        return _v0;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    _v0.frame = _v1.frame = CGRectMake(10, 10, 100, 200);
}

@end

@implementation VCPracticePageTrans

- (void)onInit {
    [super onInit];
    self.classForView = [VPracticePageTrans class];
}

- (void)onLoaded {
    [super onLoaded];
    
    self.navigationItem.rightBarButtonItems = @[
                                                BLOCK_RETURN({
                                                    UIBarButtonItem* btn = [UIBarButtonItem itemWithTitle:@"Custom"];
                                                    [btn.signals connect:kSignalClicked withSelector:@selector(optCustom) ofTarget:self];
                                                    return btn;
                                                }),
                                                BLOCK_RETURN({
                                                    UIBarButtonItem* btn = [UIBarButtonItem itemWithTitle:@"Sys"];
                                                    [btn.signals connect:kSignalClicked withSelector:@selector(optSys) ofTarget:self];
                                                    return btn;
                                                })
                                                ];
}

- (void)optSys {
    VPracticePageTrans* view = (id)self.view;
    UIActionSheetExt* as = [UIActionSheetExt temporary];
    [[as addItem:@"Flip"].signals connect:kSignalClicked withBlock:^(SSlot *s) {
        UITransition* tran = [UITransition temporary];
        tran.view = view.v1;
        tran.type = kUITransitionFlip;
        [view.v0 addTransition:tran];
    }];
    [[as addItem:@"Slide"].signals connect:kSignalClicked withBlock:^(SSlot *s) {
        UITransition* tran = [UITransition temporary];
        tran.view = view.v1;
        tran.type = kUITransitionSlide;
        [view.v0 addTransition:tran];
    }];
    [[as addItem:@"Curl"].signals connect:kSignalClicked withBlock:^(SSlot *s) {
        UITransition* tran = [UITransition temporary];
        tran.view = view.v1;
        tran.type = kUITransitionCurl;
        [view.v0 addTransition:tran];
    }];
    [[as addItem:@"Cross"].signals connect:kSignalClicked withBlock:^(SSlot *s) {
        UITransition* tran = [UITransition temporary];
        tran.view = view.v1;
        tran.type = kUITransitionCrossDissolve;
        [view.v0 addTransition:tran];
    }];
    [[as addItem:@"Ripple"].signals connect:kSignalClicked withBlock:^(SSlot *s) {
        UITransition* tran = [UITransition temporary];
        tran.view = view.v1;
        tran.type = kUITransitionRipple;
        [view.v0 addTransition:tran];
    }];
    [[as addItem:@"Suck"].signals connect:kSignalClicked withBlock:^(SSlot *s) {
        UITransition* tran = [UITransition temporary];
        tran.view = view.v1;
        tran.type = kUITransitionSuck;
        [view.v0 addTransition:tran];
    }];
    [[as addItem:@"Cube"].signals connect:kSignalClicked withBlock:^(SSlot *s) {
        UITransition* tran = [UITransition temporary];
        tran.view = view.v1;
        tran.type = kUITransitionCube;
        [view.v0 addTransition:tran];
    }];
    [[as addItem:@"Camera"].signals connect:kSignalClicked withBlock:^(SSlot *s) {
        UITransition* tran = [UITransition temporary];
        tran.view = view.v1;
        tran.type = kUITransitionCameraIris;
        [view.v0 addTransition:tran];
    }];
    [as show];
}

- (void)optCustom {
    
}

@end
