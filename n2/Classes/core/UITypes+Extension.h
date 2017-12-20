
# ifndef __UITYPESEXTENSION_BA8850EA964946D086689020718CA8DC_H_INCLUDED
# define __UITYPESEXTENSION_BA8850EA964946D086689020718CA8DC_H_INCLUDED

# import <UIKit/UIKit.h>
# import <QuartzCore/QuartzCore.h>
# import "NntLayout.h"
# import "UILayout.h"
# import "SSObject.h"
# import "CGTypes+Extension.h"
# import "CATypes+Extension.h"
# import "SMPageControl.h"

extern BOOL kUIScreenIsRetina;
extern CGSize kUIApplicationSize;
extern CGRect kUIApplicationBounds;
extern CGRect kUIScreenBounds;
extern float kUIScreenScale;
extern int kIOSMajorVersion;

extern BOOL kIOS10Above;
extern BOOL kIOS9Above;
extern BOOL kIOS8Above;
extern BOOL kIOS7Above;

// 自动的 dp 调整
extern float kUIDpFactor;
# define $dp *kUIDpFactor

extern float kUINavigationBarHeight;
extern float kUINavigationBarItemHeight;
extern float kUINavigationBarItemWidth;
extern float kUINavigationBarDodgeHeight;
extern float kUIStatusBarHeight;
extern float kUIToolBarHeight;
extern float kUITabBarHeight;
extern float kUISearchBarHeight;

// 默认的高亮图片后缀名，业务层可以通过修改这个变量来自定义图片后缀，会被当 setPush 之类的函数使用
extern NSString* kUIImageHighlightSuffix;

// 对应屏幕的种类，会影响默认选择的图片
typedef enum {
    kUIScreenSizeA, // 类3.5寸
    kUIScreenSizeB, // 类4寸屏幕
    kUIScreenSizeC, // 类4.7寸屏幕
    kUIScreenSizeD, // 类5.5寸屏幕
} UIScreenSizeType;

// 屏幕的类型
extern UIScreenSizeType kUIScreenSizeType;

// 标准大小
extern float kUINavigationBarHeight;
extern float kUINavigationBarItemHeight;
extern float kUINavigationBarDodgeHeight;
extern float kUIStatusBarHeight;
extern float kUITabBarHeight;
extern float kUISearchBarHeight;

@interface UIColor (extension)

+ (UIColor*)colorWithRGB:(int)rgb;
+ (UIColor*)colorWithRGBA:(int)rgba;
+ (UIColor*)colorWithARGB:(int)argb;
+ (UIColor*)grayWithValue:(CGFloat)val;
+ (UIColor*)blackWithAlpha:(CGFloat)val;
+ (UIColor*)whiteWithAlpha:(CGFloat)val;
+ (UIColor*)colorWithRedi:(Byte)red green:(Byte)green blue:(Byte)blue alpha:(Byte)alpha;
+ (UIColor*)colorWithRedi:(Byte)red green:(Byte)green blue:(Byte)blue alphaf:(CGFloat)alpha;
+ (UIColor*)colorWithRedi:(Byte)red green:(Byte)green blue:(Byte)blue;
+ (UIColor*)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
+ (UIColor*)colorWithWhitei:(Byte)white alpha:(CGFloat)alpha;
+ (UIColor*)colorWithWhitei:(Byte)white;

- (UIColor*)multiplyWithRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b;
- (UIColor*)multiplyWithRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b alpha:(CGFloat)a;
- (UIColor*)multiplyWithValue:(CGFloat)val;
- (UIColor*)addWithRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b;
- (UIColor*)addWithRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b alpha:(CGFloat)a;
- (UIColor*)addWithValue:(CGFloat)val;
- (UIColor*)bleachWithValue:(CGFloat)val;

- (CGFloat)componentRed;
- (CGFloat)componentGreen;
- (CGFloat)componentBlue;
- (CGFloat)componentAlpha;

- (UIColor*)blurColor;
- (UIColor*)nonblurColor;

// 自动生成一个颜色
+ (UIColor*)randomColor;

// 是否是彩色毛玻璃支持的颜色
- (BOOL)isColorizedGlossy;

// RGB颜色
- (NSUInteger)rgb;
- (NSUInteger)rgba;
- (NSUInteger)argb;

// 获取到用RGB描述的颜色
- (UIColor*)rgbColor;
@property (nonatomic, readonly) BOOL isRGBColor;

@end

static const CGPoint kCGAnchorPointCC = { 0.5f, 0.5f };
static const CGPoint kCGAnchorPointRT = { 1.f, 0.f };
static const CGPoint kCGAnchorPointRB = { 1.f, 1.f };
static const CGPoint kCGAnchorPointLT = { 0.f, 0.f };
static const CGPoint kCGAnchorPointLB = { 1.f, 1.f };
static const CGPoint kCGAnchorPointTC = { .5f, 0.f };
static const CGPoint kCGAnchorPointBC = { .5f, 1.f };
static const CGPoint kCGAnchorPointLC = { 0.f, .5f };
static const CGPoint kCGAnchorPointRC = { 1.f, .5f };

extern UIEdgeInsets UIEdgeInsetsFromPadding(CGPadding);
extern CGPadding CGPaddingFromEdgeInsets(UIEdgeInsets);
extern CGFloat UIEdgeInsetsWidth(UIEdgeInsets);
extern CGFloat UIEdgeInsetsHeight(UIEdgeInsets);

typedef enum {
    kCellPosTop,
    kCellPosMiddle,
    kCellPosBottom,
} CellPos;

@interface NSPadding (UI)

+ (instancetype)paddingWithEdgeInsets:(UIEdgeInsets)ei;
- (UIEdgeInsets)edgeInsets;

@end

@interface UITextStyle : NSObject

@property (nonatomic, retain) UIColor *textColor, *backgroundColor;
@property (nonatomic, retain) UIFont *textFont;

+ (instancetype)styleWithColor:(UIColor*)color font:(UIFont*)font;
- (id)initWithColor:(UIColor*)color font:(UIFont*)font;

+ (instancetype)styleWithColor:(UIColor*)color backgroundColor:(UIColor*)bkgColor;
- (id)initWithColor:(UIColor*)color backgroundColor:(UIColor*)bkgColor;

- (void)setIn:(UIView*)view;

@end

@interface UIFill : NSObject

@property (nonatomic, retain) UIImage *image, *patternImage;
@property (nonatomic, retain) UIColor *color;

@end

@interface UIString : UITextStyle

// 对应状态的文字，将调用 stringValue 来取得 string 对象
@property (nonatomic, retain) id text;

// 对应状态的图片和背景图片
@property (nonatomic, retain) UIImage *image, *backgroundImage;
@property (nonatomic, retain) NSString *imagePushed;

// 富文本
@property (nonatomic, retain) NSStylizedString *stylizedString;

// 用于显示的类型
@property (nonatomic, assign) Class viewForString;

// 自动从各种支持的类型转换
+ (instancetype)Any:(id)any;

+ (instancetype)stringWithColor:(UIColor *)color;
- (id)initWithColor:(UIColor *)color;

+ (instancetype)stringWithFont:(UIFont *)font;
- (id)initWithFont:(UIFont *)font;

+ (instancetype)stringWithColor:(UIColor *)color font:(UIFont *)font text:(NSString*)text;
- (id)initWithColor:(UIColor *)color font:(UIFont *)font text:(NSString*)text;

+ (instancetype)stringWithColor:(UIColor *)color text:(NSString*)text;
- (id)initWithColor:(UIColor *)color text:(NSString*)text;

+ (instancetype)stringWithFont:(UIFont *)font text:(NSString*)text;
- (id)initWithFont:(UIFont *)font text:(NSString*)text;

+ (instancetype)string:(NSString*)string;
- (id)initWithString:(NSString*)string;

+ (instancetype)stylizedString:(NSStylizedString*)string;
- (id)initWithStylizedString:(NSStylizedString*)string;

+ (instancetype)image:(UIImage*)image;
- (id)initWithImage:(UIImage*)image;

+ (instancetype)backgroundImage:(UIImage*)image;
- (id)initWithBackgroundImage:(UIImage*)image;

+ (instancetype)imagePushed:(NSString*)image;
- (id)initWithImagePushed:(NSString*)image;

+ (instancetype)imageDataSource:(id)ds;
- (id)initWithImageDataSource:(id)ds;

+ (instancetype)backgroundImageDataSource:(id)ds;
- (id)initWithBackgroundImageDataSource:(id)ds;

@end

@interface UIResponder (extension)

@property (nonatomic, assign) BOOL focus;

- (void)lostFocus;
- (void)setFocus;

@end

SIGNAL_DECL(kSignalFocused) @"::ui::responder::focused";
SIGNAL_DECL(kSignalFocusedLost) @"::ui::responder::focuse::lost";

extern BOOL kUITouched;
extern BOOL kUIDragging;

SIGNAL_DECL(kSignalMotionBegan) @"::ui::responder::motion::began";
SIGNAL_DECL(kSignalMotionEnded) @"::ui::responder::motion::ended";
SIGNAL_DECL(kSignalMotionCancelled) @"::ui::responder::motion::cancelled";

SIGNAL_DECL(kSignalDeviceShaking) @"::device::shaking";
SIGNAL_DECL(kSignalDeviceShaked) @"::device::shaked";

/** 扩展 view 以承载其他辅助数据 */
@interface UIViewExtension : NSObject

/** 触摸的状态 */
@property (nonatomic, assign) int isTouching;

/** 优先的 touchposition ，因为有些事件不是有 touches 引起的，所以需要直接保存位置 */
@property (nonatomic, retain) NSPoint *preferredPositionTouched;

/** 返回由 touch 引起的位置变更 */
@property (nonatomic, readonly) CGPoint positionTouched, deltaTouched, previousPositionTouched;

/** 位置变更的速度 */
@property (nonatomic, readonly) CGPoint velocityTouched;

/** 引起的内容位置改变 */
@property (nonatomic, assign) CGPoint positionScrolled, previousPositionScrolled;

/** touch 的间隔时间 */
@property (nonatomic, assign) NSTimeInterval durationTouched;

/** 计算相对于该 view 的 touche 位置 */
- (CGPoint)positionTouchedIn:(UIView*)view;

/** hittest 的扩展 */
@property (nonatomic, assign) CGPoint hitTestOffset;

@end

@class CGGraphic;

@protocol UIViewDraw <NSObject>

- (void)onDraw:(CGRect)rect;

@optional

- (void)onPaint:(CGGraphic*)graphic;

@end

typedef enum
{
    UIViewAutolayout = 0,
    UIViewAutolayoutNone = 1 << 1,
    
} UIViewAutolayoutMask;

@interface UIKit : NSObject
@end

@protocol UISelection <NSObject>

@property (nonatomic, assign) BOOL isSelection;

@optional

// 当前已经选中，但是又一次的激活
- (void)selectionReactive;

@end

/** 按钮组，接管选中状态 */
@interface UISelectionGroup : NSObjectExt

/** 当前选中的 */
@property (nonatomic, assign) UIView<UISelection>* currentSelection;
@property (nonatomic, assign) NSInteger selectionIndex;

/** 所有位于栈内的元素 */
@property (nonatomic, readonly) NSArray* views;

/** 添加元素 */
- (void)addObject:(UIView<UISelection>*)obj;
- (void)addObjects:(UIView<UISelection>*)obj, ...;

/** 移除元素 */
- (void)removeObject:(UIView*)obj;

/** 清空 */
- (void)removeAllObjects;

@end

@class UIMenuControllerExt;

@interface UIView (extension)
<UIViewDraw>

/** 显示 */
@property (nonatomic, assign) BOOL visible;
- (void)setVisible;
- (void)setInvisible;

/** 移动到最上面 */
- (void)bringUp;

/** 移动到最下面 */
- (void)sendBack;

/** 激活一可以激活的子元素 */
- (BOOL)anyFocus;

/** 主色调，区分于背景颜色，这个用来在做滑动动画时需要进行背景颜色的按照比例显示 */
@property (nonatomic, retain) UIColor *motifColor;

/** 子vc的数组 */
@property (nonatomic, readonly) NSSet* subcontrollers;

/** 所用的navigation，会自动回溯查找 */
@property (nonatomic, assign) UINavigationController* navigationController;

/** 所附属的vc，只有 vc->loadview 的行为才会使 view 具备这个属性，其他作为子view的view，该属性的值为 nil
 如果需要手动绑定，则必须注意 vc 的生命期和从属关系
 */
@property (nonatomic, assign) UIViewController *belongViewController;

/** 查找顶层的vc
@note 例如 VC -> View0 -> selfview，则 selfview.belongViewController == nil, 但是 selfview.headerViewController == VC
 */
@property (nonatomic, readonly) UIViewController *headViewController;

/** 扩展属性设置 */
@property (nonatomic, readonly) UIViewExtension* extension;

/** 是否进行自动布局 */
@property (nonatomic, assign) UIViewAutolayoutMask autolayoutMask;

/** 使用中心点移动frame */
@property (nonatomic, assign) CGRect centerFrame;

/** 添加一个子成员，会将 vc的 view 添加到自己的 view 中 */
- (void)addSubcontroller:(UIViewController*)ctlr;

/** 关联一个子 vc，不会操作 view */
- (void)assignSubcontroller:(UIViewController*)ctlr;

/** 移除一个子 vc，附带移除 view */
- (void)removeSubcontroller:(UIViewController*)ctlr;

/** 添加一组 view */
- (void)addSubviews:(NSSet*)subviews;

/** 根据 id 的类型来自动调用 addSubview 或者 addSubcontroller */
- (void)addSub:(id)obj;

/** 根据 id 的类型自动 removeFromsupver 或者 removeSubcontroller */
- (void)removeSub:(id)obj;

/** 强制添加，如果已经添加到其他 view，则先 remove 然后再添加 */
- (void)forceAddSub:(id)obj;
- (void)forceAddSubview:(UIView*)v;

