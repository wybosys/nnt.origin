
# import "Common.h"
# import "CGTypes+Extension.h"
# import "CoreFoundation+Extension.h"
# import <CoreText/CoreText.h>

int COLOR_COMPONENT_BLEACHd(int v, float r) {
    v += (255 - v) * r;
    if (v > 255)
        v = 255;
    return v;
}

int RGB_BLEACH(int v, float rt) {
    int r = RGB_RED(v);
    int g = RGB_GREEN(v);
    int b = RGB_BLUE(v);
    r = COLOR_COMPONENT_BLEACHd(r, rt);
    g = COLOR_COMPONENT_BLEACHd(g, rt);
    b = COLOR_COMPONENT_BLEACHd(b, rt);
    return RGB_VALUE(r, g, b);
}

const CGFloat CGVALUEMAX = 99999;
CGFloat CGHeightMax = CGVALUEMAX;
CGFloat CGWidthMax = CGVALUEMAX;
CGRect CGRectMax = {0, 0, CGVALUEMAX, CGVALUEMAX};
CGSize CGSizeMax = {CGVALUEMAX, CGVALUEMAX};
CGPoint CGPointMax = {CGVALUEMAX, CGVALUEMAX};

const float FLOAT_1_255 = 1.f / 255;

@implementation NSSize

+ (id)size:(CGSize)sz {
    return [[[NSSize alloc] initWithSize:sz] autorelease];
}

- (id)initWithSize:(CGSize)sz {
    self = [super init];
    _size = sz;
    return self;
}

@dynamic width, height;

- (void)setWidth:(CGFloat)width {
    _size.width = width;
}

- (CGFloat)width {
    return _size.width;
}

- (void)setHeight:(CGFloat)height {
    _size.height = height;
}

- (CGFloat)height {
    return _size.height;
}

- (BOOL)isEqual:(id)object {
    return CGSizeEqualToSize(self.size, [object size]);
}

- (NSString*)description {
    return NSStringFromCGSize(_size);
}

- (void)swap {
    CGFloat t = self.width;
    self.width = self.height;
    self.height = t;
}

@end

@implementation NSPoint

+ (id)point:(CGPoint)pt {
    return [[[self alloc] initWithPoint:pt] autorelease];
}

- (id)initWithPoint:(CGPoint)pt {
    self = [super init];
    _point = pt;
    return self;
}

+ (instancetype)randomPointInRect:(CGRect)rc {
    CGPoint pt = rc.origin;
    pt.x += [NSRandom valueBoundary:0 To:rc.size.width];
    pt.y += [NSRandom valueBoundary:0 To:rc.size.height];
    return [self point:pt];
}

- (instancetype)intergral {
    _point = CGPointIntegral(_point);
    return self;
}

- (NSString*)description {
    return NSStringFromCGPoint(_point);
}

- (NSInteger)copyToMem:(void *)mem {
    memcpy(mem, &_point, sizeof(CGPoint));
    return sizeof(CGPoint);
}

@end

@implementation NSPoint3d

+ (id)point3d:(CGPoint3d)pt {
    return [[[self alloc] initWithPoint3d:pt] autorelease];
}

- (id)initWithPoint3d:(CGPoint3d)pt {
    self = [super init];
    _point3d = pt;
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    NSPoint3d* ret = [self.class new];
    ret.point3d = self.point3d;
    return ret;
}

- (void)multiply:(CGFloat)v {
    _point3d.x *= v;
    _point3d.y *= v;
    _point3d.z *= v;
}

- (void)multiplyByPoint:(CGPoint3d)pt {
    _point3d.x *= pt.x;
    _point3d.y *= pt.y;
    _point3d.z *= pt.z;
}

- (instancetype)pointMultiply:(CGFloat)v {
    NSPoint3d* ret = [[self copy] autorelease];
    [ret multiply:v];
    return ret;
}

- (instancetype)pointMultiplyByPoint:(CGPoint3d)pt {
    NSPoint3d* ret = [[self copy] autorelease];
    [ret multiplyByPoint:pt];
    return ret;
}

@end

@implementation NSRect

+ (id)rect:(CGRect)rc {
    return [[[self alloc] initWithRect:rc] autorelease];
}

- (id)initWithRect:(CGRect)rc {
    self = [super init];
    _rect = rc;
    return self;
}

- (NSString*)description {
    return NSStringFromCGRect(_rect);
}

@dynamic origin, size;

- (void)setOrigin:(CGPoint)origin {
    _rect.origin = origin;
}

- (CGPoint)origin {
    return _rect.origin;
}

- (void)setSize:(CGSize)size {
    _rect.size = size;
}

- (CGSize)size {
    return _rect.size;
}

- (CGFloat)maxX {
    return CGRectGetMaxX(_rect);
}

- (CGFloat)maxY {
    return CGRectGetMaxY(_rect);
}

- (CGFloat)x {
    return _rect.origin.x;
}

- (void)setX:(CGFloat)x {
    _rect.origin.x = x;
}

- (CGFloat)y {
    return _rect.origin.y;
}

- (void)setY:(CGFloat)y {
    _rect.origin.y = y;
}

- (CGFloat)width {
    return _rect.size.width;
}

- (void)setWidth:(CGFloat)width {
    _rect.size.width = width;
}

- (CGFloat)height {
    return _rect.size.height;
}

- (void)setHeight:(CGFloat)height {
    _rect.size.height = height;
}

- (CGPoint)center {
    return CGRectCenter(_rect);
}

- (void)setCenter:(CGPoint)pt {
    _rect = CGRectSetCenter(_rect, pt);
}

- (NSRect*)offsetX:(CGFloat)x Y:(CGFloat)y {
    CGRect rc = CGRectOffset(_rect, x, y);
    return [NSRect rect:rc];
}

- (NSRect*)squaredMax {
    CGFloat val = MAX(_rect.size.width, _rect.size.height);
    CGRect rc = _rect;
    rc.size.width = rc.size.height = val;
    return [NSRect rect:rc];
}

- (NSRect*)squaredMin {
    CGFloat val = MIN(_rect.size.width, _rect.size.height);
    CGRect rc = _rect;
    rc.size.width = rc.size.height = val;
    return [NSRect rect:rc];
}

- (NSRect*)edgeInsets:(UIEdgeInsets)ei {
    CGRect rc = UIEdgeInsetsInsetRect(self.rect, ei);
    return [NSRect rect:rc];
}

@end

@implementation CGDesigner

+ (CGFloat)Height:(CGFloat)val {
    return val * .5f;
}

+ (CGFloat)Width:(CGFloat)val {
    return val * .5f;
}

+ (CGSize)Size:(CGSize)sz {
    sz.height *= .5f;
    sz.width *= .5f;
    return sz;
}

+ (CGPoint)Point:(CGPoint)pt {
    pt.x *= .5f;
    pt.y *= .5f;
    return pt;
}

+ (CGRect)Rect:(CGRect)rc {
    rc.origin = [CGDesigner Point:rc.origin];
    rc.size = [CGDesigner Size:rc.size];
    return rc;
}

+ (CGPadding)Padding:(CGPadding)pd {
    pd.left = [CGDesigner Width:pd.left];
    pd.right = [CGDesigner Width:pd.right];
    pd.top = [CGDesigner Height:pd.top];
    pd.bottom = [CGDesigner Height:pd.bottom];
    return pd;
}

@end

@implementation NSPadding

+ (instancetype)padding:(CGPadding)pad {
    NSPadding* ret = [[self alloc] init];
    ret.padding = pad;
    return [ret autorelease];
}

@end

CGPoint CGPointAddPoint(CGPoint l, CGPoint r) {
    return CGPointMake(l.x + r.x, l.y + r.y);
}

