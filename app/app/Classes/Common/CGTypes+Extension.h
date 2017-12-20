
# ifndef __CGTYPESEXTENSION_9C30CBAC689C4CF9B790D56E59B2BE87_H_INCLUDED
# define __CGTYPESEXTENSION_9C30CBAC689C4CF9B790D56E59B2BE87_H_INCLUDED

# import "Compiler.h"
# import "NSTypes+Extension.h"

CC_WARNING_PUSH
CC_WARNING_DISABLE(-Wunused-function)

C_BEGIN

extern CGFloat CGHeightMax, CGWidthMax;

typedef enum {
    kCGDirectionUnknown = 0x0,
    
    kCGDirectionFromLeft = 0x1,
    kCGDirectionFromRight = 0x2,
    kCGDirectionFromTop = 0x10,
    kCGDirectionFromBottom = 0x20,
    
    kCGDirectionCenter = 0x100,
    
    kCGDirectionHorizontal = kCGDirectionFromLeft | kCGDirectionFromRight,
    kCGDirectionVertical = kCGDirectionFromTop | kCGDirectionFromBottom,
    
    kCGDirectionToRight = kCGDirectionFromLeft,
    kCGDirectionToLeft = kCGDirectionFromRight,
    kCGDirectionToBottom = kCGDirectionFromTop,
    kCGDirectionToTop = kCGDirectionFromBottom,
    
} CGDirection;

static BOOL CGDirectionIsHorizontal(CGDirection dir) {
    return [NSMask Mask:kCGDirectionFromLeft Value:dir] ||
    [NSMask Mask:kCGDirectionFromRight Value:dir];
}

static BOOL CGDirectionIsVertical(CGDirection dir) {
    return [NSMask Mask:kCGDirectionFromTop Value:dir] ||
    [NSMask Mask:kCGDirectionFromBottom Value:dir];
}

@interface NSSize : NSObject

+ (id)size:(CGSize)sz;
- (id)initWithSize:(CGSize)sz;

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat width, height;

- (BOOL)isEqual:(id)object;

@end

@interface NSPoint : NSObject

+ (instancetype)point:(CGPoint)pt;
- (id)initWithPoint:(CGPoint)pt;

@property (nonatomic, assign) CGPoint point;

+ (instancetype)randomPointInRect:(CGRect)rc;
- (instancetype)intergral;

@end

@interface NSRect : NSObject

+ (id)rect:(CGRect)rc;
- (id)initWithRect:(CGRect)rc;

@property (nonatomic, assign) CGRect rect;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat x, y, width, height;
@property (nonatomic, assign) CGPoint center;

@property (nonatomic, readonly) CGFloat maxX, maxY;

// 偏移
- (NSRect*)offsetX:(CGFloat)x Y:(CGFloat)y;

// 正方形
- (NSRect*)squaredMax;
- (NSRect*)squaredMin;

// 应用ei
- (NSRect*)edgeInsets:(UIEdgeInsets)ei;

@end

# define RGB_RED(val) (((val) & 0xff0000) >> 16)
# define RGB_GREEN(val) (((val) & 0xff00) >> 8)
# define RGB_BLUE(val) ((val) & 0xff)
# define RGB_VALUE(r, g, b) (((r & 0xff) << 16) | ((g & 0xff) << 8) | (b & 0xff))

# define ARGB_ALPHA(val) (((val) & 0xff000000) >> 24)
# define ARGB_RED RGB_RED
# define ARGB_GREEN RGB_GREEN
# define ARGB_BLUE RGB_BLUE
# define ARGB_VALUE(a, r, g, b) (((a & 0xff) << 24) | ((r & 0xff) << 16) | ((g & 0xff) << 8) | (b & 0xff))

