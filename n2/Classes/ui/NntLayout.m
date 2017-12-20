
# import "Common.h"
# import "NntLayout.h"

CGPadding CGPaddingZero;
CGMargin CGMarginZero;

CGPadding CGPaddingMake(float t, float b, float l, float r) {
    CGPadding ret = {t, b, l, r};
    return ret;
}

CGMargin CGMarginMake(float t, float b, float l, float r) {
    CGMargin ret = {t, b, l, r};
    return ret;
}

BOOL CGPaddingEqualToPadding(CGPadding l, CGPadding r)
{
    return memcmp(&l, &r, sizeof(CGPadding)) == 0;
}

float CGMarginGetWidth(CGMargin const* mg) {
    return mg->left + mg->right;
}

float CGMarginGetHeight(CGMargin const* mg) {
    return mg->top + mg->bottom;
}

float CGPaddingGetWidth(CGPadding const* pd) {
    return pd->right + pd->left;
}

float CGPaddingGetHeight(CGPadding const* pd) {
    return pd->bottom + pd->top;
}

@implementation Layout

@dynamic rect;
@synthesize margin = _margin, padding = _padding;

+ (id)layoutWithRect:(CGRect)rc withSpacing:(CGFloat)space {
    return [[[self alloc] initWithRect:rc withSpacing:space] autorelease];
}

- (id)initWithRect:(CGRect)rc withSpacing:(CGFloat)space {
    self = [super init];
    
    [self reset];
    
    if (space == 0)
    {
        _margin = CGMarginZero;
        _padding = CGPaddingZero;
        _rc_origin = _rc_work = rc;
    }
    else
    {
        [self setSpace:space];
        [self setOriginRect:rc];
    }
    
    return self;
}

- (CGRect)rect {
    return _rc_work;
}

- (CGRect)originRect {
    return _rc_origin;
}

- (void)reset {
    _offset_x = _offset_y = 0;
    _rc_work = _rc_origin;
}

- (void)setSpace:(CGFloat)v {
    float dp = v - _padding.left;
    float dm = v - _margin.top;
    
    _padding = CGPaddingMake(v, 0, v, 0);
    _margin = CGMarginMake(0, v, 0, v);
    
    _rc_work.origin.x += dp;
    _rc_work.origin.y += dm;
    _rc_work.size.width = _rc_origin.size.width - CGPaddingGetWidth(&_padding);
    _rc_work.size.height = _rc_origin.size.height - CGPaddingGetHeight(&_padding);
}

- (void)setPadding:(CGPadding)padding {
    _padding = padding;
    
    _rc_work.origin.x = _rc_origin.origin.x + padding.left;
    _rc_work.origin.y = _rc_origin.origin.y + padding.top;
    _rc_work.size.width = _rc_origin.size.width - CGPaddingGetWidth(&_padding);
    _rc_work.size.height = _rc_origin.size.height - CGPaddingGetHeight(&_padding);
}

- (void)setOriginRect:(CGRect)rc {
    _rc_origin = _rc_work = rc;
    
    // offset rect.
    if (CGPaddingEqualToPadding(_padding, CGPaddingZero) == false)
    {
        _rc_work.origin.x += _padding.left;
        _rc_work.origin.y += _padding.top;
        _rc_work.size.width -= CGPaddingGetWidth(&_padding);
        _rc_work.size.height -= CGPaddingGetHeight(&_padding);
    }
}

- (CGRect)addLinear:(Linear *)lnr {
    float pix = lnr.started ? lnr.next : lnr.start;
    return [self stridePixel:pix];
}

- (CGRect)stridePixel:(float)pixel {
    return CGRectZero;
}

- (CGPoint)position {
    return _rc_work.origin;
}

@end

@implementation LayoutVBox

- (CGRect)stridePixel:(float)pixel {
    CGRect ret;
    int height = pixel;
    _offset_y += height;
    ret.origin.x = _rc_work.origin.x + _margin.left;
    ret.origin.y = _rc_work.origin.y + _margin.top;
    _rc_work.origin.y += height;
    ret.size.width = _rc_work.size.width - _margin.left - _margin.right;
    ret.size.height = height - _margin.top - _margin.bottom;
    return ret;
}

@end

@implementation LayoutHBox

- (CGRect)stridePixel:(float)pixel {
    CGRect ret;
    int width = pixel;
    _offset_x += width;
    ret.origin.x = _rc_work.origin.x + _margin.left;
    ret.origin.y = _rc_work.origin.y + _margin.top;
    _rc_work.origin.x += width;
    ret.size.width = width - _margin.left - _margin.right;
    ret.size.height = _rc_work.size.height - _margin.top - _margin.bottom;
    return ret;
}