CGPoint CGPointSubPoint(CGPoint l, CGPoint r) {
    return CGPointMake(l.x - r.x, l.y - r.y);
}

CGPoint CGRectCenter(CGRect rc) {
    CGPoint pt = rc.origin;
    pt.x += rc.size.width * .5f;
    pt.y += rc.size.height * .5f;
    return pt;
}

CGPoint CGSizeCenter(CGSize sz) {
    CGPoint pt = {0};
    pt.x = sz.width * .5f;
    pt.y = sz.height * .5f;
    return pt;
}

CGSize CGSizeDeflate(CGSize sz, CGFloat x, CGFloat y) {
    return CGSizeAdd(sz, -(x + x), -(y + y));
}

CGSize CGSizeScale(CGSize sz, CGFloat s) {
    sz.width *= s;
    sz.height *= s;
    return sz;
}

CGFloat CGSizeAspectRatio(CGSize sz) {
    ASSERTMSG(sz.height != 0, @"Size 的高不能为 0");
    return sz.width / sz.height;
}

CGSize CGSizeAdd(CGSize sz, CGFloat w, CGFloat h) {
    sz.width += w;
    sz.height += h;
    return sz;
}

CGSize CGSizeAddPoint(CGSize sz, CGPoint pt) {
    sz.width += pt.x;
    sz.height += pt.y;
    return sz;
}

CGSize CGSizeSubPoint(CGSize sz, CGPoint pt) {
    sz.width -= pt.x;
    sz.height -= pt.y;
    return sz;
}

CGSize CGSizeAddSize(CGSize sz, CGSize d) {
    sz.width += d.width;
    sz.height += d.height;
    return sz;
}

CGRect CGRectMakeWithSize(CGSize sz) {
    return CGRectMake(0, 0, sz.width, sz.height);
}

CGRect CGRectMakeWithPointAndSize(CGPoint pt, CGSize sz) {
    CGRect ret = {pt, sz};
    return ret;
}

CGRect CGRectMakeFromPointInflate(CGPoint pt, CGFloat x, CGFloat y) {
    CGRect ret;
    ret.origin = CGPointOffset(pt, -x, -y);
    ret.size = CGSizeMake(x + x, y + y);
    return ret;
}

CGRect CGRectDeflate(CGRect rc, CGFloat x, CGFloat y) {
    CGRect ret = rc;
    ret.origin.x += x;
    ret.origin.y += y;
    ret.size.width -= x + x;
    ret.size.height -= y + y;
    return ret;
}

CGRect CGRectDeflateWithRatio(CGRect rc, CGFloat dx, CGFloat dy) {
    CGFloat x = dx * rc.size.width * .5f;
    CGFloat y = dy * rc.size.height * .5f;
    return CGRectDeflate(rc, x, y);
}

CGRect CGRectMultiply(CGRect rc, CGFloat x, CGFloat y, CGFloat w, CGFloat h) {
    CGRect ret = rc;
    ret.origin.x *= x;
    ret.origin.y *= y;
    ret.size.width *= w;
    ret.size.height *= h;
    return ret;
}

CGRect CGRectScale(CGRect rc, CGFloat s) {
    rc.origin = CGPointSetX(rc.origin, s);
    rc.size = CGSizeScale(rc.size, s);
    return rc;
}

CGRect CGRectAdd(CGRect rc, CGFloat x, CGFloat y, CGFloat w, CGFloat h) {
    rc.origin.x += x;
    rc.origin.y += y;
    rc.size.width += w;
    rc.size.height += h;
    return rc;
}

CGRect CGRectAddSize(CGRect rc, CGFloat w, CGFloat h) {
    rc.size.width += w;
    rc.size.height += h;
    return rc;
}

CGRect CGRectCutSize(CGRect rc, CGFloat w, CGFloat h) {
    rc.origin.x += w;
    rc.origin.y += h;
    rc.size.width -= w;
    rc.size.height -= h;
    return rc;
}

CGRect CGRectClipCenterBySize(CGRect rc, CGSize sz) {
    CGRect ret = rc;
    if (sz.width) {
        ret.origin.x = rc.origin.x + (rc.size.width - sz.width) * .5f;
        ret.size.width = sz.width;
    }
    if (sz.height) {
        ret.origin.y = rc.origin.y + (rc.size.height - sz.height) * .5f;
        ret.size.height = sz.height;
    }
    return ret;
}

BOOL CGRectContainsX(CGRect rc, CGFloat x) {
    return (x > rc.origin.x) && (x < rc.origin.x + rc.size.width);
}

BOOL CGRectContainsY(CGRect rc, CGFloat y) {
    return (y > rc.origin.y) && (y < rc.origin.y + rc.size.height);
}

CGRect CGRectSetSize(CGRect rc, CGSize sz) {
    rc.size = sz;
    return rc;
}

CGRect CGRectSetX(CGRect rc, CGFloat v) {
    rc.origin.x = v;
    return rc;
}

CGRect CGRectSetY(CGRect rc, CGFloat v) {
    rc.origin.y = v;
    return rc;
}

CGFloat CGRectGetX(CGRect rc) {
    return rc.origin.x;
}

CGFloat CGRectGetY(CGRect rc) {
    return rc.origin.y;
}

CGRect CGRectSetPoint(CGRect rc, CGPoint pt) {
    rc.origin = pt;
    return rc;
}

CGRect CGRectOffsetByPoint(CGRect rc, CGPoint pt) {
    rc = CGRectOffset(rc, pt.x, pt.y);
    return rc;
}

CGRect CGRectSetWidth(CGRect rc, CGFloat val) {
    rc.size.width = val;
    return rc;
}

CGRect CGRectSetHeight(CGRect rc, CGFloat val) {
    rc.size.height = val;
    return rc;
}

CGRect CGRectSetCenter(CGRect rc, CGPoint pt) {
    rc.origin.x = pt.x - rc.size.width * .5f;
    rc.origin.y = pt.y - rc.size.height * .5f;
    return rc;
}

CGPoint CGRectLeftTop(CGRect rc) {
    return rc.origin;
}

CGPoint CGRectRightTop(CGRect rc) {
    CGPoint pt = rc.origin;
    pt.x += rc.size.width;
    return pt;
}

CGPoint CGRectLeftBottom(CGRect rc) {
    CGPoint pt = rc.origin;
    pt.y += rc.size.height;
    return pt;
}

CGPoint CGRectRightBottom(CGRect rc) {
    CGPoint pt = rc.origin;
    pt.x += rc.size.width;
    pt.y += rc.size.height;
    return pt;
}

CGPoint CGRectLeftCenter(CGRect rc) {
    CGPoint pt = rc.origin;
    pt.y += rc.size.height * .5f;
    return pt;
}

CGPoint CGRectRightCenter(CGRect rc) {
    CGPoint pt = CGRectRightTop(rc);
    pt.y += rc.size.height * .5f;
    return pt;
}

CGPoint CGRectTopCenter(CGRect rc) {
    CGPoint pt = rc.origin;
    pt.x += rc.size.width * .5f;
    return pt;
}

CGPoint CGRectBottomCenter(CGRect rc) {
    CGPoint pt = CGRectLeftBottom(rc);
    pt.x += rc.size.width * .5f;
    return pt;
}

CGPoint CGRectGetAnchorPoint(CGRect rc, CGPoint an) {
    an.x = rc.size.width * an.x + rc.origin.x;
    an.y = rc.size.height * an.y + rc.origin.y;
    return an;
}

