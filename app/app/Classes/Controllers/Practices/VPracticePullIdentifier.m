
# import "app.h"
# import "VPracticePullIdentifier.h"
# import "UIPercentageWidgets.h"

@interface VPracticePullFlush ()

@property (nonatomic, readonly) UILabelExt *lblName;

@end

@implementation VPracticePullFlush

- (void)onInit {
    [super onInit];
    
    _lblName = [[UILabelExt alloc] init];
    [self addSubview:_lblName];
    SAFE_RELEASE(_lblName);
    
    _lblName.textColor = [UIColor blueColor];
    _lblName.textFont = [UIFont boldSystemFontOfSize:20];
    _lblName.textAlignment = NSTextAlignmentCenter;
}

- (void)pullSizeNeedChanged:(CGSize)sz {
    [super pullSizeNeedChanged:sz];
    
    if (self.workState == kNSWorkStateDoing)
        return;

    if (sz.height < self.toggleValue * .8f)
        _lblName.text = @"下拉刷新";
    else
        _lblName.text = @"即将刷新";
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    _lblName.frame = rect;
}

@end

@interface VPracticePullMore ()

@property (nonatomic, readonly) UILabelExt *lblName;
@property (nonatomic, readonly) UIActivityIndicatorExt *indAct;

@end

@implementation VPracticePullMore

- (void)onInit {
    [super onInit];
    
    _lblName = [[UILabelExt alloc] init];
    [self addSubview:_lblName];
    SAFE_RELEASE(_lblName);
    
    _indAct = [[UIActivityIndicatorExt alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:_indAct];
    SAFE_RELEASE(_indAct);
    
    _lblName.textColor = [UIColor redColor];
    _lblName.textFont = [UIFont boldSystemFontOfSize:20];
    _lblName.text = @"自定义的读取更多";
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox* box = [UIVBox boxWithRect:rect withSpacing:0];
    [box addPixel:_lblName.bestHeightForWidth toView:_lblName];
    [box addPixel:self.labelText.bestHeightForWidth toView:self.labelText];
    [box apply];
    
    _indAct.rightCenter = CGRectRightCenter(rect);
}

- (void)setSize:(CGSize)sz {
    sz.height = 70;
    [super setSize:sz];
}

- (void)setWorkState:(NSWorkState)workState {
    [super setWorkState:workState];
    switch (workState)
    {
        default:
        case kNSWorkStateDone: [_indAct stopAnimating]; break;
        case kNSWorkStateDoing: [_indAct startAnimating]; break;
    }
}

@end
