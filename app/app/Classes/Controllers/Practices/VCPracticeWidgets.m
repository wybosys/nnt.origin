
# import "app.h"
# import "VCPracticeWidgets.h"
# import "VPracticeKeyboardPanel.h"
# import "UIPopoverView.h"
# import "VCPracticeSketch.h"
# import "VCPracticeToolbox.h"
# import "VCPracticeWidgets.h"
# import "VCPracticePresent.h"
# import "VCPracticePercentage.h"

@implementation VPracticePopover

- (void)onInit {
    [super onInit];
    
    for (int i = 0; i < 4; ++i) {
        [self addSubview:
         [self reusableObject:@(i) instance:^id{
            UIButtonExt* btn = [UIButtonExt temporary];
            btn.backgroundColor = [UIColor blackColor];
            btn.text = [NSString stringWithFormat:@"BUTTON %d", i];
            [btn.signals connect:kSignalClicked withBlock:^(SSlot *s) {
                [UIHud Text:btn.text];
            }];
            return btn;
        }]];
    }
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    UIVBox* box = [UIVBox boxWithRect:rect withSpacing:5];
    for (int i = 0; i < 4; ++i) {
        UIView* v = [self reusableObject:@(i)];
        [box addFlex:1 toView:v];
    }
    [box apply];
}

- (CGSize)bestSize:(CGSize)sz {
    return CGSizeMake(200, 300);
}

@end

@interface VPracticeWidgets : UIScrollViewExt

@property (nonatomic, readonly) UITextViewExt *txtGrow, *txtView;
@property (nonatomic, readonly) VPracticeButton
*btnDt, *btnPaste, *btnCrash,
*btnDesk, *btnPp0, *btnPp1,
*btnTouches,
*btnHudPrg, *btnHudTxt, *btnHudLongText,
*btnStatusBar, *btnPercentage,
*btnSketch,
*btnPresent;

@property (nonatomic, readonly) UILabelExt *lblStylized0, *lblStylized1;

@property (nonatomic, readonly) VPracticeKeyboardPanel *pnlKb;
@property (nonatomic, readonly) UITextFieldExt *inpValue, *inpPinyin, *inpSecure;
@property (nonatomic, readonly) UISearchBarExt *barSearch;
@property (nonatomic, readonly) UIView *aniSpin;

@end