CGClipRect CGSizeMapInSize(CGSize insz, CGSize sz, UIViewContentMode mode) {
    CGClipRect ret;
    ret.full = ret.work = CGRectMakeWithSize(sz);
    
    CGFloat aspsrc = insz.width / insz.height;
    CGFloat aspdes = sz.width / sz.height;
    
    if (isnan(aspsrc) || isnan(aspdes))
        return ret;
    
    switch (mode) {
        default: {} break;
        case UIViewContentModeScaleAspectFill: {
            if (aspsrc >= aspdes) {
                ret.full.size.height = sz.height;
                ret.full.size.width = ret.full.size.height * aspsrc;
                ret.full.origin.x = (sz.width - ret.full.size.width) * .5f;
            } else {
                ret.full.size.width = sz.width;
                ret.full.size.height = ret.full.size.width / aspsrc;
                ret.full.origin.y = (sz.height - ret.full.size.height) * .5f;
            }
        } break;
        case UIViewContentModeScaleAspectFit: {
            if (aspsrc >= aspdes) {
                ret.full.size.width = sz.width;
                ret.full.size.height = ret.full.size.width / aspsrc;
                ret.full.origin.y = (sz.height - ret.full.size.height) * .5f;
            } else {
                ret.full.size.height = sz.height;
                ret.full.size.width = ret.full.size.height * aspsrc;
                ret.full.origin.x = (sz.width - ret.full.size.width) * .5f;
            }
            ret.work = ret.full;
        } break;
    }
    
    ret.work = CGRectIntegral(ret.work);
    ret.full = CGRectIntegral(ret.full);
    return ret;
}

CGSize CGSizeMapInWidth(CGSize sz, CGFloat wid) {
    float ratio = sz.width / wid;
    sz.width = wid;
    if (ratio)
        sz.height /= ratio;
    sz = CGSizeIntegral(sz);
    return sz;
}

CGSize CGSizeMapInHeight(CGSize sz, CGFloat hei) {
    float ratio = sz.height / hei;
    sz.width /= ratio;
    sz.height = hei;
    sz = CGSizeIntegral(sz);
    return sz;
}

CGPoint CGPointOffset(CGPoint p, CGFloat x, CGFloat y) {
    p.x += x;
    p.y += y;
    return p;
}

CGPoint CGPointOffsetByPoint(CGPoint p, CGPoint t) {
    return CGPointOffset(p, t.x, t.y);
}

CGPoint CGPointMultiply(CGPoint pt, CGFloat x, CGFloat y) {
    pt.x *= x;
    pt.y *= y;
    return pt;
}

CGPoint CGPointSetX(CGPoint p, CGFloat v) {
    p.x = v;
    return p;
}

CGPoint CGPointSetY(CGPoint p, CGFloat v) {
    p.y = v;
    return p;
}

CGPoint CGPointScale(CGPoint p, CGFloat s) {
    p.x *= s;
    p.y *= s;
    return p;
}

CGPoint CGRectGetMinPoint(CGRect rc) {
    return CGPointMake(CGRectGetMinX(rc), CGRectGetMinY(rc));
}

CGPoint CGRectGetMaxPoint(CGRect rc) {
    return CGPointMake(CGRectGetMaxX(rc), CGRectGetMaxY(rc));
}

CGPoint UIEdgeInsetsInsetPoint(CGPoint pt, UIEdgeInsets is) {
    pt.x += is.left;
    pt.y += is.top;
    return pt;
}

CGSize UIEdgeInsetsInsetSize(CGSize sz, UIEdgeInsets is) {
    sz.width -= is.left + is.right;
    sz.height -= is.top + is.bottom;
    return sz;
}

CGRect CGRectApplyPadding(CGRect rc, CGPadding pad) {
    rc.origin.x += pad.left;
    rc.origin.y += pad.top;
    rc.size.width -= pad.left + pad.right;
    rc.size.height -= pad.top + pad.bottom;
    return rc;
}

CGRect CGRectApplyMargin(CGRect rc, CGMargin mag) {
    rc.origin.x += mag.left;
    rc.origin.y += mag.top;
    rc.size.width -= mag.left + mag.right;
    rc.size.height -= mag.top + mag.bottom;
    return rc;
}

CGRect CGRectUnapplyPadding(CGRect rc, CGPadding pad) {
    return CGRectApplyPadding(rc, CGPaddingMultiply(pad, -1, -1, -1, -1));
}

CGSize CGSizeApplyPadding(CGSize sz, CGPadding pad) {
    sz.width -= pad.left + pad.right;
    sz.height -= pad.top + pad.bottom;
    return sz;
}

CGSize CGSizeUnapplyPadding(CGSize sz, CGPadding pad) {
    return CGSizeApplyPadding(sz, CGPaddingMultiply(pad, -1, -1, -1, -1));
}

CGPadding CGPaddingMultiply(CGPadding pad, CGFloat t, CGFloat b, CGFloat l, CGFloat r) {
    pad.top *= t;
    pad.bottom *= b;
    pad.left *= l;
    pad.right *= r;
    return pad;
}

CGPadding CGPaddingAddPadding(CGPadding l, CGPadding r) {
    return CGPaddingAdd(l, r.top, r.bottom, r.left, r.right);
}

CGPadding CGPaddingAdd(CGPadding pd, CGFloat t, CGFloat b, CGFloat l, CGFloat r) {
    pd.top += t;
    pd.bottom += b;
    pd.left += l;
    pd.right += r;
    return pd;
}

/*
BOOL CGPaddingEqualToPadding(CGPadding l, CGPadding r) {
    return l.top == r.top &&
    l.bottom == r.bottom &&
    l.left == r.left &&
    l.right == r.right;
}
 */

CGRect CGRectApplyOffset(CGRect rc, CGPoint of) {
    return CGRectOffset(rc, of.x, of.y);
}

CGFloat CGPaddingHeight(CGPadding pd) {
    return pd.top + pd.bottom;
}

CGFloat CGPaddingWidth(CGPadding pd) {
    return pd.left + pd.right;
}

CGPadding CGPaddingSetTop(CGPadding pad, CGFloat v) {
    pad.top = v;
    return pad;
}

CGPadding CGPaddingSetBottom(CGPadding pad, CGFloat v) {
    pad.bottom = v;
    return pad;
}

CGPadding CGPaddingSetLeft(CGPadding pd, CGFloat v) {
    pd.left = v;
    return pd;
}

CGPadding CGPaddingSetRight(CGPadding pd, CGFloat v) {
    pd.right = v;
    return pd;
}

CGPadding CGPaddingSetLeftRight(CGPadding pd, CGFloat l, CGFloat r) {
    pd.left = l;
    pd.right = r;
    return pd;
}

CGPadding CGPaddingSetTopBottom(CGPadding pd, CGFloat t, CGFloat b) {
    pd.top = t;
    pd.bottom = b;
    return pd;
}

CGPadding CGPaddingMakeSize(CGFloat w, CGFloat h) {
    return CGPaddingMake(h, h, w, w);
}

BOOL CGSizeContainSize(CGSize l, CGSize r) {
    return l.width >= r.width &&
    l.height >= r.height;
}

CGSize CGSizeSetWidth(CGSize sz, CGFloat v) {
    sz.width = v;
    return sz;
}

CGSize CGSizeSetHeight(CGSize sz, CGFloat v) {
    sz.height = v;
    return sz;
}

CGSize CGSizeMultiply(CGSize sz, CGFloat w, CGFloat h) {
    sz.width *= w;
    sz.height *= h;
    return sz;
}

CGSize CGSizeSquare(CGSize sz, CGEdgeType type) {
    CGFloat val = type == kCGEdgeMax ? MAX(sz.width, sz.height) : MIN(sz.width, sz.height);
    return CGSizeMake(val, val);
}

CGRect CGRectSquare(CGRect rc, CGEdgeType type) {
    CGPoint cn = CGRectCenter(rc);
    rc.size = CGSizeSquare(rc.size, type);
    rc = CGRectSetCenter(rc, cn);
    return rc;
}