# define RGBA_ALPHA(val) ((val) & 0xff)
# define RGBA_RED(val) (((val) & 0xff000000) >> 24)
# define RGBA_GREEN(val) (((val) & 0xff0000) >> 16)
# define RGBA_BLUE(val) (((val) & 0xff00) >> 8)
# define RGBA_VALUE(r, g, b, a) (((r & 0xff) << 24) | ((g & 0xff) << 16) | ((b & 0xff) << 8) | (a & 0xff))

extern int RGB_BLEACH(int, float);
extern int COLOR_COMPONENT_BLEACHd(int, float);

extern const float FLOAT_1_255;

# define RGB2FLOAT(val) ((val) * FLOAT_1_255)
# define FLOAT2RGB(val) ((int)((val) * 255) & 0xff)

@interface CGDesigner : NSObject

+ (CGFloat)Height:(CGFloat)val;
+ (CGFloat)Width:(CGFloat)val;
+ (CGSize)Size:(CGSize)sz;
+ (CGPoint)Point:(CGPoint)pt;
+ (CGRect)Rect:(CGRect)rc;

# ifdef PADDING_DEFINED

+ (CGPadding)Padding:(CGPadding)pd;

# endif

@end

typedef struct _CGClipRect
{
    CGRect full, work;
} CGClipRect;

extern const CGFloat CGVALUEMAX;
extern CGRect CGRectMax;
extern CGSize CGSizeMax;
extern CGPoint CGPointMax;

extern CGPoint CGPointAddPoint(CGPoint, CGPoint);
extern CGPoint CGPointSubPoint(CGPoint, CGPoint);
extern CGPoint CGRectCenter(CGRect);
extern CGPoint CGSizeCenter(CGSize);
extern CGSize CGSizeIntegral(CGSize);
extern CGSize CGSizeBBXIntegral(CGSize);
extern CGSize CGSizeAdd(CGSize, CGFloat w, CGFloat h);
extern CGSize CGSizeAddPoint(CGSize, CGPoint);
extern CGSize CGSizeSubPoint(CGSize, CGPoint);
extern CGSize CGSizeAddSize(CGSize, CGSize);
extern CGSize CGSizeDeflate(CGSize, CGFloat x, CGFloat y);
extern CGSize CGSizeScale(CGSize, CGFloat);
extern CGFloat CGSizeAspectRatio(CGSize);
extern CGFloat CGFloatIntegral(CGFloat);
extern CGPoint CGPointIntegral(CGPoint);
extern CGRect CGRectIntegralEx(CGRect);
extern CGRect CGRectMakeWithSize(CGSize);
extern CGRect CGRectMakeWithPointAndSize(CGPoint, CGSize);
extern CGRect CGRectMakeFromPointInflate(CGPoint, CGFloat x, CGFloat y);
extern CGRect CGRectDeflate(CGRect, CGFloat x, CGFloat y);
extern CGRect CGRectDeflateWithRatio(CGRect, CGFloat dx, CGFloat dy);
extern CGRect CGRectMultiply(CGRect, CGFloat x, CGFloat y, CGFloat w, CGFloat h);
extern CGRect CGRectScale(CGRect, CGFloat);
extern CGRect CGRectAdd(CGRect, CGFloat x, CGFloat y, CGFloat w, CGFloat h);
extern CGRect CGRectAddSize(CGRect, CGFloat w, CGFloat h);
extern CGRect CGRectCutSize(CGRect, CGFloat w, CGFloat h);
extern CGRect CGRectClipCenterBySize(CGRect, CGSize);
extern CGRect CGRectSetSize(CGRect, CGSize);
extern CGRect CGRectSetWidth(CGRect, CGFloat);
extern CGRect CGRectSetHeight(CGRect, CGFloat);
extern CGRect CGRectSetCenter(CGRect, CGPoint);
extern CGRect CGRectSetX(CGRect, CGFloat);
extern CGRect CGRectSetY(CGRect, CGFloat);
extern CGFloat CGRectGetX(CGRect);
extern CGFloat CGRectGetY(CGRect);
extern CGRect CGRectSetPoint(CGRect, CGPoint);
extern CGRect CGRectOffsetByPoint(CGRect, CGPoint);
extern BOOL CGRectContainsX(CGRect, CGFloat);
extern BOOL CGRectContainsY(CGRect, CGFloat);
extern CGPoint CGRectLeftTop(CGRect);
extern CGPoint CGRectRightTop(CGRect);
extern CGPoint CGRectLeftBottom(CGRect);
extern CGPoint CGRectRightBottom(CGRect);
extern CGPoint CGRectLeftCenter(CGRect);
extern CGPoint CGRectRightCenter(CGRect);
extern CGPoint CGRectTopCenter(CGRect);
extern CGPoint CGRectBottomCenter(CGRect);
extern CGPoint CGRectGetAnchorPoint(CGRect, CGPoint);
extern CGPoint CGPointOffset(CGPoint, CGFloat x, CGFloat y);
extern CGPoint CGPointOffsetByPoint(CGPoint, CGPoint);
extern CGPoint CGPointMultiply(CGPoint, CGFloat x, CGFloat y);
extern CGPoint CGPointSetX(CGPoint, CGFloat);
extern CGPoint CGPointSetY(CGPoint, CGFloat);
extern CGPoint CGPointScale(CGPoint, CGFloat);
extern CGPoint CGRectGetMinPoint(CGRect);
extern CGPoint CGRectGetMaxPoint(CGRect);
extern CGPoint UIEdgeInsetsInsetPoint(CGPoint, UIEdgeInsets);
extern CGSize UIEdgeInsetsInsetSize(CGSize, UIEdgeInsets);
extern BOOL CGSizeContainSize(CGSize, CGSize);
extern CGSize CGSizeSetWidth(CGSize, CGFloat);
extern CGSize CGSizeSetHeight(CGSize, CGFloat);
extern CGSize CGSizeMultiply(CGSize, CGFloat w, CGFloat h);
extern CGRect CGRectApplyOffset(CGRect, CGPoint);
extern CGClipRect CGSizeMapInSize(CGSize, CGSize, UIViewContentMode);
extern CGSize CGSizeMapInWidth(CGSize, CGFloat);
extern CGSize CGSizeMapInHeight(CGSize, CGFloat);
extern CGSize CGImageGetSize(CGImageRef);
extern CGSize CGSizeFromPoint(CGPoint);
extern CGPoint CGPointFromSize(CGSize);