/** 有效的内容视图，一般的 view 即返回self */
- (UIView*)behalfView;

/** 祖宗视图 */
- (UIView*)ancestorView;
- (NSArray*)ancestorViews;

/** 查找匹配该类型的父 view */
- (UIView*)findSuperviewAsType:(Class)cls;

/** 计算共同的祖先 */
+ (UIView*)CommonAncestorView:(UIView*)l of:(UIView*)r;

/** 迭代查找符合条件的 */
- (UIView*)querySubview:(IteratorType(^)(UIView* v))query;

/** 直接初始化 */
- (id)initWithZero;
+ (instancetype)viewWithFrame:(CGRect)frame;

/** 常用的移动 */
@property (nonatomic, assign) CGPoint leftTop, leftBottom, rightTop, rightBottom, leftCenter, rightCenter, topCenter, bottomCenter, position;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat width, height, positionX, positionY;

/** 使用锚点作为基点来移动 */
- (void)setHeight:(CGFloat)val anchorPoint:(CGPoint)anchor;
- (void)setWidth:(CGFloat)val anchorPoint:(CGPoint)anchor;

/** 直接设置底部的位置 */
- (void)setBottomY:(CGFloat)val;

/** 偏移 */
- (void)offsetPosition:(CGPoint)val;

/** 当布局的时候，会回调这个接口，标准的写法是在这个回调中使用layout类来设置子元素的位置 */
- (void)onLayout:(CGRect)rect;

/** 有些UI类会需要调整当前view在父view中的布局，传入的是父view的bounds，需要调整自己的位置 */
- (void)onPosition:(CGRect)rect;

/** 获得最好的大小 */
- (CGRect)bestFrame;
- (CGSize)bestSize;
- (CGFloat)bestHeight;
- (CGFloat)bestWidth;
- (CGFloat)bestHeight:(CGSize)sz;
- (CGFloat)bestWidth:(CGSize)sz;
- (CGFloat)bestHeightForWidth:(CGFloat)val;
- (CGFloat)bestWidthForHeight:(CGFloat)val;
- (CGFloat)bestHeightForWidth;
- (CGFloat)bestWidthForHeight;

/** 子类中通常实现的是这个函数 */
- (CGSize)bestSize:(CGSize)sz;

/** 静态的最佳大小 */
+ (CGSize)BestSize;
+ (CGFloat)BestHeight;
+ (CGFloat)BestWidth;

/** 子类中通常实现的是这个函数 */
+ (CGSize)BestSize:(CGSize)sz;

/** 获得有效的内容大小，默认是和 BestSize 一致，部分情况下使用 */
- (CGRect)bestBehalfRegion:(CGSize)sz;

/** 获取到子view所占用的区域 */
- (CGRect)rectOfSubviews;

/** 高亮背景 */
@property (nonatomic, retain) UIColor *highlightColor;
@property (nonatomic, retain) UIImage *backgroundImage, *highlightImage;
@property (nonatomic, retain) UIFill *backgroundFill, *highlightFill;

/** 业务层应避免通过 layer 来设置圆角，此参数会用来修正高亮时没有圆角的问题 */
@property (nonatomic, assign) CGFloat cornerRadius;

/** 设置为正圆角(整个 view 看起来是个正圆) */
- (void)cornerRoundlize;

/** 通过名字设置点按的图片 */
- (void)setPushImageNamed:(NSString*)img;

/** 背景的区域 */
- (CGRect)frameForBackground;

/** 是否可以使用 highlightview */
- (BOOL)isHighlightEnable;

/** 用来避让键盘的大小 */
- (CGRect)frameForKeybaord;

/** 键盘需要避让和自身有关的哪个 view，默认就是自己 */
@property (nonatomic, assign) UIView* viewForKeyboard;

/** 相对于锚点设置 */
- (void)setFrame:(CGRect)frame anchorPoint:(CGPoint)anchor;
- (void)setAbsoluteFrame:(CGRect)rc anchorPoint:(CGPoint)anchor;

/** 忽略transform设置frame */
- (void)setAbsoluteFrame:(CGRect)rc;
- (void)setAbsoluteCenter:(CGPoint)pt;
- (void)setAbsolutePosition:(CGPoint)pt;

/** 位于screen上的位置 */
- (CGRect)screenFrame;

/** 相对于view的位置 */
- (CGRect)frameForView:(UIView*)view;

/** 布局使用的rect */
@property (nonatomic, readonly) CGRect rectForLayout;

/** 强制刷新一下布局 */
- (void)flushLayout;

/** layout的次数统计，用以做之后的显示动画用 */
@property (nonatomic, assign) int countLayout;

/** 长按时候弹出的 menu */
@property (nonatomic, retain) UIMenuControllerExt* menu;

/** 生成 image */
- (UIImage*)renderToImage;
- (UIImage*)renderToImageWithBackgroundColor:(UIColor*)color;
- (UIImage*)renderRectToImage:(CGRect)rc;
- (UIImage*)renderRectToImage:(CGRect)rc backgroundColor:(UIColor*)color;

/** 是否规避顶部的系统空间，默认为NO
 YES：规避电池栏； 如果是普通的view，则根据navigationbar的显示与否规避导航栏；
 */
@property (nonatomic, assign) BOOL dodgeTopRegion;

/** v 是否是自己的 parent */
- (BOOL)hasSuperView:(UIView*)v;

/** 用来遮盖的 VIEW/VC（常用于placeholder的功能） */
@property (nonatomic, retain) id overlapWidget;

/** 占位用的 view 的大小 */
- (CGRect)rectForOverlap;

/** 回调：添加到其他VIEW */
- (void)onAddingToSuperview:(UIView*)sv;
- (void)onAddedToSuperview;
- (void)onRemovingFromSuperview;
- (void)onRemovedFromSuperview;
- (void)onAddingToWindow:(UIWindow*)w;
- (void)onAddedToWindow;
- (void)onRemovingFromWindow;
- (void)onRemovedFromWindow;

/** 动画的辅助 */
+ (void)animateWithDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)option animations:(void(^)())animations;
+ (void)animateWithDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options animations:(void(^)())animations completion:(void(^)(BOOL finished))completion;

/** 不具名的子view对象 */
- (UIView*)subview:(NSString*)key instance:(UIView*(^)())instance;
- (UIView*)subview:(NSString*)key type:(Class)type;
- (UIView*)subview:(NSString*)key;
- (UIView*)subviewAtKeyPath:(NSString*)keypath;
- (NSArray*)subviews:(UIView*(^)())instance keys:(NSString*)key, ...;

/** 取消触摸 */
- (void)cancelTouchs;

@end

// 开始移动
SIGNAL_DECL(kSignalTouchesBegan) @"::ui::view::touches::began";

// 停止移动
SIGNAL_DECL(kSignalTouchesEnded) @"::ui::view::touches::ended";

// 取消移动
SIGNAL_DECL(kSignalTouchesCancel) @"::ui::view::touches::cancel";

// 正在移动
SIGNAL_DECL(kSignalTouchesMoved) @"::ui::view::touches::moved";

// 停止或者取消移动
SIGNAL_DECL(kSignalTouchesDone) @"::ui::view::touches::done";

// 绘制区域
SIGNAL_DECL(kSignalDrawRect) @"::ui::view::draw_rect";

// 需要重绘
SIGNAL_DECL(kSignalRequestRedraw) @"::ui::draw::request";

// 需要重新布局
SIGNAL_DECL(kSignalRequestRelayout) @"::ui::layout::request";

// 从属关系变化
SIGNAL_DECL(kSignalAddingToSuperview) @"::ui::superview::addingto";
SIGNAL_DECL(kSignalAddedToSuperview) @"::ui::superview::addedto";
SIGNAL_DECL(kSignalRemovingFromSuperview) @"::ui::superview::removing";
SIGNAL_DECL(kSignalRemovedFromSuperview) @"::ui::superview::removed";

@protocol UIViewEdge <NSObject>

@property (nonatomic, assign) CGPadding paddingEdge;
@property (nonatomic, assign) CGPoint offsetEdge;

@end

extern BOOL kUIViewExtAnimationPeriod;
extern NSTimeInterval kUIViewExtAnimationDuration;

@interface UIViewExt : UIView <UIViewEdge>

# ifndef IOS8_FEATURES
@property (nonatomic, retain) UIView* maskView;
# endif

// 为了避免用错高版本的 API，并且为了给自定义动画提供 duration 的参数，所以业务层必须调用 ext 的动画函数
+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations;
+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;
+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;

@end

SIGNAL_DECL(kSignalFrameChanging) @"::ui::view::frame::changing";
SIGNAL_DECL(kSignalFrameChanged) @"::ui::view::frame::changed";
SIGNAL_DECL(kSignalBoundsChanged) @"::ui::view::bounds::changed";
SIGNAL_DECL(kSignalLayoutBegin) @"::ui::view::layout::begin";
SIGNAL_DECL(kSignalLayouting) @"::ui::view::layouting";
SIGNAL_DECL(kSignalLayoutEnd) @"::ui::view::layout::end";
SIGNAL_DECL(kSignalLayout) @"::ui::view::layout::end";

@interface UIControl (extension)

@property (nonatomic, assign) BOOL disabled;

@end

@interface UIControlExt : UIControl

@end

// 单击
SIGNAL_DECL(kSignalClicked) @"::ui::clicked";

// 双击
SIGNAL_DECL(kSignalDbClicked) @"::ui::clicked::db";

// 长按
SIGNAL_DECL(kSignalLongClicked) @"::ui::clicked::long";

// 触摸
SIGNAL_DECL(kSignalTouchesDown) @"::ui::touch::down";
SIGNAL_DECL(kSignalTouchesUp) @"::ui::touch::up";
SIGNAL_DECL(kSignalTouchesUpInside) @"::ui::touch::up::inside";
SIGNAL_DECL(kSignalTouchesUpOutside) @"::ui::touch::up::outside";

@class UILabelExt;

/** 信息反馈 */
@interface UIHud : UIViewExt

/** 当前正在执行的 */
+ (instancetype)Current;

typedef enum {
    kUIHudProgress = 1, // 一直在转圈
    kUIHudText, // 文字
    kUIHudSymbol, // 显示一个大的元素
    kUIHudDefault = kUIHudProgress
} UIHudType;

/** 类型 */
@property (nonatomic, assign) UIHudType type;

/** 在某一个 view 中显示 */
- (void)showIn:(UIView*)view animated:(BOOL)animated;

/** 隐藏 */
- (void)hideWithAnimated:(BOOL)animated;

/** 显示进度用的 UI */
@property (nonatomic, readonly) UIView<NSPercentage> *progressView;

/** 标题以及内容 */
@property (nonatomic, readonly) UILabelExt *titleLabel, *detailLabel;

/** 承载内容显示的 view */
@property (nonatomic, readonly) UIView *panelView;

/** 快速显示文字 */
+ (void)Text:(NSString*)text inView:(UIView*)view;
+ (void)Text:(NSString*)text title:(NSString*)title inView:(UIView*)view;
+ (void)Text:(NSString*)text;
+ (void)Text:(NSString*)text title:(NSString*)title;
+ (void)Symbol:(NSString*)symbol text:(NSString*)text inView:(UIView*)view;

/** 成功、失败、信息 */
+ (void)Success:(NSString*)text;
+ (void)Failed:(NSString*)text;
+ (void)Noti:(NSString*)text;

/** 显示循环动态提示 */
+ (void)ShowProgress;

/** 隐藏循环动态提示 */
+ (void)HideProgress;

/** 增加一个动作显示 */
- (NSObject*)addAction:(NSString*)name;

@end

void UIHudShowText(NSString*);

@interface UIFont (extension)

/** 计算当前字体下描述的空行的高度 */
@property (nonatomic, readonly) CGFloat emptyLineHeight;

/** 默认为0的字体 */
+ (UIFont*)clearFont;

/** 随机大小的字体 */
+ (UIFont*)RandomFont;

@end

@interface UILabel (extension)

/** 文字字体 */
@property (nonatomic, retain) UIFont* textFont;

/** 是否是多行显示 */
@property (nonatomic, assign) BOOL multilines;

/** 为了兼容 ios5 以及解决 ios6 以上版本 attributedString 不支持图片显示的问题，增加样式字符串的功能 */
@property (nonatomic, retain) NSStylizedString *stylizedString;

/** 实际有多少行 */
@property (nonatomic, readonly) NSUInteger numberOfLinesForFullText;
- (NSUInteger)numberOfLinesForFullText:(CGSize)sz;
- (NSUInteger)numberOfLinesForFullTextForWidth:(CGFloat)width;
- (NSUInteger)numberOfLinesForFullTextForWidth;

/** 是否截断 */
@property (nonatomic, assign) BOOL truncation;

/** 使用中间打点的方式截断长字符串 */
@property (nonatomic, assign) BOOL ellipsisCenter;

/** 截断到指定行的末尾 */
@property (nonatomic, assign) NSInteger truncationAtTails;

/** 取得到的item 
 @note 此函数通常用于当点击时，判断点击到哪一段文字上，可以通过在 stylizedString 中反查 item 的下标来比对
 */
- (id<NSStylizedItem>)stylizedItemAtPoint:(CGPoint)pt;

/** 文字相对于父 view 的位置 */
- (CGRect)frameForContent;

/** 文字相对于当前 label 内的位置 */
- (CGRect)boundsForContent;

@end

/** 对 label 的扩展 */
@interface UILabelExt : UILabel

/** 关键字的颜色 */
@property (nonatomic, retain) UIColor* keywordColor;

/** 关键字的字体 */
@property (nonatomic, retain) UIFont* keywordFont;

/** 高亮的关键字 */
@property (nonatomic, copy) NSString *keyword;

/** 内容的边距 */
@property (nonatomic, assign) CGPadding contentPadding;

/** 各种状态的文字和属性，支持带状态的文字显示，以避免手动设来设去 
 @param states 为 state 和 UIString 的映射表
 */
