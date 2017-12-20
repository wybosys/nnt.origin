
# import "app.h"
# import "VPracticeTableItem.h"
# import "VCPracticeTableExpand.h"

@interface VPracticeDeletable ()

@property (nonatomic, readonly) UIButtonExt *btnReaded, *btnDel;

@end

@implementation VPracticeDeletable

- (void)onInit {
    [super onInit];
    
    self.viewLeft = BLOCK_RETURN({
        _btnReaded = [UIButtonExt temporary];
        _btnReaded.motifColor = [UIColor greenColor];
        _btnReaded.text = @"READED";
        [_btnReaded.signals connect:kSignalClicked withBlock:^(SSlot *s) {
            [UIHud Text:@"READED"];
        }];
        return _btnReaded;
    });

    self.viewRight = BLOCK_RETURN({
        _btnDel = [UIButtonExt temporary];
        _btnDel.motifColor = [UIColor redColor];
        _btnDel.text = @"DELETE";
        _btnDel.width = 120;
        [_btnDel.signals connect:kSignalClicked withBlock:^(SSlot *s) {
            [UIHud Text:@"DELETE"];
        }];
        return _btnDel;
    });
    
    [self.signals connect:kSignalGestureActivatedLeft withBlock:^(SSlot *s) {
        [UIHud Text:@"READED"];
    }];
}

@end

@interface VPracticeTableItem ()

@property (nonatomic, readonly) UILabelExt *lbl0;
@property (nonatomic, retain) UIColor *color0, *color1;
@property (nonatomic, retain) UIFont *font0, *font1;

@end

@implementation VPracticeTableItem

- (void)onInit {
    [super onInit];
    
    _lbl0 = [[UILabelExt alloc] init];
    [self addSub:_lbl0];
    SAFE_RELEASE(_lbl0);
    
    _lbl0.textColor = [UIColor randomColor];
    _lbl0.textFont = [UIFont systemFontOfSize:22];
    _lbl0.multilines = YES;
    
    self.font0 = [UIFont systemFontOfSize:40];
    self.font1 = [UIFont systemFontOfSize:30];
    
    [self.signals connect:kSignalClicked withSelector:@selector(actClicked) ofTarget:self];
}

- (void)onFin {
    ZERO_RELEASE(_text);
    ZERO_RELEASE(_color0);
    ZERO_RELEASE(_color1);
    ZERO_RELEASE(_font0);
    ZERO_RELEASE(_font1);
    [super onFin];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    _lbl0.frame = rect;
}

- (void)updateData {
    [super updateData];
    
    self.color0 = [UIColor randomColor];
    self.color1 = [UIColor randomColor];
    self.backgroundColor = [UIColor randomColor];
    
    NSStylizedString* str = [NSStylizedString temporary];
    [str append:[NSStylization styleWithTextColor:[UIColor blackColor] textFont:nil] format:_index];
    [str append:[NSStylization styleWithTextColor:_color0 textFont:_font0] format:@"随机："];
    [str append:[NSStylization styleWithTextColor:_color1 textFont:_font1] format:self.text];
    _lbl0.stylizedString = str;
}

- (CGSize)constraintBounds {
    CGFloat h = 0;
    h += _lbl0.bestHeightForWidth;
    return CGSizeMake(0, h);
}

- (void)actClicked {
    [self.navigationController pushViewController:[VCPracticeTableExpand temporary]];
}

@end