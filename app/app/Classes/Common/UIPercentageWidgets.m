
# import "Common.h"
# import "UIPercentageWidgets.h"

@implementation CAProgressLayer

- (void)onInit {
    [super onInit];
    self.paddingEdge = CGPaddingMake(5, 5, 5, 5);
    self.shouldRasterize = YES;
}

@dynamic progress;

+ (BOOL)needsDisplayForKey:(NSString *)key {
    return [key isEqualToString:@"progress"] || [super needsDisplayForKey:key];
}

- (id<CAAction>)actionForKey:(NSString *)event {
    if (!kUIViewExtAnimationPeriod)
        return [super actionForKey:event];
    if ([event isEqualToString:@"progress"]) {
        float val = [[self.presentationLayer valueForKey:event] floatValue];
        if (1 - val < 0.01)
            val = 0;
        CABasicAnimation* ani = [CABasicAnimation animationWithKeyPath:event];
        ani.fromValue = @(val);
        ani.duration = kUIViewExtAnimationDuration;
        return ani;
    }
    return [super actionForKey:event];
}

- (void)onPaint:(CGGraphic*)gra {
    PASS;
}

@end

@implementation UIActivityIndicatorView (percentage)

- (void)percentageBegan:(id)target {
    [self startAnimating];
}

- (void)percentageEnd:(id)target value:(NSPercentage *)value complete:(BOOL)complete {
    [self stopAnimating];
}

- (void)percentage:(id)target value:(NSPercentage *)value {
    PASS;
}

@end

@implementation UIProgressView (percentage)

- (void)percentage:(id)target value:(NSPercentage *)value {
    self.percentage = value;
}

@end

@implementation UIActivityIndicatorExt

+ (id)temporary {
    return [self.class Gray];
}

- (id)initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style {
    self = [super initWithActivityIndicatorStyle:style];
    self.hidesWhenStopped = NO;
    [self startAnimating];
    return self;
}

@end

@interface UIRingPercentageIndicatorLayer : CAProgressLayer

@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, retain) CGPen* pen;

@end

@implementation UIRingPercentageIndicatorLayer

- (void)onCopy:(UIRingPercentageIndicatorLayer*)r {
    [super onCopy:r];
    self.pen = r.pen;
    self.radius = r.radius;
}

- (void)onFin {
    ZERO_RELEASE(_pen);
    [super onFin];
}

- (void)onPaint:(CGGraphic*)gra {
    [super onPaint:gra];
    
    CGRect rc = gra.bounds;
    CGPoint center = CGRectCenter(rc);
    CGFloat radius = [NSMath minf:rc.size.width r:rc.size.height] * .5 - self.pen.width;
    if (self.radius)
        radius = [NSMath minf:radius r:self.radius];
    CGAngle* ang = [CGAngle Angle:360*self.progress];
    [gra arc:center radius:radius start:[CGAngle Angle:-90] angle:ang clockwise:YES pen:self.pen brush:nil];
}

@end

@implementation UIRingPercentageIndicator

+ (Class)layerClass {
    return [UIRingPercentageIndicatorLayer class];
}

- (void)onInit {
    [super onInit];
    self.radius = 20;
    self.pen = [CGPen Pen:[UIColor grayColor].CGColor width:1];
    self.userInteractionEnabled = NO;
    self.roating = YES;
}

- (void)onFin {
    ZERO_RELEASE(_percentage);
    [super onFin];
}

- (void)setRoating:(BOOL)roating {
    if (_roating == roating)
        return;
    _roating = roating;
    
    if (_roating) {
        CAAnimation* ani = [CAKeyframeAnimation RotateFrom:0 To:M_2PI];
        ani.repeatCount = INFINITY;
        ani.duration = 2;
        [self.layer addAnimation:ani];
    } else {
        [self.layer removeAllAnimations];
    }
}

- (void)percentage:(id)target value:(NSPercentage *)value {
    self.percentage = value;
}

- (void)setPercentage:(NSPercentage *)per {
    PROPERTY_RETAIN(_percentage, per);
    UIRingPercentageIndicatorLayer* lyr = (id)self.layer;
    lyr.progress = per.percent;
}

- (void)setRadius:(CGFloat)radius {
    _radius = radius;
    UIRingPercentageIndicatorLayer* lyr = (id)self.layer;
    lyr.radius = radius;
    [lyr setNeedsDisplay];
}

- (void)setPen:(CGPen *)pen {
    UIRingPercentageIndicatorLayer* lyr = (id)self.layer;
    lyr.pen = pen;
    [lyr setNeedsDisplay];
}

- (CGPen*)pen {
    UIRingPercentageIndicatorLayer* lyr = (id)self.layer;
    return lyr.pen;
}

@end

@interface UIProgressBarLayer : CAProgressLayer

@property (nonatomic, retain) CGPen *pen;
@property (nonatomic, retain) CGBrush *brush;

@end

@implementation UIProgressBarLayer

- (void)onInit {
    [super onInit];
    self.paddingEdge = CGPaddingMake(3, 3, 6, 6);
}

