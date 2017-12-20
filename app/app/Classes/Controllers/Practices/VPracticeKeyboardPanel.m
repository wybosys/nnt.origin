
# import "app.h"
# import "VPracticeKeyboardPanel.h"

@implementation VPracticeGrowBar

- (void)onInit {
    [super onInit];
    
    [self addSubview:BLOCK_RETURN({
        _inpText = [UITextViewExt temporary];
        _inpText.placeholder = @"输入文字";
        _inpText.backgroundColor = [UIColor grayWithValue:.9];
        _inpText.keyboardDodge = NO;
        return _inpText;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _toolbar = [UIToolbar temporary];
        return _toolbar;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox* box = [UIVBox boxWithRect:rect];
    
    CGFloat v = _inpText.bestHeightForWidth;
    v = MAX(v, 30);
    v = MIN(v, 60);
    [box addPixel:v toView:_inpText];
    
    [box addPixel:_toolbar.bestHeightForWidth toView:_toolbar];
    [box apply];
}

- (CGSize)bestSize:(CGSize)sz {
    CGFloat h = 0;
    CGFloat v = _inpText.bestHeightForWidth;
    v = MAX(v, 30);
    v = MIN(v, 60);
    h += v;
    h += _toolbar.bestHeightForWidth;
    return CGSizeMake(0, h);
}

@end

@implementation VPracticeKeyboardPanel

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor grayColor];
    
    VPracticeGrowBar* bar = [VPracticeGrowBar temporary];
    UIToolbar* tb = bar.toolbar;
    [bar.inpText.signals connect:kSignalConstraintChanged ofTarget:self];
    self.responder = bar.inpText;
    self.toolbarView = bar;
    
    [tb setItems:@[
                   BLOCK_RETURN({
        UIBarButtonItem* btn = [UIBarButtonItem itemWithTitle:@"R"];
        [btn.signals connect:kSignalClicked withBlock:^(SSlot *s) {
            UIView* v = [self reusableObject:@"R" instance:^id{
                return [UIView temporary];
            }];
            v.size = CGSizeMake(0, 100);
            v.backgroundColor = [UIColor redColor];
            self.contentView = v;
        }];
        return btn;
    }),
                   
                   BLOCK_RETURN({
        UIBarButtonItem* btn = [UIBarButtonItem itemWithTitle:@"G"];
        [btn.signals connect:kSignalClicked withBlock:^(SSlot *s) {
            UIView* v = [self reusableObject:@"G" instance:^id{
                return [UIView temporary];
            }];
            v.size = CGSizeMake(0, 50);
            v.backgroundColor = [UIColor greenColor];
            self.contentView = v;
        }];
        return btn;
    }),
                   
                   BLOCK_RETURN({
        UIBarButtonItem* btn = [UIBarButtonItem itemWithTitle:@"B"];
        [btn.signals connect:kSignalClicked withBlock:^(SSlot *s) {
            UIView* v = [self reusableObject:@"B" instance:^id{
                return [UIView temporary];
            }];
            v.size = CGSizeMake(0, 150);
            v.backgroundColor = [UIColor blueColor];
            self.contentView = v;
        }];
        return btn;
    }),

                   BLOCK_RETURN({
        UIBarButtonItem* btn = [UIBarButtonItem itemWithTitle:@"KBD"];
        [btn.signals connect:kSignalClicked withBlock:^(SSlot *s) {
            self.responder.focus = YES;
        }];
        return btn;
    }),
                   
                   BLOCK_RETURN({
        UIBarButtonItem* btn = [UIBarButtonItem itemWithTitle:@"HIDE"];
        [btn.signals connect:kSignalClicked withBlock:^(SSlot *s) {
            self.responder.focus = NO;
        }];
        return btn;
    })

                   ]];
}

@end