@end

@interface NntHFlowSegment : NSObject

@property (nonatomic, assign) CGRect rect;
@property (nonatomic, assign) NntHFlowSegment *left, *right, *top, *bottom;

@end

@implementation NntHFlowSegment

- (id)initWithRect:(CGRect)rc {
    self = [super init];
    _rect = rc;
    return self;
}

- (id)initWithSize:(CGSize)sz {
    self = [super init];
    _rect.size = sz;
    return self;
}

@end

@interface LayoutHFlow ()
{
    NSMutableArray* _segments;    
}

@end

@implementation LayoutHFlow

- (id)initWithRect:(CGRect)rc withSpacing:(CGFloat)space {
    self = [super initWithRect:rc withSpacing:space];

    _segments = [[NSMutableArray alloc] init];
    _offset_x = rc.origin.x;
    _offset_y = rc.origin.y;
    _row = 0;
    
    return self;
}

- (void)dealloc {
    [_segments release];
    [super dealloc];
}

- (void)reset {
    [super reset];
    _row = 0;
    [_segments removeAllObjects];
}

- (CGRect)strideSize:(CGSize)size {
    NntHFlowSegment* dockseg = _segments.lastObject;
    NntHFlowSegment* seg = [[NntHFlowSegment alloc] initWithSize:size];
    
    CGFloat offx = dockseg ? 0 : _offset_x;
    CGFloat offy = dockseg ? 0 : _offset_y;
    
    if (offx + size.width + CGRectGetMaxX(dockseg.rect) <= CGRectGetMaxX(_rc_origin))
    {
        // 下一个元素在该行内
        dockseg.right = seg;
        seg.left = dockseg;
        
        CGRect rc = seg.rect;
        rc.origin.x = CGRectGetMaxX(dockseg.rect) + offx;
        rc.origin.y = dockseg.rect.origin.y + offy;
        seg.rect = rc;
    }
    else
    {
        // 需要换行
        dockseg = [self l0b0Segment];
        
        dockseg.bottom = seg;
        seg.top = dockseg;
        
        CGRect rc = seg.rect;
        rc.origin.x = dockseg.rect.origin.x;
        rc.origin.y = CGRectGetMaxY(dockseg.rect);
        seg.rect = rc;
        
        ++_row;
    }
    
    [_segments addObject:seg];
    [seg release];
    
    // 设置 work 为 seg 的 rb
    _rc_work.origin.x = CGRectGetMaxX(seg.rect);
    _rc_work.origin.y = CGRectGetMaxY(seg.rect);
    
    // 计算一下应该返回的大小
    CGRect rc = seg.rect;
    rc.origin.x += self.margin.left;
    rc.size.width -= self.margin.left + self.margin.right;
    rc.origin.y += self.margin.top;
    rc.size.height -= self.margin.top + self.margin.bottom;
    
    // 根据初始的位置偏移一下，不然就变成以0点位基准，而不是传入的 rect 为基准
    rc = CGRectOffset(rc, _rc_origin.origin.x, _rc_origin.origin.y);
    return rc;
}

// 查找第一个右边=nil/下面=nil的seg
- (NntHFlowSegment*)r0b0Segment {
    for (NntHFlowSegment* each in _segments)
        if (each.right == nil && each.bottom == nil)
            return each;
    return nil;
}

// 查找第一个左边=nil/右边=nil/下面=nil的seg
- (NntHFlowSegment*)l0r0b0Segment {
    for (NntHFlowSegment* each in _segments)
        if (each.left == nil && each.right == nil && each.bottom == nil)
            return each;
    return nil;
}

// 查找第一个左边=nil/下面=nil的seg
- (NntHFlowSegment*)l0b0Segment {
    for (NntHFlowSegment* each in _segments)
        if (each.left == nil && each.bottom == nil)
            return each;
    return nil;
}

@end

enum NntLinearSegmentType {
    kNntLinearSegmentPixel,
    kNntLinearSegmentFlex,
    kNntLinearSegmentAspect,
};

@interface NntLinearSegment : NSObject {
@public
    
    enum NntLinearSegmentType type;
    union {
        float pixel;
        float flex;
    } value;
    float aspect[2];
    float result;
    void *ctx;
}

@end

@implementation NntLinearSegment

- (void)dealloc {
    [super dealloc];
}

@end

@implementation Linear

+ (id)linearWithLayout:(Layout *)layout {
    return [[[self alloc] initWithLayout:layout] autorelease];
}