@implementation VPracticeWidgets

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    [self.signals connect:kSignalDraggingBegin withSelector:@selector(Close) ofClass:[UIKeyboardExt class]];
    
    [self addSubview:BLOCK_RETURN({
        _txtGrow = [UITextViewExt temporary];
        _txtGrow.text = @"GROW TEXTVIEW";
        [_txtGrow.signals connect:kSignalConstraintChanged withSelector:@selector(setNeedsLayout) ofTarget:self];
        return _txtGrow;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _txtView = [UITextViewExt temporary];
        _txtView.returnAsLinebreak = NO;
        _txtView.text = @"TextView as TextField";
        _txtView.textAlignment = NSTextAlignmentCenter;
        return _txtView;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnDt = [VPracticeButton temporary];
        _btnDt.text = @"DATETIME";
        return _btnDt;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnPaste = [VPracticeButton temporary];
        _btnPaste.text = @"PASTE";
        return _btnPaste;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnCrash = [VPracticeButton temporary];
        _btnCrash.text = @"CRASH";
        return _btnCrash;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnDesk = [VPracticeButton temporary];
        _btnDesk.text = @"DESK";
        _btnDesk.backgroundColor = [UIColor whiteColor];
        return _btnDesk;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnPp0 = [VPracticeButton temporary];
        _btnPp0.text = @"POPOVER1";
        return _btnPp0;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnPp1 = [VPracticeButton temporary];
        _btnPp1.text = @"POPOVER2";
        return _btnPp1;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnPresent = [VPracticeButton temporary];
        _btnPresent.text = @"PRESENT";
        return _btnPresent;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnTouches = [VPracticeButton temporary];
        _btnTouches.text = @"TOUCHES";
        return _btnTouches;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnHudPrg = [VPracticeButton temporary];
        _btnHudPrg.text = @"HUDProgress";
        return _btnHudPrg;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnHudTxt = [VPracticeButton temporary];
        _btnHudTxt.text = @"HUDText";
        return _btnHudTxt;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnHudLongText = [VPracticeButton temporary];
        _btnHudLongText.text = @"LongText";
        return _btnHudLongText;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnStatusBar = [VPracticeButton temporary];
        _btnStatusBar.text = @"StatusBar";
        return _btnStatusBar;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnPercentage = [VPracticeButton temporary];
        _btnPercentage.text = @"Percentage";
        return _btnPercentage;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _barSearch = [UISearchBarExt temporary];
        _barSearch.placeholder = @"STANDALONE SEARCH";
        return _barSearch;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnSketch = [VPracticeButton temporary];
        _btnSketch.text = @"SKETCH";
        return _btnSketch;
    })];
    
    NSStylizedString* str = [NSStylizedString temporary];
    [str append:[NSStylization styleWithTextColor:[UIColor grayColor] textFont:[UIFont systemFontOfSize:12]] format:@"灰色灰色灰色灰色灰色"];
    [str append:[NSStylization styleWithTextColor:[UIColor redColor] textFont:[UIFont systemFontOfSize:8]] format:@"红色红色红色红色红色"];
    [str append:[NSStylization styleWithTextColor:[UIColor blueColor] textFont:[UIFont systemFontOfSize:16]] format:@"蓝色蓝色蓝色蓝色蓝色"];
    
    [self addSubview:BLOCK_RETURN({
        _lblStylized0 = [UILabelExt temporary];
        _lblStylized0.textFont = [UIFont systemFontOfSize:16];
        _lblStylized0.textColor = [UIColor redColor];
        _lblStylized0.stylizedString = str;
        [_lblStylized0.signals connect:kSignalClicked withBlock:^(SSlot *s) {
            UILabel* lbl = (id)s.sender;
            lbl.text = @"SHORT TEXT";
        }];
        return [UIMarqueeWrapper wrapperWithView:_lblStylized0];
    })];
    
    [self addSubview:BLOCK_RETURN({
        _lblStylized1 = [UILabelExt temporary];
        _lblStylized1.stylizedString = str;
        //_lblStylized1.multilines = YES;
        _lblStylized1.numberOfLines = 2;
        return _lblStylized1;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _inpSecure = [[UITextFieldExt alloc] init];
        _inpSecure.secureTextEntry = YES;
        return _inpSecure;
    })];
    
    _inpValue = [[UITextFieldExt alloc] init];
    [self addSub:_inpValue];
    SAFE_RELEASE(_inpValue);
    
    _inpPinyin = [[UITextFieldExt alloc] init];
    [self addSub:_inpPinyin];
    SAFE_RELEASE(_inpPinyin);
    
    [self addSubview:BLOCK_RETURN({
        _pnlKb = [VPracticeKeyboardPanel temporary];
        //_pnlKb.responder = _txtGrow;
        return _pnlKb;
    })];
    
    _inpValue.borderStyle = UITextBorderStyleBezel;
    _inpValue.placeholderColor = [UIColor redColor];
    _inpValue.placeholder = @"INPUT [a-z]{0,6} Max 6 Cap Chars";
    _inpValue.patternValue = [NSRegularExpression cachedRegularExpressionWithPattern:@"[a-z]{0,6}"];
    [_inpValue.signals connect:kSignalValueInvalid withBlock:^(SSlot *s) {
        _inpValue.textColor = [UIColor redColor];
    }];
    [_inpValue.signals connect:kSignalValueValid withBlock:^(SSlot *s) {
        _inpValue.textColor = [UIColor blackColor];
    }];
    
    // ANI
    [self addSubview:BLOCK_RETURN({
        _aniSpin = [UIView temporary];
        _aniSpin.backgroundColor = [UIColor orangeColor];
        return _aniSpin;
    })];
    [_aniSpin.signals connect:kSignalClicked withBlock:^(SSlot *s) {
        int clicked = [[_aniSpin reusableObject:@"clicked"] intValue];
        switch (clicked % 3)
        {
            case 0: {
                CAAnimation* ani = [CAKeyframeAnimation Spin];
                ani.duration = 1;
                [_aniSpin.layer addAnimation:ani];
            } break;
            case 1: {
                CAAnimation* ani = [CAKeyframeAnimation Spin:NO];
                ani.duration = 1;
                [_aniSpin.layer addAnimation:ani];
            } break;
            case 2: {
                [_aniSpin.layer stopAnimations];
            } break;
        }
        [_aniSpin reusableObject:@"clicked" set:@(++clicked)];
    }];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    [UIView beginAnimations:nil context:nil];
    
    UIVBox* box = [UIVBox boxWithRect:rect withSpacing:5];
    [box addPixel:_txtGrow.bestHeightForWidth toView:_txtGrow];
    [box addPixel:60 toView:_txtView];
    
    [box addPixel:30 HBox:^(UIHBox *box) {
        box.padding = CGPaddingMake(0, 0, -5, 0);
        box.margin = CGMarginMake(0, 0, 5, 0);
        [box addFlex:1 toView:_btnDt];
        [box addFlex:1 toView:_btnPaste];
        [box addFlex:1 toView:_btnCrash];
    }];
    
    [box addPixel:30 withSpacing:0 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_btnDesk];
        [box addPixel:5 toView:nil];
        [box addFlex:1 toView:_btnPp0];
        [box addPixel:5 toView:nil];
        [box addFlex:1 toView:_btnPp1];
    }];
    
    [box addPixel:30 HBox:^(UIHBox *box) {
        box.padding = CGPaddingMake(0, 0, -5, 0);
        box.margin = CGMarginMake(0, 0, 5, 0);
        [box addFlex:2 toView:_btnPresent];
        [box addFlex:1 toView:_btnTouches];
    }];
    
    [box addPixel:30 HBox:^(UIHBox *box) {
        box.padding = CGPaddingMake(0, 0, -5, 0);
        box.margin = CGMarginMake(0, 0, 5, 0);
        [box addFlex:1 toView:_btnHudPrg];
        [box addFlex:1 toView:_btnHudTxt];
        [box addFlex:1 toView:_btnHudLongText];
    }];
    
    [box addPixel:30 HBox:^(UIHBox *box) {
        box.padding = CGPaddingMake(0, 0, -5, 0);
        box.margin = CGMarginMake(0, 0, 5, 0);
        [box addFlex:1 toView:_btnStatusBar];
        [box addFlex:1 toView:_btnPercentage];
    }];
    
    [box addPixel:(_barSearch.bestHeight + 10) toView:_barSearch];
    
    [box addPixel:30 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_btnSketch];
        [box addAspectWithX:1 andY:1 toView:_aniSpin];
    }];
    
    [box addPixel:30 toView:_inpSecure];
    [box addPixel:100 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_lblStylized0.superview];
        [box addFlex:1 toView:_lblStylized1];
    }];
    
    // 下一页的键盘区
    [box addFlex:1 toView:nil];
    [box addPixel:30 withSpacing:0 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_inpValue];
        [box addFlex:1 toView:_inpPinyin];
    }];
    [box addPixel:_pnlKb.bestHeight toView:_pnlKb];
    [box apply];
    
    [UIView commitAnimations];
    
    self.contentHeight = 604;
}