typedef enum {
    kCGEdgeMax,
    kCGEdgeMin,
} CGEdgeType;
extern CGSize CGSizeSquare(CGSize, CGEdgeType);
extern CGRect CGRectSquare(CGRect, CGEdgeType);

# ifdef PADDING_DEFINED

extern CGFloat CGPaddingHeight(CGPadding);
extern CGFloat CGPaddingWidth(CGPadding);
extern CGRect CGRectApplyPadding(CGRect, CGPadding);
extern CGRect CGRectUnapplyPadding(CGRect, CGPadding);
extern CGSize CGSizeApplyPadding(CGSize, CGPadding);
extern CGSize CGSizeUnapplyPadding(CGSize, CGPadding);
extern CGPadding CGPaddingSetTop(CGPadding, CGFloat);
extern CGPadding CGPaddingSetBottom(CGPadding, CGFloat);
extern CGPadding CGPaddingSetLeft(CGPadding, CGFloat);
extern CGPadding CGPaddingSetRight(CGPadding, CGFloat);
extern CGPadding CGPaddingSetLeftRight(CGPadding, CGFloat l, CGFloat r);
extern CGPadding CGPaddingSetTopBottom(CGPadding, CGFloat t, CGFloat b);
extern CGPadding CGPaddingMultiply(CGPadding, CGFloat t, CGFloat b, CGFloat l, CGFloat r);
extern CGPadding CGPaddingAddPadding(CGPadding, CGPadding);
extern CGPadding CGPaddingAdd(CGPadding, CGFloat t, CGFloat b, CGFloat l, CGFloat r);
extern CGPadding CGPaddingMakeSize(CGFloat w, CGFloat h);
extern BOOL CGPaddingEqualToPadding(CGPadding, CGPadding);