@property (nonatomic, retain) NSDictionary *states;

/** 当前的状态 */
@property (nonatomic, retain) id currentState;

/** 更新当前的状态 */
- (void)updateState;

/** 垂直对齐，默认为垂直居中 NSTextAlignment*/
@property (nonatomic, assign) NSInteger textVerticalAlignment;

@end

/** 使用 label 来模拟一个 button */
@interface UILabelButton : UILabelExt

@end

@interface UIButton (extension)
<UISelection>

/** 自动文字，根据当前的状态决定设置谁的 */
@property (nonatomic, retain) NSString *anyText;

/** 显示的文字 */
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *disabledText;

/** 文字的颜色 */
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIColor *disabledTextColor;
@property (nonatomic, retain) UIColor *highlightTextColor;

/** 文字的字体 */
@property (nonatomic, retain) UIFont *textFont;

/** 显示的图片，如果是可拉伸，则会设置成 bkg，否则直接设置为 buttonImage */
@property (nonatomic, retain) UIImage *image;

/** 调整图片的边距 */
@property (nonatomic, assign) CGMargin imageMargin;

/** 选中时的文字 */
@property (nonatomic, retain) NSString *selectedText;

/** 选中时的文字颜色 */
@property (nonatomic, retain) UIColor *selectedTextColor;

/** 文字对齐 */
@property (nonatomic, assign) NSTextAlignment textAlignment;

@property (nonatomic, retain) UIImage *backgroundImage;
@property (nonatomic, retain) UIImage *disabledBackgroundImage;
@property (nonatomic, retain) UIImage *selectedImage;
@property (nonatomic, retain) UIImage *selectedBackgroundImage;

- (instancetype)initWithImage:(UIImage*)img;
- (instancetype)initWithBackgroundImage:(UIImage*)img;

/** 初始化，其中 push 会设置两张图片，一张为标准，一张为按下，按下的图片会自动依照 name + kUIImageHighlightSuffix 的后缀来匹配 */
- (instancetype)initWithPushImage:(NSString*)img;
- (instancetype)initWithPushImage:(NSString*)img stretch:(BOOL)stretch;

+ (instancetype)buttonWithImage:(UIImage*)img;
+ (instancetype)buttonWithBackgroundImage:(UIImage*)img;

/** 初始化，其中 push 会设置两张图片，一张为标准，一张为按下，按下的图片会自动依照 name + kUIImageHighlightSuffix 的后缀来匹配 */
+ (instancetype)buttonWithPushImage:(NSString*)img;

/** 自动设置 x.png 以及 x-highlight.png 两张图片 */
- (void)setPushImageNamed:(NSString*)ds;
- (void)setPushImageNamed:(NSString*)ds stretch:(BOOL)stretch;

/** 在按钮上面显示富文本 */
@property (nonatomic, retain) NSStylizedString* stylizedString;

/** 内容的边距 */
@property (nonatomic, assign) CGPadding contentPadding;

/** 内容的位置 */
@property (nonatomic, readonly) CGRect contentFrame;

/** states自定义状态
 @note 为 state 和 UIString 的映射表
 */
@property (nonatomic, retain) NSDictionary *states;

/** 当前的状态
 @note 设置后会从 states 里面取出 UIString 并设置到 button */
@property (nonatomic, retain) id currentState;

@end

/** 对于 Button 的扩展 */
@interface UIButtonExt : UIButton <UIViewEdge>

/** 可以额外设置该参数来调整点击热区 */
@property (nonatomic, assign) CGPadding hitTestPadding;

@end

@interface UIViewControllerAttributes : NSObject

/** 是否继承前一个vc设置的样式 */
@property (nonatomic, retain) NSBoolean *navigationBarInherit;

/** bar 是否透明 */
@property (nonatomic, retain) NSBoolean *navigationBarTranslucent;

/** bar 是否模糊 */
@property (nonatomic, assign) BOOL navigationBarBlur;

/** 高亮颜色 */
@property (nonatomic, retain) UIColor *navigationBarTintColor;

/** 背景颜色 */
@property (nonatomic, retain) UIColor *navigationBarColor;

/** 背景图片 */
@property (nonatomic, retain) UIImage *navigationBarImage;

/** 高度 */
@property (nonatomic, retain) NSNumber *navigationBarHeight;

/** 顶部字体的颜色 */
@property (nonatomic, retain) UITextStyle *navigationBarTitleStyle;

/** 下面的tab高度 */
@property (nonatomic, retain) NSNumber *tabBarHeight;

/** 顶部的避让默认为NO，下部的避让根据系统自动选择 */
@property (nonatomic, assign) BOOL navigationBarDodge, tabBarDodge;

/** 自动调整 statusbar 颜色, 默认为light */
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@property (nonatomic, retain) NSBoolean* statusBarHidden;

/** 设置 statusbar 的颜色，会根据兼容性自动调整 */
@property (nonatomic, retain) UIColor* statusBarColor;
@property (nonatomic, retain) UIColor* statusBarTintColor;

@end

@class UIViewControllerStack;

@interface UIViewController (extension)

// 自动隐藏 navigationbar
@property (nonatomic, assign) BOOL hidesTopBarWhenPushed;

// 是否支持滑动goBack的特性，默认为YES
@property (nonatomic, assign) BOOL panToBack;

// 是否激活AppDelegate的Container的手势，默认为YES
@property (nonatomic, assign) BOOL enableContainerGesture;

// 其他属性
@property (nonatomic, readonly) UIViewControllerAttributes* attributes;

// 父 viewcontroller
@property (nonatomic, readonly) UIViewController* superViewController;

// 父级的 stack
@property (nonatomic, readonly) UIViewControllerStack* stackController;

/** 内容的视图，VC 返回 self.view */
- (UIView*)behalfView;

// 回调
- (void)onLoaded;
- (void)onAppearing;
- (void)onAppeared;
- (void)onFirstAppeared;
- (void)onFirstAppearing;
- (void)onLaterAppeared;
- (void)onLaterAppearing;
- (void)onDisappeared;
- (void)onDisappearing;
- (void)onMemoryWarning;
- (void)onNavigationItemUpdated;
- (void)onViewLayouting;
- (void)onViewLayout;

// 是否已经显示
@property (nonatomic, readonly) BOOL isAppeared;

// 在navigationbar自定义view的情况下，被navigationbar按需调用
@property (nonatomic, retain) UIView *navigationBarView;

// 关闭模式VC
- (void)dismissModalViewController;
- (void)dismissModalViewControllerNoAnimated;

// 模式vc
- (void)presentViewController:(UIViewController *)viewControllerToPresent;
- (void)presentViewControllerNoAnimated:(UIViewController *)viewControllerToPresent;

// back回之前的状态
- (void)goBack:(BOOL)animated;
- (void)goBack;
- (void)goBackNoAnimated;

// 移除
- (void)removeFromSuperview;

// 调整避让导航栏所使用的view，默认为 self.view.view
- (UIView*)viewForDodge;

@end

SIGNAL_DECL(kSignalTitleChanged) @"::ui::vc::title::changed";
SIGNAL_DECL(kSignalTintColorChanged) @"::ui::tintcolor::changed";
SIGNAL_DECL(kSignalViewControllerDismissing) @"::ui::vc::dismissing";
SIGNAL_DECL(kSignalViewControllerDismissed) @"::ui::vc::dismissed";

@interface UIViewControllerExt : UIViewController

// vc使用的view的类，会自动在 loadView 时初始化.
@property (nonatomic, assign) Class classForView;

// 自定义的navigationController.
@property (nonatomic, retain) UINavigationController* navigationController;

// 包含的子 vc 列表.
@property (nonatomic, readonly) NSSet* subcontrollers;

// 添加子vc，会自动添加到view中
- (void)addSubcontroller:(UIViewController*)ctlr;

// 移除一个子vc
- (void)removeSubcontroller:(UIViewController*)ctlr;

// 设置为子vc，但是不会自动添加到view中
- (void)assignSubcontroller:(UIViewController*)ctlr;
- (void)unassignSubcontroller:(UIViewController*)ctlr;

@end

SIGNAL_DECL(kSignalViewLoaded) @"::ui::viewcontroller::loaded";
SIGNAL_DECL(kSignalViewAppear) @"::ui::viewcontroller::appear";
SIGNAL_DECL(kSignalViewFirstAppear) @"::ui::viewcontroller::appear::first";
SIGNAL_DECL(kSignalViewFirstAppearing) @"::ui::viewcontroller::appering::first";
SIGNAL_DECL(kSignalViewAppearing) @"::ui::viewcontroller::appearing";
SIGNAL_DECL(kSignalViewDisappear) @"::ui::viewcontroller::disappear";
SIGNAL_DECL(kSignalViewDisappearing) @"::ui::viewcontroller::disappearing";

@protocol UIScrollViewPullIdentifier <NSObject>

/** 滑动到此时代表激活 */
@property (nonatomic, assign) CGFloat toggleValue;

/** 运行的状态 */
@property (nonatomic, assign) NSWorkState workState;

/** 是否已经激活，默认为未激活 */
@property (nonatomic, assign) BOOL disabled;

/** 滚动超出了内容区域 */
- (void)pullSizeNeedChanged:(CGSize)sz;

/** 是否需要手动调整padding */
- (BOOL)shouldAdjustPullInsets;

@optional

/** 停靠的大小，不实现的话将使用 toggleValue */
- (CGFloat)dockedHeight;

@end

SIGNAL_DECL(kSignalPullIdentifierToggled) @"::ui::pullidentifier::toggled";

// 实现滚动时在额外边距中显示的识别符
@interface UIScrollViewPullIdentifier : UIViewExt <UIScrollViewPullIdentifier>
@end

// ios6水滴形式的识别符
@interface UIDripIdentifier : UIScrollViewPullIdentifier
@end

// 下拉刷新用的识别符，如果写新的最好从这个地方继承
@interface UIPullFlushView : UIScrollViewPullIdentifier
@end

// 继续拉更多的识别符，如果写新的最好从这个地方继承
@interface UIPullMoreView : UIScrollViewPullIdentifier

// 下拉中显示用的label
@property (nonatomic, retain) UILabelExt *labelText;

@end

@interface UIScrollView (extension)

/** 应用edgeInset等后计算出来的逻辑坐标 */
@property (nonatomic, readonly) CGPoint contentPosition;
@property (nonatomic, readonly) CGFloat contentX, contentY;

/** 获得 content 的实际宽高 */
@property (nonatomic, assign) CGFloat contentHeight, contentWidth;

/** 获得 content 的可用区域 */
@property (nonatomic, readonly) CGRect availableBounds;

/** 偏移 */
@property (nonatomic) CGFloat contentOffsetX, contentOffsetY;
- (void)setContentOffsetX:(CGFloat)contentOffsetX animated:(BOOL)animated;
- (void)setContentOffsetY:(CGFloat)contentOffsetY animated:(BOOL)animated;

/** 可视区域 */
@property (nonatomic, readonly) CGRect visibledBounds;

/** 附加的ei */
@property (nonatomic, assign) UIEdgeInsets edgeInsetsAddition;

/** 是否不处理navigationbar的ei调整，默认为处理 */
@property (nonatomic, assign) BOOL skipsNavigationBarInsetsAdjust;

/** 从上往下超拉时需要显示的标记 */
@property (nonatomic, retain) UIView<UIScrollViewPullIdentifier> *identifierTop;

/** 从下往上超拉时需要显示的标记 */
@property (nonatomic, retain) UIView<UIScrollViewPullIdentifier> *identifierBottom;

/** 当前的工作状态，会影响到工作标记的显示 */
@property (nonatomic, assign) NSWorkState workState;

/** 工作状态的标记 */
@property (nonatomic, retain) UIView *workingIdentifier;

/** 为空的时候的占位 */
@property (nonatomic, retain) UIView *placeholderView;

/** 直接把view增加到scroll上，否则有可能会被加到 contentview 上 */
- (void)directAddSubview:(UIView*)view;

/** 判断是否为滚动条 */
+ (BOOL)IsScrollIndicator:(UIView*)v;

/** 设置全局标记，可以一次性设置业务中所有使用的超拉标记 */
+ (void)SetIdentifierTopInstanceCallback:(void(^)(UIScrollView*))block;
+ (void)SetIdentifierBottomInstanceCallback:(void(^)(UIScrollView*))block;

/** 获得到placeholder的大小 */
- (CGRect)rectForPlaceholder;

/** 是否需要显示placeholder */
- (BOOL)shouldShowPlaceholder;

/** 设置是否不显示滚动条 */
@property (nonatomic) BOOL showsScrollIndicator;

/** 计算停靠的是哪一个 */
- (UIView*)pagingAtViews:(UIView*)view, ...;
- (UIView*)pagingInViews:(NSArray*)views;

@end

SIGNAL_DECL(kSignalWorkStateChanged) @"::work::state::changed";

@interface UIScrollViewExt : UIScrollView
<UIScrollViewDelegate, UIViewEdge>

/** 标准的 contentView Apple 没有公开，所以为了避免滑动一下就 layout 的问题，提供了一个 viewContent 作为元素的承载 */
@property (nonatomic, retain) UIView* viewContent;

/** 和父级的区别是，ext 的 addSuview 函数会将 view 加到 viewContent 之上 */
- (void)addSubview:(UIView *)view;

@end

/** 滑动 */
SIGNAL_DECL(kSignalScrolled) @"::ui::scrolled";

/** 开始滑动 */
SIGNAL_DECL(kSignalScrollingBegan) @"::ui::scrolling::began";

/** 滑动结束 */
SIGNAL_DECL(kSignalScrollingEnd) @"::ui::scrolling::end";

/** 带动画的滑动结束 */
SIGNAL_DECL(kSignalAnimateScrolled) @"::ui::scrolled::withanimation";

/** 缩放 */
SIGNAL_DECL(kSignalZoomed) @"::ui::zoomed";