CGSize CGSizeIntegral(CGSize sz) {
    sz.width = floorf(sz.width);
    sz.height = floorf(sz.height);
    return sz;
}

CGFloat CGFloatIntegral(CGFloat val) {
    return floorf(val);
}

CGSize CGSizeBBXIntegral(CGSize sz) {
    sz.width = ceilf(sz.width);
    sz.height = ceilf(sz.height);
    return sz;
}

CGPoint CGPointIntegral(CGPoint pt) {
    pt.x = floorf(pt.x);
    pt.y = floorf(pt.y);
    return pt;
}

CGRect CGRectIntegralEx(CGRect rc) {
    rc.origin = CGPointIntegral(rc.origin);
    rc.size = CGSizeIntegral(rc.size);
    return rc;
}

CGSize CGImageGetSize(CGImageRef img) {
    return CGSizeMake(CGImageGetWidth(img), CGImageGetHeight(img));
}

CGSize CGSizeFromPoint(CGPoint pt) {
    return CGSizeMake(pt.x, pt.y);
}

CGPoint CGPointFromSize(CGSize sz) {
    return CGPointMake(sz.width, sz.height);
}

@implementation CGShadow

@synthesize color;

- (id)init {
    self = [super init];
    
    self.color = [UIColor blackColor].CGColor;
    self.opacity = 0;
    self.offset = CGSizeMake(0, -3);
    self.radius = 3;
    self.hidden = NO;
    
    return self;
}

- (void)dealloc {
    CFSAFE_RELEASE(color);
    [super dealloc];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    CGShadow* ret = [[[self class] alloc] init];
    ret.color = self.color;
    ret.opacity = self.opacity;
    ret.offset = self.offset;
    ret.radius = self.radius;
    ret.hidden = self.hidden;
    return ret;
}

- (void)setColor:(CGColorRef)val {
    CFPROPERTY_RETAIN(color, val);
}

- (CGColorRef)color {
    return color;
}

- (void)setIn:(CALayer *)layer {
    if (_hidden)
        return;
    
    layer.shadowColor = self.color;
    layer.shadowOpacity = self.opacity;
    layer.shadowOffset = self.offset;
    layer.masksToBounds = NO;
}

- (void)setInContext:(CGContextRef)ctx {
    CGContextSetShadowWithColor(ctx, self.offset, self.radius, self.color);
}

+ (CGShadow*)Normal {
    CGShadow* ret = [[CGShadow alloc] init];
    ret.opacity = .3f;
    return [ret autorelease];
}

+ (CGShadow*)LeftEdge {
    CGShadow* ret = [[CGShadow alloc] init];
    ret.opacity = .2f;
    ret.offset = CGSizeMake(-2, 0);
    return [ret autorelease];
}

+ (CGShadow*)RightEdge {
    CGShadow* ret = [[CGShadow alloc] init];
    ret.opacity = .2f;
    ret.offset = CGSizeMake(2, 0);
    return [ret autorelease];
}

+ (CGShadow*)RightBottomEdge {
    CGShadow* ret = [[CGShadow alloc] init];
    ret.opacity = .2f;
    ret.offset = CGSizeMake(2, 2);
    return [ret autorelease];
}

+ (CGShadow*)TopEdge {
    CGShadow* ret = [[CGShadow alloc] init];
    ret.opacity = .2f;
    ret.offset = CGSizeMake(0, -2);
    return [ret autorelease];
}

+ (CGShadow*)BottomEdge {
    CGShadow* ret = [[CGShadow alloc] init];
    ret.opacity = .2f;
    ret.offset = CGSizeMake(0, 2);
    return [ret autorelease];
}

+ (CGShadow*)Clear {
    CGShadow* ret = [[CGShadow alloc] init];
    ret.radius = 0;
    return [ret autorelease];
}

+ (CGShadow*)Around {
    CGShadow* ret = [[CGShadow alloc] init];
    ret.radius = 3;
    ret.opacity = .2f;
    ret.offset = CGSizeMake(0, 0);
    return [ret autorelease];
}

- (instancetype)shadowWithColor:(CGColorRef)val {
    CGShadow* ret = [[self copy] autorelease];
    ret.color = val;
    return ret;
}

- (instancetype)shadowWithOpacity:(float)opacity {
    CGShadow* ret = [[self copy] autorelease];
    ret.opacity = opacity;
    return ret;
}

- (instancetype)shadowWithRadius:(CGFloat)radius {
    CGShadow* ret = [[self copy] autorelease];
    ret.radius = radius;
    return ret;
}

- (instancetype)shadowWithOpacity:(float)opacity radius:(CGFloat)radius {
    CGShadow* ret = [[self copy] autorelease];
    ret.opacity = opacity;
    ret.radius = radius;
    return ret;
}

@end

@implementation CGBlur

@synthesize tintColor;

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    CFSAFE_RELEASE(tintColor);
    [super dealloc];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    CGBlur* ret = [[[self class] alloc] init];
    ret.radius = self.radius;
    ret.tintColor = self.tintColor;
    ret.saturation = self.saturation;
    return ret;
}

- (void)setTintColor:(CGColorRef)color {
    CFPROPERTY_RETAIN(tintColor, color);
}

- (CGColorRef)tintColor {
    return tintColor;
}

+ (CGBlur*)Subtle {
    CGBlur* ret = [CGBlur temporary];
    ret.tintColor = [UIColor colorWithWhite:1 alpha:.3].rgbColor.CGColor;
    ret.radius = 5;
    ret.saturation = 1.8;
    return ret;
}

+ (CGBlur*)Light {
    CGBlur* ret = [CGBlur temporary];
    ret.tintColor = [UIColor colorWithWhite:1 alpha:.3].rgbColor.CGColor;
    ret.radius = 30;
    ret.saturation = 1.8;
    return ret;
}

+ (CGBlur*)ExtraLight {
    CGBlur* ret = [CGBlur temporary];
    ret.tintColor = [UIColor colorWithWhite:0.97 alpha:.82].rgbColor.CGColor;
    ret.radius = 20;
    ret.saturation = 1.8;
    return ret;
}

+ (CGBlur*)Dark {
    CGBlur* ret = [CGBlur temporary];
    ret.tintColor = [UIColor colorWithWhite:0.11 alpha:.73].rgbColor.CGColor;
    ret.radius = 20;
    ret.saturation = 1.8;
    return ret;
}

- (instancetype)blurWithColor:(CGColorRef)color {
    CGBlur* ret = [self copy];
    ret.tintColor = color;
    return [ret autorelease];
}

- (instancetype)blurWithSaturation:(CGFloat)sa {
    CGBlur* ret = [self copy];
    ret.saturation = sa;
    return [ret autorelease];
}

@end

@implementation CGFilter

- (id)init {
    self = [super init];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    CGFilter* ret = [[[self class] alloc] init];
    return ret;
}

- (void)dealloc {
    [super dealloc];
}

- (void)processImage:(CGImageRef)image inContext:(CGContextRef)context {
    CGRect rc = CGRectMakeWithSize(CGImageGetSize(image));
    CGContextDrawImage(context, rc, image);
}

@end

@implementation CGFilterColorReplace

- (void)processImage:(CGImageRef)image inContext:(CGContextRef)context {
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, self.color);
    CGRect rc = CGRectMakeWithSize(CGImageGetSize(image));
    CGContextFillRect(context, rc);
    CGContextSetBlendMode(context, kCGBlendModeLuminosity);
    CGContextDrawImage(context, rc, image);
    CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
    CGContextDrawImage(context, rc, image);
    CGContextRestoreGState(context);
}

@end

@implementation CGFilterGrayscale