- (void)onCopy:(UIProgressBarLayer*)r {
    [super onCopy:r];
    self.pen = r.pen;
    self.brush = r.brush;
}

- (void)onFin {
    ZERO_RELEASE(_pen);
    ZERO_RELEASE(_brush);
    [super onFin];    
}

- (void)onPaint:(CGGraphic*)gra {
    [super onPaint:gra];

    CGRect rc = gra.bounds;
    if (self.pen) {
        CGFloat er = rc.size.height * .5f;
        [gra rect:rc roundradius:er pen:self.pen brush:nil];
    }

    rc = CGRectDeflate(rc, 2, 2);
    CGFloat radius = rc.size.height * .5f;
    rc.size.width *= self.progress;
    [gra rect:rc roundradius:radius pen:nil brush:_brush];
}

@end

@implementation UIProgressBar

+ (Class)layerClass {
    return [UIProgressBarLayer class];
}

- (void)onInit {
    [super onInit];
    self.pen = [CGPen Pen:[UIColor grayColor].CGColor width:1];
    self.brush = [CGSolidBrush Brush:self.pen.color];
    self.userInteractionEnabled = NO;
}

- (void)onFin {
    ZERO_RELEASE(_percentage);
    [super onFin];
}

- (void)percentage:(id)target value:(NSPercentage *)value {
    self.percentage = value;
}

- (void)setPercentage:(NSPercentage *)per {
    PROPERTY_RETAIN(_percentage, per);
    UIProgressBarLayer* lyr = (id)self.layer;
    lyr.progress = per.percent;
}

- (void)setBrush:(CGBrush *)brush {
    UIProgressBarLayer* lyr = (id)self.layer;
    lyr.brush = brush;
    [lyr setNeedsDisplay];
}

- (CGBrush*)brush {
    UIProgressBarLayer* lyr = (id)self.layer;
    return lyr.brush;
}

- (void)setPen:(CGPen *)pen {
    UIProgressBarLayer* lyr = (id)self.layer;
    lyr.pen = pen;
    [lyr setNeedsDisplay];
}

- (CGPen*)pen {
    UIProgressBarLayer* lyr = (id)self.layer;
    return lyr.pen;
}

- (CGSize)bestSize:(CGSize)sz {
    return CGSizeMake(0, 15);
}

@end

@interface CARingActivityIndicator : CALayerExt

@property (nonatomic, retain) CGPen *pen;
@property (nonatomic, assign) CGFloat radius;

@end

@implementation CARingActivityIndicator

- (void)onInit {
    [super onInit];
    self.shouldRasterize = YES;
}

- (void)onFin {
    ZERO_RELEASE(_pen);
    [super onFin];
}

- (void)onPaint:(CGGraphic*)gra {
    CGRect rc = gra.bounds;
    CGPoint pt = CGRectCenter(rc);
    CGSize sz = CGSizeSquare(rc.size, kCGEdgeMin);
    CGFloat r = _radius;
    if (r <= 0 || r > (sz.width/2 - _pen.width))
        r = CGFloatIntegral(sz.width/2 - _pen.width);
    
    [gra arc:pt radius:r start:[CGAngle Angle:-85] angle:[CGAngle Angle:330] clockwise:YES pen:_pen brush:nil];
}

@end

@interface UIRingActivityIndicator ()

@property (nonatomic, readonly) CARingActivityIndicator *lyr;

@end

@implementation UIRingActivityIndicator

- (void)onInit {
    [super onInit];
    self.userInteractionEnabled = NO;
    
    [self.layer addSublayer:BLOCK_RETURN({
        _lyr = [CARingActivityIndicator temporary];
        return _lyr;
    })];
    self.pen = [CGPen Pen:[UIColor grayColor].CGColor width:1];
    
    // 开始运行
    [self startAnimating];
}

- (void)onFin {
    ZERO_RELEASE(_pen);
    [super onFin];
}

- (void)setPen:(CGPen *)pen {
    PROPERTY_RETAIN(_pen, pen);
    _lyr.pen = pen;
    [_lyr setNeedsDisplay];
}

- (void)setRadius:(CGFloat)radius {
    _radius = radius;
    _lyr.radius = radius;
    [_lyr setNeedsDisplay];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    _lyr.frame = rect;
}

- (void)startAnimating {
    if ([_lyr animationForKey:@"::ui::ring::rotate"])
        return;
    
    CAAnimation* ani = [CAKeyframeAnimationExt RotateFrom:0 To:M_2PI];
    ani.namekey = @"::ui::ring::rotate";
    ani.repeatCount = INFINITY;
    ani.duration = 1.3;
    [_lyr addAnimation:ani];
}

- (void)stopAnimating {
    CAAnimation* ani = [_lyr animationForKey:@"::ui::ring::rotate"];
    if (ani == nil)
        return;
    
    [_lyr stopAnimation:ani];
}

- (void)percentageBegan:(id)target {
    [self startAnimating];
}

- (void)percentageEnd:(id)target value:(NSPercentage *)value complete:(BOOL)complete {
    [self stopAnimating];
}

- (void)percentage:(id)target value:(NSPercentage *)value {
    PASS;
}

@end