/** 开始拽动 */
SIGNAL_DECL(kSignalDraggingBegin) @"::ui::dragging::begin";

/** 拽动结束 */
SIGNAL_DECL(kSignalDraggingEnd) @"::dragging::end";

/** 减速滑动开始 */
SIGNAL_DECL(kSignalDeceleratingBegin) @"::ui::decelerating::begin";

/** 减速滑动结束 */
SIGNAL_DECL(kSignalDeceleratingEnd) @"::ui::decelerating::end";

/** 开始缩放 */
SIGNAL_DECL(kSignalZoomingBegin) @"::ui::zooming::begin";

/** 结束缩放 */
SIGNAL_DECL(kSignalZoomingEnd) @"::ui::zooming::end";

/** 滚动到顶部 */
SIGNAL_DECL(kSignalScrolledToTop) @"::ui::scrolledtotop";

/** 上拉加载更多 */
SIGNAL_DECL(kSignalPullMore) @"::ui::pull::more::invoke";

/** 下拉刷新 */
SIGNAL_DECL(kSignalPullFlush) @"::ui::pull::flush::invoke";

/** 普通 view 的 scroll 化，可以是任何 view 都可以滑动 */
@interface UIScrollView (scrollize)

/** 将 view 变成可以滑动的，如果已经是可以滑动的，则直接返回可以滑动的 view */
+ (UIScrollView*)scrollize:(UIView*)view;

@end

/** 自定义结构的 cell，添加一个 view 层，用来承载业务中的视图 */
@interface UITableViewCell (extension)

- (id)initWithReuseIdentifier:(NSString*)ri;

/** cell 在当前 tableview 中的索引 */
@property (nonatomic, readonly) NSIndexPath *indexPath;

/** cell 所处的tableview，略有性能问题（使用的是FindSuperTableView[self]实现) */
@property (nonatomic, readonly) UITableView *tableView;

/** 查找cell的tableview */
+ (UITableView*)FindSuperTableView:(UIView*)view;

@end

@interface UITableViewCellExt : UITableViewCell
<UIViewEdge>

// cell 所含有的具体的业务实现 view
@property (nonatomic, retain) UIView* view;

// 同样的可以绑定vc到业务实现
@property (nonatomic, retain) UIViewController* viewController;

// 是否则个cell属于被重用的
@property (nonatomic, assign) BOOL isReused;

// 查找使用这个view的cell
+ (instancetype)CellFromView:(UIView*)view;

// override
- (void)onSelected;
- (void)onDeselected;

@end

SIGNAL_DECL(kSignalSelected) @"::ui::view::selected";
SIGNAL_DECL(kSignalDeselected) @"::ui::view::deselected";
SIGNAL_DECL(kSignalVisibleChanged) @"::ui::view::visible::changed";
SIGNAL_DECL(kSignalUserInteractionChanged) @"::ui::view::userinteraction::changed";

# define UITABLEVIEWCELLEXT_GET_EXT(reuseidr) \
cell = (UITableViewCellExt*)[tableView dequeueReusableCellWithIdentifier:reuseidr]; \
if (cell == nil) { \
cell = [[UITableViewCellExt alloc] initWithReuseIdentifier:reuseidr]; \
SAFE_AUTORELEASE(cell); \
} else { cell.isReused = YES; }

# define UITABLEVIEWCELLEXT_GET(reuseidr) \
UITableViewCellExt* cell = nil; \
UITABLEVIEWCELLEXT_GET_EXT(reuseidr);

# define UITABLEVIEWCELLEXT_MAKECELL_EXT2(cvcls, cvtype, reuseidr) \
cell = (UITableViewCellExt*)[tableView dequeueReusableCellWithIdentifier:reuseidr]; \
cvtype* cv = nil; \
if (cell == nil) { \
cell = [[UITableViewCellExt alloc] initWithReuseIdentifier:reuseidr]; \
cv = [[cvcls alloc] init]; \
if ([cv isKindOfClass:[UIView class]]) \
    cell.view = (id)cv; \
else if ([cv isKindOfClass:[UIViewController class]]) \
    cell.viewController = (id)cv; \
ZERO_RELEASE(cv); \
SAFE_AUTORELEASE(cell); \
cell.isReused = NO; \
} else { \
cell.isReused = YES; \
} \
cv = (cvtype*)cell.view;

# define UITABLEVIEWCELLEXT_MAKECELL_EXT(cvcls, reuseidr) \
UITABLEVIEWCELLEXT_MAKECELL_EXT2(cvcls, cvcls, reuseidr)

# define UITABLEVIEWCELLEXT_MAKECELL(cvcls, reuseidr) \
UITableViewCellExt* cell = nil; \
UITABLEVIEWCELLEXT_MAKECELL_EXT(cvcls, reuseidr);

# define UITABLEVIEWCELLEXT_MAKECELLSIMPLE(cvcls) \
UITABLEVIEWCELLEXT_MAKECELL(cvcls, NSStringFromClass([cvcls class]));

@protocol UIStretchableView <NSObject>

@optional

// 返回需要被拉伸的 view，这个 view 会垫在 navigation 的下面，已达到拉动时顶部不留空的目的
- (UIView*)viewForStretchable;

// 顶部默认的高度，因为拉升后高度有变化，而且不能在拉小的时候缩小原先的大小，所以需要按照默认高度调整
- (CGFloat)heightForStretchable;

@end

@interface UITableView (extension)

- (id)initWithStyle:(UITableViewStyle)style;

/** 最大的indexpath */
@property (nonatomic, copy) NSIndexPath* maxIndexPath;

/** 浮动在顶部\底部的 view
 @note 如果设置了 frame，则跳过自动大小
 2a, 如果 size==0，则使用 bestSize 机制
 2b,如果实现了 constraint 机制，则使用自动大小 机制，并且当约束改变的信号激活时，自动重新设置一下对应的高度
 */
@property (nonatomic, retain) UIView *tableFloatingHeaderView;
@property (nonatomic, retain) UIView *tableFloatingFooterView;

/** 拉伸在顶部的view，通过设置 tableHeaderView<UIScretchableView> 来设置可以拉伸的 view */
@property (nonatomic, readonly, retain) UIView *tableStretchableHeaderView;

/** sectionindex 的样式，不能直接用系统的，以防止破坏系统兼容性 */
@property (nonatomic, retain) UITextStyle *sectionTitleStyle;

/** 刷新所有显示着的cell */
- (void)refreshAppearedCells;

/** 计算大小 */
- (CGRect)rectForCells:(NSArray*)cells;

/** 所有可视的 cell 的总大小 */
- (CGRect)visibleRectForCells:(NSArray*)cells;

/** 需要剔除掉section所占空间时调用 */
- (CGRect)convertRect:(CGRect)rc clipAtSection:(NSUInteger)section;
- (CGRect)convertRect:(CGRect)rc clipAtSection:(NSUInteger)section padding:(CGPadding)padding;

/** 获得 cv 的 ip */
- (NSIndexPath*)indexPathForViewItem:(UIView*)view;

/** 重新加载 cv */
- (void)reloadCellForViewItem:(UIView*)view;

// 一些系统实现的包装
- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths;
- (void)deleteSections:(NSIndexSet *)sections;
- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths;
- (void)insertSections:(NSIndexSet *)sections;
- (void)reloadSections:(NSIndexSet *)sections;
- (void)reloadSection:(NSInteger)section;
- (void)reloadSection:(NSInteger)section withRowAnimation:(UITableViewRowAnimation)animation;
- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths;

/** 滚动到指定位置 */
- (void)scrollToSection:(NSInteger)section;
- (void)scrollToSection:(NSInteger)section atScrollPosition:(UITableViewScrollPosition)scrollPosition;
- (void)scrollToSection:(NSInteger)section atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;

/** 是否锁定 section 以避免 section 按照默认的样式进行停靠，默认为 NO */
@property (nonatomic, assign) BOOL dockingSectionHeader;
//@property (nonatomic, assign) BOOL dockingSectionFooter;

@end

@class UIIndexTitlesView;
@protocol UIIndexTitlesView <NSObject>

@optional

// 返回先使用的view类型
- (Class)typeForSectionIndexTitlesView:(UIIndexTitlesView*)tv forSection:(NSInteger)section;

// 处理显示，可以在这里绑定数据
- (void)sectionIndexTitlesView:(UIIndexTitlesView*)tv titleView:(id)view title:(id)title forSection:(NSInteger)section;

// 宽度
- (CGFloat)widthForSectionIndexTitlesView:(UIIndexTitlesView*)tv;

// 每一行的高度，如果不实现则取bestHeight
- (CGFloat)heightForSectionIndexTitlesView:(UIIndexTitlesView*)tv forSection:(NSInteger)section;

// 条目，为id的列表
- (NSArray*)titlesForIndexTitlesView:(UIIndexTitlesView*)tv;

@end

extern CGFloat kUIIndexTitlesViewDefaultWidth;

@interface UIIndexTitlesView : UIViewExt

@property (nonatomic, assign) id<UIIndexTitlesView> dataSource;

@end

@interface UITableViewExt : UITableView

// 手动控制 section 在折叠时候的位置
//@property (nonatomic, assign) CGPoint sectionFoldingPosition;

// 根据section来获取cells
- (NSArray*)visibleCellsInSection:(int)section;
- (NSArray*)visibleItemsInSection:(int)section;

// 用来显示section的view
@property (nonatomic, retain) UIIndexTitlesView* sectionIndexTitlesView;

@end

@protocol UITableViewDataSourceExt <NSObject>

