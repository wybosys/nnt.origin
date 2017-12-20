
# ifndef __NNT_LAYOUT_84B5BEEF93E74173B396DE010F50D79B_H_INCLUDED
# define __NNT_LAYOUT_84B5BEEF93E74173B396DE010F50D79B_H_INCLUDED

@class Layout;
@class LayoutVBox;
@class LayoutHBox;

# ifndef PADDING_DEFINED
# define PADDING_DEFINED
typedef struct _CGPadding {
    float top, bottom, left, right;
} CGPadding;
# endif

# ifndef MARGIN_DEFINED
# define MARGIN_DEFINED
typedef struct _CGMargin {
    float top, bottom, left, right;
} CGMargin;
# endif

extern CGPadding CGPaddingZero;
extern CGMargin CGMarginZero;

extern CGPadding CGPaddingMake(float t, float b, float l, float r);
extern CGMargin CGMarginMake(float t, float b, float l, float r);

@interface Linear : NSObject {
    int _full, _relv;
    NSMutableArray* _segs;
    bool _changed;
    int _iter;
    bool _priority;
}

@property (nonatomic, assign) CGFloat flexValue, minFlexValue;

+ (id)linearWithLayout:(Layout*)layout;

- (id)initWithLayout:(Layout*)layout;
- (id)initWithVBoxLayout:(LayoutVBox*)layout;
- (id)initWithHBoxLayout:(LayoutHBox*)layout;
- (void)resetLinearByLayout:(Layout*)layout;

- (id)addFlex:(float)flex;
- (id)addPixel:(float)pixel;
- (id)addAspectWithX:(float)x andY:(float)y;

- (BOOL)started;
- (float)start;
- (float)next;
- (float)prev;
- (void)stop;

@end

@interface Layout : NSObject {
    CGRect _rc_origin, _rc_work;
    float _offset_x, _offset_y;
    CGMargin _margin;
    CGPadding _padding;
    float _space;
}

@property (nonatomic, readonly) CGRect rect, originRect;
@property (nonatomic, readonly) CGPoint position;
@property (nonatomic, assign) CGMargin margin;
@property (nonatomic, assign) CGPadding padding;

+ (id)layoutWithRect:(CGRect)rc withSpacing:(CGFloat)space;
- (id)initWithRect:(CGRect)rc withSpacing:(CGFloat)space;
- (void)reset;
- (CGRect)addLinear:(Linear*)lnr;
- (CGRect)stridePixel:(float)pixel;
- (void)setSpace:(CGFloat)v;
- (void)setOriginRect:(CGRect)rc;

@end

@interface LayoutVBox : Layout

@end

@interface LayoutHBox : Layout

@end

@interface LayoutHFlow : Layout

// 当前进行到第几行
@property (nonatomic, assign) NSUInteger row;

- (CGRect)strideSize:(CGSize)size;

@end

# endif