@interface NSPadding : NSObject

+ (instancetype)padding:(CGPadding)pad;

@property (nonatomic, assign) CGPadding padding;

@end

# endif

# ifdef MARGIN_DEFINED

extern CGRect CGRectApplyMargin(CGRect, CGMargin);

# endif

@interface CGShadow : NSObject <NSCopying>

@property CGColorRef color;
@property float opacity;
@property CGSize offset;
@property CGFloat radius;
@property BOOL hidden;

+ (CGShadow*)Normal;
+ (CGShadow*)LeftEdge;
+ (CGShadow*)RightEdge;
+ (CGShadow*)RightBottomEdge;
+ (CGShadow*)TopEdge;
+ (CGShadow*)BottomEdge;
+ (CGShadow*)Clear;
+ (CGShadow*)Around;

- (instancetype)shadowWithColor:(CGColorRef)color;
- (instancetype)shadowWithOpacity:(float)opacity;
- (instancetype)shadowWithRadius:(CGFloat)radius;
- (instancetype)shadowWithOpacity:(float)opacity radius:(CGFloat)radius;

- (void)setIn:(CALayer*)layer;
- (void)setInContext:(CGContextRef)ctx;

@end

// 模糊
@interface CGBlur : NSObject <NSCopying>

@property CGFloat radius;
@property CGColorRef tintColor;
@property CGFloat saturation;

+ (instancetype)Subtle;
+ (instancetype)Light;
+ (instancetype)ExtraLight;
+ (instancetype)Dark;

- (instancetype)blurWithColor:(CGColorRef)color;
- (instancetype)blurWithSaturation:(CGFloat)sa;

@end

// 特效
@interface CGFilter : NSObject <NSCopying>

// 自定义的特效处理，需要实现该函数
- (void)processImage:(CGImageRef)image inContext:(CGContextRef)context;

@end

// 特换颜色
@interface CGFilterColorReplace : CGFilter
@property CGColorRef color;
@end

// 灰度化
@interface CGFilterGrayscale : CGFilterColorReplace
@end

// 蒙上颜色
@interface CGFilterTintColor : CGFilter
@property CGColorRef color;
@end

struct CGPoint3d
{
    CGFloat x;
    CGFloat y;
    CGFloat z;
};
typedef struct CGPoint3d CGPoint3d;

@interface NSPoint3d : NSObject <NSCopying>

+ (instancetype)point3d:(CGPoint3d)pt;
- (id)initWithPoint3d:(CGPoint3d)pt;

@property (nonatomic, assign) CGPoint3d point3d;

- (void)multiply:(CGFloat)v;
- (void)multiplyByPoint:(CGPoint3d)pt;
- (instancetype)pointMultiply:(CGFloat)v;
- (instancetype)pointMultiplyByPoint:(CGPoint3d)pt;

@end

CGPoint3d CGPointMake3d(CGFloat x, CGFloat y, CGFloat z);
CGPoint3d CGPoint3dFromPoint(CGPoint pt, CGFloat z);
CATransform3D CGTransform3DRotationFromPoint(CGPoint3d pt);

@interface CGLine : NSObject

// 线的阴影
@property (nonatomic, retain) CGShadow *shadow;

// 线的颜色，默认为nil
@property CGColorRef color;

// 线宽，默认为1
@property CGFloat width;

// 尖头
@property CGLineCap cap;

// 连接点
@property CGLineJoin join;

// 部分绘制中需要一个偏移量，比如下划线
@property CGPoint offset;