- (id)init {
    self = [super init];
    self.color = [UIColor grayColor].CGColor;
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    CGFilterGrayscale* ret = [super copyWithZone:zone];
    ret.color = self.color;
    return ret;
}

@end

@implementation CGFilterTintColor

- (id)copyWithZone:(NSZone *)zone {
    CGFilterTintColor* ret = [super copyWithZone:zone];
    ret.color = self.color;
    return ret;
}

- (void)processImage:(CGImageRef)image inContext:(CGContextRef)context {
    [super processImage:image inContext:context];
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, self.color);
    CGRect rc = CGRectMakeWithSize(CGImageGetSize(image));
    CGContextFillRect(context, rc);
    CGContextRestoreGState(context);
}

@end

@implementation CGLine

@synthesize color;

- (id)init {
    self = [super init];
    
    self.color = nil;
    self.width = 1;
    self.cap = kCGLineCapRound;
    self.join = kCGLineJoinRound;
    
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_shadow);
    CFSAFE_RELEASE(color);
    [super dealloc];
}

+ (instancetype)lineWithColor:(CGColorRef)color {
    CGLine* ret = [[self alloc] init];
    ret.color = color;
    return [ret autorelease];
}

+ (instancetype)lineWithWidth:(CGFloat)width {
    CGLine* ret = [[self alloc] init];
    ret.width = width;
    return [ret autorelease];
}

+ (instancetype)lineWithColor:(CGColorRef)color width:(CGFloat)width {
    CGLine* ret = [[self alloc] init];
    ret.color = color;
    ret.width = width;
    return [ret autorelease];
}

- (void)setColor:(CGColorRef)val {
    CFPROPERTY_RETAIN(color, val);
}

- (CGColorRef)color {
    return color;
}

+ (CGLine*)BadgeEdgeLine {
    CGLine* ret = [[self alloc] init];
    ret.color = [UIColor whiteColor].CGColor;
    ret.width = 2;
    ret.shadow = [CGShadow Normal];
    return [ret autorelease];
}

- (void)setIn:(CGContextRef)context {
    CGContextSetStrokeColorWithColor(context, self.color);
    CGContextSetLineWidth(context, self.width);
    CGContextSetLineCap(context, self.cap);
    CGContextSetLineJoin(context, self.join);
}

