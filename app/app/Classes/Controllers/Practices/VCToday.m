
# import "Compiler.h"
# import "Objc+Extension.h"
# import "UITypes+Minimalism.h"
# import "VCToday.h"
# import <NotificationCenter/NotificationCenter.h>

@interface VToday : UIViewExt

@property (nonatomic, readonly) UIButton *lblHw;

@end

@implementation VToday

- (void)onInit {
    [super onInit];

    [self addSubview:BLOCK_RETURN({
        _lblHw = [UIButton temporary];
        _lblHw.text = @"HELLO, WORLD!";
        _lblHw.textColor = [UIColor whiteColor];
        _lblHw.backgroundColor = [UIColor clearColor];
        return _lblHw;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    _lblHw.frame = rect;
}

@end

@interface VCToday () <NCWidgetProviding>

@end

@implementation VCToday

- (void)onInit {
    [super onInit];
    self.preferredContentSize = CGSizeMake(320, 100);
    self.classForView = [VToday class];
}

- (void)onLoaded {
    [super onLoaded];

    VToday* v = (id)self.view;
    [v.lblHw addTarget:self action:@selector(actGoto) forControlEvents:UIControlEventTouchUpInside];
}

- (void)actGoto {
    [self.extensionContext openURL:[NSURL URLWithString:@"strong.hdapp://today.hdapp"]
                 completionHandler:^(BOOL success) {
                     PASS;
                 }];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    completionHandler(NCUpdateResultNewData);
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsMake(0, 5, 0, 5);
}

@end