+ (instancetype)lineWithColor:(CGColorRef)color;
+ (instancetype)lineWithWidth:(CGFloat)width;
+ (instancetype)lineWithColor:(CGColorRef)color width:(CGFloat)width;
+ (instancetype)BadgeEdgeLine;
+ (instancetype)BottomLine;

- (void)setIn:(CGContextRef)context;
- (void)drawLineFrom:(CGPoint)from to:(CGPoint)to inContext:(CGContextRef)context;

@end

// 采用欧拉几何坐标系
@interface CGAngle : NSObject {
    CGFloat _rad;
}

@property (nonatomic, readonly) CGFloat value;

// 不经过任何转换
+ (instancetype)Angle:(CGFloat)ang;
+ (instancetype)Rad:(CGFloat)rad;

// 自动调整坐标系
+ (instancetype)RegularDegree:(CGFloat)deg;
+ (instancetype)RegularRad:(CGFloat)rad;

- (instancetype)angleAddDegree:(CGFloat)deg;
- (instancetype)angleAddRad:(CGFloat)rad;
- (id)addDegree:(CGFloat)deg;
- (id)addRad:(CGFloat)rad;

+ (CGFloat)Degree2Rad:(CGFloat)deg;
- (CGFloat)distance:(CGAngle*)r;

@end

@class CGGraphic;

@interface CGPen : NSObject

@property CGColorRef color; // 前景
@property CGColorRef backgroundColor; // 背景，有些画法需要将路径上没有绘制到的地方用背景颜色描一下，通常为 nil 并且不被使用
@property CGFloat width;
@property CGLineCap cap;
@property CGLineJoin join;

+ (instancetype)Pen:(CGColorRef)color width:(CGFloat)width;

- (void)setIn:(CGGraphic*)gra;
- (void)setInContext:(CGContextRef)ctx;

// 描边
- (void)strokeIn:(CGGraphic*)gra;
- (void)strokeInContext:(CGContextRef)ctx;

@end

@interface CGBrush : NSObject

- (void)setIn:(CGGraphic*)gra;
- (void)setInContext:(CGContextRef)ctx;

// 填充对象
- (void)fillIn:(CGGraphic*)gra;
- (void)fillInContext:(CGContextRef)ctx;

@end

@interface CGSolidBrush : CGBrush

// 单色刷子
@property CGColorRef color;

+ (instancetype)Brush:(CGColorRef)color;

@end

@interface _CGGradientBrush : CGBrush

// 添加颜色和对应的位置
- (void)addColor:(CGColorRef)color;

@end

// 线性过渡刷
@interface CGLinearGradientBrush : _CGGradientBrush

// 起始位置
@property CGPoint start, end;

@end

// 中心过渡刷
@interface CGRadialGradientBrush : _CGGradientBrush

// 通过两点来设置
@property (nonatomic, assign) CGPoint start, end;
@property (nonatomic, assign) CGFloat startRadius, endRadius;

// 通过一点来设置
@property (nonatomic, assign) CGPoint center;
@property (nonatomic, assign) CGFloat radius;

// 使用矩形来设置
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGRect rect;

@end

// 色块刷
@interface CGPatternBrush : CGBrush

@end

@interface CGMatrix : NSObject

+ (instancetype)Translate:(CGPoint)val;
+ (instancetype)scale:(CGPoint)val;
+ (instancetype)Rotate:(CGAngle*)val;

@property (nonatomic, assign) CGAffineTransform t;

// 方便拿出指针的形式
@property (nonatomic, readonly) CGAffineTransform* pT;

- (void)setIn:(CGGraphic*)gra;
- (void)setInContext:(CGContextRef)ctx;

// 应用
- (void)transform:(CGGraphic*)gra;
- (void)transformInContext:(CGContextRef)ctx;

// 变换
- (id)translate:(CGPoint)val;
- (id)scale:(CGPoint)val;
- (id)rotate:(CGAngle*)val;

@end

@interface CGPicture : NSObject