- (void)drawLineFrom:(CGPoint)from to:(CGPoint)to inContext:(CGContextRef)context {
    from = CGPointOffsetByPoint(from, self.offset);
    to = CGPointOffsetByPoint(to, self.offset);
    
    CGContextSaveGState(context);
    [self setIn:context];
    CGContextMoveToPoint(context, from.x, from.y);
    CGContextAddLineToPoint(context, to.x, to.y);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

+ (instancetype)BottomLine {
    CGLine* ret = [[self alloc] init];
    ret.width = 1;
    ret.offset = CGPointMake(0, -1);
    return [ret autorelease];
}

@end

@implementation CGAngle

@synthesize value = _rad;

+ (CGAngle*)RegularDegree:(CGFloat)deg {
    CGAngle* ret = [[self alloc] init];
    deg = -deg + 180;
    ret->_rad = [CGAngle Degree2Rad:deg];
    return [ret autorelease];
}

+ (CGAngle*)RegularRad:(CGFloat)rad {
    CGAngle* ret = [[self alloc] init];
    ret->_rad = -rad + M_PI;
    return [ret autorelease];
}

+ (CGFloat)Degree2Rad:(CGFloat)deg {
    return deg * M_DEGREE;
}

+ (CGAngle*)Angle:(CGFloat)ang {
    CGAngle* ret = [[self alloc] init];
    ret->_rad = ang * M_DEGREE;
    return [ret autorelease];
}

+ (CGAngle*)Rad:(CGFloat)rad {
    CGAngle* ret = [[self alloc] init];
    ret->_rad = rad;
    return [ret autorelease];
}

- (CGAngle*)angleAddDegree:(CGFloat)deg {
    CGAngle* ret = [[[[self class] alloc] init] autorelease];
    ret->_rad = _rad;
    return [ret addDegree:deg];
}

- (CGAngle*)angleAddRad:(CGFloat)rad {
    CGAngle* ret = [[[[self class] alloc] init] autorelease];
    ret->_rad = _rad;
    return [ret addRad:rad];
}

- (id)addDegree:(CGFloat)deg {
    deg = -deg * M_DEGREE;
    _rad = _rad + deg;
    return self;
}

- (id)addRad:(CGFloat)rad {
    rad = -rad;
    _rad = _rad + rad;
    return self;
}

- (CGFloat)distance:(CGAngle *)r {
    CGFloat ret = _rad - r->_rad;
    return fabsr(ret);
}

- (CGFloat)rad {
    return _rad;
}

- (CGFloat)angle {
    return _rad / M_DEGREE;
}

@end

@implementation CGPen

+ (instancetype)Pen:(CGColorRef)color width:(CGFloat)width {
    CGPen* ret = [[self alloc] init];
    ret.color = color;
    ret.width = width;
    return [ret autorelease];
}

- (id)init {
    self = [super init];
    self.width = 1;
    self.cap = kCGLineCapRound;
    self.join = kCGLineJoinRound;
    return self;
}

- (void)dealloc {
    CFSAFE_RELEASE(color);
    CFSAFE_RELEASE(backgroundColor);
    [super dealloc];
}

@synthesize color, backgroundColor;

- (void)setColor:(CGColorRef)val {
    CFPROPERTY_RETAIN(color, val);
}

- (CGColorRef)color {
    return color;
}

- (void)setBackgroundColor:(CGColorRef)val {
    CFPROPERTY_RETAIN(backgroundColor, val);
}

- (CGColorRef)backgroundColor {
    return backgroundColor;
}

- (void)setIn:(CGGraphic *)gra {
    [self setInContext:gra.context];
}

- (void)setInContext:(CGContextRef)ctx {
    CGContextSetStrokeColorWithColor(ctx, self.color);
    CGContextSetLineWidth(ctx, self.width);
    CGContextSetLineCap(ctx, self.cap);
    CGContextSetLineJoin(ctx, self.join);
}

- (void)strokeIn:(CGGraphic *)gra {
    [self strokeInContext:gra.context];
}

- (void)strokeInContext:(CGContextRef)ctx {
    CGContextStrokePath(ctx);
}

@end

CGPoint3d CGPointMake3d(CGFloat x, CGFloat y, CGFloat z)
{
    CGPoint3d p; p.x = x; p.y = y; p.z = z; return p;
}

CGPoint3d CGPoint3dFromPoint(CGPoint pt, CGFloat z)
{
    CGPoint3d p; p.x = pt.x; p.y = pt.y; p.z = z; return p;
}

CATransform3D CGTransform3DRotationFromPoint(CGPoint3d pt) {
    CATransform3D mat = CATransform3DIdentity;
    mat = CATransform3DRotate(mat, pt.x, 1, 0, 0);
    mat = CATransform3DRotate(mat, pt.y, 0, 1, 0);
    mat = CATransform3DRotate(mat, pt.z, 0, 0, 1);
    return mat;
}

@implementation CGMatrix

+ (instancetype)Translate:(CGPoint)val {
    CGMatrix* mat = [CGMatrix temporary];
    [mat translate:val];
    return mat;
}

+ (instancetype)scale:(CGPoint)val {
    CGMatrix* mat = [CGMatrix temporary];
    [mat scale:val];
    return mat;
}

+ (instancetype)Rotate:(CGAngle*)val {
    CGMatrix* mat = [CGMatrix temporary];
    [mat rotate:val];
    return mat;
}

- (id)init {
    self = [super init];
    _t = CGAffineTransformIdentity;
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (CGAffineTransform*)pT {
    return &_t;
}

- (void)setIn:(CGGraphic*)gra {
    [self setInContext:gra.context];
}

- (void)setInContext:(CGContextRef)ctx {
    CGAffineTransform mat = CGContextGetCTM(ctx);
    mat = CGAffineTransformInvert(mat);
    CGContextConcatCTM(ctx, mat);
    CGContextConcatCTM(ctx, _t);
}

- (void)transform:(CGGraphic*)gra {
    [self transformInContext:gra.context];
}

- (void)transformInContext:(CGContextRef)ctx {
    CGContextConcatCTM(ctx, _t);
}

- (id)translate:(CGPoint)val {
    _t = CGAffineTransformTranslate(_t, val.x, val.y);
    return self;
}

- (id)scale:(CGPoint)val {
    _t = CGAffineTransformScale(_t, val.x, val.y);
    return self;
}

- (id)rotate:(CGAngle*)val {
    _t = CGAffineTransformRotate(_t, val.value);
    return self;
}

@end

@implementation CGPicture

+ (instancetype)image:(CGImageRef)image {
    CGPicture* ret = [[self alloc] init];
    ret.image = image;
    return [ret autorelease];
}

- (id)init {
    self = [super init];
    _anchorPoint = kCGAnchorPointCC;
    return self;
}

- (void)dealloc {
    CFZERO_RELEASE(_image);
    [super dealloc];
}

- (void)setImage:(CGImageRef)image {
    CFPROPERTY_RETAIN(_image, image);
}

- (void)drawIn:(CGGraphic *)gra {
    [self drawInContext:gra.context];
}

- (void)drawInContext:(CGContextRef)ctx {
    CGContextSaveGState(ctx);
    CGSize sz = _size;
    if (CGSizeEqualToSize(sz, CGSizeZero))
        sz = CGImageGetSize(_image);
    CGRect rc = CGRectMakeWithSize(sz);
    rc.origin.x -= sz.width * _anchorPoint.x;
    rc.origin.y -= sz.height * _anchorPoint.y;
    CGContextDrawImage(ctx, rc, _image);
    CGContextRestoreGState(ctx);
}

@end

@implementation CGBrush

- (void)setIn:(CGGraphic*)gra {
    [self setInContext:gra.context];
}

- (void)setInContext:(CGContextRef)ctx {
    PASS;
}

- (void)fillIn:(CGGraphic*)gra {
    [self fillInContext:gra.context];
}

- (void)fillInContext:(CGContextRef)ctx {
    CGContextFillPath(ctx);
}

@end

@implementation CGSolidBrush

+ (instancetype)Brush:(CGColorRef)color {
    CGSolidBrush* ret = [[self alloc] init];
    ret.color = color;
    return [ret autorelease];
}

- (void)setInContext:(CGContextRef)ctx {
    CGContextSetFillColorWithColor(ctx, _color);
}

@end

@interface _CGGradientBrush ()
{
    NSMutableArray* _colors;
    CGColorSpaceRef _cs;
    @public
    CGGradientRef _br;
}

// 确保是可用的
- (void)makeUsable;

// 释放
- (void)freeRes;

@end

@implementation _CGGradientBrush

- (id)init {
    self = [super init];
    _colors = [[NSMutableArray alloc] init];
    _cs = CGColorSpaceCreateDeviceRGB();
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_colors);
    CGColorSpaceRelease(_cs);
    [self freeRes];
    [super dealloc];
}

- (void)makeUsable {
    if (_br)
        return;
    _br = CGGradientCreateWithColors(_cs, (CFArrayRef)_colors, NULL);
}

- (void)freeRes {
    if (_br) {
        CGGradientRelease(_br);
        _br = NULL;
    }
}

- (void)addColor:(CGColorRef)color {
    [_colors addObject:(id)color];
    [self freeRes];
}

- (void)setInContext:(CGContextRef)ctx {
    PASS; // 渐变会有自己独立的画法，所以不继承老的实现
}

- (void)fillInContext:(CGContextRef)ctx {
    // 渐变会有自己独立的画法，所以不继承老的实现
    // 但是要确保该画刷可用
    [self makeUsable];
}

@end

@implementation CGLinearGradientBrush

- (id)init {
    self = [super init];
    _start = CGRectTopCenter(kUIApplicationBounds);
    _end = CGRectBottomCenter(kUIApplicationBounds);
    return self;
}

- (void)fillInContext:(CGContextRef)ctx {
    [super fillInContext:ctx];
    CGContextDrawLinearGradient(ctx,
                                self->_br,
                                _start, _end,
                                0);
}

@end

@implementation CGRadialGradientBrush

- (id)init {
    self = [super init];
    _start = kCGAnchorPointCC;
    _end = kCGAnchorPointBC;
    _startRadius = 0;
    _endRadius = 10;
    return self;
}

- (void)fillInContext:(CGContextRef)ctx {
    [super fillInContext:ctx];
    CGContextDrawRadialGradient(ctx,
                                self->_br,
                                _start, _startRadius,
                                _end, _endRadius,
                                0);
}

- (void)setCenter:(CGPoint)center {
    self.start = center;
    self.end = center;
    _center = center;
}

- (void)setRadius:(CGFloat)radius {
    self.startRadius = 0;
    self.endRadius = radius;
    _radius = radius;
}

- (void)setSize:(CGSize)size {
    self.center = CGSizeCenter(size);
    self.radius = MIN(size.width, size.height) / 2;
    _size = size;
}

- (void)setRect:(CGRect)rect {
    self.center = CGRectCenter(rect);
    self.radius = MIN(rect.size.width, rect.size.height) / 2;
    _rect = rect;
}

@end

@implementation CGPatternBrush

@end

@implementation NSString (textstyle)

- (CGPoint)adjustPosition:(CGPoint)pos anchorPoint:(CGPoint)anchorPoint withFont:(UIFont*)font {
    if (CGPointEqualToPoint(anchorPoint, kCGAnchorPointLT))
        return pos;
    CGSize sz = [self sizeWithFont:font];
    pos.x -= sz.width * anchorPoint.x;
    pos.y -= sz.height * anchorPoint.y;
    return pos;
}

@end

@implementation CGTextStyle

- (id)init {
    self = [super init];
    //_textAlignment = NSTextAlignmentLeft;
    _anchorPoint = kCGAnchorPointLT;
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_font);
    [super dealloc];
}

+ (instancetype)Font:(UIFont *)font {
    CGTextStyle* ret = [[self alloc] init];
    ret.font = font;
    return [ret autorelease];
}

- (void)setIn:(CGGraphic*)gra {
    /*
    CGContextSelectFont(gra.context,
                        self.font.fontName.UTF8String,
                        self.font.pointSize,
                        kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(gra.context, kCGTextFill);
     */
}

- (CGSize)sizeOf:(NSString*)str {
    CGSize sz = [str sizeWithFont:_font];
    return sz;
}

- (CGFloat)widthOf:(NSString*)str {
    return [self sizeOf:str].width;
}

- (CGFloat)heightOf:(NSString*)str {
    return [self sizeOf:str].height;
}

@end

@interface CGCanvasPage ()
{
    BOOL _isStarted;
}

@property (nonatomic, readonly) CGMutablePathRef ph;

@end

@implementation CGCanvasPage

- (id)init {
    self = [super init];
    _ph = CGPathCreateMutable();
    return self;
}

- (void)dealloc {
    CGPathRelease(_ph);
    ZERO_RELEASE(_matrix);
    [super dealloc];
}

- (id)move:(CGPoint)pt {
    _isStarted = YES;
    CGPathMoveToPoint(_ph, _matrix.pT, pt.x, pt.y);
    return self;
}

- (id)line:(CGPoint)pt {
    if (!_isStarted)
        return [self move:pt];
    CGPathAddLineToPoint(_ph, _matrix.pT, pt.x, pt.y);
    return self;
}

