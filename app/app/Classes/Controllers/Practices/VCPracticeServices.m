
# import "app.h"
# import "VCPracticeServices.h"
# import "NSStorage.h"

@interface VPracticeServices : UIViewExt

@property (nonatomic, readonly) UITextFieldExt *inpPers;
@property (nonatomic, readonly) UIButtonExt
*btnSave, *btnLoad;

@end

@implementation VPracticeServices

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:BLOCK_RETURN({
        _inpPers = [UITextFieldExt temporary];
        _inpPers.placeholder = @"输入持久化内容";
        _inpPers.borderStyle = UITextBorderStyleBezel;
        return _inpPers;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnSave = [UIButtonExt button];
        _btnSave.text = @"SAVE";
        return _btnSave;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnLoad = [UIButtonExt button];
        _btnLoad.text = @"LOAD";
        return _btnLoad;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox* box = [UIVBox boxWithRect:rect];
    [box addPixel:30 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_inpPers];
    }];
    [box addPixel:30 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_btnSave];
        [box addFlex:1 toView:_btnLoad];
    }];
    [box apply];
}

@end

@implementation VCPracticeServices

- (void)onInit {
    [super onInit];
    self.classForView = [VPracticeServices class];
}

- (void)onLoaded {
    [super onLoaded];
    VPracticeServices* view = (id)self.view;
    [view.btnLoad.signals connect:kSignalClicked withSelector:@selector(actLoad) ofTarget:self];
    [view.btnSave.signals connect:kSignalClicked withSelector:@selector(actSave) ofTarget:self];
}

- (void)actLoad {
    VPracticeServices* view = (id)self.view;
    NSString* str = [[NSPersistentStorageService shared] getObjectForKey:@"test.service.per" def:@""];
    view.inpPers.text = str;
}

- (void)actSave {
    VPracticeServices* view = (id)self.view;
    NSString* str = view.inpPers.text;
    [[NSPersistentStorageService shared] setObject:str forKey:@"test.service.per"];
}

@end