+ (instancetype)image:(CGImageRef)image;

@property (nonatomic) CGImageRef image;

// 默认为中心点
@property (nonatomic, assign) CGPoint anchorPoint;

// 绘制
- (void)drawIn:(CGGraphic*)gra;
- (void)drawInContext:(CGContextRef)ctx;

@end

@interface NSString (textstyle)

- (CGPoint)adjustPosition:(CGPoint)pos anchorPoint:(CGPoint)anchorPoint withFont:(UIFont*)font;

@end

@interface CGTextStyle : NSObject

+ (instancetype)Font:(UIFont*)font;

// 使用的字体
@property (nonatomic, retain) UIFont *font;

// 对齐方式，默认为左对齐
//@property (nonatomic, assign) NSTextAlignment textAlignment;

// 锚点，默认为原点
@property (nonatomic, assign) CGPoint anchorPoint;

- (void)setIn:(CGGraphic*)gra;

// 取得string的尺寸
- (CGSize)sizeOf:(NSString*)str;
- (CGFloat)widthOf:(NSString*)str;
- (CGFloat)heightOf:(NSString*)str;

@end

@interface CGCanvasPage : NSObject

@property (nonatomic, retain) CGMatrix* matrix;

// 设置起点
- (instancetype)move:(CGPoint)pt;

// 绘制线段，如果没有设置起点则自动设置第一个点为起点
- (instancetype)line:(CGPoint)pt;

// 关闭子路径
- (instancetype)commit;

// 4次样条曲线
- (instancetype)curveQuad:(CGPoint)pos control:(CGPoint)control;

// 样条曲线
- (instancetype)curve:(CGPoint)pos a:(CGPoint)a b:(CGPoint)b;

// 椭圆
- (instancetype)ellipse:(CGRect)rect;
- (instancetype)ellipse:(CGPoint)center radius:(CGFloat)radius;

// 矩形
- (instancetype)rect:(CGRect)rect;
- (instancetype)rect:(CGRect)rect roundradius:(CGFloat)roundradius;

// 曲线
- (instancetype)arc:(CGPoint)center radius:(CGFloat)radius from:(CGAngle*)from delta:(CGFloat)delta;
- (instancetype)arc:(CGPoint)center radius:(CGFloat)radius from:(CGAngle*)from to:(CGAngle*)to clockwise:(BOOL)clockwise;
- (instancetype)arc:(CGFloat)radius start:(CGPoint)start end:(CGPoint)end;

@end

@interface CGBezier : NSObject

- (instancetype)move:(CGPoint)pt;
- (instancetype)curve:(CGPoint)pos a:(CGPoint)a b:(CGPoint)b;
- (instancetype)line:(CGPoint)pt;
- (instancetype)commit;
- (void)clip;

@end

@interface CGGraphic : NSObject

@property (nonatomic, readonly) CGContextRef context;
@property (nonatomic, readonly) NSRect* bbx;
@property (nonatomic, readonly) CGRect bounds;

- (instancetype)initWithContext:(CGContextRef)ctx;
+ (instancetype)graphicWithContext:(CGContextRef)ctx;

+ (instancetype)Current;
+ (instancetype)Current:(CGRect)rc;

// 反转
- (instancetype)reverse;
- (instancetype)reversex;
- (instancetype)reversey;

// 放置到点
- (instancetype)move:(CGPoint)pt;

// 绘制线段
- (instancetype)line:(CGPoint)pt pen:(CGPen*)pen;

// 增加一堆线段
- (instancetype)lines:(CGPoint const*)pts count:(NSInteger)count;

// 填充内部的图元
- (instancetype)rect:(CGRect)rc pen:(CGPen*)pen brush:(CGBrush*)br;
- (instancetype)rect:(CGRect)rc roundradius:(CGFloat)roundradius pen:(CGPen*)pen brush:(CGBrush*)br;