- (id)init {
    self = [super init];
    
    _segs = [[NSMutableArray alloc] init];
    _minFlexValue = -9999999;
    
    return self;
}

- (void)dealloc {
    [_segs release];
    [super dealloc];
}

- (id)initWithLayout:(Layout *)layout {
    if ([layout isKindOfClass:[LayoutVBox class]])
        return [self initWithVBoxLayout:(LayoutVBox*)layout];
    return [self initWithHBoxLayout:(LayoutHBox*)layout];
}

- (id)initWithVBoxLayout:(LayoutVBox*)layout {
    self = [self init];
    
    _changed = NO;
    _iter = -1;
    _priority = NO;
    _full = layout.rect.size.height;
    _relv = layout.rect.size.width;
    
    return self;
}

- (id)initWithHBoxLayout:(LayoutHBox*)layout {
    self = [self init];
    
    _changed = NO;
    _iter = -1;
    _priority = YES;
    _full = layout.rect.size.width;
    _relv = layout.rect.size.height;
    
    return self;
}

- (void)resetLinearByLayout:(Layout *)layout {
    _changed = YES;
    
    if (_priority) {
        _full = layout.rect.size.width;
        _relv = layout.rect.size.height;
    } else {
        _full = layout.rect.size.height;
        _relv = layout.rect.size.width;
    }
}

- (id)addFlex:(float)flex {
    _changed = true;
    
    NntLinearSegment* value = [[NntLinearSegment alloc] init];
    value->type = kNntLinearSegmentFlex;
    value->value.flex = flex;
    value->result = 0;
    value->ctx = 0;
    [_segs addObject:value];
    [value release];
    
    return self;
}

- (id)addPixel:(float)pixel {
    _changed = true;
    
    NntLinearSegment* value = [[NntLinearSegment alloc] init];
    value->type = kNntLinearSegmentPixel;
    value->value.pixel = pixel;
    value->result = 0;
    value->ctx = 0;
    [_segs addObject:value];
    [value release];
    
    return self;
}

- (id)addAspectWithX:(float)x andY:(float)y {
    _changed = true;
    
    NntLinearSegment* value = [[NntLinearSegment alloc] init];
    value->type = kNntLinearSegmentAspect;
    value->aspect[0] = x;
    value->aspect[1] = y;
    value->result = 0;
    value->ctx = 0;
    [_segs addObject:value];
    [value release];
    
    return self;
}

- (BOOL)started {
    return _iter != -1;
}

- (void)recalc {
    if (_changed == false)
        return;
    _changed = false;
    
    float sum_pix = 0;
    float sum_flex = 0;
    
    for (NntLinearSegment* each in _segs)
    {
        switch (each->type)
        {
            case kNntLinearSegmentPixel: {
                sum_pix += each->value.pixel;
            } break;
            case kNntLinearSegmentFlex: {
                sum_flex += each->value.flex;
            } break;
            case kNntLinearSegmentAspect: {
                
                if (_priority)
                    each->value.pixel = _relv * (each->aspect[0] / each->aspect[1]);
                else
                    each->value.pixel = _relv * (each->aspect[1] / each->aspect[0]);
                sum_pix += each->value.pixel;
                
            } break;
        }
    }
    
    sum_flex = sum_flex ? sum_flex : 1;
    
    float full_flex = _full - sum_pix;
    float each_flex = full_flex / sum_flex;
    if (_flexValue == 0)
        _flexValue = each_flex;
    else
        each_flex = _flexValue;
    
    if (each_flex < _minFlexValue)
        each_flex = _minFlexValue;
    
    for (NntLinearSegment* each in _segs)
    {
        switch (each->type)
        {
            case kNntLinearSegmentPixel:
            case kNntLinearSegmentAspect:
            {
                each->result = each->value.pixel;
            } break;
            case kNntLinearSegmentFlex:
            {
                each->result = each->value.flex * each_flex;
            } break;
        }
    }
}

- (void)setFlexValue:(CGFloat)flexValue {
    if (_flexValue == flexValue)
        return;
    
    _flexValue = flexValue;
    [self recalc];
}

- (float)start {
    [self recalc];
    
    _iter = 0;
    NntLinearSegment* seg = [_segs objectAtIndex:_iter];
    return seg->result;
}

- (float)next {
    ++_iter;
    NntLinearSegment* seg = [_segs objectAtIndex:_iter];
    return seg->result;
}

- (float)prev {
    --_iter;
    NntLinearSegment* seg = [_segs objectAtIndex:_iter];
    return seg->result;
}

- (void)stop {
    _iter = 0;
}

@end