// 实例化一个 cell，indexPath 根据不同的实现有可能代表的不是普通的cell
- (UITableViewCell*)tableViewExt:(UITableViewExt*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

// 返回 section 中有多少行
- (NSInteger)tableViewExt:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

// 返回行的高度
- (CGFloat)tableViewExt:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (NSInteger)numberOfSectionsInTableViewExt:(UITableView *)tableView;

// 实例化一个 标准cell
- (UITableViewCell*)tableViewExt:(UITableViewExt *)tableView makeCellForRowAtIndexPath:(NSIndexPath *)indexPath;

// 返回 section 标记的高度
- (CGFloat)tableViewExt:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (CGFloat)tableViewExt:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;

// 返回行的业务实现类，该类会自动通过类名被重用
- (Class)tableViewExt:(UITableViewExt*)tableView itemClassForRowAtIndexPath:(NSIndexPath*)indexPath;

// 返回 section 的标记类，会被重用
- (Class)tableViewExt:(UITableViewExt*)tableView viewClassForSectionHeaderInSection:(NSInteger)section;
- (Class)tableViewExt:(UITableViewExt*)tableView viewClassForSectionFooterInSection:(NSInteger)section;

// 当 rows 为 0 时，需要插入显示占位符的功能， 可以通过 tableViewShouldShowPlaceholder 来定义是否需要显示placeholder
- (Class)tableViewExt:(UITableViewExt*)tableView placeholderClassInSection:(NSInteger)section;
- (CGFloat)tableViewExt:(UITableViewExt*)tableView heightForPlaceholderInSection:(NSInteger)section;

@end

@protocol UITableViewDelegateExt <NSObject>

@optional

// 当 cell 显示的时候需要处理数据，就会调用该函数
- (void)tableViewExt:(UITableViewExt*)tableView cell:(UITableViewCellExt*)cell item:(UIView*)item atIndexPath:(NSIndexPath*)indexPath;

// 同理，当标记显示的时候调用该函数
- (void)tableViewExt:(UITableViewExt*)tableView header:(UIView*)header inSection:(NSInteger)section;
- (void)tableViewExt:(UITableViewExt*)tableView footer:(UIView*)footer inSection:(NSInteger)section;

// 同理，当占位标记显示的时候调用
- (void)tableViewExt:(UITableViewExt*)tableView placeholder:(UIView*)view inSection:(NSInteger)section;

// 是否显示占位
- (BOOL)tableViewShouldShowPlaceholder:(UITableView*)tableview;

// 是不是可以显示为section准备的placeholder，因为tableview会自己控制第一次的刷新，但是通常第一次的刷新因为服务器数据还未返回，所以不能显示placeholder，需要通过这个地方控制一下
- (BOOL)tableViewExt:(UITableViewExt*)tableView shouldShowPlaceholderInSection:(NSInteger)section;

@end

/** table 的功能类
 @note 
 支持动态大小，
 支持横向排列，
 支持使用 cell 来模拟section，
 tableview 用 viewwrapper 包装，所以可以使用 wrapper 的特性，
 @code
 UIViewWrapper* vw = (id)self.view; // ok
 vw == self.tableView; // false
 */
@interface UITableViewControllerExt : UIViewControllerExt
<UITableViewDataSourceExt, UITableViewDelegateExt,
UIIndexTitlesView>
{
    UITableViewExt* _tableView;
}

/** 要求的必须为 tableviewExt */
@property (nonatomic, readonly) UITableViewExt* tableView;

/** 样式 */
@property (nonatomic, assign) UITableViewStyle tableViewStyle;

/** 是否是横向排列，默认为NO即标准的竖向排列 **/
@property (nonatomic, assign) BOOL horizon;

/** 默认的 item 创建使用的类型，并且使用该类作为复用的标记(reuseIdentifier) */
@property (nonatomic, assign) Class classForItem;

/** 设置边距，实际设置的是 wrapper 的编剧*/
@property (nonatomic, assign) CGPadding paddingEdge;

/** 滚动 table 到距离下边缘的高度
 @note 常用在需要将 table 中的某一项滚动到键盘边缘
 */
- (void)scrollToView:(UIView*)view alignView:(UIView*)view animated:(BOOL)animated;

/** 重新加载 table 的数据 */
- (void)reloadTable:(BOOL)flush;
- (void)reloadTable;
- (void)flushTable;

@end

// 6.0 以上就可以使用 CollectionView

@interface UICollectionViewCellExt : UICollectionViewCell
<UIViewEdge>

@property (nonatomic, retain) UIView* view;

@end

// 支持自适应高度的单元格
@interface UIConstraintCollectionViewLayout : UICollectionViewLayout

extern CGFloat kUICollectionVewDefaultResistance;

// 弹性系数, 默认为 kUICollectionVewDefaultResistance（iOS7以上有效果）
@property (nonatomic, assign) CGFloat resistance;

@end

@interface UICollectionViewExt : UICollectionView

@end

@protocol UICollectionViewDataSourceExt <UICollectionViewDataSource>

// 替换系统的一些初始化
- (NSInteger)numberOfSectionsInCollectionViewExt:(UICollectionView *)collectionView;;
- (NSInteger)collectionViewExt:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
- (UICollectionViewCell *)collectionViewExt:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

// 当对象初始化成功时调用
- (void)collectionViewExt:(UICollectionView*)collectionView item:(UIView*)item atIndexPath:(NSIndexPath*)indexPath;

// 取得item对象的类
- (Class)collectionViewExt:(UICollectionView*)collectionView itemClassForRowAtIndexPath:(NSIndexPath*)indexPath;

@end

@protocol UICollectionViewDelegateExt <UICollectionViewDelegate>

@end

@interface UICollectionViewControllerExt : UIViewControllerExt
<UICollectionViewDataSourceExt, UICollectionViewDelegateExt>

// 布局的类
@property (nonatomic, assign) Class classForLayout;

// 内部对象的类
@property (nonatomic, assign) Class classForItem;

@end

// 默认对应于透明 navigationbar 的透明度
extern CGFloat kUINavigationBarTranslucentOpacity;

@interface UINavigationBar (extension)

// 定义边缘的阴影
@property (nonatomic, retain) CGShadow *edgeShadow;

// 文字的阴影
@property (nonatomic, assign) CGSize titleShadowOffset;

// 文字的颜色
@property (nonatomic, retain) UIColor *titleColor;

// 文字的字体
@property (nonatomic, retain) UIFont *titleFont;

// 边缘线的样式
@property (nonatomic, retain) CGLine *edgeLine;

// 是否打开毛玻璃效果（ios7以上可用，7一下的系统会直接使用带透明的颜色）
@property (nonatomic, assign) BOOL barBlur;

// 系统ui元素
@property (nonatomic, readonly) NSArray *systemViews;

// 自定义view
@property (nonatomic, retain) UIView *customBarView;

// 设置高度
@property (nonatomic, retain) NSNumber *barHeight;

// 设置bar的高亮颜色，需要有系统刷新才能应用
@property (nonatomic, retain) UIColor* barColor UI_APPEARANCE_SELECTOR;

// 直接设置 bar 的颜色，如果还有 alpha 通道，则会取消掉原始的 alpha 通道，应用并之后都根据该颜色来设置 bar 的颜色，默认为 nil
@property (nonatomic, retain) UIColor* preferrerBarColor;

// 兼容性的设置
- (void)setCompatiableTranslucent:(BOOL)val;
- (void)setCompatiableBarTintColor:(UIColor*)color;

@end

// 如果 vc 实现了此协议，则当他被 push、pop 由 navi 时，会回调这些函数
@protocol UIPushPop <NSObject>

@optional
- (BOOL)pushingInto:(id)obj;
- (void)pushInto:(id)obj;
- (void)popFrom:(id)obj;

@end

@interface UINavigationController (extension)

+ (instancetype)navigationWithController:(UIViewController*)ctlr;

- (void)pushViewController:(UIViewController *)viewController;
- (void)pushViewControllerNoAnimated:(UIViewController *)viewController;

- (NSArray*)popToViewController:(UIViewController*)viewController;
- (NSArray*)popToViewControllerNoAnimated:(UIViewController*)viewController;

- (UIViewController*)popViewController;
- (UIViewController*)popViewControllerNoAnimated;

- (NSArray*)popToRootViewController;
- (NSArray*)popToRootViewControllerNoAnimated;

// back回之前的状态
- (void)goBack:(BOOL)animated;
- (void)goBack;
- (void)goBackNoAnimated;

// 设置一些全局hook函数
+ (void)SetPushHook:(void(^)(UINavigationController*, UIViewController*))hook;
+ (void)SetNavigationItemHook:(void(^)(UINavigationController*, UIViewController*, UINavigationItem*))hook;

// 获得 bar 的高度
- (CGFloat)barHeight;

// 显示 banner
- (void)showBanner:(UIView*)view;
- (void)hideBanner:(UIView*)view;
@property (nonatomic, readonly) UIView *visibleBannerView;
@property (nonatomic, readonly) NSArray *bannerViews;

// 隐藏掉所有的banner
- (void)clearBannerViews;

@end

@interface UINavigationControllerExt : UINavigationController

@end

SIGNAL_DECL(kSignalViewControllerPushed) @"::ui::viewcontroller::pushed";
SIGNAL_DECL(kSignalViewControllerPoping) @"::ui::viewcontroller::poping";
SIGNAL_DECL(kSignalViewControllerPoped) @"::ui::viewcontroller::poped";

@interface UITextField (extension)

// 文字字体
@property (nonatomic, retain) UIFont *textFont;

// 是否是只读
@property (nonatomic, assign) BOOL readonly;

// 增加文字
- (void)appendText:(NSString*)text;
- (void)appendLineBreak;

// 清空
- (void)clear;

@end

// 自动避让键盘的协议
@protocol UIAutoKeyboardDodge <NSObject>

// 是否自动避让键盘，默认YES
@property (nonatomic, assign) BOOL keyboardDodge;

@end

@interface UITextFieldExt : UITextField
<UIAutoKeyboardDodge>

// 输入的验证，如果输入的字符不符合模式，则输入失败
@property (nonatomic, retain) NSRegularExpression *patternInput;

// 值的验证，如果输入的字符后的值不符合模式，则发出不符合模式的信号
@property (nonatomic, retain) NSRegularExpression *patternValue;

// 值是否符合模式
@property (nonatomic, readonly) BOOL isValid;

// 是否自动当点“return”的时候缩下来键盘
@property (nonatomic, assign) BOOL keyboardAutoHide;

// 内容边距
@property (nonatomic, assign) CGPadding contentPadding;

// 默认的文字，和placeholder不同的是，dt的颜色、字体和正常是一样的
@property (nonatomic, copy) NSString *defaultText;

// placeholder的颜色
@property (nonatomic, copy) UIColor *placeholderColor;

// 和settext的区别是这个函数不会激活信号
- (void)changeText:(NSString*)str;

@end

SIGNAL_DECL(kSignalEditing) @"::ui::editing";
SIGNAL_DECL(kSignalEdited) @"::ui::edited";
SIGNAL_DECL(kSignalInputInvalid) @"::ui::input::invalid";
SIGNAL_DECL(kSignalInputValid) @"::ui::input::valid";
SIGNAL_DECL(kSignalValueInvalid) @"::ui::value::invalid";
SIGNAL_DECL(kSignalValueValid) @"::ui::value::valid";

SIGNAL_DECL(kSignalKeyboardReturning) @"::ui::keyboard::return::before";
SIGNAL_DECL(kSignalKeyboardReturn) @"::ui::keyboard::return";

/** 一组图片 */
@interface UIImages : NSObjectExt

/** 图片的数组，不同类需要的格式可能不同 */
@property (nonatomic, retain) NSArray *images;

/** 如果有动画，就是动画的持续时间 */
@property (nonatomic, assign) NSTimeInterval duration;

@end

// 交叉淡出的动画
# define CROSSDISSOLVE_BEGIN(view) \
[UIView transitionWithView:view \
duration:kCAAnimationDuration \
options:UIViewAnimationOptionTransitionCrossDissolve \
animations:^{
# define CROSSDISSOLVE_END \
} completion:^(BOOL finished) { \
}];
# define CROSSDISSOLVE_EXPRESS(view, exp) \
CROSSDISSOLVE_BEGIN(view) exp; CROSSDISSOLVE_END

@interface UIImageView (extension)

/** 如果img不为nil，则view的大小会设置成img的大小 */
+ (instancetype)viewWithImage:(UIImage*)img;

/** 数据源生成图片 */
+ (instancetype)viewWithDataSource:(id)ds;

/** 设置图片数据源，支持 Image，URL，Bundle，Null，Data 的类型 */
@property (nonatomic, assign) id imageDataSource;

/** 是否关闭缓存 */
@property (nonatomic, assign) BOOL disableCache;

/** 如果支持缓存，则代表缓存中得文件地址 */
@property (nonatomic, copy) NSString *cachedImagePath;

/** 覆盖掉 SDWebImage 提供的 URL 相关方法以提供信号的功能 */
- (void)setImageWithURL:(NSURL *)url;

/** 进度指示器，类型必须实现 NSPercentage 接口 */
@property (nonatomic, assign) Class classForFetchingIdentifier;
@property (nonatomic, readonly) UIView<NSPercentage>* fetchingIdentifier;

/** 设置一批图片 */
@property (nonatomic, retain) UIImages *images;
@property (nonatomic, retain) UIImages *highlightImages;

@end

SIGNAL_DECL(kSignalImageFetchStart) @"::ui::image::fetch::start";
SIGNAL_DECL(kSignalImageFetching) @"::ui::image::fetching";
SIGNAL_DECL(kSignalImageFetched) @"::ui::image::fetched";
SIGNAL_DECL(kSignalImageFetchFailed) @"::ui::image::fetch::failed";
SIGNAL_DECL(kSignalStateChanged) @"::ui::state::changed";
SIGNAL_DECL(kSignalImageChanged) @"::ui::image::changed";

@interface UIImageViewExt : UIImageView
<UIViewEdge>

// 可以设置各种状态对应的 imageDataSource
@property (nonatomic, retain) NSDictionary* states;

// 当前状态，必须属于 states 中定义的 key
@property (nonatomic, retain) id currentState;

// 在image发生改变的时候使用淡入淡出来加强UI效果，默认为NO
@property (nonatomic, assign) BOOL fadesChanging;

// 模糊效果
@property (nonatomic, retain) CGBlur *imageBlur;

// 自定义图像滤镜
@property (nonatomic, retain) CGFilter *imageFilter;

// 是否支持动画格式图片，默认为NO，打开后 GIF 就可以动了
@property (nonatomic, assign) BOOL supportAnimatedFormat;

// 使用状态图片来初始化
- (id)initWithStates:(NSDictionary*)si;

// 不激活信号的设置
- (void)changeImage:(UIImage*)img;
- (void)changeState:(id)state;

@end

@interface UIImageViewCache : NSObject

+ (unsigned long long)ByteSize;
+ (void)Clear;

@end

@protocol UIConstraintView <NSObject>

// 返回约束（期望）的大小
- (CGSize)constraintBounds;

@end

@interface UIConstraintView : UIViewExt <UIConstraintView>
@end

SIGNAL_DECL(kSignalConstraintChanged) @"::ui::constraint::changed";

/** 实现快速包裹一个view的目的 */
@interface UIViewWrapper : UIViewExt

/** 内容的view */
@property (nonatomic, retain) UIView* contentView;

/** 上下左右的四个边界view */
@property (nonatomic, retain) UIView *leftView, *rightView, *topView, *bottomView;

/** 优先大小 */
@property (nonatomic, retain) NSRect *preferredRect;

/** 优先位置 */
@property (nonatomic, retain) NSPoint *preferredAnchorTo;

/** 是否忽略 transform 以避免类似于横向 tableview 时造成大小设置失败的问题，默认为 YES */
@property (nonatomic, assign) BOOL ignoreContentViewTransform;

- (id)initWithView:(UIView*)view;
+ (instancetype)wrapperWithView:(UIView*)view;
+ (instancetype)wrapperWithView:(UIView*)view paddingEdge:(CGPadding)paddingEdge;

@end

// 实现快速包裹一个vc的目的
@interface UIViewControllerWrapper : UIViewControllerExt

@property (nonatomic, retain) UIViewController *viewController;

- (id)initWithViewController:(UIViewController*)vc;
+ (instancetype)wrapperWithViewController:(UIViewController*)vc;

@end

@interface UISwitch (extension)

@end

/** 自定义的开关 */
@interface UISwitchExt : UIControlExt

@property(nonatomic, retain) UIColor *onTintColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property(nonatomic, retain) UIColor *tintColor NS_AVAILABLE_IOS(6_0);
@property(nonatomic, retain) UIColor *thumbTintColor NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;

@property(nonatomic, retain) UIImage *onImage NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;
@property(nonatomic, retain) UIImage *offImage NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;

/** 是否打开了开关 */
@property(nonatomic, assign) BOOL on;
- (void)setOn:(BOOL)on animated:(BOOL)animated; // does not send action

/** 打开 */
- (void)setOn;

/** 关闭 */
- (void)setOff;

/** 激发到相对状态 */
- (void)toggle;
- (void)toggle:(BOOL)animated;

/** 根据需要访问即生成 label */
@property (nonatomic, retain) NSString* text;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIFont *textFont;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, retain) UILabelExt *titleLabel;

@end

@interface UIImage (extension)

/** 使用中心点拉大图片 */
+ (UIImage*)stretchImage:(NSString*)name;

/** 使用停靠点拉大图片 */
+ (UIImage*)stretchImage:(NSString*)name anchorPoint:(CGPoint)pt;

/** 定点拉大图片 */
+ (UIImage*)stretchImage:(NSString*)name atPoint:(CGPoint)pt;

/** 水平中心拉大图片 */
+ (UIImage*)stretchImageHov:(NSString*)name;

/** 垂直中心拉大图片 */
+ (UIImage*)stretchImageVec:(NSString*)name;

/** 加载 bundle 里面的图片 */
+ (UIImage*)bundleNamed:(NSString*)name;

/** 生成符合屏幕缩放比例的图片 */
- (UIImage*)adaptivedImage;

/** 缩放图片 */
- (UIImage*)imageScaled:(CGFloat)scale;

/** 裁剪图片 */
- (UIImage*)imageClip:(CGRect)rc;