// 绘制圆
- (instancetype)ellipse:(CGRect)rc pen:(CGPen*)pen brush:(CGBrush*)br;

// 绘制曲线
- (instancetype)arc:(CGPoint)center radius:(CGFloat)radius start:(CGAngle*)start end:(CGAngle*)end clockwise:(BOOL)clockwise pen:(CGPen*)pen brush:(CGBrush*)br;
- (instancetype)arc:(CGPoint)center radius:(CGFloat)radius start:(CGAngle*)start angle:(CGAngle*)angle clockwise:(BOOL)clockwise pen:(CGPen*)pen brush:(CGBrush*)br;
- (instancetype)arc:(CGFloat)radius from:(CGPoint)from to:(CGPoint)to pen:(CGPen*)pen brush:(CGBrush*)br;

// 绘制路径
- (instancetype)path:(void(^)(CGGraphic* graphic))block;

// 绘制层
- (instancetype)layer:(void(^)(CGGraphic* graphic))block shadow:(CGShadow*)shadow;

// 填充
- (instancetype)fill:(CGBrush*)br;

// 描边
- (instancetype)stroke:(CGPen*)pen;

// 绘制文字
- (instancetype)text:(NSString*)text position:(CGPoint)position brush:(CGBrush*)br style:(CGTextStyle*)font;
- (instancetype)text:(NSString*)text position:(CGPoint)position anchor:(CGPoint)anchor brush:(CGBrush*)br style:(CGTextStyle*)font;

// 绘制图片
- (instancetype)picture:(CGPicture*)img position:(CGPoint)position;
- (instancetype)picture:(CGPicture*)img position:(CGPoint)position transform:(CGMatrix*)mat;

// 绘制一页图元
- (instancetype)stroke:(CGCanvasPage*)page pen:(CGPen*)pen;
- (instancetype)fill:(CGCanvasPage*)page brush:(CGBrush*)brush;

// 完成一次绘图
- (instancetype)perform;
- (instancetype)clip:(CGRect)rc;

// 状态保存
- (instancetype)push;
- (instancetype)pop;

// 转换
@property (nonatomic, assign) CGMatrix* matrix;
- (instancetype)transform:(CGMatrix*)matrix;

@end

@interface CGPrimitive : NSObject

/** 重置 */
- (void)reset;

/** 渲染 */
- (void)render:(CGGraphic*)graphic;

/** 基础的笔触 */
@property (nonatomic, retain) CGPen *pen;

/** 基础的笔刷 */
@property (nonatomic, retain) CGBrush *brush;

@end

@interface CGPrimitiveLine : CGPrimitive

/** 线段上的所有点 */
@property (nonatomic, retain) NSMutableArray *points;

/** 增加一个点 */
- (void)add:(CGPoint)pt;

@end

@interface CGPrimitivePolygon : CGPrimitiveLine

@end

@interface CGPrimitives : NSObject

/** 所有的图元 */
@property (nonatomic, retain) NSMutableArray* primitives;

/** 增加一个图元 */
- (void)addObject:(CGPrimitive*)obj;

/** 绘制 */
- (void)render:(CGGraphic*)graphic;

/** 清空 */
- (void)clear;

@end

@interface CGSketch : NSObject

@property (nonatomic, retain) CGPen *pen;
@property (nonatomic, retain) CGBrush *brush;
@property (nonatomic, retain) CGMatrix *matrix;
@property (nonatomic, retain) CGPrimitives *primitives;

/** 添加图元 */
- (void)add:(CGPrimitive*)prim;

/** 绘图 */
- (void)renderInContext:(CGContextRef)ctx;
- (void)renderInGraphic:(CGGraphic*)gra;

/** 清空图元 */
- (void)clear;

@end

# define M_2PI    6.28318530717958623
# define M_1_2PI  0.15915494309189535
# define M_DEGREE 0.0174532925199432951

CC_WARNING_POP

C_END

# endif