@end

@implementation VCPracticeWidgets

- (void)onInit {
    [super onInit];
    self.classForView = [VPracticeWidgets class];
}

- (void)onLoaded {
    [super onLoaded];
    VPracticeWidgets* view = (id)self.view;
    [view.btnDt.signals connect:kSignalClicked withSelector:@selector(actDT) ofTarget:self];
    [view.btnPaste.signals connect:kSignalClicked withSelector:@selector(actPaste) ofTarget:self];
    [view.btnDesk.signals connect:kSignalClicked withSelector:@selector(actPopoverDesk:) ofTarget:self];
    [view.btnPp0.signals connect:kSignalClicked withSelector:@selector(actPopover:) ofTarget:self];
    [view.btnPp1.signals connect:kSignalClicked withSelector:@selector(actPopover:) ofTarget:self];
    [view.inpValue.signals connect:kSignalValueChanged withSelector:@selector(actInputChange:) ofTarget:self];
    [view.btnSketch.signals connect:kSignalClicked withSelector:@selector(actSketch) ofTarget:self];
    [view.btnPresent.signals connect:kSignalClicked withSelector:@selector(actPresent) ofTarget:self];
    [view.btnStatusBar.signals connect:kSignalClicked withSelector:@selector(actStatusBar) ofTarget:self];
    [view.btnPercentage.signals connect:kSignalClicked withSelector:@selector(actPercentage) ofTarget:self];
    
    view.btnDt.menu = BLOCK_RETURN({
        UIMenuControllerExt* menu = [UIMenuControllerExt temporary];
        [[menu addItem:@"TEST"].signals connect:kSignalClicked withBlock:^(SSlot *s) {
            [UIHud Text:@"MENU CLICKED"];
        }];
        return menu;
    });
    
    [view.btnCrash addTarget:self action:@selector(actCrash) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = BLOCK_RETURN({
        UIBarButtonItem* btn = [UIBarButtonItem itemWithTitle:@"POPOVER"];
        [btn.signals connect:kSignalClicked withBlock:^(SSlot *s) {
            UIPopoverView* pv = [UIPopoverView popoverContent:[VPracticePopover temporary]];
            [pv popoverForView:btn.buttonItem];
        }];
        return btn;
    });
    
    // 测试触摸
    [view.btnTouches.signals connect:kSignalTouchesDown withBlock:^(SSlot *s) {
        LOG("Button Touch Down");
    }];
    [view.btnTouches.signals connect:kSignalTouchesUpInside withBlock:^(SSlot *s) {
        LOG("Button Touch Up Inside");
    }];
    [view.btnTouches.signals connect:kSignalTouchesUpOutside withBlock:^(SSlot *s) {
        LOG("Button Touch Up Outside");
    }];
    [view.btnTouches.signals connect:kSignalTouchesCancel withBlock:^(SSlot *s) {
        LOG("Button Touch Cancel");
    }];
    [view.btnTouches.signals connect:kSignalClicked withBlock:^(SSlot *s) {
        LOG("Button Clicked");
    }];
    
    [view.btnHudPrg.signals connect:kSignalClicked withBlock:^(SSlot *s) {
        [UIHud ShowProgress];
        DISPATCH_DELAY(1, {
            [[[UIHud Current] addAction:@"ACTION动作"].signals connect:kSignalClicked withBlock:^(SSlot *s) {
                [UIHud Text:@"ACTION"];
            }];
        });
        DISPATCH_DELAY(5, {
            [UIHud HideProgress];
        });
        
        /*
        for (int i = 0; i < 5; ++i) {
            [UIHud ShowProgress];
            [UIHud HideProgress];
        }
         */
    }];
    [view.btnHudTxt.signals connect:kSignalClicked withBlock:^(SSlot *s) {
        [UIHud Noti:@"消息内容"];
    }];
    [view.btnHudLongText.signals connect:kSignalClicked withSelector:@selector(actHudLongText) ofTarget:self];
}

- (void)onAppeared {
    [super onAppeared];
    UIButtonExt* btn = [UIButtonExt temporary];
    btn.backgroundColor = [UIColor orangeColor];
    btn.text = @"DROP BUTTON";
    btn.height = 50;
    
    [self.navigationController showBanner:btn];
    [btn.layer addAnimation:[CAKeyframeAnimation SlideFromTop:btn]];

    [btn.signals connect:kSignalClicked withBlock:^(SSlot *s) {
        [btn.layer addAnimation:[CAKeyframeAnimation SlideToTop:btn]
                     completion:^{
                         [self.navigationController hideBanner:(id)s.sender];
                     }];
    }];
}

- (void)actHudLongText {
    static int hlt_count = 0;
    if (hlt_count++ %2 == 0) {
        [UIHud Text:[@"消息内容" stringBySelfAppendingCount:100]];
    } else {
        [UIHud Text:[@"消息内容" stringBySelfAppendingCount:200]];
    }
}

- (void)actCrash {
    [self performSyncSelector:@selector(getUrl) withObject:nil];
}

- (void)actDT {
    UIDatePicker* dp = [UIDatePicker temporary];
    dp.backgroundColor = [UIColor whiteColor];
    //UIToolbarPanel* pn = [UIToolbarPanel panelWithView:dp];
    UIPopoverDesktop* desk = [UIPopoverDesktop desktopWithView:dp];
    [desk open];
    
    [dp.signals connect:kSignalValueChanged withBlock:^(SSlot *s) {
        LOG(dp.date.description.UTF8String);
    }];
}

- (void)actPaste {
    static int paste_cnt = 0;
    UIPasteboardExt* pb = [UIPasteboardExt Open:@"hdapp.test"];
    if (paste_cnt++ % 2 == 0)
    {
        pb.object = [[NSString stringWithFormat:@"HELLO, HDAPP, [%d]", paste_cnt] dataUsingEncoding:NSASCIIStringEncoding];
    }
    else
    {
        NSData* da = pb.object;
        NSString* str = [NSString stringWithData:da encoding:NSASCIIStringEncoding];
        [UIHud Text:str];
    }
}

- (void)actPopover:(SSlot*)s {
    UIPopoverView* pv = [UIPopoverView popoverContent:[VPracticePopover temporary]];
    [pv popoverForView:(UIView*)s.sender];
}

- (void)actPopoverDesk:(SSlot*)s {
    int tag = [self.attachment.strong getInt:@"popover"];
    UIPopoverDesktop* pd = [UIPopoverDesktop desktopWithContent:[VCPracticeToolbox temporary]];
    pd.highlightViews = @[s.sender];
    
    // 为了测试弹出的对话框需要避让键盘
    //tag = 4;
    
    switch (tag)
    {
        case 0: pd.direction = kCGDirectionFromBottom; break;
        case 1: pd.direction = kCGDirectionFromTop; break;
        case 2: pd.direction = kCGDirectionFromLeft; break;
        case 3: pd.direction = kCGDirectionFromRight; break;
        case 4: pd.direction = kCGDirectionCenter; break;
    }
    [pd open];
    
    [self.attachment.strong setInt:(++tag % 5) forKey:@"popover"];
}

- (void)actInputChange:(SSlot*)s {
    VPracticeWidgets* view = (id)self.view;
    view.inpPinyin.text = [[NSPinyin StringToPinyin:s.data.object] componentsJoinedByString:@""];
}

- (void)actSketch {
    [self.navigationController pushViewController:[VCPracticeSketch temporary]];
}

- (void)actPresent {
    VCPracticePresent* ctlr = [VCPracticePresent temporary];
    UINavigationController* navi = [UINavigationController navigationWithController:ctlr];
    [[UIAppDelegate shared] presentModalViewController:navi];
}

static int statusbarcounter = 0;
- (void)actStatusBar {
    switch (statusbarcounter++)
    {
        case 0: [[UIAppDelegate shared].statusBar pushHidden:YES animated:YES]; break;
        case 1: [[UIAppDelegate shared].statusBar pushHidden:YES animated:YES]; break;
        case 2: [[UIAppDelegate shared].statusBar popHiddenWithAnimated:YES]; break;
        case 3: [[UIAppDelegate shared].statusBar popHiddenWithAnimated:YES]; break;
        default: statusbarcounter = 0; break;
    }
}

- (void)actPercentage {
    VCPracticePercentage* ctlr = [VCPracticePercentage temporary];
    [self.navigationController pushViewController:ctlr];
}

@end