/** 重新设置图片的大小 */
- (UIImage*)imageResize:(CGSize)sz contentMode:(UIViewContentMode)mode;

/** 读取一组图片 */
+ (NSArray*)imagesNamed:(NSString*)name, ...;
+ (NSArray*)imagesNamedFromArray:(NSArray*)arr;

/** 使用包带的图像内容生成 */
+ (UIImage*)imageWithContentOfNamed:(NSString*)name;
+ (UIImage*)imageWithContentOfDataSource:(id)ds;

/** 获得最佳的大小 */
- (CGSize)bestSize:(CGSize)cssz;
+ (CGSize)BestSize:(CGSize)imgsize constraintIn:(CGSize)cssz;
+ (CGSize)BestSize:(CGSize)imgsize constraintIn:(CGSize)cssz constraintMax:(CGSize)maxsz;

/** 生成模糊化的图片 */
- (UIImage*)imageBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor*)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor;
- (UIImage*)imageBlur:(CGBlur*)blur;

/** 常用模糊效果 */
- (UIImage*)imageSubtleBlur;
- (UIImage*)imageLightBlur;
- (UIImage*)imageExtraLightBlur;
- (UIImage*)imageDarkBlur;

/** 生成带透明的图片 */
- (UIImage*)imageAlpha:(CGFloat)alpha;

/** 反转的图片 
 @param vertical 是否按照垂直方向翻转
 */
- (UIImage*)imageFlip:(BOOL)vertical;
- (UIImage*)imageFlipVertical;
- (UIImage*)imageFlipHorizon;

/** 应用滤镜 */
- (UIImage*)imageFilter:(CGFilter*)filter;

/** 使用名字保存到临时目录中 */
- (void)saveAs:(NSString*)name;

/** 保存到文件 */
- (void)saveTo:(NSString*)file;

/** 空图片 */
+ (instancetype)clearImage;

@end

@interface UIImage (asyncdownload)

// 异步下载图片
- (void)asyncDownloadImageByURL:(NSURL*)url;

@end

@interface UIBackgroudImage : UIImage @end

/** 兼容高清和普通的函数，内部会根据当前屏幕自动调整 */
@interface UIRetina : NSObject

/** 自动查找app资源库中改名字对应的图片类型，自动添加 @2x，568@2x */
+ (NSString*)pathOfImageNamed:(NSString*)name;

/** 加载资源库中的图片，不适用缓存 */
+ (UIImage*)loadImageNamed:(NSString*)name;

@end

//# define _R(name) [UIRetina imageNamed:name]

@protocol UIJavascriptObject <NSObject>

// 返回js对象在js中的名字
- (NSString*)nameForJavascriptObject;

@end

@interface UIWebView (extension)

// 操作html的title
@property (nonatomic, assign) NSString* title;

// html字符串
@property (nonatomic, retain) NSString* htmlString;

// 执行js脚本
- (NSString*)stringByEvaluatingJavaScriptFromFomat:(NSString *)script, ...;

// 简化的写法
- (NSString*)runJavascript:(NSString*)str;

@end

@interface UIWebView (callback)

/** 为了统一各产品线的js回调，WEB端采用和安卓同样的js语法调用（即将生成 window.jsobj... 的对象调用） */
- (void)addJSObject:(id<UIJavascriptObject>)jsobj;

/** 根据名字查询js回调对象 */
- (id<UIJavascriptObject>)jsobjectForName:(NSString*)name;

/** 当前所有的js回调对象 */
- (NSArray*)allJSObjects;

/** 是否表现的像一个 app 的页面，默认为 NO */
- (void)simulateNativeApp:(BOOL)val;

@end

@interface UIWebViewExt : UIWebView

@end

@class UIWebViewController;
@protocol UIWebViewController <NSObject>

@optional

/** 如果当前页面请求了一个新页面跳转，则需要实例化一个web用来展示这个页面 */
- (UIWebViewController*)webViewControllerForForward:(UIWebViewController*)vc;

/** 新页面是否同步设置当前页面的JS对象，默认为NO，因为大多数业务情况下会子类化web然后在onload的地方手动实例化自己的JSObject，如果再自动继承，则会覆盖之前的，导致类型错误的问题 */
- (BOOL)webViewControllerInheritJSObjects:(UIWebViewController*)vc;

@end

/** 封装完整的 webview */
@interface UIWebViewController : UIViewControllerExt
<UIWebViewController, NSCopying>

@property (nonatomic, assign) id<UIWebViewController> delegate;

/** 内部的webview */
@property (nonatomic, readonly) UIWebView *webView;

/** 请求串 */
@property (nonatomic, copy) NSURLRequest *request;
@property (nonatomic, copy) NSString *requestString;
@property (nonatomic, copy) NSURL *requestURL;

/** cookies，会自动添加到request中 */
@property (nonatomic, retain) NSArray *cookies;

/** 使用的自定义客户端类型标记 */
@property (nonatomic, copy) NSString *userAgent;

/** 自动根据web的浏览的页面设置title，默认为YES */
@property (nonatomic, assign) BOOL autosyncTitle;

/** 缓存的时间，默认为0 */
@property (nonatomic, assign) NSUInteger cacheExpiration;

/** 重新加载 */
- (void)reloadData;

/** 清空全部缓存 */
+ (void)ClearCaches;

/** 清空当前 webview 的缓存 */
- (void)clearCache;

/** 是否每次新开页面都需要清除一下对应的缓存，默认为 NO */
@property (nonatomic, assign) BOOL purifyCache;

/** 是否表现的像原生的 app，默认为 NO */
@property (nonatomic, assign) BOOL simulateNativeApp;

@end

// 正在加载内容
SIGNAL_DECL(kSignalContentLoading) @"::ui::content::loading";

// 内容已经加载
SIGNAL_DECL(kSignalContentLoaded) @"::ui::content::loaded";

// 内容加载失败
SIGNAL_DECL(kSignalContentLoadFailed) @"::ui::content::load::failed";

// 需要复制一个对象
SIGNAL_DECL(kSignalDuplicatedObject) @"::object::duplicated";

// 单击了网页内的链接
SIGNAL_DECL(kSignalLinkClicked) @"::ui::link::clicked";

@interface UIGestureRecognizer (extension)

/** 是否可以发出信号 */
- (BOOL)isValidRecognizer;

/** 遍历所有的点 */
- (void)foreachTouch:(BOOL(^)(CGPoint pt, NSInteger idx))touch inView:(UIView*)view;

@end

@interface UIPanGestureRecognizer (extension)

/** 滑动的方向 */
@property (nonatomic, readonly) CGDirection direction;

/** 此次识别过程总共移动的距离 */
@property (nonatomic, assign) CGPoint translation;

/** 全生命期移动的距离 */
@property (nonatomic, assign) CGPoint offset;

/** 移动的增量 */
@property (nonatomic, assign) CGPoint delta;

/** 移动的速度 */
@property (nonatomic, assign) CGPoint velocity;

@end

@interface UIPinchGestureRecognizer (extension)

/** 整个生命期缩放的大小 */
@property (nonatomic, readonly) CGFloat zoom;

/** 此次识别出的缩放 */
@property (nonatomic, readonly) float delta;

@end

enum {
    UISwipeGestureRecognizerDirectionAll =
    UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown,
    UISwipeGestureRecognizerDirectionHorizon =
    UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight,
    UISwipeGestureRecognizerDirectionVertical =
    UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown
};

// 手势激活一个动作
SIGNAL_DECL(kSignalGesture) @"::ui::gesture";

// 手势开始
SIGNAL_DECL(kSignalGestureBegan) @"::ui::gesture::began";

// 手势结束、和手势识别是同一个意思，但是这两个信号不响应中间状态，如果需要动画等来配合手势，用 kSignalGesture 信号代替
SIGNAL_DECL(kSignalGestureEnded) @"::ui::gesture::ended";
SIGNAL_DECL(kSignalGestureRecognized) @"::ui::gesture::ended";

// 手势的数据变化
SIGNAL_DECL(kSignalGestureChanged) @"::ui::gesture::changed";

// 手势识别取消
SIGNAL_DECL(kSignalGestureCancel) @"::ui::gesture::cancel";

// 手势可能被其他手势截获，但响应了触摸消息
SIGNAL_DECL(kSignalGesturePossible) @"::ui::gesture::possible";

// 时候识别失败
SIGNAL_DECL(kSignalGestureFailed) @"::ui::gesture::failed";

// 如果手势具有方向特征，则代表中途改变了方向
SIGNAL_DECL(kSignalDirectionChanged) @"::direction::changed";

/** 继承了 touchs 和 手势识别 的统一处理类
 @note 一些业务需要 touchs 和手势同时存在并被处理，但是因为手势的识别会 cancel 掉 touches 的消息，而且有可能 touches 和 gesture 会维护相同的状态，所以封装一个大统一类，如果是gesture 取消了 touches，则 touches 的 cancel 信号不会被激活，而且 touches 和 gesture 的 began 都统一为 start
 */
@interface UIUnifiedGestureTouches : NSObjectExt

/** 添加一个手势 */
- (void)addGestureRecognizer:(UIGestureRecognizer*)rec;

@end

@interface UIView (unified_gt)

@property (nonatomic, readonly) UIUnifiedGestureTouches *unifiedGestureTouches;

@end

@interface UIDesktopView : UIScrollViewExt

- (void)open;
- (void)close;

@end

@interface UIDesktop : UIViewControllerExt

// 桌面的颜色
@property (nonatomic, retain) UIColor* backgroundColor;

// 初始化
+ (instancetype)desktopWithContent:(UIViewController*)vc;
+ (instancetype)desktopWithView:(UIView*)v;
- (id)initWithContent:(UIViewController*)vc;

// 内容页面
@property (nonatomic, retain) UIViewController *content;

// 标准桌面颜色
+ (UIColor*)BackgroundColor;

// 标准模式显示
- (instancetype)open;
- (instancetype)openIn:(UIViewController*)ctlr;

// 关闭此desktop
- (void)close;

// 关闭所有的Desktop，比如登出的时候需要关闭正在显示desktop
+ (void)CloseAll;

// 打开，模拟系统popup的形式
- (instancetype)popup;
- (instancetype)popupIn:(UIViewController*)ctlr;

// 源视图和目的视图，用以在之间生成打开动画
@property (nonatomic, assign) UIView *viewSource, *viewDest;

// 点击空白处关闭，默认为 YES
@property (nonatomic, assign) BOOL clickToClose;

// 用于当 desktop 弹出时仍然高亮的视图
@property (nonatomic, retain) NSArray *highlightViews;

// 控制位置
@property (nonatomic, assign) CGPadding contentPadding;

// 一些其他的函数
- (void)slideFromTop;
- (void)slideFromBottom;
- (void)slideFromLeft;
- (void)slideFromRight;
- (void)slideToTop;
- (void)slideToBottom;
- (void)slideToLeft;
- (void)slideToRight;
- (void)tremble;
- (void)fadeIn;

@end

SIGNAL_DECL(kSignalOpening) @"::ui::opening";
SIGNAL_DECL(kSignalOpened) @"::ui::opened";
SIGNAL_DECL(kSignalClosing) @"::ui::closing";
SIGNAL_DECL(kSignalClosed) @"::ui::closed";
SIGNAL_DECL(kSignalRequestOpen) @"::ui::request::open";
SIGNAL_DECL(kSignalRequestClose) @"::ui::request::close";

@interface UIPopoverDesktop : UIDesktop

// 弹开的方向，默认为 fromBottom
@property (nonatomic, assign) CGDirection direction;

@end

// 用于调试时显示“尚未实现”而不是点击上去没反应时用的空类
@interface UINotImplementationView : UIViewExt
@end

@interface UINotImplementationViewController : UIViewControllerExt
@end

@interface UIMessageBox : NSObject

// 弹出确定取消
+ (instancetype)YesNo:(NSString*)title message:(NSString*)message yes:(NSString*)yes no:(NSString*)no;
- (id)initWith:(NSString*)title message:(NSString*)message yes:(NSString*)yes no:(NSString*)no;

// 弹出确认
+ (instancetype)Ok:(NSString*)title message:(NSString*)message ok:(NSString*)ok;
- (id)initWithOk:(NSString*)title message:(NSString*)message ok:(NSString*)ok;

@end

SIGNAL_DECL(kSignalOkClicked) @"::ui::clicked::ok";
SIGNAL_DECL(kSignalCancelClicked) @"::ui::clicked::cancel";

@interface NSError (ui)

// 使用alert来显示一个错误
- (void)show;

@end

// 有时候需要一个vc但是手上只有一个view，但又不希望是一个标准vc，就可以使用这个原型vc来欺骗掉rt达到目的
// 该类具有vc的大部分接口
@interface UIProtoViewController : NSObject

@property (nonatomic, assign) UINavigationController* navigationController;
@property (nonatomic, retain) UIView* view;

- (void)loadView;

@end

@interface UINavigationItem (extension)

- (void)setWithNavigationItem:(UINavigationItem*)item;

// 左边的按钮
@property (nonatomic, retain) UIView* leftBarViewItem;

// 右边的按钮
@property (nonatomic, retain) UIView* rightBarViewItem;

@end

SIGNAL_DECL(kSignalItemsChanged) @"::ui::items::changed"; // item即将改变
SIGNAL_DECL(kSignalSelectionChanging) @"::ui::selection::changing"; // 选择即将改变
SIGNAL_DECL(kSignalSelectionChanged) @"::ui::selection::changed"; // 选择产生改变
SIGNAL_DECL(kSignalSelectionReactive) @"::ui::selection::reactive"; // 点击当前选择的
SIGNAL_DECL(kSignalSelectionUpdated) @"::ui::selection::updated"; // 选择已经更新，有可能是换选，也有可能重复点击
SIGNAL_DECL(kSignalSelectionGot) @"ui::selection::got"; // 选中
SIGNAL_DECL(kSignalSelectionLost) @"ui::selection::lost"; // 取消选中

