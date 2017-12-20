
# import "app.h"
# import "VCPracticeToolbox.h"
# import "QCTestingSuite.h"

@interface VPracticeToolbox : UIViewExt

@property (nonatomic, readonly) UIButtonExt
*btnMessage,
*btnAtStart,
*btnAtStop,
*btnAtPlay;

@property (nonatomic, readonly) UITextFieldExt *inpText;

@end

@implementation VPracticeToolbox

- (void)onInit {
    [super onInit];    
    self.backgroundColor = [UIColor grayColor];
    
    [self addSubview:BLOCK_RETURN({
        _btnMessage = [UIButtonExt temporary];
        _btnMessage.text = @"Click Me";
        return _btnMessage;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnAtStart = [UIButtonExt temporary];
        _btnAtStart.text = @"AT Start";
        return _btnAtStart;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnAtStop = [UIButtonExt temporary];
        _btnAtStop.text = @"AT Stop";
        return _btnAtStop;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnAtPlay = [UIButtonExt temporary];
        _btnAtPlay.text = @"AT Play";
        return _btnAtPlay;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _inpText = [UITextFieldExt temporary];
        _inpText.borderStyle = UITextBorderStyleLine;
        _inpText.text = @"输入文字";
        return _inpText;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIHBox* box = [UIHBox boxWithRect:rect];
    [box addFlex:1 withSpacing:5 VBox:^(UIVBox *box) {
        [box addPixel:30 toView:_btnMessage];
        [box addFlex:1 toView:nil];
        
        [box addPixel:30 toView:_btnAtStart];
        [box addPixel:30 toView:_btnAtStop];
        [box addPixel:30 toView:_btnAtPlay];
        
        [box addFlex:1 toView:nil];
        [box addPixel:30 toView:_inpText];
    }];
    [box addFlex:1 toView:nil];
    [box apply];
}

- (CGSize)bestSize:(CGSize)sz {
    return CGSizeMake(200, 200);
}

@end

@implementation VCPracticeToolbox

- (void)onInit {
    [super onInit];
    
    self.classForView = [VPracticeToolbox class];
}

- (void)onLoaded {
    [super onLoaded];
    
    VPracticeToolbox* view = (id)self.view;
    [view.btnMessage.signals connect:kSignalClicked withBlock:^(SSlot *s) {
        [UIHud Text:@"CLICKED"];
    }];
    
    [view.btnAtStart.signals connect:kSignalClicked withSelector:@selector(actAtStart) ofTarget:self];
    [view.btnAtStop.signals connect:kSignalClicked withSelector:@selector(actAtStop) ofTarget:self];
    [view.btnAtPlay.signals connect:kSignalClicked withSelector:@selector(actAtPlay) ofTarget:self];
}

- (void)actAtStart {
    DEVELOP_EXPRESS([[QCTestingSuite shared] record]);
}

- (void)actAtStop {
    DEVELOP_EXPRESS([[QCTestingSuite shared].recordingProfile stop]);
}

- (void)actAtPlay {
    DEVELOP_EXPRESS([[QCTestingSuite shared].recordingProfile play]);
}

@end
