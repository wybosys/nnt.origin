
# import "Compiler.h"
# import "Objc+Extension.h"
# import "UITypes+Minimalism.h"

# define IMPL_INIT \
- (id)init { \
self = [super init]; \
[self onInit]; \
return self; \
}

# define IMPL_VIEW_INIT \
- (id)initWithFrame:(CGRect)frame { \
self = [super initWithFrame:frame]; \
[self onInit]; \
return self; \
}

# define IMPL_FIN \
- (void)dealloc { \
[self onFin]; \
SUPER_DEALLOC; \
}

# define IMPL_VIEW_LAYOUT \
- (void)layoutSubviews { \
[super layoutSubviews]; \
CGRect rc = self.bounds; \
[self onLayout:rc]; \
}

@implementation NSObject (minimalism)

- (void)onInit {
    PASS;
}

- (void)onFin {
    PASS;
}

+ (id)temporary {
    id ret = [[self.class alloc] init];
    SAFE_AUTORELEASE(ret);
    return ret;
}

@end

@implementation UIView (minimalism)

- (void)onLayout:(CGRect)rect {
    PASS;
}

@end

@implementation UIViewExt

IMPL_VIEW_INIT;
IMPL_FIN;
IMPL_VIEW_LAYOUT;

@end

@implementation UIViewControllerExt

IMPL_INIT;
IMPL_FIN;

- (void)onInit {
    [super onInit];
    self.classForView = [UIViewExt class];
}

- (void)loadView {
    UIView* v = [self.classForView temporary];
    self.view = v;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self onLoaded];
}

- (void)onLoaded {
    PASS;
}

@end

@implementation UILabel (minimalism)

@dynamic textFont;

- (void)setTextFont:(UIFont *)textFont {
    self.font = textFont;
}

- (UIFont*)textFont {
    return self.font;
}

@end

@implementation UIButton (minimalism)

@dynamic textColor, textFont, textAlignment, text;

- (void)setTextColor:(UIColor *)textColor {
    [self setTitleColor:textColor forState:UIControlStateNormal];
}

- (UIColor*)textColor {
    return [self titleColorForState:UIControlStateNormal];
}

- (void)setTextFont:(UIFont *)textFont {
    self.titleLabel.textFont = textFont;
}

- (UIFont*)textFont {
    return self.titleLabel.textFont;
}

- (void)setText:(NSString *)text {
    [self setTitle:text forState:UIControlStateNormal];
}

- (NSString*)text {
    return [self titleForState:UIControlStateNormal];
}

@end