@interface UITextView (extension)

/** 字体 */
@property (nonatomic, retain) UIFont *textFont;

/** 只读 */
@property (nonatomic, assign) BOOL readonly;

/** 富文本样式的字符串 */
- (void)setStylizedString:(NSStylizedString*)str;

@end

@interface UITextViewExt : UIViewExt
<UIAutoKeyboardDodge>

/** 可以滚动的内容页面 */
@property (nonatomic, readonly) UITextView* textView;

/** 文字相关属性 */
@property (nonatomic, copy) NSString *text, *placeholder;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIFont *textFont;
@property (nonatomic, assign) NSTextAlignment textAlignment;

/** 只读与否 */
@property (nonatomic, assign) BOOL readonly;

/** 用return按钮来换行 */
@property (nonatomic, assign) BOOL returnAsLinebreak;

/** 输入、字符串验证用的匹配串 */
@property (nonatomic, retain) NSRegularExpression *patternInput, *patternValue;

/** 这一次匹配是否成功 */
@property (nonatomic, readonly) BOOL isValid;

/** 内容的边距 */
@property (nonatomic, assign) CGPadding contentPadding;

/** 其他导出自 textview 的 */
@property (nonatomic, assign) UIReturnKeyType returnKeyType;

/** 增加文字 */
- (void)appendText:(NSString*)text;

/** 增加换行 */
- (void)appendLineBreak;

/** 清空 */
- (void)clear;

/** 富文本样式字符串 */
@property (nonatomic, retain) NSStylizedString *stylizedString;

@end

SIGNAL_DECL(kSignalLinesChanged) @"::ui::lines::changed";

@interface UIKeyboardExt : NSObject

// 获得在view中得键盘大小
- (CGRect)rectInView:(UIView*)view;

// 避让键盘
- (void)dodgeView:(UIView*)view;

// 关闭键盘
+ (void)Close;

// 键盘当前的和最终的大小
@property (nonatomic, assign) CGRect frame, framing;

// 屏幕上是否有键盘
@property (nonatomic, assign) BOOL visible;

// 最近一次键盘动画使用的时间
@property (nonatomic, assign) CGFloat duration;

// 最近一次键盘动画使用的过渡效果
@property (nonatomic, assign) UIViewAnimationCurve animationCurve;
@property (nonatomic, readonly) UIViewAnimationOptions animationOptions;

// 即将隐藏\显示
@property (nonatomic, readonly) BOOL willHide, willShow;

@end

/** 承载自定义输入框+键盘的对象 */
@interface UIKeyboardPanel : UIViewExt <UIConstraintView>

/** 键盘顶部的控件，通常为输入框或者其他 */
@property (nonatomic, retain) UIView* toolbarView;

/** 键盘区域
 @note 当键盘激活时，如果是非输入状态，则会在键盘的位置显示内容 UI
 */
@property (nonatomic, retain) UIView* contentView;

/** 绑定到一个responder，如果激活将自动调用activate */
@property (nonatomic, retain) UIResponder* responder;

/** 打开键盘 */
- (void)open;

/** 关闭键盘 */
- (void)close;

@end

extern UIViewAnimationOptions UIViewAnimationCurve2Options(UIViewAnimationCurve);

SIGNAL_DECL(kSignalKeyboardHiding) @"::ui::keyboard::hiding";
SIGNAL_DECL(kSignalKeyboardHidden) @"::ui::keyboard::hidden";
SIGNAL_DECL(kSignalKeyboardShowing) @"::ui::keyboard::showing";
SIGNAL_DECL(kSignalKeyboardShown) @"::ui::keyboard::shown";

@interface NSItemObject: NSObject

// 显示的文字
@property (nonatomic, copy) NSString *title;

// 索引
@property (nonatomic, assign) NSInteger index;

// 标记
@property (nonatomic, assign) NSInteger tag;

@end

@interface UIActionSheetExt : UIActionSheet
<UIActionSheetDelegate>

- (id)init;

// 自动关闭, 默认为 YES
@property (nonatomic, assign) BOOL autoClose;

// 添加一个文字选项，可以通过 itemobject 的 ksignalclicked 来绑定处理
- (NSItemObject*)addItem:(NSString*)str;

// 添加取消的文字
- (NSItemObject*)addCancel:(NSString*)str;

// 显示，调用这个函数才能显示出来
- (void)show;

@end

@interface UIAlertView (extension)

// 输入框、密码框
@property (nonatomic, readonly) UITextField *inputText, *inputSecure;

// 登录用的用户名框、密码框
@property (nonatomic, readonly) UITextField *inputUser, *inputPassword;

@end

@interface UIAlertViewExt : UIAlertView

@property (nonatomic, retain) UIView *contentView;

// 添加按钮
- (NSObject*)addItem:(NSString*)str;
- (NSObject*)addCancel:(NSString*)str;

// 同步的方式，返回按键
// 标准的启动方式为异步，只能通过信号来绑定处理，而同步的方式会在显示后阻塞确认线程，当选择完毕后，确认线程恢复执行，可以通过返回的索引来判断哪个按钮点击
- (NSInteger)confirm;

@end

@interface UIMenuItem (extension)

// 是否隐藏，默认为 NO
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, assign) BOOL visible;

@end

@interface UIMenuControllerExt : NSObjectExt

// 绑定的执行对象
@property (nonatomic, assign) id target;

// 标准句柄
@property (nonatomic, readonly) UIMenuController* menu;

// 显示时用来偏移原始 frame 的参数，可以用来调整 menu 的位置
@property (nonatomic, assign) CGPadding padding;

// 允许默认的动作
@property (nonatomic, assign) BOOL disableStandardActions;

// 添加一个菜单项
- (UIMenuItem*)addItem:(NSString*)title;

// 获取到 items 的列表
@property (nonatomic, readonly) NSArray *items;

// 根据当前的配置实例化一个对象
- (UIMenuController*)instanceMenu;

@end

@interface UIPasteboard (extension)

// 剪贴板上的对象
@property (nonatomic, assign) id object;

// 保存一个对象到剪贴板
- (void)setObject:(id)object;

@end

@interface UIPasteboardExt : NSObjectExt

// 打开
+ (instancetype)Open:(NSString*)name;

// 操作对象
@property (nonatomic, assign) id object;

// 一些直接访问对象
@property(nonatomic,copy) NSString *string;
@property(nonatomic,copy) NSURL *URL;
@property(nonatomic,copy) UIImage *image;
@property(nonatomic,copy) UIColor *color;

@end

@interface UIDatePicker (extension)

- (void)setTime:(NSTime*)tm animated:(BOOL)animated;
- (NSTime*)time;

// 标准时期拾取控件的高度
+ (CGFloat)Height;

@end

@interface UIDatePickerExt : UIDatePicker

@end

extern CGRect UIEdgeInsetsDeinsetRect(CGRect rect, UIEdgeInsets insets);
extern UIEdgeInsets UIEdgeInsetsAdd(UIEdgeInsets, UIEdgeInsets);
extern UIEdgeInsets UIEdgeInsetsSub(UIEdgeInsets, UIEdgeInsets);