- (id)commit {
    CGPathCloseSubpath(_ph);
    _isStarted = NO;
    return self;
}

- (id)curveQuad:(CGPoint)pos control:(CGPoint)control {
    CGPathAddQuadCurveToPoint(_ph, _matrix.pT, control.x, control.y, pos.x, pos.y);
    return self;
}

- (id)curve:(CGPoint)pos a:(CGPoint)a b:(CGPoint)b {
    CGPathAddCurveToPoint(_ph, _matrix.pT, a.x, a.y, b.x, b.y, pos.x, pos.y);
    return self;
}

- (id)ellipse:(CGRect)rect {
    CGPathAddEllipseInRect(_ph, _matrix.pT, rect);
    return self;
}

- (id)ellipse:(CGPoint)center radius:(CGFloat)radius {
    CGRect rc = CGRectMake(center.x - radius, center.y - radius, radius + radius, radius + radius);
    return [self ellipse:rc];
}

- (instancetype)rect:(CGRect)rect {
    CGPathAddRect(_ph, _matrix.pT, rect);
    return self;
}

- (instancetype)rect:(CGRect)rect roundradius:(CGFloat)roundradius {
    CGPathAddRoundedRect(_ph, _matrix.pT, rect, roundradius, roundradius);
    return self;
}

- (id)arc:(CGPoint)center radius:(CGFloat)radius from:(CGAngle*)from delta:(CGFloat)delta {
    CGPathAddRelativeArc(_ph, _matrix.pT, center.x, center.y, radius, from.value, delta);
    return self;
}

- (id)arc:(CGPoint)center radius:(CGFloat)radius from:(CGAngle*)from to:(CGAngle*)to clockwise:(BOOL)clockwise {
    CGPathAddArc(_ph, _matrix.pT, center.x, center.y, radius, from.value, to.value, clockwise);
    return self;
}

- (id)arc:(CGFloat)radius start:(CGPoint)start end:(CGPoint)end {
    CGPathAddArcToPoint(_ph, _matrix.pT, start.x, start.y, end.x, end.y, radius);
    return self;
}

@end

@interface CGBezier ()

@property (nonatomic, readonly) UIBezierPath *ph;

@end

@implementation CGBezier

- (id)init {
    self = [super init];
    _ph = [[UIBezierPath bezierPath] retain];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_ph);
    [super dealloc];
}

- (instancetype)move:(CGPoint)pt {
    [_ph moveToPoint:pt];
    return self;
}

- (instancetype)curve:(CGPoint)pos a:(CGPoint)a b:(CGPoint)b {
    [_ph addCurveToPoint:pos controlPoint1:a controlPoint2:b];
    return self;
}

- (instancetype)line:(CGPoint)pt {
    [_ph addLineToPoint:pt];
    return self;
}

- (instancetype)commit {
    [_ph closePath];
    return self;
}

- (void)clip {
    [_ph addClip];
}

@end

@interface CGGraphic ()
{
    CGContextRef _ctx;
    BOOL _reversex, _reversey;
}

@end

@implementation CGGraphic

@synthesize context = _ctx;

- (instancetype)initWithContext:(CGContextRef)ctx {
    self = [super init];
    _ctx = CGContextRetain(ctx);
    return self;
}

+ (instancetype)graphicWithContext:(CGContextRef)ctx {
    return [[[[self class] alloc] initWithContext:ctx] autorelease];
}

+ (instancetype)Current {
    return [[[self alloc] initWithContext:UIGraphicsGetCurrentContext()] autorelease];
}

+ (instancetype)Current:(CGRect)rc {
    CGGraphic* ret = [self Current];
    ret->_bounds = rc;
    return ret;
}

- (void)dealloc {
    CGContextRelease(_ctx);
    [super dealloc];
}

- (instancetype)reverse {
    CGContextScaleCTM(_ctx, -1, -1);
    CGContextTranslateCTM(_ctx, -_bounds.size.width, -_bounds.size.height);
    _reversex = _reversey = YES;
    return self;
}

- (instancetype)reversex {
    CGContextScaleCTM(_ctx, -1, 1);
    CGContextTranslateCTM(_ctx, -_bounds.size.width, 0);
    _reversex = YES;
    return self;
}

- (instancetype)reversey {
    CGContextScaleCTM(_ctx, 1, -1);
    CGContextTranslateCTM(_ctx, 0, -_bounds.size.height);
    _reversey = YES;
    return self;
}

- (NSRect*)bbx {
    return [NSRect rect:CGContextGetClipBoundingBox(_ctx)];
}

- (instancetype)move:(CGPoint)pt {
    CGContextMoveToPoint(_ctx, pt.x, pt.y);
    return self;
}

- (instancetype)line:(CGPoint)pt pen:(CGPen *)pen {
    [pen setIn:self];
    CGContextAddLineToPoint(_ctx, pt.x, pt.y);
    if (pen)
        CGContextStrokePath(_ctx);
    return self;
}

- (instancetype)lines:(CGPoint const*)pts count:(NSInteger)count {
    CGContextAddLines(_ctx, pts, count);
    return self;
}

- (instancetype)rect:(CGRect)rc pen:(CGPen*)pen brush:(CGBrush*)br {
    [pen setIn:self];
    [br setIn:self];
    
    CGContextAddRect(_ctx, rc);
    if (br)
        CGContextFillRect(_ctx, rc);
    if (pen)
        CGContextStrokeRect(_ctx, rc);
    return self;
}

- (instancetype)rect:(CGRect)rc roundradius:(CGFloat)roundradius pen:(CGPen*)pen brush:(CGBrush*)br {
    [pen setIn:self];
    [br setIn:self];
    
    rc.size.width = [NSMath maxf:rc.size.width r:roundradius*2];
    
    CGMutablePathRef ph = CGPathCreateMutable();
    CGPathAddRoundedRect(ph, nil, rc, roundradius, roundradius);
    CGContextAddPath(_ctx, ph);
    CGPathRelease(ph);
    
    if (br)
        CGContextFillPath(_ctx);
    if (pen)
        CGContextStrokePath(_ctx);
    return self;
}

- (instancetype)ellipse:(CGRect)rc pen:(CGPen *)pen brush:(CGBrush *)br {
    [pen setIn:self];
    [br setIn:self];
    
    CGContextAddEllipseInRect(_ctx, rc);
    if (br)
        CGContextFillRect(_ctx, rc);
    if (pen)
        CGContextStrokeRect(_ctx, rc);
    
    return self;
}

- (instancetype)arc:(CGPoint)center radius:(CGFloat)radius start:(CGAngle *)start end:(CGAngle *)end clockwise:(BOOL)clockwise pen:(CGPen *)pen brush:(CGBrush *)br {
    [pen setIn:self];
    [br setIn: self];
    
    CGContextAddArc(_ctx, center.x, center.y, radius, start.value, end.value, !clockwise);
    if (br)
        CGContextFillPath(_ctx);
    if (pen)
        CGContextStrokePath(_ctx);
    
    return self;
}

- (instancetype)arc:(CGPoint)center radius:(CGFloat)radius start:(CGAngle*)start angle:(CGAngle*)angle clockwise:(BOOL)clockwise pen:(CGPen*)pen brush:(CGBrush*)br {
    return [self arc:center radius:radius start:start end:[CGAngle Rad:(start.value + angle.value)] clockwise:clockwise pen:pen brush:br];
}

- (instancetype)arc:(CGFloat)radius from:(CGPoint)from to:(CGPoint)to pen:(CGPen *)pen brush:(CGBrush *)br {
    [pen setIn:self];
    [br setIn:self];
    
    CGContextAddArcToPoint(_ctx, from.x, from.y, to.x, to.y, radius);
    if (br)
        CGContextFillPath(_ctx);
    if (pen)
        CGContextStrokePath(_ctx);
    
    return self;
}

