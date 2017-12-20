
# import "Common.h"
# import "UITypes+Extension.h"
# import "AppDelegate+Extension.h"
# import "UIDripRefresh.h"
# import "UIImageView+WebCache.h"
# import "PECropView.h"
# import <Accelerate/Accelerate.h>
# import <CoreText/CoreText.h>
# import "CoreFoundation+Extension.h"
# import "NSCron.h"
# import "FileSystem+Extension.h"
# import "NSMemCache.h"
# import <MapKit/MapKit.h>
# import "UITypes+Swizzle.h"
# import <StoreKit/StoreKit.h>
# import "NSStorage.h"
# import <GPUImage/GPUImageView.h>
# import <GPUImage/GPUImagePicture.h>
# import <GPUImage/GPUImageiOSBlurFilter.h>
# import "UIPercentageWidgets.h"
# import "NSSystemFeatures.h"
# import "NSMemCache.h"

static BOOL NavigationControllerCanOverrideSetting(id obj) {
    NSString* nc = NSStringFromClass([obj class]);
    if ([nc hasPrefix:@"UMS"]) // 银联支付
        return NO;
    if ([nc hasPrefix:@"PLUI"]) // 照相机
        return NO;
    return YES;
}

NSString* kUIImageHighlightSuffix = @"_highlight";

UIEdgeInsets UIEdgeInsetsFromPadding(CGPadding pd) {
    return UIEdgeInsetsMake(pd.top, pd.left, pd.bottom, pd.right);
}

CGPadding CGPaddingFromEdgeInsets(UIEdgeInsets ei) {
    return CGPaddingMake(ei.top, ei.bottom, ei.left, ei.right);
}

CGFloat UIEdgeInsetsWidth(UIEdgeInsets ei) {
    return ei.left + ei.right;
}

CGFloat UIEdgeInsetsHeight(UIEdgeInsets ei) {
    return ei.top + ei.bottom;
}

@implementation NSPadding (UI)

+ (instancetype)paddingWithEdgeInsets:(UIEdgeInsets)ei {
    return [self padding:CGPaddingFromEdgeInsets(ei)];
}

- (UIEdgeInsets)edgeInsets {
    return UIEdgeInsetsFromPadding(self.padding);
}

@end

@implementation UITextStyle

- (id)initWithColor:(UIColor *)color font:(UIFont *)font {
    self = [super init];
    self.textColor = color;
    self.textFont = font;
    return self;
}

+ (instancetype)styleWithColor:(UIColor *)color font:(UIFont *)font {
    return [[[self alloc] initWithColor:color font:font] autorelease];
}

+ (instancetype)styleWithColor:(UIColor*)color backgroundColor:(UIColor*)bkgColor {
    return [[[self alloc] initWithColor:color backgroundColor:bkgColor] autorelease];
}

- (id)initWithColor:(UIColor*)color backgroundColor:(UIColor*)bkgColor {
    self = [super init];
    self.textColor = color;
    self.backgroundColor = bkgColor;
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_textColor);
    ZERO_RELEASE(_backgroundColor);
    ZERO_RELEASE(_textFont);
    [super dealloc];
}

- (void)setIn:(UIView *)view {
    if (self.textFont)
        OBJC_NOEXCEPTION([view performSelector:@selector(setTextFont:) withObject:self.textFont]);
    if (self.textColor)
        OBJC_NOEXCEPTION([view performSelector:@selector(setTextColor:) withObject:self.textColor]);
    if (self.backgroundColor)
        view.backgroundColor = self.backgroundColor;
}

@end

@implementation UIFill

- (void)dealloc {
    ZERO_RELEASE(_image);
    ZERO_RELEASE(_patternImage);
    ZERO_RELEASE(_color);
    [super dealloc];
}

@end

@implementation UIString

+ (instancetype)Any:(id)any {
    if ([any isKindOfClass:NSString.class])
        return [self.class string:any];
    else if ([any isKindOfClass:UIColor.class])
        return [self.class stringWithColor:any];
    else if ([any isKindOfClass:UIFont.class])
        return [self.class stringWithFont:any];
    else if ([any isKindOfClass:NSStylizedString.class])
        return [self.class stylizedString:any];
    else if ([any isKindOfClass:UIImage.class])
        return [self.class image:any];
    else if ([any isKindOfClass:self.class])
        return any;
    return nil;
}

+ (instancetype)stringWithColor:(UIColor *)color {
    return [[(UIString*)[self alloc] initWithColor:color] autorelease];
}

- (id)initWithColor:(UIColor *)color {
    self = [super init];
    self.textColor = color;
    return self;
}

+ (instancetype)stringWithFont:(UIFont *)font {
    return [[[self alloc] initWithFont:font] autorelease];
}

- (id)initWithFont:(UIFont *)font {
    self = [super init];
    self.textFont = font;
    return self;
}

+ (instancetype)stringWithColor:(UIColor *)color font:(UIFont *)font text:(NSString*)text {
    return [[[self alloc] initWithColor:color font:font text:text] autorelease];
}

- (id)initWithColor:(UIColor *)color font:(UIFont *)font text:(NSString*)text {
    self = [super initWithColor:color font:font];
    self.text = text;
    return self;
}

+ (instancetype)stringWithColor:(UIColor *)color text:(NSString*)text {
    return [[[self alloc] initWithColor:color text:text] autorelease];
}

- (id)initWithColor:(UIColor *)color text:(NSString*)text {
    return [self initWithColor:color font:nil text:text];
}

+ (instancetype)stringWithFont:(UIFont *)font text:(NSString*)text {
    return [[[self alloc] initWithFont:font text:text] autorelease];
}

- (id)initWithFont:(UIFont *)font text:(NSString*)text {
    return [self initWithColor:nil font:font text:text];
}

+ (instancetype)string:(NSString*)string {
    return [[[self alloc] initWithString:string] autorelease];
}

- (id)initWithString:(NSString*)string {
    self = [super init];
    self.text = string;
    return self;
}

+ (instancetype)stylizedString:(NSStylizedString*)string {
    return [[[self alloc] initWithStylizedString:string] autorelease];
}

- (id)initWithStylizedString:(NSStylizedString*)string {
    self = [super init];
    self.stylizedString = string;
    return self;
}

+ (instancetype)image:(UIImage *)image {
    return [[[self alloc] initWithImage:image] autorelease];
}

- (id)initWithImage:(UIImage *)image {
    self = [super init];
    self.image = image;
    return self;
}

+ (instancetype)backgroundImage:(UIImage*)image {
    return [[[self alloc] initWithBackgroundImage:image] autorelease];
}

- (id)initWithBackgroundImage:(UIImage*)image {
    self = [super init];
    self.backgroundImage = image;
    return self;
}

+ (instancetype)imagePushed:(NSString*)image {
    return [[[self alloc] initWithImagePushed:image] autorelease];
}

- (id)initWithImagePushed:(NSString*)image {
    self = [super init];
    self.imagePushed = image;
    return self;
}

+ (instancetype)imageDataSource:(id)ds {
    return [[[self alloc] initWithImageDataSource:ds] autorelease];
}

- (id)initWithImageDataSource:(id)ds {
    self = [super init];
    self.image = [UIImage imageWithContentOfDataSource:ds];
    return self;
}

+ (instancetype)backgroundImageDataSource:(id)ds {
    return [[[self alloc] initWithBackgroundImageDataSource:ds] autorelease];
}

- (id)initWithBackgroundImageDataSource:(id)ds {
    self = [super init];
    self.backgroundImage = [UIImage imageWithContentOfDataSource:ds];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_text);
    ZERO_RELEASE(_image);
    ZERO_RELEASE(_imagePushed);
    ZERO_RELEASE(_stylizedString);
    ZERO_RELEASE(_backgroundImage);
    [super dealloc];
}

- (void)setIn:(UIView *)view {
    [super setIn:view];
    if (self.text)
        OBJC_NOEXCEPTION([view performSelector:@selector(setText:) withObject:[self.text stringValue]]);
    if (self.stylizedString) {
        self.stylizedString.lastStyle = nil;
        OBJC_NOEXCEPTION([view performSelector:@selector(setStylizedString:) withObject:self.stylizedString]);
    }
    if (self.image)
        OBJC_NOEXCEPTION([view performSelector:@selector(setImage:) withObject:self.image]);
    if (self.backgroundImage)
        OBJC_NOEXCEPTION([view performSelector:@selector(setBackgroundImage:) withObject:self.backgroundImage]);
    if (self.imagePushed) {
        OBJC_NOEXCEPTION([view performSelector:@selector(setPushImageNamed:) withObject:self.imagePushed]);
    }
}

@end

@interface UIImageFlymakeCache : NSFlymakeCache @end

@implementation UIImageFlymakeCache

SHARED_IMPL;

- (void)onInit {
    [super onInit];
    self.threshold = 60;
}

@end

@implementation UIColor (extension)

- (CGFloat)componentRed {
    ASSERTMSG(self.isRGBColor, @"需要保证是 RGB 颜色");
    CGFloat const* cmps = CGColorGetComponents(self.CGColor);
    return cmps[0];
}

- (CGFloat)componentGreen {
    ASSERTMSG(self.isRGBColor, @"需要保证是 RGB 颜色");
    CGFloat const* cmps = CGColorGetComponents(self.CGColor);
    return cmps[1];
}

- (CGFloat)componentBlue {
    ASSERTMSG(self.isRGBColor, @"需要保证是 RGB 颜色");
    CGFloat const* cmps = CGColorGetComponents(self.CGColor);
    return cmps[2];
}

- (CGFloat)componentAlpha {
    ASSERTMSG(self.isRGBColor, @"需要保证是 RGB 颜色");
    CGFloat const* cmps = CGColorGetComponents(self.CGColor);
    return cmps[3];
}

+ (UIColor*)colorWithRGB:(int)rgb {
    return [UIColor colorWithRed:RGB2FLOAT(RGB_RED(rgb)) green:RGB2FLOAT(RGB_GREEN(rgb)) blue:RGB2FLOAT(RGB_BLUE(rgb)) alpha:1];
}

+ (UIColor*)colorWithRGBA:(int)rgba {
    return [UIColor colorWithRed:RGB2FLOAT(RGBA_RED(rgba)) green:RGB2FLOAT(RGBA_GREEN(rgba)) blue:RGB2FLOAT(RGBA_BLUE(rgba)) alpha:RGB2FLOAT(RGBA_ALPHA(rgba))];
}

+ (UIColor*)colorWithARGB:(int)argb {
    return [UIColor colorWithRed:RGB2FLOAT(ARGB_RED(argb)) green:RGB2FLOAT(ARGB_GREEN(argb)) blue:RGB2FLOAT(ARGB_BLUE(argb)) alpha:RGB2FLOAT(ARGB_ALPHA(argb))];
}

+ (UIColor*)grayWithValue:(CGFloat)val {
    return [UIColor colorWithRed:val green:val blue:val alpha:1];
}

+ (UIColor*)blackWithAlpha:(CGFloat)val {
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:val];
}

+ (UIColor*)whiteWithAlpha:(CGFloat)val {
    return [UIColor colorWithRed:1 green:1 blue:1 alpha:val];
}

- (UIColor*)multiplyWithRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b {
    return [self multiplyWithRed:r green:g blue:b alpha:1];
}

- (UIColor*)multiplyWithRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b alpha:(CGFloat)a {
    ASSERTMSG(self.isRGBColor, @"需要保证是 RGB 颜色");
    CGFloat colors[4];
    memcpy(colors, CGColorGetComponents(self.CGColor), sizeof(colors));
    colors[0] *= r;
    colors[1] *= g;
    colors[2] *= b;
    colors[3] *= a;
    return [UIColor colorWithRed:colors[0] green:colors[1] blue:colors[2] alpha:colors[3]];
}

- (UIColor*)multiplyWithValue:(CGFloat)val {
    return [self multiplyWithRed:val green:val blue:val];
}

- (UIColor*)addWithRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b {
    return [self addWithRed:r green:g blue:b alpha:0];
}

- (UIColor*)addWithRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b alpha:(CGFloat)a {
    ASSERTMSG(self.isRGBColor, @"需要保证是 RGB 颜色");
    CGFloat colors[4];
    memcpy(colors, CGColorGetComponents(self.CGColor), sizeof(colors));
    colors[0] += r;
    colors[1] += g;
    colors[2] += b;
    colors[3] += a;
    for (int i = 0; i < 4; ++i) {
        if (colors[i] > 1)
            colors[i] = 1;
    }
    return [UIColor colorWithRed:colors[0] green:colors[1] blue:colors[2] alpha:colors[3]];
}

- (UIColor*)addWithValue:(CGFloat)val {
    return [self addWithRed:val green:val blue:val];
}

- (UIColor*)bleachWithValue:(CGFloat)val {
    ASSERTMSG(self.isRGBColor, @"需要保证是 RGB 颜色");
    CGFloat colors[4];
    memcpy(colors, CGColorGetComponents(self.CGColor), sizeof(colors));
    colors[0] += (1 - colors[0]) * val;
    colors[1] += (1 - colors[1]) * val;
    colors[2] += (1 - colors[2]) * val;
    for (int i = 0; i < 4; ++i) {
        if (colors[i] > 1)
            colors[i] = 1;
    }
    return [UIColor colorWithRed:colors[0] green:colors[1] blue:colors[2] alpha:colors[3]];
}

+ (UIColor*)colorWithRedi:(Byte)red green:(Byte)green blue:(Byte)blue alpha:(Byte)alpha {
    return [UIColor colorWithRed:RGB2FLOAT(red) green:RGB2FLOAT(green) blue:RGB2FLOAT(blue) alpha:RGB2FLOAT(alpha)];
}

+ (UIColor*)colorWithRedi:(Byte)red green:(Byte)green blue:(Byte)blue alphaf:(CGFloat)alpha {
    return [UIColor colorWithRed:RGB2FLOAT(red) green:RGB2FLOAT(green) blue:RGB2FLOAT(blue) alpha:alpha];
}

+ (UIColor*)colorWithRedi:(Byte)red green:(Byte)green blue:(Byte)blue {
    return [self colorWithRedi:red green:green blue:blue alpha:255];
}

+ (UIColor*)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

+ (UIColor*)colorWithWhitei:(Byte)white alpha:(CGFloat)alpha {
    return [self colorWithRedi:white green:white blue:white alpha:alpha];
}

+ (UIColor*)colorWithWhitei:(Byte)white {
    return [self colorWithWhitei:white alpha:255];
}

- (UIColor*)blurColor {
    CGFloat colors[4];
    memcpy(colors, CGColorGetComponents(self.CGColor), sizeof(colors));
    for (int i = 0; i < 3; ++i) {
        if (colors[i] <= 0.4) {
            //WARN("设置的颜色小于转化到 blur 颜色的最小值");
            colors[i] = 0.4;
        }
        colors[i] = (colors[i] - 0.4) / 0.6;
    }
    return [UIColor colorWithRed:colors[0] green:colors[1] blue:colors[2] alpha:colors[3]];
}

- (UIColor*)nonblurColor {
    CGFloat colors[4];
    memcpy(colors, CGColorGetComponents(self.CGColor), sizeof(colors));
    for (int i = 0; i < 3; ++i) {
        colors[i] = (1 - colors[i]) / 2.5 + colors[i];
    }
    return [UIColor colorWithRed:colors[0] green:colors[1] blue:colors[2] alpha:colors[3]];
}

+ (UIColor*)randomColor {
    CGFloat r = [NSRandom valueBoundary:0 To:1];
    CGFloat g = [NSRandom valueBoundary:0 To:1];
    CGFloat b = [NSRandom valueBoundary:0 To:1];
    return [UIColor colorWithRed:r green:g blue:b];
}

- (UIColor*)rgbColor {
    CGColorSpaceRef cs = CGColorGetColorSpace(self.CGColor);
    CGColorSpaceModel csm = CGColorSpaceGetModel(cs);
    if (csm == kCGColorSpaceModelRGB)
        return self;
    
    if (csm == kCGColorSpaceModelMonochrome) {
        CGFloat colors[2];
        memcpy(colors, CGColorGetComponents(self.CGColor), sizeof(colors));
        return [UIColor colorWithRed:colors[0] green:colors[0] blue:colors[0] alpha:colors[1]];
    }
    
    WARN("没有根据此种颜色类型转换成标准RGB颜色");
    return self;
}

- (BOOL)isRGBColor {
    CGColorSpaceRef cs = CGColorGetColorSpace(self.CGColor);
    CGColorSpaceModel csm = CGColorSpaceGetModel(cs);
    return csm == kCGColorSpaceModelRGB;
}

- (BOOL)isColorizedGlossy {
    // 如果是透明、白色、灰色，则设置成 nil，以达到正确的毛玻璃效果
    if (self == [UIColor clearColor])
        return YES;

    CGColorSpaceRef cs = CGColorGetColorSpace(self.CGColor);
    CGColorSpaceModel csm = CGColorSpaceGetModel(cs);
    if (csm == kCGColorSpaceModelMonochrome)
        return YES;
    
    CGFloat colors[4];
    memcpy(colors, CGColorGetComponents(self.CGColor), sizeof(colors));
    if (colors[0] == colors[1] &&
        colors[1] == colors[2] &&
        colors[2] == colors[3])
        return YES;
    
    return NO;
}

- (NSUInteger)rgb {
    CGFloat colors[4];
    memcpy(colors, CGColorGetComponents(self.rgbColor.CGColor), sizeof(colors));
    char r = FLOAT2RGB(colors[0]);
    char g = FLOAT2RGB(colors[1]);
    char b = FLOAT2RGB(colors[2]);
    return RGB_VALUE(r, g, b);
}

- (NSUInteger)rgba {
    CGFloat colors[4];
    memcpy(colors, CGColorGetComponents(self.rgbColor.CGColor), sizeof(colors));
    char r = FLOAT2RGB(colors[0]);
    char g = FLOAT2RGB(colors[1]);
    char b = FLOAT2RGB(colors[2]);
    char a = FLOAT2RGB(colors[3]);
    return RGBA_VALUE(r, g, b, a);
}

- (NSUInteger)argb {
    CGFloat colors[4];
    memcpy(colors, CGColorGetComponents(self.rgbColor.CGColor), sizeof(colors));
    char r = FLOAT2RGB(colors[0]);
    char g = FLOAT2RGB(colors[1]);
    char b = FLOAT2RGB(colors[2]);
    char a = FLOAT2RGB(colors[3]);
    return ARGB_VALUE(a, r, g, b);
}

@end

BOOL kUITouched = NO;
BOOL kUIDragging = NO;

@implementation UIResponder (extension)

SIGNALS_BEGIN

SIGNAL_ADD(kSignalFocused)
SIGNAL_ADD(kSignalFocusedLost)

SIGNAL_ADD(kSignalMotionBegan)
SIGNAL_ADD(kSignalMotionEnded)
SIGNAL_ADD(kSignalMotionCancelled)

SIGNAL_ADD(kSignalDeviceShaking)
SIGNAL_ADD(kSignalDeviceShaked)

SIGNALS_END

- (void)SWIZZLE_CALLBACK(touches_begin):(NSSet*)touches withEvent:(UIEvent*)event {
    kUITouched = YES;
}

- (void)SWIZZLE_CALLBACK(touches_end):(NSSet*)touches withEvent:(UIEvent*)event {
    kUITouched = NO;
}

- (void)SWIZZLE_CALLBACK(touches_cancel):(NSSet*)touches withEvent:(UIEvent*)event {
    kUITouched = NO;
}

- (void)SWIZZLE_CALLBACK(touches_moved):(NSSet*)touches withEvent:(UIEvent*)event {
    PASS;
}

- (void)SWIZZLE_CALLBACK(motion_begin):(UIEventSubtype)st withEvent:(UIEvent*)event {
    [self.touchSignals emit:kSignalMotionBegan withResult:@(st)];
    if (st == UIEventSubtypeMotionShake) {
        [self.touchSignals emit:kSignalDeviceShaking];
        [[UIDevice currentDevice].touchSignals emit:kSignalDeviceShaking];
    }
}

- (void)SWIZZLE_CALLBACK(motion_end):(UIEventSubtype)st withEvent:(UIEvent*)event {
    [self.touchSignals emit:kSignalMotionEnded withResult:@(st)];
    if (st == UIEventSubtypeMotionShake) {
        if (kIOS7Above)
            [self.touchSignals emit:kSignalDeviceShaked]; // iOS6一下 不支持 VC 级别的shake
        [[UIDevice currentDevice].touchSignals emit:kSignalDeviceShaked];
    }
}

- (void)SWIZZLE_CALLBACK(motion_cancel):(UIEventSubtype)st withEvent:(UIEvent*)event {
    [self.touchSignals emit:kSignalMotionCancelled withResult:@(st)];
}

- (void)setFocus:(BOOL)focus {
    if (focus)
        [self becomeFirstResponder];
    else
        [self resignFirstResponder];
}

- (void)SWIZZLE_CALLBACK(focuse_got) {
    [self.touchSignals emit:kSignalFocused];
}

- (void)SWIZZLE_CALLBACK(focuse_lost) {
    [self.touchSignals emit:kSignalFocusedLost];
}

- (BOOL)focus {
    return [self isFirstResponder];
}

- (void)lostFocus {
    if (self.focus)
        self.focus = NO;
}

- (void)setFocus {
    if (!self.focus)
        self.focus = YES;
}

@end

@interface UISelectionGroup ()

@property (nonatomic, readonly) NSMutableArray *widgets;

@end

@implementation UISelectionGroup

- (void)onInit {
    [super onInit];
    _widgets = [[NSMutableArray alloc] init];
}

- (void)onFin {
    ZERO_RELEASE(_widgets);
    [super onFin];
}

SIGNALS_BEGIN

SIGNAL_ADD(kSignalSelectionChanging)
SIGNAL_ADD(kSignalSelectionChanged)
SIGNAL_ADD(kSignalSelectionReactive)
SIGNAL_ADD(kSignalSelectionUpdated)

[self.signals connect:kSignalSelectionChanged redirectTo:kSignalSelectionUpdated ofTarget:self].priority = kSSlotPriorityLow;
[self.signals connect:kSignalSelectionReactive redirectTo:kSignalSelectionUpdated ofTarget:self].priority = kSSlotPriorityLow;

SIGNALS_END

- (void)updateData {
    [super updateData];

    if (_currentSelection == nil && _widgets.count) {
        // 查找 widgets 中第一个 select 的，作为当前选中
        UIView<UISelection>* seled = [_widgets objectWithQuery:^id(UIView<UISelection>* l) {
            return TRIEXPRESS(l.isSelection, l, nil);
        }];
        NSInteger idx = TRIEXPRESS(seled, [_widgets indexOfObject:seled], 0);
        
        // 默认选中第一个
        self.selectionIndex = idx;
    }
}

- (void)addObject:(UIView<UISelection>*)obj {
    [_widgets addObject:obj];
    [obj.signals connect:kSignalClicked withSelector:@selector(__act_clicked:) ofTarget:self];
}

- (void)addObjects:(UIView<UISelection>*)obj, ... {
    [self addObject:obj];

    va_list va;
    va_start(va, obj);
    id each = nil;
    while ((each = va_arg(va, id))) {
        [self addObject:each];
    }
    va_end(va);
}

- (void)__act_clicked:(SSlot*)s {
    self.currentSelection = (id)s.sender;
}

- (void)removeObject:(UIView*)obj {
    if (obj == self.currentSelection) {
        _currentSelection = nil;
    }
    [obj.signals disconnectToTarget:self];
    [_widgets removeObject:obj];
}

- (void)removeAllObjects {
    _currentSelection = nil;
    [_widgets removeAllObjects:^(id each) {
        [self removeObject:each];
    }];
}

- (void)setCurrentSelection:(UIView<UISelection> *)currentSelection {
    if (currentSelection == nil)
        return;
    
    if (_currentSelection == currentSelection) {
        if ([currentSelection respondsToSelector:@selector(selectionReactive)])
            [currentSelection selectionReactive];
        [self.signals emit:kSignalSelectionReactive withResult:currentSelection];
        return;
    }
    
    BOOL needsig = _currentSelection != nil;
    
    // 发送 ing 的消息，以让业务决定能不能选中
    if (needsig)
    {
        SSlotTunnel* tun = [SSlotTunnel temporary];
        [self.signals emit:kSignalSelectionChanging withResult:[NSPair pairFirst:_currentSelection Second:currentSelection]];
        if (tun.vetoed)
            return;
    }
    
    for (UIView<UISelection>* each in _widgets) {
        if (each != currentSelection)
            each.isSelection = NO;
    }
    
    // 设置为当前
    _currentSelection = currentSelection;
    _currentSelection.isSelection = YES;
    
    if (needsig)
        [self.signals emit:kSignalSelectionChanged withResult:_currentSelection];
}

- (void)setSelectionIndex:(NSInteger)selectionIndex {
    self.currentSelection = [_widgets objectAtIndex:selectionIndex def:nil];
}

- (NSInteger)selectionIndex {
    return [_widgets indexOfObject:self.currentSelection];
}

- (NSArray*)views {
    return _widgets;
}

@end

@implementation UIKit

SHARED_IMPL;

SIGNALS_BEGIN

SIGNAL_ADD(kSignalClicked)
SIGNAL_ADD(kSignalDbClicked)
SIGNAL_ADD(kSignalLongClicked)

SIGNAL_ADD(kSignalTouchesBegan)
SIGNAL_ADD(kSignalTouchesCancel)
SIGNAL_ADD(kSignalTouchesEnded)
SIGNAL_ADD(kSignalTouchesMoved)
SIGNAL_ADD(kSignalTouchesDone)

SIGNAL_ADD(kSignalGesture)
SIGNAL_ADD(kSignalGestureBegan)
SIGNAL_ADD(kSignalGestureEnded)
SIGNAL_ADD(kSignalGestureChanged)
SIGNAL_ADD(kSignalGestureCancel)
SIGNAL_ADD(kSignalGesturePossible)
SIGNAL_ADD(kSignalGestureFailed)
SIGNAL_ADD(kSignalGestureRecognized)

SIGNAL_ADD(kSignalViewAppear)
SIGNAL_ADD(kSignalViewFirstAppear)
SIGNAL_ADD(kSignalViewDisappear)

SIGNAL_ADD(kSignalValueChanged)

SIGNALS_END

@end

@interface UIViewExtension () {
    NSTimeInterval _lastTouchTimestamp;
}

@property (nonatomic, assign) int longClickWaiting;
@property (nonatomic, assign) UIView *owner;
@property (nonatomic, retain) UITouch *currentTouch;
@property (nonatomic, retain) UIView *viewHighlight;
@property (nonatomic, assign) BOOL isHighlight;

@end

@implementation UIViewExtension

- (void)dealloc {
    ZERO_RELEASE(_preferredPositionTouched);
    ZERO_RELEASE(_currentTouch);
    ZERO_RELEASE(_viewHighlight);
    [super dealloc];
}

- (void)setCurrentTouch:(UITouch *)currentTouch {
    if (_currentTouch == nil || currentTouch == nil)
        self.durationTouched = 0;
    else
        self.durationTouched = currentTouch.timestamp - _lastTouchTimestamp;
    _lastTouchTimestamp = currentTouch.timestamp;
    PROPERTY_RETAIN(_currentTouch, currentTouch);
}

- (CGPoint)positionTouched {
    if (_preferredPositionTouched)
        return _preferredPositionTouched.point;
    CGPoint pt = [_currentTouch locationInView:_owner];
    return pt;
}

- (CGPoint)positionTouchedIn:(UIView*)view {
    if (_preferredPositionTouched)
        return [_owner convertPoint:_preferredPositionTouched.point toView:view];
    CGPoint pt = [_currentTouch locationInView:view];
    return pt;
}

- (CGPoint)positionHitTest {
    CGPoint pt = [self positionTouched];
    pt = CGPointAddPoint(pt, self.hitTestOffset);
    return pt;
}

- (CGPoint)previousPositionTouched {
    CGPoint pt = [_currentTouch previousLocationInView:_owner];
    return pt;
}

- (CGPoint)deltaTouched {
    CGPoint ptc = [self positionTouched];
    CGPoint ptp = [self previousPositionTouched];
    return CGPointSubPoint(ptc, ptp);
}

- (CGPoint)velocityTouched {
    if (self.durationTouched == 0)
        return CGPointZero;
    CGPoint pt = self.deltaTouched;
    // 判定误触
    if (fabs(pt.x) < 5 && fabs(pt.y) < 5)
        return CGPointZero;
    pt = CGPointMultiply(pt, 1/self.durationTouched, 1/self.durationTouched);
    return pt;
}

@end

@interface UIView (signals)
<SSignals>
@end

@implementation UIView (signals)

- (void)signals:(NSObject *)object signalConnected:(NSString *)sig slot:(SSlot *)slot {
    if (self.userInteractionEnabled == NO) {
        BOOL touchs =
        sig == kSignalClicked ||
        sig == kSignalDbClicked ||
        sig == kSignalLongClicked ||
        sig == kSignalTouchesBegan ||
        sig == kSignalTouchesCancel ||
        sig == kSignalTouchesEnded ||
        sig == kSignalTouchesMoved;
        self.userInteractionEnabled = touchs;
    }
}

@end

@interface UIViewExt_BackgroundView : UIImageView @end
@implementation UIViewExt_BackgroundView

- (void)setImage:(UIImage *)image {
    if (UIEdgeInsetsEqualToEdgeInsets(image.capInsets, UIEdgeInsetsZero))
        self.contentMode = UIViewContentModeScaleAspectFill;
    else
        self.contentMode = UIViewContentModeScaleToFill;
    [super setImage:image];
}

@end

@interface UIView (backgroundView)

// 背景是否独立于当前的 view
- (BOOL)isBackgroundViewBeyond;

// 添加背景 view 到界面
- (void)doInsertBackgroundView:(UIView*)bv;

// 承载背景
@property (nonatomic, retain) UIViewExt_BackgroundView *ext_backgroundView;

// 用来当高亮时，保存一下背景颜色，用以高亮取消时设置回去
@property (nonatomic, retain) UIColor *ext_backgroundColor;

@end

@implementation UIView (backgroundView)

- (BOOL)isBackgroundViewBeyond {
    return YES;
}

- (void)doInsertBackgroundView:(UIView*)bv {
    [self.superview insertSubview:bv belowSubview:self];
}

NSOBJECT_DYNAMIC_PROPERTY_EXT(UIView, ext_backgroundView,, setExt_backgroundView, {
    [val removeFromSuperview];
}, {
    UIImageView* v = val;
    v.userInteractionEnabled = NO;
    v.hidden = self.hidden;
    v.frame = self.frameForBackground;
    [self doInsertBackgroundView:val];
}, RETAIN_NONATOMIC);

NSOBJECT_DYNAMIC_PROPERTY(UIView, ext_backgroundColor, setExt_backgroundColor, RETAIN_NONATOMIC);

@end

@implementation UIView (extension)

+ (instancetype)temporary {
    return [[[[self class] alloc] initWithZero] autorelease];
}

- (void)setVisible:(BOOL)visible {
    self.hidden = !visible;
}

- (BOOL)visible {
    return !self.hidden;
}

- (void)setVisible {
    self.visible = YES;
}

- (void)setInvisible {
    self.hidden = YES;
}

- (void)SWIZZLE_CALLBACK(set_hide):(BOOL)val {
    // 处理背景
    if (self.isBackgroundViewBeyond)
        self.ext_backgroundView.hidden = val;
    
    // 信号
    [self.touchSignals emit:kSignalVisibleChanged];
}

- (void)SWIZZLE_CALLBACK(set_userinteraction):(BOOL)val {
    [self.touchSignals emit:kSignalUserInteractionChanged];
}

- (void)bringUp {
    [self.superview bringSubviewToFront:self];
}

- (void)sendBack {
    [self.superview sendSubviewToBack:self];
}

- (BOOL)anyFocus {
    if (!self.userInteractionEnabled || self.hidden)
        return NO;
    if ([self isFirstResponder])
        return YES;
    if ([self canBecomeFirstResponder])
        return [self becomeFirstResponder];
    for (UIView* sub in self.subviews) {
        if (sub.anyFocus)
            return YES;
    }
    return NO;
}

NSOBJECT_DYNAMIC_PROPERTY_READONLY_EXT(UIView, extension, UIViewExtension, val.owner = self);

NSOBJECT_DYNAMIC_PROPERTY_DECL(UIView, motifColor);

- (void)setMotifColor:(UIColor *)color {
    self.backgroundColor = color;
    NSOBJECT_DYNAMIC_PROPERTY_SET(UIView, motifColor, RETAIN_NONATOMIC, color);
}

- (UIColor*)motifColor {
    UIColor* ret = NSOBJECT_DYNAMIC_PROPERTY_GET(UIView, motifColor);
    if (ret)
        return ret;
    return self.backgroundColor;
}

NSOBJECT_DYNAMIC_PROPERTY_DECL(UIView, menu);

- (void)setMenu:(UIMenuControllerExt *)menu {
    if (menu) {
        if ([menu isKindOfClass:[UIMenuControllerExt class]] == NO) {
            FATAL("绑定了一个错误的menu类型");
            menu = nil;
        } else {
            [self.signals connect:kSignalLongClicked withSelector:@selector(pass) ofTarget:self];
        }
    } else {
        [self.signals disconnect:kSignalLongClicked withSelector:@selector(pass) ofTarget:self];
    }
    
    NSOBJECT_DYNAMIC_PROPERTY_SET(UIView, menu, RETAIN_NONATOMIC, menu);
}

- (UIMenuControllerExt *)menu {
    id obj = NSOBJECT_DYNAMIC_PROPERTY_GET(UIView, menu);
    return obj;
}

NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR(UIView, dodgeTopRegion, setDodgeTopRegion, BOOL, @(val), [val boolValue], RETAIN);
NSOBJECT_DYNAMIC_PROPERTY(UIView, belongViewController, setBelongViewController, ASSIGN);
NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR(UIView, autolayoutMask, setAutolayoutMask, UIViewAutolayoutMask, @(val), [val intValue], RETAIN);

SIGNALS_BEGIN

self.signals.delegate = self;

SIGNAL_ADD(kSignalClicked)
SIGNAL_ADD(kSignalDbClicked)
SIGNAL_ADD(kSignalLongClicked)

SIGNAL_ADD(kSignalTouchesBegan)
SIGNAL_ADD(kSignalTouchesCancel)
SIGNAL_ADD(kSignalTouchesEnded)
SIGNAL_ADD(kSignalTouchesMoved)
SIGNAL_ADD(kSignalTouchesDone)

SIGNAL_ADD(kSignalLayoutBegin)
SIGNAL_ADD(kSignalLayoutEnd)
SIGNAL_ADD(kSignalLayouting)

SIGNAL_ADD(kSignalVisibleChanged)
SIGNAL_ADD(kSignalUserInteractionChanged)

SIGNAL_ADD(kSignalAddingToSuperview)
SIGNAL_ADD(kSignalAddedToSuperview)
SIGNAL_ADD(kSignalRemovingFromSuperview)
SIGNAL_ADD(kSignalRemovedFromSuperview)

SIGNAL_ADD(kSignalDrawRect)

SIGNALS_END

- (void)SWIZZLE_CALLBACK(set_frame):(CGRect)rc {
    self.ext_backgroundView.frame = [self frameForBackground];
}

- (void)SWIZZLE_CALLBACK(set_center):(CGPoint)pt {
    if (self.isBackgroundViewBeyond)
        self.ext_backgroundView.center = pt;
}

- (void)setFrame:(CGRect)frame anchorPoint:(CGPoint)anchor {
    frame.origin.x -= frame.size.width * anchor.x;
    frame.origin.y -= frame.size.height * anchor.y;
    self.frame = frame;
}

- (void)setAbsoluteFrame:(CGRect)frame anchorPoint:(CGPoint)anchor {
    frame.origin.x -= frame.size.width * anchor.x;
    frame.origin.y -= frame.size.height * anchor.y;
    [self setAbsoluteFrame:frame];
}

- (void)setAbsoluteFrame:(CGRect)rc {
    CGAffineTransform mat = self.transform;
    CATransform3D mat3d = self.layer.transform;
    self.transform = CGAffineTransformIdentity;
    self.layer.transform = CATransform3DIdentity;
    
    self.frame = rc;
    
    self.transform = mat;
    self.layer.transform = mat3d;
}

- (void)setAbsoluteCenter:(CGPoint)pt {
    CGAffineTransform mat = self.transform;
    CATransform3D mat3d = self.layer.transform;
    self.transform = CGAffineTransformIdentity;
    self.layer.transform = CATransform3DIdentity;
    
    self.center = pt;
    
    self.transform = mat;
    self.layer.transform = mat3d;
}

- (void)setAbsolutePosition:(CGPoint)pt {
    CGAffineTransform mat = self.transform;
    CATransform3D mat3d = self.layer.transform;
    self.transform = CGAffineTransformIdentity;
    self.layer.transform = CATransform3DIdentity;
    
    [self setPosition:pt];
    
    self.transform = mat;
    self.layer.transform = mat3d;
}

- (CGRect)screenFrame {
    CGRect rr = [self.superview convertRect:self.frame toView:nil];
    return rr;
}

- (CGRect)frameForView:(UIView*)view {
    UIView* v = [UIAppDelegate shared].window.rootViewController.view;
    CGRect rc = self.frame;
    rc = [v convertRect:rc fromView:self.superview];
    rc = [view convertRect:rc fromView:v];
    return rc;
}

static float kTouchesLongDuration = .25f;
static float kTouchesDBDuration = .2f;

# define TOUCHES_CANCEL \
{ \
self.extension.isTouching = 0; \
self.extension.longClickWaiting = NO; \
[self touchesCancelled:touches withEvent:event]; \
}

- (void)SWIZZLE_CALLBACK(touches_begin):(NSSet*)touches withEvent:(UIEvent*)event {
    self.extension.isTouching += 1;
    self.extension.currentTouch = [touches anyObject];
    self.extension.preferredPositionTouched = nil;
    
    // 如果不是第一次，则跳过判断
    if (self.extension.isTouching != 1)
        return;
    
    // 得到单击所位于的 view
    UIView* tv = [self hitTest:self.extension.positionHitTest withEvent:event];
    // 如果点击的不是自己，则跳过
    if (tv != self) {
        self.extension.isTouching = 0;
        return;
    }

    // 是否需要响应长按、双击
    if ([tv.touchSignals isConnected:kSignalLongClicked] ||
        [tv.touchSignals isConnected:kSignalDbClicked])
    {
        self.extension.longClickWaiting = YES;
        // 如果长按，则去处理长按的信号
        DISPATCH_DELAY(kTouchesLongDuration, {
            [self __act_longclicked_check];
        });
    }
    
    // 高亮处理
    UIView* hlview = self.extension.viewHighlight;
    if (hlview == nil) {
        hlview = self;
        while ((hlview.isHighlightEnable == NO) && hlview)
            hlview = hlview.superview;
    }
    if (hlview) {
        self.extension.viewHighlight = hlview;
        [self turnOnHighlight];
    }
    
    // 信号传递
    SSlotTunnel* tun = [SSlotTunnel temporary];
    [[UIKit shared].touchSignals emit:kSignalTouchesBegan withResult:touches withTunnel:tun];
    if (tun.vetoed) {
        TOUCHES_CANCEL;
    } else {
        [self.touchSignals emit:kSignalTouchesBegan withResult:touches withTunnel:tun];
    }
}

- (void)turnOnHighlight {
    UIView* hlv = self.extension.viewHighlight;
    hlv.extension.isHighlight = NO;
    
    if (hlv.highlightImage)
    {
        self.ext_backgroundColor = self.backgroundColor;
        self.backgroundColor = [UIColor clearColor];
        
        hlv.ext_backgroundView.image = hlv.highlightImage;
        hlv.extension.isHighlight = YES;
    }
    else if (hlv.highlightColor)
    {
        self.ext_backgroundColor = self.backgroundColor;
        self.backgroundColor = [UIColor clearColor];

        if (hlv.ext_backgroundView.image)
            hlv.ext_backgroundView.image = nil;
        hlv.ext_backgroundView.backgroundColor = hlv.highlightColor;
        hlv.extension.isHighlight = YES;
    }
}

- (void)turnOffHighlight {
    UIView* hlv = self.extension.viewHighlight;
    if (hlv.extension.isHighlight == NO)
        return;
    hlv.extension.isHighlight = NO;
    
    hlv.ext_backgroundView.backgroundColor = [UIColor clearColor];
    hlv.ext_backgroundView.image = hlv.backgroundImage;
    self.backgroundColor = self.ext_backgroundColor;
    
    self.extension.viewHighlight = nil;
}

- (void)__act_longclicked_check {
    int const touching = self.extension.isTouching;
    BOOL const waiting = self.extension.longClickWaiting;
    self.extension.longClickWaiting = NO;
    
    // 判断是不是长按
    if (touching == 1 && waiting) {
        // 在这里清除 touching 状态以避免 clicked 单击被阻断
        self.extension.isTouching = 0;
        
        // 转发信号
        [self.touchSignals emit:kSignalLongClicked];
        
        // 处理弹出菜单
        [self longclickedProcessMenu];
    }
}

- (void)longclickedProcessMenu {
    // 激活长按, 如果有menu，则显示menu
    UIMenuControllerExt* menuext = self.menu;
    if (menuext == nil)
        return;

    self.focus = YES;
    menuext.target = self;
    
    // 获得到UI的对象
    UIMenuController* menu = [menuext instanceMenu];
    menu.arrowDirection = UIMenuControllerArrowDefault;
    
    // 显示
    CGRect tgtrc = self.frame;
    CGPadding pad = menuext.padding;
    if ([self respondsToSelector:@selector(paddingEdge)]) {
        CGPadding vpd = [(UIViewExt*)self paddingEdge];
        pad = CGPaddingAddPadding(pad, vpd);
    }
    tgtrc = CGRectApplyPadding(tgtrc, pad);
    [menu setTargetRect:tgtrc inView:self.superview];
    [menu setMenuVisible:YES animated:YES];
}

- (void)__act_clicked_check {
    int const touching = self.extension.isTouching;
    self.extension.isTouching = 0;
    
    // 如果是多次点击
    if (touching > 1) {
        [self.touchSignals emit:kSignalDbClicked];
    }
    else if (touching == 1)
    {
        // 如果是单击
        SSlotTunnel* tun = [SSlotTunnel temporary];
        [[UIKit shared].touchSignals emit:kSignalClicked withResult:self withTunnel:tun];
        if (tun.vetoed == NO) {
            [self.touchSignals emit:kSignalClicked];
        }
    }
}

- (void)SWIZZLE_CALLBACK(touches_cancel):(NSSet*)touches withEvent:(UIEvent*)event {
    self.extension.currentTouch = [touches anyObject];
    if (self.extension.isTouching == 0)
        return;
    
    // 清空状态
    self.extension.isTouching = 0;
    self.extension.longClickWaiting = NO;
    
    // 高亮处理
    [self turnOffHighlight];
    
    // 发出标记
    [[UIKit shared].touchSignals emit:kSignalTouchesCancel withResult:touches];
    [self.touchSignals emit:kSignalTouchesCancel withResult:touches];

    [[UIKit shared].touchSignals emit:kSignalTouchesDone withResult:touches];
    [self.touchSignals emit:kSignalTouchesDone withResult:touches];
}

- (void)SWIZZLE_CALLBACK(touches_moved):(NSSet*)touches withEvent:(UIEvent*)event {
    self.extension.currentTouch = [touches anyObject];
    if (self.extension.isTouching == 0)
        return;
    
    SSlotTunnel* tun = [SSlotTunnel temporary];
    [[UIKit shared].touchSignals emit:kSignalTouchesMoved withResult:touches withTunnel:tun];
    if (tun.vetoed) {
        TOUCHES_CANCEL;
    } else {
        [self.touchSignals emit:kSignalTouchesMoved withResult:touches withTunnel:tun];
    }
}

- (void)SWIZZLE_CALLBACK(touches_end):(NSSet*)touches withEvent:(UIEvent*)event {
    self.extension.currentTouch = [touches anyObject];
    if (self.extension.isTouching == 0)
        return;
    
    // 清空状态
    self.extension.longClickWaiting = NO;
    
    // 关闭高亮
    [self turnOffHighlight];
    
    // 单击判断
    if (self.extension.isTouching == 1)
    {
        if ([self.touchSignals isConnected:kSignalDbClicked]) {
            DISPATCH_DELAY(kTouchesDBDuration, {
                [self __act_clicked_check];
            });
        } else {
            [self __act_clicked_check];
        }
    }
    
    // 信号处理
    [[UIKit shared].touchSignals emit:kSignalTouchesEnded withResult:touches];
    [self.touchSignals emit:kSignalTouchesEnded withResult:touches];

    [[UIKit shared].touchSignals emit:kSignalTouchesDone withResult:touches];
    [self.touchSignals emit:kSignalTouchesDone withResult:touches];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if ([sender isKindOfClass:[UIMenuController class]]) {
        if (sender == self.menu.menu) {
            if (self.menu.disableStandardActions) {
                char const* str = sel_getName(action);
                if (strncmp(str, "__wrapper_uimenu", 16) != 0)
                    return NO;
            }
            return [self.menu.target respondsToSelector:action];
        }
    }
    return NO;
}

# define UIMENU_WRAPPER_IMPL(idx) \
- (void)__wrapper_uimenu_action##idx:(UIMenuController*)obj { \
UIMenuItem* mi = [obj.menuItems objectAtIndex:idx]; \
[mi.signals emit:kSignalClicked]; \
}

UIMENU_WRAPPER_IMPL(0);
UIMENU_WRAPPER_IMPL(1);
UIMENU_WRAPPER_IMPL(2);
UIMENU_WRAPPER_IMPL(3);
UIMENU_WRAPPER_IMPL(4);
UIMENU_WRAPPER_IMPL(5);
UIMENU_WRAPPER_IMPL(6);
UIMENU_WRAPPER_IMPL(7);
UIMENU_WRAPPER_IMPL(8);
UIMENU_WRAPPER_IMPL(9);

- (BOOL)canBecomeFirstResponder {
    if (self.menu) {
        // 如果存在菜单，则必须返回 YES
        return YES;
    }
    
    // 默认返回 NO
    return NO;
}

- (BOOL)isHighlightEnable {
    if (self.highlightFill == nil)
        return NO;
    
    return [self.touchSignals isConnected:kSignalClicked] ||
    [self.touchSignals isConnected:kSignalLongClicked] ||
    [self.touchSignals isConnected:kSignalDbClicked];
}

@dynamic centerFrame;

- (CGRect)centerFrame {
    return self.frame;
}

- (void)setCenterFrame:(CGRect)centerFrame {
    [self setFrame:centerFrame anchorPoint:kCGAnchorPointCenter];
}

@dynamic subcontrollers;

static void* __uiview_key_subcontrollers;

- (NSSet*)subcontrollers {
    NSSet* ret = nil;
    SYNCHRONIZED_BEGIN
    ret = objc_getAssociatedObject(self, &__uiview_key_subcontrollers);
    if (ret == nil) {
        ret = [[NSMutableSet alloc] init];
        objc_setAssociatedObject(self, &__uiview_key_subcontrollers, ret, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        SAFE_RELEASE(ret);
    }
    SYNCHRONIZED_END
    return ret;
}

NSOBJECT_DYNAMIC_PROPERTY_DECL(UIView, navigationController);
NSOBJECT_DYNAMIC_PROPERTY_IMPL_SET(UIView, navigationController, setNavigationController, ASSIGN);

- (UINavigationController*)navigationController {
    id val = NSOBJECT_DYNAMIC_PROPERTY_GET(UIView, navigationController);
    if (val == nil)
        val = self.belongViewController.navigationController;
    if (val == nil) {
        UIView* sv = self.superview;
        if ([sv isKindOfClass:[UIWindow class]])
            return nil;
        val = sv.navigationController;
    }
    return val;
}

- (void)addSubcontroller:(UIViewController *)ctlr {
    if (ctlr == nil)
        return;
    ASSERT([ctlr isKindOfClass:[UIViewController class]]);
    NSMutableSet* arr = (id)self.subcontrollers;
    if ([arr containsObject:ctlr])
        return;
    [arr addObject:ctlr];
    [self addSubview:ctlr.view];
}

- (void)assignSubcontroller:(UIViewController *)ctlr {
    if (ctlr == nil)
        return;
    ASSERT([ctlr isKindOfClass:[UIViewController class]]);
    NSMutableSet* arr = (id)self.subcontrollers;
    if ([arr containsObject:ctlr])
        return;
    [arr addObject:ctlr];
}

- (void)removeSubcontroller:(UIViewController *)ctlr {
    if (ctlr == nil)
        return;
    NSMutableSet* arr = (id)self.subcontrollers;
    [ctlr.view removeFromSuperview];
    [arr removeObject:ctlr];
}

- (void)addSub:(id)obj {
    if ([obj isKindOfClass:[UIView class]]) {
        [self addSubview:obj];
    } else if ([obj isKindOfClass:[UIViewController class]]) {
        [self addSubcontroller:obj];
    }
}

- (void)removeSub:(id)obj {
    if ([obj isKindOfClass:[UIView class]]) {
        [obj removeFromSuperview];
    } else if ([obj isKindOfClass:[UIViewController class]]) {
        [self removeSubcontroller:obj];
    }
}

- (void)forceAddSub:(id)obj {
    SAFE_RETAIN(obj);
    [self removeSub:obj];
    [self addSub:obj];
    SAFE_RELEASE(obj);
}

- (void)forceAddSubview:(UIView*)v {
    SAFE_RETAIN(v);
    [v removeFromSuperview];
    [self addSubview:v];
    SAFE_RELEASE(v);
}

- (UIView*)behalfView {
    return self;
}

- (UIView*)ancestorView {
    UIView *pv = self.superview;
    UIView *cv = self;
    while (pv && ![pv isKindOfClass:[UIWindow class]]) {
        cv = pv;
        pv = cv.superview;
    }
    return cv;
}

- (NSArray*)ancestorViews {
    NSMutableArray* ret = [NSMutableArray array];
    UIView *pv = self.superview;
    while (pv && ![pv isKindOfClass:[UIWindow class]]) {
        UIView* cv = pv;
        pv = cv.superview;
        [ret addObject:cv];
    }
    return ret;
}

- (UIView*)findSuperviewAsType:(Class)cls {
    UIView* sv = self.superview;
    while (sv) {
       if ([sv isKindOfClass:cls])
           return sv;
        sv = sv.superview;
    }
    return nil;
}

+ (UIView*)CommonAncestorView:(UIView*)l of:(UIView*)r {
    NSArray* ls = l.ancestorViews;
    NSArray* rs = r.ancestorViews;
    NSArray* s = [ls arrayIntersects:rs];
    return s.firstObject;
}

- (UIView*)querySubview:(IteratorType(^)(UIView* v))query {
    for (UIView* each in self.subviews) {
        IteratorType it = query(each);
        if (it == kIteratorTypeOk)
            return each;
        if (it == kIteratorTypeBreak)
            continue;
        UIView* view = [each querySubview:query];
        if (view)
            return view;
    }
    return nil;
}

- (void)onLayout:(CGRect)rect {
    PASS;
}

- (void)onPosition:(CGRect)rect {
    PASS;
}

- (void)onDraw:(CGRect)rect {
    PASS;
}

- (id)initWithZero {
    self = [self initWithFrame:CGRectZero];
    return self;
}

+ (instancetype)viewWithFrame:(CGRect)frame {
    return [[[self alloc] initWithFrame:frame] autorelease];
}

@dynamic leftTop, leftBottom, rightTop, rightBottom, leftCenter, rightCenter, topCenter, bottomCenter, position;
@dynamic size;
@dynamic width, height, positionX, positionY;

- (void)setSize:(CGSize)sz {
    CGRect rc = self.frame;
    if (CGSizeEqualToSize(rc.size, sz))
        return;
    rc.size = sz;
    self.frame = rc;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setLeftTop:(CGPoint)pt {
    CGRect rc = self.frame;
    if (CGPointEqualToPoint(rc.origin, pt))
        return;
    rc.origin = pt;
    self.frame = rc;
}

- (CGPoint)leftTop {
    return self.frame.origin;
}

- (void)setLeftBottom:(CGPoint)pt {
    CGRect rc = self.frame;
    rc.origin.x = pt.x;
    rc.origin.y = pt.y - rc.size.height;
    self.frame = rc;
}

- (CGPoint)leftBottom {
    CGPoint pt = self.frame.origin;
    pt.y += self.frame.size.height;
    return pt;
}

- (void)setRightTop:(CGPoint)pt {
    CGRect rc = self.frame;
    rc.origin.x = pt.x - rc.size.width;
    rc.origin.y = pt.y;
    self.frame = rc;
}

- (CGPoint)rightTop {
    CGPoint pt = self.frame.origin;
    pt.x += self.frame.size.width;
    return pt;
}

- (void)setRightBottom:(CGPoint)pt {
    CGRect rc = self.frame;
    rc.origin.x = pt.x - rc.size.width;
    rc.origin.y = pt.y - rc.size.height;
    self.frame = rc;
}

- (CGPoint)rightBottom {
    CGPoint pt = self.frame.origin;
    pt.x += self.frame.size.width;
    pt.y += self.frame.size.height;
    return pt;
}

- (void)setRightCenter:(CGPoint)pt {
    pt.y -= self.bounds.size.height * .5f;
    [self setRightTop:pt];
}

- (CGPoint)rightCenter {
    CGPoint pt = self.rightTop;
    pt.y += self.bounds.size.height * .5f;
    return pt;
}

- (void)setLeftCenter:(CGPoint)pt {
    pt.y -= self.bounds.size.height * .5f;
    [self setLeftTop:pt];
}

- (CGPoint)leftCenter {
    CGPoint pt = self.leftTop;
    pt.y += self.bounds.size.height * .5f;
    return pt;
}

- (void)setTopCenter:(CGPoint)pt {
    pt.x -= self.bounds.size.width * .5f;
    [self setLeftTop:pt];
}

- (CGPoint)topCenter {
    CGPoint pt = self.leftTop;
    pt.x += self.bounds.size.width * .5f;
    return pt;
}

- (void)setBottomCenter:(CGPoint)pt {
    pt.x -= self.bounds.size.width * .5f;
    [self setLeftBottom:pt];
}

- (CGPoint)bottomCenter {
    CGPoint pt = self.leftBottom;
    pt.x += self.bounds.size.width * .5f;
    return pt;
}

- (void)setHeight:(CGFloat)val {
    CGRect rc = self.frame;
    if (rc.size.height == val)
        return;
    rc.size.height = val;
    self.frame = rc;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setWidth:(CGFloat)val {
    CGRect rc = self.frame;
    if (rc.size.width == val)
        return;
    rc.size.width = val;
    self.frame = rc;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)val anchorPoint:(CGPoint)anchor {
    CGRect rc = self.frame;
    if (rc.size.height == val)
        return;
    rc.origin.y += (rc.size.height - val) * anchor.y;
    rc.size.height = val;
    self.frame = rc;
}

- (void)setWidth:(CGFloat)val anchorPoint:(CGPoint)anchor {
    CGRect rc = self.frame;
    if (rc.size.width == val)
        return;
    rc.origin.x += (rc.size.width - val) * anchor.x;
    rc.size.width = val;
    self.frame = rc;
}

- (void)setPositionX:(CGFloat)val {
    CGRect rc = self.frame;
    if (rc.origin.x == val)
        return;
    rc.origin.x = val;
    self.frame = rc;
}

- (void)setPositionY:(CGFloat)val {
    CGRect rc = self.frame;
    if (rc.origin.y == val)
        return;
    rc.origin.y = val;
    self.frame = rc;
}

- (void)setBottomY:(CGFloat)val {
    CGRect rc = self.frame;
    rc.origin.y = val - rc.size.height;
    self.frame = rc;
}

- (void)setPosition:(CGPoint)val {
    CGRect rc = self.frame;
    rc.origin = CGPointIntegral(val);
    self.frame = rc;
}

- (CGPoint)position {
    return self.frame.origin;
}

- (void)offsetPosition:(CGPoint)val {
    val = CGPointIntegral(val);
    CGRect rc = self.frame;
    rc.origin.x += val.x;
    rc.origin.y += val.y;
    self.frame = rc;
}

- (CGRect)bestFrame {
    CGRect rc = self.frame;
    rc.size = self.bestSize;
    return rc;
}

- (CGSize)bestSize {
    return [self bestSize:CGSizeMax];
}

- (CGSize)bestSize:(CGSize)sz {
    return CGSizeZero;
}

- (CGRect)bestBehalfRegion:(CGSize)sz {
    return CGRectMakeWithPointAndSize(CGPointZero, [self bestSize:sz]);
}

- (CGFloat)bestHeight {
    return self.bestSize.height;
}

- (CGFloat)bestWidth {
    return self.bestSize.width;
}

- (CGFloat)bestHeight:(CGSize)sz {
    return [self bestSize:sz].height;
}

- (CGFloat)bestWidth:(CGSize)sz {
    return [self bestSize:sz].width;
}

- (CGFloat)bestHeightForWidth:(CGFloat)val {
    CGSize sz = CGSizeMax;
    if (val > 0)
        sz.width = val;
    return [self bestHeight:sz];
}

- (CGFloat)bestWidthForHeight:(CGFloat)val {
    CGSize sz = CGSizeMax;
    if (val > 0)
        sz.height = val;
    return [self bestWidth:sz];
}

- (CGFloat)bestHeightForWidth {
    return [self bestHeightForWidth:self.bounds.size.width];
}

- (CGFloat)bestWidthForHeight {
    return [self bestWidthForHeight:self.bounds.size.height];
}

+ (CGSize)BestSize {
    return [[self class] BestSize:CGSizeMax];
}

+ (CGSize)BestSize:(CGSize)sz {
    WARN("没有实现类型 %s 的 BestSize 方法", object_getClassName(self));
    return CGSizeZero;
}

+ (CGFloat)BestHeight {
    return [[self class] BestSize].height;
}

+ (CGFloat)BestWidth {
    return [[self class] BestSize].width;
}

- (CGRect)rectOfSubviews {
    CGRect rc = CGRectZero;
    for (UIView* v in self.subviews) {
        if (CGRectEqualToRect(rc, CGRectZero))
            rc = v.frame;
        else
            rc = CGRectUnion(rc, v.frame);
    }
    return rc;
}

- (void)addSubviews:(NSSet *)subviews {
    for (UIView* each in subviews) {
        [self addSubview:each];
    }
}

- (void)SWIZZLE_CALLBACK(layout_subviews) {
    PASS;
}

- (void)SWIZZLE_CALLBACK(layer_drawing):(CALayer*)layer inContext:(CGContextRef)ctx {
    PASS;
}

- (void)SWIZZLE_CALLBACK(layer_drawed):(CALayer*)layer inContext:(CGContextRef)ctx {
    PASS;
}

- (CGRect)frameForBackground {
    return self.frame;
}

- (CGRect)frameForKeybaord {
    return self.screenFrame;
}

NSOBJECT_DYNAMIC_PROPERTY(UIView, viewForKeyboard, setViewForKeyboard, ASSIGN);

- (void)SWIZZLE_CALLBACK(draw_rect):(CGRect)rc {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    // 获得有效的绘图区域
    rc = self.rectForLayout;
    [self.touchSignals emit:kSignalDrawRect withData:&rc];
    
    // 调用默认的处理函数
    [self onDraw:rc];
    if ([self respondsToSelector:@selector(onPaint:)]) {
        [self onPaint:[CGGraphic Current:rc]];
    }
    
    CGContextRestoreGState(ctx);
}

- (void)SWIZZLE_CALLBACK(moving_to_window):(UIWindow*)window {
    if (window)
        [self onAddingToWindow:window];
    else
        [self onRemovingFromWindow];
}

- (void)SWIZZLE_CALLBACK(moved_to_window) {
    if (self.window)
        [self onAddedToWindow];
    else
        [self onRemovedFromWindow];
}

- (void)SWIZZLE_CALLBACK(moving_to_superview):(UIView*)superview {
    if (superview) {
        [self.touchSignals emit:kSignalAddingToSuperview withResult:superview];
        [self onAddingToSuperview:superview];
    } else {
        [self.touchSignals emit:kSignalRemovingFromSuperview withResult:superview];
        [self onRemovingFromSuperview];
    }
}

- (void)SWIZZLE_CALLBACK(moved_to_superview) {
    if (self.superview) {
        // 放置背景
        if (self.backgroundFill || self.highlightFill)
            [self doInsertBackgroundView:self.ext_backgroundView];
        
        // 通知
        [self onAddedToSuperview];
        [self.touchSignals emit:kSignalAddedToSuperview];
    } else {
        if (self.backgroundFill || self.highlightFill)
            [self.ext_backgroundView removeFromSuperview];
        
        // 通知
        [self onRemovedFromSuperview];
        [self.touchSignals emit:kSignalRemovedFromSuperview];
    }
}

- (void)SWIZZLE_CALLBACK(add_view):(UIView*)view {
    PASS;
}

- (void)onAddingToSuperview:(UIView*)sv {
    PASS;
}

- (void)onAddedToSuperview {
    PASS;
}

- (void)onRemovingFromSuperview {
    PASS;
}

- (void)onRemovedFromSuperview {
    PASS;
}

- (void)onAddingToWindow:(UIWindow*)w {
    PASS;
}

- (void)onAddedToWindow {
    PASS;
}

- (void)onRemovingFromWindow {
    PASS;
}

- (void)onRemovedFromWindow {
    PASS;
}

NSOBJECT_DYNAMIC_PROPERTY_EXT(UIView, highlightFill,, setHighlightFill,, {
    // 如果设置，需要保证 bv 是存在的
    if (val && self.ext_backgroundView == nil) {
        self.ext_backgroundView = [UIViewExt_BackgroundView temporary];
    }
}, RETAIN_NONATOMIC);

NSOBJECT_DYNAMIC_PROPERTY_EXT(UIView, backgroundFill,, setBackgroundFill,, {
    if (val && self.ext_backgroundView == nil) {
        self.ext_backgroundView = [UIViewExt_BackgroundView temporary];
    }
}, RETAIN_NONATOMIC);

- (void)setCornerRadius:(CGFloat)cornerRadius {
    [self.layer roundlize:cornerRadius];
    [self.ext_backgroundView.layer roundlize:cornerRadius];
}

- (CGFloat)cornerRadius {
    return self.layer.cornerRadius;
}

- (void)cornerRoundlize {
    [self.layer roundlize];
    [self.ext_backgroundView.layer roundlize];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    if (backgroundImage && self.backgroundFill == nil)
        self.backgroundFill = [UIFill temporary];
    self.backgroundFill.image = backgroundImage;
    self.ext_backgroundView.image = backgroundImage;
}

- (void)setHighlightImage:(UIImage *)highlightImage {
    if (highlightImage && self.highlightFill == nil)
        self.highlightFill = [UIFill temporary];
    self.highlightFill.image = highlightImage;
}

- (void)setHighlightColor:(UIColor *)highlightColor {
    if (highlightColor && self.highlightFill == nil)
        self.highlightFill = [UIFill temporary];
    self.highlightFill.color = highlightColor;
}

- (UIImage*)backgroundImage {
    return self.backgroundFill.image;
}

- (UIColor*)highlightColor {
    return self.highlightFill.color;
}

- (UIImage*)highlightImage {
    return self.highlightFill.image;
}

- (void)setPushImageNamed:(NSString*)img {
    NSString* hiimg = [img stringByAppendingString:kUIImageHighlightSuffix];
    self.backgroundImage = [UIImage stretchImage:img];
    self.highlightImage = [UIImage stretchImage:hiimg];
}

- (UIImage*)renderToImage {
    return [self renderToImageWithBackgroundColor:self.backgroundColor];
}

- (UIImage*)renderToImageWithBackgroundColor:(UIColor*)color {
    CGRect rcwork = self.bounds;
    UIGraphicsBeginImageContextWithOptions(rcwork.size,
                                           self.opaque,
                                           kUIScreenScale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (ctx == nil)
        return nil;
    
    // 填充背景色
    if (color) {
        CGContextSetFillColorWithColor(ctx, color.CGColor);
        CGContextFillRect(ctx, rcwork);
    }
    
    if (kIOS7Above) {
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:AFTER_SCREENUPDATED];
    } else {
        [self.layer renderInContext:ctx];
    }
    
    // 取得绘制结果
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage*)renderRectToImage:(CGRect)rc {
    return [self renderRectToImage:rc backgroundColor:self.backgroundColor];
}

- (UIImage*)renderRectToImage:(CGRect)rc backgroundColor:(UIColor*)color {
    UIGraphicsBeginImageContextWithOptions(rc.size,
                                           self.opaque,
                                           kUIScreenScale);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (ctx == nil)
        return nil;
    
    CGContextTranslateCTM(ctx, -rc.origin.x, -rc.origin.y);
    if (color) {
        CGContextSetFillColorWithColor(ctx, color.CGColor);
        CGContextFillRect(ctx, self.bounds);
    }
    
    if (kIOS7Above) {
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:AFTER_SCREENUPDATED];
    } else {
        [self.layer renderInContext:ctx];
    }
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (CGPadding)paddingEdge {
    return CGPaddingZero;
}

- (CGPoint)offsetEdge {
    return CGPointZero;
}

- (CGRect)rectForLayout {
    CGRect rc = self.bounds;
    if (CGRectEqualToRect(rc, CGRectZero))
        return CGRectZero;
    rc = CGRectApplyPadding(rc, self.paddingEdge);
    rc = CGRectApplyOffset(rc, self.offsetEdge);
    return rc;
}

- (void)flushLayout {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR(UIView, countLayout, setCountLayout, int, @(val), [val intValue], RETAIN_NONATOMIC);

- (void)doLayoutSubviews:(CGRect)rc {
    NSRect* objrc = [[NSRect alloc] initWithRect:rc];
    
    // 准备，可以在回调中修改 rect，或者加动画
    [self.touchSignals emit:kSignalLayoutBegin withResult:objrc];
    
    // 布局
    [self callOnLayout:objrc.rect];
    
    // 提供二次处理
    [self.touchSignals emit:kSignalLayouting withResult:objrc];
    
    // 结束，可以用来结束动画等
    [self.touchSignals emit:kSignalLayoutEnd withResult:objrc];
    
    SAFE_RELEASE(objrc);
    
    // 放置覆盖用的VIEW
    [self.overlapWidget behalfView].frame = self.rectForOverlap;
    [[self.overlapWidget behalfView] bringUp];
}

# define UIVIEWEXT_LAYOUT_ANIMATED_BEGIN \
int tcountlayout = self.countLayout; \
if (tcountlayout == 0) [UIView setAnimationsEnabled:NO];
# define UIVIEWEXT_LAYOUT_ANIMATED_END \
if (tcountlayout == 0) [UIView setAnimationsEnabled:YES];

- (void)callOnLayout:(CGRect)rect {
    UIVIEWEXT_LAYOUT_ANIMATED_BEGIN
    [self onLayout:rect];
    UIVIEWEXT_LAYOUT_ANIMATED_END
    
    // 增加layout计数器
    ++self.countLayout;
}

- (BOOL)hasSuperView:(UIView*)v {
    UIView* each = self.superview;
    while (each &&
           each != v)
    {
        each = each.superview;
    }
    return each == v;
}

NSOBJECT_DYNAMIC_PROPERTY_EXT(UIView, overlapWidget,, setOverlapWidget, {
    [[self.overlapWidget behalfView] removeFromSuperview];
}, {
    [self addSub:val];
    [self setNeedsLayout];
}, RETAIN_NONATOMIC);

- (CGRect)rectForOverlap {
    return self.bounds;
}

+ (void)animateWithDuration:(NSTimeInterval)interval options:(UIViewAnimationOptions)option animations:(void(^)())animations {
    [UIView animateWithDuration:interval delay:0 options:option animations:animations completion:nil];
}

+ (void)animateWithDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options animations:(void(^)())animations completion:(void(^)(BOOL finished))completion {
    [UIView animateWithDuration:duration delay:0 options:options animations:animations completion:completion];
}

- (UIView*)subview:(NSString*)key instance:(UIView*(^)())instance {
    key = [NSString stringWithFormat:@"__::ui::subview::%@", key];
    return [self reusableObject:key instance:^id{
        UIView* v = instance();
        [self addSubview:v];
        return v;
    }];
}

- (UIView*)subview:(NSString*)key type:(Class)type {
    return [self subview:key instance:^UIView *{
        return [type temporary];
    }];
}

- (UIView*)subview:(NSString*)key {
    key = [NSString stringWithFormat:@"__::ui::subview::%@", key];
    return [self reusableObject:key];
}

- (UIView*)subviewAtKeyPath:(NSString*)keypath {
    NSArray* arr = [keypath componentsSeparatedByString:@"."];
    UIView* found = [self subview:arr.firstObject];
    for (int i = 1; i < arr.count; ++i)
        found = [found subview:[arr objectAtIndex:i]];
    return found;
}

- (NSArray*)subviews:(UIView*(^)())instance keys:(NSString*)key, ... {
    NSMutableArray* arr = [NSMutableArray temporary];
    [arr addObject:[self subview:key instance:instance]];
    
    va_list va;
    va_start(va, key);
    while ((key = va_arg(va, NSString*)))
    {
        [arr addObject:[self subview:key instance:instance]];
    }
    va_end(va);
    return arr;
}

- (UIViewController*)headViewController {
    UIViewController* vc = self.belongViewController;
    if (vc != nil)
        return vc;
    return self.superview.headViewController;
}

- (void)cancelTouchs {
    BOOL ou = self.userInteractionEnabled;
    self.userInteractionEnabled = NO;
    self.userInteractionEnabled = ou;
}

@end

@interface UIViewExt ()
{
    UIView* _ext_maskview;
}
@end

@implementation UIViewExt

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.backgroundColor = [UIColor clearColor];
    self.contentMode = UIViewContentModeRedraw;
    self.clipsToBounds = YES;
    self.autoresizingMask = UIViewAutoresizingNone;

    [self onInit];
    return self;
}

- (void)dealloc {
    [self onFin];
    [super dealloc];
}

+ (id)temporary {
    return [[[self alloc] initWithZero] autorelease];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalFrameChanging)
SIGNAL_ADD(kSignalFrameChanged)
SIGNAL_ADD(kSignalBoundsChanged)
SIGNALS_END

@synthesize paddingEdge, offsetEdge;

- (void)setNeedsLayout {
    if (DATA_ONLY_MODE == NO)
        [super setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _ext_maskview.frame = self.bounds;
    
    CGRect rc = self.rectForLayout;
    if (CGRectEqualToRect(rc, CGRectZero))
        return;
    
    [self doLayoutSubviews:rc];
}

- (void)doLayoutSubviews:(CGRect)rc {
    CGFloat top = 0;
    if (self.dodgeTopRegion)
    {
        top += kUIStatusBarHeight;
        UIViewController* bvc = self.belongViewController;
        if (!bvc.hidesTopBarWhenPushed) {
            top += kUINavigationBarHeight;
        }
    }
    rc = CGRectApplyPadding(rc, CGPaddingMake(top, 0, 0, 0));
    [super doLayoutSubviews:rc];
}

- (void)setFrame:(CGRect)frame {
    frame = CGRectIntegralEx(frame);
    
    if (CGRectEqualToRect(frame, self.frame)) {
        // 需要刷新以下页面，以激活因为数据改变而需要的布局修改
        //[self setNeedsLayout];
        // 注释掉是因为没找到受影响的地方
        return;
    }

    BOOL boundsChanged = !CGSizeEqualToSize(frame.size, self.bounds.size);
    
    NSRect* rcobj = [NSRect rect:frame];
    [self.touchSignals emit:kSignalFrameChanging withResult:rcobj];
    
    [super setFrame:rcobj.rect];
    
    [self.touchSignals emit:kSignalFrameChanged withResult:rcobj];
    
    if (boundsChanged) {
        [self.touchSignals emit:kSignalBoundsChanged withResult:[NSRect rect:self.bounds]];
    }
    
    [self setNeedsLayout];
}

- (BOOL)isHighlightEnable {
    if (self.highlightFill == nil)
        return NO;
    
    return [self.touchSignals isConnected:kSignalClicked] ||
    [self.touchSignals isConnected:kSignalLongClicked] ||
    [self.touchSignals isConnected:kSignalDbClicked];
}

- (BOOL)isBackgroundViewBeyond {
    return NO;
}

- (void)doInsertBackgroundView:(UIView*)bv {
    if (bv.superview == nil)
        [self insertSubview:bv atIndex:0];
    [self sendSubviewToBack:bv];
}

- (CGRect)frameForBackground {
    return self.bounds;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    [super drawLayer:layer inContext:ctx];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // 这个函数必须实现已激活 drawlayer 函数
}

- (void)setMaskView:(UIView *)maskView {
# ifdef IOS8_FEATURES
    if (kIOS8Above) {
        [super setMaskView:maskView];
        return;
    }
# endif
    
    PROPERTY_RETAIN(_ext_maskview, maskView);
    self.layer.mask = maskView.layer;
}

- (UIView*)maskView {
# ifdef IOS8_FEATURES
    if (kIOS8Above) {
        return [super maskView];
    }
# endif
    return _ext_maskview;
}

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations {
    kUIViewExtAnimationPeriod = YES;
    kUIViewExtAnimationDuration = duration;
    [UIView animateWithDuration:duration animations:animations];
    kUIViewExtAnimationPeriod = NO;
}

+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion {
    kUIViewExtAnimationPeriod = YES;
    kUIViewExtAnimationDuration = duration;
    [UIView animateWithDuration:duration delay:delay options:options animations:animations completion:completion];
    kUIViewExtAnimationPeriod = NO;
}

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion {
    kUIViewExtAnimationPeriod = YES;
    kUIViewExtAnimationDuration = duration;
    [UIView animateWithDuration:duration animations:animations completion:completion];
    kUIViewExtAnimationPeriod = NO;
}

@end

BOOL kUIViewExtAnimationPeriod = NO;
NSTimeInterval kUIViewExtAnimationDuration = 0;

@implementation UIControl (extension)

SIGNALS_BEGIN

SIGNAL_ADD(kSignalTouchesDown)
SIGNAL_ADD(kSignalTouchesUp)
SIGNAL_ADD(kSignalTouchesUpInside)
SIGNAL_ADD(kSignalTouchesUpOutside)
SIGNAL_ADD(kSignalTouchesCancel)

// 生成点击
[self addTarget:self action:@selector(__cb_touch_down_inside) forControlEvents:UIControlEventTouchDown];
[self addTarget:self action:@selector(__cb_touch_up_inside) forControlEvents:UIControlEventTouchUpInside];
[self addTarget:self action:@selector(__cb_touch_up_outside) forControlEvents:UIControlEventTouchUpOutside];
[self addTarget:self action:@selector(__cb_value_changed) forControlEvents:UIControlEventValueChanged];
[self addTarget:self action:@selector(__cb_touch_cancel) forControlEvents:UIControlEventTouchCancel];

SIGNAL_ADD(kSignalClicked)
SIGNAL_ADD(kSignalLongClicked)
SIGNAL_ADD(kSignalValueChanged)

SIGNALS_END

- (void)__cb_touch_up_outside {
    SSlotTunnel* tun = [SSlotTunnel temporary];
    [self.touchSignals emit:kSignalTouchesUpOutside withTunnel:tun];
    [self.touchSignals emit:kSignalTouchesUp withTunnel:tun];
}

- (void)__cb_touch_cancel {
    SSlotTunnel* tun = [SSlotTunnel temporary];
    [self.touchSignals emit:kSignalTouchesCancel withTunnel:tun];
    [self.touchSignals emit:kSignalTouchesUp withTunnel:tun];
}

- (void)__cb_touch_down_inside {
    SSlotTunnel* tun = [SSlotTunnel temporary];
    [self.touchSignals emit:kSignalTouchesDown withTunnel:tun];
    if (tun.vetoed)
        return;

    self.extension.isTouching = 1;
    
    // 是否需要判断长按
    if ([self.touchSignals isConnected:kSignalLongClicked])
    {
        self.extension.longClickWaiting = 0;
        [self performSoleSelector:@selector(__cb_wait_longclicked) withObject:nil afterDelay:kTouchesLongDuration];
    }
}

- (void)__cb_wait_longclicked {
    if (self.extension.isTouching) {
        self.extension.longClickWaiting = 1;
        // 需要发出长按的信号
        [self __cb_touch_up_inside];
    }
}

- (void)__cb_touch_up_inside {
    SSlotTunnel* tun = [SSlotTunnel temporary];
    [self.touchSignals emit:kSignalTouchesUpInside withTunnel:tun];
    [self.touchSignals emit:kSignalTouchesUp withTunnel:tun];
    if (tun.vetoed)
        return;

    // 判断是否为长按
    BOOL longclicked = NO;
    if ([self.touchSignals isConnected:kSignalLongClicked])
    {
        longclicked = self.extension.longClickWaiting;
        if (longclicked) {
            if (longclicked != 1) {
                // 已经激活了长按，所以短按不激活
                return;
            }
            // 累加一下长按计数，以避免重复信号的激发
            ++self.extension.longClickWaiting;
        }
    }
    self.extension.isTouching = 0;
    
    // 激活信号，并根据路由
    SSignal* sig = TRIEXPRESS(longclicked, kSignalLongClicked, kSignalClicked);
    [[UIKit shared].signals emit:sig withResult:self withTunnel:tun];
    if (tun.vetoed == NO)
        [self.touchSignals emit:sig];
    
    // 如果是长按，就需要激活长按弹出菜单的功能
    if (longclicked)
        [self longclickedProcessMenu];
}

- (void)__cb_value_changed {
    // 值发生修改
    [NSTrailChange SetChange];
    
    // 发出信号
    [self.touchSignals emit:kSignalValueChanged];
    [[UIKit shared].touchSignals emit:kSignalValueChanged withResult:self];
}

- (void)setDisabled:(BOOL)disabled {
    self.enabled = !disabled;
}

- (BOOL)disabled {
    return !self.enabled;
}

@end

@implementation UIControlExt

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self onInit];
    return self;
}

- (void)dealloc {
    [self onFin];
    [super dealloc];
}

- (void)SWIZZLE_CALLBACK(layout_subviews) {
    [super SWIZZLE_CALLBACK(layout_subviews)];
    [self onLayout:self.rectForLayout];
}

@end

static id __gs_hud = nil;

@interface UIHud ()

@property (nonatomic, readonly) UIView *panelShadow;
@property (nonatomic, readonly) NSMutableArray *btnActions;

@end

@implementation UIHud

- (void)onInit {
    [super onInit];
    
    if (kIOS7Above) {
        [self addSubview:BLOCK_RETURN({
            _panelShadow = [UIView temporary];
            _panelShadow.backgroundColor = [UIColor clearColor];
            _panelShadow.layer.shadow = [CGShadow Around];
            return _panelShadow;
        })];
    }
    
    [self addSubview:BLOCK_RETURN({
        if (kIOS7Above) {
            _panelView = [UIToolbar temporary];
        } else {
            _panelView = [UIViewExt temporary];
            _panelView.backgroundColor = [UIColor blackWithAlpha:.8];
        }
        _panelView.layer.masksToBounds = YES;
        _panelView.layer.cornerRadius = 8;
        return _panelView;
    })];
    
    [_panelView addSubview:BLOCK_RETURN({
        if (kIOS7Above) {
            _progressView = BLOCK_RETURN({
                UIRingActivityIndicator* v = [UIRingActivityIndicator temporary];
                v.pen.color = [UIColor blackColor].CGColor;
                v.radius = 16;
                return v;
            });
        } else {
            _progressView = BLOCK_RETURN({
                UIRingActivityIndicator* v = [UIRingActivityIndicator temporary];
                v.pen.color = [UIColor whiteColor].CGColor;
                v.radius = 16;
                return v;
            });
        }
        return _progressView;
    })];
    
    [_panelView addSubview:BLOCK_RETURN({
        _titleLabel = [UILabelExt temporary];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        if (kIOS7Above)
            _titleLabel.textColor = [UIColor colorWithWhitei:30];
        else
            _titleLabel.textColor = [UIColor whiteColor];
        return _titleLabel;
    })];
    
    [_panelView addSubview:BLOCK_RETURN({
        _detailLabel = [UILabelExt temporary];
        _detailLabel.multilines = YES;
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _detailLabel.textFont = [UIFont systemFontOfSize:15];
        if (kIOS7Above)
            _detailLabel.textColor = [UIColor blackColor];
        else
            _detailLabel.textColor = [UIColor whiteColor];
        return _detailLabel;
    })];
    
    self.type = kUIHudDefault;
    _btnActions = [[NSMutableArray alloc] init];
    
    // 避让键盘
    [[UIKeyboardExt shared].signals connect:kSignalFrameChanged withSelector:@selector(cbKeyboardFrameChanged) ofTarget:self];
    [[UIKeyboardExt shared].signals connect:kSignalKeyboardHiding withSelector:@selector(cbKeyboardFrameHidden) ofTarget:self];
}

- (void)onFin {
    if (__gs_hud == self)
        __gs_hud = nil;
    
    [[UIKeyboardExt shared].signals disconnectToTarget:self];
    ZERO_RELEASE(_btnActions);
    [super onFin];
}

+ (instancetype)Current {
    return __gs_hud;
}

- (NSObject*)addAction:(NSString*)name {
    if (self.type != kUIHudProgress)
        return nil;
    
    UIButtonExt* btn = [UIButtonExt temporary];
    btn.text = name;
    btn.textColor = [UIColor blackColor];
    btn.highlightTextColor = [UIColor grayColor];
    btn.textFont = [UIFont systemFontOfSize:20];
    btn.frame = _progressView.frame;
    [btn.signals connect:kSignalClicked withBlock:^(SSlot *s) {
        [UIHud HideProgress];
    }];
    
    self.userInteractionEnabled = YES;
    [_panelView addSubview:btn];
    [_btnActions addObject:btn];
    
    [UIViewExt animateWithDuration:kCAAnimationDuration animations:^{
        [self flushLayout];
    }];
    
    return btn;
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    // 获取最大的宽度
    real maxwidth = rect.size.width * .8;
    CGPadding panpad = CGPaddingMake(10, 10, 10, 10);
    real spacing = 8;
    if (self.type == kUIHudSymbol)
        spacing = 0;
 
    // 根据不同类型来布局
    UIVBox* box = [UIVBox boxWithRect:rect];
    [box addFlex:1 toView:nil];

    switch (self.type)
    {
        case kUIHudProgress:
        {
            [box addPixel:64 HBox:^(UIHBox *box) {
                [box addFlex:1 toView:nil];
                
                CGFloat pnlwidth = 64;
                for (UIView* each in _btnActions) {
                    pnlwidth += 5;
                    pnlwidth += each.bestWidth;
                }
                
                [box addPixel:pnlwidth HBox:^(UIHBox *box) {
                    box.inView = _panelView;
                    box.padding = panpad;
                    [box addFlex:1 toView:_progressView set:^(CGRect rc, UIView *view) {
                        view.frame = CGRectOffset(rc, 2, 0);
                    }];
                    
                    for (UIView* each in _btnActions) {
                        [box addPixel:5 toView:nil];
                        [box addPixel:each.bestWidth toView:each];
                    }
                }];
                [box addFlex:1 toView:nil];
            }];
        } break;
            
        case kUIHudText:
        case kUIHudSymbol:
        {
            CGSize bszTitle = [_titleLabel bestSize:CGSizeMake(maxwidth - CGPaddingWidth(panpad), CGVALUEMAX)];
            CGSize bszDetails = [_detailLabel bestSize:CGSizeMake(maxwidth - CGPaddingWidth(panpad), CGVALUEMAX)];
            
            real h = 0;
            if (bszTitle.height)
                h += bszTitle.height + spacing;
            h += bszDetails.height + CGPaddingHeight(panpad);
            h = [NSMath minf:h r:(kUIApplicationSize.height - CGPaddingHeight(panpad))];
            
            real w = [NSMath minf:maxwidth r:[NSMath maxf:bszTitle.width r:bszDetails.width] + CGPaddingWidth(panpad)];
            
            [box addPixel:h HBox:^(UIHBox *box) {
                [box addFlex:1 toView:nil];
                [box addPixel:w VBox:^(UIVBox *box) {
                    box.inView = _panelView;
                    box.padding = panpad;
                    if (bszTitle.height) {
                        [box addPixel:bszTitle.height toView:_titleLabel];
                        [box addPixel:spacing toView:nil];
                    }
                    [box addFlex:1 toView:_detailLabel];
                }];
                [box addFlex:1 toView:nil];
            }];
        };
    }
    
    [box addFlex:1 toView:nil];
    [box apply];
    
    // 设置一下阴影
    if (kIOS7Above) {
        _panelShadow.frame = _panelView.frame;
        CGRect rc = _panelShadow.bounds;
        _panelShadow.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:rc cornerRadius:8].CGPath;
    }
    
    // 如果键盘弹开，需要躲避
    if ([UIKeyboardExt shared].visible) {
        CGRect keyrc = [UIKeyboardExt shared].frame;
        CGRect hudrc = self.panelView.screenFrame;
        if (CGRectIntersectsRect(hudrc, keyrc)) {
            CGFloat off = CGRectLeftTop(keyrc).y - CGRectLeftBottom(hudrc).y;
            off -= 8;
            self.transform = CGAffineTransformMakeTranslation(0, off);
        }
    }
}

- (void)showIn:(UIView*)view animated:(BOOL)animated {
    // iOS7 因为使用毛玻璃效果，而毛玻璃不支持淡入淡出
    if (kIOS7Above)
        animated = NO;
    
    self.frame = view.bounds;
    [self flushLayout];
    
    [view addSubview:self];
    
    if (animated) {
        self.alpha = 0;
        [UIView animateWithDuration:.36 animations:^{
            self.alpha = 1;
        }];
    }
}

- (void)hideWithAnimated:(BOOL)animated {
    if (animated) {
        _panelShadow.hidden = YES;
        [UIView animateWithDuration:.36 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
        return;
    }
    
    [self removeFromSuperview];
}

- (void)setType:(UIHudType)type {
    if (_type == type)
        return;
    _type = type;
    
    _titleLabel.textFont = [UIFont boldSystemFontOfSize:16];
    switch (_type)
    {
        case kUIHudProgress: {
            _progressView.visible = YES;
            _detailLabel.visible = _titleLabel.visible = NO;
        } break;
        case kUIHudText: {
            _titleLabel.visible = _detailLabel.visible = YES;
            _progressView.visible = NO;
        } break;
        case kUIHudSymbol: {
            _titleLabel.visible = _detailLabel.visible = YES;
            _progressView.visible = NO;
            _titleLabel.textFont = [UIFont fontWithName:@"Heiti TC" size:50];
        } break;
    }
}

- (void)cbKeyboardFrameChanged {
    CGRect keyrc = [UIKeyboardExt shared].frame;
    CGRect hudrc = self.panelView.screenFrame;
    if (CGRectIntersectsRect(hudrc, keyrc)) {
        CGFloat off = CGRectLeftTop(keyrc).y - CGRectLeftBottom(hudrc).y;
        off -= 8;
        self.transform = CGAffineTransformMakeTranslation(0, off);
    }
}

- (void)cbKeyboardFrameHidden {
    self.transform = CGAffineTransformMakeTranslation(0, 0);
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect rc = self.frame;
    rc.size.width = 64;
    rc.size.height = 64;
    if (CGRectContainsPoint(rc, point)) {
        [self.class HideProgress];
        return nil;
    }
    return [super hitTest:point withEvent:event];
}

+ (void)Text:(NSString *)text title:(NSString *)title inView:(UIView*)view {
    if (text.notEmpty == NO) {
        LOG("不能显示为内容为nil的HUD");
        return;
    }
    
    UIHud* hud = [UIHud temporary];
    hud.userInteractionEnabled = NO;
    hud.type = kUIHudText;
    hud.detailLabel.text = text;
    hud.titleLabel.text = title;
    [hud showIn:view animated:YES];
    DISPATCH_DELAY(2, {
        [hud hideWithAnimated:YES];
    });
}

+ (void)Text:(NSString *)text inView:(UIView *)view {
    [self Text:text title:nil inView:view];
}

+ (void)Text:(NSString *)text {
    UIView* view = [UIAppDelegate shared].window;
    [self Text:text inView:view];
}

+ (void)Text:(NSString *)text title:(NSString *)title {
    UIView* view = [UIAppDelegate shared].window;
    [self Text:text title:title inView:view];
}

NSOBJ_GLOBALOBJ(NSAtomicCounter, hudprogresscounter);

+ (void)ShowProgress {
    if (hudprogresscounter().radd == 0)
    {
        ASSERTMSG(__gs_hud == nil, @"UIHudProgress 全局句柄已经被占用");
        UIView* view = [UIAppDelegate shared].window;
        
        UIHud* hud = [UIHud temporary];
        hud.type = kUIHudProgress;
        [hud showIn:view animated:YES];
        __gs_hud = hud;
    }
# ifdef DEBUG_MODE
    else
    {
        LOG("HudProgress 正处于显示中");
    }
# endif
}

+ (void)HideProgress {
    if (hudprogresscounter().value == 0) {
        LOG("HudProgress 之前已经隐藏");
        return;
    }
    
    // 最少显示1s，不然会在频繁调用时视觉感觉闪烁
    DISPATCH_DELAY_BEGIN(1)    
    if (hudprogresscounter().value && hudprogresscounter().sub == 0)
    {
        ASSERTMSG(__gs_hud != nil, @"UIHudProgress 全局句柄不能为 nil");

        [__gs_hud hideWithAnimated:YES];
        __gs_hud = nil;
    }
    DISPATCH_DELAY_END
}

+ (void)Symbol:(NSString*)symbol text:(NSString*)text inView:(UIView*)view {
    UIHud* hud = [UIHud temporary];
    hud.userInteractionEnabled = NO;
    hud.type = kUIHudSymbol;
    hud.detailLabel.text = text;
    hud.titleLabel.text = symbol;
    [hud showIn:view animated:YES];
    DISPATCH_DELAY(2, {
        [hud hideWithAnimated:YES];
    });
}

+ (void)Success:(NSString*)text {
    UIView* view = [UIAppDelegate shared].window;
    [self Symbol:@"√" text:text inView:view];
}

+ (void)Failed:(NSString*)text {
    UIView* view = [UIAppDelegate shared].window;
    [self Symbol:@"×" text:text inView:view];
}

+ (void)Noti:(NSString*)text {
    UIView* view = [UIAppDelegate shared].window;
    [self Symbol:@"!" text:text inView:view];
}

- (void)cbGyroChanged:(SSlot*)s {
    CGPoint3d pt = [s.data.object point3d];
    CATransform3D mat = CATransform3DMakeTranslation(pt.y, pt.x, 0);
    self.layer.transform = mat;
}

@end

void UIHudShowText(NSString* str) {
    [UIHud Text:str];
}

@implementation UIFont (extension)

- (CGFloat)emptyLineHeight {
    //return [@"口" sizeWithFont:self].height;
    return self.lineHeight;
}

+ (UIFont*)clearFont {
    static UIFont* ret = nil;
    SYNCHRONIZED_BEGIN
    if (ret == nil)
        ret = [UIFont systemFontOfSize:0];
    SYNCHRONIZED_END
    return ret;
}

+ (UIFont*)RandomFont {
    return [UIFont systemFontOfSize:[NSRandom valueBoundary:1 To:50]];
}

@end

@interface NSStylizedString (private)

@property (nonatomic, retain) NSAttributedString *unsafeAttributedString;

@end

@interface CAExtLabelStylizedLayer : CAStylizedTextLayer

@property (nonatomic, assign) BOOL needRedraw;

@end

@implementation CAExtLabelStylizedLayer

@end

@interface UILabel (extlayer)

@property (nonatomic, retain) CAExtLabelStylizedLayer *layerStylized;

@end

@implementation UILabel (extlayer)

NSOBJECT_DYNAMIC_PROPERTY_EXT(UILabel, layerStylized,, setLayerStylized,,, RETAIN_NONATOMIC);

@end

@implementation UILabel (extension)

- (void)setTruncation:(BOOL)truncation {
    if (truncation)
        self.lineBreakMode = NSLineBreakByTruncatingTail;
    else
        self.lineBreakMode = NSLineBreakByCharWrapping;
}

- (BOOL)truncation {
    return self.lineBreakMode != NSLineBreakByCharWrapping;
}

- (void)setTruncationAtTails:(NSInteger)truncationAtTail {
    if (truncationAtTail) {
        self.numberOfLines = truncationAtTail;
        self.lineBreakMode = NSLineBreakByTruncatingTail;
    } else {
        self.numberOfLines = 0;
        self.lineBreakMode = NSLineBreakByCharWrapping;
    }
}

- (NSInteger)truncationAtTails {
    if (self.numberOfLines == 0)
        return 0;
    if (self.lineBreakMode != NSLineBreakByTruncatingTail)
        return 0;
    return self.numberOfLines;
}

- (void)setEllipsisCenter:(BOOL)ellipsisCenter {
    if (ellipsisCenter)
        self.lineBreakMode = NSLineBreakByTruncatingMiddle;
    else
        self.lineBreakMode = NSLineBreakByCharWrapping;
}

- (BOOL)ellipsisCenter {
    return self.lineBreakMode != NSLineBreakByTruncatingMiddle;
}

- (CGSize)bestSize {
    return [self bestSize:CGSizeMax];
}

- (CGSize)bestSize:(CGSize)sz {
    if (self.stylizedString)
        return [self bestSizeForStyledString:sz];

    if (self.text.notEmpty)
        return [self bestSizeForString:sz];
    
    return CGSizeZero;
}

- (CGSize)bestSizeForString:(CGSize)sz {
    NSString* str = self.text;

    CGPadding pad = CGPaddingZero;
    if ([self respondsToSelector:@selector(contentPadding)]) {
        pad = [(id)self contentPadding];
        if (sz.width != CGVALUEMAX)
            sz.width -= CGPaddingWidth(pad);
        if (sz.height != CGVALUEMAX)
            sz.height -= CGPaddingHeight(pad);
    }
    
    CGSize ret = [str sizeWithFont:self.font
                 constrainedToSize:sz
                     lineBreakMode:self.lineBreakMode];
    
    // 如果有行数控制
    if (self.numberOfLines > 1) {
        CGFloat maxh = self.numberOfLines * self.font.emptyLineHeight;
        ret.height = MIN(ret.height, maxh);
    }
    
    if (sz.width == CGVALUEMAX)
        ret.width += CGPaddingWidth(pad);
    if (sz.height == CGVALUEMAX)
        ret.height += CGPaddingHeight(pad);
    
    ret = CGSizeBBXIntegral(ret);
    return ret;
}

- (CGSize)bestSizeForStyledString:(CGSize)sz {
    CGPadding pad = CGPaddingZero;
    if ([self respondsToSelector:@selector(contentPadding)]) {
        pad = [(id)self contentPadding];
        if (sz.width != CGVALUEMAX)
            sz.width -= CGPaddingWidth(pad);
        if (sz.height != CGVALUEMAX)
            sz.height -= CGPaddingHeight(pad);
    }
    
    CGSize ret = CGSizeZero;
    // 多行控制
    if (self.numberOfLines > 1) {
        ret = [self.stylizedString.unsafeAttributedString bestSize:sz
                                                       inLineRange:NSMakeRange(0, self.numberOfLines)];
    } else {
        ret = [self.stylizedString.unsafeAttributedString bestSize:sz];
    }
    
    if (sz.width == CGVALUEMAX)
        ret.width += CGPaddingWidth(pad);
    if (sz.height == CGVALUEMAX)
        ret.height += CGPaddingHeight(pad);
    
    ret = CGSizeBBXIntegral(ret);
    return ret;
}

- (NSUInteger)numberOfLinesForFullText:(CGSize)sz {
    if (sz.width == 0)
        sz.width = CGVALUEMAX;
    if (sz.height == 0)
        sz.height = CGVALUEMAX;
    
    if ([self respondsToSelector:@selector(contentPadding)]) {
        CGPadding pad = [(id)self contentPadding];
        if (sz.width != CGVALUEMAX)
            sz.width -= CGPaddingWidth(pad);
        if (sz.height != CGVALUEMAX)
            sz.height -= CGPaddingHeight(pad);
    }
    
    if (self.stylizedString) {
        return [self.stylizedString.unsafeAttributedString numberOfLines:sz];
    }
    
    if (self.text.notEmpty) {
        CGSize ret = [self.text sizeWithFont:self.font
                           constrainedToSize:sz
                               lineBreakMode:self.lineBreakMode];
        return [NSMath CeilFloat:ret.height r:self.font.emptyLineHeight];
    }
    
    return 0;
}

- (NSUInteger)numberOfLinesForFullText {
    return [self numberOfLinesForFullText:self.bounds.size];
}

- (NSUInteger)numberOfLinesForFullTextForWidth:(CGFloat)width {
    return [self numberOfLinesForFullText:CGSizeMake(width, CGVALUEMAX)];
}

- (NSUInteger)numberOfLinesForFullTextForWidth {
    return [self numberOfLinesForFullText:CGSizeMake(self.bounds.size.width, CGVALUEMAX)];
}

- (void)setMultilines:(BOOL)multilines {
    if (multilines == YES) {
        self.numberOfLines = 0;
        self.lineBreakMode = NSLineBreakByWordWrapping;
    } else {
        self.numberOfLines = 1;
    }
}

- (BOOL)multilines {
    return self.numberOfLines == 0;
}

- (void)setTextFont:(UIFont *)textFont {
    self.font = textFont;
}

- (UIFont*)textFont {
    return self.font;
}

- (void)copy:(id)sender {
    NSString* str = self.text;
    if (self.stylizedString)
        str = self.stylizedString.stringValue;
    [[UIPasteboard generalPasteboard] setObject:str];
}

- (CGPadding)contentPadding {
    return CGPaddingZero;
}

- (NSInteger)textVerticalAlignment {
    return NSTextAlignmentCenter;
}

- (void)SWIZZLE_CALLBACK(layer_drawed):(CALayer*)layer inContext:(CGContextRef)ctx {
    [super SWIZZLE_CALLBACK(layer_drawed):layer inContext:ctx];
    if (self.layer != layer)
        return;
    
    // 绘制样式字符串
    if (self.layerStylized.needRedraw)
    {
        CAExtLabelStylizedLayer* layer = self.layerStylized;
        NSAttributedString* as = layer.attributedString;
        CGRect rc = CGRectApplyPadding(self.bounds, self.contentPadding);
        CGSize size = CGSizeMake(rc.size.width, CGVALUEMAX);
        if (self.numberOfLines > 0) {
            size = [as bestSize:size inLineRange:NSMakeRange(0, self.numberOfLines)];
        } else {
            size = [as bestSize:size];
        }
        size.width = 0;
        
        // 计算大小
        switch ((int)self.textVerticalAlignment) {
            case NSTextAlignmentCenter: {
                rc = CGRectClipCenterBySize(rc, size);
            } break;
            case NSTextAlignmentTop: {
                rc.size.height = MIN(rc.size.height, size.height);
            } break;
            case NSTextAlignmentBottom: {
                if (size.height < rc.size.height) {
                    rc = CGRectCutSize(rc, 0, rc.size.height - size.height);
                } else {
                    rc.size.height = MIN(rc.size.height, size.height);
                }
            } break;
        }
        
        // 刷新显示
        if (CGRectEqualToRect(rc, layer.frame) == NO)
            layer.frame = rc;
        [layer setNeedsDisplay];
        self.layerStylized.needRedraw = NO;
    }
}

- (id<NSStylizedItem>)stylizedItemAtPoint:(CGPoint)pt {
    if ([self respondsToSelector:@selector(contentPadding)]) {
        CGPadding pad = [(id)self contentPadding];
        pt.x -= pad.left;
        pt.y -= pad.top;
    }
    
    // 点击的是label，但是stylized实际上有一些偏移
    CAStylizedTextLayer* lyrStylized = self.layerStylized;
    pt = CGPointSubPoint(pt, lyrStylized.frame.origin);
    return [lyrStylized itemAtPoint:pt];
}

NSOBJECT_DYNAMIC_PROPERTY_DECL(UILabel, stylizedString);
NSOBJECT_DYNAMIC_PROPERTY_IMPL_GET(UILabel, stylizedString);

- (void)setStylizedString:(NSStylizedString *)string {
    NSOBJECT_DYNAMIC_PROPERTY_SET(UILabel, stylizedString, RETAIN_NONATOMIC, string);
    
    // 设置用来渲染的层
    CAExtLabelStylizedLayer* layer = self.layerStylized;
    if (string)
    {
        // 如果不存在style，则需要按照当前的设置初始化一下
        if (string.lastStyle == nil) {
            [string setStylization:[NSStylization styleWithTextColor:self.textColor textFont:self.textFont]];
        } else {
            if (string.lastStyle.textFont == nil)
                string.style.textFont = self.textFont;
            if (string.lastStyle.textColor == nil)
                string.style.textColor = self.textColor;
        }
        
        // 建立绘图层
        if (layer == nil) {
            layer = [[CAExtLabelStylizedLayer alloc] init];
            self.layerStylized = layer;
            [self.layer addSublayer:layer];
            SAFE_RELEASE(layer);
        }
        
        if ([string paragraphSpecifiedAlignment] == NO)
            [[string style] setAlignment:self.textAlignment];
        if ([string paragraphSpecifiedLineBreak] == NO)
            [[string style] setLineBreakMode:self.lineBreakMode];
        
        // 提高性能
        string.unsafeAttributedString = string.attributedString;
        
        // 设置到绘图
        layer.numberOfLines = self.numberOfLines;
        layer.string = string;
        layer.needRedraw = YES;
        layer.size = CGSizeZero; // 必须重置为0大小，否则如果因为 label 的尺寸为0导致不重绘，但是 layer 的尺寸就没有变化
        
        // 需要把原来的text清空
        [self changeText:nil];
    }
    else if (layer)
    {
        [layer removeFromSuperlayer];
        self.layerStylized = nil;
    }
    
    // 重绘
    [self setNeedsDisplay];
    
    // 通知下变更
    [self.touchSignals emit:kSignalValueChanged];
}

- (void)changeText:(NSString*)str {
    [self setText:str];
}

- (CGRect)rectForContent {
    return self.bounds;
}

- (CGRect)boundsForContent {
    if (self.text) {
        return [self textRectForBounds:self.bounds limitedToNumberOfLines:self.numberOfLines];
    }
    
    if (self.stylizedString) {
        CAExtLabelStylizedLayer* layer = self.layerStylized;
        NSAttributedString* as = layer.attributedString;
        CGRect rc = self.rectForContent;
        CGSize size = CGSizeMake(rc.size.width, CGVALUEMAX);
        if (self.numberOfLines > 0) {
            size = [as bestSize:size inLineRange:NSMakeRange(0, self.numberOfLines)];
        } else {
            size = [as bestSize:size];
        }
        CGRect ret = CGRectMakeWithSize(size);
        switch (self.textAlignment) {
            default:
            case NSTextAlignmentLeft: {
                ret.origin = rc.origin;
            } break;
            case NSTextAlignmentCenter: {
                ret.origin = CGPointOffset(rc.origin, (rc.size.width - ret.size.width)/2, 0);
            } break;
            case NSTextAlignmentRight: {
                ret.origin = CGPointOffset(rc.origin, (rc.size.width - ret.size.width), 0);
            } break;
        }
        return ret;
    }
    
    return CGRectZero;
}

- (CGRect)frameForContent {
    CGRect rc = [self boundsForContent];
    rc.origin = CGPointAddPoint(rc.origin, self.frame.origin);
    return rc;
}

@end

@interface UILabelExt ()

@property (nonatomic, copy) NSString *originText;

@end

@implementation UILabelExt

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    self.textVerticalAlignment = NSTextAlignmentCenter;
    [self onInit];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_keywordColor);
    ZERO_RELEASE(_keywordFont);
    ZERO_RELEASE(_keyword);
    ZERO_RELEASE(_originText);
    ZERO_RELEASE(_currentState);
    ZERO_RELEASE(_states);
    
    [self onFin];
    [super dealloc];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalValueChanged)
SIGNALS_END

- (CGRect)rectForContent {
    CGRect rc = self.bounds;
    rc = CGRectApplyPadding(rc, self.contentPadding);
    return rc;
}

- (void)setText:(NSString*)str {
    [super setText:str];
    self.originText = str;
    
    if (self.keyword.notEmpty) {
        [self __lbext_updatekeyword];
    } else if (self.stylizedString) {
        self.stylizedString = nil;
    }
    
    [self.touchSignals emit:kSignalValueChanged];
}

- (void)changeText:(NSString*)str {
    self.originText = str;
    [super setText:str];
}

- (void)setKeyword:(NSString*)str {
    PROPERTY_COPY(_keyword, str);
    
    if (self.keyword.notEmpty) {
        [self __lbext_updatekeyword];
    } else if (self.stylizedString) {
        self.stylizedString = nil;
    }
}

- (UIFont*)keywordFont {
    if (_keywordFont == nil)
        return self.textFont;
    return _keywordFont;
}

- (UIColor*)keywordColor {
    if (_keywordColor == nil)
        return self.textColor;
    return _keywordColor;
}

- (void)__lbext_updatekeyword {
    NSString* oritext = self.originText;
    if (oritext == nil && self.stylizedString)
        oritext = self.stylizedString.stringValue;
    if (oritext == nil)
        return;
    
    NSArray* comps = nil;
    @try {
        comps = [oritext substringsByOccurrencesOfString:self.keyword options:NSCaseInsensitiveSearch | NSKeepFirstMatched];
    }
    @catch (...) {
        FATAL("UILabel处理keyword失败");
    }
    NSStylizedString* stystr = [NSStylizedString temporary];
    NSStylization* sep = [NSStylization styleWithTextColor:self.keywordColor textFont:self.keywordFont];
    NSStylization* val = [NSStylization styleWithTextColor:self.textColor textFont:self.textFont];
    [comps foreach:^IteratorType(id first) {
        [stystr append:val format:first];
        return kIteratorTypeOk;
    } next:^IteratorType(id second) {
        [stystr append:sep format:second];
        return kIteratorTypeOk;
    }];
    
    self.stylizedString = stystr;
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    bounds = CGRectApplyPadding(bounds, self.contentPadding);
    bounds = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    return bounds;
}

- (void)drawTextInRect:(CGRect)rect {
    rect = CGRectApplyPadding(rect, self.contentPadding);
    [super drawTextInRect:rect];
}

- (void)setCurrentState:(id)currentState {
    if ([_currentState isEqual:currentState])
        return;
    
    id str = [self.states objectForKey:currentState];
    if (str == nil) {
        WARN("UILabelExt 不包含该状态");
        return;
    }
    
    // 设置
    [[UIString Any:str] setIn:self];
    
    PROPERTY_RETAIN(_currentState, currentState);
}

- (void)updateState {
    if (_currentState) {
        id str = [self.states objectForKey:_currentState];
        if (str) {
            [[UIString Any:str] setIn:self];
        }
    }
}

@end

@implementation UILabelButton

- (void)onInit {
    [super onInit];
    self.textColor = [UIColor whiteColor];
    self.textAlignment = NSTextAlignmentCenter;
}

- (void)turnOnHighlight {
    [super turnOnHighlight];
    self.highlighted = YES;
}

- (void)turnOffHighlight {
    [super turnOffHighlight];
    self.highlighted = NO;
}

@end

@implementation UIButton (extension)

+ (id)temporary {
    // return [[self class] buttonWithType:UIButtonTypeSystem];
    // 导致 selected 后显示出现了个蓝底
    return [[self class] buttonWithType:UIButtonTypeCustom];
}

- (instancetype)initWithImage:(UIImage*)img {
    self = [super initWithFrame:CGRectMakeWithSize(img.size)];
    self.image = img;
    self.size = img.size;
    return self;
}

- (instancetype)initWithBackgroundImage:(UIImage*)img {
    self = [super initWithZero];
    self.backgroundImage = img;
    self.size = img.size;
    return self;
}

- (instancetype)initWithPushImage:(NSString*)img {
    return [self initWithPushImage:img stretch:YES];
}

- (instancetype)initWithPushImage:(NSString *)img stretch:(BOOL)stretch {
    self = [super initWithZero];
    [self setPushImageNamed:img stretch:stretch];
    return self;
}

+ (instancetype)buttonWithImage:(UIImage*)img {
    UIButton* btn = [[self alloc] initWithImage:img];
    btn.size = img.size;
    return [btn autorelease];
}

+ (instancetype)buttonWithBackgroundImage:(UIImage*)img {
    UIButton* btn = [[self alloc] initWithBackgroundImage:img];
    btn.size = img.size;
    return [btn autorelease];
}

+ (instancetype)buttonWithPushImage:(NSString*)img {
    UIButton* btn = [[self alloc] initWithZero];
    [btn setPushImageNamed:img];
    return [btn autorelease];
}

- (void)setAnyText:(NSString *)anyText {
    [self setTitle:anyText forState:self.state];
}

- (NSString*)anyText {
    return [self titleForState:self.state];
}

- (void)setText:(NSString *)text {
    [self setTitle:text forState:UIControlStateNormal];
    self.titleLabel.stylizedString = nil;
}

- (NSString*)text {
    return [self titleForState:UIControlStateNormal];
}

- (void)setDisabledText:(NSString *)disabledText {
    [self setTitle:disabledText forState:UIControlStateDisabled];
}

- (NSString*)disabledText {
    return [self titleForState:UIControlStateDisabled];
}

- (void)setSelectedText:(NSString *)selectedText {
    [self setTitle:selectedText forState:UIControlStateSelected];
    self.titleLabel.stylizedString = nil;
}

- (NSString*)selectedText {
    return [self titleForState:UIControlStateSelected];
}

- (void)setTextColor:(UIColor*)color {
    [self setTitleColor:color forState:UIControlStateNormal];
}

- (UIColor*)textColor {
    return [self titleColorForState:UIControlStateNormal];
}

- (void)setDisabledTextColor:(UIColor *)disabledTextColor {
    [self setTitleColor:disabledTextColor forState:UIControlStateDisabled];
}

- (UIColor*)disabledTextColor {
    return [self titleColorForState:UIControlStateDisabled];
}

- (void)setHighlightTextColor:(UIColor *)highlightTextColor {
    [self setTitleColor:highlightTextColor forState:UIControlStateHighlighted];
}

- (UIColor*)highlightTextColor {
    return [self titleColorForState:UIControlStateHighlighted];
}

- (void)setSelectedTextColor:(UIColor *)selectedTextColor {
    [self setTitleColor:selectedTextColor forState:UIControlStateSelected];
}

- (UIColor*)selectedTextColor {
    return [self titleColorForState:UIControlStateSelected];
}

- (void)setTextFont:(UIFont *)font {
    self.titleLabel.font = font;
}

- (UIFont*)textFont {
    return self.titleLabel.font;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    self.titleLabel.textAlignment = textAlignment;
}

- (NSTextAlignment)textAlignment {
    return self.titleLabel.textAlignment;
}

- (void)setImage:(UIImage*)img {
    [self setImage:img forState:UIControlStateNormal];
    if (self.image != nil && self.image != img)
        [NSTrailChange SetChange];
    // 如果当前大小为0，则初始化一下
    if (CGSizeEqualToSize(self.bounds.size, CGSizeZero))
        self.size = img.size;
}

- (void)setImageMargin:(CGMargin)m {
    UIEdgeInsets ei = UIEdgeInsetsMake(m.top, m.left, m.bottom, m.right);
    self.imageEdgeInsets = ei;
}

- (CGMargin)imageMargin {
    UIEdgeInsets ei = self.imageEdgeInsets;
    return CGMarginMake(ei.top, ei.bottom, ei.left, ei.right);
}

- (UIImage*)image {
    return [self imageForState:UIControlStateNormal];
}

- (void)setHighlightImage:(UIImage *)highlightImage {
    [self setImage:highlightImage forState:UIControlStateHighlighted];
}

- (UIImage*)highlightImage {
    return [self imageForState:UIControlStateHighlighted];
}

- (void)setHighlightColor:(UIColor *)highlightColor {
    PASS;
}

- (void)setBackgroundImage:(UIImage *)image {
    [self setBackgroundImage:image forState:UIControlStateNormal];
}

- (UIImage*)backgroundImage {
    return [self backgroundImageForState:UIControlStateNormal];
}

- (void)setDisabledBackgroundImage:(UIImage *)disabledBackgroundImage {
    [self setBackgroundImage:disabledBackgroundImage forState:UIControlStateDisabled];
}

- (UIImage*)disabledBackgroundImage {
    return [self backgroundImageForState:UIControlStateDisabled];
}

- (void)setSelectedImage:(UIImage *)selectedImage {
    [self setImage:selectedImage forState:UIControlStateSelected];
}

- (UIImage*)selectedImage {
    return [self imageForState:UIControlStateSelected];
}

- (void)setSelectedBackgroundImage:(UIImage *)selectedBackgroundImage {
    [self setBackgroundImage:selectedBackgroundImage forState:UIControlStateSelected];
}

- (UIImage*)selectedBackgroundImage {
    return [self backgroundImageForState:UIControlStateSelected];
}

- (void)setPushImageNamed:(NSString *)ds {
    [self setPushImageNamed:ds stretch:YES];
}

- (void)setPushImageNamed:(NSString*)ds stretch:(BOOL)stretch {
    UIImage* img = nil;
    UIImage* imgh = nil;
    if (stretch) {
        img = [UIImage stretchImage:ds];
        imgh = [UIImage stretchImage:[ds stringByAppendingString:kUIImageHighlightSuffix]];
    } else {
        img = [UIImage imageWithContentOfNamed:ds];
        imgh = [UIImage imageWithContentOfNamed:[ds stringByAppendingString:kUIImageHighlightSuffix]];
    }
    
    if (stretch) {
        if (img)
            [self setBackgroundImage:img forState:UIControlStateNormal];
        if (imgh)
            [self setBackgroundImage:imgh forState:UIControlStateHighlighted];
    } else {
        if (img)
            [self setImage:img forState:UIControlStateNormal];
        if (imgh)
            [self setImage:imgh forState:UIControlStateHighlighted];
    }
    
    // 如果可能，调整到图片大小
    if (CGSizeEqualToSize(self.bounds.size, CGSizeZero) &&
        img)
    {
        [self setSize:img.size];
    }
}

- (void)setContentPadding:(CGPadding)contentPadding {
    self.contentEdgeInsets = UIEdgeInsetsFromPadding(contentPadding);
}

- (CGPadding)contentPadding {
    return CGPaddingFromEdgeInsets(self.contentEdgeInsets);
}

- (CGSize)bestSize:(CGSize)sz {
    CGSize ret = CGSizeZero;
    
    NSString* str = self.text;
    if (self.selected) {
        if (self.selectedText.notEmpty)
            str = self.selectedText;
    }
    
    if (str.notEmpty == NO)
    {
        if (self.selected)
        {
            if (self.selectedBackgroundImage)
                ret = self.selectedBackgroundImage.size;
            else if (self.selectedImage)
                ret = self.selectedImage.size;
            else if (self.image)
                ret = self.image.size;
            else if (self.backgroundImage)
                ret = self.backgroundImage.size;
        }
        else
        {
            if (self.backgroundImage)
                ret = self.backgroundImage.size;
            else if (self.image)
                ret = self.image.size;
        }
    }
    else
    {
        // 获得到文字的大小
        ret = [str sizeWithFont:self.textFont
              constrainedToSize:sz
                  lineBreakMode:self.titleLabel.lineBreakMode];
        
        // 如果有图标，则说明文字前面带了一个 imageview
        if (self.image) {
            CGSize sz = self.image.size;
            ret.width += sz.width;
            ret.height = MAX(ret.height, sz.height);
            UIEdgeInsets ei = self.imageEdgeInsets;
            ret.width += UIEdgeInsetsWidth(ei);
        }
    }
    
    ret = CGSizeUnapplyPadding(ret, self.contentPadding);
    ret = CGSizeBBXIntegral(ret);
    return ret;
}

- (void)setStylizedString:(NSStylizedString *)stylizedString {
    // 不输入空格则换选时得stylizedstring不显示
    [self setTitle:@"      " forState:UIControlStateNormal];
    self.titleLabel.stylizedString = stylizedString;
}

- (NSStylizedString*)stylizedString {
    return self.titleLabel.stylizedString;
}

- (BOOL)isSelection {
    return self.selected;
}

- (void)setIsSelection:(BOOL)isSelection {
    self.selected = isSelection;
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalStateChanged)
SIGNALS_END

NSOBJECT_DYNAMIC_PROPERTY(UIButton, states, setStates, RETAIN_NONATOMIC);
NSOBJECT_DYNAMIC_PROPERTY_EXT(UIButton, currentState,, setCurrentState,, {
    UIString* str = [UIString Any:[self.states objectForKey:val]];
    if (str == nil)
        LOG("没有在 button 的 states 找到指定状态");
    [str setIn:self];
    [self.signals emit:kSignalStateChanged];
}, RETAIN_NONATOMIC);

- (CGRect)contentFrame {
    return [self titleRectForContentRect:self.bounds];
}

@end

@implementation UIButtonExt

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self onInit];
    return self;
}

- (void)dealloc {
    [self onFin];
    [super dealloc];
}

@synthesize paddingEdge, offsetEdge;

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGPaddingEqualToPadding(self.hitTestPadding, CGPaddingZero)) {
        BOOL hit = [super pointInside:point withEvent:event];
        return hit;
    }
    
    CGRect rc = self.bounds;
    if ([self.superview isKindOfClass:[UINavigationBar class]]) {
        point.y *= kUIScreenScale;
        CGRect rcsv = self.superview.bounds;
        rc.size.height = rcsv.size.height;
    }
    
    rc = CGRectApplyPadding(rc, self.hitTestPadding);
    BOOL hit = CGRectContainsPoint(rc, point);
    return hit;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self SWIZZLE_CALLBACK(layout_subviews)];
    [self onLayout:self.rectForLayout];
}

@end

@interface UIViewControllerExtension : NSObject

@property (nonatomic, assign) BOOL observedTitle;
@property (nonatomic, assign) UIViewController* owner;
@property (nonatomic, assign) int countAppeared;
@property (nonatomic, assign) BOOL appeared;

@end

@implementation UIViewControllerExtension

- (void)dealloc {
    
    if (self.observedTitle) {
        self.observedTitle = NO;
        [_owner removeObserver:self forKeyPath:@"title"];
    }
    
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (self.observedTitle && [keyPath isEqualToString:@"title"]) {
        [_owner.signals emit:kSignalTitleChanged withResult:_owner.title];
    }
}

@end

@interface UIViewController (signals)
<SSignals>

@property (nonatomic, readonly) UIViewControllerExtension *extension;

@end

@implementation UIViewController (signals)

NSOBJECT_DYNAMIC_PROPERTY_DECL(UIViewController, extension);

- (UIViewControllerExtension*)extension {
    UIViewControllerExtension* ext = nil;
    SYNCHRONIZED_BEGIN
    ext = NSOBJECT_DYNAMIC_PROPERTY_GET(UIViewController, extension);
    if (ext == nil) {
        ext = [[UIViewControllerExtension alloc] init];
        ext.owner = self;
        NSOBJECT_DYNAMIC_PROPERTY_SET(UIViewController, extension, RETAIN_NONATOMIC, ext);
        SAFE_RELEASE(ext);
    }
    SYNCHRONIZED_END
    return ext;
}

- (void)signals:(NSObject*)object signalConnected:(SSignal*)sig slot:(SSlot*)slot {
    if (!self.extension.observedTitle && sig == kSignalTitleChanged) {
        self.extension.observedTitle = YES;
        [self addObserver:self.extension forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    }
}

@end

@interface UIViewControllerAttributes ()

@property (nonatomic, retain) UIColor *previousNavigationBarTintColor;

@end

@implementation UIViewControllerAttributes

- (id)init {
    self = [super init];
    _statusBarStyle = [UIAppDelegate shared].preferredStatusBarStyle;
    _tabBarDodge = kIOS7Above;
    self.navigationBarBlur = NO;
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_navigationBarInherit);
    ZERO_RELEASE(_navigationBarTranslucent);
    ZERO_RELEASE(_navigationBarTintColor);
    ZERO_RELEASE(_previousNavigationBarTintColor);
    ZERO_RELEASE(_navigationBarColor);
    ZERO_RELEASE(_navigationBarImage);
    ZERO_RELEASE(_navigationBarHeight);
    ZERO_RELEASE(_tabBarHeight);
    ZERO_RELEASE(_navigationBarTitleStyle);
    ZERO_RELEASE(_statusBarHidden);
    ZERO_RELEASE(_statusBarColor);
    ZERO_RELEASE(_statusBarTintColor);
    [super dealloc];
}

- (UITextStyle*)navigationBarTitleStyle {
    if (_navigationBarTitleStyle == nil) {
        NSDictionary* dict = [UINavigationBar appearance].titleTextAttributes;
        _navigationBarTitleStyle = [[UITextStyle alloc] init];
        _navigationBarTitleStyle.textColor = [dict objectForKey:UITextAttributeTextColor];
        if (_navigationBarTitleStyle.textColor == nil)
            _navigationBarTitleStyle.textColor = [UIColor blackColor];
        _navigationBarTitleStyle.textFont = [dict objectForKey:UITextAttributeFont];
        if (_navigationBarTitleStyle.textFont == nil)
            _navigationBarTitleStyle.textFont = [UIFont boldSystemFontOfSize:18];
    }
    return _navigationBarTitleStyle;
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    _statusBarStyle = statusBarStyle;
    self.statusBarTintColor = nil;
}

- (void)setStatusBarTintColor:(UIColor *)statusBarTintColor {
    PROPERTY_RETAIN(_statusBarTintColor, statusBarTintColor);
    if (_statusBarTintColor.rgb > 0x800000)
        _statusBarStyle = UIStatusBarStyleLightContent;
    else
        _statusBarStyle = UIStatusBarStyleDefault;
}

@end

@interface UIScrollView (edgeinsets)

@property (nonatomic, assign) UIEdgeInsets
edgeInsetsForNavigationBar,
edgeInsetsForTabBar,
edgeInsetsForHeaderAddition,
edgeInsetsForFooterAddition,
edgeInsetsAddition,
edgeInsetsForPull;

@end

@implementation UIViewController (extension)

NSOBJECT_DYNAMIC_PROPERTY_READONLY_EXT(UIViewController, attributes, UIViewControllerAttributes, );

NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR(UIViewController, hidesTopBarWhenPushed, setHidesTopBarWhenPushed, BOOL, @(val), [val boolValue], RETAIN_NONATOMIC);

NSOBJECT_DYNAMIC_PROPERTY_DECL(UIViewController, superViewController);
NSOBJECT_DYNAMIC_PROPERTY_IMPL_SET(UIViewController, superViewController, setSuperViewController, ASSIGN);

- (UIViewController*)superViewController {
    UIViewController* ret = NSOBJECT_DYNAMIC_PROPERTY_GET(UIViewController, superViewController);
    if (ret == nil)
        ret = self.parentViewController;
    return ret;
}

NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR(UIViewController, panToBack, setPanToBack, BOOL, @(val),
                                       TRIEXPRESS(val, [val boolValue], YES),
                                       RETAIN_NONATOMIC);

NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR(UIViewController, enableContainerGesture, setEnableContainerGesture, BOOL, @(val),
                                       TRIEXPRESS(val, [val boolValue], YES),
                                       RETAIN_NONATOMIC);

SIGNALS_BEGIN

self.signals.delegate = self;

SIGNAL_ADD(kSignalViewControllerDismissing)
SIGNAL_ADD(kSignalViewControllerDismissed)

SIGNAL_ADD(kSignalViewLoaded)
SIGNAL_ADD(kSignalViewAppear)
SIGNAL_ADD(kSignalViewFirstAppear)
SIGNAL_ADD(kSignalViewAppearing)
SIGNAL_ADD(kSignalViewFirstAppearing)
SIGNAL_ADD(kSignalViewDisappear)
SIGNAL_ADD(kSignalViewDisappearing)

SIGNAL_ADD(kSignalTitleChanged)

SIGNALS_END

- (void)SWIZZLE_CALLBACK(view_loaded) {
    // set belong
    self.view.belongViewController = self;
    
    // callback
    [self.touchSignals emit:kSignalViewLoaded];
    [self onLoaded];
}

- (UIView*)behalfView {
    if (self.isViewLoaded)
        return self.view;
    return nil;
}

- (void)onLoaded {
    PASS;
}

- (void)onAppearing {
    PASS;
}

- (void)onAppeared {
    PASS;
}

- (void)onDisappearing {
    PASS;
}

- (void)onDisappeared {
    PASS;
}

NSOBJECT_DYNAMIC_PROPERTY(UIViewController, navigationBarView, setNavigationBarView, RETAIN_NONATOMIC);

- (void)updateData {
    [self.view updateData];
}

- (void)dismissModalViewController {
    [self.touchSignals emit:kSignalViewControllerDismissing];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.touchSignals emit:kSignalViewControllerDismissed];
    }];
}

- (void)dismissModalViewControllerNoAnimated {
    [self.touchSignals emit:kSignalViewControllerDismissing];
    [self dismissViewControllerAnimated:NO completion:^{
        [self.touchSignals emit:kSignalViewControllerDismissed];
    }];
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent {
    [self presentViewController:viewControllerToPresent animated:YES completion:^{
        PASS;
    }];
}

- (void)presentViewControllerNoAnimated:(UIViewController *)viewControllerToPresent {
    [self presentViewController:viewControllerToPresent animated:NO completion:^{
        PASS;
    }];
}

- (void)removeFromSuperview {
    [self.view removeFromSuperview];
}

- (NSSet*)subcontrollers {
    return nil;
}

- (void)onMemoryWarning {
    LOG("收到 VC %s 内存警告", object_getClassName(self));
}

- (void)goBack:(BOOL)animated {
    if (self.stackController)
        [self.stackController popViewControllerWithAnimated:animated];
    else if (self.navigationController)
        [self.navigationController goBack:animated];
    else if ([UIAppDelegate shared].topmostViewController == self)
        [self dismissModalViewControllerAnimated:animated];
}

- (void)goBack {
    [self goBack:YES];
}

- (void)goBackNoAnimated {
    [self goBack:NO];
}

- (UIView*)viewForDodge {
    return self.view.behalfView;
}

- (UIViewControllerStack*)stackController {
    id svc = self.superViewController;
    if ([svc isKindOfClass:[UIViewControllerStack class]])
        return svc;
    return nil;
}

- (NSSet*)allSubcontrollers {
    NSMutableSet* ret = [NSMutableSet set];
    [ret unionSet:self.subcontrollers];
    if (self.isViewLoaded)
        [ret unionSet:self.view.subcontrollers];
    return ret;
}

// 信号和Callback的顺序
// 先激发信号，再次调用回调，以方便各种listener处理完后可以在应用层以重载的形式进行后处理

- (void)SWIZZLE_CALLBACK(appearing):(BOOL)animated {
    if (self.extension.appeared)
        return;
    
    // 是否第一次显示
    if (self.extension.countAppeared == 0) {
        [self onFirstAppearing];
        [self.touchSignals emit:kSignalViewFirstAppearing];
    } else {
        [self onLaterAppearing];
    }
    
    // 显示通知
    [self.touchSignals emit:kSignalViewAppearing withResult:[NSNumber numberWithBool:animated]];
    [self onAppearing];

    // 通知到子一层
    NSSet* subcontrollers = self.allSubcontrollers;
    for (UIViewController* each in subcontrollers) {
        [each viewWillAppear:animated];
    }
    
    // 刷新ui
# ifdef IOS7_FEATURES
    UINavigationBar* navibar = [self.navigationController navigationBar];
    if (kIOS7Above && self.attributes.navigationBarTintColor && !self.attributes.previousNavigationBarTintColor)
    {
        self.attributes.previousNavigationBarTintColor = navibar.tintColor;
        navibar.tintColor = self.attributes.navigationBarTintColor;
    }
# endif
    
    // 调整边缘
    if ([self.viewForDodge isKindOfClass:[UIScrollView class]]) {
        UIScrollView* scroll = (id)self.viewForDodge;
        if (scroll.skipsNavigationBarInsetsAdjust)
            return;
        
        // 设置顶部的空间
        {
            UIEdgeInsets ei = scroll.edgeInsetsForNavigationBar;
            if (self.attributes.navigationBarDodge) {
                if (self.attributes.navigationBarHeight)
                    ei.top = self.attributes.navigationBarHeight.floatValue;
                else
                    ei.top = kUINavigationBarHeight;
                ei.top += kUIStatusBarHeight;
            }
            scroll.edgeInsetsForNavigationBar = ei;
        }
        
        // 设置底部的控件
        {
            if (self.tabBarController != nil) {
                UIEdgeInsets ei = scroll.edgeInsetsForTabBar;
                if (!self.hidesBottomBarWhenPushed && self.attributes.tabBarDodge) {
                    if (self.attributes.tabBarHeight)
                        ei.bottom = self.attributes.tabBarHeight.floatValue;
                    else
                        ei.bottom = kUITabBarHeight;
                }
                scroll.edgeInsetsForTabBar = ei;
            }
        }
        // 如果是第一次显示
        if (self.extension.countAppeared == 0) {
            // 需要偏移一下 y 方向的显示，以避让导航栏
            CGPoint offpt = scroll.contentOffset;
            offpt.y = -scroll.contentInset.top;
            scroll.contentOffset = offpt;
        }
    }
}

- (void)SWIZZLE_CALLBACK(appeared):(BOOL)animated {
    if (self.extension.appeared)
        return;
    
    LOG("%s (%s) 第 %d 次显示", object_getClassName(self), object_getClassName(self.view), self.extension.countAppeared);
    
    // 是否第一次显示
    if (self.extension.countAppeared == 0) {
        [self onFirstAppeared];
        [self.touchSignals emit:kSignalViewFirstAppear];
        [[UIKit shared].touchSignals emit:kSignalViewFirstAppear withResult:self];
    } else {
        [self onLaterAppeared];
    }
    
    // 显示通知
    [self.touchSignals emit:kSignalViewAppear withResult:[NSNumber numberWithBool:animated]];
    [self onAppeared];
    
    // 通知到子一层
    NSSet* subcontrollers = self.allSubcontrollers;
    for (UIViewController* each in subcontrollers) {
        [each viewDidAppear:animated];
    }
    
    // 计数器
    ++self.extension.countAppeared;
    self.extension.appeared = YES;
}

- (BOOL)isAppeared {
    return self.extension.appeared;
}

- (void)onFirstAppeared {
    PASS;
}

- (void)onFirstAppearing {
    PASS;
}

- (void)onLaterAppeared {
    PASS;
}

- (void)onLaterAppearing {
    PASS;
}

- (void)SWIZZLE_CALLBACK(disappearing):(BOOL)animated {
    if (!self.extension.appeared)
        return;
    
    [self onDisappearing];
    [self.touchSignals emit:kSignalViewDisappearing withResult:[NSNumber numberWithBool:animated]];
    
    NSSet* subcontrollers = self.allSubcontrollers;
    for (UIViewController* each in subcontrollers) {
        [each viewWillDisappear:animated];
    }
    
    // 还原ui
# ifdef IOS7_FEATURES
    UINavigationBar* navibar = [self.navigationController navigationBar];
    if (kIOS7Above && self.attributes.navigationBarTintColor && self.attributes.previousNavigationBarTintColor) {
        navibar.tintColor = self.attributes.previousNavigationBarTintColor;
        self.attributes.previousNavigationBarTintColor = nil;
    }
# endif
}

- (void)SWIZZLE_CALLBACK(disappeared):(BOOL)animated {
    if (!self.extension.appeared)
        return;
    
    [self.touchSignals emit:kSignalViewDisappear withResult:[NSNumber numberWithBool:animated]];
    [self onDisappeared];
    
    NSSet* subcontrollers = self.allSubcontrollers;
    for (UIViewController* each in subcontrollers) {
        [each viewDidDisappear:animated];
    }
    
    self.extension.appeared = NO;
}

static void(^__gs_navi_hook_naviitem)(UINavigationController*, UIViewController*, UINavigationItem*) = nil;

- (void)SWIZZLE_CALLBACK(navi_item):(UINavigationItem*)item {
    BOOL canOS = NavigationControllerCanOverrideSetting(self);
    if (canOS && __gs_navi_hook_naviitem)
    {
        id navi = self.navigationController;
        if (navi) {
            __gs_navi_hook_naviitem(navi, self, item);
            [self onNavigationItemUpdated];
        }
    }
}

- (void)onViewLayouting {
    PASS;
}

- (void)onViewLayout {
    PASS;
}

- (void)SWIZZLE_CALLBACK(will_layout) {
    [self onViewLayouting];
}

- (void)SWIZZLE_CALLBACK(did_layout) {
    [self onViewLayout];
}

- (void)onNavigationItemUpdated {
    PASS;
}

@end

@interface UIViewControllerExt ()

@property (nonatomic, assign) id customNavigationController;

@end

@implementation UIViewControllerExt

- (id)init {
    self = [super init];

    _subcontrollers = [[NSMutableSet alloc] init];
    self.classForView = [UIViewExt class];

# ifdef IOS7_FEATURES
    if (kIOS7Above) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
# endif
    
    [self onInit];
    return self;
}

- (void)dealloc {
    // 取消子vc的联系
    for (UIViewController* each in _subcontrollers) {
        each.superViewController = nil;
    }
    ZERO_RELEASE(_subcontrollers);
    
    // 取消view的联系
    if (self.isViewLoaded)
        self.view.belongViewController = nil;

    [self onFin];
    
    [super dealloc];
}

- (void)loadView {
    if (_classForView) {
        UIView* view = [[_classForView alloc] initWithZero];        
        self.view = view;
        SAFE_RELEASE(view);
        return;
    }
    
    [super loadView];
}

# ifdef IOS7_FEATURES

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [UIAppDelegate shared].preferredStatusBarStyle;
}

# endif

- (void)setWantsFullScreenLayout:(BOOL)wantsFullScreenLayout {
    [super setWantsFullScreenLayout:wantsFullScreenLayout];
    
    //有可能会引起navi提前被使用，所以不实现
    //if ([self.view respondsToSelector:@selector(setWantsFullScreenLayout:)]) {
    //    [self.view performSelector:@selector(setWantsFullScreenLayout:) withObject:@(wantsFullScreenLayout)];
    //}
    
# ifdef IOS7_FEATURES
    if (kIOS7Above) {
        self.edgesForExtendedLayout = UIRectEdgeAll;
        //self.automaticallyAdjustsScrollViewInsets = YES;
    }
# endif
}

- (void)didReceiveMemoryWarning {
    [self onMemoryWarning];
    [super didReceiveMemoryWarning];
}

- (void)addSubcontroller:(UIViewController *)ctlr {
    if ([self.subcontrollers containsObject:ctlr])
        return;
    ctlr.superViewController = self;
    [self.view addSubview:ctlr.view];
    [(NSMutableSet*)self.subcontrollers addObject:ctlr];
}

- (void)removeSubcontroller:(UIViewController *)ctlr {
    if (ctlr == nil)
        return;
    [ctlr.view removeFromSuperview];
    [(NSMutableSet*)self.subcontrollers removeObject:ctlr];
    ctlr.superViewController = nil;
}

- (void)assignSubcontroller:(UIViewController*)ctlr {
    if ([self.subcontrollers containsObject:ctlr])
        return;
    ctlr.superViewController = self;
    [(NSMutableSet*)self.subcontrollers addObject:ctlr];
}

- (void)unassignSubcontroller:(UIViewController*)ctlr {
    if (ctlr == nil)
        return;
    [(NSMutableSet*)self.subcontrollers removeObject:ctlr];
    ctlr.superViewController = nil;
}

- (UINavigationController*)navigationController {
    if (_customNavigationController)
        return _customNavigationController;
    if ((_customNavigationController = [super navigationController]))
        return _customNavigationController;
    if ((_customNavigationController = self.superViewController.navigationController))
        return _customNavigationController;
    if (self.isViewLoaded && (_customNavigationController = self.view.superview.navigationController))
        return _customNavigationController;
    return nil;
}

- (UINavigationController*)standardNavigationController {
    return [super navigationController];
}

- (void)setNavigationController:(UINavigationController *)navigationController {
    _customNavigationController = navigationController;
}

@end

@implementation UIScrollView (edgeinsets)

NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR_EXT(UIScrollView, edgeInsetsForNavigationBar, setEdgeInsetsForNavigationBar,
                                           UIEdgeInsets,
                                           ,[NSPadding paddingWithEdgeInsets:val], [self updateContentInset],
                                           [val edgeInsets],
                                           RETAIN_NONATOMIC);

NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR_EXT(UIScrollView, edgeInsetsForTabBar, setEdgeInsetsForTabBar,
                                           UIEdgeInsets,
                                           ,[NSPadding paddingWithEdgeInsets:val], [self updateContentInset],
                                           [val edgeInsets],
                                           RETAIN_NONATOMIC);

NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR_EXT(UIScrollView, edgeInsetsForHeaderAddition, setEdgeInsetsForHeaderAddition,
                                           UIEdgeInsets,
                                           ,[NSPadding paddingWithEdgeInsets:val], [self updateContentInset],
                                           [val edgeInsets],
                                           RETAIN_NONATOMIC);

NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR_EXT(UIScrollView, edgeInsetsForFooterAddition, setEdgeInsetsForFooterAddition,
                                           UIEdgeInsets,
                                           ,[NSPadding paddingWithEdgeInsets:val], [self updateContentInset],
                                           [val edgeInsets],
                                           RETAIN_NONATOMIC);

NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR_EXT(UIScrollView, edgeInsetsAddition, setEdgeInsetsAddition,
                                           UIEdgeInsets,
                                           ,[NSPadding paddingWithEdgeInsets:val], [self updateContentInset],
                                           [val edgeInsets],
                                           RETAIN_NONATOMIC);

NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR_EXT(UIScrollView, edgeInsetsForPull, setEdgeInsetsForPull,
                                           UIEdgeInsets,
                                           ,[NSPadding paddingWithEdgeInsets:val], [self updateContentInset],
                                           [val edgeInsets],
                                           RETAIN_NONATOMIC);

- (void)updateContentInset {
    UIEdgeInsets ei = UIEdgeInsetsZero;
    
    ei = UIEdgeInsetsAdd(ei, self.edgeInsetsForNavigationBar);
    ei = UIEdgeInsetsAdd(ei, self.edgeInsetsForTabBar);
    ei = UIEdgeInsetsAdd(ei, self.edgeInsetsForHeaderAddition);
    ei = UIEdgeInsetsAdd(ei, self.edgeInsetsForFooterAddition);
    ei = UIEdgeInsetsAdd(ei, self.edgeInsetsAddition);
    self.scrollIndicatorInsets = ei;
    
    // 不累加为了pull而添加的额外边距
    ei = UIEdgeInsetsAdd(ei, self.edgeInsetsForPull);
    self.contentInset = ei;
}

@end

@implementation UIScrollViewPullIdentifier

@synthesize toggleValue, workState, disabled;

- (void)setDisabled:(BOOL)val {
    disabled = val;
    self.hidden = val;
}

- (void)pullSizeNeedChanged:(CGSize)sz {
    PASS;
}

@end

@interface UIDripIdentifier ()

@property (nonatomic, readonly) UIDripRefresh *drip;

@end

@implementation UIDripIdentifier

- (void)onInit {
    [super onInit];
    
    _drip = [[UIDripRefresh alloc] initWithZero];
    [self addSubview:_drip];
    SAFE_RELEASE(_drip);
    
    [_drip.signals connect:kSignalValueChanged redirectTo:kSignalPullIdentifierToggled ofTarget:self];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalPullIdentifierToggled)
SIGNALS_END

- (void)pullSizeNeedChanged:(CGSize)sz {
    _drip.offset = sz.height;
    
    if (sz.height == 0)
        [_drip endRefreshing];
    
    [self setSize:sz];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    _drip.frame = rect;
}

@end

@interface UIPullFlushView () {
    BOOL _toggling;
}

@end

@implementation UIPullFlushView

SIGNALS_BEGIN
SIGNAL_ADD(kSignalPullIdentifierToggled)
SIGNALS_END

- (void)onInit {
    [super onInit];
    self.toggleValue = 75;
}

- (void)pullSizeNeedChanged:(CGSize)sz {
    [self setSize:sz];
    
    if (sz.height > self.toggleValue) {
        if (!_toggling) {
            _toggling = YES;
            [self.signals emit:kSignalPullIdentifierToggled];
        }
    } else {
        _toggling = NO;
    }
}

@end

@interface UIPullMoreView () {
    BOOL _toggling;
}

@end

@implementation UIPullMoreView

SIGNALS_BEGIN
SIGNAL_ADD(kSignalPullIdentifierToggled)
SIGNALS_END

- (void)onInit {
    [super onInit];
    self.toggleValue = 30;
    
    _labelText = [[UILabelExt alloc] initWithZero];
    [self addSubview:_labelText];
    SAFE_RELEASE(_labelText);

    _labelText.textAlignment = NSTextAlignmentCenter;
    _labelText.text = @"加载更多";
    _labelText.textColor = [UIColor grayColor];
    _labelText.textFont = [UIFont systemFontOfSize:14];
}

- (void)setLabelText:(UILabelExt *)labelText {
    if (_labelText == labelText)
        return;
    labelText.frame = _labelText.frame;
    [_labelText removeFromSuperview];
    _labelText = labelText;
    [self addSubview:_labelText];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    _labelText.frame = CGRectOffset(rect, 0, -8);
}

- (void)pullSizeNeedChanged:(CGSize)sz {
    [self setSize:sz];
    self.alpha = sz.height / self.toggleValue;
    
    if (sz.height > self.toggleValue) {
        if (!_toggling) {
            _toggling = YES;
            [self.signals emit:kSignalPullIdentifierToggled];
        }
    } else {
        _toggling = NO;
    }
}

- (CGFloat)dockedHeight {
    return MAX(self.frame.size.height, self.toggleValue);
}

- (BOOL)shouldAdjustPullInsets {
    return NO;
}

@end

@interface UIExtRefreshControlForPlullFlush : UIRefreshControl <UIScrollViewPullIdentifier> @end
@implementation UIExtRefreshControlForPlullFlush

SIGNALS_BEGIN
SIGNAL_ADD(kSignalPullIdentifierToggled)
SIGNALS_END

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self addTarget:self action:@selector(cbSysRefreshControlToggled) forControlEvents:UIControlEventValueChanged];
    return self;
}

- (void)dealloc {
    [self.signals disconnect];
    [self removeTarget:self action:@selector(cbSysRefreshControlToggled) forControlEvents:UIControlEventValueChanged];
    [super dealloc];
}

- (void)cbSysRefreshControlToggled {
    if (self.isRefreshing) {
        [self.signals emit:kSignalPullIdentifierToggled];
    }
}

@dynamic toggleValue;
@synthesize workState, disabled;

- (CGFloat)toggleValue {
    return 64;
}

- (void)pullSizeNeedChanged:(CGSize)sz {
    PASS;
}

- (void)setWorkState:(NSWorkState)val {
    workState = val;
    if (workState == kNSWorkStateDone && self.isRefreshing)
        [self endRefreshing];
}

- (void)setDisabled:(BOOL)v {
    disabled = v;
    if (self.isRefreshing)
        [self endRefreshing];
    self.hidden = v;
}

- (BOOL)shouldAdjustPullInsets {
    return NO;
}

@end

@implementation UIScrollView (extension)

SIGNALS_BEGIN

SIGNAL_ADD(kSignalScrolled)
SIGNAL_ADD(kSignalScrollingBegan)
SIGNAL_ADD(kSignalScrollingEnd)

SIGNAL_ADD(kSignalPullFlush)
SIGNAL_ADD(kSignalPullMore)

SIGNAL_ADD(kSignalAnimateScrolled)
SIGNAL_ADD(kSignalZoomed)
SIGNAL_ADD(kSignalDraggingBegin)
SIGNAL_ADD(kSignalDraggingEnd)
SIGNAL_ADD(kSignalDeceleratingBegin)
SIGNAL_ADD(kSignalDeceleratingEnd)
SIGNAL_ADD(kSignalZoomingBegin)
SIGNAL_ADD(kSignalZoomingEnd)
SIGNAL_ADD(kSignalScrolledToTop)

SIGNAL_ADD(kSignalWorkStateChanged)

SIGNALS_END

SHARED_IMPL;

NSOBJECT_DYNAMIC_PROPERTY_EXT(UIScrollView, identifierTop,, setIdentifierTop, {
    [self.identifierTop.signals disconnect:kSignalPullIdentifierToggled ofTarget:self];
    [self.identifierTop removeFromSuperview];
}, {
    [self directAddSubview:val];
    [((NSObject*)val).signals connect:kSignalPullIdentifierToggled withSelector:@selector(__scroll_identifier_flush_toggled:) ofTarget:self];
}, RETAIN_NONATOMIC);

NSOBJECT_DYNAMIC_PROPERTY_EXT(UIScrollView, identifierBottom,, setIdentifierBottom, {
    [self.identifierBottom.signals disconnect:kSignalPullIdentifierToggled ofTarget:self];
    [self.identifierBottom removeFromSuperview];
}, {
    [self directAddSubview:val];
    [((NSObject*)val).signals connect:kSignalPullIdentifierToggled withSelector:@selector(__scroll_identifier_more_toggled:) ofTarget:self];
}, RETAIN_NONATOMIC);

NSOBJECT_DYNAMIC_PROPERTY_DECL(UIScrollView, workState);

- (NSWorkState)workState {
    return [NSOBJECT_DYNAMIC_PROPERTY_GET(UIScrollView, workState) intValue];
}

- (void)setWorkState:(NSWorkState)workState {
    NSOBJECT_DYNAMIC_PROPERTY_SET(UIScrollView, workState, RETAIN_NONATOMIC, @(workState));
    [self.touchSignals emit:kSignalWorkStateChanged];
    [self __scroll_workstatement_changed];
}

NSOBJECT_DYNAMIC_PROPERTY_EXT(UIScrollView, placeholderView,, setPlaceholderView, {
    [self.placeholderView removeFromSuperview];
}, {
    [self directAddSubview:val];
    ((UIView*)val).userInteractionEnabled = NO;
    ((UIView*)val).hidden = YES;
}, RETAIN_NONATOMIC);

NSOBJECT_DYNAMIC_PROPERTY_EXT(UIScrollView, workingIdentifier,, setWorkingIdentifier, {
    [self.workingIdentifier removeFromSuperview];
}, {
    [self directAddSubview:val];
    ((UIView*)val).hidden = YES;
}, RETAIN_NONATOMIC);

NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR(UIScrollView, skipsNavigationBarInsetsAdjust, setSkipsNavigationBarInsetsAdjust, BOOL, @(val), [val boolValue], RETAIN_NONATOMIC);

- (void)directAddSubview:(UIView*)view {
    [self addSubview:view];
}

@dynamic contentHeight, contentWidth;

- (void)setContentHeight:(CGFloat)contentHeight {
    if (contentHeight < 0)
        contentHeight = 0;
    CGSize sz = self.contentSize;
    if (sz.height == contentHeight)
        return;
    sz.height = contentHeight;
    self.contentSize = sz;
}

- (CGFloat)contentHeight {
    return self.contentSize.height;
}

- (void)setContentWidth:(CGFloat)contentWidth {
    CGSize sz = self.contentSize;
    if (sz.width == contentWidth)
        return;
    sz.width = contentWidth;
    self.contentSize = sz;
}

- (CGFloat)contentWidth {
    return self.contentSize.width;
}

- (CGPoint)contentPosition {
    CGPoint pt = self.contentOffset;
    UIEdgeInsets is = self.contentInset;
    pt = UIEdgeInsetsInsetPoint(pt, is);
    return pt;
}

- (CGFloat)contentX {
    return self.contentPosition.x;
}

- (CGFloat)contentY {
    return self.contentPosition.y;
}

- (CGRect)availableBounds {
    CGSize cntrc = self.contentSize;
    CGSize rc = self.bounds.size;
    if (cntrc.width < rc.width)
        cntrc.width = rc.width;
    if (cntrc.height < rc.height)
        cntrc.height = rc.height;
    return CGRectMakeWithSize(cntrc);
}

- (CGFloat)contentOffsetX {
    return self.contentOffset.x;
}

- (CGFloat)contentOffsetY {
    return self.contentOffset.y;
}

- (void)setContentOffsetX:(CGFloat)contentOffsetX {
    CGPoint pt = self.contentOffset;
    pt.x = contentOffsetX;
    self.contentOffset = pt;
}

- (void)setContentOffsetY:(CGFloat)contentOffsetY {
    CGPoint pt = self.contentOffset;
    pt.y = contentOffsetY;
    self.contentOffset = pt;
}

- (void)setContentOffsetX:(CGFloat)contentOffsetX animated:(BOOL)animated {
    CGPoint pt = self.contentOffset;
    pt.x = contentOffsetX;
    [self setContentOffset:pt animated:animated];
}

- (void)setContentOffsetY:(CGFloat)contentOffsetY animated:(BOOL)animated {
    CGPoint pt = self.contentOffset;
    pt.y = contentOffsetY;
    [self setContentOffset:pt animated:animated];
}

- (CGRect)visibledBounds {
    CGRect rc = self.rectForLayout;
    return rc;
}

+ (BOOL)IsScrollIndicator:(UIView*)v {
    if ([v isKindOfClass:[UIImageView class]] == NO)
        return NO;
    UIImageView* imgv = (UIImageView*)v;
    UIImage* img = imgv.image;
    CGSize sz = img.size;
    if (kIOS7Above) {
        if (sz.width == 3.5f &&
            sz.height == 3.5f)
        {
            return YES;
        }
    } else {
        if (sz.width == 7.f &&
            sz.height == 7.f)
        {
            return YES;
        }
    }
    return NO;
}

static void (^__gs_uiscrollview_identifiertop_instance)(UIScrollView*) = nil;
static void (^__gs_uiscrollview_identifierbottom_instance)(UIScrollView*) = nil;

+ (void)SetIdentifierTopInstanceCallback:(void(^)(UIScrollView*))block {
    BLOCK_RETAIN(__gs_uiscrollview_identifiertop_instance, block);
}

+ (void)SetIdentifierBottomInstanceCallback:(void(^)(UIScrollView*))block {
    BLOCK_RETAIN(__gs_uiscrollview_identifierbottom_instance, block);
}

- (UIRefreshControl<UIScrollViewPullIdentifier>*)createSystemRefreshControl {
    UIExtRefreshControlForPlullFlush* rfh = [[UIExtRefreshControlForPlullFlush alloc] initWithZero];
    return [rfh autorelease];
}

- (UIDripIdentifier*)createCustomDrip {
    UIDripIdentifier* idr = [[UIDripIdentifier alloc] initWithFrame:CGRectMake(0, -80, 0, 80)];
    return [idr autorelease];
}

- (UIView<UIScrollViewPullIdentifier>*)createIdentifierTopView {
    UIView<UIScrollViewPullIdentifier>* ret = nil;
    // ios6 以上用系统控件，以下用自定义控件
    if (kIOS6Above)
        ret = [self createSystemRefreshControl];
    else
        ret = [self createCustomDrip];
    return ret;
}

- (UIView<UIScrollViewPullIdentifier>*)createIdentifierBottomView {
    UIPullMoreView* ret = [UIPullMoreView temporary];
    return ret;
}

- (void)signals:(NSObject *)object signalConnected:(NSString *)sig slot:(SSlot *)slot {
    [super signals:object signalConnected:sig slot:slot];
    
    if (sig == kSignalPullFlush && self.identifierTop == nil) {
        if (__gs_uiscrollview_identifiertop_instance)
            __gs_uiscrollview_identifiertop_instance(self);
        else
            self.identifierTop = [self createIdentifierTopView];
    }
    
    if (sig == kSignalPullMore && self.identifierBottom == nil) {
        if (__gs_uiscrollview_identifierbottom_instance)
            __gs_uiscrollview_identifierbottom_instance(self);
        else
            self.identifierBottom = [self createIdentifierBottomView];
    }
}

- (void)doScrollIdentifierProcess {
    // 调整位置
    CGRect const wrc = self.bounds;
    CGSize const szcnt = self.contentSize;
    UIEdgeInsets const ci = self.contentInset;
    UIEdgeInsets const pi = self.edgeInsetsForPull;
    UIEdgeInsets const ei = UIEdgeInsetsSub(ci, pi);

    BOOL enabledIdentifierTop = (self.identifierTop != nil) && !self.identifierTop.disabled;
    BOOL enabledIdentifierBottom = (self.identifierBottom != nil) && !self.identifierBottom.disabled && (szcnt.height > UIEdgeInsetsInsetRect(wrc, ci).size.height);
    if (enabledIdentifierTop || enabledIdentifierBottom)
    {
        CGPoint const ptoff = self.contentOffset;
        
        if (enabledIdentifierTop)
        {
            CGPoint const pos = UIEdgeInsetsInsetPoint(ptoff, ei);
            UIView<UIScrollViewPullIdentifier>* top = self.identifierTop;
            CGSize sz = CGSizeMake(wrc.size.width, -pos.y);
            if (sz.height >= 0)
            {
                [top pullSizeNeedChanged:sz];
                top.positionY = pos.y;
                [top bringUp];
            }
        }
        
        if (enabledIdentifierBottom)
        {
            UIView<UIScrollViewPullIdentifier>* bottom = self.identifierBottom;
            CGSize const szcnt = self.contentSize;
            CGSize sz = CGSizeMake(wrc.size.width, self.contentOffset.y + wrc.size.height - szcnt.height - ei.bottom);
            [bottom pullSizeNeedChanged:sz];
            bottom.positionY = szcnt.height;
            [bottom bringUp];
        }
    }
}

- (void)SWIZZLE_CALLBACK(didscroll) {
    // 得到滚动的位置
    CGPoint const pos = self.contentPosition;
    self.extension.preferredPositionTouched = [NSPoint point:pos];
    self.extension.positionScrolled = pos;
    
    // 处理 pull, 并且只能当是手动控制时才处理
    if (self.dragging || self.decelerating) {
        [self doScrollIdentifierProcess];
    }
    
    // 系统级信号
    [self.touchSignals emit:kSignalScrolled];
    [[UIScrollView shared].touchSignals emit:kSignalScrolled];
    
    self.extension.previousPositionScrolled = pos;
}

- (void)cancelDragging {
    self.panGestureRecognizer.enabled = NO;
    self.panGestureRecognizer.enabled = YES;
}

- (void)__scroll_identifier_flush_toggled:(SSlot*)s {
    if (self.workState != kNSWorkStateUnknown && self.workState != kNSWorkStateDone)
        return;
    self.workState = kNSWorkStateWaiting;
    self.identifierTop.workState = kNSWorkStateWaiting;
}

- (void)__scroll_identifier_more_toggled:(SSlot*)s {
    if (self.workState != kNSWorkStateUnknown && self.workState != kNSWorkStateDone)
        return;
    self.workState = kNSWorkStateWaiting;
    self.identifierBottom.workState = kNSWorkStateWaiting;
}

- (void)__scroll_identifier_toggled {
    if (self.identifierTop.workState == kNSWorkStateWaiting) {
        if (![self.identifierTop respondsToSelector:@selector(shouldAdjustPullInsets)] ||
            self.identifierTop.shouldAdjustPullInsets) {
            [UIView animateWithDuration:kCAAnimationDuration animations:^{
                CGFloat val = self.identifierTop.toggleValue;
                if ([self.identifierBottom respondsToSelector:@selector(dockedHeight)])
                    val = [self.identifierBottom dockedHeight];
                UIEdgeInsets ei = self.edgeInsetsForPull;
                ei.top = val;
                self.edgeInsetsForPull = ei;
            }];
        }
        
        self.identifierTop.workState = kNSWorkStateDoing;
        [self.signals emit:kSignalPullFlush];
    }
    
    if (self.identifierBottom.workState == kNSWorkStateWaiting) {
        if (![self.identifierBottom respondsToSelector:@selector(shouldAdjustPullInsets)] ||
            self.identifierBottom.shouldAdjustPullInsets) {
            [UIView animateWithDuration:kCAAnimationDuration animations:^{
                CGFloat val = self.identifierBottom.toggleValue;
                if ([self.identifierBottom respondsToSelector:@selector(dockedHeight)])
                    val = [self.identifierBottom dockedHeight];
                UIEdgeInsets ei = self.edgeInsetsForPull;
                ei.bottom = val;
                self.edgeInsetsForPull = ei;
            }];
        }
        
        self.identifierBottom.workState = kNSWorkStateDoing;
        [self.signals emit:kSignalPullMore];
    }
}

- (void)__scroll_workstatement_changed {
    if (self.workState == kNSWorkStateDone) {
        if (self.identifierTop.workState == kNSWorkStateDoing) {
            self.identifierTop.workState = kNSWorkStateDone;
            if (![self.identifierTop respondsToSelector:@selector(shouldAdjustPullInsets)] ||
                self.identifierTop.shouldAdjustPullInsets) {
                [UIView animateWithDuration:kCAAnimationDuration animations:^{
                    UIEdgeInsets ei = self.edgeInsetsForPull;
                    ei.top = 0;
                    self.edgeInsetsForPull = ei;
                }];
            }
        }
        if (self.identifierBottom.workState == kNSWorkStateDoing) {
            self.identifierBottom.workState = kNSWorkStateDone;
            if (![self.identifierBottom respondsToSelector:@selector(shouldAdjustPullInsets)] ||
                self.identifierBottom.shouldAdjustPullInsets) {
                [UIView animateWithDuration:kCAAnimationDuration animations:^{
                    UIEdgeInsets ei = self.edgeInsetsForPull;
                    ei.bottom = 0;
                    self.edgeInsetsForPull = ei;
                }];
            }
        }
        [self flashScrollIndicators];
    }
}

// 开始滚动
- (void)__scroll_scrolling_began {
    [self.touchSignals emit:kSignalScrollingBegan];
}

// 结束滚动
- (void)__scroll_scrolling_ended {
    [self.touchSignals emit:kSignalScrollingEnd];
}

- (void)SWIZZLE_CALLBACK(begindeceleration) {
    [self.touchSignals emit:kSignalDeceleratingBegin];
}

- (void)SWIZZLE_CALLBACK(stopdeceleration) {
    [self.touchSignals emit:kSignalDeceleratingEnd];
    
    // 处理标记动作，此处和 enddragging 同时都进行处理，为了避免 idr 激活的时机不同，导致不能正确激活刷新动作的问题
    [self __scroll_identifier_toggled];
    
    // 如果减速过程停止，并且当前没有拖拽，则判定为结束滚动
    if (!self.dragging)
        [self __scroll_scrolling_ended];
}

- (void)SWIZZLE_CALLBACK(begindragging) {
    kUIDragging = YES;
    
    // 拖动的时候关掉键盘
    if ([UIKeyboardExt shared].visible)
        [UIKeyboardExt Close];
    
    [self.touchSignals emit:kSignalDraggingBegin];
    [[UIScrollView shared].touchSignals emit:kSignalDraggingBegin];
    
    // 如果当前没有执行减速过程，则判定为开始滚动
    if (!self.decelerating)
        [self __scroll_scrolling_began];
}

- (void)SWIZZLE_CALLBACK(enddragging):(id)decerating {
    kUIDragging = NO;
    BOOL isDecerating = [decerating boolValue];

    // 处理标记动作
    [self __scroll_identifier_toggled];
    
    // 发出信号
    [self.touchSignals emit:kSignalDraggingEnd withResult:decerating];
    [[UIScrollView shared].touchSignals emit:kSignalDraggingEnd withResult:decerating];
    
    // 如果停止了拖动，并且没有减速的过程，则判定为滚动停止
    if (!isDecerating)
        [self __scroll_scrolling_ended];
}

- (void)SWIZZLE_CALLBACK(layout_subviews) {
    [super SWIZZLE_CALLBACK(layout_subviews)];
    
    CGRect rc = self.bounds;
    if (CGRectEqualToRect(rc, CGRectZero))
        return;
    
    if (self.placeholderView.visible)
    {
        self.placeholderView.frame = self.rectForPlaceholder;
        [self bringSubviewToFront:self.placeholderView];
    }
    
    if (self.workingIdentifier.visible)
    {
        self.workingIdentifier.frame = rc;
        [self bringSubviewToFront:self.workingIdentifier];
    }
}

- (CGRect)rectForPlaceholder {
    CGRect rc = self.rectForLayout;
    return rc;
}

- (CGRect)rectForLayout {
    CGRect rc = self.bounds;
    UIEdgeInsets ei = self.contentInset;
    rc = UIEdgeInsetsInsetRect(rc, ei);
    return rc;
}

- (BOOL)shouldShowPlaceholder {
    return YES;
}

- (UIView*)pagingAtViews:(UIView*)view, ... {
    va_list va;
    va_start(va, view);
    NSArray* arr = [NSArray arrayWithObjects:view arg:va];
    va_end(va);
    return [self pagingInViews:arr];
}

- (UIView*)pagingInViews:(NSArray*)views {
    CGRect rc = self.visibledBounds;
    CGPoint pt = CGRectCenter(rc);
    for (UIView* each in views) {
        CGRect rc = each.frame;
        if (CGRectContainsPoint(rc, pt))
            return each;
    }
    return nil;
}

@dynamic showsScrollIndicator;

- (void)setShowsScrollIndicator:(BOOL)showsScrollIndicator {
    self.showsHorizontalScrollIndicator = showsScrollIndicator;
    self.showsVerticalScrollIndicator = showsScrollIndicator;
}

- (BOOL)showsScrollIndicator {
    return self.showsHorizontalScrollIndicator || self.showsVerticalScrollIndicator;
}

- (void)cancelTouchs {
    BOOL os = self.scrollEnabled;
    self.scrollEnabled = NO;
    self.scrollEnabled = os;
}

@end

NSCLASS_SUBCLASS(UIExtScrollView_ContentView, UIViewExt);

@implementation UIScrollViewExt

// scrollview 采用内部嵌套一个 contentView 来解决 scrolling 时，频繁调用 layoutsubviews 的问题
/*
 需要解决如下问题：
 1，保证初始时的 content 的大小和 contentSize 以及 bounds 大小一致
 2，当 onlayout 调用后，业务层有可能修改了 contentSize ，此时需要同步修改 content 的大小，并且不能再次进入layout流程以避免死循环
 3，当 content 的大小存在，而业务层修改了 contentSize，需要同步修改 content 的大小，但是要避免问题 2 的死循环
 4，onlayout 需要由 content 来进行激发
 */

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    UIViewExt* tmp = [[UIExtScrollView_ContentView alloc] initWithZero];
    self.viewContent = tmp;
    SAFE_RELEASE(tmp);
    
    [self onInit];
    
    // 设置自身为 delegate 用以达到支持 signals 的目的
    self.delegate = self;
    
    return self;
}

- (void)dealloc {
    [self onFin];
    
    // 通过测试发现，位于 ARC 的语境下，如果不断掉 scrollview 的 signals，某些情况下会引发野指针的问题
    // 所以在这个地方保护一下
    [self.viewContent.signals disconnect];
    [self.touchSignals disconnect];
    
    [super dealloc];
}

- (void)setFrame:(CGRect)frame {
    frame = CGRectIntegralEx(frame);
    if (CGRectEqualToRect(self.frame, frame))
        return;
    
    // 设置修改后的大小
    [super setFrame:frame];
    
    // 刷新内容大小
    CGSize szbd = self.bounds.size;
    // 扣除避让掉了的大小
    UIEdgeInsets ei = self.contentInset;
    szbd = UIEdgeInsetsInsetSize(szbd, ei);
    // 设置到 contentSize
    self.contentSize = szbd;
}

- (void)setContentSize:(CGSize)contentSize {
    if (CGSizeEqualToSize(self.contentSize, contentSize))
        return;
    
    // 设置大小
    CGPoint offpt = self.contentOffset;
    [super setContentSize:contentSize];
    self.viewContent.size = contentSize;
    self.contentOffset = offpt;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 布局一下overlap
    [self.overlapWidget behalfView].frame = self.rectForOverlap;
    [[self.overlapWidget behalfView] bringUp];
}

@dynamic paddingEdge, offsetEdge;

- (void)setPaddingEdge:(CGPadding)paddingEdge {
    OBJC_NOEXCEPTION({
        ((id<UIViewEdge>)self.viewContent).paddingEdge = paddingEdge;
    });
}

- (CGPadding)paddingEdge {
    CGPadding ret = CGPaddingZero;
    OBJC_NOEXCEPTION({
        ret = ((id<UIViewEdge>)self.viewContent).paddingEdge;
    });
    return ret;
}

- (CGRect)rectForLayout {
    CGRect rc = self.bounds;
    UIEdgeInsets ei = self.contentInset;
    rc = UIEdgeInsetsInsetRect(rc, ei);
    CGPadding pad = self.paddingEdge;
    rc = CGRectApplyPadding(rc, pad);
    return rc;
}

- (void)setOffsetEdge:(CGPoint)offsetEdge {
    OBJC_NOEXCEPTION({
        ((id<UIViewEdge>)self.viewContent).offsetEdge = offsetEdge;
    });
}

- (CGPoint)offsetEdge {
    CGPoint ret = CGPointZero;
    OBJC_NOEXCEPTION({
        ret = ((id<UIViewEdge>)self.viewContent).offsetEdge;
    });
    return ret;
}

- (void)setViewContent:(UIView *)viewContent {
    if (_viewContent == viewContent)
        return;
    
    [_viewContent.signals disconnectToTarget:self];
    [_viewContent removeFromSuperview];
    
    _viewContent = viewContent;
    [self addSubview:_viewContent];
    
    // 设置大小
    _viewContent.size = self.contentSize;
    
    // 如果 content layout，则调用 onlayout 的回调处理
    [_viewContent.signals connect:kSignalLayout withSelector:@selector(__cbscroll_contentlayout:) ofTarget:self];
    
    // 点击 content 即为点击 scroll
    [_viewContent.signals connect:kSignalClicked redirectTo:kSignalClicked ofTarget:self];

    // 连接 relayout 的信号
    [_viewContent.signals connect:kSignalLayoutBegin redirectTo:kSignalLayoutBegin ofTarget:self];
    [_viewContent.signals connect:kSignalLayouting redirectTo:kSignalLayouting ofTarget:self];
    [_viewContent.signals connect:kSignalLayoutEnd redirectTo:kSignalLayoutEnd ofTarget:self];
}

- (void)__cbscroll_contentlayout:(SSlot*)s {
    NSRect* rc = (NSRect*)s.data.object;
    [self callOnLayout:rc.rect];
    
    CGSize sz = rc.size;
    // 扣回边缘占据的大小
    sz = CGSizeUnapplyPadding(sz, self.paddingEdge);
    
    // 如果大小发生变动，则重新刷一下contentsize
    if (CGSizeEqualToSize(sz, self.contentSize) == NO)
    {
        CGPoint offpt = self.contentOffset;

        // 但是不能引起重新设置content的大小，所以得调用父类的
        [super setContentSize:sz];
        
        self.contentOffset = offpt;
    }
}

- (void)setNeedsLayout {
    [super setNeedsLayout];
    [self.viewContent setNeedsLayout];
}

- (void)layoutIfNeeded {
    [super layoutIfNeeded];
    [self.viewContent layoutIfNeeded];
}

- (void)addSubview:(UIView *)view {
    if ([UIScrollView IsScrollIndicator:view]) {
        [super addSubview:view];
        return;
    }
    
    if (view == _viewContent) {
        [super addSubview:view];
    } else {
        [self.viewContent addSubview:view];
    }
}

- (void)insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview {
    if (siblingSubview == self.viewContent) {
        [super insertSubview:view aboveSubview:siblingSubview];
        return;
    }
    [self.viewContent insertSubview:view aboveSubview:siblingSubview];
}

- (void)insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview {
    if (siblingSubview == self.viewContent) {
        [super insertSubview:view belowSubview:siblingSubview];
        return;
    }
    [self.viewContent insertSubview:view belowSubview:siblingSubview];
}

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index {
    [self.viewContent insertSubview:view atIndex:index];
}

- (void)directAddSubview:(UIView *)view {
    [super addSubview:view];
}

- (CGSize)bestSize:(CGSize)sz {
    return [self.viewContent bestSize:sz];
}

// 回调信号

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self.touchSignals emit:kSignalZoomed];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self SWIZZLE_CALLBACK(didscroll)];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self SWIZZLE_CALLBACK(begindragging)];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self SWIZZLE_CALLBACK(enddragging):@(decelerate)];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self SWIZZLE_CALLBACK(begindeceleration)];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self SWIZZLE_CALLBACK(stopdeceleration)];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self.touchSignals emit:kSignalAnimateScrolled];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    [self.touchSignals emit:kSignalZoomingBegin];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [self.touchSignals emit:kSignalZoomingEnd];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [self.touchSignals emit:kSignalScrolledToTop];
}

@end

@interface UIExtScrollView_Scrollize : UIScrollViewExt

@property (nonatomic, retain) UIView *scrollizedView;

@end

@implementation UIExtScrollView_Scrollize

- (void)setScrollizedView:(UIView *)scrollizedView {
    [_scrollizedView removeFromSuperview];
    [_scrollizedView.signals disconnectToTarget:self];
    
    [self addSubview:scrollizedView];
    _scrollizedView = scrollizedView;
    
    // 如果产生了变化，则需要刷新下大小
    if ([_scrollizedView.signals hasSignal:kSignalValueChanged])
        [_scrollizedView.signals connect:kSignalValueChanged
                            withSelector:@selector(setNeedsLayout)
                                ofTarget:self];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    // 先支持垂直可变的，以后遇到业务了再去设计水平可变的问题
    rect.size.height = CGVALUEMAX;
    CGSize sz = [_scrollizedView bestSize:rect.size];
    rect.size = sz;
    _scrollizedView.frame = rect;
    
    self.contentHeight = rect.size.height;
}

- (CGSize)bestSize:(CGSize)sz {
    return [_scrollizedView bestSize:sz];
}

@end

@implementation UIScrollView (scrollize)

static NSString* kUIScrollizedViewKey = @"::ui::scrollizedview::key";
+ (UIScrollView*)scrollize:(UIView *)view {
    if ([view isKindOfClass:[UIScrollView class]])
        return (id)view;
    UIScrollView* v = [view.attachment.weak objectForKey:kUIScrollizedViewKey];
    if (v)
        return v;
    
    UIExtScrollView_Scrollize* scr = [UIExtScrollView_Scrollize temporary];
    [view.attachment.weak setObject:scr forKey:kUIScrollizedViewKey];
    scr.scrollizedView = view;
    return scr;
}

@end

@implementation UITableViewCell (extension)

- (id)initWithReuseIdentifier:(NSString *)ri {
    return [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ri];
}

- (NSIndexPath*)indexPath {
    UITableView* tbl = [self tableView];
    return [tbl indexPathForCell:self];
}

- (UITableView*)tableView {
    return (id)[self findSuperviewAsType:[UITableView class]];
}

+ (UITableView*)FindSuperTableView:(UIView*)obj {
    return (id)[obj findSuperviewAsType:[UITableView class]];
}

@end

@implementation UITableViewCellExt

+ (instancetype)CellFromView:(UIView *)view {
    return (id)[view findSuperviewAsType:[UITableViewCell class]];
}

- (id)initWithReuseIdentifier:(NSString *)ri {
    self = [super initWithReuseIdentifier:ri];

    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self onInit];
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleGray;

    [self onInit];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_viewController);

    [self onFin];
    [super dealloc];
}

@synthesize paddingEdge, offsetEdge;

SIGNALS_BEGIN
SIGNAL_ADD(kSignalConstraintChanged)
SIGNAL_ADD(kSignalSelected)
SIGNAL_ADD(kSignalDeselected)
SIGNALS_END

- (UIView*)behalfView {
    return self.view;
}

- (void)setViewController:(UIViewController *)viewController {
    self.view = viewController.view;
    PROPERTY_RETAIN(_viewController, viewController);
}

- (void)setView:(UIView *)view {
    if (_view == view)
        return;
    
    // 移除旧的
    [_view.signals disconnectToTarget:self];
    [_view removeFromSuperview];
    
    // 解绑旧的vc
    if (_viewController)
        ZERO_RELEASE(_viewController);
    
    // 设置新的
    if (view.superview != self) {
        [self.contentView addSubview:view];
    }
    _view = view;
        
    // 转移信号
    if ([_view.signals hasSignal:kSignalConstraintChanged]) {
        [_view.signals connect:kSignalConstraintChanged ofTarget:self];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rc = self.contentView.bounds;
    
    rc = CGRectApplyPadding(rc, self.paddingEdge);
    rc = CGRectApplyOffset(rc, self.offsetEdge);

    _view.frame = rc;
    [self callOnLayout:rc];
}

- (void)setFrame:(CGRect)frame {
    frame = CGRectIntegralEx(frame);
    
    id obj = self.tableView;
    if ([obj isKindOfClass:[UITableViewExt class]]) {
        UITableViewExt* tbl = (UITableViewExt*)obj;
        if (CGAffineTransformIsIdentity(tbl.transform) == NO) {
            CGRect rc = tbl.bounds;
            frame.size.width = rc.size.width;
        }
    }
    
    [super setFrame:frame];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (newSuperview == nil)
        return;
    
    id obj = [UITableViewCell FindSuperTableView:newSuperview];
    if ([obj isKindOfClass:[UITableViewExt class]]) {
        UITableViewExt* tbl = (UITableViewExt*)obj;
        if (CGAffineTransformIsIdentity(tbl.transform) == NO) {
            CGRect rc = tbl.bounds;
            CGRect frame = self.frame;
            frame.size.width = rc.size.width;
            [super setFrame:frame];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected) {
        [self onSelected];
        [self.touchSignals emit:kSignalSelected];
    } else {
        [self onDeselected];
        [self.touchSignals emit:kSignalDeselected];
    }
}

- (void)onSelected {
    PASS;
}

- (void)onDeselected {
    PASS;
}

- (void)updateData {
    [super updateData];
    [_view updateData];
}

- (void)setNeedsLayout {
    [super setNeedsLayout];
    [_view setNeedsLayout];
}

@end

@protocol UITableViewWrapperExt <NSObject>
- (void)onWrapperLayout:(CGRect)rect;
@end

@interface UITableViewWrapperExt : UIViewWrapper @end
@implementation UITableViewWrapperExt

- (void)onInit {
    [super onInit];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    if ([self.contentView respondsToSelector:@selector(onWrapperLayout:)])
        [(id<UITableViewWrapperExt>)self.contentView onWrapperLayout:rect];
}

- (CGSize)bestSize:(CGSize)sz {
    return self.bounds.size;
}

@end

@implementation UITableView (extension)

- (id)initWithStyle:(UITableViewStyle)style {
    self = [self initWithFrame:CGRectZero style:style];
    self.backgroundColor = [UIColor clearColor];
    return self;
}

- (CGSize)bestSize:(CGSize)sz {
    return self.bounds.size;
}

NSOBJECT_DYNAMIC_PROPERTY_DECL(UITableView, maxIndexPath);
NSOBJECT_DYNAMIC_PROPERTY_IMPL_GET(UITableView, maxIndexPath);

- (void)setMaxIndexPath:(NSIndexPath *)maxIndexPath {
    NSOBJECT_DYNAMIC_PROPERTY_SET(UITableView, maxIndexPath, COPY_NONATOMIC, maxIndexPath);
    self.placeholderView.visible = self.shouldShowPlaceholder;
}

NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR(UITableView, dockingSectionHeader, setDockingSectionHeader, BOOL, @(val), [val boolValue], RETAIN_NONATOMIC);
//NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR(UITableView, dockingSectionFooter, setDockingSectionFooter, BOOL, @(val), [val boolValue], RETAIN_NONATOMIC);

- (BOOL)shouldShowPlaceholder {
    // 如果没有ip并且当前的刷新状态不为 unknown
    if (self.workState == kNSWorkStateUnknown)
        return NO;
    
    // 从业务层获取
    id<UITableViewDelegateExt> dlg = (id)self.delegate;
    if ([dlg respondsToSelector:@selector(tableViewShouldShowPlaceholder:)])
        return [dlg tableViewShouldShowPlaceholder:self];
    
    return self.maxIndexPath == nil;
}

- (CGRect)rectForCells:(NSArray*)cells {
    CGRect sum = CGRectZero;
    for (uint i = 0; i < cells.count; ++i) {
        UITableViewCell* cell = [cells objectAtIndex:i];
        CGRect erc = [self rectForRowAtIndexPath:cell.indexPath];
        if (i == 0) {
            sum = erc;
        } else {
            sum = CGRectUnion(sum, erc);
        }
    }
    return sum;
}

- (CGRect)visibleRectForCells:(NSArray*)cells {
    CGRect rc = [self rectForCells:cells];
    
    CGFloat maxy = CGRectGetMaxY(rc);
    if (maxy > self.contentOffset.y &&
        rc.origin.y < self.contentOffset.y) {
        rc.size.height -= self.contentOffset.y - rc.origin.y;
        rc.origin.y = self.contentOffset.y;
    }
    
    CGFloat bdy = self.contentOffset.y + self.bounds.size.height;
    if (maxy > bdy) {
        rc.size.height -= maxy - bdy;
    }
    
    return rc;
}

- (CGRect)convertRect:(CGRect)rc clipAtSection:(NSUInteger)section {
    return [self convertRect:rc clipAtSection:section padding:CGPaddingZero];
}

- (CGRect)convertRect:(CGRect)rc clipAtSection:(NSUInteger)section padding:(CGPadding)padding {
    CGRect rcsecheader = [self rectForHeaderInSection:section];
    CGRect rcsecfooter = [self rectForFooterInSection:section];
    
    if (CGRectIntersectsRect(rc, rcsecheader))
    {
        CGFloat height = rc.size.height - (rcsecheader.origin.y - rc.origin.y + rcsecheader.size.height);
        if (height >= 0) {
            if (height >= padding.bottom) {
                rc.origin.y = CGRectGetMaxY(rcsecheader);
            } else {
                rc.origin.y = CGRectGetMaxY(rcsecheader) - (padding.bottom - height);
            }
            rc.size.height = height;
        } else {
            rc.size.height = 0;
        }
    }
    
    if (CGRectGetMaxY(rc) > rcsecfooter.origin.y) {
        rc.size.height -= CGRectGetMaxY(rc) - rcsecfooter.origin.y;
    }
    
    return rc;
}

- (NSIndexPath*)indexPathForViewItem:(UIView*)view {
    UITableViewCell* cell = [UITableViewCellExt CellFromView:view];
    return [self indexPathForCell:cell];
}

- (void)reloadCellForViewItem:(UIView*)view {
    NSIndexPath* ip = [self indexPathForViewItem:view];
    if (ip == nil) {
        WARN("期望 reload 的 cv 不属于这个 tableview");
        return;
    }
    
    [self reloadRowsAtIndexPaths:@[ip]];
}

- (void)refreshAppearedCells {
    [self beginUpdates];
    for (UIView* each in self.visibleCells) {
        [each updateData];
    }
    [self endUpdates];
}

NSOBJECT_DYNAMIC_PROPERTY_EXT(UITableView, tableFloatingHeaderView,, setTableFloatingHeaderView,
{
    UIView* old = self.tableFloatingHeaderView;
    if (old == val) {
        CGFloat height = [val frame].size.height;
        UIEdgeInsets ei = self.edgeInsetsForHeaderAddition;
        ei.top = height;
        self.edgeInsetsForHeaderAddition = ei;
        [self setNeedsLayout];
        return;
    }
    [old removeFromSuperview];
},
{
    [self.superview forceAddSubview:val];
    CGFloat height = [val frame].size.height;
    if (height == 0) {
        height = [val bestHeight];
        if (height)
            [val setHeight:height];
    }
    UIEdgeInsets ei = self.edgeInsetsForHeaderAddition;
    ei.top = height;
    self.edgeInsetsForHeaderAddition = ei;
    [self setNeedsLayout];
}, RETAIN_NONATOMIC);

NSOBJECT_DYNAMIC_PROPERTY_EXT(UITableView, tableFloatingFooterView,, setTableFloatingFooterView, {
    UIView* old = self.tableFloatingFooterView;
    if (old == val) {
        CGFloat height = [val frame].size.height;
        if (height == 0)
            height = [val bestHeight];
        UIEdgeInsets ei = self.edgeInsetsForFooterAddition;
        ei.bottom = height;
        self.edgeInsetsForFooterAddition = ei;
        [self setNeedsLayout];
        return;
    }
    [old removeFromSuperview];
},
{
    [self.superview forceAddSubview:val];
    CGFloat height = [val frame].size.height;
    if (height == 0) {
        height = [val bestHeight];
        if (height)
            [val setHeight:height];
    }
    UIEdgeInsets ei = self.edgeInsetsForFooterAddition;
    ei.bottom = height;
    self.edgeInsetsForFooterAddition = ei;
    [self setNeedsLayout];
}, RETAIN_NONATOMIC);

static NSString* kUITableViewStretchableHeaderHeightKey = @"::ui::tableview::header::stretchable::height";
NSOBJECT_DYNAMIC_PROPERTY_EXT(UITableView, tableStretchableHeaderView,, setTableStretchableHeaderView, {
    [self.tableStretchableHeaderView removeFromSuperview];
}, {
    CGFloat height = [val frame].size.height;
    [self.attachment.strong setObject:@(height) forKey:kUITableViewStretchableHeaderHeightKey];
    [self.superview forceAddSubview:val];
    [val sendBack];
}, RETAIN_NONATOMIC);

- (void)SWIZZLE_CALLBACK(layout_subviews) {
    [super SWIZZLE_CALLBACK(layout_subviews)];
    
    CGRect rc = self.rectForLayout;
    if (CGRectEqualToRect(rc, CGRectZero))
        return;
    
    // 调整一下显示
    [self updateAppearances];
    
    // 调用父类以发送信号
    [self doLayoutSubviews:rc];
}

- (void)setSectionTitleStyle:(UITextStyle *)sectionTitleStyle {
    if (!kIOS6Above)
        return;
    if (sectionTitleStyle.textColor)
        self.sectionIndexColor = sectionTitleStyle.textColor;
    if (sectionTitleStyle.backgroundColor)
        self.sectionIndexBackgroundColor = sectionTitleStyle.backgroundColor;
}

- (UITextStyle*)sectionTitleStyle {
    UITextStyle* ret = [UITextStyle temporary];
    ret.textColor = self.sectionIndexColor;
    ret.backgroundColor = self.sectionIndexBackgroundColor;
    return ret;
}

- (void)updateAppearances {
    // 调整一下floating的位置
    if (self.tableFloatingHeaderView &&
        ![NSMask Mask:UIViewAutolayoutNone Value:self.tableFloatingHeaderView.autolayoutMask])
    {
        CGRect rc = self.tableFloatingHeaderView.frame;
        rc.origin.y = self.edgeInsetsForNavigationBar.top;
        rc.size.width = self.contentWidth;
        
        CGFloat offy = self.contentY;
        if (offy >= 0)
            rc.origin.y -= offy;
        
        self.tableFloatingHeaderView.frame = rc;
    }
    
    if (self.tableFloatingFooterView &&
        ![NSMask Mask:UIViewAutolayoutNone Value:self.tableFloatingFooterView.autolayoutMask])
    {
        CGRect rc = self.tableFloatingFooterView.frame;
        rc.origin.y = self.tableFloatingFooterView.superview.bounds.size.height - rc.size.height;
        //rc.size.width = self.contentWidth;
        rc.size.width = self.tableFloatingFooterView.superview.bounds.size.width;
        self.tableFloatingFooterView.frame = rc;
    }
    
    // 调整一下stretch的位置
    if (self.tableStretchableHeaderView)
    {
        CGRect rc = self.tableStretchableHeaderView.frame;
        rc.size.width = self.contentWidth;
        rc.size.height = [[self.attachment.strong objectForKey:kUITableViewStretchableHeaderHeightKey] floatValue];
        
        CGFloat offy = self.contentY;        
        if (offy < 0) {
            rc.origin.y = 0;
            rc.size.height -= offy;
        } else {
            UIViewWrapper* vw = (UIViewWrapper*)self.superview;
            if (vw.paddingEdge.top) {
                CGFloat left = rc.size.height - kUINavigationBarDodgeHeight;
                if (offy > left)
                    offy = left;
            }
            rc.origin.y = -offy;
        }
        
        self.tableStretchableHeaderView.frame = rc;
    }

    // 调整 section 的位置
    NSUInteger const sections = self.numberOfSections;
    for (NSInteger idx = 0; idx < sections; ++idx)
    {
        UIView* vHeader = [self headerViewInSection:idx];
        if (self.dockingSectionHeader)
        {
            CGRect rcori = [self rectForHeaderInSection:idx];
            vHeader.position = rcori.origin;
        }
    }
}

- (CGFloat)headerSectionOffset {
    CGFloat ret = 0;
    with(self.tableFloatingHeaderView, {
        ret += self.edgeInsetsForNavigationBar.top;
        ret += self.edgeInsetsForHeaderAddition.top;
    });
    return ret;
}

- (UIView<UIScrollViewPullIdentifier>*)createIdentifierTopView {
    UIView<UIScrollViewPullIdentifier>* ret = nil;
    if (kIOS7Above ||
        (kIOS6Above && self.tableFloatingHeaderView == nil))
    {
        ret = [self createSystemRefreshControl];
    }
    else
    {
        ret = [self createCustomDrip];
    }
    return ret;
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths {
    [self deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)deleteSections:(NSIndexSet *)sections {
    [self deleteSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths {
    BOOL needreload = NO;
    for (NSIndexPath* ip in indexPaths) {
        int rows = [self.dataSource tableView:self numberOfRowsInSection:ip.section];
        if (rows <= 1) {
            needreload = YES;
            break;
        }
    }
    
    if (needreload == YES) {
        [self flushData];
        return;
    }
    
    [self insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)insertSections:(NSIndexSet *)sections {
    [self insertSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)reloadSections:(NSIndexSet *)sections {
    [self reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)reloadSection:(NSInteger)section {
    [self reloadSection:section withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)reloadSection:(NSInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    [self reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:animation];
}

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths {
    [self reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)scrollToSection:(NSInteger)section {
    [self scrollToSection:section atScrollPosition:UITableViewScrollPositionBottom];
}

- (void)scrollToSection:(NSInteger)section atScrollPosition:(UITableViewScrollPosition)scrollPosition {
    [self scrollToSection:section atScrollPosition:scrollPosition animated:YES];
}

- (void)scrollToSection:(NSInteger)section atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated {
    NSInteger const cntsections = self.numberOfSections;
    if (cntsections == 0 || section >= cntsections || section < 0)
        return;
    // 如果只有一个 section，则移动到出第一行
    if (cntsections == 1) {
        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                    atScrollPosition:scrollPosition
                            animated:animated];
        return;
    }
    // 如果位于最后一个 section，则偏移到最后一个 section 的第一行
    NSInteger const nxtsection = section + 1;
    if (nxtsection >= cntsections) {
        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]
                    atScrollPosition:scrollPosition
                            animated:animated];
        return;
    }
    // 偏移到下一行的第一行
    [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:nxtsection]
                atScrollPosition:scrollPosition
                        animated:animated];
}

- (UIView*)headerViewInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)])
        return [self.delegate tableView:self viewForHeaderInSection:section];
    return nil;
}

- (void)flushData {
    [self reloadData];
}

@end

CGFloat kUIIndexTitlesViewDefaultWidth = 20;

@interface UIIndexTitleLabel : UILabelExt
@end

@implementation UIIndexTitleLabel

- (void)onInit {
    [super onInit];
    self.textColor = [UIColor blackColor];
    self.textFont = [UIFont systemFontOfSize:12];
    self.textAlignment = NSTextAlignmentCenter;
}

@end

@interface UIIndexTitlesView ()
{
    int _lasttouched;
}

@property (nonatomic, readonly) NSMutableArray* titleViews;

@end

@implementation UIIndexTitlesView

- (void)onInit {
    [super onInit];
    _titleViews = [[NSMutableArray alloc] init];
    _lasttouched = -1;
    
    // changing 代表手指不离开的换选，changed代表手指离开的换选，一个需要不动画，一个需要动画
    //[self.signals connect:kSignalTouchesMoved withSelector:@selector(__indextitles_touchesmoved:) ofTarget:self];
    [self.signals connect:kSignalClicked withSelector:@selector(__indextitles_clicked:) ofTarget:self];
}

- (void)onFin {
    ZERO_RELEASE(_titleViews);
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalSelectionChanged)
SIGNAL_ADD(kSignalSelectionChanging)
SIGNALS_END

- (void)updateData {
    [super updateData];
    
    /* 流程
     1，清空老的tvs
     2，取得sections对应的string列表
     3，去获得section对应的type，并生成对应的view，并回调
     4，刷新布局
     */
    
    [self.titleViews removeAllObjects:^(id v) {
        [v removeFromSuperview];
    }];
    
    NSArray* titles = nil;
    if ([self.dataSource respondsToSelector:@selector(titlesForIndexTitlesView:)])
        titles = [self.dataSource titlesForIndexTitlesView:self];
    if (titles.count == 0)
        return;
    
    Class clsTv = [UIIndexTitleLabel class];
    BOOL customTv = [self.dataSource respondsToSelector:@selector(typeForSectionIndexTitlesView:forSection:)];
    BOOL customHeight = [self.dataSource respondsToSelector:@selector(heightForSectionIndexTitlesView:forSection:)];
    BOOL customInit = [self.dataSource respondsToSelector:@selector(sectionIndexTitlesView:titleView:title:forSection:)];
    [titles foreachWithIndex:^BOOL(id title, NSInteger idx) {
        Class tmpcls = clsTv;
        if (customTv)
            tmpcls = [self.dataSource typeForSectionIndexTitlesView:self forSection:idx];
        
        UIView* view = [tmpcls temporary];
        view.userInteractionEnabled = NO;
        [self addSubview:view];
        [_titleViews addObject:view];
        if (customInit) {
            [self.dataSource sectionIndexTitlesView:self titleView:view title:title forSection:idx];
        } else {
            UILabel* lbl = (UILabel*)view;
            OBJC_NOEXCEPTION(lbl.text = title);
        }
        [view updateData];
        
        CGFloat height = 0;
        if (customHeight)
            height = [self.dataSource heightForSectionIndexTitlesView:self forSection:idx];
        else
            height = view.bestHeight;
        view.height = height;
        
        return YES;
    }];
    
    [self setNeedsLayout];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox* box = [UIVBox boxWithRect:rect];
    [box addFlex:1 toView:nil];
    
    // 排列
    for (UIView* each in self.titleViews) {
        CGFloat height = each.frame.size.height;
        [box addPixel:height toView:each];
    }
    
    [box addFlex:1 toView:nil];
    [box apply];
    
    //self.contentHeight = box.position.y;
}

- (void)__indextitles_touchesmoved:(SSlot*)s {
    CGPoint pt = self.extension.positionTouched;
    // 判断点击的是哪个
    [self.titleViews foreachWithIndex:^BOOL(UIView* v, NSInteger idx) {
        CGRect fm = v.frame;
        if (CGRectContainsPoint(fm, pt)) {
            if (_lasttouched != idx) {
                _lasttouched = idx;
                [self.signals emit:kSignalSelectionChanging withResult:@(idx)];
            }
            return NO;
        }
        return YES;
    }];
}

- (void)__indextitles_clicked:(SSlot*)s {
    CGPoint pt = self.extension.positionTouched;
    // 判断点击的是哪个
    [self.titleViews foreachWithIndex:^BOOL(UIView* v, NSInteger idx) {
        CGRect fm = v.frame;
        if (CGRectContainsPoint(fm, pt)) {
            if (_lasttouched != idx) {
                _lasttouched = idx;
                [self.signals emit:kSignalSelectionChanged withResult:@(idx)];
            }
            return NO;
        }
        return YES;
    }];
}

@end

typedef enum {
    // 普通的cell
    kUITableViewCellSectionNormal,
    // 用cell装载的占位符
    kUITableViewCellSectionPlaceholder,
} UITableViewCellSectionType;

@interface UITableViewExt ()
<UITableViewDelegate>

// 提前计算尺寸所预先实现的cell对象，之后会在重用流程中被使用
@property (nonatomic, readonly) NSMutableDictionary *constraintCells;

// 计算好了的单元格尺寸，避免重复计算
@property (nonatomic, readonly) NSMutableDictionary *constraintSizes;

// 已经实例化好了的header和footer，避免多次重复计算
@property (nonatomic, readonly) NSMutableDictionary *storeHeaders, *storeFooters;

// 保存好上一步计算出来的尺寸，避免重复计算
@property (nonatomic, readonly) NSMutableDictionary *headerSizes, *footerSizes;

// 附加的辅助view
@property (nonatomic, readonly) NSMutableDictionary *assistViews;

@end

@implementation UITableViewExt

# define UITABLEVIEWEXT_COMMON_INIT \
_constraintCells = [[NSMutableDictionary alloc] init]; \
_constraintSizes = [[NSMutableDictionary alloc] init]; \
_storeHeaders = [[NSMutableDictionary alloc] init]; \
_storeFooters = [[NSMutableDictionary alloc] init]; \
_headerSizes = [[NSMutableDictionary alloc] init]; \
_footerSizes = [[NSMutableDictionary alloc] init]; \
_assistViews = [[NSMutableDictionary alloc] init]; \
self.separatorStyle = UITableViewCellSeparatorStyleNone; \
self.delegate = self; \
self.rowHeight = 0;

//_sectionFoldingPosition = CGPointZero; \

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    
    UITABLEVIEWEXT_COMMON_INIT;
    
    [self onInit];
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    UITABLEVIEWEXT_COMMON_INIT;
    
    [self onInit];
    return self;
}

- (void)dealloc {
    [self onFin];
    
    ZERO_RELEASE(_constraintCells);
    ZERO_RELEASE(_constraintSizes);
    ZERO_RELEASE(_storeHeaders);
    ZERO_RELEASE(_storeFooters);
    ZERO_RELEASE(_headerSizes);
    ZERO_RELEASE(_footerSizes);
    ZERO_RELEASE(_assistViews);
    
    self.delegate = nil;
    self.dataSource = nil;
    self.belongViewController = nil;
    self.tableHeaderView = nil;
    self.tableFooterView = nil;
    [super dealloc];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalSelected)
SIGNALS_END

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
}

- (void)setSectionIndexTitlesView:(UIIndexTitlesView *)sectionIndexTitlesView {
    if (_sectionIndexTitlesView == sectionIndexTitlesView)
        return;
    
    [_sectionIndexTitlesView.signals disconnect:kSignalSelectionChanging ofTarget:self];
    [_sectionIndexTitlesView.signals disconnect:kSignalSelectionChanged ofTarget:self];
    
    [_sectionIndexTitlesView removeFromSuperview];
    _sectionIndexTitlesView = sectionIndexTitlesView;
    [self.superview addSubview:_sectionIndexTitlesView];
    
    [_sectionIndexTitlesView.signals connect:kSignalSelectionChanging withSelector:@selector(__indextitles_selectchanging:) ofTarget:self];
    [_sectionIndexTitlesView.signals connect:kSignalSelectionChanged withSelector:@selector(__indextitles_selectchanged:) ofTarget:self];
    
    // 如果没有绑定datasource，但是tableView的dataSource实现了接口，则自动设置到tableView的dataSource上
    if (_sectionIndexTitlesView.dataSource == nil &&
        [self.dataSource conformsToProtocol:@protocol(UIIndexTitlesView)])
        _sectionIndexTitlesView.dataSource = (id)self.dataSource;
}

- (void)__indextitles_selectchanging:(SSlot*)s {
    // 滚动到对应的section
    NSInteger secid = [s.data.object integerValue];
    [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:secid]
                atScrollPosition:UITableViewScrollPositionTop
                        animated:NO];
}

- (void)__indextitles_selectchanged:(SSlot*)s {
    // 滚动到对应的section
    NSInteger secid = [s.data.object integerValue];
    [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:secid]
                atScrollPosition:UITableViewScrollPositionTop
                        animated:YES];
}

- (void)setTableFloatingHeaderView:(UIView *)tableFloatingHeaderView {
    // 需要保证高度不为0
    if (tableFloatingHeaderView.frame.size.height == 0) {
        if ([tableFloatingHeaderView conformsToProtocol:@protocol(UIConstraintView)])
            tableFloatingHeaderView.height = ((id<UIConstraintView>)tableFloatingHeaderView).constraintBounds.height;
        else
            tableFloatingHeaderView.height = tableFloatingHeaderView.bestHeight;
    }
    
    // 如果属于动态变高，则需要当约束变化时刷新重新设置一下啊
    if ([tableFloatingHeaderView conformsToProtocol:@protocol(UIConstraintView)]) {
        [tableFloatingHeaderView.signals connect:kSignalConstraintChanged withSelector:@selector(__cb_constraint_floatingheader_changed:) ofTarget:self];
    }
    
    // 设置，tableview的底层会自动设置ei
    [super setTableFloatingHeaderView:tableFloatingHeaderView];
}

- (void)__cb_constraint_floatingheader_changed:(SSlot*)s {
    UIView<UIConstraintView>* view = (id)s.sender;
    view.height = view.constraintBounds.height;
    self.tableFloatingHeaderView = view;
}

- (void)setTableFloatingFooterView:(UIView *)tableFloatingFooterView {
    // 需要保证高度不为0
    if (tableFloatingFooterView.frame.size.height == 0) {
        if ([tableFloatingFooterView conformsToProtocol:@protocol(UIConstraintView)])
            tableFloatingFooterView.height = ((id<UIConstraintView>)tableFloatingFooterView).constraintBounds.height;
        else
            tableFloatingFooterView.height = tableFloatingFooterView.bestHeight;
    }
    
    // 如果属于动态变高，则需要当约束变化时刷新重新设置一下啊
    if ([tableFloatingFooterView conformsToProtocol:@protocol(UIConstraintView)]) {
        [tableFloatingFooterView.signals connect:kSignalConstraintChanged withSelector:@selector(__cb_constraint_floatingfooter_changed:) ofTarget:self];
    }

    [super setTableFloatingFooterView:tableFloatingFooterView];
}

- (void)__cb_constraint_floatingfooter_changed:(SSlot*)s {
    UIView<UIConstraintView>* view = (id)s.sender;
    view.height = view.constraintBounds.height;
    self.tableFloatingFooterView = view;
}

- (void)setTableHeaderView:(UIView *)tableHeaderView {
    // 需要保证高度不为0
    if (tableHeaderView.frame.size.height == 0) {
        CGFloat h = kUIStatusBarHeight;
        if ([tableHeaderView conformsToProtocol:@protocol(UIConstraintView)])
            h += ((id<UIConstraintView>)tableHeaderView).constraintBounds.height;
        else
            h += tableHeaderView.bestHeight;
        if (self.belongViewController.hidesTopBarWhenPushed) {
            // 如果隐藏了导航栏，就需要规避一下电池栏
            if ([tableHeaderView isKindOfClass:[UIViewExt class]])
                ((UIViewExt*)tableHeaderView).paddingEdge = CGPaddingAdd(((UIViewExt*)tableHeaderView).paddingEdge, kUIStatusBarHeight, 0, 0, 0);
        }
        tableHeaderView.height = h;
    }
    
    // 如果属于动态变高，则需要当约束变化时刷新重新设置一下啊
    if ([tableHeaderView conformsToProtocol:@protocol(UIConstraintView)]) {
        [tableHeaderView.signals connect:kSignalConstraintChanged withSelector:@selector(__cb_constraint_header_changed:) ofTarget:self];
    }
    
    // 判断是否存在可以拉伸的部件
    if ([tableHeaderView conformsToProtocol:@protocol(UIStretchableView)]) {
        if ([tableHeaderView respondsToSelector:@selector(viewForStretchable)]) {
            id<UIStretchableView> v = (id<UIStretchableView>)tableHeaderView;
            UIView* sv = [v viewForStretchable];
            CGFloat h = [v heightForStretchable];
            UIViewWrapper* vw = (UIViewWrapper*)self.superview;
            h += vw.paddingEdge.top;
            sv.height = h;
            self.tableStretchableHeaderView = sv;
        }
    }
    
    // 设置，tableview的底层会自动设置ei
    [super setTableHeaderView:tableHeaderView];
}

- (void)__cb_constraint_header_changed:(SSlot*)s {
    UIView<UIConstraintView>* view = (id)s.sender;
    view.height = view.constraintBounds.height;
    self.tableHeaderView = view;
}

- (void)SWIZZLE_CALLBACK(layout_subviews) {
    [super SWIZZLE_CALLBACK(layout_subviews)];
}

- (void)onWrapperLayout:(CGRect)rect {
    // 设置placeholder
    if (CGAffineTransformEqualToTransform(self.transform, CGAffineTransformIdentity) == NO)  {
        CGAffineTransform mat = CGAffineTransformMakeRotation(M_PI_2);
        self.workingIdentifier.transform = mat;
        self.placeholderView.transform = mat;
    }
    
    // 调整sectionindex的位置
    if (self.sectionIndexTitlesView && self.sectionIndexTitlesView.dataSource) {
        CGFloat width = kUIIndexTitlesViewDefaultWidth;
        if ([self.sectionIndexTitlesView.dataSource respondsToSelector:@selector(widthForSectionIndexTitlesView:)])
            width = [self.sectionIndexTitlesView.dataSource widthForSectionIndexTitlesView:self.sectionIndexTitlesView];
        UIHBox* box = [UIHBox boxWithRect:rect];
        [box addFlex:1 toView:nil];
        [box addPixel:width toView:self.sectionIndexTitlesView];
        [box apply];
    }
}

- (UIView*)headerViewInSection:(NSInteger)section {
    UIView* v = [_storeHeaders objectForKey:@(section)];
    if (v == nil)
        v = [super headerViewInSection:section];
    return v;
}

/*
- (CGFloat)headerSectionOffset {
    CGFloat ret = 0;
    if (CGPointEqualToPoint(self.sectionFoldingPosition, CGPointZero) == NO) {
        ret = self.sectionFoldingPosition.y;
        if (kIOS7Above)
            ret += kUIStatusBarHeight;
    } else {
        ret = [super headerSectionOffset];
    }
    return ret;
}
 */

- (void)reloadData:(BOOL)flush {
    if (flush)
        [self flushData];
    else
        [self reloadData];
}

- (void)reloadData {
    self.maxIndexPath = nil;

    [super reloadData];
    
    // 需要刷新一下sectinIndexs
    if (self.sectionIndexTitlesView && self.sectionIndexTitlesView.visible) {
        [self.sectionIndexTitlesView updateData];
    }
}

- (void)flushData {
    self.maxIndexPath = nil;

    // 清空老的数据
    [_constraintSizes removeAllObjects];
    [_constraintCells removeAllObjects];
    [_headerSizes removeAllObjects];
    [_footerSizes removeAllObjects];
    
    // 重新加载全部
    [super flushData];
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    UITableViewCell* cell = [super dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [_constraintCells popQueObjectForKey:identifier];
    }
    return cell;
}

- (NSIndexPath*)indexPathForCell:(UITableViewCell *)cell {
    NSIndexPath* ip = [super indexPathForCell:cell];
    return ip;
}

- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [_constraintSizes removeObjectByKeyFilter:^BOOL(NSIndexPath* k) {
        return [sections containsIndex:k.section];
    }];
    
    [super deleteSections:sections withRowAnimation:animation];
}

- (void)reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [_constraintSizes removeObjectByKeyFilter:^BOOL(NSIndexPath* k) {
        return [sections containsIndex:k.section];
    }];

    [super reloadSections:sections withRowAnimation:animation];
}

- (void)moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    [_constraintSizes removeAllObjects];
    
    [super moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [_constraintSizes removeAllObjects];
    [super deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [_constraintSizes removeObjectsForKeys:indexPaths];
    [super reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [_constraintSizes removeAllObjects];
    [super insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [_constraintSizes removeAllObjects];
    [super insertSections:sections withRowAnimation:animation];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self performSelector:@selector(SWIZZLE_CALLBACK(didscroll))];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self performSelector:@selector(SWIZZLE_CALLBACK(begindragging))];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self performSelector:@selector(SWIZZLE_CALLBACK(enddragging):) withObject:@(decelerate)];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self performSelector:@selector(SWIZZLE_CALLBACK(begindeceleration))];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self performSelector:@selector(SWIZZLE_CALLBACK(stopdeceleration))];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.touchSignals emit:kSignalSelected withResult:indexPath];
}

- (NSArray*)visibleCellsInSection:(int)section {
    NSArray* cells = self.visibleCells;
    return [cells arrayWithCollector:^id(UITableViewCell* l) {
        NSIndexPath* ip = l.indexPath;
        if (ip.section != section)
            return nil;
        return l;
    }];
}

- (NSArray*)visibleItemsInSection:(int)section {
    return [[self visibleCellsInSection:section] arrayWithCollector:^id(UITableViewCellExt* l) {
        return l.view;
    }];
}

@end

@interface UITableViewNullCell : UITableViewCellExt @end
@implementation UITableViewNullCell @end

@interface UITableViewControllerExt ()
<UITableViewDataSource, UITableViewDelegate>
@end

@implementation UITableViewControllerExt

@synthesize tableView = _tableView;

- (void)onInit {
    [super onInit];
    _tableViewStyle = UITableViewStylePlain;
    //_horizon = NO;
    self.classForView = nil;
}

- (void)onFin {
    [super onFin];
}

- (CGPadding)paddingEdge {
    return ((UIViewWrapper*)self.view).paddingEdge;
}

- (void)setPaddingEdge:(CGPadding)paddingEdge {
    ((UIViewWrapper*)self.view).paddingEdge = paddingEdge;
}

SIGNALS_BEGIN

// 用来当 cell 显示、隐藏时抛出该 cell
SIGNAL_ADD(kSignalVisibleChanged)

SIGNALS_END

- (void)loadView {
    if (self.classForView) {
        [super loadView];
    } else {
        self.view = BLOCK_RETURN({
            _tableView = [[UITableViewExt alloc] initWithStyle:_tableViewStyle];
            UITableViewWrapperExt* vw = [UITableViewWrapperExt wrapperWithView:_tableView];
            SAFE_RELEASE(_tableView);
            vw.ignoreContentViewTransform = _horizon == YES;
            return vw;
        });
    }
    
    id v = self.view;
    if ([v isKindOfClass:[UITableViewExt class]])
        _tableView = (UITableViewExt*)v;
    else
        _tableView = self.tableView;
    
    if (_tableView == nil) {
        WARN("没有设置正确的 UITableViewExt 对象");
        return;
    }
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.placeholderView.hidden = YES;
    _tableView.belongViewController = self;
    
    if (_horizon) {
        _tableView.transform = CGAffineTransformMakeRotation(-M_PI_2);
        _tableView.autoresizesSubviews = NO;
        _tableView.showsHorizontalScrollIndicator = _tableView.showsVerticalScrollIndicator = NO;
    }
    
    _tableView.frame = CGRectZero;
}

- (UITableViewExt*)tableView {
    if (_tableView == nil) {
        [self view]; // 加载view，以保证 tableview 不是空的
    }
    return _tableView;
}

- (void)reloadTable:(BOOL)flush {
    self.tableView.workState = kNSWorkStateDone;
    [self.tableView reloadData:flush];
}

- (void)reloadTable {
    [self reloadTable:NO];
}

- (void)flushTable {
    [self reloadTable:YES];
}

- (void)scrollToView:(UIView*)v alignView:(UIView*)av animated:(BOOL)animated {
    CGRect rcv = self.view.frame;
    CGRect rct = [self.tableView convertRect:v.bounds fromView:v];
    CGRect rck = av.bounds;
    CGFloat y = (rck.size.height + CGRectGetMaxY(rct)) - rcv.size.height;
    
    // 如果需要向下滚动，会和超拉刷新产生干扰，此时调整为滚动到起始点
    if (y < 0)
        return;
    
    [self.tableView setContentOffsetY:y animated:animated];
}

- (void)didReceiveMemoryWarning {
    [self onMemoryWarning];
    [super didReceiveMemoryWarning];
}

- (BOOL)checkIndexPathIsPlaceholder:(NSIndexPath*)ip {
    // 如果ip 的行 > 0，则必定不会是占位
    if (ip.row > 0)
        return NO;
    id<UITableViewDataSourceExt, UITableViewDataSource> ds = (id)_tableView.dataSource;
    NSInteger rowscnt = [ds tableView:_tableView numberOfRowsInSection:ip.section];
    // 如果当前显示的是占位符，那么 rowscnt 必然 = 1，所以大于1的都不会是显示占位符
    if (rowscnt > 1)
        return NO;
    NSInteger normalrowscnt = [ds tableViewExt:_tableView numberOfRowsInSection:ip.section];
    // 如果当前显示的是占位符，那么实际的行数 = 0, 所有行数 = 1
    return rowscnt == 1 && normalrowscnt == 0;
}

- (CGFloat)tableView:(UITableViewExt *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 使用标准流程获得高度
    id<UITableViewDataSourceExt> ds = (id<UITableViewDataSourceExt>)self.tableView.dataSource;

    // 如果是占位符，则直接返回占位符的高度
    if ([self checkIndexPathIsPlaceholder:indexPath]) {
        return [ds tableViewExt:tableView heightForPlaceholderInSection:indexPath.section];
    }

    // 返回普通 cell 的高度
    return [ds tableViewExt:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableViewExt:(UITableViewExt*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.rowHeight)
        return tableView.rowHeight;
    
    NSIndexPath* ip = [indexPath clone];
    
    // 如果已经存在计算好的大小，则直接使用
    NSSize* sz = [tableView.constraintSizes objectForKey:ip];
    if (sz)
        return sz.height;

    // 否则通过cell来计算应该有的高度
    id<UITableViewDataSourceExt, UITableViewDataSource> ds = (id)self.tableView.dataSource;
    UITableViewCell* cell = nil;
    cell = [ds tableView:tableView cellForRowAtIndexPath:ip];
    if ([cell isKindOfClass:[UITableViewNullCell class]])
        return 0;
    
    if (cell.reuseIdentifier) {
        if ([tableView.constraintCells existsQueObject:cell forKey:cell.reuseIdentifier] == NO)
            [tableView.constraintCells pushQueObject:cell forKey:cell.reuseIdentifier];
    }
    
    CGFloat ret = 0;
    if ([cell isKindOfClass:[UITableViewCellExt class]])
    {
        UITableViewCellExt* cellext = (id)cell;
        
        // 如果属于根据约束自动调整大小的
        if ([cellext.view conformsToProtocol:@protocol(UIConstraintView)])
        {
            // 强制数据模式
            DATA_ONLY_MODE = YES;
            
            // 保护大小以避免计算出错的问题
            CGRect defrc = cell.frame;
            defrc.size.width = tableView.bounds.size.width;
            if (defrc.size.width == 0) {
                DATA_ONLY_MODE = NO;
                return 0;
            }
            if (defrc.size.height == 0)
                defrc.size.height = 568;
            cell.frame = defrc;
            
            // 需要强制刷新一下数据，才能获得正确的大小
            [cell updateData];
            
            // 保护处理一下第一个cell，以初始化子控件的大小
            if (cellext.isReused == NO) {
                [cell layoutSubviews];
                if (cell.behalfView != cell)
                    [cell.behalfView layoutSubviews];
            }
            
            // 调整大小
            [cell layoutSubviews];
            if (cell.behalfView != cell)
                [cell.behalfView layoutSubviews];
            
            // 恢复UI模式
            DATA_ONLY_MODE = NO;
            
            // 计算并写入约束大小
            sz = [NSSize size:[(UIConstraintView*)cell.behalfView constraintBounds]];
        }
        else
        {
            sz = [NSSize size:[cell.behalfView bestSize]];
        }
        
        if (sz.height) {
            sz.height += CGPaddingHeight(cellext.paddingEdge);
            ret = sz.height;
        }
        
        // 保存到重用中，第二次就不需要再计算
        if ([cellext.view conformsToProtocol:@protocol(UIConstraintView)])
            [tableView.constraintSizes setObject:sz forKey:ip];
    }
    
    return ret;
}

- (void)__cell_constraint_changed:(SSlot*)s {
    UITableViewCellExt* cell = (UITableViewCellExt*)s.sender;
    NSIndexPath* ip = cell.indexPath;
    if (ip == nil)
        return;
    
    // 删除历史大小
    [self.tableView.constraintSizes removeObjectForKey:ip];
    
    // 刷新
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (UITableViewCell*)tableView:(UITableViewExt*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableViewExt:tableView cellForRowAtIndexPath:indexPath];
}

- (Class)tableViewExt:(UITableViewExt*)tableView itemClassForRowAtIndexPath:(NSIndexPath*)indexPath {
    return self.classForItem;
}

- (UITableViewCell*)tableViewExt:(UITableViewExt *)tableView makeCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (UITableViewCell*)tableViewExt:(UITableViewExt*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCellExt* cell = nil;
    id<UITableViewDataSourceExt> ds = (id)tableView.dataSource;
    id<UITableViewDelegateExt> dl = (id)tableView.delegate;
    
    // 实例化 cell
    Class cls4item = nil;
    
    // 如果是占位符，则使用占位符的类型，否则使用 CV 的类型
    if ([self checkIndexPathIsPlaceholder:indexPath])
    {
        cls4item = [ds tableViewExt:tableView placeholderClassInSection:indexPath.section];
        if (cls4item == nil)
        {
            FATAL("TableView 返回了一个 空的 cell-placeholder 类型");
        }
        else
        {
            NSString* cellIdentifier = NSStringFromClass(cls4item);
            UITABLEVIEWCELLEXT_MAKECELL_EXT2(cls4item, UIView, cellIdentifier);
            
            if ([dl respondsToSelector:@selector(tableViewExt:placeholder:inSection:)]) {
                [dl tableViewExt:tableView placeholder:cv inSection:indexPath.section];
            }
        }
    }
    else
    {
        cls4item = self.classForItem;
        if ([ds respondsToSelector:@selector(tableViewExt:itemClassForRowAtIndexPath:)])
            cls4item = [ds tableViewExt:tableView
             itemClassForRowAtIndexPath:indexPath];
        
        // 根据类型实例化 cell
        if (cls4item)
        {
            NSString* cellIdentifier = NSStringFromClass(cls4item);
            UITABLEVIEWCELLEXT_MAKECELL_EXT2(cls4item, UIView, cellIdentifier);
        }
        else
        {
            if ([ds respondsToSelector:@selector(tableViewExt:makeCellForRowAtIndexPath:)]) {
                cell = (id)[ds tableViewExt:tableView
                  makeCellForRowAtIndexPath:indexPath];
            }
        }
        if ([dl respondsToSelector:@selector(tableViewExt:cell:item:atIndexPath:)]) {
            [dl tableViewExt:tableView
                        cell:cell
                        item:cell.view
                 atIndexPath:indexPath];
        }
        
        // 如果是新建的cv 并且支持自动匹配大小
        if (cell.isReused == NO && [cell.view conformsToProtocol:@protocol(UIConstraintView)]) {
            [cell.signals connect:kSignalConstraintChanged withSelector:@selector(__cell_constraint_changed:) ofTarget:self];
        }
    }
    
    if (cell == nil) {
        INFO("TableView 返回了一个 空的 cell 对象");
        cell = [UITableViewNullCell temporary];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath* ip = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    
    // 如果是横向
    if (_horizon)
        cell.contentView.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    // 刷新数据
    [cell updateData];
    //[cell setNeedsLayout];
    
    // 发出现实改变的信号
    [cell.touchSignals emit:kSignalVisibleChanged];
    if (cell.behalfView != cell)
        [cell.behalfView.touchSignals emit:kSignalVisibleChanged];
    [self.touchSignals emit:kSignalVisibleChanged withResult:cell];
    
    // 设置最大的
    if (tableView.maxIndexPath == nil ||
        (ip.section >= tableView.maxIndexPath.section &&
         ip.row >= tableView.maxIndexPath.row))
    {
        tableView.maxIndexPath = ip;
    }
}

- (void)tableView:(UITableViewExt*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PASS;
}

- (Class)tableViewExt:(UITableViewExt *)tableView viewClassForSectionHeaderInSection:(NSInteger)section {
    return [UIViewExt class];
}

- (Class)tableViewExt:(UITableViewExt *)tableView viewClassForSectionFooterInSection:(NSInteger)section {
    return [UIViewExt class];
}

- (UIView*)tableView:(UITableViewExt*)tableView viewForHeaderInSection:(NSInteger)section {
    id<UITableViewDataSourceExt> ds = (id)tableView.dataSource;
    id<UITableViewDelegateExt> dl = (id)tableView.delegate;
    
    // 如果不存在，则需要实例化 header
    UIView* v = [tableView.storeHeaders objectForKey:@(section)];
    if (v == nil) {
        Class cls = [ds tableViewExt:tableView viewClassForSectionHeaderInSection:section];
        if (cls == nil)
            return nil;
        v = [cls temporary];
        [tableView.storeHeaders setObject:v forKey:@(section)];
    }
    
    // 刷新数据
    if ([dl respondsToSelector:@selector(tableViewExt:header:inSection:)])
        [dl tableViewExt:tableView header:v inSection:section];
    [v updateData];
    
    return v;
}

- (UIView*)tableView:(UITableViewExt*)tableView viewForFooterInSection:(NSInteger)section {
    id<UITableViewDataSourceExt> ds = (id)tableView.dataSource;
    id<UITableViewDelegateExt> dl = (id)tableView.delegate;
    
    // 如果不存在，则需要实例化 footer
    UIView* v = [tableView.storeFooters objectForKey:@(section)];
    if (v == nil) {
        Class cls = [ds tableViewExt:tableView viewClassForSectionFooterInSection:section];
        if (cls == nil)
            return nil;
        v = [cls temporary];
        [tableView.storeFooters setObject:v forKey:@(section)];
    }
    
    // 刷新数据
    if ([dl respondsToSelector:@selector(tableViewExt:footer:inSection:)])
        [dl tableViewExt:tableView footer:v inSection:section];
    [v updateData];
    
    return v;
}

- (NSInteger)tableView:(UITableViewExt *)tableView numberOfRowsInSection:(NSInteger)section {
    // 通过回调决定
    NSInteger ret = [self tableViewExt:tableView numberOfRowsInSection:section];
    
    // 判断有没有 placeholder
    if (ret == 0 &&
        [self tableViewExt:tableView placeholderClassInSection:section] &&
        [self tableViewExt:tableView shouldShowPlaceholderInSection:section])
    {
        ret += 1;
    }
    
    return ret;
}

- (NSInteger)tableViewExt:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger ret = [self numberOfSectionsInTableViewExt:tableView];
    return ret;
}

- (NSInteger)numberOfSectionsInTableViewExt:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableViewExt *)tableView heightForHeaderInSection:(NSInteger)section {
    // 采用可变的机制来处理
    NSSize* sz = [tableView.headerSizes objectForKey:@(section)];
    if (sz != nil)
        return sz.height;
    
    // 返回的类如果支持动态大小，则计算，否则使用标准流程处理
    Class hcls = [self tableViewExt:tableView viewClassForSectionHeaderInSection:section];
    if (class_conformsToProtocol(hcls, @protocol(UIConstraintView)))
    {
        // 如果当前tableview同样没有尺寸，则跳过
        CGSize tblsz = tableView.bounds.size;
        if (tblsz.width == 0)
            return 0;
        
        UIView<UIConstraintView>* hv = (id)[self tableView:tableView viewForHeaderInSection:section];
        // 强制宽度、计算大小
        [hv setWidth:tblsz.width];
        [hv layoutSubviews];
        sz = [NSSize size:[hv constraintBounds]];
        // 保存
        [tableView.headerSizes setObject:sz forKey:@(section)];
        return sz.height;
    }
    
    return [self tableViewExt:tableView heightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableViewExt *)tableView heightForFooterInSection:(NSInteger)section {
    // 采用可变的机制来处理
    NSSize* sz = [tableView.footerSizes objectForKey:@(section)];
    if (sz != nil)
        return sz.height;
    
    // 返回的类如果支持动态大小，则计算，否则使用标准流程处理
    Class hcls = [self tableViewExt:tableView viewClassForSectionFooterInSection:section];
    if (class_conformsToProtocol(hcls, @protocol(UIConstraintView)))
    {
        // 如果当前tableview同样没有尺寸，则跳过
        CGSize tblsz = tableView.bounds.size;
        if (tblsz.width == 0)
            return 0;
        
        UIView<UIConstraintView>* hv = (id)[self tableView:tableView viewForFooterInSection:section];
        // 强制宽度、计算大小
        [hv setWidth:tblsz.width];
        [hv layoutSubviews];
        sz = [NSSize size:[hv constraintBounds]];
        // 保存
        [tableView.footerSizes setObject:sz forKey:@(section)];
        return sz.height;
    }
    
    return [self tableViewExt:tableView heightForFooterInSection:section];
}

- (CGFloat)tableViewExt:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableViewExt:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (Class)tableViewExt:(UITableViewExt*)tableView placeholderClassInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableViewExt:(UITableViewExt*)tableView heightForPlaceholderInSection:(NSInteger)section {
    Class cls = [self tableViewExt:tableView placeholderClassInSection:section];
    return TRIEXPRESS(cls, [cls BestHeight], 0);
}

- (BOOL)tableViewExt:(UITableViewExt*)tableView shouldShowPlaceholderInSection:(NSInteger)section {
    return tableView.workState != kNSWorkStateUnknown;
}

- (void)tableView:(UITableViewExt*)tableView placeholder:(UIView*)view inSection:(NSInteger)section {
    PASS;
}

// tableview-scrollview delegate.

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.tableView performSelector:@selector(SWIZZLE_CALLBACK(didscroll))];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.tableView performSelector:@selector(SWIZZLE_CALLBACK(begindragging))];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.tableView performSelector:@selector(SWIZZLE_CALLBACK(enddragging):) withObject:@(decelerate)];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self.tableView performSelector:@selector(SWIZZLE_CALLBACK(begindeceleration))];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.tableView performSelector:@selector(SWIZZLE_CALLBACK(stopdeceleration))];
}

@end

// 6.0 以上就可以使用 collectionview

@implementation UICollectionViewCellExt

@synthesize paddingEdge, offsetEdge;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self onInit];
    return self;
}

- (void)dealloc {
    [self onFin];
    [super dealloc];
}

- (void)setView:(UIView *)view {
    if (_view == view)
        return;
    
    // 移除旧的
    [_view removeFromSuperview];
    
    // 添加新的
    if (view.superview != self) {
        [self.contentView addSubview:view];
    }
    _view = view;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rc = self.contentView.bounds;
    
    rc = CGRectApplyPadding(rc, self.paddingEdge);
    rc = CGRectApplyOffset(rc, self.offsetEdge);
    
    _view.frame = rc;
    [self callOnLayout:rc];
}

- (void)updateData {
    [super updateData];
    [_view updateData];
}

- (void)setNeedsLayout {
    [super setNeedsLayout];
    [_view setNeedsLayout];
}

@end

@interface UICollectionViewExt ()

// 用以保存已经注册的类
@property (nonatomic, readonly) NSMutableDictionary* mpItemClasses;

// 用以复用的view对象
@property (nonatomic, readonly) NSMutableDictionary* mpReuseItems;

@end

@implementation UICollectionViewExt

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    self.backgroundColor = [UIColor clearColor];

    _mpItemClasses = [[NSMutableDictionary alloc] init];
    _mpReuseItems = [[NSMutableDictionary alloc] init];
    
    self.allowsSelection = NO;
    
    [self onInit];
    return self;
}

- (void)dealloc {
    [self onFin];
    
    ZERO_RELEASE(_mpItemClasses);
    ZERO_RELEASE(_mpReuseItems);
    [super dealloc];
}

// 注册实用类
- (NSString*)registerItemClass:(Class)cls {
    NSString* clsnm = NSStringFromClass(cls);
    if ([_mpItemClasses exists:clsnm])
        return clsnm;
    [_mpItemClasses setObject:[NSClass object:cls] forKey:clsnm];
    [self registerClass:[UICollectionViewCellExt class] forCellWithReuseIdentifier:clsnm];
    return clsnm;
}

// 获得到指定的对象
- (UIViewWrapper*)dequeueItemView:(NSString*)idr {
    UIViewWrapper* cv = [_mpReuseItems popQueObjectForKey:idr];
    if (cv != nil)
        return cv;
    NSClass* cls = [_mpItemClasses objectForKey:idr];
    if (cls) {
        cv = [UIViewWrapper wrapperWithView:[cls.classValue temporary]];
    }
    return cv;
}

@end

@interface UIConstraintCollectionViewLayout ()
{
    CGPoint _position;
}

@property (nonatomic, retain) NSArray* allAttributes;
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, retain) UIDynamicAnimator *dynAnimator;

@end

CGFloat kUICollectionVewDefaultResistance = 900.f;

@implementation UIConstraintCollectionViewLayout

- (id)init {
    self = [super init];
    
    if (kIOS7Above)
        _dynAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    _resistance = kUICollectionVewDefaultResistance;
    
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_dynAnimator);
    ZERO_RELEASE(_allAttributes);
    [super dealloc];
}

- (void)prepareLayout {
    [super prepareLayout];

    self.allAttributes = [self layoutAttributesForElementsInRect:CGRectMax];

    _contentSize = CGSizeZero;
    for (UICollectionViewLayoutAttributes* attr in self.allAttributes) {
        _contentSize.width = CGFloatMax(CGRectGetMaxX(attr.frame), _contentSize.width);
        _contentSize.height = CGFloatMax(CGRectGetMaxY(attr.frame), _contentSize.height);
    }
    
    _position = CGPointZero;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
    [super prepareForCollectionViewUpdates:updateItems];
}

- (void)invalidateLayout {
    [super invalidateLayout];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    CGPoint posTouch = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    UIScrollView *scrollView = self.collectionView;
    CGFloat delta = newBounds.origin.y - scrollView.bounds.origin.y;
    
    [self.dynAnimator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior* bhvSpring, NSUInteger idx, BOOL *stop) {
        UICollectionViewLayoutAttributes *item = [bhvSpring.items firstObject];
        CGFloat distTouch = fabsf(posTouch.y - bhvSpring.anchorPoint.y);
        
        // 计算阻尼系数
        CGFloat scrResis = 0;
        if (self.resistance)
            scrResis = distTouch / self.resistance;
        
        // 设置偏心位置
        CGPoint center = item.center;
        if (delta < 0)
            center.y += MAX(delta, delta * scrResis);
        else
            center.y += MIN(delta, delta * scrResis);
        
        item.center = center;
        
        // 刷新
        [self.dynAnimator updateItemUsingCurrentState:item];
    }];
    return NO;
}

- (CGSize)collectionViewContentSize {
    return _contentSize;
}

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect {
    if (_allAttributes != nil) {
        CGFloat rectmaxy = CGRectGetMaxY(rect);
        
        // 计算属于区域的行
        NSMutableArray* ret = [NSMutableArray temporary];
        BOOL findmaxy = NO;
        for (UICollectionViewLayoutAttributes* attr in _allAttributes) {
            // 找到第一个 maxy > rect.y 后，再找第一个 y > rect.maxy 的，中间即为区域内
            if (!findmaxy) {
                findmaxy = CGRectGetMaxY(attr.frame) >= rect.origin.y;
                if (findmaxy)
                    goto ADD_AND_NEXT;
                continue;
            }
            
            if (attr.frame.origin.y > rectmaxy)
                break;
         
ADD_AND_NEXT:
            [ret addObject:attr];
        }
        return ret;
    }
    
    // 总共的行数
    NSInteger numItems = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
    
    // 计算每一行的大小
    NSMutableArray *attrs = [NSMutableArray array];
    for(NSInteger i = 0; i < numItems; ++i)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        // 得到行的属性
        UICollectionViewLayoutAttributes* attr = [self layoutAttributesForItemAtIndexPath:indexPath];
        // 添加到返回列表中
        [attrs addObject:attr];
        // 生成behavior
        if (kIOS7Above)
        {
            UIAttachmentBehavior *bhvSpring = [[UIAttachmentBehavior alloc] initWithItem:attr
                                                                        attachedToAnchor:attr.center];
            bhvSpring.length = 1.f;
            bhvSpring.damping = 0.8f;
            bhvSpring.frequency = 1.f;
            [self.dynAnimator addBehavior:bhvSpring];
            SAFE_RELEASE(bhvSpring);
        }
    }
    return attrs;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 取得类型名
    Class cls = [(id<UICollectionViewDataSourceExt>)self.collectionView.dataSource collectionViewExt:self.collectionView itemClassForRowAtIndexPath:indexPath];
    
    // 注册到系统中
    NSString* reuseIdentifier = [(UICollectionViewExt*)self.collectionView registerItemClass:cls];
    
    // 获得重用对象
    UIViewWrapper* vw = (id)[(UICollectionViewExt*)self.collectionView dequeueItemView:reuseIdentifier];
    [(id<UICollectionViewDataSourceExt>)self.collectionView.dataSource collectionViewExt:self.collectionView item:vw.contentView atIndexPath:indexPath];
    [vw updateData];
    
    // 如果没有宽度，则设置为collection的宽度
    if (vw.bounds.size.width == 0) {
        CGRect rc = self.collectionView.bounds;
        vw.width = rc.size.width;
        [vw layoutSubviews];
    }
    
    // 更新对象数据
    UIView<UIConstraintView>* cv = (id)vw.contentView;
    [cv layoutSubviews];
    
    // 获得大小
    CGSize sz = cv.constraintBounds;
    if (sz.width == 0)
        sz.width = cv.bounds.size.width;
    
    CGRect rc = CGRectMakeWithPointAndSize(_position, sz);
    _position = CGPointOffset(_position, 0, sz.height);

    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attrs.frame = rc;
    return attrs;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForInsertedItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    return nil;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDeletedItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    return nil;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGPoint pt = proposedContentOffset;
    return pt;
}

@end

@implementation UICollectionViewControllerExt

- (void)onInit {
    [super onInit];
    self.classForView = [UICollectionViewExt class];
    self.classForLayout = [UIConstraintCollectionViewLayout class];
}

- (void)onFin {
    [super onFin];
}

static NSString* UICOLLECTIONVIEWCELL_DEFAULTIDENTIFIER = @"_::default::cell";

- (void)loadView {
    UICollectionViewLayout* cl = [[self.classForLayout alloc] init];
    UICollectionView* cv = [[self.classForView alloc] initWithFrame:CGRectMakeWithSize(kUIApplicationSize)
                                               collectionViewLayout:cl];
    self.view = [UIViewWrapper wrapperWithView:cv];
    SAFE_RELEASE(cl);
    SAFE_RELEASE(cv);
    
    cv.delegate = self;
    cv.dataSource = self;
    
    // 注册标准类型
    [cv registerClass:[UICollectionViewCellExt class] forCellWithReuseIdentifier:UICOLLECTIONVIEWCELL_DEFAULTIDENTIFIER];
}

# pragma mark implementation

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self numberOfSectionsInCollectionViewExt:collectionView];
}

- (NSInteger)numberOfSectionsInCollectionViewExt:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self collectionViewExt:collectionView numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self collectionViewExt:collectionView cellForItemAtIndexPath:indexPath];
}

- (NSInteger)collectionViewExt:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (UICollectionViewCell *)collectionViewExt:(UICollectionViewExt *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 取得对应的type
    Class cls = [self collectionViewExt:collectionView itemClassForRowAtIndexPath:indexPath];
    
    // 注册到系统中
    NSString* reuseIdentifier = [collectionView registerItemClass:cls];
    
    // 获得到分配的cell
    UICollectionViewCellExt* ret = (id)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                                 forIndexPath:indexPath];
    
    // 初始化view
    if (ret.view == nil) {
        // 拿到单元对象
        UIViewWrapper* cv = [collectionView dequeueItemView:reuseIdentifier];
        ret.view = cv;
    }
    
    // 刷新数据
    [self collectionViewExt:collectionView item:ret.view.behalfView atIndexPath:indexPath];
    [ret updateData];
    
    return ret;
}

- (void)collectionViewExt:(UICollectionView*)collectionView item:(UIView*)item atIndexPath:(NSIndexPath*)indexPat {
    PASS;
}

- (Class)collectionViewExt:(UICollectionView*)collectionView itemClassForRowAtIndexPath:(NSIndexPath*)indexPath {
    Class ret = self.classForItem;
    return ret;
}

@end

NSCLASS_SUBCLASS(CANavigationBarCompatiableLayer, CALayer);
NSCLASS_SUBCLASS(UINavigationBarExtTitleLabel, UILabelExt);

@interface UIExtNavigationBarAppearanceView : UIViewExt

@property (nonatomic, assign) BOOL showEdgeLine;
@property (nonatomic, retain) CGLine *edgeLine;

@end

@implementation UIExtNavigationBarAppearanceView

- (void)onInit {
    [super onInit];
    self.userInteractionEnabled = NO;
    self.showEdgeLine = YES;
}

- (void)onFin {
    ZERO_RELEASE(_edgeLine);
    [super onFin];
}

- (void)onDraw:(CGRect)rect {
    [super onDraw:rect];
    
    CGGraphic* gra = [CGGraphic Current];
    if (_showEdgeLine && _edgeLine) {
        CGFloat off = 0;
        if (_edgeLine.width >= 2)
            off = _edgeLine.width / 2;
        [gra move:CGPointOffset(CGRectLeftBottom(rect), 0, -off)];
        [gra line:CGPointOffset(CGRectRightBottom(rect), 0, -off) pen:[CGPen Pen:_edgeLine.color width:_edgeLine.width]];
    }
}

@end

NSCLASS_SUBCLASS(UIButtonExt4BarButtonItem, UIButtonExt);
NSCLASS_SUBCLASS(UILabelExt4BarButtonItem, UILabelExt);

@implementation UINavigationBar (extension)

- (BOOL)isBackgroundViewBeyond {
    return NO;
}

- (void)doInsertBackgroundView:(UIView*)bv {
    [self addSubview:bv];
}

NSOBJECT_DYNAMIC_PROPERTY(UINavigationBar, barColor, setBarColor, RETAIN_NONATOMIC);
NSOBJECT_DYNAMIC_PROPERTY(UINavigationBar, edgeShadow, setEdgeShadow, RETAIN_NONATOMIC);

- (void)setTitleShadowOffset:(CGSize)titleShadowOffset {
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:self.titleTextAttributes];
    [dict setObject:[NSValue valueWithCGSize:titleShadowOffset] forKey:UITextAttributeTextShadowOffset];
    self.titleTextAttributes = dict;
}

- (CGSize)titleShadowOffset {
    return [[self.titleTextAttributes objectForKey:UITextAttributeTextShadowOffset] CGSizeValue];
}

- (void)setTitleColor:(UIColor *)titleColor {
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:self.titleTextAttributes];
    [dict setObject:titleColor forKey:UITextAttributeTextColor];
    self.titleTextAttributes = dict;
}

- (UIColor*)titleColor {
    return [self.titleTextAttributes objectForKey:UITextAttributeTextColor];
}

- (void)setTitleFont:(UIFont *)titleFont {
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:self.titleTextAttributes];
    [dict setObject:titleFont forKey:UITextAttributeFont];
    self.titleTextAttributes = dict;
}

- (UIFont*)titleFont {
    return [self.titleTextAttributes objectForKey:UITextAttributeFont];
}

- (void)setTextColor:(UIColor*)color {
    [self setTitleColor:color];
}

- (void)setTextFont:(UIFont*)font {
    [self setTitleFont:font];
}

NSOBJECT_DYNAMIC_PROPERTY_EXT(UINavigationBar, customBarView,, setCustomBarView, {
    [self.customBarView removeFromSuperview];
}, {
    [self addSubview:val];
}, RETAIN_NONATOMIC);

NSOBJECT_DYNAMIC_PROPERTY(UINavigationBar, barHeight, setBarHeight, RETAIN_NONATOMIC);

- (void)onAddedToWindow {
    [super onAddedToWindow];
    
    if (self.edgeShadow) {
        [self.edgeShadow setIn:self.layer];
    }
}

- (void)SWIZZLE_CALLBACK(add_view):(UIView*)view {
    if (view == nil)
        return;
    
    if (view == self.topItem.titleView)
    {
        if ([view respondsToSelector:@selector(setTitleShadowOffset:)])
            [(id)view setTitleShadowOffset:self.titleShadowOffset];
        else if ([view respondsToSelector:@selector(setShadowOffset:)])
            [(id)view setShadowOffset:self.titleShadowOffset];
    }
}

- (UILabel*)extTitleLabel {
    UILabel* lbl = [self.subviews objectWithQuery:^id(id l) {
        if ([l isKindOfClass:[UINavigationBarExtTitleLabel class]])
            return l;
        return nil;
    }];
    if (lbl == nil) {
        lbl = [[UINavigationBarExtTitleLabel alloc] initWithZero];
        lbl.userInteractionEnabled = NO;
        lbl.textAlignment = NSTextAlignmentCenter;
        [self addSubview:lbl];
        SAFE_RELEASE(lbl);
    }
    return lbl;
}

- (NSArray*)systemViews {
    __block id lbl = nil;
    NSMutableArray* ret = (NSMutableArray*)[self.subviews arrayWithCollector:^id(id l) {
        NSString* vname = NSStringFromClass([l class]);
        if (l == self.topItem.titleView)
            return l;
        if (l == self.topItem.leftBarViewItem)
            return l;
        if (l == self.topItem.rightBarViewItem)
            return l;
        if ([l isKindOfClass:[UIButton class]])
            return l;
        if ([vname hasPrefix:@"UINav"])
            return l;
        return nil;
    }];
    if (lbl)
        [ret readdObject:lbl];
    return ret;
}

- (void)SWIZZLE_CALLBACK(layout_subviews) {
    [super SWIZZLE_CALLBACK(layout_subviews)];

    CGRect rc = self.bounds;
    if (self.barHeight) {
        CGFloat tgtHeight = self.barHeight.floatValue;
        if (rc.size.height != tgtHeight) {
            [self setHeight:tgtHeight];
            rc = self.bounds;
        }
    }
    
    // 收集所有的系统定义 view
    NSArray* sysuis = self.systemViews;
    
    // 是否需要处理一下标准baritem的位置
    for (id each in sysuis) {
        if ([each isMemberOfClass:[UIButtonExt4BarButtonItem class]] == NO)
            continue;
        [each offsetPosition:((UIButtonExt4BarButtonItem*)each).offsetEdge];
    }
    
    // 移动标准控件到该在的位置
    if (rc.size.height != kUINavigationBarHeight)
    {
        if (kIOS7Above && self.topItem.titleView == nil)
        {
            UILabel* lbl = [self extTitleLabel];
            UIView* std = [sysuis objectWithQuery:^id(id l) {
                NSString* nl = NSStringFromClass([l class]);
                if ([nl hasPrefix:@"UINavi"] && [nl hasPrefix:@"View"])
                    return l;
                return nil;
            }];
            if (std) {
                lbl.hidden = NO;
                lbl.frame = std.frame;
                std.hidden = YES;
                lbl.text = self.topItem.title;
                lbl.textColor = self.titleColor;
            }
        }
        
        if (self.topItem.titleView == nil) {
            for (UIView* each in sysuis) {
                CGRect rce = each.frame;
                rce.origin.y -= rc.size.height - kUINavigationBarHeight;
                each.frame = rce;
            }
        }
    }
    else
    {
        UILabel* lbl = [self.subviews objectWithQuery:^id(id l) {
            if ([l isKindOfClass:[UINavigationBarExtTitleLabel class]])
                return l;
            return nil;
        }];
        if (lbl)
            lbl.hidden = YES;
    }
    
    // 自定义view
    CGRect fm = self.frame;
    fm.size.height += fm.origin.y;
    fm.origin.y = -fm.origin.y;

    // 设置自定义视图的大小到满屏
    self.ext_backgroundView.frame = fm;
    self.customBarView.frame = fm;
    
    // 需要移动系统控件到最上
    for (UIView* each in sysuis)
        [each bringUp];

    // 移动自定义 appearance 层到最上面
    UIExtNavigationBarAppearanceView* av = [self.subviews objectWithQuery:^id(id l) {
        if ([l isKindOfClass:[UIExtNavigationBarAppearanceView class]])
            return l;
        return nil;
    }];
    av.frame = self.bounds;
    [av bringUp];
 
    // 设置阴影路径
    [self updateAdditionAppearances];
}

- (void)onAddedToSuperview {
    [super onAddedToSuperview];
    
    // 如果是7一下的系统，为了支持自定义样式，需要添加一个新的layer用来绘图
    if (!kIOS7Above)
    {
        CALayer* defly = [self.layer.sublayers objectAtIndex:0];
        defly.hidden = YES;
    }
    
    // 兼容层，用来绘制背景等
    [self.layer addSublayer:[self reusableObject:@"::compatiable::layer" instance:^id{
        CANavigationBarCompatiableLayer* el = [CANavigationBarCompatiableLayer temporary];
        el.hidden = YES;
        return el;
    }]];
    
    // 增加自定义层，用来绘制自定义元素
    [self addSubview:[self reusableObject:@"::appearance::view" instance:^id{
        UIExtNavigationBarAppearanceView* av = [UIExtNavigationBarAppearanceView temporary];
        av.edgeLine = self.edgeLine;
        return av;
    }]];
    
    // 重新设置一下bar的颜色
    UIColor* color = [[UINavigationBar appearance] barColor];
    if (color &&
        color != [UIColor clearColor])
    {
        if (self.barColor == nil)
            self.barColor = color;
        [self setCompatiableBarTintColor:color];
    }
    
    // 设置其他属性
    NSDictionary* dict = [[UINavigationBar appearance] titleTextAttributes];
    if ([dict objectForKey:UITextAttributeTextColor])
        self.titleColor = [dict objectForKey:UITextAttributeTextColor];
    if ([dict objectForKey:UITextAttributeFont])
        self.titleFont = [dict objectForKey:UITextAttributeFont];
    
    // 刷新
    [self updateCompatiableAppears];
}

- (void)setEdgeLine:(CGLine *)edgeLine {
    [[self.subviews objectWithQuery:^id(id l) {
        if ([l isKindOfClass:[UIExtNavigationBarAppearanceView class]])
            return l;
        return nil;
    }] setEdgeLine:edgeLine];
}

- (CGLine*)edgeLine {
    return [[self.subviews objectWithQuery:^id(id l) {
        if ([l isKindOfClass:[UIExtNavigationBarAppearanceView class]])
            return l;
        return nil;
    }] edgeLine];
}

- (void)setCompatiableTranslucent:(BOOL)val {
    if (self.translucent == val)
        return;
    self.translucent = val;
    if (kIOS7Above)
        [self setCompatiableBarTintColor:self.barTintColor];
}

- (void)setCompatiableBarTintColor:(UIColor*)color {
    if (!kIOS7Above)
        return;
    self.barColor = color;
    
    if (self.translucent) {
        if (color.isColorizedGlossy)
            color = nil;
    }
    
    self.barTintColor = color;
}

NSOBJECT_DYNAMIC_PROPERTY_EXT(UINavigationBar, preferrerBarColor,, setPreferrerBarColor,, {
    [self updateCompatiableAppears];
}, RETAIN_NONATOMIC);

CGFloat kUINavigationBarTranslucentOpacity = 0.78f;

- (void)updateCompatiableAppears {
    CANavigationBarCompatiableLayer* el = [self.layer.sublayers objectWithQuery:^id(id l) {
        if ([l isKindOfClass:[CANavigationBarCompatiableLayer class]])
            return l;
        return nil;
    }];
    
    el.hidden = self.barBlur;
    if (el.hidden == NO)
    {
        CGRect rc = self.bounds;
        if (kIOS7Above) {
            rc.origin.y -= self.frame.origin.y;
            rc.size.height += self.frame.origin.y;
        }
        el.frame = rc;
        [el retain];
        [el removeFromSuperlayer];
        [self.layer insertSublayer:el atIndex:1];
        [el release];
        
        UIColor* prefColor = self.preferrerBarColor;
        if (prefColor == nil) {
            if (self.translucent)
                el.opacity = kUINavigationBarTranslucentOpacity;
            else
                el.opacity = 1;
            el.backgroundColor = self.barColor.CGColor;
        } else {
            el.opacity = 1;
            el.backgroundColor = prefColor.CGColor;
        }
    }
    
    // 是否绘制阴影
    [self updateAdditionAppearances];
}

- (void)updateAdditionAppearances {
    if (self.edgeShadow.hidden)
    {
        self.layer.shadowPath = nil;
    }
    else
    {
        CGRect rc = self.bounds;
        CGRect shadowPath = CGRectMake(rc.origin.x - 10,
                                       rc.size.height - 6,
                                       rc.size.width + 20,
                                       5);
        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowPath].CGPath;
    }
    
    UIExtNavigationBarAppearanceView* av = [self.subviews objectWithQuery:^id(id l) {
        if ([l isKindOfClass:[UIExtNavigationBarAppearanceView class]])
            return l;
        return nil;
    }];
    av.showEdgeLine = self.layer.shadowPath != nil;
    [av setNeedsDisplay];
}

- (void)setBarBlur:(BOOL)barBlur {
    if (!kIOS7Above)
        return;
    
    UIView* bg = [self.subviews objectWithQuery:^id(id l) {
        NSString* cls = NSStringFromClass([l class]);
        if ([cls hasSuffix:@"Background"])
            return l;
        return nil;
    }];
    bg.visible = barBlur;
}

- (BOOL)barBlur {
    if (!kIOS7Above)
        return NO;
    UIView* bg = [self.subviews objectWithQuery:^id(id l) {
        NSString* cls = NSStringFromClass([l class]);
        if ([cls hasSuffix:@"Background"])
            return l;
        return nil;
    }];
    return bg.visible;
}

@end

@interface UINavigationController (banners)

@property (nonatomic, readonly) NSMutableArray *arrBanners;

@end

@implementation UINavigationController (banners)

NSOBJECT_DYNAMIC_PROPERTY_READONLY(UINavigationController, arrBanners, NSMutableArray);

@end

@implementation UINavigationController (extension)

+ (instancetype)navigationWithController:(UIViewController*)ctlr {
    return [[[self alloc] initWithRootViewController:ctlr] autorelease];
}

- (CGFloat)barHeight {
    CGFloat ret = 0;
    if (self.navigationBar.visible)
        ret += self.navigationBar.frame.size.height;
    UIViewController* vc = self.visibleViewController;
    if (vc.attributes.navigationBarTranslucent.boolValue)
        ret += kUIStatusBarHeight;
    return ret;
}

- (void)showBanner:(UIView *)view {
    if (view == nil)
        return;
    
    UIViewController* vc = self.topViewController;
    UIView* sv = vc.view;
    view.navigationController = self;
    
    // 重新定义信号，以防止异常通知，显示banner会使用一个view包裹住目标view，所以目标view的adding相关信号会提前emit
    UIViewWrapper* vw = [UIViewWrapper wrapperWithView:view];
    
    // 如果初始没有高度，则复制给默认全部工作区域
    CGSize vsz = view.frame.size;
    if (CGSizeEqualToSize(vsz, CGSizeZero))
    {
        // 先设置为最大的可能大小
        [view setSize:sv.bounds.size];
        
        // 布局一下，已生成第一版的位置
        [view layoutSubviews];
        
        // 取得最佳高度
        CGFloat ret = view.bestHeight;
        if (ret == 0) {
            ret = self.view.bounds.size.height;
            if (vc.attributes.navigationBarDodge &&
                vc.attributes.navigationBarTranslucent.boolValue)
            {
                ret -= self.navigationBar.frame.size.height;
                ret -= kUIStatusBarHeight;
            }
        }
        
        // 设置最佳高度
        [vw setHeight:ret];
        [vw layoutSubviews];
    }
    else
    {
        [vw setSize:vsz];
    }

    CGRect bounds = self.view.bounds;
    UIVBox* box = [UIVBox boxWithRect:bounds withSpacing:0];
    
    // 避让标题
    if (vc.attributes.navigationBarDodge &&
        vc.attributes.navigationBarTranslucent.boolValue)
    {
        CGFloat val = self.navigationBar.frame.size.height;
        val += kUIStatusBarHeight;
        [box addPixel:val toView:nil];
    }
    
    [box addPixel:vw.frame.size.height toView:vw];
    [box addFlex:1 toView:nil];
    [box apply];

    // 增加到队列或者直接显示
    if (self.arrBanners.count == 0)
        [sv addSubview:vw];
    [self.arrBanners addObject:vw];
}

- (void)hideBanner:(UIView *)view {
    UIViewWrapper* vw = (id)view.superview;
    if (vw == nil) {
        WARN("隐藏的这个 view 不是 banner");
        return;
    }
    
    // 从队列中移除
    [self.arrBanners removeObject:vw];
    [vw removeFromSuperview];
    
    // 显示队列中的下一个
    if (self.arrBanners.count) {
        UIViewController* vc = self.topViewController;
        UIView* sv = vc.view;
        DISPATCH_DELAY_BEGIN(.3)
        UIView* tv = self.arrBanners.firstObject;
        [sv addSubview:tv];
        DISPATCH_DELAY_END
    }
    
    LOG("Banner 队列里面还存在 %d 个即将显示", self.arrBanners.count);
}

- (UIView*)visibleBannerView {
    return [self.arrBanners.firstObject behalfView];
}

- (NSArray*)bannerViews {
    return [self.arrBanners arrayWithCollector:^id(id l) {
        return [l behalfView];
    }];
}

- (void)clearBannerViews {
    for (UIViewWrapper* each in self.arrBanners) {
        [each.contentView.signals block];
        [each removeFromSuperview];
    }
    [self.arrBanners removeAllObjects];
    LOG("清空 banners 队列");
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalViewControllerPushed)
SIGNAL_ADD(kSignalViewControllerPoped)
SIGNALS_END

- (void)pushViewController:(UIViewController *)viewController {
    [self pushViewController:viewController animated:YES];
}

- (void)pushViewControllerNoAnimated:(UIViewController *)viewController {
    [self pushViewController:viewController animated:NO];
}

- (NSArray*)popToViewController:(UIViewController*)viewController {
    return [self popToViewController:viewController animated:YES];
}

- (NSArray*)popToViewControllerNoAnimated:(UIViewController*)viewController {
    return [self popToViewController:viewController animated:NO];
}

- (UIViewController*)popViewController {
    return [self popViewControllerAnimated:YES];
}

- (UIViewController*)popViewControllerNoAnimated {
    return [self popViewControllerAnimated:NO];
}

- (NSArray*)popToRootViewController {
    return [self popToRootViewControllerAnimated:YES];
}

- (NSArray*)popToRootViewControllerNoAnimated {
    return [self popToRootViewControllerAnimated:NO];
}

- (CGRect)frameForContent {
    CGRect rc = self.view.bounds;
    CGRect rcbar = self.navigationBar.bounds;
    rc.origin.y += rcbar.size.height;
    rc.size.height -= rcbar.size.height;
    return rc;
}

- (void)goBack:(BOOL)animated {
    if (self.viewControllers.count) {
        if ([self popViewControllerAnimated:animated])
            return;
    }
    [self dismissModalViewControllerAnimated:animated];
}

- (void)goBack {
    [self goBack:YES];
}

- (void)goBackNoAnimated {
    [self goBack:NO];
}

static void(^__gs_navi_hook_push)(UINavigationController*, UIViewController*) = nil;

+ (void)SetPushHook:(void(^)(UINavigationController*, UIViewController*))hook {
    BLOCK_RETAIN(__gs_navi_hook_push, hook);
}

+ (void)SetNavigationItemHook:(void(^)(UINavigationController*, UIViewController*, UINavigationItem*))hook {
    BLOCK_RETAIN(__gs_navi_hook_naviitem, hook);
}

- (void)takeoverPageViewController:(UIViewController*)vc {
    [vc.signals connect:kSignalViewAppear withSelector:@selector(__navi_childvc_appear:) ofTarget:self];
    [vc.signals connect:kSignalViewAppearing withSelector:@selector(__navi_childvc_appearing:) ofTarget:self];
    [vc.signals connect:kSignalViewDisappearing withSelector:@selector(__navi_childvc_disappearing:) ofTarget:self];
    [vc.signals connect:kSignalViewDisappear withSelector:@selector(__navi_childvc_disappear:) ofTarget:self];
}

- (void)SWIZZLE_CALLBACK(pushing):(UIViewController*)viewController animated:(BOOL)animated {
    [UIKeyboardExt Close];
    
    // 前置绑定处理信号
    [self takeoverPageViewController:viewController];
    
    if (__gs_navi_hook_push)
        __gs_navi_hook_push(self, viewController);
}

- (void)SWIZZLE_CALLBACK(push):(UIViewController*)viewController animated:(BOOL)animated {
    INFO("Navigation 推入 %s", objc_getClassName(viewController));
    
    // 传递 navigation
    if ([viewController respondsToSelector:@selector(setNavigationController:)]) {
        [viewController performSelector:@selector(setNavigationController:) withObject:self];
    }
    
    [self.touchSignals emit:kSignalViewControllerPushed withResult:viewController];
}

- (void)SWIZZLE_CALLBACK(pop):(UIViewController*)vc animated:(BOOL)animated {
    INFO("Navigation 推出 %s", objc_getClassName(vc));
    
    [self.touchSignals emit:kSignalViewControllerPoped];
}

- (void)SWIZZLE_CALLBACK(setViewControllers):(NSArray*)vcs animated:(BOOL)animated {
    [vcs foreach:^BOOL(id obj) {
        [self takeoverPageViewController:obj];
        return YES;
    }];
}

- (void)__navi_childvc_appearing:(SSlot*)s {
    UIViewController* vc = (UIViewController*)s.sender;
    [self __navi_updateui_byvc:vc appearing:YES];
}

- (void)__navi_childvc_appear:(SSlot*)s {
    UIViewController* vc = (UIViewController*)s.sender;
    [self __navi_updateui_byvc:vc appearing:NO];
}

- (void)__navi_childvc_disappearing:(SSlot*)s {
    PASS;
}

- (void)__navi_childvc_disappear:(SSlot*)s {
    PASS;
}

- (void)__navi_updateui_byvc:(UIViewController*)vc appearing:(BOOL)appearing {
    BOOL canOS = NavigationControllerCanOverrideSetting(vc);
    
    // 如果searchbar被响应，则需要根据需求显示/隐藏导航栏
    if (canOS && !vc.isSearchBarResponding)
        [self setNavigationBarHidden:vc.hidesTopBarWhenPushed animated:YES];
    
    // 是否需要隐藏电池栏
    if (vc.attributes.statusBarHidden)
        [[UIApplication sharedApplication] setStatusBarHidden:vc.attributes.statusBarHidden.boolValue
                                                withAnimation:UIStatusBarAnimationFade];
    if (vc.attributes.statusBarHidden.boolValue == NO) {
        if (vc.attributes.statusBarColor) {
            [UIApplication sharedApplication].statusBarColor = vc.attributes.statusBarColor;
        } else {
            [[UIApplication sharedApplication] setStatusBarStyle:vc.attributes.statusBarStyle animated:YES];
        }
    }
    
    // 如果不继承现有的，则需要单独设置
    if (vc.attributes.navigationBarInherit.boolValue == NO)
    {
        // 基础设置
        if (canOS)
            self.navigationBar.translucent = vc.attributes.navigationBarTranslucent.boolValue;
        if (vc.attributes.navigationBarTintColor)
            self.navigationBar.tintColor = vc.attributes.navigationBarTintColor;
        // 自定义title样式
        [vc.attributes.navigationBarTitleStyle setIn:self.navigationBar];
        // 自定义背景
        if (vc.attributes.navigationBarColor)
        {
            self.navigationBar.backgroundImage = nil;
            if (kIOS7Above) {
                [self.navigationBar setCompatiableBarTintColor:vc.attributes.navigationBarColor];
            } else {
                self.navigationBar.barColor = vc.attributes.navigationBarColor;
            }
        }
        else if (vc.attributes.navigationBarImage)
        {
            self.navigationBar.backgroundImage = vc.attributes.navigationBarImage;
        }
        else
        {
            self.navigationBar.backgroundImage = nil;
            if (kIOS7Above) {
                UIColor* color = [[UINavigationBar appearance] barColor];
                if (color == nil)
                    color = [[UINavigationBar appearance] barTintColor];
                if (!(vc.hidesTopBarWhenPushed && appearing))
                    [self.navigationBar setCompatiableBarTintColor:color];
            } else {
                self.navigationBar.barColor = [[UINavigationBar appearance] barColor];
            }
        }
    }

    // 保护设置
    if (canOS) {
        // ios7的searchbar会停靠到最上边缘，其他版本不会，需要做一下处理
        if (vc.attributes.navigationBarTranslucent.boolValue || kIOS7Above) {
            vc.wantsFullScreenLayout = YES;
            //vc.view.wantsFullScreenLayout = YES;
        }
        if (self.navigationBar.translucent) {
            self.navigationBar.barBlur = vc.attributes.navigationBarBlur;
        } else {
            self.navigationBar.barBlur = YES;
        }
    }

    // 如果是标题栏透明，则不能显示阴影
    if (appearing) {
        if (!vc.attributes.navigationBarBlur
            && vc.attributes.navigationBarTranslucent.boolValue
            && vc.attributes.navigationBarColor == [UIColor clearColor])
        {
            self.navigationBar.edgeShadow.hidden = YES;
        } else {
            self.navigationBar.edgeShadow.hidden = NO;
        }
        [self.navigationBar updateAdditionAppearances];
    }
    
    // 自定义view
    if (appearing) {
        self.navigationBar.customBarView = vc.navigationBarView;
        self.navigationBar.customBarView.navigationController = self;
    }
    
    // 自定义高度
    if (canOS && appearing) {
        self.navigationBar.barHeight = vc.attributes.navigationBarHeight;
        if (vc.attributes.navigationBarHeight == nil)
            [self.navigationBar setHeight:kUINavigationBarHeight];
    }
    
    // 如果是其他vc，为了解决文字颜色淡化的问题，需要用 baritem 的 textcolor 重新设置一下
    if (canOS == NO) {
        NSDictionary* dict = [[UIBarButtonItem appearance] titleTextAttributesForState:UIControlStateNormal];
        UIColor* color = [dict objectForKey:UITextAttributeTextColor];
        if (color)
            self.navigationBar.titleColor = color;
    }

    // 刷新一下显示
    [self.navigationBar updateCompatiableAppears];
}

@end

# ifdef IOS7_FEATURES

@interface UINavigationControllerExtAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>
@end

@implementation UINavigationControllerExtAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 1;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *ctlrTo = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *ctlrFrom = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [[transitionContext containerView] addSubview:ctlrTo.view];
    [[transitionContext containerView] addSubview:ctlrFrom.view];
    
    ctlrFrom.view.layer.shadow = [CGShadow LeftEdge];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^{
                         ctlrFrom.view.transform = CGAffineTransformMakeTranslation(ctlrFrom.view.bounds.size.width, 0);
                     }
                     completion:^(BOOL finished) {
                         BOOL cancel = [transitionContext transitionWasCancelled];
                         if (cancel) {
                             // 如果取消了动画，则需要将显示状态置为未显示，否则不会调用 appeared 的方法
                             ctlrFrom.extension.appeared = NO;
                         }
                         [transitionContext completeTransition:!cancel];
                     }];
}

- (void)animationEnded:(BOOL)transitionCompleted {
    PASS;
}

@end

# endif

NSCLASS_SUBCLASS(UINaviExtPanGestureRecognizer, UIPanGestureRecognizer);

@interface UINavigationControllerExt ()
<UINavigationControllerDelegate, UIGestureRecognizerDelegate>

# ifdef IOS7_FEATURES
@property (nonatomic, readonly) UIPanGestureRecognizer *panTransition;
@property (nonatomic, retain) UIPercentDrivenInteractiveTransition *transitionInteractive;
@property (nonatomic, retain) UINavigationControllerExtAnimatedTransitioning *transitionAnimated;
# endif

@end

@implementation UINavigationControllerExt

@synthesize panTransition;

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    
    // 初始化控制
    self.delegate = self;
    
# ifdef IOS7_FEATURES
    if (kIOS7Above)
    {
        // 处理自动边距
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.navigationBar.translucent = NO;
        
        // 处理ios7边缘手势
        //self.interactivePopGestureRecognizer.delegate = self;
    }
# endif
    
    if (!kIOS7Above) {
        self.navigationBar.titleShadowOffset = CGSizeMake(0, 0);
    }
    
    if (rootViewController) {
        [rootViewController.signals connect:kSignalViewAppearing withSelector:@selector(__navi_childvc_appearing:) ofTarget:self];
        [rootViewController.signals connect:kSignalViewAppear withSelector:@selector(__navi_childvc_appear:) ofTarget:self];
    }
    
    [self onInit];
    return self;
}

- (void)dealloc {
# ifdef IOS7_FEATURES
    ZERO_RELEASE(panTransition);
    ZERO_RELEASE(_transitionInteractive);
    ZERO_RELEASE(_transitionAnimated);
# endif
    
    [self onFin];
    [super dealloc];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalViewControllerPoping)
SIGNALS_END

- (UIPanGestureRecognizer*)panTransition {
    if (panTransition == nil) {
        // 为ios7提供全局滑动的手势
        panTransition = [[UINaviExtPanGestureRecognizer alloc] init];
        panTransition.delegate = self;
        [panTransition.signals connect:kSignalGesture withSelector:@selector(__navi_pantransition) ofTarget:self];
    }
    return panTransition;
}

- (UIViewController*)popViewControllerAnimated:(BOOL)animated {
    // 发送消息
    SSlotTunnel* tun = [SSlotTunnel temporary];
    [self.signals emit:kSignalViewControllerPoping withResult:self.topViewController withTunnel:tun];
    if (tun.vetoed)
        return nil;
    return [super popViewControllerAnimated:animated];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    [super setViewControllers:viewControllers animated:animated];
    
    // 保护第一个VC的大小
    if (viewControllers.count) {
        UIView* view = [[viewControllers firstObject] behalfView];
        if (CGRectEqualToRect(view.frame, CGRectZero)) {
            CGRect rc = [self frameForContent];
            view.frame = rc;
            [view layoutSubviews];
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    PASS;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    PASS;
}

# ifdef IOS7_FEATURES

//- (NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {}
//- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController {}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController {
    return _transitionInteractive;
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPop)
        return _transitionAnimated;
    return nil;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ((kIOS7Above && gestureRecognizer == self.interactivePopGestureRecognizer) ||
        gestureRecognizer == self.panTransition)
    {
        if (self.viewControllers.count <= 1)
            return NO;
        UIViewController* vc = self.topViewController;
        if (vc.panToBack == NO)
            return NO;
    }
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [UIAppDelegate shared].preferredStatusBarStyle;
}

# endif

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self SWIZZLE_CALLBACK(appearing):animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self SWIZZLE_CALLBACK(appeared):animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self SWIZZLE_CALLBACK(disappearing):animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self SWIZZLE_CALLBACK(disappeared):animated];
}

- (void)viewDidLoad {
    // 需要将 frame 的大小设置0，否则打开时会多于留空
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.frame = CGRectZero;

    // 重载
    [super viewDidLoad];
    
    // 为ios7添加手势，使用滑动来后退
    //[self.view addGestureRecognizer:self.panTransition];
    if (kIOS7Above) {
        self.interactivePopGestureRecognizer.delegate = self;
    }
}

- (void)__navi_pantransition {
    CGFloat prg = fabsf(self.panTransition.translation.x / CGRectGetWidth(self.view.bounds));
    switch (self.panTransition.state)
    {
        default: break;
        case UIGestureRecognizerStateBegan: {
            // 如果是从左往右，pop
            if ([NSMask Mask:kCGDirectionFromLeft Value:self.panTransition.direction]) {
                // 如果滑的非常快，则直接pop，不做动画
                if (self.panTransition.velocity.x > 300) {
                    [self popViewControllerAnimated:YES];
                } else {
                    if (kIOS7Above) {
                        self.transitionInteractive = [UIPercentDrivenInteractiveTransition temporary];
                        self.transitionAnimated = [UINavigationControllerExtAnimatedTransitioning temporary];
                    }
                    //LOG("Navigation Pan Begin Transition");
                    [self popViewControllerAnimated:YES];
                }
            }
        } break;
        case UIGestureRecognizerStateChanged: {
            if (kIOS7Above)
                [_transitionInteractive updateInteractiveTransition:prg];
        } break;
        case UIGestureRecognizerStateCancelled: {
            if (kIOS7Above) {
                [_transitionInteractive cancelInteractiveTransition];
                self.transitionInteractive = nil;
                self.transitionAnimated = nil;
                //LOG("Navigation Pan Cancel Transition");
            }
        } break;
        case UIGestureRecognizerStateEnded: {
            if (kIOS7Above) {
                if (prg < .382f) {
                    [_transitionInteractive cancelInteractiveTransition];
                    //LOG("Navigation Pan Cancel Transition");
                } else {
                    [_transitionInteractive finishInteractiveTransition];
                    //LOG("Navigation Pan Finish Transition");
                }
                self.transitionInteractive = nil;
                self.transitionAnimated = nil;
            }
        } break;
    }
}

@end

@implementation UITextField (extension)

- (void)setTextFont:(UIFont *)textFont {
    self.font = textFont;
}

- (UIFont*)textFont {
    return self.font;
}

- (void)setReadonly:(BOOL)readonly {
    self.enabled = !readonly;
}

- (BOOL)readonly {
    return !self.enabled;
}

- (void)appendText:(NSString*)text {
    if (text == nil)
        return;
    
    NSString* str = self.text;
    str = [str stringByAppendingString:text];
    self.text = str;
}

- (void)appendLineBreak {
    [self appendText:@"\n"];
}

- (void)clear {
    self.text = @"";
}

@end

@interface UITextFieldExt ()

@property (nonatomic, assign) BOOL isValid;

@end

PRIVATE_IMPL_BEGIN(UITextFieldExt, NSObject <UITextFieldDelegate>, )

@property (nonatomic, copy) NSString *lastString;

PRIVATE_IMPL(UITextFieldExt)

- (id)init {
    self = [super init];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiChanged:) name:UITextFieldTextDidChangeNotification object:d_owner];

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    ZERO_RELEASE(_lastString);
    [super dealloc];
}

- (void)notiChanged:(id)da {
    if ([self.lastString isEqualToString:d_owner.text])
        return;
    
    [NSTrailChange SetChange];
    self.lastString = d_owner.text;
    
    // 验证值
    d_owner.isValid = [self checkValueValid:self.lastString];
    if (d_owner.isValid) {
        [d_owner.touchSignals emit:kSignalValueValid];
    } else {
        [d_owner.touchSignals emit:kSignalValueInvalid];
    }
    
    [d_owner.touchSignals emit:kSignalValueChanged withResult:self.lastString];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.lastString = nil;
    [d_owner.touchSignals emit:kSignalEditing];
    
    // 避让键盘
    if (d_owner.keyboardDodge)
        [[UIKeyboardExt shared] dodgeView:d_owner];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (d_owner.text.notEmpty == NO && d_owner.defaultText.notEmpty) {
        d_owner.text = d_owner.defaultText;
    }
    
    if (self.lastString != nil) {
        [d_owner.touchSignals emit:kSignalValueChanged withResult:d_owner.text];
        self.lastString = nil;
    }
    
    [d_owner.touchSignals emit:kSignalEdited withResult:d_owner.text];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* strAfter = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    /*
    if (d_owner.patternSecure) {
        [d_owner.patternSecure enumerateMatchesInString:strAfter
                                                options:NSMatchingReportProgress
                                                  range:NSMakeRange(0, strAfter.length)
                                             usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                             }];
    }
     */
    
    // 使用输入pattern
    if ([self checkInputValid:strAfter] == NO) {
        [d_owner.touchSignals emit:kSignalInputInvalid];
        return NO;
    } else {
        [d_owner.touchSignals emit:kSignalInputValid withResult:strAfter];
    }

    [NSTrailChange SetChange];
    return YES;
}

- (BOOL)checkInputValid:(NSString*)str {
    if (d_owner.patternInput == nil)
        return YES;
    
    NSRange rgFull = NSMakeRange(0, str.length);
    NSRange result = [d_owner.patternInput rangeOfFirstMatchInString:str options:0 range:rgFull];
    if (NSEqualRanges(result, rgFull) == NO) {
        return NO;
    }
    
    return YES;
}

- (BOOL)checkValueValid:(NSString*)str {
    if (d_owner.patternValue == nil)
        return YES;
    
    NSRange rgFull = NSMakeRange(0, str.length);
    NSRange result = [d_owner.patternValue rangeOfFirstMatchInString:str options:0 range:rgFull];
    if (NSEqualRanges(result, rgFull) == NO) {
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    SSlotTunnel* tun = [SSlotTunnel temporary];
    [d_owner.touchSignals emit:kSignalKeyboardReturning withVariant:nil withTunnel:tun];
    if (tun.vetoed)
        return NO;
    [d_owner.touchSignals emit:kSignalKeyboardReturn];
    [d_owner.touchSignals emit:kSignalKeyboardHiding withVariant:nil withTunnel:tun];
    if (tun.vetoed)
        return NO;
    if (d_owner.keyboardAutoHide)
        [d_owner resignFirstResponder];
    return YES;
}

PRIVATE_IMPL_END()

@interface UITextFieldExt ()
{
    PRIVATE_DECL(UITextFieldExt);
}

@end

@implementation UITextFieldExt

@synthesize keyboardDodge;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    PRIVATE_CONSTRUCT(UITextFieldExt);
    
    self.delegate = d_ptr;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.keyboardAutoHide = YES;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.keyboardDodge = YES;

    [self onInit];
    return self;
}

- (void)dealloc {
    [self onFin];
    
    ZERO_RELEASE(_patternInput);
    ZERO_RELEASE(_patternValue);
    //ZERO_RELEASE(_patternSecure);
    ZERO_RELEASE(_defaultText);
    
    PRIVATE_DESTROY();
    [super dealloc];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalEditing)
SIGNAL_ADD(kSignalEdited)
SIGNAL_ADD(kSignalInputInvalid)
SIGNAL_ADD(kSignalInputValid)
SIGNAL_ADD(kSignalValueInvalid)
SIGNAL_ADD(kSignalValueValid)
SIGNAL_ADD(kSignalValueChanged)
SIGNAL_ADD(kSignalKeyboardReturning)
SIGNAL_ADD(kSignalKeyboardReturn)
SIGNAL_ADD(kSignalKeyboardHiding)
SIGNALS_END

- (void)setDefaultText:(NSString *)defaultText {
    PROPERTY_COPY(_defaultText, defaultText);
    if (self.text.notEmpty == NO)
        self.text = defaultText;
}

- (void)changeText:(NSString*)str {
    [[self.signals settingForSignal:kSignalValueChanged] block];
    [self setText:str];
    [[self.signals settingForSignal:kSignalValueChanged] unblock];
}

- (void)setText:(NSString *)text {
    if ([self.text isEqualToString:text])
        return;
    
    // 比较已经存在改变
    [NSTrailChange SetChange];
    
    // 设置并且判断是否合乎标准
    BOOL notempty = text.notEmpty;
    if (notempty) {
        if ([d_ptr checkInputValid:text] == NO) {
            [self.touchSignals emit:kSignalInputInvalid];
            return;
        }
    }
    
    [super setText:text];
    
    if (notempty) {
        self.isValid = [d_ptr checkValueValid:text];
        if (self.isValid)
            [self.touchSignals emit:kSignalValueValid];
        else
            [self.touchSignals emit:kSignalValueInvalid];
    }
    
    if ([d_ptr.lastString isEqualToString:text] == NO)
        [self.touchSignals emit:kSignalValueChanged withResult:text];
    
    d_ptr.lastString = text;
}

- (BOOL)becomeFirstResponder {
    BOOL suc = [super becomeFirstResponder];
    return suc;
}

- (BOOL)resignFirstResponder {
    BOOL suc = [super resignFirstResponder];
    return suc;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [super SWIZZLE_CALLBACK(touches_begin):touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [super SWIZZLE_CALLBACK(touches_cancel):touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [super SWIZZLE_CALLBACK(touches_end):touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [super SWIZZLE_CALLBACK(touches_moved):touches withEvent:event];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect rc = CGRectApplyPadding(bounds, self.contentPadding);
    return rc;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect rc = CGRectApplyPadding(bounds, self.contentPadding);
    return rc;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (CGSize)bestSize:(CGSize)sz {
    NSString* str = self.text;
    if (str.length == 0)
        str = self.placeholder;
    if (str.length == 0)
        str = @"";
    
    CGPadding pad = CGPaddingZero;
    if ([self respondsToSelector:@selector(contentPadding)]) {
        pad = [(id)self contentPadding];
        if (sz.width != CGVALUEMAX)
            sz.width -= CGPaddingWidth(pad);
        if (sz.height != CGVALUEMAX)
            sz.height -= CGPaddingHeight(pad);
    }
    
    NSString* tmp = [[NSString alloc] initWithFormat:@"%@", str];
    CGSize ret = [tmp sizeWithFont:self.font constrainedToSize:sz lineBreakMode:NSLineBreakByCharWrapping];
    [tmp release];
    
    if (sz.width == CGVALUEMAX)
        ret.width += CGPaddingWidth(pad);
    if (sz.height == CGVALUEMAX)
        ret.height += CGPaddingHeight(pad);
    
    if (self.editing) {
        ret.width += [@"口" sizeWithFont:self.font].width;
    }
    
    ret = CGSizeBBXIntegral(ret);
    return ret;
}

/*
- (void)setPatternSecure:(NSRegularExpression *)patternSecure {
    PROPERTY_RETAIN(_patternSecure, patternSecure);
    self.secureTextEntry = _patternSecure == nil;
}
 */

@end

@implementation UIImages

- (void)onInit {
    [super onInit];
}

- (void)onFin {
    ZERO_RELEASE(_images);
    [super onFin];
}

@end

@interface SDWebImageManager (uiextension)
- (NSString *)cacheKeyForURL:(NSURL *)url;
@end

@interface SDImageCache (uiextension)
- (NSString *)cachedFileNameForKey:(NSString *)key;
- (NSString *)defaultCachePathForKey:(NSString *)key;
@end

@implementation UIImageView (extension)

+ (instancetype)viewWithImage:(UIImage *)img {
    return [[[self alloc] initWithImage:img] autorelease];
}

+ (instancetype)viewWithDataSource:(id)ds {
    UIImageView* ret = [[self alloc] initWithZero];
    ret.imageDataSource = ds;
    return [ret autorelease];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalImageFetchStart)
SIGNAL_ADD(kSignalImageFetching)
SIGNAL_ADD(kSignalImageFetched)
SIGNAL_ADD(kSignalImageFetchFailed)
SIGNAL_ADD(kSignalImageChanged)
SIGNALS_END

SHARED_IMPL;

- (void)setImageDataSource:(id)ds {
    // 取消尚未加载完成的图片
    [self cancelCurrentArrayLoad];

    // 先设置为空
    self.image = nil;
    if (ds == nil)
        return;
    
    if ([ds isKindOfClass:[NSDataSource class]]) {
        NSDataSource* src = (NSDataSource*)ds;
        if (src.url) {
            [self setImageWithURL:src.url];
        } else if (src.bundle.notEmpty) {
            [self setImage:[UIImage imageWithContentOfNamed:src.bundle]];
        }
        return;
    }
    
    if ([ds isKindOfClass:[NSURL class]]) {
        [self setImageWithURL:ds];
        return;
    }
    
    if ([ds isKindOfClass:[UIImage class]]) {
        [self setImage:ds];
        return;
    }
    
    if ([ds isKindOfClass:[NSString class]]) {
        if ([ds notEmpty] == NO) {
            // 试图加载空路径图片
            [self setImage:nil];
            [self.signals emit:kSignalImageFetchFailed];
            return;
        }
        
        NSURL* url = [NSURL URLWithString:ds];
        if (url && url.scheme.notEmpty) {
            [self setImageWithURL:url];
            return;
        }
        
        if ([ds isAbsolutePath]) {
            [self setImage:[UIImage imageWithContentsOfFile:ds]];
            return;
        }
        
        [self setImage:[UIImage imageWithContentOfNamed:ds]];
        return;
    }
    
    if ([ds isKindOfClass:[NSNull class]])
    {
        [self setImage:nil];
        return;
    }
}

- (NSDataSource*)imageDataSource {
    return [NSDataSource dsWithData:self.image];
}

- (void)setImageWithURL:(NSURL *)url {
    [self.touchSignals emit:kSignalImageFetchStart];
    [self setImageWithURL:url placeholderImage:self.image];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    SDWebImageOptions opt = SDWebImageRetryFailed;
    if (self.disableCache)
        opt |= SDWebImageRefreshCached | SDWebImageCacheMemoryOnly;
    [self setImageWithURL:url placeholderImage:placeholder options:opt];
}

NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR(UIImageView, disableCache, setDisableCache, BOOL, @(val), [val boolValue], RETAIN_NONATOMIC);
NSOBJECT_DYNAMIC_PROPERTY(UIImageView, cachedImagePath, setCachedImagePath, RETAIN_NONATOMIC);
NSOBJECT_DYNAMIC_PROPERTY_EXT(UIImageView, fetchingIdentifier,, setFetchingIdentifier, {
    [self.fetchingIdentifier removeFromSuperview];
}, {
    [self addSubview:val];
}, RETAIN_NONATOMIC);
NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR(UIImageView, classForFetchingIdentifier, setClassForFetchingIdentifier, Class, [NSClass object:val], [val classValue], RETAIN_NONATOMIC);

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options {
    self.cachedImagePath = nil;
    
    // 如果 flymake 的缓存中还有该图片，则直接显示
    {
        UIImage* imgfl = [[UIImageFlymakeCache shared] objectForKey:url];
        if (imgfl != nil) {
            self.image = imgfl;
            return;
        }
    }
    
    // 处理进度条的显示
    id<NSPercentage> idrFetching = [self.classForFetchingIdentifier temporary];
    if ([idrFetching isKindOfClass:[UIView class]]) {
        UIView* vIdr = (id)idrFetching;
        self.fetchingIdentifier = vIdr;
    }
    if ([idrFetching respondsToSelector:@selector(percentageBegan:)])
        [idrFetching percentageBegan:idrFetching];
    
    // 使用 SDImage 来下载图片
    [self setImageWithURL:url
         placeholderImage:placeholder
                  options:options
                 progress:^(NSUInteger receivedSize, long long expectedSize)
     {
         if (expectedSize == -1)
             return;
         NSPercentage* per = [NSPercentage percentWithMax:expectedSize value:receivedSize];
         [self.touchSignals emit:kSignalImageFetching withResult:per];
         
         if ([idrFetching respondsToSelector:@selector(percentage:value:)])
             [idrFetching percentage:idrFetching value:per];
     }
                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
     {
         if (error)
         {
             LOG("下载图片 %s 失败", url.absoluteString.UTF8String);
             [error log];
             
             // 发出失败的信号
             [self.touchSignals emit:kSignalImageFetchFailed withResult:error];
             
             if ([idrFetching respondsToSelector:@selector(percentage:value:error:)])
                 [idrFetching percentage:idrFetching value:nil error:error];
         }
         else
         {
             // 获得到缓存中得地址
             NSString* fs = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
             fs = [[SDImageCache sharedImageCache] defaultCachePathForKey:fs];
             self.cachedImagePath = fs;
             
             // 发送信号
             [self.touchSignals emit:kSignalImageFetched withResult:image];
             
             if ([idrFetching respondsToSelector:@selector(percentageDone:value:)])
                 [idrFetching percentageDone:idrFetching value:nil];
             
             // 添加到 flymake 中，采用 addinstance 因为 setimagewithurl 通常是异步加载
             [[UIImageFlymakeCache shared] addInstance:^id{
                 return self.image;
             } withKey:url];
         }
         
         // 图片下载完成
         if ([idrFetching respondsToSelector:@selector(percentageEnd:value:complete:)])
             [idrFetching percentageEnd:idrFetching value:nil complete:error != nil];
         self.fetchingIdentifier = nil;
     }
     ];
}

+ (NSString*)PathInCacheForImageUrl:(NSURL*)url {
    SDWebImageManager* mgr = [SDWebImageManager sharedManager];
    NSString* str = [mgr cacheKeyForURL:url];
    str = [mgr.imageCache defaultCachePathForKey:str];
    return str;
}

+ (NSString*)PathExistsInCacheForImageUrl:(NSURL*)url {
    NSString* str = [[self class] PathInCacheForImageUrl:url];
    if ([[FSApplication shared] existsFile:str])
        return str;
    return nil;
}

- (CGSize)bestSize:(CGSize)sz {
    return [self.image bestSize:sz];
}

- (CGSize)bestSize {
    return self.image.size;
}

- (void)SWIZZLE_CALLBACK(layout_subviews) {
    [super SWIZZLE_CALLBACK(layout_subviews)];
    CGRect rc = self.rectForLayout;
    if (self.fetchingIdentifier) {
        CGSize sz = self.fetchingIdentifier.bestSize;
        if (sz.width == 0)
            sz.width = rc.size.width;
        if (sz.height == 0)
            sz.height = rc.size.height;
        self.fetchingIdentifier.size = sz;
        self.fetchingIdentifier.center = CGRectCenter(self.bounds);
    }
}

@dynamic images, highlightImages;

- (void)setImages:(UIImages *)images {
    self.animationImages = images.images;
    self.animationDuration = images.duration;
}

- (UIImages*)images {
    UIImages* ret = [UIImages temporary];
    ret.images = self.animationImages;
    ret.duration = self.animationDuration;
    return ret;
}

- (void)setHighlightImages:(UIImages *)highlightImages {
    self.highlightedAnimationImages = highlightImages.images;
    self.animationDuration = highlightImages.duration;
}

- (UIImages*)highlightImages {
    UIImages* ret = [UIImages temporary];
    ret.images = self.highlightedAnimationImages;
    ret.duration = self.animationDuration;
    return ret;
}

@end

@interface UIImageViewExt ()

@property (nonatomic, retain) UIImage *originImage;

@end

@implementation UIImageViewExt

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.clipsToBounds = YES;
    [self onInit];
    return self;
}

- (id)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    self.clipsToBounds = YES;
    if (UIEdgeInsetsEqualToEdgeInsets(image.capInsets, UIEdgeInsetsZero))
        self.contentMode = UIViewContentModeScaleAspectFit;
    [self onInit];
    return self;
}

- (id)initWithStates:(NSDictionary*)si {
    self = [super initWithZero];
    self.states = si;
    return self;
}

- (void)dealloc {
    [self onFin];
    
    ZERO_RELEASE(_originImage);
    ZERO_RELEASE(_states);
    ZERO_RELEASE(_currentState);
    ZERO_RELEASE(_imageBlur);
    ZERO_RELEASE(_imageFilter);
    [super dealloc];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalStateChanged)
SIGNAL_ADD(kSignalBoundsChanged)
SIGNALS_END

@synthesize paddingEdge, offsetEdge;

- (void)setImage:(UIImage *)image {
    if (self.supportAnimatedFormat == NO && image.images.count) {
        image = image.images.firstObject;
    }
    
    UIImage* oldimage = self.originImage;    
    self.originImage = image;
    if (self.fadesChanging && image)
    {
        [UIView transitionWithView:self
                          duration:kCAAnimationDuration
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [super setImage:self.processedImage];
                        } completion:^(BOOL finished) {
                            PASS;
                        }];
    }
    else
    {
        [super setImage:self.processedImage];
    }
        
    if (oldimage != nil)
        [NSTrailChange SetChange];
    
    // 信号发出
    [self.touchSignals emit:kSignalImageChanged withResult:self.image];
    [[UIImageView shared].touchSignals emit:kSignalImageChanged withResult:self];
}

- (void)changeImage:(UIImage *)img {
    self.originImage = img;
    [super setImage:self.processedImage];
}

- (void)setImageBlur:(CGBlur *)imageBlur {
    // 不能判断是否是同一个 blur，以防止重用时没用
    PROPERTY_RETAIN(_imageBlur, imageBlur);
    [self changeImage:self.originImage];
}

- (void)setImageFilter:(CGFilter *)imageFilter {
    PROPERTY_RETAIN(_imageFilter, imageFilter);
    [self changeImage:self.originImage];
}

- (UIImage*)processedImage {
    UIImage* ret = self.originImage;
    
    if (self.imageBlur) {
        ret = [ret imageBlur:self.imageBlur];
    }
    
    if (self.imageFilter) {
        ret = [ret imageFilter:self.imageFilter];
    }
    
    return ret;
}

- (void)setCurrentState:(id)currentState {
    PROPERTY_RETAIN(_currentState, currentState);
    
    [self __updateState];
    
    [self.touchSignals emit:kSignalStateChanged];
}

- (void)changeState:(id)state {
    PROPERTY_RETAIN(_currentState, state);
}

- (void)setStates:(NSDictionary *)states {
    PROPERTY_RETAIN(_states, states);
    [self __updateState];
}

- (void)__updateState {
    if (_states.count == 0)
        return;
    
    if (_currentState == nil) {
        [self changeState:nil];
        self.image = nil;
        return;
    }
    
    id obj = [_states objectForKey:_currentState];
    self.imageDataSource = obj;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rc = self.bounds;
    [self callOnLayout:rc];
}

- (void)setFrame:(CGRect)frame {
    CGRect rc = self.frame;
    if (CGRectEqualToRect(rc, frame))
        return;
    
    [super setFrame:frame];
    
    if (CGSizeEqualToSize(rc.size, frame.size) == NO)
        [self.touchSignals emit:kSignalBoundsChanged];
}

@end

@implementation UIImageViewCache

+ (unsigned long long)ByteSize {
    return [SDImageCache sharedImageCache].getSize;
}

+ (void)Clear {
    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] clearMemory];
}

@end

@implementation UIConstraintView

SIGNALS_BEGIN
SIGNAL_ADD(kSignalConstraintChanged)
SIGNALS_END

- (CGSize)constraintBounds {
    return CGSizeZero;
}

@end

@implementation UIViewWrapper

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.layer.masksToBounds = YES;
    return self;
}

- (id)initWithView:(UIView *)view {
    self = [super initWithZero];
    self.contentView = view;
    self.frame = view.frame;
    return self;
}

- (void)onInit {
    [super onInit];
    self.ignoreContentViewTransform = YES;
}

- (void)dealloc {
    ZERO_RELEASE(_contentView);
    ZERO_RELEASE(_preferredRect);
    ZERO_RELEASE(_preferredAnchorTo);
    [super dealloc];
}

+ (id)wrapperWithView:(UIView *)view {
    return [[[self alloc] initWithView:view] autorelease];
}

+ (id)wrapperWithView:(UIView*)view paddingEdge:(CGPadding)paddingEdge {
    UIViewWrapper* ret = [self.class wrapperWithView:view];
    ret.paddingEdge = paddingEdge;
    return ret;
}

- (UIView*)behalfView {
    return self.contentView;
}

- (void)setContentView:(UIView *)contentView {
    if (_contentView == contentView)
        return;

    [_contentView removeFromSuperview];
    if (contentView.superview != self)
        [self addSubview:contentView];
    
    PROPERTY_RETAIN(_contentView, contentView);
}

- (void)onLayout:(CGRect)rc {
    [super onLayout:rc];
    rc = self.bounds;
    rc = CGRectApplyOffset(rc, self.offsetEdge);
    
    if (self.leftView) {
        UIHBox* box = [UIHBox boxWithRect:rc];
        [box addPixel:self.leftView.frame.size.width toView:self.leftView];
        [box apply];
    }
    
    if (self.rightView) {
        UIHBox* box = [UIHBox boxWithRect:rc];
        [box addFlex:1 toView:nil];
        [box addPixel:self.rightView.frame.size.width toView:self.rightView];
        [box apply];
    }
    
    if (self.topView) {
        UIVBox* box = [UIVBox boxWithRect:rc];
        [box addPixel:self.topView.frame.size.height toView:self.topView];
        [box apply];
    }
    
    if (self.bottomView) {
        UIVBox* box = [UIVBox boxWithRect:rc];
        [box addFlex:1 toView:nil];
        [box addPixel:self.bottomView.frame.size.height toView:self.bottomView];
        [box apply];
    }
    
    if (self.ignoreContentViewTransform) {
        if (self.preferredRect) {
            [self.contentView setFrame:self.preferredRect.rect];
        } else if (self.preferredAnchorTo) {
            CGPoint pt = CGRectGetAnchorPoint(rc, self.preferredAnchorTo.point);
            [self.contentView setCenter:pt];
        } else {
            rc = CGRectApplyPadding(rc, self.paddingEdge);
            [self.contentView setFrame:rc];
        }
    } else {
        if (self.preferredRect) {
            [self.contentView setAbsoluteFrame:self.preferredRect.rect];
        } else if (self.preferredAnchorTo) {
            CGPoint pt = CGRectGetAnchorPoint(rc, self.preferredAnchorTo.point);
            [self.contentView setAbsoluteCenter:pt];
        } else {
            rc = CGRectApplyPadding(rc, self.paddingEdge);
            [self.contentView setAbsoluteFrame:rc];
        }
    }
}

- (BOOL)isHighlightEnable {
    if ([super isHighlightEnable])
        return YES;

    return [self.contentView.touchSignals isConnected:kSignalClicked] ||
    [self.contentView.touchSignals isConnected:kSignalLongClicked] ||
    [self.contentView.touchSignals isConnected:kSignalDbClicked];
}

- (void)updateData {
    [super updateData];
    [_contentView updateData];
}

- (void)setLeftView:(UIView *)leftView {
    CGPadding pad = self.paddingEdge;
    pad.left -= _leftView.frame.size.width;
    CGFloat val = leftView.frame.size.width;
    if (val == 0)
        val = leftView.bestWidth;
    if (val == 0)
        val = [leftView.class BestWidth];
    pad.left += val;
    self.paddingEdge = pad;
    
    if (_leftView != leftView) {
        [_leftView removeFromSuperview];
        _leftView = leftView;
        [self addSubview:_leftView];
    }
    _leftView.width = val;

    [self setNeedsLayout];
}

- (void)setRightView:(UIView *)rightView {
    CGPadding pad = self.paddingEdge;
    pad.right -= _rightView.frame.size.width;
    CGFloat val = rightView.frame.size.width;
    if (val == 0)
        val = rightView.bestWidth;
    if (val == 0)
        val = [rightView.class BestWidth];
    pad.right += val;
    self.paddingEdge = pad;
    
    if (_rightView != rightView) {
        [_rightView removeFromSuperview];
        _rightView = rightView;
        [self addSubview:_rightView];
    }
    _rightView.width = val;
    
    [self setNeedsLayout];
}

- (void)setTopView:(UIView *)topView {
    CGPadding pad = self.paddingEdge;
    pad.top -= _topView.frame.size.height;
    CGFloat val = topView.frame.size.height;
    if (val == 0)
        val = topView.bestHeight;
    if (val == 0)
        val = [topView.class BestHeight];
    pad.top += val;
    self.paddingEdge = pad;
    
    if (_topView != topView) {
        [_topView removeFromSuperview];
        _topView = topView;
        [self addSubview:_topView];
    }
    _topView.height = val;
    
    [self setNeedsLayout];
}

- (void)setBottomView:(UIView *)bottomView {
    CGPadding pad = self.paddingEdge;
    pad.bottom -= _bottomView.frame.size.height;
    CGFloat val = bottomView.frame.size.height;
    if (val == 0)
        val = bottomView.bestHeight;
    if (val == 0)
        val = [bottomView.class BestHeight];
    pad.bottom += val;
    self.paddingEdge = pad;
    
    if (_bottomView != bottomView) {
        [_bottomView removeFromSuperview];
        _bottomView = bottomView;
        [self addSubview:_bottomView];
    }
    _bottomView.height = val;
    
    [self setNeedsLayout];
}

@end

@implementation UIViewControllerWrapper

- (id)init {
    self = [super init];
    self.classForView = [UIViewWrapper class];
    return self;
}

- (id)initWithViewController:(UIViewController *)vc {
    self = [self init];
    self.viewController = vc;
    return self;
}

+ (id)wrapperWithViewController:(UIViewController *)vc {
    return [[[self alloc] initWithViewController:vc] autorelease];
}

- (void)setViewController:(UIViewController *)viewController {
    [self removeSubcontroller:_viewController];
    _viewController = viewController;
    [self addSubcontroller:_viewController];
    
    UIViewWrapper* view = (UIViewWrapper*)self.view;
    view.contentView = _viewController.view;
}

- (NSString*)title {
    return _viewController.title;
}

- (void)setTitle:(NSString *)title {
    _viewController.title = title;
}

@end

@implementation UISwitch (extension)

+ (CGSize)BestSize:(CGSize)sz {
    CGFloat ret = 52;
    if (kIOSMajorVersion < 7)
        ret = 76;
    return CGSizeMake(ret, 36);
}

- (CGSize)bestSize:(CGSize)sz {
    return [self.class BestSize:sz];
}

@end

@interface UISwitchExt ()
{
    UISwitch* _sys;
    UIView* _sw;
}

@end

@implementation UISwitchExt

- (void)onInit {
    [super onInit];
    
    CGSize sz = [UISwitch BestSize];
    if (kIOSMajorVersion < 7 && 0) {
        //cus = [[UIFlatSwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 36)];
        //[self addSubview:cus];
        //SAFE_RELEASE(cus);
    } else {
        _sys = [[UISwitch alloc] initWithFrame:CGRectMakeWithSize(sz)];
        [self addSubview:_sys];
        SAFE_RELEASE(_sys);
    
        [_sys addTarget:self action:@selector(__swvaluechanged:withEvent:) forControlEvents:UIControlEventValueChanged];
    }
    
    _sw = TRIEXPRESS(_sys, _sys, nil);
    
    // 设置初始大小
    [self setSize:sz];
}

- (void)onFin {
    [super onFin];
}

+ (CGSize)BestSize:(CGSize)sz {
    return [UISwitch BestSize:sz];
}

- (CGSize)bestSize:(CGSize)sz {
    CGSize ret = [self.class BestSize:sz];
    if (titleLabel) {
        CGSize sztl = [titleLabel bestSize];
        ret.height = MAX(ret.height, sztl.height);
        ret.width += sztl.width + 5;
    }
    return ret;
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    UIHBox* box = [UIHBox boxWithRect:rect];
    if (titleLabel) {
        [box addFlex:1 toView:titleLabel];
        [box addPixel:5 toView:nil];
    }
    [box addPixel:_sw.frame.size.width toView:_sw set:^(CGRect rc, UIView *view) {
        view.center = CGRectCenter(rc);
    }];
    [box apply];
}

- (void)__swvaluechanged:(id)sender withEvent:(UIEvent *)event {
    [self.touchSignals emit:kSignalValueChanged withResult:[NSBoolean boolean:self.on]];
}

@dynamic onTintColor, tintColor, thumbTintColor, onImage, offImage, on;

- (void)setOnTintColor:(UIColor *)onTintColor {
    if (_sys)
        _sys.onTintColor = onTintColor;
}

- (UIColor*)onTintColor {
    if (_sys)
        return _sys.onTintColor;
    return nil;
}

- (void)setTintColor:(UIColor *)tintColor {
    if (_sys)
        _sys.tintColor = tintColor;
    //_sw.tintColor = tintColor;
}

- (UIColor*)tintColor {
    if (_sys)
        return _sys.tintColor;
    //return _sw.tintColor;
    return nil;
}

- (void)setThumbTintColor:(UIColor *)thumbTintColor {
    if (_sys)
        _sys.thumbTintColor = thumbTintColor;
    //_sw.thumbTintColor = thumbTintColor;
}

- (UIColor*)thumbTintColor {
    if (_sys)
        return _sys.thumbTintColor;
    //return _sw.thumbTintColor;
    return nil;
}

- (void)setOnImage:(UIImage *)onImage {
    if (_sys)
        _sys.onImage = onImage;
    //_sw.onImage = onImage;
}

- (UIImage*)onImage {
    if (_sys)
        return _sys.onImage;
    //return _sw.onImage;
    return nil;
}

- (void)setOffImage:(UIImage *)offImage {
    if (_sys)
        _sys.offImage = offImage;
    //_sw.offImage = offImage;
}

- (UIImage*)offImage {
    if (_sys)
        return _sys.offImage;
    return nil;
}

- (void)setOn:(BOOL)on {
    if (_sys)
        _sys.on = on;
    //_sw.on = on;
}

- (BOOL)on {
    if (_sys)
        return _sys.on;
    return NO;
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    if (_sys)
        [_sys setOn:on animated:animated];
    //[_sw setOn:on animated:animated];
}

- (void)setOn {
    self.on = YES;
}

- (void)setOff {
    self.on = NO;
}

- (void)toggle {
    [self toggle:YES];
}

- (void)toggle:(BOOL)animated {
    [self setOn:!self.on animated:animated];
}

@dynamic textFont, textColor, text, textAlignment;

- (void)setTextFont:(UIFont *)textFont {
    self.titleLabel.textFont = textFont;
}

- (UIFont*)textFont {
    return self.titleLabel.textFont;
}

- (void)setTextColor:(UIColor *)textColor {
    self.titleLabel.textColor = textColor;
}

- (UIColor*)textColor {
    return self.titleLabel.textColor;
}

- (void)setText:(NSString *)text {
    self.titleLabel.text = text;
}

- (NSString*)text {
    return self.titleLabel.text;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    self.titleLabel.textAlignment = textAlignment;
}

- (NSTextAlignment)textAlignment {
    return self.titleLabel.textAlignment;
}

@synthesize titleLabel;

- (UILabelExt*)titleLabel {
    if (titleLabel)
        return titleLabel;
    titleLabel = [UILabelExt temporary];
    [self addSubview:titleLabel];
    return titleLabel;
}

- (void)setTitleLabel:(UILabelExt *)lbl {
    [titleLabel removeFromSuperview];
    titleLabel = lbl;
    [self addSubview:titleLabel];
}

@end

@implementation UIImage (extension)

+ (UIImage*)CopyImagePropertiesTo:(UIImage*)to From:(UIImage*)frm {
    if (UIEdgeInsetsEqualToEdgeInsets(frm.capInsets, UIEdgeInsetsZero) == NO) {
        if (kIOS6Above)
            to = [to resizableImageWithCapInsets:frm.capInsets resizingMode:frm.resizingMode];
        else
            to = [to resizableImageWithCapInsets:frm.capInsets];
    }
    return to;
}

- (UIImage*)adaptivedImage {
    UIImage* ret = self;
    if (kUIScreenIsRetina && self.scale == 1)
        ret = [UIImage imageWithCGImage:self.CGImage
                                  scale:kUIScreenScale
                            orientation:self.imageOrientation];
    return ret;
}

- (UIImage*)imageScaled:(CGFloat)scale {
    if (self.scale == scale)
        return self;
    return [UIImage imageWithCGImage:self.CGImage
                               scale:scale
                         orientation:self.imageOrientation];
}

+ (UIImage*)bundleNamed:(NSString*)name {
    return [[UIImageFlymakeCache shared] addInstance:^id{
        return [UIRetina loadImageNamed:name];
    } withKey:name];
}

+ (UIImage*)stretchImage:(NSString *)name {
    return [self stretchImage:name anchorPoint:kCGAnchorPointCenter];
}

+ (UIImage*)stretchImage:(NSString*)name anchorPoint:(CGPoint)pt {
    return [[UIImageFlymakeCache shared] addInstance:^id{
        UIImage* image = [UIRetina loadImageNamed:name];
        CGSize imgSize = image.size;
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(imgSize.height * pt.y,
                                                                    imgSize.width * pt.x,
                                                                    imgSize.height * (1 - pt.y),
                                                                    imgSize.width * (1 - pt.x))];
# ifdef DEBUG_MODE
        if (image == nil)
            INFO("没有找到图片 %s", name.UTF8String);
# endif
        return image;
    } withKey:[name stringByAppendingFormat:@"::stretch::anchor::%f,%f", pt.x, pt.y]];
}

+ (UIImage*)stretchImage:(NSString*)name atPoint:(CGPoint)pt {
    return [[UIImageFlymakeCache shared] addInstance:^id{
        UIImage* image = [UIRetina loadImageNamed:name];
        CGSize imgSize = image.size;
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(pt.y,
                                                                    pt.x,
                                                                    imgSize.height - pt.y,
                                                                    imgSize.width - pt.x)];
# ifdef DEBUG_MODE
        if (image == nil)
            INFO("没有找到图片 %s", name.UTF8String);
# endif
        return image;
    } withKey:[name stringByAppendingFormat:@"::stretch::position::%f,%f", pt.x, pt.y]];
}

+ (UIImage*)stretchImageHov:(NSString*)name {
    return [UIImage stretchImage:name anchorPoint:kCGAnchorPointTC];
}

+ (UIImage*)stretchImageVec:(NSString*)name {
    return [UIImage stretchImage:name anchorPoint:kCGAnchorPointLC];
}

- (UIImage*)imageClip:(CGRect)rc {
    UIGraphicsBeginImageContextWithOptions(rc.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextTranslateCTM(ctx, 0, -self.size.height);
    
    CGContextDrawImage(ctx, CGRectMake(-rc.origin.x, rc.origin.y, self.size.width, self.size.height), self.CGImage);
    UIImage* ret = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return ret;
}

- (UIImage*)imageResize:(CGSize)sz contentMode:(UIViewContentMode)mode {
    CGClipRect rcwork = CGSizeMapInSize(self.size, sz, mode);
    rcwork.full = CGRectIntegral(rcwork.full);
    rcwork.work = CGRectIntegral(rcwork.work);
    
    /*
    CGImageRef srcImg = self.CGImage;
    CGContextRef imgCtx = CGBitmapContextCreate(NULL,
                                                rcwork.full.size.width, rcwork.full.size.height,
                                                CGImageGetBitsPerComponent(srcImg),
                                                CGImageGetBytesPerRow(srcImg),
                                                CGImageGetColorSpace(srcImg),
                                                CGImageGetBitmapInfo(srcImg));
    */
    
    UIGraphicsBeginImageContextWithOptions(rcwork.work.size, NO, self.scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 反转原始图
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextTranslateCTM(ctx, 0, -rcwork.work.size.height);
    
    // 移动工作区域
    rcwork.full.origin.x = rcwork.work.origin.x - rcwork.full.origin.x;
    rcwork.full.origin.y = rcwork.work.origin.y - rcwork.full.origin.y;

    CGContextDrawImage(ctx, rcwork.full, self.CGImage);
    UIImage* ret = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return ret;
}

+ (NSArray*)imagesNamed:(NSString *)name, ... {
    NSMutableArray* ret = [NSMutableArray array];
    va_list va;
    va_start(va, name);
    UIImage* img = [UIImage imageWithContentOfNamed:name];
    while (img) {
        [ret addObject:img];
        NSString* name = va_arg(va, NSString*);
        if (name == nil)
            break;
        img = [UIImage imageWithContentOfNamed:name];
    }
    va_end(va);
    return ret;
}

+ (NSArray*)imagesNamedFromArray:(NSArray*)arr {
    return [arr arrayWithCollector:^id(NSString* l) {
        return [UIImage imageWithContentOfNamed:l];
    }];
}

+ (UIImage*)imageWithContentOfNamed:(NSString*)name {
    return [[UIImageFlymakeCache shared] addInstance:^id{
        return [UIRetina loadImageNamed:name];
    } withKey:name];
}

+ (UIImage*)imageWithContentOfDataSource:(id)ds {
    if ([ds isKindOfClass:[NSDataSource class]])
    {
        NSDataSource* dsobj = ds;
        if (dsobj.sync)
        {
            NSData* da = [NSData dataWithContentsOfDataSource:ds];
            return [self.class imageWithData:da];
        }
    
        NSString* fs = [UIImageView PathExistsInCacheForImageUrl:dsobj.url];
        if (fs != nil) {
            return [self.class imageWithContentsOfFile:fs];
        }
        
        // 异步处理
        UIImage* ret = [self init];
        [ret asyncDownloadImageByURL:dsobj.url];
        return ret;
    }
    
    if ([ds isKindOfClass:[NSString class]])
    {
        return [self imageWithContentOfNamed:ds];
    }
    
    return nil;
}

+ (CGSize)BestSize:(CGSize)imgsz constraintIn:(CGSize)sz constraintMax:(CGSize)maxsz {
    CGSize ret = CGSizeZero;
    if (CGSizeEqualToSize(imgsz, CGSizeZero))
        return ret;
    
    // 等比映射到 constraintSize 空间
    if (sz.width < sz.height) {
        if (imgsz.width) {
            CGFloat rt = sz.width / imgsz.width;
            ret.height = imgsz.height * rt;
        }
        ret.width = ret.height * (imgsz.width / imgsz.height);
    } else {
        if (imgsz.height) {
            CGFloat rt = sz.height / imgsz.height;
            ret.width = imgsz.width * rt;
        }
        ret.height = ret.width * (imgsz.height / imgsz.width);
    }
    
    ret = CGSizeIntegral(ret);
    
    // 判断长度是否小于最大大小，否则认为是超长图，就需要依据最大大小再次缩放
    if (ret.height > maxsz.height) {
        ret.width = ret.width / ret.height * maxsz.height;
        ret.height = maxsz.height;
    }
    
    if (ret.width > maxsz.width) {
        ret.height = ret.height / ret.width * maxsz.width;
        ret.width = maxsz.width;
    }
    
    ret = CGSizeIntegral(ret);
    
    return ret;
}

+ (CGSize)BestSize:(CGSize)imgsz constraintIn:(CGSize)sz {
    return [UIImage BestSize:imgsz constraintIn:sz constraintMax:kUIApplicationSize];
}

- (CGSize)bestSize:(CGSize)cssz {
    return [UIImage BestSize:self.size constraintIn:cssz];
}

- (UIImage*)imageSubtleBlur {
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    return [self imageBlurWithRadius:5 tintColor:tintColor saturationDeltaFactor:1.8];
}

- (UIImage*)imageLightBlur {
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    return [self imageBlurWithRadius:30 tintColor:tintColor saturationDeltaFactor:1.8];
}

- (UIImage*)imageExtraLightBlur {
    UIColor *tintColor = [UIColor colorWithWhite:0.97 alpha:0.82];
    return [self imageBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8];
}

- (UIImage*)imageDarkBlur {
    UIColor *tintColor = [UIColor colorWithWhite:0.11 alpha:0.73];
    return [self imageBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8];
}

- (UIImage*)imageBlur:(CGBlur*)blur {
    if (blur == nil)
        return self;
    return [self imageBlurWithRadius:blur.radius
                           tintColor:[UIColor colorWithCGColor:blur.tintColor]
               saturationDeltaFactor:blur.saturation];
}

- (UIImage*)imageBlurWithRadius:(CGFloat)blurRadius
                      tintColor:(UIColor*)tintColor
          saturationDeltaFactor:(CGFloat)saturationDeltaFactor
{
    // 模拟器上内部加速会获得比 gpu 加速更高的性能
    if (kDeviceRunningSimulator)
        return [self accelerateImageBlurWithRadius:blurRadius tintColor:tintColor saturationDeltaFactor:saturationDeltaFactor];
    return [self gpuImageBlurWithRadius:blurRadius tintColor:tintColor saturationDeltaFactor:saturationDeltaFactor];
}

// 使用显卡加速来生成模糊效果
- (UIImage*)gpuImageBlurWithRadius:(CGFloat)blurRadius
                                tintColor:(UIColor*)tintColor
                    saturationDeltaFactor:(CGFloat)saturationDeltaFactor
{
    // 经过测试，需要对 saturation 进行统一偏移才能达到两个方法出来的 blur 效果近似
    blurRadius *= 0.2f;
    
    GPUImageiOSBlurFilter* filter = [[GPUImageiOSBlurFilter alloc] init];
    filter.blurRadiusInPixels = blurRadius;
    filter.saturation = saturationDeltaFactor;
    
    GPUImagePicture* picture = [[GPUImagePicture alloc] initWithImage:self];
    [picture addTarget:filter];
    
    [filter useNextFrameForImageCapture];
    [picture processImage];
    
    UIImage* img = [filter imageFromCurrentFramebuffer];
    if (tintColor) {
        CGFilterTintColor* f = [CGFilterTintColor temporary];
        f.color = tintColor.CGColor;
        img = [img imageFilter:f];
    }
    
    ZERO_RELEASE(filter);
    ZERO_RELEASE(picture);
    return img;
}

// 使用原生加速来生成模糊效果
- (UIImage*)accelerateImageBlurWithRadius:(CGFloat)blurRadius
                      tintColor:(UIColor*)tintColor
          saturationDeltaFactor:(CGFloat)saturationDeltaFactor
{
    // Check pre-conditions.
    if (self.size.width < 1 || self.size.height < 1) {
        LOG("图片尺寸错误");
        return nil;
    }
    if (!self.CGImage) {
        LOG("图片数据错误，缺少 CGImage");
        return nil;
    }
    
    CGRect imageRect = { CGPointZero, self.size };
    UIImage *effectImage = self;
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -self.size.height);
        CGContextDrawImage(effectInContext, imageRect, self.CGImage);
        
        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            NSUInteger radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if (!effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // Set up output context.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, imageRect, self.CGImage);
    
    // Draw effect image.
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    // Add in color tint.
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

- (void)saveAs:(NSString*)name {
    NSData* data = UIImagePNGRepresentation(self);
    NSString* fn = [[FSApplication shared] pathWritable:[name stringByAppendingString:@".png"]];
    [data writeToFile:fn atomically:YES];
}

- (void)saveTo:(NSString*)file {
    NSData* data = nil;
    NSString* ext = [file pathExtension];
    if ([ext isEqualToString:@"jpg"]) {
        data = UIImageJPEGRepresentation(self, 1);
    } else if ([ext isEqualToString:@"png"]) {
        data = UIImagePNGRepresentation(self);
    }
    if (data == nil) {
        WARN("从 Image 中获得图像数据失败");
        return;
    }
    [data writeToFile:file atomically:YES];
}

- (UIImage*)imageAlpha:(CGFloat)alpha {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawAtPoint:CGPointZero blendMode:kCGBlendModeNormal alpha:alpha];
    UIImage* output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [UIImage CopyImagePropertiesTo:output From:self];
}

- (UIImage*)imageFlip:(BOOL)vertical {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (vertical) {
        CGContextTranslateCTM(ctx, 0, self.size.height);
        CGContextScaleCTM(ctx, 1, -1);
    } else {
        CGContextTranslateCTM(ctx, self.size.width, 0);
        CGContextScaleCTM(ctx, -1, 1);
    }
    [self drawAtPoint:CGPointZero];
    UIImage* output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [UIImage CopyImagePropertiesTo:output From:self];
}

- (UIImage*)imageFlipVertical {
    return [self imageFlip:YES];
}

- (UIImage*)imageFlipHorizon {
    return [self imageFlip:NO];
}

- (UIImage*)imageFilter:(CGFilter *)filter {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextTranslateCTM(ctx, 0, -self.size.height);
    CGContextScaleCTM(ctx, 1/self.scale, 1/self.scale);
    
    [filter processImage:self.CGImage inContext:ctx];
    
    UIImage* output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return output;
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalImageFetched)
SIGNAL_ADD(kSignalImageFetchFailed)
SIGNALS_END

+ (instancetype)clearImage {
    static UIImage *__gs_image_clear = nil;
    if (__gs_image_clear == nil)
        __gs_image_clear = [UIImage new];
    return __gs_image_clear;
}

@end

@implementation UIImage (asyncdownload)

static char uiimage_async_key;

- (void)asyncDownloadImageByURL:(NSURL*)url {
    [self _cancelCurrentImageLoad];
    
    if (url) {
        id<SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadWithURL:url
                                                                                     options:0
                                                                                    progress:nil
                                                                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
                                             {
                                                 dispatch_main_sync_safe(^{
                                                     if (image) {
                                                         [self.signals emit:kSignalImageFetched withResult:image];
                                                     } else {
                                                         [self.signals emit:kSignalImageFetchFailed withResult:error];
                                                     }
                                                     
                                                     // 清除operation
                                                     objc_setAssociatedObject(self, &uiimage_async_key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                                                 });
                                             }];
        objc_setAssociatedObject(self, &uiimage_async_key, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)_cancelCurrentImageLoad {
    id<SDWebImageOperation> operation = objc_getAssociatedObject(self, &uiimage_async_key);
    if (operation) {
        [operation cancel];
        objc_setAssociatedObject(self, &uiimage_async_key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end

@implementation UIBackgroudImage

+ (UIImage*)imageNamed:(NSString *)name {
    UIImage* img = [UIImage imageNamed:name];
    object_setClass(img, [UIBackgroudImage class]);
    return img;
}

@end

@implementation UIRetina

+ (NSString*)pathOfImageNamed:(NSString*)name {
    NSString* ret = nil;
    NSBundle* bd = [NSBundle mainBundle];
    
    if (kUIScreenIsRetina)
    {
        // 带 extension 的分段查找
        if (ret == nil)
        {
            NSRegularExpression* renormal = [NSRegularExpression cachedRegularExpressionWithPattern:@"([0-9a-z\\-_\\./]+)\\.([0-9a-z]+)$"
                                                                                            options:NSRegularExpressionCaseInsensitive error:nil];
            NSArray* result = [renormal stringsMatchedInString:name options:0 range:NSMakeRange(0, name.length)];
            if (result.count)
            {
                NSString* fn = [result.firstObject objectAtIndex:1];
                NSString* ext = [result.firstObject objectAtIndex:2];
                NSString* tmp = nil;
                
                if (kUIScreenSizeType == kUIScreenSizeB)
                {
                    tmp = [fn stringByAppendingString:@"-568h@2x"];
                    ret = [bd pathForResource:tmp ofType:ext];
                }
                
                if (ret == nil)
                {
                    tmp = [fn stringByAppendingString:@"@3x"];
                    ret = [bd pathForResource:tmp ofType:ext];
                }
                
                if (ret == nil)
                {
                    tmp = [fn stringByAppendingString:@"@2x"];
                    ret = [bd pathForResource:tmp ofType:ext];
                }
                
                if (ret == nil)
                {
                    tmp = fn;
                    ret = [bd pathForResource:tmp ofType:ext];
                }
            }
        }

        if (ret == nil)
        {
            NSString* tmp = nil;
            
            if (kUIScreenSizeType == kUIScreenSizeB)
            {
                tmp = [name stringByAppendingString:@"-568h@2x"];
                ret = [bd imageNamed:tmp];
            }
            
            if (ret == nil)
            {
                tmp = [name stringByAppendingString:@"@3x"];
                ret = [bd imageNamed:tmp];
            }
            
            if (ret == nil)
            {
                tmp = [name stringByAppendingString:@"@2x"];
                ret = [bd imageNamed:tmp];
            }
        }
    }
    else
    {
        // 非 retina 屏幕，但是此时的文件名可能没有2x 比率
        NSString* tmp = nil;
        
        if (ret == nil)
        {
            ret = [bd imageNamed:name];
        }
        
        if (ret == nil)
        {
            tmp = [name stringByAppendingString:@"@3x"];
            ret = [bd imageNamed:tmp];
        }
        
        if (ret == nil)
        {
            tmp = [name stringByAppendingString:@"@2x"];
            ret = [bd imageNamed:tmp];
        }
    }
    
    if (ret == nil) {
        ret = [bd imageNamed:name];
    }
        
    return ret;
}

+ (UIImage*)loadImageNamed:(NSString *)name {
    NSString* path = [self.class pathOfImageNamed:name];
    if (path.notEmpty == NO)
        return nil;
    
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    if (image == nil) {
        image = [UIImage imageNamed:name];
    }
    
    if (kUIScreenIsRetina) {
        if (image.scale == 1)
            image = [UIImage imageWithCGImage:image.CGImage
                                        scale:kUIScreenScale
                                  orientation:image.imageOrientation];
    }
    
    return image;
}

@end

@implementation UIWebView (extension)

@dynamic title;

- (NSString*)title {
    return [self stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)setTitle:(NSString *)title {
    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.title=\"%@\"", title]];
}

- (NSString *)stringByEvaluatingJavaScriptFromFomat:(NSString *)script, ... {
    va_list va;
    va_start(va, script);
    NSString* str = [[NSString alloc] initWithFormat:script arguments:va];
    va_end(va);
    NSString* ret = [self stringByEvaluatingJavaScriptFromString:str];
    SAFE_RELEASE(str);
    return ret;
}

- (NSString*)htmlString {
    return [self stringByEvaluatingJavaScriptFromString:@"document"];
}

- (void)setHtmlString:(NSString *)htmlString {
    [self loadHTMLString:htmlString baseURL:[NSBundle mainBundle].resourceURL];
}

- (NSString*)runJavascript:(NSString*)str {
    return [self stringByEvaluatingJavaScriptFromString:str];
}

@end

@implementation UIWebView (callback)

- (void)simulateNativeApp:(BOOL)val {
    self.scrollView.bounces = !val;
    self.scrollView.scrollEnabled = !val;
    self.scrollView.bouncesZoom = !val;
    if (val) {
        self.scrollView.showsScrollIndicator = NO;
    }
}

- (void)setJSObject:(id)obj forName:(NSString*)name {
    if ([name isEqualToString:@"native"])
        return;
    NSMutableDictionary* dict = [self.attachment.strong objectForKey:@"_::js::objects" create:^id{
        return [NSMutableDictionary dictionary];
    }];
    [dict setObject:obj forKey:name];
}

- (id)jsobjectForName:(NSString*)name {
    if ([name isEqualToString:@"native"])
        return self.belongViewController;
    NSDictionary* dict = [self.attachment.strong objectForKey:@"_::js::objects"];
    return [dict objectForKey:name];
}

- (NSArray*)allJSObjects {
    NSDictionary* dict = [self.attachment.strong objectForKey:@"_::js::objects"];
    return dict.allValues;
}

- (NSMutableArray*)additionJavascripts {
    return [self.attachment.strong objectForKey:@"_::js::additions" create:^id{
        return [NSMutableArray array];
    }];
}

- (void)addJSObject:(id<UIJavascriptObject>)jsobj {
    NSString* name = [jsobj nameForJavascriptObject];
    if (name.notEmpty == NO) {
        FATAL("JSObject 的 name 不能为空");
        return;
    }
    
    // 先得保存 jsobj
    [self setJSObject:jsobj forName:name];
    
    // 遍历所有的 method，找出需要生成回调的
    NSMutableArray* arrSels = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray* arrFuns = [[NSMutableArray alloc] initWithCapacity:10];
    [NSClass ForeachMethod:^BOOL(Method mth) {
        char const* name = sel_getName(method_getName(mth));
        if (strncmp(name, "js_", 3) != 0)
            return YES;
        [arrSels addObject:[NSString stringWithCString:(name + 3) encoding:NSASCIIStringEncoding]];
        return YES;
    } forClass:[jsobj class]];
    
    // 生成js函数列表, this.xx = function (a, b) {};
    for (NSString* strsel in arrSels) {
        NSMutableString* jsstr = [[NSMutableString alloc] initWithCapacity:256];
        [jsstr appendString:@"this."];
        NSArray* comps = [strsel componentsSeparatedByString:@":"];
        [jsstr appendString:comps.firstObject];
        [jsstr appendString:@"= function ("];
        
        if (comps.count == 2) {
            [jsstr appendString:[comps objectAtIndex:1]];
        } else {
            for (uint i = 1; i < comps.count - 1; ++i) {
                NSString* comp = [comps objectAtIndex:i];
                [jsstr appendString:comp];
                if (i != comps.count - 2)
                    [jsstr appendString:@","];
            }
        }
        
        [jsstr appendString:@") {"];
        [jsstr appendString:@"var argus = escape(encodeURIComponent(JSON.stringify(arguments)));"];
        [jsstr appendFormat:@"var api = 'app://callback/invoke/%@/' + escape('js_%@') + '/' + argus;", name, strsel];
        // 由于 window.location 不能在短时间(during short interval)内多次被调用，所以修改成为 iframe 方式.
        [jsstr appendString:@"var cbframe = document.createElement('IFRAME');"];
        [jsstr appendString:@"cbframe.setAttribute('src', api);"];
        [jsstr appendString:@"document.body.appendChild(cbframe);"];
        [jsstr appendString:@"cbframe.parentNode.removeChild(cbframe);"];
        // 返回的数据
        [jsstr appendString:@"return document.nativeapp_returnvalue;"];
        [jsstr appendString:@"};"];
        
        [arrFuns addObject:jsstr];
        SAFE_RELEASE(jsstr);
    }
    SAFE_RELEASE(arrSels);
    
    // 遍历 func 生成 js
    NSMutableString* js = [[NSMutableString alloc] initWithCapacity:256];
    [js appendFormat:@"window.%@ = new function () {", name];
    for (NSString* fun in arrFuns) {
        [js appendString:fun];
    }
    [js appendString:@" return this; };"];
    SAFE_RELEASE(arrFuns);
    
    // 应用
    [self stringByEvaluatingJavaScriptFromString:js];
    [[self additionJavascripts] addObject:js];
    
    SAFE_RELEASE(js);
}

- (BOOL)canProcessCallback:(NSURL*)url {
    if ([url.scheme isEqualToString:@"app"] == NO)
        return NO;
    if ([url.host isEqualToString:@"callback"] == NO)
        return NO;
    NSArray* comps = url.pathComponents;
    return comps.count == 5;
}

- (void)processCallback:(NSURL*)url {
    NSArray* comps = url.pathComponents;
    NSString* action = [comps objectAtIndex:1];
    if ([action isEqualToString:@"invoke"]) {
        NSString* objname = [comps objectAtIndex:2];
        NSString* objmethod = [[comps objectAtIndex:3] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString* arguments = [[comps objectAtIndex:4] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [self invokeCallback:objname withMethod:objmethod withArgument:arguments.jsonObject];
    }
}

- (void)invokeCallback:(NSString*)objname withMethod:(NSString*)method withArgument:(NSDictionary*)argument {
    id obj = [self jsobjectForName:objname];
    if (obj == nil) {
        FATAL("没有找到 web 回调 %@ 对应的对象", objname);
        return;
    }
    
    // 调用
    Class cls = [obj class];
    SEL sel = sel_registerName(method.UTF8String);
    NSMethodSignature* sig = [cls instanceMethodSignatureForSelector:sel];
    NSInvocation* inv = [NSInvocation invocationWithMethodSignature:sig];
    [inv setSelector:sel];
    [inv setTarget:obj];
    
    for (int i = 0; i < argument.count; ++i) {
        id val = [argument objectForKey:@(i).stringValue];
        [inv setArgument:&val atIndex:i+2];
    }
    
    id ret = nil;
    if (strcmp(sig.methodReturnType, @encode(void)) == 0) {
        // 没有返回值
        [inv invoke];
    } else {
        // 含有有返回值
        [inv invoke];
        [inv getReturnValue:&ret];
    }
    
    // 返回值压回web
    if (ret == nil)
    {
        ret = @"null";
    }
    else if ([ret isKindOfClass:[NSString class]])
    {
        // 如果是string，则需要用 “” 括起来，但是要注意“”嵌套的问题
        ret = [ret stdStringValue];
    }
    else if ([ret isKindOfClass:[NSNumber class]])
    {
        // 数字直接填写进去
        ret = [ret stringValue];
    }
    else
    {
        // 如果不是string或标准类型，则需要打包成json
        ret = [ret jsonString];
        // 为了兼容android只能传标准对象的问题，如果不是标准对象，则使用的是json格式
        ret = [NSString stringWithFormat:@"JSON.stringify(%@)", ret];
    }
    
    NSString* cmd = [NSString stringWithFormat:@"document.nativeapp_returnvalue=%@", ret];
    [self stringByEvaluatingJavaScriptFromString:cmd];
}

- (void)useAdditionJavascripts {
    NSArray* jss = [self.attachment.strong objectForKey:@"_::js::additions"];
    for (NSString* each in jss) {
        [self stringByEvaluatingJavaScriptFromString:each];
    }
}

@end

# ifdef DEVELOP_MODE

@class WebView;
@class WebFrame;
@class WebScriptCallFrame;

@interface UIWebViewDebugObject : NSObjectExt

@end

@implementation UIWebViewDebugObject

- (void)webView:(WebView *)webView idParseSource:(NSString *)source
 baseLineNumber:(unsigned)lineNumber
        fromURL:(NSURL *)url
       sourceId:(int)sid
    forWebFrame:(WebFrame *)webFrame
{
    PASS;
}

// some source failed to parse
- (void)webView:(WebView *)webView
failedToParseSource:(NSString*)source
 baseLineNumber:(unsigned)lineNumber
        fromURL:(NSURL *)url
      withError:(NSError *)error
    forWebFrame:(WebFrame *)webFrame
{
    [error log];
    
    NSMutableString* str = [NSMutableString string];
    [str appendFormat:@"UIWebView failedToParse: %@\n", url];
    [str appendFormat:@"line: %d\n", lineNumber];
    [str appendFormat:@"%@", source];
    WARN(str.UTF8String);
}

- (void)webView:(WebView *)webView exceptionWasRaised:(WebScriptCallFrame *)frame
       sourceId:(int)sid
           line:(int)lineno
    forWebFrame:(WebFrame *)webFrame
{
    NSMutableString* str = [NSMutableString string];
    [str appendString:@"UIWebView exception: \n"];
    [str appendFormat:@"line: %d\n", lineno];
    OBJC_NOEXCEPTION({
        [str appendFormat:@"function: %@" COMMA [frame performSelector:@selector(functionName)]];
    });
    INFO(str.UTF8String);
}

// 为了避免出现 warning，实际上没有作用
- (void)functionName {}
- (void)setScriptDebugDelegate:(id)d {}

@end

# endif

@interface UIWebViewExt ()

# ifdef DEVELOP_MODE
@property (nonatomic, readonly) UIWebViewDebugObject *objDebug;
# endif

@end

@implementation UIWebViewExt

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
# ifdef DEVELOP_MODE
    _objDebug = [[UIWebViewDebugObject alloc] init];
# endif
    return self;
}

- (void)dealloc {
# ifdef DEVELOP_MODE
    ZERO_RELEASE(_objDebug);
# endif
    [super dealloc];
}

# ifdef DEVELOP_MODE

- (void)webView:(WebView*)webView windowScriptObjectAvailable:(id)newWindowScriptObject {
    [webView performSelector:@selector(setScriptDebugDelegate:) withObject:_objDebug];
}

- (void)webView:(WebView*)webView didClearWindowObject:(id)windowObject forFrame:(WebFrame*)frame {
    [webView performSelector:@selector(setScriptDebugDelegate:) withObject:_objDebug];
}

# endif

@end

@interface UIWebViewController ()
<UIWebViewDelegate,
UIJavascriptObject
>

@end

@implementation UIWebViewController

- (void)onInit {
    [super onInit];
    
    self.hidesBottomBarWhenPushed = YES;
    self.classForView = [UIWebViewExt class];
    self.delegate = self;
    self.autosyncTitle = YES;
}

- (void)onFin {
    ZERO_RELEASE(_request);
    ZERO_RELEASE(_cookies);
    ZERO_RELEASE(_userAgent);
    
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalContentLoading)
SIGNAL_ADD(kSignalContentLoaded)
SIGNAL_ADD(kSignalContentLoadFailed)
SIGNAL_ADD(kSignalDuplicatedObject)
SIGNAL_ADD(kSignalLinkClicked)
SIGNALS_END

- (void)onLoaded {
    [super onLoaded];
    
    UIWebViewExt* view = (id)self.view;
    view.scalesPageToFit = YES;
    view.delegate = self;
    if (self.simulateNativeApp)
        [view simulateNativeApp:YES];
    
    // 自身就可以回调js，但是区别于普通的回调对象，自身是不放到jsobj链表之中
    [view addJSObject:self];
}

- (void)setRequestString:(NSString *)requestString {
    self.request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestString]];
}

- (NSString*)requestString {
    return self.request.URL.absoluteString;
}

- (void)setRequestURL:(NSURL *)requestURL {
    self.request = [NSURLRequest requestWithURL:requestURL];
}

- (NSURL*)requestURL {
    return self.request.URL;
}

- (void)onFirstAppeared {
    [super onFirstAppeared];
    [self reloadData];
}

- (void)reloadData {
    if (self.request == nil)
        return;
    if (self.request.URL == nil)
        return;
    
    // 清缓存
    if (self.purifyCache)
        [self clearCache];
    
    // 配置 cookie
    if (self.cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:self.cookies forURL:self.request.URL mainDocumentURL:nil];
    }
    
    NSMutableURLRequest* req = [NSMutableURLRequest mutableRequestWithRequest:self.request];
    
    // set cache
    if (self.cacheExpiration) {
        req.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
        req.timeoutInterval = self.cacheExpiration;
    }
    
    // addcookies
    [req addCookies:[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies];
    
    // set ua.
    if (self.userAgent) {
        [req setUserAgent:self.userAgent];
    }
    
    // 打开
    [self.webView loadRequest:req];
}

+ (void)ClearCaches {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)clearCache {
    if (self.request == nil)
        return;
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:self.request];
}

@dynamic webView;

- (UIWebView*)webView {
    return (UIWebView*)self.view;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    LOG("WebView 访问 %s", request.URL.absoluteString.UTF8String);
    
    // 处理回调
    if ([self.webView canProcessCallback:request.URL]) {
        [self.webView processCallback:request.URL];
        return NO;
    }
    
    if (navigationType != UIWebViewNavigationTypeLinkClicked)
        return YES;
    
    // 点中了link
    [self.touchSignals emit:kSignalLinkClicked withResult:request.URL];
    
    // 如果没有navi，则也没办法推入下一页，只能本地刷新一下
    if (self.navigationController == nil)
        return YES;
    
    UIWebViewController* ctlr = nil;
    if (_delegate &&
        [_delegate respondsToSelector:@selector(webViewControllerForForward:)])
    {
        ctlr = [_delegate webViewControllerForForward:self];
    } else {
        ctlr = [self webViewControllerForForward:self];
    }
    
    // 如果是空或者自己，则都用自己打开连接
    if (ctlr == nil || ctlr == self)
        return YES;
    
    // 更新 title
    [ctlr.signals connect:kSignalContentLoaded withSelector:@selector(__act_subwebctlr_loaded:) ofTarget:self];
    [ctlr.signals connect:kSignalDuplicatedObject redirectTo:kSignalDuplicatedObject ofTarget:self];
    
    // 绑定一些数据
    ctlr.request = request;
    if (ctlr.cookies == nil)
        ctlr.cookies = self.cookies;

    // 推入显示
    [self.navigationController pushViewController:ctlr animated:YES];
    
    return NO;
}

- (id)copyWithZone:(NSZone *)zone {
    UIWebViewController* ret = [[[self class] alloc] init];
    ret.autosyncTitle = self.autosyncTitle;
    ret.purifyCache = self.purifyCache;
    ret.request = self.request;
    ret.cookies = self.cookies;
    ret.userAgent = self.userAgent;
    ret.cacheExpiration = self.cacheExpiration;
    ret.simulateNativeApp = self.simulateNativeApp;
    return ret;
}

- (UIWebViewController*)webViewControllerForForward:(UIWebViewController *)vc {
    // 实例化一个新的web
    UIWebViewController* ret = [self clone];
    
    // 如果需要继承JS
    if ([_delegate respondsToSelector:@selector(webViewControllerInheritJSObjects:)] &&
        [_delegate webViewControllerInheritJSObjects:self]
        )
    {
        for (id each in self.webView.allJSObjects) {
            [self.webView addJSObject:each];
        }
    }
    
    // 释放信号以让业务层后处理
    [self.touchSignals emit:kSignalDuplicatedObject withResult:ret];
    return ret;
}

- (BOOL)webViewControllerInheritJSObjects:(UIWebViewController*)vc {
    return NO;
}

- (void)__act_subwebctlr_loaded:(SSlot*)s {
    UIWebViewController* ctlr = (UIWebViewController*)s.sender;
    if (self.autosyncTitle) {
        NSString* title = ctlr.webView.title;
        if (title.notEmpty)
            ctlr.title = title;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.touchSignals emit:kSignalContentLoading];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.webView useAdditionJavascripts];
    [self.touchSignals emit:kSignalContentLoaded];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.touchSignals emit:kSignalContentLoadFailed withResult:error];
}

// 内置的一些标准JS函数

- (NSString*)nameForJavascriptObject {
    return @"native";
}

- (void)js_log:(NSString*)str {
    LOG(str.UTF8String);
}

- (void)js_info:(NSString*)str {
    INFO(str.UTF8String);
}

- (void)js_warn:(NSString*)str {
    WARN(str.UTF8String);
}

- (void)js_fatal:(NSString*)str {
    FATAL(str.UTF8String);
}

@end

@implementation UIGestureRecognizer (extension)

SIGNALS_BEGIN
[self addTarget:self action:@selector(__cb_gesture)];
SIGNAL_ADD(kSignalGesture)
SIGNAL_ADD(kSignalGestureBegan)
SIGNAL_ADD(kSignalGestureEnded)
SIGNAL_ADD(kSignalGestureChanged)
SIGNAL_ADD(kSignalGestureCancel)
SIGNAL_ADD(kSignalGesturePossible)
SIGNAL_ADD(kSignalGestureFailed)
SIGNAL_ADD(kSignalGestureRecognized)
SIGNALS_END

- (void)__cb_gesture {
    BOOL ava = YES;
    SSignal* sig = nil;
    switch (self.state) {
        case UIGestureRecognizerStateBegan: {
            sig = kSignalGestureBegan;
            [self __ges_began];
        } break;
        case UIGestureRecognizerStateEnded: {
            sig = kSignalGestureEnded;
            [self __ges_end];
        } break;
        case UIGestureRecognizerStateChanged: {
            sig = kSignalGestureChanged;
        } break;
        case UIGestureRecognizerStateCancelled: {
            sig = kSignalGestureCancel;
            ava = NO;
        } break;
        case UIGestureRecognizerStatePossible: {
            sig = kSignalGesturePossible;
        } break;
        case UIGestureRecognizerStateFailed: {
            sig = kSignalGestureFailed;
            ava = NO;
        } break;
    }
    
    if (sig == nil) {
        WARN("没有绑定该手势状态的信号");
        return;
    }
    
    if (self.isValidRecognizer == NO)
        return;

    if (ava)
    {
        UIView* belong = self.view;
        CGPoint pt = [self locationInView:self.view];
        belong.extension.preferredPositionTouched = [NSPoint point:pt];
        
        // 处理手势数据
        [self __ges_process];
        
        // 激活信号
        [[UIKit shared].touchSignals emit:sig withResult:self];
        [[UIKit shared].touchSignals emit:kSignalGesture withResult:self];
        
        [self.touchSignals emit:sig];
        [self.touchSignals emit:kSignalGesture];
    }
    else
    {
        [[UIKit shared].touchSignals emit:sig withResult:self];

        // 激活信号
        [self.touchSignals emit:sig];
    }
}

- (BOOL)isValidRecognizer {
    return YES;
}

- (void)foreachTouch:(BOOL(^)(CGPoint pt, NSInteger idx))touch inView:(UIView*)view {
    NSInteger num = self.numberOfTouches;
    for (NSInteger i = 0; i < num; ++i) {
        CGPoint pt = [self locationOfTouch:i inView:view];
        if (touch(pt, i) == NO)
            break;
    }
}

- (void)__ges_began {
    PASS;
}

- (void)__ges_process {
    PASS;
}

- (void)__ges_end {
    PASS;
}

@end

@implementation UIPanGestureRecognizer (extension)

NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR(UIPanGestureRecognizer, direction, setDirection, CGDirection, @(val), [val intValue], RETAIN_NONATOMIC);
NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR(UIPanGestureRecognizer, velocity, setVelocity, CGPoint, [NSPoint point:val], [val point], RETAIN_NONATOMIC);
NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR(UIPanGestureRecognizer, translation, setTranslation, CGPoint, [NSPoint point:val], [val point], RETAIN_NONATOMIC);
NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR(UIPanGestureRecognizer, delta, setDelta, CGPoint, [NSPoint point:val], [val point], RETAIN_NONATOMIC);
NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR(UIPanGestureRecognizer, offset, setOffset, CGPoint, [NSPoint point:val], [val point], RETAIN_NONATOMIC);

SIGNALS_BEGIN
SIGNAL_ADD(kSignalDirectionChanged)
SIGNALS_END

- (void)__ges_began {
    [super __ges_began];
    self.delta = CGPointZero;
    self.translation = CGPointZero;
}

- (void)__ges_end {
    [super __ges_end];
    self.direction = kCGDirectionUnknown;
}

- (void)__ges_process {
    [super __ges_process];
    
    CGPoint vel = [self velocityInView:self.view];
    CGDirection dir = 0;
    
    if (vel.x > 0)
        dir |= kCGDirectionFromLeft;
    else
        dir |= kCGDirectionFromRight;
    
    if (vel.y > 0)
        dir |= kCGDirectionFromBottom;
    else
        dir |= kCGDirectionFromTop;
 
    if (self.direction != dir) {
        self.direction = dir;
        [self.touchSignals emit:kSignalDirectionChanged withResult:@(dir)];
    }
    
    self.velocity = vel;

    CGPoint pt = [self translationInView:self.view];
    self.delta = CGPointSubPoint(pt, self.translation);
    self.offset = CGPointAddPoint(self.offset, self.delta);
    self.translation = pt;
}

- (BOOL)isValidRecognizer {
    if (self.numberOfTouches == 0)
        return YES;
    return self.numberOfTouches >= self.minimumNumberOfTouches &&
    self.numberOfTouches <= self.maximumNumberOfTouches;
}

@end

@implementation UIPinchGestureRecognizer (extension)

NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR(UIPanGestureRecognizer, zoom, setZoom, CGFloat, @(val), [val floatValue], RETAIN_NONATOMIC);
NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR2(UIPanGestureRecognizer, previousZoom, setPreviousZoom, CGFloat, @(val), [val floatValue], RETAIN_NONATOMIC);

- (float)delta {
    return self.scale;
}

- (void)__ges_began {
    [super __ges_began];
    [self setPreviousZoom:self.zoom];
}

- (void)__ges_process {
    [super __ges_process];
    CGFloat r = [self previousZoom];
    if (r == 0)
        r = 1;
    self.zoom = r * self.scale;
}

@end

@interface UIUnifiedGestureTouches ()
{
    BOOL _touching, _recing;
}

@property (nonatomic, assign) UIView *view;

@end

@implementation UIUnifiedGestureTouches

- (void)setView:(UIView *)view {
    _view = view;
    [_view.signals connect:kSignalTouchesBegan withSelector:@selector(__cb_touches_began:) ofTarget:self];
    [_view.signals connect:kSignalTouchesMoved withSelector:@selector(__cb_touches_moved:) ofTarget:self];
    [_view.signals connect:kSignalTouchesEnded withSelector:@selector(__cb_touches_end:) ofTarget:self];
    [_view.signals connect:kSignalTouchesCancel withSelector:@selector(__cb_touches_cancel:) ofTarget:self];
}

- (void)addGestureRecognizer:(UIGestureRecognizer *)rec {
    [_view addGestureRecognizer:rec];
    [rec.signals connect:kSignalGestureBegan withSelector:@selector(__cb_gesture_began:) ofTarget:self];
    [rec.signals connect:kSignalGestureEnded withSelector:@selector(__cb_gesture_end:) ofTarget:self];
    [rec.signals connect:kSignalGestureCancel withSelector:@selector(__cb_gesture_cancel:) ofTarget:self];
    [rec.signals connect:kSignalGesture withSelector:@selector(__cb_gesture:) ofTarget:self];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalStart)
SIGNAL_ADD(kSignalDone)
SIGNAL_ADD(kSignalGesture)
SIGNAL_ADD(kSignalGestureRecognized)
SIGNAL_ADD(kSignalTouchesMoved)
SIGNALS_END

- (void)__cb_gesture_began:(SSlot*)s {
    _recing = YES;
    if (!_touching)
        [self.touchSignals emit:kSignalStart];
}

- (void)__cb_gesture_cancel:(SSlot*)s {
    if (!_touching)
        [self.touchSignals emit:kSignalDone];
    _recing = NO;
}

- (void)__cb_gesture_end:(SSlot*)s {
    // 需要清理一下 touches 的数据，以避免误认为是 touches，而导致一些延迟动画错误
    self.view.extension.currentTouch = nil;
    [self.touchSignals emit:kSignalDone];
    _recing = NO;
}

- (void)__cb_gesture:(SSlot*)s {
    [self.touchSignals emit:kSignalGestureRecognized withResult:s.sender];
}

- (void)__cb_touches_began:(SSlot*)s {
    _touching = YES;
    if (!_recing)
        [self.touchSignals emit:kSignalStart];
}

- (void)__cb_touches_end:(SSlot*)s {
    [self.touchSignals emit:kSignalDone];
    _touching = NO;
}

- (void)__cb_touches_moved:(SSlot*)s {
    [self.touchSignals emit:kSignalTouchesMoved];
}

- (void)__cb_touches_cancel:(SSlot*)s {
    if (!_recing)
        [self.touchSignals emit:kSignalDone];
    _touching = NO;
}

@end

@implementation UIView (unified_gt)

NSOBJECT_DYNAMIC_PROPERTY_READONLY_EXT(UIView, unifiedGestureTouches, UIUnifiedGestureTouches, {
    val.view = self;
});

@end

CGFloat kUIDesktopAnimationDuration = .3f;

@interface UIDesktopView ()

@property (nonatomic, assign) UIDesktop* desktop;

@end

@implementation UIDesktopView

- (void)onInit {
    [super onInit];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    rect = CGRectApplyPadding(rect, self.desktop.contentPadding);
    self.desktop.content.view.frame = rect;
    
    // 再次尝试一下布局当前view
    [self.desktop.content.view onPosition:rect];
}

- (void)onAddedToSuperview {
    [super onAddedToSuperview];
    
    // 做打开的动画
    if (self.desktop.viewSource && self.desktop.viewDest)
    {
        self.desktop.viewDest.hidden = YES;
        // 原图片
        UIImage* imgSrc = nil;
        UIViewContentMode imgMode = UIViewContentModeScaleAspectFill;
        if (imgSrc == nil) {
            if ([self.desktop.viewSource respondsToSelector:@selector(image)]) {
                imgSrc = [self.desktop.viewSource performSelector:@selector(image)];
                imgMode = self.desktop.viewSource.contentMode;
            } else {
                imgSrc = self.desktop.viewSource.renderToImage;
            }
        }
        
        // 用来做移动动画的
        UIImageViewExt* viewSrc = [UIImageViewExt viewWithImage:imgSrc];
        viewSrc.contentMode = imgMode;
        viewSrc.frame = self.desktop.viewSource.screenFrame;
        [UIView animateWithDuration:kUIDesktopAnimationDuration
                         animations:^{
                             CGRect cntRc = [self.desktop.viewDest bestBehalfRegion:self.bounds.size];
                             viewSrc.frame = cntRc;
                         }
                         completion:^(BOOL finished) {
                             self.desktop.viewDest.hidden = NO;
                             [viewSrc removeFromSuperview];
                         }];
        [self addSubview:viewSrc];
    }
    
    // 渐变背景色
    UIColor* color = [self.backgroundColor retain];
    if (color != [UIColor clearColor])
    {
        self.layer.backgroundColor = [UIColor clearColor].CGColor;
        [UIView animateWithDuration:kUIDesktopAnimationDuration animations:^{
            self.layer.backgroundColor = color.CGColor;
        }];
    }
    SAFE_RELEASE(color);
}

- (void)open {
    UIViewController* root = [UIAppDelegate shared].topmostViewController;
    self.frame = root.view.bounds;
    [root.view addSubview:self];
}

- (void)close {
    [self removeFromSuperview];
}

@end

@interface UIDesktop ()
{
    BOOL _opening, _closing;
}

@end

@implementation UIDesktop

- (void)onInit {
    [super onInit];
    self.classForView = [UIDesktopView class];
    self.clickToClose = YES;
    self.backgroundColor = [UIDesktop BackgroundColor];
}

- (id)initWithContent:(UIViewController *)vc {
    self = [self init];
    self.content = vc;
    
    [vc.signals addSignal:kSignalRequestClose];
    [vc.view.signals addSignal:kSignalRequestClose];
    [vc.view.signals connect:kSignalRequestClose ofTarget:vc];
    
    return self;
}

+ (instancetype)desktopWithContent:(UIViewController *)vc {
    return [[[self alloc] initWithContent:vc] autorelease];
}

+ (instancetype)desktopWithView:(UIView *)v {
    UIViewControllerExt* vc = [[UIViewControllerExt alloc] init];
    vc.view = v;
    
    UIDesktop* ret = [self desktopWithContent:vc];
    SAFE_RELEASE(vc);
    return ret;
}

- (void)setContent:(UIViewController *)content {
    if (_content == content)
        return;
    
    // 为了防止 content 的 view 点击产生背景高亮，保护处理一下
    [content.view setHighlightFill:nil];
    
    // 移除掉旧的，加入新的
    [self removeSubcontroller:_content];
    PROPERTY_RETAIN(_content, content);
    [self addSubcontroller:_content];
    
    // view 或者 content 的 request close 均会引起 desktop 的 close
    [_content.signals addSignal:kSignalRequestClose];
    [_content.view.signals addSignal:kSignalRequestClose];
    [_content.view.signals connect:kSignalRequestClose redirectTo:kSignalRequestClose ofTarget:_content];
    [_content.signals connect:kSignalRequestClose withSelector:@selector(close) ofTarget:self];
}

- (void)dealloc {
    ZERO_RELEASE(_content);
    ZERO_RELEASE(_backgroundColor);
    ZERO_RELEASE(_highlightViews);
    
    [super dealloc];
}

+ (UIColor*)BackgroundColor {
    return [UIColor colorWithARGB:0x3c000000];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalOpened)
SIGNAL_ADD(kSignalClosed)
SIGNAL_ADD(kSignalRequestClose)
SIGNALS_END

- (void)onLoaded {
    [super onLoaded];
    [self.signals connect:kSignalRequestClose withSelector:@selector(close) ofTarget:self];
}

static NSString* UIDesktopStackKey = @"::ui::desktop::stack";

- (instancetype)open {
    UIViewController* root = [UIAppDelegate shared].topmostViewController;
    return [self openIn:root];
}

- (instancetype)openIn:(UIViewController *)root {
    if (_opening)
        return self;
    _opening = YES;
    
    // 关闭键盘
    [UIKeyboardExt Close];
    
    // 显示view，保护一下，但是会在close的时候release
    SAFE_RETAIN(self);
    
    // 设置 content 的默认大小为总大小
    CGRect rect = root.view.bounds;
    if (CGRectEqualToRect(rect, CGRectZero))
        rect = kUIScreenBounds;
    self.view.frame = rect;
    
    // 刷新布局
    [self.view flushLayout];
    
    // 刷新一下数据，并布局，以为之后的弹出设置好元素大小
    [self.content.view updateData];
    [self.content.view setNeedsLayout];
    
    // 回调处理
    [self cbOpening];
    
    // 将要显示
    [self.content viewWillAppear:YES];
    [self.touchSignals emit:kSignalViewAppearing withResult:self.content];
    
    // 添加目标的view
    [root.view addSubview:self.view];
    
    // 已经显示
    [self.content viewDidAppear:YES];
    [self.touchSignals emit:kSignalViewAppear withResult:self.content];
    
    // 已经打开
    [self.touchSignals emit:kSignalOpened];
    
    // 如果含有强制高亮元素，此时显示
    for (id obj in self.highlightViews) {
        UIView* vobj = [obj behalfView];
        UIImageView* vimg = [UIImageView viewWithImage:vobj.renderToImage];
        vimg.userInteractionEnabled = NO;
        [vimg setPosition:vobj.screenFrame.origin];
        [self.view addSubview:vimg];
    }
    
    // 放到栈里
    [[[NSObject shared].attachment.strong objectForKey:UIDesktopStackKey create:^id{
        return [NSMutableArray temporary];
    }] addObject:self];
    
    // 是否显示 status
    if (self.attributes.statusBarHidden.boolValue)
        [[UIAppDelegate shared].statusBar pushHidden:YES animated:YES];
    
    return self;
}

- (void)cbOpening {
    PASS;
}

- (void)close {
    if (_closing)
        return;
    _closing = YES;
    
    [self.touchSignals emit:kSignalViewDisappearing withResult:self.content];
    
    if (self.view.backgroundColor != [UIColor clearColor]) {
        [UIView animateWithDuration:kUIDesktopAnimationDuration animations:^{
            self.view.layer.opacity = 0;
        } completion:^(BOOL finished) {
            if (finished) {
                [self.view removeFromSuperview];
                [self.touchSignals emit:kSignalViewDisappear withResult:self.content];
            }
        }];
    } else {
        [self.view removeFromSuperview];
        [self.touchSignals emit:kSignalViewDisappear withResult:self.content];
    }
    
    [self.touchSignals emit:kSignalClosed];
    
    // 从栈里移除
    [(NSMutableArray*)[[NSObject shared].attachment.strong objectForKey:UIDesktopStackKey] removeObject:self];
    
    // 显示状态栏
    if (self.attributes.statusBarHidden.boolValue)
        [[UIAppDelegate shared].statusBar pushHidden:NO animated:YES];
    
    SAFE_RELEASE(self);
}

+ (void)CloseAll {
    NSMutableArray* alls = [NSMutableArray arrayWithArray:[[NSObject shared].attachment.strong objectForKey:UIDesktopStackKey]];
    for (UIDesktop* each in alls) {
        [each close];
    }
}

- (instancetype)popup {
    [self.signals connect:kSignalOpened withSelector:@selector(slideFromBottom) ofTarget:self];
    [self.signals connect:kSignalClosed withSelector:@selector(slideToBottom) ofTarget:self];
    return [self open];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIDesktopView* view = (UIDesktopView*)self.view;
    view.backgroundColor = self.backgroundColor;
    view.desktop = self;
    //self.viewDest = view;
    
    // 绑定信号
    [self.content.view.signals connect:kSignalClicked redirectTo:kSignalClicked ofTarget:view];
    [view.signals connect:kSignalClicked withSelector:@selector(__desk_clicked) ofTarget:self];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    PROPERTY_RETAIN(_backgroundColor, backgroundColor);
    if (self.content)
        self.view.backgroundColor = backgroundColor;
}

- (void)__desk_clicked {
    if (self.clickToClose)
        [self close];
}

- (void)slideFromTop {
    [self.content.view.layer addAnimation:[CAKeyframeAnimation SlideFromTop:self.content.view] forKey:nil];
}

- (void)slideFromBottom {
    CGFloat fy = CGRectGetMaxY(self.view.bounds);
    CGFloat ty = CGRectGetY(self.content.view.frame);
    self.content.view.positionY = fy;
    [UIView animateWithDuration:kUIDesktopAnimationDuration
                     animations:^{
                         self.content.view.positionY = ty;
                     }];
}

- (void)slideFromLeft {
    [self.content.view.layer addAnimation:[CAKeyframeAnimation SlideFromLeft:self.content.view] forKey:nil];
}

- (void)slideFromRight {
    [self.content.view.layer addAnimation:[CAKeyframeAnimation SlideFromRight:self.content.view] forKey:nil];
}

- (void)slideToTop {
    [self.content.view.layer addAnimation:[CAKeyframeAnimation SlideToTop:self.content.view] forKey:nil];
}

- (void)slideToBottom {
    [self.content.view.layer addAnimation:[CAKeyframeAnimation SlideToBottom:self.content.view] forKey:nil];
}

- (void)slideToLeft {
    [self.content.view.layer addAnimation:[CAKeyframeAnimation SlideToLeft:self.content.view] forKey:nil];
}

- (void)slideToRight {
    [self.content.view.layer addAnimation:[CAKeyframeAnimation SlideToRight:self.content.view] forKey:nil];
}

- (void)tremble {
    [self.content.view.layer addAnimation:[CAKeyframeAnimation TrembleOut] forKey:nil];
}

- (void)fadeIn {
    [self.content.view.layer addAnimation:[CAKeyframeAnimation FadeIn] forKey:nil];
}

@end

@interface UIPopoverDesktopWrapper : UIViewControllerExt

@property (nonatomic, retain) UIViewController *content;
@property (nonatomic, assign) UIPopoverDesktop *desktop;

@end

@interface UIPopoverDesktopWrapperView : UIScrollViewExt

@end

@implementation UIPopoverDesktopWrapperView

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    UIPopoverDesktopWrapper* ctlr = (id)self.belongViewController;
    CGSize const bsz = [ctlr.content.view bestSize:rect.size];
    switch (ctlr.desktop.direction)
    {
        default: break;
            
        case kCGDirectionFromBottom: {
            UIVBox* box = [UIVBox boxWithRect:rect];
            [box addFlex:1 toView:nil];
            [box addPixel:bsz.height toView:ctlr.content.view];
            [box apply];
        } break;
            
        case kCGDirectionFromTop: {
            UIVBox* box = [UIVBox boxWithRect:rect];
            [box addPixel:bsz.height toView:ctlr.content.view];
            [box apply];
        } break;
            
        case kCGDirectionFromLeft: {
            UIHBox* box = [UIHBox boxWithRect:rect];
            [box addPixel:bsz.width toView:ctlr.content.view];
            [box apply];
        } break;
            
        case kCGDirectionFromRight: {
            UIHBox* box = [UIHBox boxWithRect:rect];
            [box addFlex:1 toView:nil];
            [box addPixel:bsz.width toView:ctlr.content.view];
            [box apply];
        } break;
            
        case kCGDirectionCenter: {
            ctlr.content.view.frame = CGRectClipCenterBySize(rect, bsz);
        } break;
    }
}

@end

@implementation UIPopoverDesktopWrapper

- (void)onInit {
    [super onInit];
    self.classForView = [UIPopoverDesktopWrapperView class];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalRequestClose)
SIGNALS_END

- (void)setContent:(UIViewController *)content {
    if (_content == content)
        return;
    
    [_content.signals disconnect:kSignalRequestClose ofTarget:self];
    [self removeSubcontroller:_content];
    
    _content = content;
    [self addSubcontroller:_content];
    [_content.signals addSignal:kSignalRequestClose];
    [_content.signals connect:kSignalRequestClose ofTarget:self];
}

@end

@implementation UIPopoverDesktop

- (id)init {
    self = [super init];
    _direction = kCGDirectionFromBottom;
    return self;
}

- (void)setContent:(UIViewController*)content {
    [content.signals addSignal:kSignalRequestClose];
    [content.view.signals addSignal:kSignalRequestClose];
    [content.view.signals connect:kSignalRequestClose ofTarget:content];
    
    UIPopoverDesktopWrapper* vc = [UIPopoverDesktopWrapper temporary];
    vc.content = content;
    vc.desktop = self;
    [super setContent:vc];
}

- (void)cbOpening {
    switch (self.direction)
    {
        default: break;
            
        case kCGDirectionFromBottom: {
            [[self.signals connect:kSignalOpened withSelector:@selector(slideFromBottom) ofTarget:self] oneshot];
            [[self.signals connect:kSignalClosed withSelector:@selector(slideToBottom) ofTarget:self] oneshot];
        } break;
            
        case kCGDirectionFromTop: {
            [[self.signals connect:kSignalOpened withSelector:@selector(slideFromTop) ofTarget:self] oneshot];
            [[self.signals connect:kSignalClosed withSelector:@selector(slideToTop) ofTarget:self] oneshot];
        } break;
            
        case kCGDirectionFromLeft: {
            [[self.signals connect:kSignalOpened withSelector:@selector(slideFromLeft) ofTarget:self] oneshot];
            [[self.signals connect:kSignalClosed withSelector:@selector(slideToLeft) ofTarget:self] oneshot];
        } break;
            
        case kCGDirectionFromRight: {
            [[self.signals connect:kSignalOpened withSelector:@selector(slideFromRight) ofTarget:self] oneshot];
            [[self.signals connect:kSignalClosed withSelector:@selector(slideToRight) ofTarget:self] oneshot];
        } break;
    }
}

@end

@interface UINotImplementationView ()

@property (nonatomic, readonly) UILabelExt* lbl;

@end

@implementation UINotImplementationView

- (void)onInit {
    [super onInit];    
    self.backgroundColor = [UIColor grayColor];
    
    _lbl = [[UILabelExt alloc] initWithZero];
    _lbl.text = @"没有实现";
    _lbl.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_lbl];
    SAFE_RELEASE(_lbl);
}

- (void)onLayout:(CGRect)rect {
    _lbl.frame = rect;
}

@end

@implementation UINotImplementationViewController

- (void)onInit {
    [super onInit];
    self.classForView = [UINotImplementationView class];
    self.title = @"没有实现";
}

@end

@interface UIMessageBox ()
<UIAlertViewDelegate>

@property (nonatomic, retain) UIAlertView* alert;

@end

@implementation UIMessageBox

+ (UIMessageBox*)YesNo:(NSString*)title message:(NSString*)message yes:(NSString*)yes no:(NSString*)no {
    return [[[self alloc] initWith:title message:message yes:yes no:no] autorelease];
}

- (id)initWith:(NSString*)title message:(NSString*)message yes:(NSString*)yes no:(NSString*)no {
    self = [super init];
    
    _alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:no otherButtonTitles:yes, nil];
    [_alert show];
    
    return self;
}

+ (instancetype)Ok:(NSString*)title message:(NSString*)message ok:(NSString*)ok {
    return [[[self alloc] initWithOk:title message:message ok:ok] autorelease];
}

- (id)initWithOk:(NSString*)title message:(NSString*)message ok:(NSString*)ok {
    self = [super init];
    
    _alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:ok otherButtonTitles:nil];
    [_alert show];

    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_alert);
    [super dealloc];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalClicked)
SIGNAL_ADD(kSignalOkClicked)
SIGNAL_ADD(kSignalCancelClicked)
SIGNALS_END

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.touchSignals emit:kSignalClicked withResult:[NSNumber numberWithInt:buttonIndex]];
    
    switch (buttonIndex) {
        case 0: {
            [self.touchSignals emit:kSignalCancelClicked];
        } break;
        case 1: {
            [self.touchSignals emit:kSignalOkClicked];
        } break;
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    [self retain];
}

- (void)didPresentAlertView:(UIAlertView *)alertView {
    PASS;
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    PASS;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self release];
}

@end

@implementation NSError (ui)

- (void)show {
    [UIHud Text:self.localizedDescription];
}

@end

@implementation UIProtoViewController

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_view);
    [super dealloc];
}

- (UIView*)view {
    if (_view)
        return _view;
    [self loadView];
    return _view;
}

- (void)loadView {
    _view = [[UIViewExt alloc] initWithZero];
}

- (void)viewWillAppear:(BOOL)animated {
    PASS;
}

- (void)viewDidAppear:(BOOL)animated {
    PASS;
}

- (void)viewWillDisappear:(BOOL)animated {
    PASS;
}

- (void)viewDidDisappear:(BOOL)animated {
    PASS;
}

@end

NSInteger kUIBarItemDefaultPriority = 0;

@implementation UINavigationItem (extension)

- (void)SWIZZLE_CALLBACK(set_titleview):(UIView*)view {
    NSDictionary* dict = [[UINavigationBar appearance] titleTextAttributes];
    if (dict) {
        if ([view respondsToSelector:@selector(setTextFont:)]) {
            if ([(id)view textFont] == [UIFont clearFont]) {
                UIFont* ft = [dict objectForKey:UITextAttributeFont];
                if (ft)
                    [view performSelector:@selector(setTextFont:) withObject:ft];
            }
        }
        if ([view respondsToSelector:@selector(setTextColor:)]) {
            if ([(id)view textColor] == [UIColor clearColor]) {
                UIColor* cr = [dict objectForKey:UITextAttributeTextColor];
                if (cr)
                    [view performSelector:@selector(setTextColor:) withObject:cr];
            }
        }
    }
    
    CGSize sz = view.frame.size;
    if (CGSizeEqualToSize(sz, CGSizeZero))
        sz = [view bestSize:CGSizeMake(kUIApplicationSize.width, kUINavigationBarHeight)];
    if (sz.width == 0)
        sz.width = 220;
    if (sz.height == 0)
        sz.height = kUINavigationBarItemHeight;
    [view setSize:sz];
}

- (void)setWithNavigationItem:(UINavigationItem *)item {
    // 如果自己没有按钮，或者新的对象的按钮比自己优先级别高，则使用新的来替换掉自己

    if (self.leftBarButtonItem == nil ||
       (item.rightBarButtonItem && self.leftBarButtonItem.priority <= item.leftBarButtonItem.priority))
    {
        self.leftBarButtonItem = item.leftBarButtonItem;
    }
        
    //self.leftBarButtonItems = item.leftBarButtonItems;
    //self.leftItemsSupplementBackButton = item.leftItemsSupplementBackButton;
    
    if (self.rightBarButtonItem == nil ||
        (item.rightBarButtonItem && self.rightBarButtonItem.priority <= item.rightBarButtonItem.priority))
    {
        self.rightBarButtonItem = item.rightBarButtonItem;
    }
    
    //self.rightBarButtonItems = item.rightBarButtonItems;
}

- (void)setLeftBarViewItem:(UIView *)leftBarViewItem {
    [self.leftBarButtonItem.customView.signals disconnect:kSignalClicked ofTarget:self.leftBarButtonItem];
    
    if (leftBarViewItem.frame.size.height == 0)
        [leftBarViewItem setHeight:kUINavigationBarItemHeight];
    
    UIBarButtonItem* bi = [[UIBarButtonItem alloc] initWithCustomView:leftBarViewItem];
    self.leftBarButtonItem = bi;
    SAFE_RELEASE(bi);
    
    [leftBarViewItem.signals connect:kSignalClicked redirectTo:kSignalClicked ofTarget:bi];
}

- (UIView*)leftBarViewItem {
    return self.leftBarButtonItem.customView;
}

- (void)setRightBarViewItem:(UIView *)rightBarViewItem {
    [self.rightBarButtonItem.customView.signals disconnect:kSignalClicked ofTarget:self.rightBarButtonItem];
    
    if (rightBarViewItem.frame.size.height == 0)
        [rightBarViewItem setHeight:kUINavigationBarItemHeight];
    
    UIBarButtonItem* bi = [[UIBarButtonItem alloc] initWithCustomView:rightBarViewItem];
    self.rightBarButtonItem = bi;
    SAFE_RELEASE(bi);
    
    [rightBarViewItem.signals connect:kSignalClicked redirectTo:kSignalClicked ofTarget:bi];
}

- (UIView*)rightBarViewItem {
    return self.rightBarButtonItem.customView;
}

@end

@implementation UITextView (extension)

- (void)setTextFont:(UIFont *)textFont {
    self.font = textFont;
}

- (UIFont*)textFont {
    return self.font;
}

- (void)setReadonly:(BOOL)readonly {
    self.editable = !readonly;
}

- (BOOL)readonly {
    return !self.editable;
}

- (CGSize)bestSize {
    return [self bestSize:CGSizeMax];
}

- (CGSize)bestSize:(CGSize)sz {
    if (self.text.notEmpty)
        return [self bestSizeForString:sz];
    return CGSizeZero;
}

+ (CGPadding)PaddingForTextDocument {
    return CGPaddingMake(8, 8, 2, 2);
}

- (CGSize)bestSizeForString:(CGSize)sz {
    NSString* str = self.text;
    
    CGPadding pad = [self.class PaddingForTextDocument];
    if (sz.width != CGVALUEMAX) {
        sz.width -= CGPaddingWidth(pad);
    }
    if (sz.height != CGVALUEMAX) {
        sz.height -= CGPaddingHeight(pad);
    }
    
    //需要处理一下行首、行尾为换行的情况
    if ([str hasSuffix:@"\n"])
        str = [str stringByAppendingString:@"-"];
    
    CGSize ret = [str sizeWithFont:self.font constrainedToSize:sz];
    if (sz.width == CGVALUEMAX)
        ret.width += CGPaddingWidth(pad);
    if (sz.height == CGVALUEMAX)
        ret.height += CGPaddingHeight(pad);

    ret = CGSizeBBXIntegral(ret);
    return ret;
}

- (void)setStylizedString:(NSStylizedString*)str {
    TODO("需要解决富文本样式显示的问题");
    /**
     有几个问题待解决: attr 不能正确显示 stylized 设置的颜色，不支持行距、字间距的设置
     */
    /*
    if (kIOS6Above) {
        NSAttributedString* attstr = str.attributedString;
        self.allowsEditingTextAttributes = NO;
        self.attributedText = attstr;
    } else {
        self.text = str.stringValue;
    }
     */
    self.text = str.stringValue;
}

@end

@interface UITextViewExtImpl : UITextView

@property (nonatomic, assign) UITextViewExt *extTextView;

@end

@interface UITextViewExt ()
<UITextViewDelegate>
{
    UITextViewExtImpl* _textView;
    BOOL _isEditing, _linesChanged;
}

@property (nonatomic, readonly) UITextViewExtImpl *placeholderView;
@property (nonatomic, copy) NSString *lastString;

@end

@implementation UITextViewExtImpl

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    return self;
}

- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType {
    [super setReturnKeyType:returnKeyType];
    _extTextView.returnAsLinebreak = returnKeyType == UIReturnKeyDefault;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    BOOL ret = [super canPerformAction:action withSender:sender];
    if (ret == NO || _extTextView.placeholderView.visible)
        return ret;
    return ret;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return [self.gestureRecognizers containsObject:gestureRecognizer];
}

@end

@implementation UITextViewExt

@synthesize keyboardDodge;
@synthesize textView = _textView;

- (void)onInit {
    [super onInit];
    
    [self addSubview:BLOCK_RETURN({
        _textView = [UITextViewExtImpl temporary];
        _textView.delegate = self;
        _textView.extTextView = self;
        [_textView.signals connect:kSignalFocused ofTarget:self];
        [_textView.signals connect:kSignalFocusedLost ofTarget:self];
        return _textView;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _placeholderView = [UITextViewExtImpl temporary];
        _placeholderView.hidden = YES;
        _placeholderView.readonly = YES;
        _placeholderView.userInteractionEnabled = NO;
        return _placeholderView;
    })];
    
    // 默认的字型
    _placeholderView.textColor = [UIColor colorWithRGB:0xC7C7CD]; // 和 textfield 的一致
    self.textFont = [UIFont systemFontOfSize:17];

    self.returnAsLinebreak = YES;
    self.keyboardDodge = YES;
    
    // 需要监听是否输入的内容导致输入框大小变化
    [_textView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)onFin {
    [_textView removeObserver:self forKeyPath:@"contentSize"];

    ZERO_RELEASE(_stylizedString);
    ZERO_RELEASE(_patternInput);
    ZERO_RELEASE(_patternValue);
    ZERO_RELEASE(_lastString);
    [super onFin];
}

- (BOOL)isFirstResponder {
    return _textView.isFirstResponder;
}

- (BOOL)canBecomeFirstResponder {
    return [_textView canBecomeFirstResponder];
}

- (BOOL)becomeFirstResponder {
    return [_textView becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    [super resignFirstResponder];
    return [_textView resignFirstResponder];
}

SIGNALS_BEGIN

SIGNAL_ADD(kSignalInputInvalid)
SIGNAL_ADD(kSignalInputValid)
SIGNAL_ADD(kSignalValueInvalid)
SIGNAL_ADD(kSignalValueValid)

SIGNAL_ADD(kSignalEdited)
SIGNAL_ADD(kSignalEditing)
SIGNAL_ADD(kSignalLinesChanged)

SIGNAL_ADD(kSignalConstraintChanged)

SIGNAL_ADD(kSignalValueChanged)
SIGNAL_ADD(kSignalKeyboardReturn)

SIGNALS_END

- (void)appendText:(NSString*)text {
    if (text == nil)
        return;
    
    NSString* str = _textView.text;
    str = [str stringByAppendingString:text];
    self.text = str;
}

- (void)appendLineBreak {
    [self appendText:@"\n"];
}

- (void)clear {
    self.text = @"";
}

- (void)setReadonly:(BOOL)readonly {
    _textView.readonly = readonly;
}

- (BOOL)readonly {
    return _textView.readonly;
}

- (void)setContentPadding:(CGPadding)contentPadding {
    CGPadding pad = [UITextView PaddingForTextDocument];
    contentPadding.left -= pad.left;
    if (contentPadding.left < 0)
        contentPadding.left = 0;
    contentPadding.right -= pad.right;
    if (contentPadding.right < 0)
        contentPadding.right = 0;
    contentPadding.top -= pad.top;
    if (contentPadding.top < 0)
        contentPadding.top = 0;
    contentPadding.bottom -= pad.bottom;
    if (contentPadding.bottom < 0)
        contentPadding.bottom = 0;
    self.paddingEdge = contentPadding;
}

- (CGPadding)contentPadding {
    CGPadding pad = [UITextView PaddingForTextDocument];
    CGPadding ret = self.paddingEdge;
    ret.left += pad.left;
    ret.right += pad.right;
    ret.top += pad.top;
    ret.bottom += pad.bottom;
    return ret;
}

- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType {
    _textView.returnKeyType = returnKeyType;
}

- (UIReturnKeyType)returnKeyType {
    return _textView.returnKeyType;
}

- (CGSize)bestSize:(CGSize)sz {
    CGSize ret = CGSizeZero;
    if (_placeholderView.visible)
        ret = [_placeholderView bestSize:sz];
    else
        ret = [_textView bestSize:sz];
    ret = CGSizeUnapplyPadding(ret, self.paddingEdge);
    return ret;
}

- (void)setTextColor:(UIColor *)textColor {
    _textView.textColor = textColor;
    _placeholderView.textColor = [textColor bleachWithValue:.5f];
}

- (UIColor*)textColor {
    return _textView.textColor;
}

- (void)setTextFont:(UIFont *)textFont {
    _textView.textFont = textFont;
    _placeholderView.textFont = textFont;
}

- (UIFont*)textFont {
    return _textView.textFont;
}

- (void)setPlaceholder:(NSString *)text {
    _placeholderView.text = text;
    _placeholderView.hidden = _textView.text.notEmpty;
}

- (NSString*)placeholder {
    return _placeholderView.text;
}

- (void)setText:(NSString *)text {
    BOOL notempty = text.notEmpty;
    
    if (notempty) {
        if ([self checkInputValid:text] == NO) {
            [self.touchSignals emit:kSignalInputInvalid];
            return;
        }
    }
    
    _textView.text = text;
    _placeholderView.hidden = text.notEmpty;
    
    if (notempty) {
        _isValid = [self checkValueValid:text];
        if (self.isValid)
            [self.touchSignals emit:kSignalValueValid];
        else
            [self.touchSignals emit:kSignalValueInvalid];
    }
}

- (NSString*)text {
    return _textView.text;
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    // 因为边距的问题，需要重新调整一下最终的位置
    rect = CGRectDeflate(rect, -6, 0);
    rect = CGRectOffset(rect, 2, 0);
    
    _textView.frame = rect;
    _placeholderView.frame = rect;
}

- (CGRect)frameForKeybaord {
    CGRect rc = [_textView caretRectForPosition:_textView.selectedTextRange.end];
    if (CGRectGetMaxY(rc) > CGRectGetMaxY(_textView.bounds))
        rc = [_textView convertRect:rc toView:nil];
    else
        rc = [self convertRect:self.bounds toView:nil];
    return rc;
}

@dynamic textAlignment;

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    _textView.textAlignment = textAlignment;
    _placeholderView.textAlignment = textAlignment;
}

- (NSTextAlignment)textAlignment {
    return _textView.textAlignment;
}

- (void)setStylizedString:(NSStylizedString *)stylizedString {
    PROPERTY_RETAIN(_stylizedString, stylizedString);
    [_textView setStylizedString:stylizedString];
}

# pragma mark delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [self.signals emit:kSignalEditing];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    _isEditing = YES;
    
    // 避让键盘
    if (self.keyboardDodge)
        [[UIKeyboardExt shared] dodgeView:self];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    _isEditing = NO;
    [self.signals emit:kSignalEdited];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (!self.returnAsLinebreak && [text isEqualToString:@"\n"]) {
        [self.signals emit:kSignalKeyboardReturn];
        self.focus = NO;
        return NO;
    }
    
    // 如果修改的或被修改的含有换行，则激活行数变化的信号
    if ([text rangeOfString:@"\n"].length) {
        _linesChanged = YES;
    } else {
        if (textView.text.notEmpty) {
            NSString* str = [textView.text substringWithRange:range];
            if ([str rangeOfString:@"\n"].length) {
                _linesChanged = YES;
            }
        }
    }
    
    // 修改后的str
    NSString* strAfter = _textView.text;
    strAfter = [strAfter stringByReplacingCharactersInRange:range withString:text];
    
    // 判断
    if ([self checkInputValid:strAfter] == NO) {
        [self.touchSignals emit:kSignalInputInvalid];
        return NO;
    } else {
        [self.touchSignals emit:kSignalInputValid withResult:strAfter];
    }
    
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object != _textView)
        return;
    
    if ([keyPath isEqualToString:@"contentSize"]) {
        [self.signals emit:kSignalConstraintChanged];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    NSString* strAfter = _textView.text;
    if ([strAfter isEqualToString:self.lastString])
        return;
    
    [NSTrailChange SetChange];
    
    if (_linesChanged) {
        [self.signals emit:kSignalLinesChanged];
        _linesChanged = NO;
    }
    
    // 判断是否符合输入规则
    if ([self checkInputValid:strAfter] == NO) {
        [self.touchSignals emit:kSignalInputInvalid];
        strAfter = self.lastString;
        _textView.text = strAfter;
    } else {
        [self.touchSignals emit:kSignalInputValid withResult:strAfter];
    }
    self.lastString = strAfter;
    
    // 判断字数是否是显示place
    if (self.placeholder.notEmpty) {
        _placeholderView.visible = strAfter.length == 0;
    }
    
    // 验证值
    _isValid = [self checkValueValid:strAfter];
    if (_isValid) {
        [self.touchSignals emit:kSignalValueValid];
    } else {
        [self.touchSignals emit:kSignalValueInvalid];
    }
    
    [self.touchSignals emit:kSignalValueChanged withResult:strAfter];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    if (self.keyboardDodge && _isEditing) {
        // 刷新一下键盘规避
        [[UIKeyboardExt shared] dodgeView:self];
    }
}

- (BOOL)checkInputValid:(NSString*)str {
    if (self.patternInput == nil)
        return YES;
    
    NSRange rgFull = NSMakeRange(0, str.length);
    NSRange result = [self.patternInput rangeOfFirstMatchInString:str range:rgFull];
    if (NSEqualRanges(result, rgFull) == NO)
        return NO;
    
    return YES;
}

- (BOOL)checkValueValid:(NSString*)str {
    if (self.patternValue == nil)
        return YES;
    
    NSRange rgFull = NSMakeRange(0, str.length);
    NSRange result = [self.patternValue rangeOfFirstMatchInString:str range:rgFull];
    if (NSEqualRanges(result, rgFull) == NO)
        return NO;
    
    return YES;
}

@end

@interface UIKeyboardExt ()
{
    CGFloat _positiony; // 当前需要规避的位置
    CGFloat _offsety; // 当前的偏移
    CGFloat _diffy; // 与上一次的差异
    UIView *_offsetView; // 应该使用的偏移元素
    CGRect _frameDodge, _framingDodge;
}

@end

static CGFloat kUIKeyboardDefaultHeight = 216;
static CGFloat kUIKeyboardDefaultDuration = 0.25f;

@implementation UIKeyboardExt

SHARED_IMPL;

- (id)init {
    self = [super init];
    
    self.visible = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiCommon:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiCommon:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiCommon:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiCommon:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiCommon:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiCommon:) name:UIKeyboardDidChangeFrameNotification object:nil];
    
    [self.signals connect:UIKeyboardWillShowNotification withSelector:@selector(__kb_showing:) ofTarget:self];
    [self.signals connect:UIKeyboardDidShowNotification withSelector:@selector(__kb_shown:) ofTarget:self];
    [self.signals connect:UIKeyboardWillHideNotification withSelector:@selector(__kb_hiding:) ofTarget:self];
    [self.signals connect:UIKeyboardDidHideNotification withSelector:@selector(__kb_hiden:) ofTarget:self];
    [self.signals connect:UIKeyboardWillChangeFrameNotification withSelector:@selector(actFrameChanging:) ofTarget:self];
    [self.signals connect:UIKeyboardDidChangeFrameNotification withSelector:@selector(actFrameChanged:) ofTarget:self];
    
    [self.signals connect:UIKeyboardWillShowNotification redirectTo:kSignalKeyboardShowing ofTarget:self];
    [self.signals connect:UIKeyboardDidShowNotification redirectTo:kSignalKeyboardShown ofTarget:self];
    [self.signals connect:UIKeyboardWillHideNotification redirectTo:kSignalKeyboardHiding ofTarget:self];
    [self.signals connect:UIKeyboardDidHideNotification redirectTo:kSignalKeyboardHidden ofTarget:self];
    
    // 初始化第一次键盘位置信息
    self.frame = _frameDodge = CGRectMake(0, kUIApplicationSize.height, kUIApplicationSize.width, kUIKeyboardDefaultHeight);
    self.framing = _framingDodge = self.frame;
    
    self.duration = kUIKeyboardDefaultDuration;
    self.animationCurve = UIViewAnimationCurveEaseOut;
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

SIGNALS_BEGIN

SIGNAL_ADD(UIKeyboardWillShowNotification)
SIGNAL_ADD(UIKeyboardDidShowNotification)
SIGNAL_ADD(UIKeyboardWillHideNotification)
SIGNAL_ADD(UIKeyboardDidHideNotification)
SIGNAL_ADD(UIKeyboardWillChangeFrameNotification)
SIGNAL_ADD(UIKeyboardDidChangeFrameNotification)

SIGNAL_ADD(kSignalKeyboardHiding)
SIGNAL_ADD(kSignalKeyboardHidden)
SIGNAL_ADD(kSignalKeyboardShowing)
SIGNAL_ADD(kSignalKeyboardShown)

SIGNAL_ADD(kSignalFrameChanging)
SIGNAL_ADD(kSignalFrameChanged)

SIGNALS_END

- (CGRect)rectInView:(UIView *)view {
    CGRect fs = view.frame;
    CGRect rr = [[UIAppDelegate shared].window.rootViewController.view convertRect:fs fromView:view.superview];
    CGRect krc = [UIKeyboardExt shared].frame;
    krc.size.height -= rr.origin.y;
    return krc;
}

- (void)notiCommon:(NSNotification*)info {
    [self.touchSignals emit:info.name withResult:info.userInfo];
}

- (void)__kb_showing:(SSlot*)s {
    self.visible = YES;
    
    NSDictionary* dict = (NSDictionary*)s.data.object;
    
    self.framing = _framingDodge = [[dict objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    self.frame = _frameDodge = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (self.frame.origin.x < 0)
    {
        // 推进来的键盘
        _framingDodge.origin.x = self.frame.origin.x;
        _framingDodge.origin.y = 0;
    }
    
    self.duration = [[dict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    self.animationCurve = [[dict objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    
    [self doRefreshDodge];
}

- (void)__kb_shown:(SSlot*)s {
    PASS;
}

- (void)__kb_hiding:(SSlot*)s {
    NSDictionary* dict = (NSDictionary*)s.data.object;
    
    self.framing = _framingDodge = [[dict objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    self.frame = _frameDodge = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (self.frame.origin.x < 0)
    {
        // 推出去的键盘
        _frameDodge.origin.x = 0;
        _frameDodge.origin.y += _frameDodge.size.height;
    }
    
    self.duration = [[dict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    self.animationCurve = [[dict objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];

    [self doRefreshDodge];
    
    // 直接设置已经隐藏，以避免中间状态时刷新错误
    self.visible = NO;
}

- (void)__kb_hiden:(SSlot*)s {
    _positiony = _offsety = _diffy = 0;
}

- (void)doRefreshDodge {
    UIView* base = _offsetView;
    if (base == nil)
        return;
    
    CGFloat offset = _frameDodge.origin.y - _positiony;
    if (offset > 0) {
        // 键盘没有遮盖住目标
        if (_offsety != 0) {
            // 需要恢复原状
            [UIView animateWithDuration:self.duration animations:^{
                CGAffineTransform mat = base.transform;
                mat = CGAffineTransformTranslate(mat, 0, -_offsety);
                base.transform = mat;
            }];
        }
        _diffy = _offsety = 0;
        return;
    }
    
    // 被遮盖，需要偏移一下位置
    offset = -_offsety + offset;
    _offsety += offset;
    
    // 需要偏移
    if (offset != 0) {
        [UIView animateWithDuration:self.duration
                         animations:^{
                             CGAffineTransform mat = base.transform;
                             mat = CGAffineTransformTranslate(mat, 0, offset);
                             base.transform = mat;
                         }];
    }
}

- (void)actFrameChanging:(SSlot*)s {
    NSDictionary* dict = (NSDictionary*)s.data.object;
    self.framing = [[dict objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    self.frame = _frameDodge = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.duration = [[dict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    self.animationCurve = [[dict objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    [self.touchSignals emit:kSignalFrameChanging withResult:[NSRect rect:self.frame]];
}

- (void)actFrameChanged:(SSlot*)s {
    NSDictionary* dict = (NSDictionary*)s.data.object;
    self.frame = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.framing = _framingDodge = _frameDodge = self.frame;
    self.duration = [[dict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    self.animationCurve = [[dict objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    [self.touchSignals emit:kSignalFrameChanged withResult:[NSRect rect:self.frame]];
}

- (void)dodgeView:(UIView *)view {
    CGRect vrc = view.frameForKeybaord;
    CGPoint vlb = CGRectLeftBottom(vrc);
    vlb.y -= _offsety;
    if (_positiony != 0) {
        _diffy = vlb.y - _positiony;
    }
    _positiony = vlb.y;
    _offsetView = view.viewForKeyboard;
    if (_offsetView == nil)
        _offsetView = [self.class DodgeViewForView:view];
    [self doRefreshDodge];
}

// 如果遇到父view为scroll或者navigation，则用来进行偏移
+ (UIView*)DodgeViewForView:(UIView*)view {
    UIView* current = view;
    UIView* prev = nil;
    UINavigationController* navi = view.navigationController;
    while (current != nil)
    {
        if (current == navi.view)
            return prev;
        // 1-9 之前用的是 isMemberOfClass，但是会 skip 掉 desktop，如果 desktop 上正好有输入框，则不能正确避让
        if ([current isKindOfClass:[UIScrollView class]] == NO)
            goto NEXT;
        if ([NSStringFromClass(current.class) hasPrefix:@"UITableViewCell"])
            goto NEXT;
        if ([current isKindOfClass:[UITableViewCell class]])
            goto NEXT;
        return current;
    NEXT:
        prev = current;
        current = current.superview;
    }
    return nil;
}

+ (void)Close {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    // 通过回调取得的 visible 状态通常晚于view的刷新，所以在这个地方强制关闭
    [UIKeyboardExt shared].visible = NO;
}

- (UIViewAnimationOptions)animationOptions {
    return UIViewAnimationCurve2Options(self.animationCurve);
}

- (BOOL)willHide {
    CGFloat v = self.framing.origin.y - self.frame.origin.y;
    return v + self.frame.size.height == 0;
}

- (BOOL)willShow {
    CGFloat v = self.frame.origin.y - self.framing.origin.y;
    return v + self.frame.size.height == 0;
}

- (BOOL)frameChanged {
    return !CGPointEqualToPoint(self.frame.origin, self.framing.origin);
}

@end

@implementation UIKeyboardPanel

- (void)onInit {
    [super onInit];
    
    [[UIKeyboardExt shared].signals connect:kSignalFrameChanging withSelector:@selector(__act_keyboard_changing:) ofTarget:self];
    [[UIKeyboardExt shared].signals connect:kSignalKeyboardShowing withSelector:@selector(__act_keyboard_showing) ofTarget:self];
    [[UIKeyboardExt shared].signals connect:kSignalKeyboardHiding withSelector:@selector(__act_keyboard_hiding) ofTarget:self];
    
    self.clipsToBounds = NO;
}

- (void)onFin {
    ZERO_RELEASE(_responder);
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD_SLOT(kSignalConstraintChanged, @selector(__act_constraint_changed))
SIGNAL_ADD(kSignalSelectionChanged)
SIGNALS_END

- (BOOL)isFirstResponder {
    return
    _responder.isFirstResponder ||
    _contentView != nil;
}

- (void)setToolbarView:(UIView *)toolbarView {
    if (_toolbarView == toolbarView)
        return;
    [_toolbarView removeFromSuperview];
    _toolbarView = toolbarView;
    [self addSubview:_toolbarView];
}

- (void)setContentView:(UIView *)contentView {
    if (_contentView == contentView)
        return;
    
    NSPair* changedevt = [NSPair pairFirst:contentView Second:_contentView];
    
    // 设置宽度
    CGSize cntsz = contentView.frame.size;
    if (cntsz.width == 0) {
        CGFloat w = self.frame.size.width;
        if (w == 0)
            w = contentView.bestWidth;
        cntsz.width = w;
    }
    
    // 设置高度
    if (cntsz.height == 0) {
        CGFloat h = contentView.bestHeight;
        cntsz.height = h;
    }
    
    // 计算位置
    UIKeyboardExt* kbd = [UIKeyboardExt shared];
    UIView* oldView = _contentView;
    _contentView = contentView;
    _contentView.size = cntsz;
    if (oldView)
        _contentView.position = CGPointMake(0, oldView.leftBottom.y);
    else
        _contentView.position = CGPointMake(0, _toolbarView.frame.size.height + kbd.frame.size.height);
    [self addSubview:_contentView];
    
    // 划出原来的，滑入新的
    [UIView animateWithDuration:kCAAnimationDuration
                     animations:^{
                         // 隐藏旧的
                         //oldView.position = oldView.leftBottom;
                         // 显示新的
                         [_contentView offsetPosition:CGPointMake(0, -cntsz.height)];
                         // 偏移自身
                         if (_contentView) {
                             self.transform = CGAffineTransformMakeTranslation(0, -cntsz.height);
                         } else {
                             self.transform = CGAffineTransformIdentity;
                         }
                     } completion:^(BOOL finished) {
                         [oldView removeFromSuperview];
                     }];
    
    // 如果键盘弹开，则收掉键盘
    [UIKeyboardExt Close];
    
    // 同步自己的大小
    self.height = self.bestHeight;
    
    // 需要解决隐藏的响应
    [_responder.signals connect:kSignalFocusedLost withSelector:@selector(__act_focused_lost) ofTarget:self];
    
    // 发送一次信号，激活尺寸改变
    [self.signals emit:kSignalConstraintChanged];
    
    // 发送改变的信号
    [self.signals emit:kSignalSelectionChanged withResult:changedevt];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox* box = [UIVBox boxWithRect:rect];
    [box addPixel:_toolbarView.bestHeight toView:_toolbarView];
    [box addPixel:_contentView.bestHeight toView:_contentView];
    [box apply];
}

- (CGSize)bestSize:(CGSize)sz {
    CGFloat h = 0;
    h += _toolbarView.bestHeight;
    h += _contentView.bestHeight;
    
    UIKeyboardExt* kbd = [UIKeyboardExt shared];
    if (self.focus && kbd.visible)
        h += kbd.frame.size.height;
    
    return CGSizeMake(kUIApplicationSize.width, h);
}

- (CGSize)constraintBounds {
    return [self bestSize];
}

- (void)__act_keyboard_changing:(SSlot*)s {
    // 如果没有激活，或者当前正在显示contentView
    if (_responder.focus == NO || self.contentView)
        return;
    
    UIKeyboardExt* kbd = [UIKeyboardExt shared];
    // 如果已经激活，则偏移到键盘位置
    [UIView animateWithDuration:kbd.duration
                        options:kbd.animationOptions
                     animations:^{
                         if (kbd.willHide) {
                             self.transform = CGAffineTransformIdentity;
                         } else {
                             self.transform = CGAffineTransformMakeTranslation(0, -kbd.frame.size.height);
                         }
                     }];
}

- (void)__act_keyboard_showing {
    // 同步自己的大小
    self.height = self.bestHeight;
    
    // 发送一次信号，激活尺寸改变
    [self.signals emit:kSignalConstraintChanged];
}

- (void)__act_keyboard_hiding {
    // 同步自己的大小
    self.height = self.bestHeight;
    
    // 如果没有contentview, 则是隐藏键盘, 需要改变ui
    if (self.contentView == nil) {
        [self.signals emit:kSignalConstraintChanged];
        [self.signals emit:kSignalSelectionChanged withResult:[NSPair temporary]];
    }
}

- (void)setResponder:(UIResponder*)responder {
    if (_responder == responder)
        return;
    
    [_responder.signals disconnectToTarget:self];
    PROPERTY_RETAIN(_responder, responder);
    
    // 如果是textinput或者textview，需要关闭自动避让键盘
    if ([responder conformsToProtocol:@protocol(UIAutoKeyboardDodge)])
        ((id<UIAutoKeyboardDodge>)responder).keyboardDodge = NO;
    
    [_responder.signals connect:kSignalFocused withSelector:@selector(__act_focused) ofTarget:self];
}

- (void)__act_focused {
    UIView* oldContent = _contentView;
    NSPair* changedevt = [NSPair pairFirst:[UIKeyboardExt shared] Second:_contentView];
    _contentView = nil;
    
    if (oldContent) {
        [UIView animateWithDuration:kCAAnimationDuration
                         animations:^{
                             [oldContent offsetPosition:CGPointMake(0, oldContent.frame.size.height)];
                         } completion:^(BOOL finished) {
                             [oldContent removeFromSuperview];
                         }];
    }
    
    // 断开隐藏的响应，因为会自动隐藏
    [_responder.signals disconnect:kSignalFocusedLost withSelector:@selector(__act_focused_lost) ofTarget:self];
    
    // 变更信号
    [self.signals emit:kSignalSelectionChanged withResult:changedevt];
}

- (void)__act_focused_lost {
    self.contentView = nil;
}

- (void)__act_constraint_changed {
    CGRect rc = self.frame;
    CGSize bsz = self.bestSize;
    CGFloat off = bsz.height - rc.size.height;
    rc.origin.y -= off;
    rc.size.height += off;
    self.frame = rc;
}

- (void)open {
    if (_responder.focus)
        return;
    _responder.focus = YES;
}

- (void)close {
    if (_responder.focus) {
        _responder.focus = NO;
    } else if (self.contentView) {
        self.contentView = nil;
    }
}

@end

UIViewAnimationOptions UIViewAnimationCurve2Options(UIViewAnimationCurve curve) {
    UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseOut;
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            opt = UIViewAnimationOptionCurveEaseInOut; break;
        case UIViewAnimationCurveEaseIn:
            opt = UIViewAnimationOptionCurveEaseIn; break;
        case UIViewAnimationCurveEaseOut:
            opt = UIViewAnimationOptionCurveEaseOut; break;
        case UIViewAnimationCurveLinear:
            opt = UIViewAnimationOptionCurveLinear; break;
        default: break;
    }
    return opt;
}

@implementation NSItemObject

- (void)dealloc {
    ZERO_RELEASE(_title);
    [super dealloc];
}

@end

@interface UIActionSheetExt ()
{
    NSMutableDictionary* _maped;
}

@end

@implementation UIActionSheetExt

- (id)init {
    self = [super init];
    
    self.title = nil;
    self.delegate = self;
    self.autoClose = YES;
    _maped = [[NSMutableDictionary alloc] init];
    
    [self onInit];
    return self;
}

- (void)dealloc {
    [self onFin];
    
    ZERO_RELEASE(_maped);
    [super dealloc];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalClosed)
SIGNALS_END

+ (id)temporary {
    return [[[self alloc] init] autorelease];
}

- (void)__ase_any_touch {
    if (self.autoClose == NO)
        return;
    
    NSObject* obj = [_maped objectForInt:self.cancelButtonIndex];
    [obj.touchSignals emit:kSignalClicked withResult:self];
    
    [self dismissWithClickedButtonIndex:-1 animated:YES];
}

- (NSItemObject*)addItem:(NSString*)str {
    NSInteger idx = [self addButtonWithTitle:str];
    NSItemObject* obj = [NSItemObject temporary];
    obj.title = str;
    obj.index = idx;
    [obj.signals addSignal:kSignalClicked];
    [_maped setObject:obj forInt:idx];
    return obj;
}

- (NSItemObject*)addCancel:(NSString*)str {
    NSInteger idx = [self addButtonWithTitle:str];
    NSItemObject* obj = [NSItemObject temporary];
    obj.title = str;
    obj.index = idx;
    [obj.signals addSignal:kSignalClicked];
    [_maped setObject:obj forInt:idx];
    self.cancelButtonIndex = self.destructiveButtonIndex = idx;
    return obj;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // iOS8 采用了 UIAlertControl 作为弹出选择，所以只能当 alert 隐藏掉后才能激活选中的动作
    //NSObject* obj = [_maped objectForInt:buttonIndex];
    //[obj.touchSignals emit:kSignalClicked withResult:self];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == -1)
        buttonIndex = self.cancelButtonIndex;
    NSItemObject* obj = [_maped objectForInt:buttonIndex];
    
    // 参照前一个函数的注释
    [obj.touchSignals emit:kSignalClicked withResult:self];
    [self.signals emit:kSignalClosed withResult:obj];
    
    // 断开对全局点击的处理
    [[UIKit shared].signals disconnect:kSignalTouchesBegan withSelector:@selector(__ase_any_touch) ofTarget:self];
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    PASS;
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet {
    // 如果点击了背景，也可以关闭 as
    [[UIKit shared].signals connect:kSignalTouchesBegan withSelector:@selector(__ase_any_touch) ofTarget:self].fps = 1;
}

- (void)show {
    [UIKeyboardExt Close];
    
    UIView* view = [UIAppDelegate shared].topmostViewController.view;
    [self showInView:view];
}

@end

@implementation UIAlertView (extension)

- (UITextField*)inputText {
    if (self.alertViewStyle != UIAlertViewStylePlainTextInput)
        self.alertViewStyle = UIAlertViewStylePlainTextInput;
    return [self textFieldAtIndex:0];
}

- (UITextField*)inputSecure {
    if (self.alertViewStyle != UIAlertViewStyleSecureTextInput)
        self.alertViewStyle = UIAlertViewStyleSecureTextInput;
    return [self textFieldAtIndex:0];
}

- (UITextField*)inputUser {
    if (self.alertViewStyle != UIAlertViewStyleLoginAndPasswordInput)
        self.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    return [self textFieldAtIndex:0];
}

- (UITextField*)inputPassword {
    if (self.alertViewStyle != UIAlertViewStyleLoginAndPasswordInput)
        self.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    return [self textFieldAtIndex:1];
}

@end

@interface UIAlertViewExt ()
<UIAlertViewDelegate>
{
    bool _async;
    NSInteger _clicked;
    NSSyncLoop* _loop;
    NSMutableArray* _items;
}

@end

@implementation UIAlertViewExt

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    _loop = [[NSSyncLoop alloc] init];
    _items = [[NSMutableArray alloc] init];
    _async = false;
    self.delegate = self;
    self.title = @"";
    self.message = @"";

    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_loop);
    ZERO_RELEASE(_items);
    [super dealloc];
}

- (void)setContentView:(UIView *)contentView {
    if (_contentView == contentView)
        return;
    [_contentView removeFromSuperview];
    _contentView = contentView;
    
    if (kIOS7Above)
    {
        CGRect rc = _contentView.frame;
        if (CGSizeEqualToSize(rc.size, CGSizeZero))
        {
            CGSize sz = CGSizeMake(240, CGVALUEMAX);
            sz = [_contentView bestSize:sz];
            rc.size = sz;
            _contentView.frame = rc;
        }
        
        [self setValue:_contentView forKey:@"accessoryView"];
    }
    else
    {
        [self addSubview:_contentView];
        
        // 设置高度
        UILabel* lblMsg = [self labelMessage];
        lblMsg.hidden = YES;
        CGFloat lh = lblMsg.font.emptyLineHeight;
        
        @try {
            [_contentView performSelector:@selector(setTextColor:) withObject:lblMsg.textColor];
            [_contentView performSelector:@selector(setTextFont:) withObject:lblMsg.textFont];
        }
        @catch (...) {}
        
        // 设置大小
        CGRect rc = _contentView.frame;
        rc.size.width = 240;
        
        if (rc.size.height == 0) {
            rc.size.height = [_contentView bestHeightForWidth:rc.size.width];
            if (rc.size.height > 200)
                rc.size.height = 200;
        }
        _contentView.frame = rc;
        
        if (lh) {
            int cnt = [NSMath CeilFloat:rc.size.height r:lh];
            if (cnt >= 1)
                self.message = [@"\n" stringBySelfAppendingCount:(cnt - 1)];
        }
    }
}

- (NSObject*)addItem:(NSString *)str {
    NSObject* obj = [NSObject temporary];
    [obj.signals addSignal:kSignalClicked];
    [_items addObject:obj];
    [self addButtonWithTitle:str];
    return obj;
}

- (NSObject*)addCancel:(NSString*)str {
    NSObject* obj = [NSObject temporary];
    [obj.signals addSignal:kSignalClicked];
    [_items addObject:obj];
    NSInteger idx = [self addButtonWithTitle:str];
    self.cancelButtonIndex = idx;
    return obj;
}

- (NSInteger)confirm {
    [UIKeyboardExt Close];
    
    _async = false;
    [self show];
    [_loop wait];
    return _clicked;
}

- (void)show {
    [UIKeyboardExt Close];

    _async = true;
    [super show];
    [self retain];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    _clicked = buttonIndex;
    [_loop continuee];
    
    NSObject* obj = [_items objectAtIndex:buttonIndex];
    [obj.touchSignals emit:kSignalClicked withResult:self];
    
    if (_async)
        [self release];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rc = self.bounds;
    CGPadding pad = CGPaddingZero;
    pad.top = CGRectGetMaxY([self labelTitle].frame) + 10;
    pad.bottom = CGRectGetMaxY(rc) - [self firstCommandButton].frame.origin.y;
    pad.left = 15;
    pad.right = 10;
    rc = CGRectApplyPadding(rc, pad);
    
    [self callOnLayout:rc];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    self.contentView.frame = rect;
}

- (UILabel*)labelTitle {
    if (kIOS7Above)
        return nil;
    NSArray* arr = [self.subviews arrayWithCollector:^id(id l) {
        if (l == self.contentView)
            return nil;
        if ([l isMemberOfClass:[UILabel class]])
            return l;
        return nil;
    }];
    return arr.firstObject;
}

- (UILabel*)labelMessage {
    NSArray* arr = [self.subviews arrayWithCollector:^id(id l) {
        if (l == self.contentView)
            return nil;
        if ([l isMemberOfClass:[UILabel class]])
            return l;
        return nil;
    }];
    if (kIOS7Above)
        return arr.firstObject;
    return arr.secondObject;
}

- (UIView*)firstCommandButton {
    return [self.subviews objectWithQuery:^id(id l) {
        if (l == self.contentView)
            return nil;
        NSString* str = NSStringFromClass([l class]);
        if ([str hasPrefix:@"UIAlert"])
            return l;
        return nil;
    }];
}

@end

@implementation UIMenuItem (extension)

SIGNALS_BEGIN
SIGNAL_ADD(kSignalClicked)
SIGNALS_END

NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR(UIMenuItem, hidden, setHidden, BOOL, @(val), [val boolValue], RETAIN_NONATOMIC);

- (void)setVisible:(BOOL)visible {
    self.hidden = !visible;
}

- (BOOL)visible {
    return !self.hidden;
}

@end

@interface UIMenuControllerExt ()
{
    NSMutableArray *_customItems;
}

@end

@implementation UIMenuControllerExt

- (void)onInit {
    [super onInit];
    _customItems = [[NSMutableArray alloc] init];
}

- (void)onFin {
    ZERO_RELEASE(_customItems);
    [super onFin];
}

@synthesize items = _customItems;

- (UIMenuItem*)addItem:(NSString *)title {
    UIMenuItem* mi = [[UIMenuItem alloc] initWithTitle:title action:nil];
    [_customItems addObject:mi];
    SAFE_RELEASE(mi);
    return mi;
}

- (UIMenuController*)instanceMenu {
    _menu = [UIMenuController sharedMenuController];
    for (int i = 0; i < _customItems.count; ++i) {
        UIMenuItem* mi = _customItems[i];
        if (mi.hidden)
            continue;
        NSString* str = [NSString stringWithFormat:@"__wrapper_uimenu_action%d:", i];
        SEL sel = sel_registerName(str.UTF8String);
        mi.action = sel;
    }
    [_menu setMenuItems:_customItems];
    return _menu;
}

@end

@implementation UIPasteboard (extension)

+ (id)shared {
    return [UIPasteboard generalPasteboard];
}

- (id)object {
    id ret = nil;
    if ((ret = [self base64Object]))
        return ret;
    
    if ((ret = self.string))
        return ret;
    
    if ((ret = self.URL))
        return ret;
    
    if ((ret = self.image))
        return ret;
    
    if ((ret = self.color))
        return ret;
    
    return nil;
}

- (void)setObject:(id)object {
    if (object == nil)
        return;
    
    if ([object isKindOfClass:[NSString class]])
    {
        self.string = object;
    }
    else if ([object isKindOfClass:[NSURL class]])
    {
        self.URL = object;
    }
    else if ([object isKindOfClass:[UIImage class]])
    {
        self.image = object;
    }
    else if ([object isKindOfClass:[UIColor class]])
    {
        self.color = object;
    }
    else
    {
        // 如果是其他类型，则需要保存成binary-base64
        if ([object conformsToProtocol:@protocol(NSCoding)])
        {
            NSData* data = [NSKeyedArchiver archivedDataWithRootObject:object];
            [self attachBase64Object:[data base64]];
        }
    }
}

- (void)attachBase64Object:(NSString*)str {
    NSString* ms = [NSString stringWithFormat:@"\x0B\xA\x64\x00%@", str];
    self.string = ms;
}

- (id)base64Object {
    NSString* raw = self.string;
    if (raw == nil)
        return nil;
    
    // 判断是不是base64object
    if ([raw hasPrefix:@"\x0B\xA\x64\x00"] == NO)
        return nil;
    
    NSData* data = [[raw substringFromIndex:4] debase64data];
    id ret = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return ret;
}

@end

@interface UIPasteboardExt ()

@property (nonatomic, retain) UIPasteboard *pb;

- (instancetype)initWithPb:(UIPasteboard*)pb;

@end

@implementation UIPasteboardExt

SHARED_IMPL;

- (id)initWithPb:(UIPasteboard *)pb {
    self = [super init];
    self.pb = pb;
    return self;
}

- (id)init {
    self = [super init];
    self.pb = [UIPasteboard generalPasteboard];
    return self;
}

+ (instancetype)Open:(NSString *)name {
    UIPasteboard* pb = [UIPasteboard pasteboardWithName:name create:NO];
    if (pb == nil)
        pb = [UIPasteboard pasteboardWithName:name create:YES];
    pb.persistent = YES;
    return [[[self.class alloc] initWithPb:pb] autorelease];
}

- (void)onInit {
    [super onInit];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(__noti_valuechagned:)
                                                 name:UIPasteboardChangedNotification
                                               object:nil];
}

- (void)onFin {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    ZERO_RELEASE(_pb);
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalValueChanged)
SIGNALS_END

- (void)__noti_valuechagned:(NSNotification*)noti {
    if (noti.object != self.pb)
        return;
    [self.signals emit:kSignalValueChanged];
}

NSPROPERTY_BRIDGE_TO(object, setObject, self.pb.object, id);
NSPROPERTY_BRIDGE_TO(string, setString, self.pb.string, NSString*);
NSPROPERTY_BRIDGE_TO(URL, setURL, self.pb.URL, NSURL*);
NSPROPERTY_BRIDGE_TO(image, setImage, self.pb.image, UIImage*);
NSPROPERTY_BRIDGE_TO(color, setColor, self.pb.color, UIColor*);

@end

@implementation UIDatePicker (extension)

+ (CGFloat)Height {
    return 160;
}

@end

CGRect UIEdgeInsetsDeinsetRect(CGRect rect, UIEdgeInsets insets) {
    rect.origin.x    -= insets.left;
    rect.origin.y    -= insets.top;
    rect.size.width  += (insets.left + insets.right);
    rect.size.height += (insets.top  + insets.bottom);
    return rect;
}

UIEdgeInsets UIEdgeInsetsAdd(UIEdgeInsets l, UIEdgeInsets r) {
    l.top += r.top;
    l.bottom += r.bottom;
    l.right += r.right;
    l.left += r.left;
    return l;
}

UIEdgeInsets UIEdgeInsetsSub(UIEdgeInsets l, UIEdgeInsets r) {
    l.top -= r.top;
    l.bottom -= r.bottom;
    l.right -= r.right;
    l.left -= r.left;
    return l;
}

@interface UIBarItem (signals)
<SSignals>
@end

@implementation UIBarItem (signals)

- (void)signals:(NSObject *)object signalConnected:(NSString *)sig slot:(SSlot *)slot {
    PASS;
}

@end

@implementation UIBarItem (extension)

SIGNALS_BEGIN

self.signals.delegate = self;

SIGNAL_ADD(kSignalClicked)
SIGNAL_ADD(kSignalLongClicked)

SIGNALS_END

- (void)__bi_clicked {
    [self.touchSignals emit:kSignalClicked withResult:self];
}

- (void)__bi_longclicked {
    [self.touchSignals emit:kSignalLongClicked];
}

NSOBJECT_DYNAMIC_PROPERTY_DECL(UIBarItem, priority);

- (void)setPriority:(NSInteger)priority {
    NSOBJECT_DYNAMIC_PROPERTY_SET(UIBarItem, priority, RETAIN_NONATOMIC, @(priority));
}

- (NSInteger)priority {
    id obj = NSOBJECT_DYNAMIC_PROPERTY_GET(UIBarItem, priority);
    return [obj integerValue];
}

@end

@implementation UIBarButtonItem (extension)

- (UIView*)behalfView {
    return self.customView;
}

+ (id)itemWithImage:(UIImage *)image {
    return [[[self alloc] initWithImage:image] autorelease];
}

+ (id)itemWithTitle:(NSString *)title {
    return [[[self alloc] initWithTitle:title] autorelease];
}

+ (id)itemWithStylizedString:(NSStylizedString *)string {
    return [[[self alloc] initWithStylizedString:string] autorelease];
}

+ (id)itemWithPush:(NSString *)pushimg {
    return [[[self alloc] initWithPush:pushimg] autorelease];
}

+ (id)itemWithView:(UIView *)view {
    CGRect rc = view.frame;
    if (CGSizeEqualToSize(rc.size, CGSizeZero)) {
        CGSize bsz = [view bestSize];
        if (CGSizeEqualToSize(bsz, CGSizeZero) == NO)
            rc = CGRectClipCenterBySize(rc, bsz);
    }
    if (rc.size.height == 0)
        rc.size.height = kUINavigationBarItemHeight;
    if (rc.size.width == 0)
        rc.size.width = kUINavigationBarItemWidth;
    
    if (!kIOS7Above) {
        if ([view respondsToSelector:@selector(setOffsetEdge:)]) {
            [(id)view setOffsetEdge:CGPointMake(-10, 0)];
        }
    }
    
    view.frame = rc;
    
    UIBarButtonItem* bbi = [[self alloc] initWithCustomView:view];
    
    if ([view isKindOfClass:[UIButtonExt class]]) {
        UIButtonExt* btn = (UIButtonExt*)view;
        btn.hitTestPadding = [bbi buttonHitTestPadding];
    }
    
    return [bbi autorelease];
}

- (id)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style {
    return [self initWithImage:image style:style target:self action:@selector(__bi_clicked)];
}

- (id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style {
    return [self initWithTitle:title style:style target:self action:@selector(__bi_clicked)];
}

- (id)initWithPush:(NSString *)pushimg style:(UIBarButtonItemStyle)style {
    return [self initWithImage:[UIImage imageWithContentOfNamed:pushimg] style:style];
}

- (id)initWithImage:(UIImage *)image {
    UIButtonExt* btn = [[UIButtonExt4BarButtonItem alloc] initWithZero];
    
    if ([image isKindOfClass:[UIBackgroudImage class]])
        btn.backgroundImage = image;
    else
        btn.image = image;
    
    [btn sizeToFit];
    UIBarButtonItem* bbi = [self initWithCustomView:btn];
    SAFE_RELEASE(btn);
    
    btn.hitTestPadding = [self buttonHitTestPadding];
    return bbi;
}

- (id)initWithStylizedString:(NSStylizedString *)string {
    UILabelExt* lbl = [[UILabelExt4BarButtonItem alloc] initWithZero];
    lbl.stylizedString = string;
    lbl.size = lbl.bestSize;
    
    UIBarButtonItem* bbi = [self initWithCustomView:lbl];
    SAFE_RELEASE(lbl);
    
    return bbi;
}

- (id)initWithTitle:(NSString *)title {
    UIButtonExt* btn = [[UIButtonExt4BarButtonItem alloc] initWithZero];
    btn.text = title;
    
    NSDictionary* dict = [[UIBarButtonItem appearance] titleTextAttributesForState:UIControlStateNormal];
    if ([UINavigationBar appearance].tintColor)
        btn.textColor = [UINavigationBar appearance].tintColor;
    else if ([dict objectForKey:UITextAttributeTextColor])
        btn.textColor = [dict objectForKey:UITextAttributeTextColor];
    else
        btn.textColor = [UIColor colorWithRGB:0x5aff];
    
    if ([dict objectForKey:UITextAttributeFont])
        btn.textFont = [dict objectForKey:UITextAttributeFont];
    else
        btn.textFont = [UIFont systemFontOfSize:17];

    [btn sizeToFit];
    UIBarButtonItem* bbi = [self initWithCustomView:btn];
    SAFE_RELEASE(btn);
    
    btn.hitTestPadding = [self buttonHitTestPadding];
    return bbi;
}

- (id)initWithPush:(NSString *)pushimg {
    UIButtonExt* btn = [[UIButtonExt4BarButtonItem alloc] initWithZero];
    [btn setPushImageNamed:pushimg];
    [btn sizeToFit];
    id ret = [self initWithCustomView:btn];
    SAFE_RELEASE(btn);
    
    btn.hitTestPadding = [self buttonHitTestPadding];
    return ret;
}

- (CGPadding)buttonHitTestPadding {
    CGPadding pad = CGPaddingMake(-20, -30, -10, -30);
    return pad;
}

- (UIButton*)customButton {
    if ([self.customView isKindOfClass:[UIButton class]]) {
        return ((UIButton*)self.customView);
    }
    return nil;
}

- (UIButtonExt*)customButtonExt {
    if ([self.customView isKindOfClass:[UIButtonExt4BarButtonItem class]]) {
        return ((UIButtonExt*)self.customView);
    }
    return nil;
}

- (UILabelExt*)customLabelExt {
    if ([self.customView isKindOfClass:[UILabelExt4BarButtonItem class]]) {
        return ((UILabelExt*)self.customView);
    }
    return nil;
}

- (UIButtonExt*)buttonItem {
    return [self customButtonExt];
}

- (UILabelExt*)labelItem {
    return [self customLabelExt];
}

- (NSStylizedString*)stylizedString {
    return self.labelItem.stylizedString;
}

- (void)setStylizedString:(NSStylizedString *)stylizedString {
    self.labelItem.stylizedString = stylizedString;
}

- (void)setSize:(CGSize)size {
    self.buttonItem.size = size;
}

- (CGSize)size {
    return self.buttonItem.frame.size;
}

- (void)setWidth:(CGFloat)width {
    [self.buttonItem setWidth:width];
}

- (CGFloat)width {
    return self.buttonItem.frame.size.width;
}

- (void)setTintColor:(UIColor *)tintColor {
    [self customButton].textColor = tintColor;
}

- (void)setTextColor:(UIColor *)textColor {
    [self customButton].textColor = textColor;
}

- (void)setTextFont:(UIFont *)textFont {
    [self customButton].textFont = textFont;
}

- (UIColor*)textColor {
    return [self customButton].textColor;
}

- (UIFont*)textFont {
    return [self customButton].textFont;
}

- (void)setTitle:(NSString *)title {
    [self customButton].text = title;
}

- (NSString*)title {
    return [self customButton].text;
}

- (id)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem {
    return [self initWithBarButtonSystemItem:systemItem target:self action:@selector(__bi_clicked)];
}

- (void)signals:(NSObject *)object signalConnected:(NSString *)sig slot:(SSlot *)slot {
    if (sig == kSignalClicked)
        [self.customView.signals connect:kSignalClicked withSelector:@selector(__bi_clicked) ofTarget:self];
    if (sig == kSignalLongClicked)
        [self.customView.signals connect:kSignalLongClicked withSelector:@selector(__bi_longclicked) ofTarget:self];
}

NSOBJECT_DYNAMIC_PROPERTY_DECL(UIBarButtonItem, hitTestPadding);

- (void)setHitTestPadding:(CGPadding)hitTestPadding {
    NSOBJECT_DYNAMIC_PROPERTY_SET(UIBarButtonItem, hitTestPadding, RETAIN_NONATOMIC, [NSPadding padding:hitTestPadding]);
    [self customButtonExt].hitTestPadding = hitTestPadding;
}

- (CGPadding)hitTestPadding {
    return [NSOBJECT_DYNAMIC_PROPERTY_GET(UIBarButtonItem, hitTestPadding) padding];
}

- (void)__bi_clicked {
    UIButtonExt* bext = [self customButtonExt];
    if (bext == nil)
        return;
    [super __bi_clicked];
}

@end

@implementation UIView (activity_indicator)

- (void)startActiviting {
    CAAnimation* ani = [CAKeyframeAnimation Spin];
    ani.duration = 1.f;
    ani.resetOnCompletion = NO;
    [self.layer addAnimation:ani];
}

- (void)stopActiviting {
    [self.layer stopAnimations];
}

@end

@implementation UIActivityIndicatorView (extension)
                               
+ (instancetype)activityIndicatorWithStyle:(UIActivityIndicatorViewStyle)style {
    return [[[self alloc] initWithActivityIndicatorStyle:style] autorelease];
}

+ (instancetype)Gray {
    return [[self class] activityIndicatorWithStyle:UIActivityIndicatorViewStyleGray];
}

+ (instancetype)White {
    return [[self class] activityIndicatorWithStyle:UIActivityIndicatorViewStyleWhite];
}

+ (instancetype)WhithLarge {
    return [[self class] activityIndicatorWithStyle:UIActivityIndicatorViewStyleWhiteLarge];
}

- (BOOL)animating {
    return self.isAnimating;
}

- (void)setAnimating:(BOOL)animating {
    if (animating == self.isAnimating)
        return;
    if (animating)
        [self startAnimating];
    else
        [self stopAnimating];
}
                            
@end

@implementation UIImageCropController

- (void)onInit {
    [super onInit];
    self.classForView = [PECropView class];
}

- (void)onFin {
    ZERO_RELEASE(_image);
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalDone)
SIGNAL_ADD(kSignalCancel)
SIGNALS_END

- (void)onLoaded {
    [super onLoaded];
    
    PECropView* pev = (PECropView*)self.view;
    pev.backgroundColor = [UIColor grayColor];
    pev.image = self.image;
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTitle:@"取消"];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTitle:@"确定"];
    
    [self.navigationItem.leftBarButtonItem.signals connect:kSignalClicked redirectTo:kSignalCancel ofTarget:self];
    [self.navigationItem.rightBarButtonItem.signals connect:kSignalClicked withSelector:@selector(__icc_ok) ofTarget:self];
}

- (void)onAppeared {
    [super onAppeared];
    
    if (self.aspect) {
        PECropView* pev = (PECropView*)self.view;
        pev.cropAspectRatio = self.aspect;
        pev.keepingCropAspectRatio = YES;
    }
}

- (void)__icc_ok {
    PECropView* pev = (PECropView*)self.view;
    UIImage* result = pev.croppedImage;
    [self.signals emit:kSignalDone withResult:result];
}

@end

@interface UIPageViewControllerExt ()
<UIPageViewControllerDelegate, UIPageViewControllerDataSource>
{
    NSInteger _currentPage;
    
    // 5.0以下系统会将所有的style都转换成pageCurl，所以需要保存一下预期的style
    UIPageViewControllerTransitionStyle _settingStyle;
}

@end

@implementation UIPageViewControllerExt

@synthesize currentPage = _currentPage;

- (id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary *)options {
    self = [super initWithTransitionStyle:style navigationOrientation:navigationOrientation options:options];
    _settingStyle = style;
    self.delegate = self;
    self.dataSource = self;
    _currentPage = -1;
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_pageViewControllers);
    [super dealloc];
}

- (NSInteger)currentPage {
    if (_currentPage == -1)
        return 0;
    return _currentPage;
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalSelectionChanged)
SIGNALS_END

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 如果是5.0以下的系统，而且style设置成scroll，需要关闭掉tap
    if (!kIOS6Above &&
        _settingStyle == UIPageViewControllerTransitionStyleScroll)
    {
        UIGestureRecognizer* gr = [self.gestureRecognizers objectWithQuery:^id(UIGestureRecognizer* l) {
            if ([l isKindOfClass:[UITapGestureRecognizer class]])
                return l;
            return nil;
        }];
        gr.enabled = NO;
    }
}

- (void)setViewControllers:(NSArray *)viewControllers direction:(UIPageViewControllerNavigationDirection)direction animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    [super setViewControllers:viewControllers direction:direction animated:animated completion:completion];
}

- (void)setPageViewControllers:(NSArray *)pageViewControllers {
    PROPERTY_RETAIN(_pageViewControllers, pageViewControllers);
    
    if (_pageViewControllers == nil)
        return;
    
    [self setViewControllers:[NSArray arrayWithObject:[_pageViewControllers objectAtIndex:self.currentPage]]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:^(BOOL finished) {
                      PASS;
                  }];
}

- (void)setCurrentPage:(NSInteger)currentPage {
    if (_currentPage == currentPage)
        return;
    _currentPage = currentPage;

    [self setViewControllers:[NSArray arrayWithObject:[_pageViewControllers objectAtIndex:self.currentPage]]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:^(BOOL finished) {
                      PASS;
                  }];
}

- (void)setPageViewControllers:(NSArray*)array selectPageAtIndex:(NSInteger)idx {
    PROPERTY_RETAIN(_pageViewControllers, array);
    if (_pageViewControllers == nil)
        return;
    
    self.currentPage = idx;
}

- (void)changePageViewControllers:(NSArray*)array {
    PROPERTY_RETAIN(_pageViewControllers, array);
}

- (UIViewController*)currentViewController {
    return [_pageViewControllers objectAtIndex:_currentPage];
}

- (void)setCurrentViewController:(UIViewController*)vc {
    NSUInteger idx = [_pageViewControllers indexOfObject:vc];
    if (idx == _currentPage)
        return;
    self.currentPage = idx;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    NSArray* vcs = pageViewController.viewControllers;
    _currentPage = [_pageViewControllers indexOfObject:vcs.firstObject];
    if (finished && completed)
        [self.signals emit:kSignalSelectionChanged];
    
    // iOS6 会当 keyboard 弹出时，存在一个 bug 自动释放最后一个 page，所以需要保护重新设置一下
    if (kIOSMajorVersion == 6)
    {
        int tmp = _currentPage;
        _currentPage = -1;
        DISPATCH_DELAY_BEGIN(.1)
        self.currentPage = tmp;
        DISPATCH_DELAY_END
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    UIViewController* ret = [self.pageViewControllers previousObject:viewController];
    return ret;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    UIViewController* ret = [self.pageViewControllers nextObject:viewController];
    return ret;
}

@end

@implementation CLPlacemark (extension)

- (CLLocation*)locationValue {
    return self.location;
}

- (CLPlacemark*)placemarkValue {
    return self;
}

- (NSString*)city {
    if (self.locality)
        return self.locality;
    return self.administrativeArea;
}

- (NSString*)province {
    return self.administrativeArea;
}

@end

@implementation CLLocation (extension)

- (CLLocation*)locationValue {
    return self;
}

- (CLPlacemark*)placemarkValue {
    return nil;
}

@end

@implementation UIDevice (extension)

+ (id)shared {
    return [UIDevice currentDevice];
}

SIGNALS_BEGIN

SIGNAL_ADD(kSignalDeviceShaking)
SIGNAL_ADD(kSignalDeviceShaked)
SIGNAL_ADD(kSignalDeviceVibrate)

[self.signals settingForSignal:kSignalDeviceShaking].fps = 1;
[self.signals settingForSignal:kSignalDeviceShaked].fps = 1;
[self.signals settingForSignal:kSignalDeviceVibrate].fps = 1;

SIGNALS_END

+ (BOOL)IsRoot {
    FILE* fp = popen("ls /var", "r");
    char buf[8];
    int len = fread(buf, 1, 8, fp);
    pclose(fp);
    return len != 0;
}

+ (UIDeviceType)DeviceType {
    NSString* model = [UIDevice currentDevice].model;
    UIDeviceType ret = 0;
    if ([model rangeOfString:@"iphone" options:NSCaseInsensitiveSearch].location != NSNotFound)
        ret |= kUIDeviceTypeIPhone;
    else if ([model rangeOfString:@"ipad" options:NSCaseInsensitiveSearch].location != NSNotFound)
        ret |= kUIDeviceTypeIPad;
    else if ([model rangeOfString:@"ipod" options:NSCaseInsensitiveSearch].location != NSNotFound)
        ret |= kUIDeviceTypeIPod;
    if ([model rangeOfString:@"simulator" options:NSCaseInsensitiveSearch].location != NSNotFound)
        ret |= kUIDeviceTypeSimulator;
    return ret;
}

+ (NSString*)UniqueIdentifier {
    static NSString* uidr = nil;
    DISPATCH_ONCE_BEGIN
    if (uidr == nil) {
        uidr = [[[NSPersistentStorageService shared] getObjectForKey:@"::ui::device::uniqueidentifier" def:nil] copy];
        if (uidr == nil) {
            uidr = [[NSString uuid] copy];
            [[NSPersistentStorageService shared] setObject:uidr forKey:@"::ui::device::uniqueidentifier"];
        }
        INFO("Device UUID: %s", uidr.UTF8String);
    }
    DISPATCH_ONCE_END
    return uidr;
}

+ (void)Vibrate {
    [[UIDevice shared].signals emit:kSignalDeviceVibrate];
}

- (void)__cb_vibrate {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@end

@implementation UIScreen (extension)

static NSString *__gs_launchimage = nil, *__gs_launchimage_nm = nil;

+ (NSString*)pathForLaunchImage {
    if (__gs_launchimage)
        return __gs_launchimage;
    
    NSString* nm = [UIScreen namedForLaunchImage];
    __gs_launchimage = [[UIRetina pathOfImageNamed:nm] copy];
    return __gs_launchimage;
}

+ (NSString*)namedForLaunchImage {
    if (__gs_launchimage_nm)
        return __gs_launchimage_nm;
    
    NSBundle* bdl = [NSBundle mainBundle];
    NSString* ph = nil;
    
    do {
        if (kUIScreenSizeType == kUIScreenSizeD) {
            ph = @"LaunchImage-800-Portrait-736h@3x";
            if (([bdl pathForResource:ph ofType:@"png"]))
                break;
            else
            {
                ph = @"LaunchImage-800-667h@2x";
                if (([bdl pathForResource:ph ofType:@"png"]))
                    break;
                ph = @"LaunchImage-700-568h@2x";
                if (([bdl pathForResource:ph ofType:@"png"]))
                    break;
                ph = @"Default-568h@2x";
                if (([bdl pathForResource:ph ofType:@"png"]))
                    break;
                ph = @"Default@2x";
                if (([bdl pathForResource:ph ofType:@"png"]))
                    break;
                ph = @"Default";
                break;
            }
        }
        if (kUIScreenSizeType == kUIScreenSizeC) {
            ph = @"LaunchImage-800-667h@2x";
            if (([bdl pathForResource:ph ofType:@"png"]))
                break;
            else
            {
                ph = @"LaunchImage-700-568h@2x";
                if (([bdl pathForResource:ph ofType:@"png"]))
                    break;
                ph = @"Default-568h@2x";
                if (([bdl pathForResource:ph ofType:@"png"]))
                    break;
                ph = @"Default@2x";
                if (([bdl pathForResource:ph ofType:@"png"]))
                    break;
                ph = @"Default";
                break;
            }
        }
        if (kUIScreenSizeType == kUIScreenSizeB) {
            ph = @"LaunchImage-700-568h@2x";
            if (([bdl pathForResource:ph ofType:@"png"]))
                break;
            ph = @"Default-568h@2x";
            if (([bdl pathForResource:ph ofType:@"png"]))
                break;
        }
        ph = @"Default@2x";
        if (([bdl pathForResource:ph ofType:@"png"]))
            break;
        ph = @"Default";
    } while(0);
    
    __gs_launchimage_nm = [ph copy];
    return __gs_launchimage_nm;
}

+ (UIImage*)LaunchImage {
    NSString* ph = [UIScreen pathForLaunchImage];
    return [UIImage imageWithContentsOfFile:ph];
}

static NSString *__gs_appicon_nm = nil, *__gs_appicon = nil;

+ (NSString*)pathForAppIcon {
    if (__gs_appicon)
        return __gs_appicon;
    NSString* nm = [UIScreen namedForAppIcon];
    __gs_appicon = [[UIRetina pathOfImageNamed:nm] copy];
    return __gs_appicon;
}

+ (NSString*)namedForAppIcon {
    if (__gs_appicon_nm)
        return __gs_appicon_nm;
    
    NSBundle* bdl = [NSBundle mainBundle];
    NSString* nm = nil;
    do {
        nm = @"AppIcon60x60@2x";
        if ([bdl pathForResource:nm ofType:@"png"])
            break;
        nm = @"AppIcon57x57@2x";
        if ([bdl pathForResource:nm ofType:@"png"])
            break;
        nm = @"AppIcon40x40@2x";
        if ([bdl pathForResource:nm ofType:@"png"])
            break;
        nm = @"AppIcon40x40@2x";
        if ([bdl pathForResource:nm ofType:@"png"])
            break;
        nm = @"AppIcon40x40";
    } while(0);

    __gs_appicon_nm = [nm copy];
    return __gs_appicon_nm;
}

+ (UIImage*)AppIcon {
    NSString* ph = [UIScreen pathForAppIcon];
    return [UIImage imageWithContentsOfFile:ph];
}

@end

@interface UIApplication (sk)
<SKStoreProductViewControllerDelegate>

@end

@implementation UIApplication (extension)

+ (id)shared {
    return [UIApplication sharedApplication];
}

- (BOOL)openURLString:(NSString*)str {
    NSURL* url = [NSURL URLWithString:str];
    if (url == nil)
        WARN("尝试打开一个空页面");
    return [self openURL:url];
}

- (BOOL)canOpenURLString:(NSString*)str {
    NSURL* url = [NSURL URLWithString:str];
    return [self canOpenURL:url];
}

- (BOOL)openHttp:(NSString *)url {
    NSURL* obj = [NSURL URLWithString:url];
    if (obj.scheme == nil) {
        url = [NSString stringWithFormat:@"http://%@", url];
        obj = [NSURL URLWithString:url];
    }
    if (url == nil)
        WARN("尝试打开一个空的 HTTP 页面");
    return [self openURL:obj];
}

- (BOOL)isInstalled:(NSString *)scheme {
    if ([scheme indexOfSubString:@"://"] == NSNotFound)
        scheme = [scheme stringByAppendingString:@"://"];
    return [self canOpenURLString:scheme];
}

- (BOOL)openApp:(NSString*)scheme {
    if ([scheme indexOfSubString:@"://"] == NSNotFound)
        scheme = [scheme stringByAppendingString:@"://"];
    return [self openURLString:scheme];
}

- (void)goAppstoreHome:(NSString*)appid {
# ifdef DEBUG_MODE
    if ([[NSRegularExpression Digital] isMatchs:appid] == NO) {
        FATAL("appid 必须都是数字");
    }
# endif
    
    if (kIOS6Above && !kDeviceRunningSimulator)
    {
        // 部分网络情况下，直接通过 SK 来内嵌 APPSTORE 页面会长时间不响应，则需要通过超时设定来显示一个跳转的按钮
        [UIHud ShowProgress];
        
        __block SKStoreProductViewController *ctlr = [[SKStoreProductViewController alloc] init];
        ctlr.delegate = self;
        NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:appid.intValue]
                                                         forKey:SKStoreProductParameterITunesItemIdentifier];
        
        LOG("请求内部打开 %s 的 APPSTORE 页面", appid.UTF8String);
        [ctlr loadProductWithParameters:dict completionBlock:^(BOOL result, NSError *error) {
            if (result && ctlr) {
                [[UIAppDelegate shared] presentModalViewController:ctlr];
            }
            
            if (error) {
                [UIHud Failed:error.localizedDescription];
            }

            ctlr = nil;
            [UIHud HideProgress];
        }];
        
        [[NSTimeoutManager SetTimeout:3 key:@"::app::openapphome" inThread:NO].signals connect:kSignalTakeAction withBlock:^(SSlot *s) {
            if (ctlr == nil)
                return;
            
            LOG("因为 APPSTORE 长时间没有响应，则使用外部URL打开 %s 的 APPSTORE 页面", appid.UTF8String);

            // 停止当前的等待
            ctlr = nil;
            [UIHud HideProgress];

            // 外部跳转
            [self openURLString:[self appstoreURL:appid]];
        }];
    }
    else
    {
        [self openURLString:[self appstoreURL:appid]];
    }
}

- (NSString*)appstoreURL:(NSString *)appid {
    NSString* scheme = TRIEXPRESS(kDeviceRunningSimulator, @"https", @"itms-apps");
    return [NSString stringWithFormat:@"%@://itunes.apple.com/us/app/id%@?mt=8", scheme, appid];
}

- (void)goAppHome:(NSString *)url {
    NSRegularExpression* rx = [NSRegularExpression AppUrlOnAppstore];
    if ([rx isMatchs:url]) {
        NSArray* res = [rx capturesInString:url];
        [[UIApplication sharedApplication] goAppstoreHome:res.secondObject];
        return;
    }
    
    [[UIApplication sharedApplication] openURLString:url];
}

- (void)goReview:(NSString *)appid {
    // 内部打开的productvc 里面的的撰写点评不能按，还是跳转到外部去点评
    NSString* homeurl = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", appid];
    [self openURLString:homeurl];
}

NSOBJECT_DYNAMIC_PROPERTY_EXT(UIApplication, statusBarColor,, setStatusBarColor,, {
    UIStatusBarStyle style = UIStatusBarStyleDefault;
    if (((UIColor*)val).rgb < 0x7f7f7f) {
        style = UIStatusBarStyleLightContent;
    }
    [self setStatusBarStyle:style animated:YES];
}, RETAIN_NONATOMIC);

- (NSArray*)appSchemes {
    NSDictionary *dictInfo = [[NSBundle mainBundle] infoDictionary];
    NSArray* urls = [dictInfo getArray:@"CFBundleURLTypes"];
    return [urls arrayWithCollector:^id(NSDictionary* l) {
        return [l getArray:@"CFBundleURLSchemes"].firstObject;
    }];
}

@end

@implementation UIApplication (sk)

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:^{
        [viewController release];
    }];
}

@end

@interface UIStylizedStringView ()
<NSStylizedItemCustomDelegate>

@property (nonatomic, retain) NSAttributedString *attributedString;
@property (nonatomic, readonly) NSMutableArray *customViews; // 保存所有的自定义view

@end

@implementation UIStylizedStringView

- (void)onInit {
    [super onInit];
    
    self.dataSource = self;
    self.delegate = self;
    _customViews = [[NSMutableArray alloc] init];
}

- (void)onFin {
    ZERO_RELEASE(_string);
    ZERO_RELEASE(_attributedString);
    ZERO_RELEASE(_customViews);
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalStylizedCustomViewCreated)
SIGNALS_END

- (void)setString:(NSStylizedString *)string {
    for (id each in _string.items) {
        if ([each conformsToProtocol:@protocol(NSStylizedItemCustom)])
            ((id<NSStylizedItemCustom>)each).delegate = nil;
    }
    
    PROPERTY_RETAIN(_string, string);
    
    for (id each in _string.items) {
        if ([each conformsToProtocol:@protocol(NSStylizedItemCustom)])
            ((id<NSStylizedItemCustom>)each).delegate = self;
    }
    
    self.attributedString = _string.attributedString;
    [self updateData];
}

- (void)reloadData {
    for (id each in _string.items) {
        if ([each conformsToProtocol:@protocol(NSStylizedItemCustom)])
            ((id<NSStylizedItemCustom>)each).delegate = self;
    }
    
    self.attributedString = _string.attributedString;
    
    // 刷新ui
    [self updateData];
    
    // 重绘
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

- (CGSize)bestSize:(CGSize)sz {
    return [self.attributedString bestSize:sz];
}

+ (UIView*)CustomViewForItem:(id)item {
    return [[item attachment].weak objectForKey:kUIStylizedStringViewKey];
}

+ (void)SetCustomView:(UIView*)view forItem:(id)item {
    [[item attachment].weak setObject:view forKey:kUIStylizedStringViewKey];
}

- (void)updateData {
    [super updateData];
    
    // 保存所有正在使用的，以用来移除不用的
    NSMutableArray* usedViews = [NSMutableArray array];
    
    // 生成子控件
    for (id<NSStylizedItem> each in self.string.items) {
        if ([each conformsToProtocol:@protocol(NSStylizedItemCustom)] == NO)
            continue;
        
        id<NSStylizedItemCustom> item = (id<NSStylizedItemCustom>)each;
        UIView* view = [UIStylizedStringView CustomViewForItem:item];
        // 如果view == nil，则代表这个item为新的item，需要生成view
        if (view == nil) {
            view = [self.dataSource stylizedStringView:self
                             customViewForStylizedItem:item];
            ASSERTMSG(view != nil, @"为 StylizedItem 返回一个为 nil 的 view");
            [UIStylizedStringView SetCustomView:view forItem:item];
            [self addSubview:view];
            // 加入到列表中
            [_customViews addObject:view];
        }
        
        // 加入到已经用过的表中
        [usedViews addObject:view];
        
        // 如果没有设置大小，则需要绑定一下最佳大小
        if (CGRectEqualToRect(view.frame, CGRectZero))
            [view setSize:[view bestSize]];
        
        // 回调一下，以方便处理
        if ([self.delegate respondsToSelector:@selector(stylizedStringView:customView:forStylizedItem:)])
            [self.delegate stylizedStringView:self customView:view forStylizedItem:item];
    }
    
    // 将不用的view移除
    for (UIView* unused in [_customViews removeObjectsNotIn:usedViews]) {
        [unused removeFromSuperview];
    }
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    // 布局子控件
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedString);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    // 生成子控件
    NSArray* lines = (NSArray*)CTFrameGetLines(frame);
    CGPoint origins[lines.count];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
    
    NSUInteger idxLine = 0;
    for (id each in lines)
    {
        CTLineRef line = (CTLineRef)each;
        for (id each in (NSArray*)CTLineGetGlyphRuns(line))
        {
            CTRunRef run = (CTRunRef)each;
            CFRange rgnRun = CTRunGetStringRange(run);
            
            // 查找对应的item
            id<NSStylizedItem> founditem = nil;
            NSRange rgnFind = NSRangeZero;
            for (NSUInteger i = 0; i < self.string.items.count; ++i)
            {
                id<NSStylizedItem> each = [self.string.items objectAtIndex:i];
                rgnFind.length = each.placedString.length;
                
                // range是否匹配
                BOOL found = NSRangeEqualToCFRange(rgnFind, rgnRun);
                
                // 偏移位置
                rgnFind.location += rgnFind.length;

                if (found)
                { // 找到
                    founditem = each;
                    break;
                }
            }
            
            // 检查自定义控件
            if ([founditem conformsToProtocol:@protocol(NSStylizedItemCustom)])
            {
                // 摆放自定义控件到对应位置
                id<NSStylizedItemCustom> item = (id<NSStylizedItemCustom>)founditem;
                UIView* view = [UIStylizedStringView CustomViewForItem:item];
                
                CGRect rc;
                CGFloat ascent, descent;
                rc.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
                rc.size.height = ascent + descent;
                
                CGFloat xOffset = CTLineGetOffsetForStringIndex(line, rgnRun.location, NULL);
                rc.origin.x = origins[idxLine].x + rect.origin.x + xOffset;
                rc.origin.y = origins[idxLine].y + rect.origin.y - descent;
                rc.origin.y = rect.size.height - rc.size.height - rc.origin.y;
                
                view.frame = rc;
            }

        }
        
        ++idxLine;
    }

    CFRelease(frame);
    CFRelease(framesetter);
    CGPathRelease(path);
}

- (void)setContentPadding:(CGPadding)contentPadding {
    self.paddingEdge = contentPadding;
}

- (CGPadding)contentPadding {
    return self.paddingEdge;
}

- (void)SWIZZLE_CALLBACK(draw_rect):(CGRect)rc {
    [super SWIZZLE_CALLBACK(draw_rect):rc];
    rc = self.rectForLayout;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx, rc.origin.x, rc.origin.y + rc.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    
    [CAStylizedTextLayer DrawStylizedString:self.string
                           attributedString:self.attributedString
                                  inContext:ctx
                                     inRect:rc];
}

static NSString* kUIStylizedStringViewKey = @"::ui::stylized::view";

- (CGFloat)ascentForItem:(id<NSStylizedItemCustom>)item {
    UIView* view = [[(id)item attachment].weak objectForKey:kUIStylizedStringViewKey];
    return view.frame.size.height;
}

- (CGFloat)descentForItem:(id<NSStylizedItemCustom>)item {
    return 0;
}

- (CGFloat)widthForItem:(id<NSStylizedItemCustom>)item {
    UIView* view = [[(id)item attachment].weak objectForKey:kUIStylizedStringViewKey];
    return view.frame.size.width;
}

- (UIView*)stylizedStringView:(UIStylizedStringView*)view customViewForStylizedItem:(id<NSStylizedItemCustom>)item {
    UIView* ret = nil;
    if (item.identifier == kStylizedIdentifierLink)
    {
        UILabelExt* lbl = [[UILabelExt alloc] initWithZero];
        lbl.highlightColor = [UIColor grayColor];
        NSStylizedString* str = [NSStylizedString temporary];
        [str append:item.stylization format:item.string];
        lbl.stylizedString = str;
        ret = lbl;
    }
    else if (item.identifier == kStylizedIdentifierImage)
    {
        UIImageViewExt* img = [[UIImageViewExt alloc] initWithZero];
        img.imageDataSource = item.string;
        ret = img;
    }
    else if (item.identifier == kStylizedIdentifierLabel)
    {
        UILabelExt* lbl = [[UILabelExt alloc] initWithZero];
        lbl.text = item.string;
        NSStylization* sty = [item stylization];
        if (sty.textColor)
            lbl.textColor = sty.textColor;
        if (sty.textFont)
            lbl.textFont = sty.textFont;
        ret = lbl;
    }
    return [ret autorelease];
}

@end

NSString* kStylizedIdentifierLink = @"::ui::stylized::idr::link";
NSString* kStylizedIdentifierImage = @"::ui::stylized::idr::image";
NSString* kStylizedIdentifierLabel = @"::ui::stylized::idr::label";

@implementation UIPageControl (extension)

SIGNALS_BEGIN

SIGNAL_ADD(kSignalSelectionChanged)
[self.signals connect:kSignalValueChanged withSelector:@selector(__cb_pc_valuedchanged:) ofTarget:self];

SIGNALS_END

- (void)__cb_pc_valuedchanged:(SSlot*)s {
    [self.signals emit:kSignalSelectionChanged withResult:@(self.currentPage)];
}

- (CGSize)bestSize:(CGSize)sz {
    CGSize ret = self.bounds.size;
    ret.width = self.numberOfPages * 20;
    return ret;
}

- (void)changeCurrentPage:(NSUInteger)currentPage {
    [[self.signals settingForSignal:kSignalValueChanged] block];
    self.currentPage = currentPage;
    [[self.signals settingForSignal:kSignalValueChanged] unblock];
}

@end

@implementation UIPageControlExt

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.userInteractionEnabled = NO;
    [self onInit];
    return self;
}

- (void)dealloc {
    [self onFin];
    [super dealloc];
}

SIGNALS_BEGIN

SIGNAL_ADD(kSignalSelectionChanged)
[self.signals connect:kSignalValueChanged withSelector:@selector(__cb_pc_valuedchanged:) ofTarget:self];

SIGNALS_END

- (void)__cb_pc_valuedchanged:(SSlot*)s {
    [self.signals emit:kSignalSelectionChanged withResult:@(self.currentPage)];
}

- (CGSize)bestSize:(CGSize)sz {
    CGSize ret = self.bounds.size;
    ret.width = self.numberOfPages * 20;
    return ret;
}

- (void)changeCurrentPage:(NSUInteger)currentPage {
    [[self.signals settingForSignal:kSignalValueChanged] block];
    self.currentPage = currentPage;
    [[self.signals settingForSignal:kSignalValueChanged] unblock];
}

@end

@implementation UITabBarItem (extension)

static int __gs_tabbaritem_tag = 0;

- (id)initWithTitle:(NSString*)title {
    return [self initWithTitle:title image:nil];
}

- (id)initWithImage:(UIImage*)image {
    return [self initWithTitle:nil image:image];
}

- (id)initWithTitle:(NSString*)title image:(UIImage*)image {
    self = [self initWithTitle:title image:image tag:__gs_tabbaritem_tag++];
    if (image == nil) {
        [self setTitlePositionAdjustment:UIOffsetMake(0, -15)];
    }
    return self;
}

- (id)initWithTabBarSystemItem:(UITabBarSystemItem)systemItem {
    return [self initWithTabBarSystemItem:systemItem tag:__gs_tabbaritem_tag++];
}

NSOBJECT_DYNAMIC_PROPERTY(UITabBarItem, images, setImages, RETAIN_NONATOMIC);
NSOBJECT_DYNAMIC_PROPERTY(UITabBarItem, highlightImages, setHighlightImages, RETAIN_NONATOMIC);

+ (instancetype)itemWithTitle:(NSString*)title {
    return [[self class] itemWithTitle:title image:nil];
}

+ (instancetype)itemWithImage:(UIImage*)image {
    return [[self class] itemWithTitle:nil image:image];
}

+ (instancetype)itemWithTitle:(NSString*)title image:(UIImage*)image {
    return [[[self alloc] initWithTitle:title image:image] autorelease];
}

+ (instancetype)itemWithTabBarSystemItem:(UITabBarSystemItem)systemItem {
    return [[[self alloc] initWithTabBarSystemItem:systemItem] autorelease];
}

static NSString* kUITabBarItemHighlightImageKey = @"::ui::tabbaritem::image::highlight";

- (void)setHighlightImage:(UIImage*)highlightImage {
    [self setFinishedSelectedImage:highlightImage withFinishedUnselectedImage:self.finishedUnselectedImage];
    [self.attachment.strong setObject:highlightImage forKey:kUITabBarItemHighlightImageKey];
}

- (UIImage*)highlightImage {
    UIImage* img = [self.attachment.strong objectForKey:kUITabBarItemHighlightImageKey];
    if (img)
        return img;
    return self.finishedSelectedImage;
}

- (void)setImage:(UIImage *)image {
    [self setFinishedSelectedImage:image withFinishedUnselectedImage:image];
}

- (UIImage*)image {
    return self.finishedUnselectedImage;
}

- (void)setImagePushed:(NSString *)name {
    self.highlightImage = [UIImage imageWithContentOfNamed:[name stringByAppendingString:kUIImageHighlightSuffix]];
    self.image = [UIImage imageWithContentOfNamed:name];
}

@end

NSCLASS_SUBCLASS(UITabBarExtBackgroundLayer, CALayer);

@implementation UITabBar (extension)

NSOBJECT_DYNAMIC_PROPERTY(UITabBar, edgeShadow, setEdgeShadow, RETAIN_NONATOMIC);

- (void)onAddedToWindow {
    [super onAddedToWindow];
    
    // 添加背景
    if (self.backgroundColor) {
        if ([self tabBarBackgroudLayer] == nil) {
            UITabBarExtBackgroundLayer* layer = [[UITabBarExtBackgroundLayer alloc] init];
            layer.backgroundColor = self.backgroundColor.CGColor;
            if (kIOS7Above) {
                [self.layer insertSublayer:layer atIndex:0];
            } else {
                [self.layer insertSublayer:layer atIndex:1];
            }
            SAFE_RELEASE(layer);
        }
        if (kIOS7Above) {
            self.barTintColor = self.backgroundColor;
            self.backgroundColor = nil;
        }
    }
    
    // 添加阴影
    if (self.edgeShadow) {
        [self.edgeShadow setIn:self.layer];
        CGRect shadowPath = CGRectMake(self.layer.bounds.origin.x - 10, self.layer.bounds.origin.y, self.layer.bounds.size.width + 20, 5);
        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowPath].CGPath;
    }
}

- (CALayer*)tabBarBackgroudLayer {
    return [self.layer.sublayers objectWithQuery:^id(id l) {
        if ([l isKindOfClass:[UITabBarExtBackgroundLayer class]])
            return l;
        return nil;
    }];
}

- (UIView*)itemViewAtIndex:(NSUInteger)idx {
    return [self.indexedItemViews objectAtIndex:idx def:nil];
}

- (UIView*)itemView:(UITabBarItem *)item {
    return [self itemViewAtIndex:[self.items indexOfObject:item]];
}

- (NSArray*)indexedItemViews {
    return self.itemViews;
}

- (NSUInteger)indexOfItemView:(UIView *)itemView {
    return [self.itemViews indexOfObject:itemView];
}

- (UITabBarItem*)itemOfItemView:(UIView *)itemView {
    NSUInteger idx = [self indexOfItemView:itemView];
    return [self.items objectAtIndex:idx def:nil];
}

static NSString* kUITabBarItemViewKey = @"::ui::tabbar::item::content";

+ (UIView*)ViewOfItem:(UIView*)itemView {
    return [itemView.attachment.weak objectForKey:kUITabBarItemViewKey];
}

+ (void)AddView:(UIView*)view toItemView:(UIView*)itemView {
    if (view.superview == nil)
    {
        view.frame = itemView.bounds;
        [itemView addSubview:view];
    }
    
    [itemView.attachment.weak setObject:view forKey:kUITabBarItemViewKey];
    [view.attachment.weak setObject:itemView forKey:kUITabBarItemViewKey];
}

NSOBJECT_DYNAMIC_PROPERTY_READONLY(UITabBar, itemViews, NSMutableArray);

- (void)SWIZZLE_CALLBACK(add_view):(UIView*)view {
    // ios7 下隐藏 line
    //if (kIOS7Above && [view isKindOfClass:[UIImageView class]]) {
    //    view.hidden = YES;
    //}
    
    NSMutableArray* items = (NSMutableArray*)self.itemViews;
    if ([[self class] IsTabBarItemView:view] &&
        [items containsObject:view] == NO)
    {
        // 保存系统item
        [items addObject:view];
        
        // 提供tabbaritem的信号功能
        [view.signals connect:kSignalClicked withSelector:@selector(__tabbar_item_clicked:) ofTarget:self];
        [view.signals connect:kSignalLongClicked withSelector:@selector(__tabbar_item_longclicked:) ofTarget:self];
        
        // 修剪一下
        NSArray* removed = [items removeObjectsNotIn:self.subviews];
        for (UIView* each in removed) {
            each = [[self class] ViewOfItem:each];
            [each removeFromSuperview];
        }
        
        // 调用后处理
        UITabBarController* vc = (id)self.belongViewController;
        if ([vc.delegate respondsToSelector:@selector(tabBarController:itemView:)]) {
            // 回调
            [vc.delegate performSelector:@selector(tabBarController:itemView:) withObject:vc withObject:view];
        }
        
        // 如果存在removed，则需要重新排序
        if (removed.count) {
            // 刷新一下排序
            [self updateIndexed];
        }
        
        // 标记捕获到系统ui，用来防止添加其他 view 时引起当 layout 时错误二次激活 selected 信号
        [self.attachment.strong setObject:@YES forKey:@"::ui::tabbar::got::sysui"];
    }
}

- (void)__tabbar_item_clicked:(SSlot*)s {
    UITabBarItem* tbi = [self itemOfItemView:(UIView*)s.sender];
    [tbi.signals emit:kSignalClicked];
}

- (void)__tabbar_item_longclicked:(SSlot*)s {
    UITabBarItem* tbi = [self itemOfItemView:(UIView*)s.sender];
    [tbi.signals emit:kSignalLongClicked];
}

- (void)SWIZZLE_CALLBACK(layout_subviews) {
    [self updateIndexed];
    
    UITabBarController* vc = (id)self.belongViewController;
    if ([vc.delegate respondsToSelector:@selector(tabBarController:itemViewFrameChanged:)]) {
        for (UIView* each in self.itemViews) {
            // 调整一下大小
            CGRect rc = each.frame;
            rc = CGRectDeflate(rc, -2, 0);
            each.frame = rc;

            // 回调
            [vc.delegate performSelector:@selector(tabBarController:itemViewFrameChanged:) withObject:vc withObject:each];
        }
    }
    
    // 调整一下背景layer
    CALayer* layer = [self tabBarBackgroudLayer];
    if (layer)
        layer.frame = self.bounds;
    
    // 需要刷新一下选中状态
    if ([self.attachment.strong getInt:@"::ui::tabbar::got::sysui"]) {
        SSlotTunnel* tun = [SSlotTunnel temporary];
        [vc.signals emit:kSignalSelectionChanging withResult:[vc.viewControllers objectAtIndex:vc.selectedIndex] withTunnel:tun];
        if (tun.vetoed == NO)
            [vc.signals emit:kSignalSelectionChanged withResult:[vc.viewControllers objectAtIndex:vc.selectedIndex]];
    }
    
    [self.attachment.strong setObject:@NO forKey:@"::ui::tabbar::got::sysui"];
}

- (void)updateIndexed {
    NSArray* items = [self.itemViews sortedArrayUsingComparator:^NSComparisonResult(UIView* obj1, UIView* obj2) {
        CGFloat x1 = CGRectGetMaxX(obj1.frame);
        CGFloat x2 = CGRectGetMaxX(obj2.frame);
        return x1 > x2;
    }];
    NSMutableArray* mut = (NSMutableArray*)self.itemViews;
    [mut setArray:items];
}

+ (BOOL)IsTabBarItemView:(id)o {
    NSString* name = NSStringFromClass([o class]);
    return [name hasPrefix:@"UITabBar"];
}

@end

@implementation UITabBarController (extension)

SIGNALS_BEGIN
SIGNAL_ADD(kSignalSelectionChanging)
SIGNAL_ADD(kSignalSelectionChanged)
SIGNAL_ADD(kSignalItemsChanged)
SIGNALS_END

@end

@implementation UITabBarControllerExt

- (id)init {
    self = [super init];
    //self.delegate = self; 调试发现 tabbar 会在 init 的时候就把 view 初始化成功
    //self.tabBar.belongViewController = self;
    //self.previousSelectedIndex = -1;
    [self onInit];
    self.view.frame = CGRectZero;
    return self;
}

- (void)dealloc {
    [self onFin];
    self.tabBar.belongViewController = nil;
    [super dealloc];
}

- (void)SWIZZLE_CALLBACK(view_loaded) {
    self.delegate = self;
    self.tabBar.belongViewController = self;
    self.previousSelectedIndex = -1;
    [super SWIZZLE_CALLBACK(view_loaded)];
}

- (void)onViewLayout {
    [super onViewLayout];
    
    // 如果是 ios6，会自动多余扣除一个tabheight
    if (kIOS7Above == NO) {
        UIViewController* cur = self.selectedViewController;
        UIView* v = cur.view;
        v.size = self.view.frame.size;
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    _previousSelectedIndex = self.selectedIndex;
    UIViewController* targetvc = [self.viewControllers objectAtIndex:selectedIndex];
    SSlotTunnel* tun = [SSlotTunnel temporary];
    [self.touchSignals emit:kSignalSelectionChanging withResult:targetvc withTunnel:tun];
    if (tun.vetoed == NO) {
        [super setSelectedIndex:selectedIndex];
        [self.touchSignals emit:kSignalSelectionChanged withResult:targetvc];
    }
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController {
    if (self.selectedViewController == selectedViewController)
        return;
    _previousSelectedIndex = self.selectedIndex;
    SSlotTunnel* tun = [SSlotTunnel temporary];
    [self.touchSignals emit:kSignalSelectionChanging withResult:selectedViewController withTunnel:tun];
    if (tun.vetoed == NO) {
        [super setSelectedViewController:selectedViewController];
        [self.touchSignals emit:kSignalSelectionChanged withResult:selectedViewController];
    }
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    [super setViewControllers:viewControllers animated:animated];
    [self.touchSignals emit:kSignalItemsChanged];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    SSlotTunnel* tun = [SSlotTunnel temporary];
    [self.touchSignals emit:kSignalSelectionChanging withResult:viewController withTunnel:tun];
    if (tun.vetoed)
        return NO;
    
    _previousSelectedIndex = self.selectedIndex;
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    // 会重复调用，和 setSelectedViewController
    // 如果是 ios6，会自动多余扣除一个tabheight
    if (kIOS7Above == NO) {
        UIViewController* cur = self.selectedViewController;
        UIView* v = cur.view;
        v.size = self.view.frame.size;
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController willBeginCustomizingViewControllers:(NSArray *)viewControllers {
    PASS;
}

- (void)tabBarController:(UITabBarController *)tabBarController willEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
    PASS;
}

- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
    PASS;
}

@end

@implementation UISearchBar (extension)

- (void)setBackgroundImageForSearchField:(UIImage *)backgroundImageForSearchField {
    [self setSearchFieldBackgroundImage:backgroundImageForSearchField forState:UIControlStateNormal];
}

- (UIImage*)backgroundImageForSearchField {
    return [self searchFieldBackgroundImageForState:UIControlStateNormal];
}

NSOBJECT_DYNAMIC_PROPERTY(UISearchBar, textAttributes, setTextAttributes, RETAIN_NONATOMIC);

- (CGSize)bestSize:(CGSize)sz {
    sz.height = kUISearchBarHeight;
    return sz;
}

NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR(UISearchBar, disableSearchTransition, setDisableSearchTransition, BOOL, @(val), [val boolValue], RETAIN_NONATOMIC);

- (void)setMotifColor:(UIColor *)motifColor {
    if (kIOS7Above)
        [self setBarTintColor:motifColor];
    else
        [self setTintColor:motifColor];
}

- (UIColor*)motifColor {
    if (kIOS7Above)
        return [self barTintColor];
    return [self tintColor];
}

- (void)updateAppearance {
    NSDictionary* atts = self.textAttributes;
    if (atts == nil)
        return;
    
    UIView* view = self;
    if (kIOS7Above) {
        view = self.subviews.firstObject;
    }
    
    for (UIView *each in view.subviews) {
        if ([each isKindOfClass:[UIButton class]]) {
            UIButton *btn = (id)each;

            UIColor* color = atts[UITextAttributeTextColor];
            if (color)
                btn.textColor = color;
            
            UIFont* font = atts[UITextAttributeFont];
            if (font)
                btn.textFont = font;
        }
    }
}

@end

@implementation UIViewController (searchbar)

NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR(UIViewController, isSearchBarResponding, setIsSearchBarResponding, BOOL,
    @(val),[val boolValue]
, RETAIN_NONATOMIC);

@end

@implementation UIView (searchbar)

NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR(UIViewController, disableSearchBarSearchTransition, setDisableSearchBarSearchTransition, BOOL,
                                       @(val), [val boolValue],
                                       RETAIN_NONATOMIC);

@end

@interface UISearchBarExt ()
<UISearchDisplayDelegate>

// 是否是独立显示，而不是和searchcontroller配合使用
@property (nonatomic, readonly, assign) BOOL standalone;

// 提供结果复用的数据集合
@property (nonatomic, readonly) NSMutableDictionary *constraintCells;
@property (nonatomic, readonly) NSMutableDictionary *constraintSizes;

@end

@implementation UISearchBarExt

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (!kIOS7Above)
    {
        // 隐藏系统的背景
        for (UIView* each in self.subviews) {
            NSString* str = NSStringFromClass(each.class);
            if ([str hasSuffix:@"Background"]) {
                [each removeFromSuperview];
                break;
            }
        }
        
        // 设置为灰色底
        self.backgroundColor = [UIColor colorWithRedi:187 green:187 blue:187];
    }
    
    // 使用自己处理事件
    self.delegate = self;
    
    // 其他设置
    self.showsCancelButtonWhileSearching = YES;
    self.keyboardAutoHide = YES;
    
    // 复用
    _constraintCells = [NSMutableDictionary new];
    _constraintSizes = [NSMutableDictionary new];
    
    [self onInit];
    return self;
}

- (void)dealloc {
    [self onFin];
    
    ZERO_RELEASE(_constraintCells);
    ZERO_RELEASE(_constraintSizes);
    ZERO_RELEASE(_displayer);
    [super dealloc];
}

- (CGSize)bestSize:(CGSize)sz {
    sz.height = kUISearchBarHeight;
    return sz;
}

SIGNALS_BEGIN

SIGNAL_ADD(kSignalCancel)
SIGNAL_ADD(kSignalDone)
SIGNAL_ADD(kSignalValueChanged)

SIGNAL_ADD(kSignalSearchStarting)
SIGNAL_ADD(kSignalSearchStart)
SIGNAL_ADD(kSignalSearchEnding)
SIGNAL_ADD(kSignalSearchEnd)
SIGNAL_ADD(kSignalSearchString)
SIGNAL_ADD(kSignalSearchScope)

SIGNALS_END

- (BOOL)standalone {
    if (self.belongViewController)
        return ![self.belongViewController isKindOfClass:[UISystemSearchBarController class]];
    return YES;
}

- (void)setContentsViewController:(UIViewController *)contentsViewController {
    PROPERTY_ASSIGN(_contentsViewController, contentsViewController);
    
    // 获得到content
    UIViewController* root = _contentsViewController;
    if (root == nil)
        root = [UIAppDelegate shared].topmostViewController;
    
    UISearchDisplayController* ctlr = [[UISearchDisplayController alloc] initWithSearchBar:self contentsController:root];
    self.displayer = ctlr;
    SAFE_RELEASE(ctlr);
    
    // 绑定数据结果的回调
    ctlr.delegate = self;
    ctlr.searchResultsDataSource = self;
    ctlr.searchResultsDelegate = self;
    ctlr.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 4.12 发现当searchbar位于内部时，搜索的结果存在偏移
    ctlr.searchResultsTableView.contentInset = UIEdgeInsetsMake(kUISearchBarHeight, 0, 0, 0);
}

- (UINavigationController*)navigationController {
    if (self.contentsViewController.navigationController)
        return self.contentsViewController.navigationController;
    return [UIAppDelegate shared].topmostViewController.navigationController;
}

- (UITableView*)tableView {
    return self.displayer.searchResultsTableView;
}

- (void)reloadData:(BOOL)flush {
    if (flush) {
        [_constraintSizes removeAllObjects];
    }
    
    [_displayer.searchResultsTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

static BOOL __gs_searchbar_isresponding = NO;

+ (BOOL)IsResponding {
    return __gs_searchbar_isresponding;
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    // 清0rowheight，以避免使用计算 heightforrow 的时候出错
    controller.searchResultsTableView.rowHeight = 0;
    
    __gs_searchbar_isresponding = YES;
    self.contentsViewController.isSearchBarResponding = YES;
    [self.signals emit:kSignalSearchStarting];
    
    // 设置一下不显示动画
    self.contentsViewController.view.disableSearchBarSearchTransition = self.disableSearchTransition;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    // 如果是vcsearchbar，则需要转化一下信号
    UIViewController* bvc = self.belongViewController;
    if (bvc && [bvc isKindOfClass:[UISystemSearchBarController class]]) {
        if ([bvc.signals isConnected:kSignalPullFlush])
            [self.tableView.signals connect:kSignalPullFlush ofTarget:bvc];
        if ([bvc.signals isConnected:kSignalPullMore])
            [self.tableView.signals connect:kSignalPullMore ofTarget:bvc];
    }
    
    // 发出已经激活搜索的信号
    [self.signals emit:kSignalSearchStart];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    [self.signals emit:kSignalSearchEnding];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    __gs_searchbar_isresponding = NO;
    self.contentsViewController.isSearchBarResponding = NO;
    [self.signals emit:kSignalSearchEnd];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    PASS;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView {
    PASS;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    PASS;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
    PASS;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {
    PASS;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    PASS;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self.signals emit:kSignalSearchString withResult:searchString];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self.signals emit:kSignalSearchScope withResult:[NSNumber numberWithInteger:searchOption]];
    return YES;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    // 如果是独立模式，而且打开了自动显示取消按钮
    if (self.standalone) {
        if (self.showsCancelButtonWhileSearching)
            self.showsCancelButton = YES;
        [self.signals emit:kSignalSearchStarting];
        [self.signals emit:kSignalSearchStart];
    }
    
    // 刷新一下自定义的样式
    [self updateAppearance];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if (self.standalone) {
        [self.signals emit:kSignalSearchEnding];
        [self.signals emit:kSignalSearchEnd];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.signals emit:kSignalValueChanged withResult:searchText];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.signals emit:kSignalSearchString withResult:searchBar.text];
    [self.signals emit:kSignalDone];
    
    // 如果是独立模式，而且打开了自动隐藏
    if (self.keyboardAutoHide && self.standalone) {
        self.focus = NO;
        if (self.showsCancelButtonWhileSearching)
            self.showsCancelButton = NO;
    }
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    PASS;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [self.signals emit:kSignalCancel];
    
    // 如果是独立模式，而且打开了自动显示取消的功能
    if (self.showsCancelButtonWhileSearching && self.standalone) {
        self.focus = NO;
        self.showsCancelButton = NO;
    }
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar {
    PASS;
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    PASS;
}

# pragma mark scroll-delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [(id)scrollView SWIZZLE_CALLBACK(didscroll)];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [(id)scrollView SWIZZLE_CALLBACK(begindragging)];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [(id)scrollView SWIZZLE_CALLBACK(enddragging):@(decelerate)];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [(id)scrollView SWIZZLE_CALLBACK(begindeceleration)];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [(id)scrollView SWIZZLE_CALLBACK(stopdeceleration)];
}

@end

@interface UISystemSearchBarController ()
<UITableViewDataSource, UITableViewDelegate>
@end

@implementation UISystemSearchBarController

- (void)onInit {
    [super onInit];
}

- (void)onFin {
    // 清空一下绑定
    UISearchBarExt* view = (UISearchBarExt*)self.view;
    view.displayer.delegate = nil;
    view.displayer.searchResultsDataSource = nil;
    view.displayer.searchResultsDelegate = nil;
    [super onFin];
}

SIGNALS_BEGIN

// 标准搜索用的信号
SIGNAL_ADD(kSignalCancel)
SIGNAL_ADD(kSignalDone)
SIGNAL_ADD(kSignalValueChanged)

SIGNAL_ADD(kSignalSearchStarting)
SIGNAL_ADD(kSignalSearchStart)
SIGNAL_ADD(kSignalSearchEnding)
SIGNAL_ADD(kSignalSearchEnd)
SIGNAL_ADD(kSignalSearchString)
SIGNAL_ADD(kSignalSearchScope)

// 因业务层使用时绑定信号通常早于searchTable的初始化，所以需要转一次信号
SIGNAL_ADD(kSignalPullFlush)
SIGNAL_ADD(kSignalPullMore)

SIGNALS_END

- (void)loadView {
    UISearchBarExt* view = [[UISearchBarExt alloc] initWithFrame:CGRectMake(0, 0, 0, kUISearchBarHeight)];
    view.belongViewController = self;
    self.view = view;
    SAFE_RELEASE(view);
    
    [view.signals redirects:@[
                              kSignalCancel,
                              kSignalDone,
                              kSignalValueChanged,
                              kSignalSearchStarting,
                              kSignalSearchStart,
                              kSignalSearchEnding,
                              kSignalSearchEnd,
                              kSignalSearchString,
                              kSignalSearchScope
                              ]
                   toTarget:self];
}

- (void)onLoaded {
    [super onLoaded];
}

- (void)setContentsViewController:(UIViewController *)contentsViewController {
    UISearchBarExt* view = (UISearchBarExt*)self.view;
    view.contentsViewController = contentsViewController;
    view.displayer.searchResultsDataSource = self;
    view.displayer.searchResultsDelegate = self;
}

- (UIViewController*)contentsViewController {
    UISearchBarExt* view = (UISearchBarExt*)self.view;
    return view.contentsViewController;
}

- (UITableView*)tableView {
    UISearchBarExt* view = (UISearchBarExt*)self.view;
    return view.tableView;
}

- (UISearchBar*)searchBar {
    UISearchBarExt* view = (UISearchBarExt*)self.view;
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self numberOfSectionsInTableViewExt:tableView];
}

- (NSInteger)numberOfSectionsInTableViewExt:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self tableViewExt:tableView numberOfRowsInSection:section];
}

- (NSInteger)tableViewExt:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (Class)tableViewExt:(UITableViewExt *)tableView itemClassForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.classForItem;
}

- (UITableViewCell*)tableView:(UITableViewExt *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableViewExt:tableView cellForRowAtIndexPath:indexPath];
}

- (UITableViewCell*)tableViewExt:(UITableViewExt *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Class cls4item = [self tableViewExt:tableView itemClassForRowAtIndexPath:indexPath];
    if (cls4item == nil)
        cls4item = [UIViewExt class];
    NSString* strcls4item = NSStringFromClass(cls4item);
    UITableViewCellExt* cell = nil;
    UITABLEVIEWCELLEXT_MAKECELL_EXT2(cls4item, UIView, strcls4item);
    
    // 初始化
    [self tableViewExt:tableView cell:cell item:cell.view atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.navigationController = self.bindedNavigationController;
    [cell updateData];
}

- (void)tableViewExt:(UITableView *)tableView cell:(UITableViewCellExt *)cell item:(UIView *)item atIndexPath:(NSIndexPath *)indexPath {
    PASS;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableViewExt:tableView heightForRowAtIndexPath:indexPath];
}

- (NSMutableDictionary*)constraintSizes {
    return self.searchBar.constraintSizes;
}

- (NSMutableDictionary*)constraintCells {
    return self.searchBar.constraintCells;
}

- (CGFloat)tableViewExt:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.rowHeight)
        return tableView.rowHeight;
    
    NSIndexPath* ip = [indexPath clone];
    
    // 如果已经存在计算好的大小，则直接使用
    NSSize* sz = [self.constraintSizes objectForKey:ip];
    if (sz)
        return sz.height;
    
    // 否则通过cell来计算应该有的高度
    id<UITableViewDataSourceExt, UITableViewDataSource> ds = (id)self.tableView.dataSource;
    UITableViewCell* cell = nil;
    cell = [ds tableView:tableView cellForRowAtIndexPath:ip];
    if ([cell isKindOfClass:[UITableViewNullCell class]])
        return 0;
    
    if (cell.reuseIdentifier) {
        if ([self.constraintCells existsQueObject:cell forKey:cell.reuseIdentifier] == NO)
            [self.constraintCells pushQueObject:cell forKey:cell.reuseIdentifier];
    }
    
    CGFloat ret = 0;
    
    if ([cell isKindOfClass:[UITableViewCellExt class]])
    {
        UITableViewCellExt* cellext = (UITableViewCellExt*)cell;
        if ([cellext.view conformsToProtocol:@protocol(UIConstraintView)])
        {
            // 强制数据模式
            DATA_ONLY_MODE = YES;
            
            // 保护大小以避免计算出错的问题
            CGRect defrc = cell.frame;
            defrc.size.width = tableView.bounds.size.width;
            if (defrc.size.width == 0) {
                DATA_ONLY_MODE = NO;
                return 0;
            }
            if (defrc.size.height == 0)
                defrc.size.height = 568;
            cell.frame = defrc;
            
            // 需要强制刷新一下数据，才能获得正确的大小
            [cell updateData];
            
            // 保护处理一下第一个cell，以初始化子控件的大小
            if (cellext.isReused == NO) {
                [cell layoutSubviews];
                if (cell.behalfView != cell)
                    [cell.behalfView layoutSubviews];
            }
            
            // 调整大小
            [cell layoutSubviews];
            if (cell.behalfView != cell)
                [cell.behalfView layoutSubviews];
            
            // 恢复UI模式
            DATA_ONLY_MODE = NO;
            
            // 计算并写入约束大小
            sz = [NSSize size:[(UIConstraintView*)cell.behalfView constraintBounds]];
        }
        else
        {
            sz = [NSSize size:[cell.behalfView bestSize]];
        }
        
        if (sz.height) {
            sz.height += CGPaddingHeight(cellext.paddingEdge);
            ret = sz.height;
        }
        
        if ([cellext.view conformsToProtocol:@protocol(UIConstraintView)])
            [self.constraintSizes setObject:sz forKey:ip];
    }

    return ret;
}

// 不能给navigation设置自定义的navigationcontroller，这将引起位于tableview或可能其他地方时候的析构崩溃
- (UINavigationController*)navigationController {
    return [self performSelector:@selector(standardNavigationController)];
}

- (id)bindedNavigationController {
    return [self performSelector:@selector(customNavigationController)];
}

# pragma mark scroll-delegate.

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [(id)scrollView SWIZZLE_CALLBACK(didscroll)];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [(id)scrollView SWIZZLE_CALLBACK(begindragging)];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [(id)scrollView SWIZZLE_CALLBACK(enddragging):@(decelerate)];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [(id)scrollView SWIZZLE_CALLBACK(begindeceleration)];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [(id)scrollView SWIZZLE_CALLBACK(stopdeceleration)];
}

@end

# define kUISearchBarBackground 0xc9c9ce

@interface UIUnifiedSearchBarActivatedDesktop : UIViewExt

@property (nonatomic, assign) UIUnifiedSearchBar *owner;
@property (nonatomic, assign) UISearchBarExt *searchBar;
@property (nonatomic, assign) UIViewControllerStack *stackController;

@end

@implementation UIUnifiedSearchBarActivatedDesktop

- (void)onInit {
    [super onInit];
}

- (void)onFin {
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalClosed)
SIGNALS_END

- (void)openIn:(UIViewController*)ctlr {
    UIDesktop* desk = [UIDesktop desktopWithView:self];
    [desk.signals connect:kSignalClosed ofTarget:self];
    desk.clickToClose = NO;
    if (ctlr)
        [desk openIn:ctlr];
    else
        [desk open];
}

- (void)close {
    [self.signals emit:kSignalRequestClose];
}

- (void)setSearchBar:(UISearchBarExt *)searchBar {
    [_searchBar.signals disconnectToTarget:self];
    _searchBar = searchBar;
    _searchBar.userInteractionEnabled = YES;
    [self forceAddSubview:_searchBar];
    
    _searchBar.focus = YES;
    
    // 点击取消的时候隐藏
    [_searchBar.signals connect:kSignalCancel withSelector:@selector(__usb_cancel) ofTarget:self];
}

- (void)setOwner:(UIUnifiedSearchBar *)owner {
    _owner = owner;
    self.backgroundColor = _owner.backgroundColor;
}

- (void)setStackController:(UIViewControllerStack *)stackController {
    _stackController = stackController;
    [self addSubview:_stackController.view];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    UIVBox* box = [UIVBox boxWithRect:rect];
    [box addPixel:kUIStatusBarHeight toView:nil];
    [box addPixel:_searchBar.frame.size.height toView:_searchBar];
    [box addFlex:1 toView:_stackController.view];
    [box apply];
}

- (void)__usb_cancel {
    [_searchBar.signals disconnectToTarget:self];
    _searchBar.focus = NO;
    _searchBar.userInteractionEnabled = NO;
    
    [_owner forceAddSubview:_searchBar];
    
    [self close];
}

@end

@interface UIUnifiedSearchBar ()
{
    UIUnifiedSearchBarActivatedDesktop* _desk;
}

@end

@implementation UIUnifiedSearchBar

- (void)onInit {
    [super onInit];
    
    self.backgroundColor = [UIColor colorWithRGB:kUISearchBarBackground];
    self.heightForSearchBar = 0;
    
    [self addSubview:BLOCK_RETURN({
        _searchBar = [UISearchBarExt temporary];
        _searchBar.userInteractionEnabled = NO;
        return _searchBar;
    })];
    
    [self assignSubcontroller:BLOCK_RETURN({
        _stackController = [UIViewControllerStack temporary];
        return _stackController;
    })];
    
    [_searchBar.signals redirects:@[
                                    kSignalCancel,
                                    kSignalDone,
                                    kSignalValueChanged,
                                    kSignalSearchStarting,
                                    kSignalSearchStart,
                                    kSignalSearchEnding,
                                    kSignalSearchEnd,
                                    kSignalSearchString,
                                    kSignalSearchScope,
                                    kSignalCancel
                                    ]
                         toTarget:self];
    
    [self.signals connect:kSignalClicked withSelector:@selector(__usb_search_starting) ofTarget:self];
}

- (void)onFin {
    [super onFin];
}

SIGNALS_BEGIN

// 标准搜索用的信号
SIGNAL_ADD(kSignalCancel)
SIGNAL_ADD(kSignalDone)
SIGNAL_ADD(kSignalValueChanged)

SIGNAL_ADD(kSignalSearchStarting)
SIGNAL_ADD(kSignalSearchStart)
SIGNAL_ADD(kSignalSearchEnding)
SIGNAL_ADD(kSignalSearchEnd)
SIGNAL_ADD(kSignalSearchString)
SIGNAL_ADD(kSignalSearchScope)
SIGNAL_ADD(kSignalCancel)

SIGNALS_END

- (CGSize)bestSize:(CGSize)sz {
    CGSize ret = [self.class BestSize:sz];
    return CGSizeUnapplyPadding(ret, self.paddingEdge);
}

+ (CGSize)BestSize:(CGSize)sz {
    return CGSizeMake(kUIApplicationSize.width, kUISearchBarHeight);
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    if (self.heightForSearchBar == 0) {
        _searchBar.frame = rect;
    } else {
        UIVBox* box = [UIVBox boxWithRect:rect];
        if (kIOS7Above)
            [box addPixel:kUIStatusBarHeight toView:_searchBar];
        [box addPixel:self.heightForSearchBar toView:_searchBar];
        [box apply];
    }
}

- (void)__usb_search_starting {
    // 如果已经打开，则不需要做动画
    if (self.actived)
        return;
    self.actived = YES;
}

- (void)setActived:(BOOL)actived {
    if (_actived == actived)
        return;
    _actived = actived;
    
    // 如果已经打开，则隐藏
    if (_desk)
    {
        [_desk close];
        ZERO_RELEASE(_desk);
    }
    else
    {
        _desk = [UIUnifiedSearchBarActivatedDesktop temporary];
        _desk.searchBar = _searchBar;
        _desk.stackController = _stackController;
        _desk.owner = self;
        [_desk openIn:self.contentViewController];
        
        // 如果关闭，需要修改一下状态
        [_desk.signals connect:kSignalClosed withSelector:@selector(__usb_desk_close) ofTarget:self];
    }
}

- (void)__usb_desk_close {
    _desk = nil;
    _actived = NO;
}

NSPROPERTY_BRIDGE_TO(placeholder, setPlaceholder, self.searchBar.placeholder, NSString*);

@end

@implementation UIUnifiedSearchBarController

- (void)onInit {
    [super onInit];
    self.hidesTopBarWhenPushed = YES;
    self.classForView = [UIUnifiedSearchBar class];
}

- (void)onLoaded {
    [super onLoaded];
    
    UIUnifiedSearchBar* bar = self.searchBar;
    bar.contentViewController = self;
    bar.actived = YES;
    bar.heightForSearchBar = kUISearchBarHeight;
    [bar.signals connect:kSignalCancel withSelector:@selector(goBack) ofTarget:self];
}

- (UIUnifiedSearchBar*)searchBar {
    return (id)self.view;
}

@end

@interface UICaretIdentifier ()

@property (nonatomic, assign) int mode;

@end

@implementation UICaretIdentifier

- (void)onInit {
    [super onInit];
    
    self.color = [UIColor blackColor];
    self.blink = YES;
    self.mode = 0;
    
    [[[NSCron shared] addConfig:@"*/1 * *"].signals connect:kSignalCronActive withSelector:@selector(doBlink) ofTarget:self];
}

- (void)onFin {
    ZERO_RELEASE(_color);
    [super onFin];
}

- (void)doBlink {
    self.mode = !self.mode;
    [self setNeedsDisplay];
}

- (void)onDraw:(CGRect)rect {
    [super onDraw:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (self.mode) {
        CGContextSetFillColorWithColor(ctx, self.color.CGColor);
        CGContextFillRect(ctx, rect);
    }
}

- (CGSize)bestSize:(CGSize)sz {
    return CGSizeMake(1, 10);
}

@end

@interface UIBlurStage : CADisplayStage

@end

@implementation UIBlurStage

SHARED_IMPL;

- (id)init {
    self = [super init];
    self.fps = 30;
    return self;
}

@end

@interface UIBlurView ()

@property (nonatomic, readonly) GPUImageView *vBlur;
@property (nonatomic, readonly) GPUImageiOSBlurFilter *gpuBlur;

@end

@implementation UIBlurView

- (void)onInit {
    [super onInit];
  
    _vBlur = [[GPUImageView alloc] init];
    _vBlur.userInteractionEnabled = NO;
    [self addSubview:_vBlur];
    SAFE_RELEASE(_vBlur);
    
    _gpuBlur = [[GPUImageiOSBlurFilter alloc] init];
    
    // 在显示队列里面刷新
    [[UIBlurStage shared].signals connect:kSignalTakeAction withSelector:@selector(__cb_nextframe) ofTarget:self];
}

- (void)onFin {
    ZERO_RELEASE(_blur);
    ZERO_RELEASE(_gpuBlur);
    [super onFin];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    _vBlur.frame = rect;
}

- (void)setBlur:(CGBlur *)blur {
    PROPERTY_RETAIN(_blur, blur);
    
    _gpuBlur.blurRadiusInPixels = blur.radius * 0.2f;
    _gpuBlur.saturation = blur.saturation;
}

- (void)__cb_nextframe {
    if (self.viewForBlur == nil)
        return;
    CGRect rc = [self.viewForBlur convertRect:self.frame fromView:self.superview];
    UIImage* img = [self.viewForBlur renderRectToImage:rc];
    GPUImagePicture* pic = [[GPUImagePicture alloc] initWithImage:img];
    [pic addTarget:_gpuBlur];
    [_gpuBlur addTarget:_vBlur];
    [pic processImage];
    SAFE_RELEASE(pic);
}

@end

@interface UISyncBlurView ()

@property (nonatomic, readonly) UIToolbar *vTb;
@property (nonatomic, readonly) UIViewExt *vMask;

@end

@implementation UISyncBlurView

- (void)onInit {
    [super onInit];
    
    if (kIOS7Above) {
        _vTb = [UIToolbar temporary];
        _vTb.userInteractionEnabled = NO;
        [self addSubview:_vTb];
    }
    
    _vMask = [UIViewExt temporary];
    _vMask.userInteractionEnabled = NO;
    [self addSubview:_vMask];
}

- (void)onFin {
    ZERO_RELEASE(_blur);
    [super onFin];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    _vTb.frame = rect;
    _vMask.frame = rect;
}

- (void)setBlur:(CGBlur *)blur {
    PROPERTY_RETAIN(_blur, blur);
    
    UIColor* color = [UIColor colorWithCGColor:blur.tintColor];
    _vMask.backgroundColor = color;
    //_vMask.alpha = color.componentAlpha;
}

@end

@implementation UISegmentedControl (extension)

SIGNALS_BEGIN
SIGNAL_ADD(kSignalSelectionChanged)
[self.signals connect:kSignalValueChanged redirectTo:kSignalSelectionChanged ofTarget:self];
SIGNALS_END

- (void)onAddedToSuperview {
    [super onAddedToSuperview];
    
    // 如果是从初始状态转进来，是不会默认激活初始选中的信号，所以要手动激活一下
    if (self.selectedSegmentIndex != UISegmentedControlNoSegment) {
        [self.signals emit:kSignalSelectionChanged];
    }
}

@end

@implementation UISegmentedControlExt

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self onInit];
    return self;
}

- (void)dealloc {
    [self onFin];
    [super dealloc];
}

@end

@implementation UIToolbar (extension)

- (CGSize)bestSize:(CGSize)sz {
    return CGSizeMake(kUIApplicationSize.width, kUIToolBarHeight);
}

@end

@implementation UIToolbarPanel

+ (instancetype)panelWithView:(UIView*)view {
    return [[[self alloc] initWithView:view] autorelease];
}

- (id)initWithView:(UIView*)view {
    self = [super init];
    self.contentView = view;
    return self;
}

- (void)onInit {
    [super onInit];
    
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, kUIToolBarHeight)];
    [self addSubview:_toolbar];
    SAFE_RELEASE(_toolbar);
}

- (void)setContentView:(UIView *)contentView {
    if (_contentView == contentView)
        return;
    [_contentView removeFromSuperview];
    _contentView = contentView;
    [self addSubview:_contentView];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox* box = [UIVBox boxWithRect:rect];
    [box addPixel:_toolbar.frame.size.height toView:_toolbar];
    [box addFlex:1 toView:_contentView];
    [box apply];
}

- (CGSize)bestSize:(CGSize)sz {
    CGSize ret;
    ret.width = kUIApplicationSize.width;
    ret.height = _toolbar.frame.size.height + _contentView.bestHeight;
    return ret;
}

@end

@implementation UISlider (extension)

- (void)setPercentage:(NSPercentage*)prc {
    self.value = prc.value;
    self.minimumValue = 0;
    self.maximumValue = prc.max;
}

- (NSPercentage*)percentage {
    return [NSPercentage percentWithMax:self.maximumValue value:self.value];
}

@end

@implementation UIProgressView (extension)

+ (id)temporary {
    return [self.class Default];
}

+ (instancetype)progressViewStyle:(UIProgressViewStyle)style {
    return [[[self alloc] initWithProgressViewStyle:style] autorelease];
}

+ (instancetype)Default {
    return [[self class] progressViewStyle:UIProgressViewStyleDefault];
}

+ (instancetype)Toolbar {
    return [[self class] progressViewStyle:UIProgressViewStyleBar];
}

- (void)setPercentage:(NSPercentage*)prc {
    self.progress = prc.percent;
}

- (NSPercentage*)percentage {
    return [NSPercentage percent:self.progress];
}

- (CGSize)bestSize:(CGSize)sz {
    CGFloat h = 0;
    if (kIOS7Above)
        h = 4;
    else
        h = 8;
    return CGSizeMake(0, h);
}

@end

@implementation UIPickerView (extension)

- (CGSize)bestSize:(CGSize)sz {
    return CGSizeMake(kUIApplicationSize.width, 162);
}

+ (CGSize)BestSize:(CGSize)sz {
    return CGSizeMake(kUIApplicationSize.width, 162);
}

@end

@implementation UIPickerViewExt

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.dataSource = self;
    self.delegate = self;
    
    [self onInit];
    return self;
}

- (void)dealloc {
    [self onFin];
    
    ZERO_RELEASE(_datas);
    ZERO_RELEASE(_sizes);
    ZERO_RELEASE(_selected);
    ZERO_RELEASE(_selectedDatas);
    ZERO_RELEASE(_selectedString);
    [super dealloc];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalSelectionChanged)
SIGNALS_END

- (void)setDatas:(NSArray *)datas {
    PROPERTY_RETAIN(_datas, datas);
    [self reloadAllComponents];
}

- (void)reloadAllComponents {
    [super reloadAllComponents];
    [self __updateSelected];
}

- (void)__updateSelected {
    NSMutableArray* tmp = [NSMutableArray temporary];
    for (int i = 0; i < self.numberOfComponents; ++i) {
        [tmp addObject:@([self selectedRowInComponent:i])];
    }
    
    PROPERTY_RETAIN(_selected, tmp);
    PROPERTY_RETAIN(_selectedString, [[tmp arrayWithCollector:^id(id l) {
        return [l stringValue];
    }] componentsJoinedByString:@"."]);
    
    // 如果datas不是空，则刷新data列表
    if (_datas != nil)
    {
        NSMutableArray* arr = [NSMutableArray temporary];
        [_selected foreachWithIndex:^BOOL(NSNumber* selected, NSInteger idx) {
            [arr addObject:_datas[idx][selected.intValue]];
            return YES;
        }];
        
        PROPERTY_RETAIN(_selectedDatas, arr);
    }
}

- (void)setSelectedDatas:(NSArray *)selectedDatas {
    PROPERTY_RETAIN(_selectedDatas, selectedDatas);
    // 计算每一秩的下标
    NSInteger range = MIN(_selectedDatas.count, _datas.count);
    for (NSInteger i = 0; i < range; ++i) {
        id tgt = _selectedDatas[i];
        NSArray* des = _datas[i];
        NSInteger idx = [des indexOfObject:tgt];
        if (idx != NSNotFound) {
            [self selectRow:idx inComponent:i animated:NO];
        }
    }
}

- (void)setSelected:(NSArray *)selected {
    PROPERTY_RETAIN(_selected, selected);
    for (int i = 0; i < selected.count; ++i) {
        NSNumber* num = [selected objectAtIndex:i];
        [self selectRow:num.intValue inComponent:i animated:YES];
    }
}

- (void)setSelectedString:(NSString *)selectedString {
    PROPERTY_RETAIN(_selectedString, selectedString);
    NSArray* cmps = [selectedString componentsSeparatedByString:@"."];
    NSInteger const cnt = MIN(cmps.count, self.numberOfComponents);
# ifdef DEBUG_MODE
    if (cnt != self.numberOfComponents)
        INFO("输入的选中字串拆分出来的数目和原有的数目不一致");
# endif
    for (int i = 0; i < cnt; ++i) {
        NSString* row = [cmps objectAtIndex:i];
        if (row.notEmpty)
            [self selectRow:row.intValue inComponent:i animated:YES];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.datas.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray* sub = [self.datas objectAtIndex:component def:nil];
    return [sub countByCollector:^NSInteger(id obj) {
        return ![obj isKindOfClass:[NSNull class]];
    }];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSArray* sub = [self.datas objectAtIndex:component def:nil];
    id str = [sub objectAtIndex:row def:nil];
    if ([str isKindOfClass:[UIString class]]) {
        return ((UIString*)str).text;
    }
    return [str stringValue];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSArray* sub = [self.datas objectAtIndex:component def:nil];
    id str = [sub objectAtIndex:row def:nil];
    if ([str isKindOfClass:[UIString class]]) {
        return ((UIString*)str).stylizedString.attributedString;
    }
    return nil;
}

/*
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;
 */

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self __updateSelected];
    NSPoint* pt = [NSPoint point:CGPointMake(component, row)];
    [self.signals emit:kSignalSelectionChanged withResult:pt];
}

@end

@interface UIViewStack ()
{
    NSMutableArray* _views;
}

@end

@implementation UIViewStack

- (void)onInit {
    [super onInit];
    _views = [[NSMutableArray alloc] init];
    self.animationDelegate = self;
}

- (void)onFin {
    ZERO_RELEASE(_views);
    [super onFin];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];

    for (UIView* each in _views) {
        each.frame = rect;
    }
}

- (void)pushView:(UIView *)view animated:(BOOL)animated {
    [self pushView:view animated:animated custom:nil];
}

- (UIView*)popViewWithAnimated:(BOOL)animated {
    return [self popViewWithAnimated:animated custom:nil];
}

- (void)pushView:(UIView*)view animated:(BOOL)animated custom:(void(^)(UIView* p, UIView* n, BOOL reverse))custom {
    if (_views.count == 0)
        animated = NO;

    // 调整推入的显示
    UIView* pastV = _views.lastObject;
    [_views addObject:view];
    [self addSubview:view];
    view.frame = self.rectForLayout;
    
    // 显示推入的动画
    if (animated == YES) {
        if (custom) {
            custom(pastV, view, NO);
        } else {
            if ([view conformsToProtocol:@protocol(UIStackAnimation)]) {
                id<UIStackAnimation> pv = (id)view;
                if ([pv respondsToSelector:@selector(ignoreParticularAnimation)] &&
                    pv.ignoreParticularAnimation) {
                    [self.animationDelegate stackAnimatesfrom:pastV to:view reverse:NO];
                } else {
                    [pv stackAnimatesfrom:pastV to:view reverse:NO];
                }
            } else {
                [self.animationDelegate stackAnimatesfrom:pastV to:view reverse:NO];
            }
        }
    }
}

- (UIView*)popViewWithAnimated:(BOOL)animated custom:(void(^)(UIView* p, UIView* n, BOOL reverse))custom {
    if (_views.count <= 1)
        return nil;
    
    UIView* view = [_views.lastObject consign];
    [_views removeObject:view];
    UIView* nowview = _views.lastObject;
    
    if (animated == NO) {
        [view removeFromSuperview];
    } else {
        if (custom) {
            custom(view, nowview, YES);
        } else {
            if ([view conformsToProtocol:@protocol(UIStackAnimation)]) {
                id<UIStackAnimation> pv = (id)view;
                if ([pv respondsToSelector:@selector(ignoreParticularAnimation)] &&
                    pv.ignoreParticularAnimation) {
                    [self.animationDelegate stackAnimatesfrom:view to:nowview reverse:YES];
                } else {
                    [pv stackAnimatesfrom:view to:nowview reverse:YES];
                }
            } else {
                [self.animationDelegate stackAnimatesfrom:view to:nowview reverse:YES];
            }
        }
        
        DISPATCH_DELAY_BEGIN(kCAAnimationDuration)
        [view removeFromSuperview];
        DISPATCH_DELAY_END
    }
    
    return view;
}

- (UIView*)removeViewAtIndex:(NSInteger)idx {
    UIView* vi = [[_views objectAtIndex:idx def:nil] consign];
    if (vi == nil)
        return nil;
    
    [_views removeObject:vi];
    [vi removeFromSuperview];
    
    return vi;
}

- (void)pushView:(UIView*)view {
    [self pushView:view animated:YES];
}

- (void)pushViewNonAnimated:(UIView*)view {
    [self pushView:view animated:NO];
}

- (UIView*)popView {
    return [self popViewWithAnimated:YES];
}

- (UIView*)popViewNonAnimated {
    return [self popViewWithAnimated:NO];
}

- (void)stackAnimatesfrom:(UIView *)from to:(UIView *)to reverse:(BOOL)reverse {
    [from.layer addAnimation:[CAKeyframeAnimationExt FadeOut]];
    [to.layer addAnimation:[CAKeyframeAnimationExt FadeIn]];
}

- (CGSize)bestSize:(CGSize)sz {
    return kUIApplicationSize;
}

@end

@interface UIViewControllerStack ()
{
    NSMutableArray* _viewControllers;
}

@property (nonatomic, assign) UIViewController *visibledViewController;

@end

@implementation UIViewControllerStack

@synthesize viewControllers = _viewControllers;

- (void)onInit {
    [super onInit];
    self.classForView = [UIViewStack class];
    _viewControllers = [[NSMutableArray alloc] init];
}

- (void)onFin {
    ZERO_RELEASE(_viewControllers);
    [super onFin];
}

- (void)onLoaded {
    [super onLoaded];
    self.animationDelegate = self;
}

@dynamic animationDelegate;

- (void)setAnimationDelegate:(id<UIStackAnimation>)animationDelegate {
    UIViewStack* view = (id)self.view;
    view.animationDelegate = animationDelegate;
}

- (id<UIStackAnimation>)animationDelegate {
    UIViewStack* view = (id)self.view;
    return view.animationDelegate;
}

- (void)pushViewController:(UIViewController*)vc animated:(BOOL)animated {
    if (_viewControllers.count == 0)
        animated = NO;
    
    // 添加到数组中
    [vc.signals connect:kSignalViewAppear withSelector:@selector(__sckvcs_appeared:) ofTarget:self];
    [_viewControllers addObject:vc];
    [self assignSubcontroller:vc];

    // 添加显示
    UIViewStack* view = (id)self.view;
    [view pushView:vc.view animated:animated custom:^(UIView *p, UIView *n, BOOL reverse) {
        if ([vc conformsToProtocol:@protocol(UIStackAnimation)]) {
            id<UIStackAnimation> pvc = (id)vc;
            if ([pvc respondsToSelector:@selector(ignoreParticularAnimation)] &&
                pvc.ignoreParticularAnimation) {
                [self.animationDelegate stackAnimatesfrom:p to:n reverse:reverse];
            } else {
                [pvc stackAnimatesfrom:p to:n reverse:reverse];
            }
        } else {
            [self.animationDelegate stackAnimatesfrom:p to:n reverse:reverse];
        }
    }];
    
    self.title = vc.title;
    _visibledViewController = vc;
}

- (void)__sckvcs_appeared:(SSlot*)s {
    UIViewController* vc = (id)s.sender;
    // 如果键盘当前已经弹开，则需要自动激活第一个可以修改的元素
    if ([UIKeyboardExt shared].visible)
        [vc.view anyFocus];
}

- (UIViewController*)popViewControllerWithAnimated:(BOOL)animated {
    if (_viewControllers.count <= 1)
        return nil;
    
    // 从数组中移除
    UIViewController* vc = [_viewControllers.lastObject consign];
    [_viewControllers removeObject:vc];
    UIViewController* nowvc = _viewControllers.lastObject;
    [self unassignSubcontroller:vc];
    
    UIViewStack* view = (id)self.view;
    [view popViewWithAnimated:animated custom:^(UIView *p, UIView *n, BOOL reverse) {
        if ([vc conformsToProtocol:@protocol(UIStackAnimation)]) {
            id<UIStackAnimation> pvc = (id)vc;
            if ([pvc respondsToSelector:@selector(ignoreParticularAnimation)] &&
                pvc.ignoreParticularAnimation) {
                [self.animationDelegate stackAnimatesfrom:p to:n reverse:reverse];
            } else {
                [pvc stackAnimatesfrom:p to:n reverse:reverse];
            }
        } else {
            [self.animationDelegate stackAnimatesfrom:p to:n reverse:reverse];
        }
    }];
    
    self.title = nowvc.title;
    _visibledViewController = nowvc;
    return vc;
}

- (UIViewController*)removeViewControllerAtIndex:(NSInteger)idx {
    UIViewController* vc = [[_viewControllers objectAtIndex:idx def:nil] consign];
    if (vc == nil)
        return nil;
    
    [_viewControllers removeObject:vc];
    [self unassignSubcontroller:vc];
    
    UIViewStack* view = (id)self.view;
    [view removeViewAtIndex:idx];
    
    return vc;
}

- (void)pushViewController:(UIViewController*)vc {
    [self pushViewController:vc animated:YES];
}

- (void)pushViewControllerNonAnimated:(UIViewController*)vc {
    [self pushViewController:vc animated:NO];
}

- (UIViewController*)popViewController {
    return [self popViewControllerWithAnimated:YES];
}

- (UIViewController*)popViewControllerNonAnimated {
    return [self popViewControllerWithAnimated:NO];
}

- (void)popToViewController:(UIViewController*)vc animated:(BOOL)animated {
    NSInteger idx = [self.viewControllers indexOfObject:vc];
    if (idx == NSNotFound) {
        WARN("期望抛出到一个不存在的 vc");
        return;
    }
    
    [self popToViewControllerAtIndex:idx animated:animated];
}

- (void)popToViewControllerAtIndex:(NSInteger)idx animated:(BOOL)animated {
    NSInteger curidx = [self.viewControllers indexOfObject:self.visibledViewController];
    if (curidx == idx)
        return;
    NSInteger all = self.viewControllers.count;
    NSInteger cnt = all - idx;
    while (cnt--) {
        [self popViewControllerNonAnimated];
    }
}

- (void)popToRootViewController {
    [self popToViewControllerAtIndex:0 animated:YES];
}

- (void)popToRootViewControllerNonAnimated {
    [self popToViewControllerAtIndex:0 animated:NO];
}

- (void)stackAnimatesfrom:(UIView *)from to:(UIView *)to reverse:(BOOL)reverse {
    if (reverse) {
        [from.layer addAnimation:[CAKeyframeAnimationExt SlideToRight:from]];
        [to.layer addAnimation:[CAKeyframeAnimationExt SlideFromLeft:to]];
    } else {
        [from.layer addAnimation:[CAKeyframeAnimationExt SlideToLeft:from]];
        [to.layer addAnimation:[CAKeyframeAnimationExt SlideFromRight:to]];
    }
}

@end

@implementation UISketchView

+ (Class)layerClass {
    return [CASketchLayer class];
}

@dynamic sketch;

- (CGSketch*)sketch {
    return ((CASketchLayer*)self.layer).sketch;
}

- (void)setSketch:(CGSketch *)sketch {
    ((CASketchLayer*)self.layer).sketch = sketch;
}

- (void)clear {
    [(CASketchLayer*)self.layer clear];
}

@end

@implementation UITablePanelPattern

- (id)initWithPatterns:(NSDictionary*)dict {
    self = [self init];
    self.patterns = dict;
    return self;
}

+ (instancetype)patterns:(NSDictionary*)dict {
    return [[[self.class alloc] initWithPatterns:dict] autorelease];
}

- (void)dealloc {
    ZERO_RELEASE(_patterns);
    [super dealloc];
}

- (UIImage*)cellImageAtIndexPath:(NSIndexPath*)ip {
    NSInteger cells = [self.tableView numberOfRowsInSection:ip.section];
    UIPanelPatternType tp = kUIPanelPatternTypeSingle;
    if (cells > 1) {
        if (cells == 2) {
            if (ip.row == 0)
                tp = kUIPanelPatternTypeHeader;
            else
                tp = kUIPanelPatternTypeFooter;
        } else {
            if (ip.row == 0)
                tp = kUIPanelPatternTypeHeader;
            else if (ip.row == cells - 1)
                tp = kUIPanelPatternTypeFooter;
            else
                tp = kUIPanelPatternTypeBody;
        }
    }
    return [self.patterns objectForKey:@(tp)];
}

- (void)setPattern:(void(^)(UIPanelPatternType, UIImage*))block atIndexPath:(NSIndexPath*)ip {
    NSInteger cells = [self.tableView numberOfRowsInSection:ip.section];
    UIPanelPatternType tp = kUIPanelPatternTypeSingle;
    if (cells > 1) {
        if (cells == 2) {
            if (ip.row == 0)
                tp = kUIPanelPatternTypeHeader;
            else
                tp = kUIPanelPatternTypeFooter;
        } else {
            if (ip.row == 0)
                tp = kUIPanelPatternTypeHeader;
            else if (ip.row == cells - 1)
                tp = kUIPanelPatternTypeFooter;
            else
                tp = kUIPanelPatternTypeBody;
        }
    }
    block(tp, [self.patterns objectForKey:@(tp)]);
}

@end

@implementation UITableView (panel_pattern)

NSOBJECT_DYNAMIC_PROPERTY_EXT(UITableView, panelPattern,, setPanelPattern,, {
    ((UITablePanelPattern*)val).tableView = self;
}, RETAIN_NONATOMIC);

@end

@interface UIMaskStackView ()
{
    NSMutableArray *_arrMasks, *_arrNormals;
}

@end

@implementation UIMaskStackView

@synthesize maskViews = _arrMasks, normalViews = _arrNormals;

- (void)onInit {
    [super onInit];
    _arrMasks = [[NSMutableArray alloc] init];
    _arrNormals = [[NSMutableArray alloc] init];
    
    self.maskView = [UIViewExt temporary];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    self.maskView.frame = rect;
    for (UIView* v in _arrMasks) {
        v.frame = rect;
    }
    for (UIView* v in _arrNormals) {
        v.frame = rect;
    }
}

- (void)setMaskViews:(NSArray *)maskViews {
    [_arrMasks setArray:maskViews];
}

- (void)setNormalViews:(NSArray *)normalViews {
    [_arrNormals setArray:normalViews];
    for (UIView* v in _arrNormals) {
        [self addSubview:v];
    }
}

- (void)addMask:(UIView *)view {
    [_arrMasks addObject:view];
    [self.maskView addSubview:view];
}

- (void)addNormal:(UIView *)view {
    [_arrNormals addObject:view];
    [self addSubview:view];
}

@end

@interface UIDragManager ()
{
    NSMutableArray *_views;
}

@end

@implementation UIDragManager

SHARED_IMPL;

- (void)onInit {
    [super onInit];
    _views = [[NSMutableArray alloc] init];
}

- (void)onFin {
    ZERO_RELEASE(_views);
    [super onFin];
}

- (void)add:(UIView *)view {
    [_views addObject:view];
    [view.signals connect:kSignalTouchesMoved withSelector:@selector(__cb_touchmoved:) ofTarget:self];
}

- (void)remove:(UIView *)view {
    [view.signals disconnectToTarget:self];
    [_views removeObject:view];
}

- (void)__cb_touchmoved:(SSlot*)s {
    UIView* view = (id)s.sender;
    CGPoint dt = view.extension.deltaTouched;
    [view offsetPosition:dt];
}

@end

@implementation UITransition

- (void)onInit {
    [super onInit];
    _duration = kCAAnimationDuration;
}

- (void)onFin {
    ZERO_RELEASE(_view);
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalDone)
SIGNALS_END

@end

NSString* const kUITransitionSlide = @"type::slide";
NSString* const kUITransitionCrossDissolve = @"type::crossdissolve";
NSString* const kUITransitionFlip = @"type::flip";
NSString* const kUITransitionCurl = @"type::curl";
NSString* const kUITransitionRipple = @"type::ripple";
NSString* const kUITransitionSuck = @"type::suck";
NSString* const kUITransitionCube = @"type::cube";
NSString* const kUITransitionCameraIris = @"type::camerairis";

NSString* const kUITransitionFromLeft = @"subtype::left";
NSString* const kUITransitionFromRight = @"subtype::right";
NSString* const kUITransitionFromTop = @"subtype::top";
NSString* const kUITransitionFromBottom = @"subtype::bottom";
NSString* const kUITransitionFront = @"subtype::front";
NSString* const kUITransitionRear = @"subtype::rear";
NSString* const kUITransitionOpen = @"subtype::open";
NSString* const kUITransitionClose = @"subtype::close";
NSString* const kUITransitionPush = @"type::push";
NSString* const kUITransitionMovein = @"type::movein";
NSString* const kUITransitionReveal = @"type::reveal";

@implementation UIView (transition)

- (void)addTransition:(UITransition*)trans {
    if (trans.type == kUITransitionFlip)
    {
        int flag = UIViewAnimationOptionTransitionFlipFromLeft;
        if (trans.direction == kUITransitionFromLeft) flag = UIViewAnimationOptionTransitionFlipFromLeft;
        else if (trans.direction == kUITransitionFromRight) flag = UIViewAnimationOptionTransitionFlipFromRight;
        else if (trans.direction == kUITransitionFromTop) flag = UIViewAnimationOptionTransitionFlipFromTop;
        else if (trans.direction == kUITransitionFromBottom) flag = UIViewAnimationOptionTransitionFlipFromBottom;
        flag |= UIViewAnimationOptionShowHideTransitionViews;
        [UIView transitionFromView:self toView:trans.view duration:trans.duration
                           options:flag
                        completion:^(BOOL finished) {
                            [trans.touchSignals emit:kSignalDone];
                        }];
    }
    else if (trans.type == kUITransitionSlide)
    {
        CATransitionExt* ct = [CATransitionExt temporary];
        ct.duration = trans.duration;
        ct.type = BLOCK_RETURN({
            if (trans.mode == kUITransitionMovein)
                return kCATransitionMoveIn;
            if (trans.mode == kUITransitionReveal)
                return kCATransitionReveal;
            return kCATransitionPush;
        });
        ct.subtype = BLOCK_RETURN({
            if (trans.direction == kUITransitionFromLeft) return kCATransitionFromLeft;
            if (trans.direction == kUITransitionFromRight) return kCATransitionFromRight;
            if (trans.direction == kUITransitionFromTop) return kCATransitionFromTop;
            if (trans.direction == kUITransitionFromBottom) return kCATransitionFromBottom;
            return kCATransitionFromLeft;
        });
        [self.layer addAnimation:ct completion:^{
            [trans.touchSignals emit:kSignalDone];
        }];
        self.hidden = YES;
    }
    else if (trans.type == kUITransitionCurl)
    {
        int flag = UIViewAnimationOptionTransitionCurlUp;
        if (trans.direction == kUITransitionFront) flag = UIViewAnimationOptionTransitionCurlUp;
        else if (trans.direction == kUITransitionRear) flag = UIViewAnimationOptionTransitionCurlDown;
        [UIView transitionFromView:self toView:trans.view duration:trans.duration
                           options:flag
                        completion:^(BOOL finished) {
                            [trans.touchSignals emit:kSignalDone];
                        }];
    }
    else if (trans.type == kUITransitionCrossDissolve)
    {
        [UIView transitionFromView:self toView:trans.view duration:trans.duration
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        completion:^(BOOL finished) {
                            [trans.touchSignals emit:kSignalDone];
                        }];
        self.hidden = YES;
    }
    else if (trans.type == kUITransitionReveal)
    {
        CATransitionExt* ct = [CATransitionExt temporary];
        ct.duration = trans.duration;
        ct.type = kCATransitionReveal;
        ct.subtype = BLOCK_RETURN({
            if (trans.direction == kUITransitionFromLeft) return kCATransitionFromLeft;
            if (trans.direction == kUITransitionFromRight) return kCATransitionFromRight;
            if (trans.direction == kUITransitionFromTop) return kCATransitionFromTop;
            if (trans.direction == kUITransitionFromBottom) return kCATransitionFromBottom;
            return kCATransitionFromLeft;
        });
        [trans.view.layer addAnimation:ct completion:^{
            [trans.touchSignals emit:kSignalDone];
        }];
        self.hidden = YES;
    }
    else if (trans.type == kUITransitionRipple)
    {
        CATransitionExt* ct = [CATransitionExt temporary];
        ct.duration = trans.duration;
        ct.type = kCATransitionRipple;
        [self.layer addAnimation:ct completion:^{
            [trans.touchSignals emit:kSignalDone];
        }];
        self.hidden = trans.view != nil;
    }
    else if (trans.type == kUITransitionSuck)
    {
        CATransitionExt* ct = [CATransitionExt temporary];
        ct.duration = trans.duration;
        ct.type = kCATransitionSuck;
        [self.layer addAnimation:ct completion:^{
            [trans.touchSignals emit:kSignalDone];
        }];
        self.hidden = trans.view != nil;
    }
    else if (trans.type == kUITransitionCube)
    {
        CATransitionExt* ct = [CATransitionExt temporary];
        ct.duration = trans.duration;
        ct.type = kCATransitionCube;
        ct.subtype = BLOCK_RETURN({
            if (trans.direction == kUITransitionFromLeft) return kCATransitionFromLeft;
            if (trans.direction == kUITransitionFromRight) return kCATransitionFromRight;
            if (trans.direction == kUITransitionFromTop) return kCATransitionFromTop;
            if (trans.direction == kUITransitionFromBottom) return kCATransitionFromBottom;
            return kCATransitionFromBottom;
        });
        UIView* workv = BLOCK_RETURN({
            if (trans.view)
                return [UIView CommonAncestorView:self of:trans.view];
            return self;
        });
        trans.view.hidden = YES;
        [workv.layer addAnimation:ct completion:^{
            [trans.touchSignals emit:kSignalDone];
        }];
        trans.view.hidden = NO;
        self.hidden = trans.view != nil;
    }
    else if (trans.type == kUITransitionCameraIris)
    {        
        CATransitionExt* ct = [CATransitionExt temporary];
        ct.duration = trans.duration;
        ct.type = kCATransitionCameraIrisHoollowOpen;
        if (trans.mode == kUITransitionClose)
            ct.type = kCATransitionCameraIrisHoollowClose;
        [self.layer addAnimation:ct completion:^{
            [trans.touchSignals emit:kSignalDone];
        }];
        self.hidden = trans.view != nil;
    }
    else
    {
        WARN("没有处理这种过渡效果 %s", trans.type.UTF8String);
    }
}

@end

@interface UIMarqueeWrapper ()
{
    CGSize _bsz;
}

@property (nonatomic, assign) BOOL animation;

@end

@implementation UIMarqueeWrapper

- (void)onInit {
    [super onInit];
    self.speed = 36;
}

- (void)setContentView:(UIView *)contentView {
    [self.signals disconnectToTarget:contentView];
    
    [super setContentView:contentView];
    
    // 如果含有 valuechanged 的信号，会当值改变时刷新跑马灯
    if ([contentView.signals hasSignal:kSignalValueChanged])
        [contentView.signals connect:kSignalValueChanged withSelector:@selector(updateData) ofTarget:self];
    [self updateData];
}

- (void)updateData {
    [super updateData];
    _bsz = self.contentView.bestSize;
    [self setNeedsLayout];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    BOOL animate;
    if (rect.size.width < _bsz.width) {
        rect.size.width = _bsz.width;
        animate = YES;
    } else {
        animate = NO;
    }
    
    self.contentView.frame = rect;
    self.animation = animate;
}

- (void)setAnimation:(BOOL)animation {
    if (_animation == animation)
        return;
    _animation = animation;
    if (_animation)
        [self startAnimating];
    else
        [self stopAnimating];
}

- (void)startAnimating {
    CGSize sz = self.rectForLayout.size;
    
    // 停顿2s，向左移动，到底，停顿2s，向右移动，到头，重复
    CAKeyframeAnimationExt* ani = [CAKeyframeAnimationExt animation];
    ani.resetOnCompletion = YES;
    ani.keyPath = @"transform.translation.x";
    
    [ani waitTime:2];
    [ani addValue:@(sz.width - _bsz.width) flex:1];
    [ani waitTime:2];
    [ani addValue:@(0) flex:1];
    
    ani.duration = _bsz.width / _speed + 4;
    ani.repeatCount = INFINITY;
    
    ani.namekey = @"::ui::marquee::animation";
    [self.contentView.layer addAnimation:ani];
}

- (void)stopAnimating {
    CAAnimation* ani = [self.contentView.layer animationForKey:@"::ui::marquee::animation"];
    if (ani) {
        [self.contentView.layer stopAnimation:ani];
    }
}

@end