// 可以用来当系统运行在需要处理UI的时候使用
# define UIUPDATE_BEGIN \
{ if (DATA_ONLY_MODE == NO) {

# define UIUPDATE_END }}
# define UIUPDATE(exp) UIUPDATE_BEGIN exp; UIUPDATE_END

// 运行必须位于屏幕更新后
# define UIUPDATE_SCREEN(exp) \
{ AFTER_SCREENUPDATED = YES; exp; AFTER_SCREENUPDATED = NO; }

@interface UIBarItem (extension)

// 默认为 kUIBarItemDefaultPriority, 越小的数值代表越大
@property (nonatomic, assign) NSInteger priority;

@end

extern NSInteger kUIBarItemDefaultPriority;

@interface UIBarButtonItem (extension)

// 范围控制
@property (nonatomic, assign) CGPadding hitTestPadding;

- (id)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style;
- (id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style;
- (id)initWithPush:(NSString*)pushimg style:(UIBarButtonItemStyle)style;

- (id)initWithImage:(UIImage*)image;
- (id)initWithTitle:(NSString*)title;
- (id)initWithPush:(NSString*)pushimg;

// 如果使用样式string，内部将使用label来实现，其他的均使用button来实现
- (id)initWithStylizedString:(NSStylizedString*)string;

+ (instancetype)itemWithImage:(UIImage*)image;
+ (instancetype)itemWithTitle:(NSString*)title;
+ (instancetype)itemWithStylizedString:(NSStylizedString*)string;
+ (instancetype)itemWithPush:(NSString*)pushimg;
+ (instancetype)itemWithView:(UIView*)view;

- (id)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem;

// 颜色、字号
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIFont *textFont;

// 获得到内部实现用的button
@property (nonatomic, readonly) UIButtonExt *buttonItem;

// 获得内部使用的label
@property (nonatomic, readonly) UILabelExt *labelItem;

// 内部使用的label所使用的样式string
@property (nonatomic, retain) NSStylizedString *stylizedString;

// 设置大小
@property (nonatomic, assign) CGSize size;

@end

@interface UIView (activity_indicator)

// 开始播放代表正在运行的动画
- (void)startActiviting;

// 停止代表正在运行的动画
- (void)stopActiviting;

@end

@interface UIActivityIndicatorView (extension)

+ (instancetype)activityIndicatorWithStyle:(UIActivityIndicatorViewStyle)style;
+ (instancetype)Gray;
+ (instancetype)White;
+ (instancetype)WhithLarge;

// 动画
@property (nonatomic, assign) BOOL animating;

@end

@interface UIImageCropController : UIViewControllerExt

// 输入用的图片
@property (nonatomic, retain) UIImage *image;

// 限制修改的长宽比, 0为不限制
@property (nonatomic, assign) CGFloat aspect;

@end

@interface UIPageViewControllerExt : UIPageViewController

@property (nonatomic, retain) NSArray *pageViewControllers;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) UIViewController *currentViewController;

- (void)setPageViewControllers:(NSArray*)array selectPageAtIndex:(NSInteger)idx;
- (void)changePageViewControllers:(NSArray*)array;

@end

typedef enum {
    kUIDeviceTypeIPhone = 0x1000,
    kUIDeviceTypeIPad = 0x2000,
    kUIDeviceTypeIPod = 0x4000,
    kUIDeviceTypeSimulator = 0x0001,
} UIDeviceType;

@interface UIDevice (extension)

// 是否已经越狱
+ (BOOL)IsRoot;

// 当前设备的类型
+ (UIDeviceType)DeviceType;

// 获得到唯一 ID
+ (NSString*)UniqueIdentifier;

// 振动一下
+ (void)Vibrate;

@end

SIGNAL_DECL(kSignalDeviceVibrate) @"::ui::device::vibrate";

@interface UIScreen (extension)

// 最佳适配的程序启动文件
+ (NSString*)pathForLaunchImage;
+ (NSString*)namedForLaunchImage;
+ (UIImage*)LaunchImage;

// 最佳的缩略图
+ (NSString*)pathForAppIcon;
+ (NSString*)namedForAppIcon;
+ (UIImage*)AppIcon;

@end

@interface UIApplication (extension)

/** 打开外部链接 */
- (BOOL)openURLString:(NSString*)url;

/** 是否可以打开该链接 */
- (BOOL)canOpenURLString:(NSString*)url;

/** 打开url，如果没有http前缀，会自动补全 */
- (BOOL)openHttp:(NSString*)url;

/** 是否安装了程序 */
- (BOOL)isInstalled:(NSString*)scheme;

/** 打开 app */
- (BOOL)openApp:(NSString*)scheme;

/** 打开改程序在 AppStore 里面的页面 */
- (void)goAppstoreHome:(NSString*)appid;
- (NSString*)appstoreURL:(NSString*)appid;

/** 如果 url 包含 appid，则打开 appstore 里面的页面，否则打开 URL */
- (void)goAppHome:(NSString*)url;

/** 打开程序在 AppStore 的点评页面 */
- (void)goReview:(NSString*)appid;

/** 所有的用来跳回来的 scheme */
- (NSArray*)appSchemes;

/** 设置状态栏的颜色 */
@property (nonatomic, retain) UIColor *statusBarColor;

@end

@class UIStylizedStringView;

@protocol UIStylizedStringDataSrouce <NSObject>

- (UIView*)stylizedStringView:(UIStylizedStringView*)view customViewForStylizedItem:(id<NSStylizedItemCustom>)item;

@end

@protocol UIStylizedStringDelegate <NSObject>

@optional
- (void)stylizedStringView:(UIStylizedStringView*)view customView:(UIView*)customView forStylizedItem:(id<NSStylizedItemCustom>)item;

@end

@interface UIStylizedStringView : UIViewExt
<UIStylizedStringDataSrouce, UIStylizedStringDelegate>

@property (nonatomic, assign) id<UIStylizedStringDataSrouce> dataSource;
@property (nonatomic, assign) id<UIStylizedStringDelegate> delegate;
@property (nonatomic, retain) NSStylizedString *string;
@property (nonatomic, readonly) NSAttributedString *attributedString;
@property (nonatomic, assign) CGPadding contentPadding;

- (void)reloadData;

@end

SIGNAL_DECL(kSignalStylizedCustomViewCreated) @"::ui::stylized::custom::created";

extern NSString* kStylizedIdentifierLink;
extern NSString* kStylizedIdentifierImage;
extern NSString* kStylizedIdentifierLabel;

@interface UIPageControl (extension)

- (void)changeCurrentPage:(NSUInteger)index;

@end

@interface UIPageControlExt : SMPageControl

- (void)changeCurrentPage:(NSUInteger)index;

@end

@interface UITabBarItem (extension)

// 注意设置顺序，imageHighlight 之后再设置 image， image会冲掉highlight
@property (nonatomic, retain) UIImage *highlightImage;
@property (nonatomic, retain) UIImage *image;

// 一组图片
@property (nonatomic, retain) UIImages *images;
@property (nonatomic, retain) UIImages *highlightImages;

// 根据名字设置普通的和highlight的图片
- (void)setImagePushed:(NSString*)name;

// 一些初始化的处理
- (id)initWithTitle:(NSString*)title;
- (id)initWithImage:(UIImage*)image;

- (id)initWithTitle:(NSString*)title image:(UIImage*)image;
- (id)initWithTabBarSystemItem:(UITabBarSystemItem)systemItem;

+ (instancetype)itemWithTitle:(NSString*)title;
+ (instancetype)itemWithImage:(UIImage*)image;
+ (instancetype)itemWithTitle:(NSString*)title image:(UIImage*)image;
+ (instancetype)itemWithTabBarSystemItem:(UITabBarSystemItem)systemItem;

@end

@interface UITabBar (extension)

// 正在显示的item
@property (nonatomic, readonly) NSArray* itemViews;

// 设置边缘线
@property (nonatomic, retain) CGShadow *edgeShadow;

// 获取内部的item
- (UIView*)itemViewAtIndex:(NSUInteger)idx;
- (UIView*)itemView:(UITabBarItem*)item;
- (NSArray*)indexedItemViews;
- (NSUInteger)indexOfItemView:(UIView*)itemView;
- (UITabBarItem*)itemOfItemView:(UIView*)itemView;

+ (UIView*)ViewOfItem:(UIView*)itemView;
+ (void)AddView:(UIView*)view toItemView:(UIView*)itemView;

@end

@interface UITabBarController (extension)

@end

@protocol UITabBarControllerDelegateExt <UITabBarControllerDelegate>

@optional

- (void)tabBarController:(UITabBarController *)tabBarController itemView:(UIView*)itemView;
- (void)tabBarController:(UITabBarController *)tabBarController itemViewFrameChanged:(UIView *)itemView;

@end

@interface UITabBarControllerExt : UITabBarController
<UITabBarControllerDelegateExt>

@property (nonatomic, assign) NSUInteger previousSelectedIndex;

@end

@interface UIViewController (searchbar)

@property (nonatomic, assign) BOOL isSearchBarResponding;

@end

@interface UIView (searchbar)

@property (nonatomic, assign) BOOL disableSearchBarSearchTransition;

@end

@interface UISearchBar (extension)

// 输入框的背景
@property (nonatomic, retain) UIImage *backgroundImageForSearchField;

// 不显示过渡动画
@property (nonatomic, assign) BOOL disableSearchTransition;

// 文字的属性
@property (nonatomic, retain) NSDictionary* textAttributes UI_APPEARANCE_SELECTOR;

@end

/** 扩展标准的 searchbar */
@interface UISearchBarExt : UISearchBar
<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

/** 用来显示结果的vc */
@property (nonatomic, assign) UIViewController* contentsViewController;

/** 结果的table */
@property (nonatomic, readonly) UITableView* tableView;

/** 结果的vc */
@property (nonatomic, retain) UISearchDisplayController* displayer;

/** 是否处于打开状态 */
+ (BOOL)IsResponding;

/** 如果不是和 searchcontroller 配合，则可以使用这几个参数来控制样式
 是否当搜索时自动显示、隐藏closebutton， 默认为YES */
@property (nonatomic, assign) BOOL showsCancelButtonWhileSearching;

/** 点击 search 即为结束搜索，默认为YES */
@property (nonatomic, assign) BOOL keyboardAutoHide;

@end

SIGNAL_DECL(kSignalSearchStarting) @"::ui::search::starting";
SIGNAL_DECL(kSignalSearchStart) @"::ui::search::start";
SIGNAL_DECL(kSignalSearchEnding) @"::ui::search::ending";
SIGNAL_DECL(kSignalSearchEnd) @"::ui::search::end";
SIGNAL_DECL(kSignalSearchString) @"::ui::search::string";
SIGNAL_DECL(kSignalSearchScope) @"::ui::search::scope";

/** 使用系统标准的 search 体系来搜索
 */
@interface UISystemSearchBarController : UIViewControllerExt
<UITableViewDelegateExt, UITableViewDataSourceExt>

/** 用来显示结果的vc */
@property (nonatomic, assign) UIViewController* contentsViewController;

/** 承载结果显示的table */
@property (nonatomic, readonly) UITableView* tableView;

/** 生成结果用类 */
@property (nonatomic, assign) Class classForItem;

/** 搜索条 */
@property (nonatomic, readonly) UISearchBarExt* searchBar;

/** 获得到绑定的navi **/
- (id)bindedNavigationController;

@end

@class UIViewControllerStack;

/** 自定义子页面的通用 searchbar，使用此类不需要先用一个 vc 包裹，只是需要注意一些信号的使用
 */
@interface UIUnifiedSearchBar : UIViewExt

// 内部使用 searchbar
@property (nonatomic, readonly) UISearchBarExt *searchBar;

// 显示所在的 content-vc，如果为 nil，则显示在 top 上
@property (nonatomic, assign) UIViewController *contentViewController;

// 用于显示自定义页面的堆栈
@property (nonatomic, readonly) UIViewControllerStack *stackController;

// 是否已经激活
@property (nonatomic, assign) BOOL actived;

// 是否预定义 searchbar 的高度，默认为 0，代表全拉伸
@property (nonatomic, assign) CGFloat heightForSearchBar;

// 一些快速属性
@property (nonatomic, copy) NSString* placeholder;

@end

/** 自定义子页面的 searchbar vc，使用此类主要只做初始状态就为选中搜索状态的业务
 */
@interface UIUnifiedSearchBarController : UIViewControllerExt

@property (nonatomic, readonly) UIUnifiedSearchBar* searchBar;

@end

// 输入时闪动的指示符
@interface UICaretIdentifier : UIViewExt

// 颜色
@property (nonatomic, retain) UIColor* color;

// 是否闪烁
@property (nonatomic, assign) BOOL blink;

@end

// 提供模糊效果
@interface UIBlurView : UIViewExt

// 模糊参数
@property (nonatomic, retain) CGBlur* blur;

// 设置用来跟踪模糊的view
@property (nonatomic, assign) UIView* viewForBlur;

@end

// 系统实现的动态模糊效果，ios6不支持，将只用一个简单模糊覆盖掉
@interface UISyncBlurView : UIViewExt

// 模糊参数
@property (nonatomic, retain) CGBlur* blur;

@end

// 标签
@interface UISegmentedControl (extension)

@end

@interface UISegmentedControlExt : UISegmentedControl

@end

// 工具条
@interface UIToolbar (extension)
@end

// 带内容页面的工具条，一般用来弹出
@interface UIToolbarPanel : UIViewExt

// 上半部分的toolbar
@property (nonatomic, readonly) UIToolbar* toolbar;

// 下半部分的内容页面
@property (nonatomic, retain) UIView* contentView;

+ (instancetype)panelWithView:(UIView*)view;
- (id)initWithView:(UIView*)view;

@end

// 滑动条
@interface UISlider (extension)

// 设置进度
- (void)setPercentage:(NSPercentage*)prc;
- (NSPercentage*)percentage;

@end

// 进度显示
@interface UIProgressView (extension)

+ (instancetype)progressViewStyle:(UIProgressViewStyle)style;
+ (instancetype)Default;
+ (instancetype)Toolbar;

// 设置进度
- (void)setPercentage:(NSPercentage*)prc;
- (NSPercentage*)percentage;

@end

// 数值拾取
@interface UIPickerView (extension)

@end

@interface UIPickerViewExt : UIPickerView
<UIPickerViewDataSource, UIPickerViewDelegate>

// 直接赋值的各个栏位的数据，二维数组，第一维是栏位，第二维是各栏数据，数据为 UIString
@property (nonatomic, retain) NSArray *datas;

// 尺寸，数据为 NSSize
@property (nonatomic, retain) NSArray *sizes;

// selected，数据为 number 的列表
@property (nonatomic, retain) NSArray *selected;

// 使用 xx.xx.xx 的格式来设置选中
@property (nonatomic, retain) NSString *selectedString;

// 当前选中的data
@property (nonatomic, retain) NSArray *selectedDatas;

@end

@protocol UIStackAnimation <NSObject>

// 实现两个页面之间切换的动画，正向
// reverse 代表的是正向还是反向（对应于pop或者push）
- (void)stackAnimatesfrom:(UIView*)from to:(UIView*)to reverse:(BOOL)reverse;

@optional

// 是否激活此动画，默认为 YES，用于动画只用在某类情况，而其他类情况不适用动画
@property (nonatomic, assign) BOOL ignoreParticularAnimation;

@end

// ViewController的堆栈
@interface UIViewControllerStack : UIViewControllerExt
<UIStackAnimation>

// 所有的vc
@property (nonatomic, readonly) NSArray *viewControllers;

// 当前的 vc
@property (nonatomic, readonly) UIViewController *visibledViewController;

// 动画的代理
@property (nonatomic, assign) id<UIStackAnimation> animationDelegate;

- (void)pushViewController:(UIViewController*)vc animated:(BOOL)animated;
- (UIViewController*)popViewControllerWithAnimated:(BOOL)animated;

- (void)pushViewController:(UIViewController*)vc;
- (void)pushViewControllerNonAnimated:(UIViewController*)vc;
- (UIViewController*)popViewController;
- (UIViewController*)popViewControllerNonAnimated;

- (void)popToViewController:(UIViewController*)vc animated:(BOOL)animated;
- (void)popToViewControllerAtIndex:(NSInteger)idx animated:(BOOL)animated;
- (void)popToRootViewController;
- (void)popToRootViewControllerNonAnimated;

// 移除对应下标的vc
- (UIViewController*)removeViewControllerAtIndex:(NSInteger)idx;

@end

@interface UIViewStack : UIViewExt
<UIStackAnimation>

// 动画的代理
@property (nonatomic, assign) id<UIStackAnimation> animationDelegate;

@property (nonatomic, readonly) NSArray *views;

- (void)pushView:(UIView*)view animated:(BOOL)animated;
- (UIView*)popViewWithAnimated:(BOOL)animated;

- (void)pushView:(UIView*)view;
- (void)pushViewNonAnimated:(UIView*)view;
- (UIView*)popView;
- (UIView*)popViewNonAnimated;

- (UIView*)removeViewAtIndex:(NSInteger)idx;

@end

@interface UISketchView : UIViewExt

@property (nonatomic, retain) CGSketch *sketch;

- (void)clear;

@end

typedef enum {
    kUIPanelPatternTypeSingle,
    kUIPanelPatternTypeHeader,
    kUIPanelPatternTypeBody,
    kUIPanelPatternTypeFooter,
} UIPanelPatternType;

extern BOOL UIPanelPatternTypeHasBottomEdge(UIPanelPatternType ty);

// panel 组合 pattern，比如 cell，含有4个状态：只有一个，头尾，头中尾，共4张图片，根据行数的不同需要自动选择背景
@interface UITablePanelPattern : NSObject

// 必须是 patterntype 和 image 的对应
- (id)initWithPatterns:(NSDictionary*)dict;
+ (instancetype)patterns:(NSDictionary*)dict;

// 返回单元格的背景
- (UIImage*)cellImageAtIndexPath:(NSIndexPath*)ip;
- (void)setPattern:(void(^)(UIPanelPatternType, UIImage*))block atIndexPath:(NSIndexPath*)ip;

@property (nonatomic, retain) NSDictionary *patterns;
@property (nonatomic, assign) UITableView *tableView;

@end

@interface UITableView (panel_pattern)

@property (nonatomic, retain) UITablePanelPattern *panelPattern;

@end

// 用于生成遮罩的视图栈
@interface UIMaskStackView : UIViewExt

// 按照 FILO 的原则
@property (nonatomic, retain) NSArray* maskViews;
@property (nonatomic, retain) NSArray* normalViews;

// 添加一个 mask
- (void)addMask:(UIView*)view;

// 添加一个普通的
- (void)addNormal:(UIView*)view;

@end

// 拖动的管理器
@interface UIDragManager : NSObjectExt

- (void)add:(UIView*)view;
- (void)remove:(UIView*)view;

@end

/** 添加过渡效果 */
@interface UITransition : NSObjectExt

/** 部分动画需要一个目标 view 作为目的承载 */
@property (nonatomic, retain) UIView *view;

/** 持续时间 */
@property (nonatomic, assign) NSTimeInterval duration;

/** 动画的类型 */
@property (nonatomic, assign) NSString *type;

/** 动画的方向 */
@property (nonatomic, assign) NSString *direction;

/** 动画的动作 */
@property (nonatomic, assign) NSString *mode;

@end

// 类型参数
extern NSString* const kUITransitionSlide;
extern NSString* const kUITransitionCrossDissolve;
extern NSString* const kUITransitionFlip;
extern NSString* const kUITransitionCurl;
extern NSString* const kUITransitionRipple; // 水滴
extern NSString* const kUITransitionSuck; // 吸入
extern NSString* const kUITransitionCube; // 立方体
extern NSString* const kUITransitionCameraIris; // 镜头

// 方向参数
extern NSString* const kUITransitionFromLeft;
extern NSString* const kUITransitionFromRight;
extern NSString* const kUITransitionFromTop;
extern NSString* const kUITransitionFromBottom;
extern NSString* const kUITransitionFront; // 从前面开始
extern NSString* const kUITransitionRear; // 从后面开始

// 动作参数
extern NSString* const kUITransitionOpen; // 打开
extern NSString* const kUITransitionClose; // 关闭
extern NSString* const kUITransitionPush; // 新的把旧的推开
extern NSString* const kUITransitionMovein; // 新的位于旧的之上
extern NSString* const kUITransitionReveal; // 将旧的推开

@interface UIView (transition)

/** 添加动画 */
- (void)addTransition:(UITransition*)trans;

@end

/** 给 View 增加跑马灯的效果 */
@interface UIMarqueeWrapper : UIViewWrapper

/** 动画的速度，px/s */
@property (nonatomic, assign) float speed;

@end

# endif