- (instancetype)text:(NSString*)text position:(CGPoint)position brush:(CGBrush*)br style:(CGTextStyle*)font {
    return [self text:text position:position anchor:font.anchorPoint brush:br style:font];
}

- (instancetype)text:(NSString*)text position:(CGPoint)position anchor:(CGPoint)anchor brush:(CGBrush*)br style:(CGTextStyle*)font {
    [br setIn:self];
    [font setIn:self];
    
    // 根据对齐方式修正一下绘制的位置点
    position = [text adjustPosition:position anchorPoint:anchor withFont:font.font];
    
    UIGraphicsPushContext(_ctx);
    CGContextSaveGState(_ctx);
    
    if (_reversey) {
        CGContextTranslateCTM(_ctx, 0, _bounds.size.height);
        CGContextScaleCTM(_ctx, 1, -1);
        CGContextTranslateCTM(_ctx, 0, _bounds.size.height - font.font.pointSize);
        position.y = -position.y;
    }
    
    [text drawAtPoint:position withFont:font.font];
    
    CGContextRestoreGState(_ctx);
    UIGraphicsPopContext();
    
    return self;
}

- (instancetype)picture:(CGPicture*)img position:(CGPoint)position {
    return [self picture:img position:position transform:nil];
}

- (instancetype)picture:(CGPicture*)img position:(CGPoint)position transform:(CGMatrix*)mat {
    CGContextSaveGState(_ctx);
    CGContextTranslateCTM(_ctx, position.x, position.y);
    [mat transformInContext:_ctx];
    [img drawInContext:_ctx];
    CGContextRestoreGState(_ctx);
    return self;
}

- (instancetype)fill:(CGBrush*)br {
    [br setIn:self];
    [br fillInContext:_ctx];
    return self;
}

- (instancetype)stroke:(CGPen*)pen {
    [pen setIn:self];
    [pen strokeInContext:_ctx];
    return self;
}

- (instancetype)path:(void(^)(CGGraphic* graphic))block {
    [self push];
    CGContextBeginPath(_ctx);
    block(self);
    CGContextMoveToPoint(_ctx, 0, 0);
    CGContextClosePath(_ctx);
    [self pop];
    return self;
}

- (instancetype)layer:(void(^)(CGGraphic* graphic))block shadow:(CGShadow*)shadow {
    [self push];
    [shadow setInContext:_ctx];
    CGContextBeginTransparencyLayer(_ctx, nil);
    block(self);
    CGContextEndTransparencyLayer(_ctx);
    [self pop];
    return self;
}

- (instancetype)stroke:(CGCanvasPage*)page pen:(CGPen*)pen {
    CGContextAddPath(_ctx, page.ph);
    [self stroke:pen];
    return self;
}

- (instancetype)fill:(CGCanvasPage*)page brush:(CGBrush*)brush {
    CGContextAddPath(_ctx, page.ph);
    [self fill:brush];
    return self;
}

- (instancetype)push {
    CGContextSaveGState(_ctx);
    return self;
}

- (instancetype)pop {
    CGContextRestoreGState(_ctx);
    return self;
}

- (instancetype)perform {
    CGContextClosePath(_ctx);
    return self;
}

- (instancetype)clip:(CGRect)rc {
    CGContextClipToRect(_ctx, rc);
    _bounds = rc;
    return self;
}

- (void)setMatrix:(CGMatrix *)matrix {
    [matrix setIn:self];
}

- (CGMatrix*)matrix {
    CGMatrix* ret = [CGMatrix temporary];
    ret.t = CGContextGetCTM(_ctx);
    return ret;
}

- (instancetype)transform:(CGMatrix*)matrix {
    [matrix transform:self];
    return self;
}

@end

@implementation CGPrimitive

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_pen);
    ZERO_RELEASE(_brush);
    [super dealloc];
}

- (void)reset {
    PASS;
}

- (void)render:(CGGraphic *)graphic {
    PASS;
}

@end

@implementation CGPrimitiveLine

- (id)init {
    self = [super init];
    _points = [[NSMutableArray alloc] init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_points);
    [super dealloc];
}

- (void)reset {
    [self.points removeAllObjects];
}

- (void)render:(CGGraphic *)graphic {
    if (self.points.count <= 1)
        return;
    // 只能绘制2各节点以上的线段
    [graphic move:[self.points.firstObject point]];
    for (uint i = 1; i < self.points.count; ++i) {
        NSPoint* pt = [self.points objectAtIndex:i];
        [graphic line:pt.point pen:nil];
    }
    [graphic stroke:self.pen];
}

- (void)add:(CGPoint)pt {
    [self.points addObject:[NSPoint point:pt]];
}

@end

@implementation CGPrimitivePolygon

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)render:(CGGraphic *)graphic {
    if (self.points.count <= 1)
        return;
    
    NSMemObject* mo = [NSMemObject allocmem:self.points.count type:sizeof(CGPoint)];
    [self.points copyToMem:mo.ptr];
    
    if (self.brush) {
        [graphic path:^(CGGraphic *graphic) {
            [graphic move:[self.points.firstObject point]];
            [graphic lines:mo.ptr count:self.points.count];
        }];
        [graphic fill:self.brush];
    }

    if (self.pen) {
        [graphic path:^(CGGraphic *graphic) {
            [graphic lines:mo.ptr count:self.points.count];
            [graphic line:[self.points.firstObject point] pen:nil];
        }];
        [graphic stroke:self.pen];
    }
}

@end

@implementation CGPrimitives

- (id)init {
    self = [super init];
    _primitives = [[NSMutableArray alloc] init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_primitives);
    [super dealloc];
}

- (void)addObject:(CGPrimitive *)obj {
    [self.primitives addObject:obj];
}

- (void)render:(CGGraphic *)graphic {
    for (CGPrimitive* each in self.primitives) {
        [each render:graphic];
    }
}

- (void)clear {
    [self.primitives removeAllObjects];
}

@end

@interface CGSketch ()

@property (nonatomic, readonly) NSMutableSet *pens, *brushs, *matrxies;

@end

@implementation CGSketch

- (id)init {
    self = [super init];
    
    _pens = [[NSMutableSet alloc] init];
    _brushs = [[NSMutableSet alloc] init];
    _matrxies = [[NSMutableSet alloc] init];
    _primitives = [[CGPrimitives alloc] init];
    
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_pens);
    ZERO_RELEASE(_brushs);
    ZERO_RELEASE(_matrxies);
    
    ZERO_RELEASE(_pen);
    ZERO_RELEASE(_brush);
    ZERO_RELEASE(_matrix);
    ZERO_RELEASE(_primitives);
    
    [super dealloc];
}

- (void)setInContext:(CGContextRef)ctx {
    [_pen setInContext:ctx];
    [_brush setInContext:ctx];
    [_matrix setInContext:ctx];
}

- (void)renderInContext:(CGContextRef)ctx {
    CGGraphic* graphic = [CGGraphic graphicWithContext:ctx];
    [self setInContext:ctx];
    [self.primitives render:graphic];
}

- (void)renderInGraphic:(CGGraphic *)gra {
    [self setInContext:gra.context];
    [self.primitives render:gra];
}

- (void)clear {
    [self.primitives clear];
    
    [_pens removeAllObjects];
    [_brushs removeAllObjects];
    [_matrxies removeAllObjects];
}

- (void)add:(CGPrimitive *)prim {
    [self.primitives addObject:prim];
    if (prim.pen == nil)
        prim.pen = _pen;
    if (prim.brush == nil)
        prim.brush = _brush;
}

@end
