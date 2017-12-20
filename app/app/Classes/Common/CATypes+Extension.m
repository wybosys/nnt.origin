
# import "Common.h"
# import "CATypes+Extension.h"
# import <CoreText/CoreText.h>
# import "CGTypes+Extension.h"
# import "CoreFoundation+Extension.h"

static int __gs_caani_key = 0;

# define CAANIMATION_KEY [NSString stringWithFormat:@"::ca::animation::key::%d", ++__gs_caani_key]

@implementation NSObject (ca_extension)

- (void)animateData {
    PASS;
}

@end

@interface _CALayerAnimationsObject : NSObject {
    int _count;
}

@property (nonatomic, retain) CALayer* layer;
@property (nonatomic, retain) NSArray* animations;

@end

@implementation _CALayerAnimationsObject

SIGNALS_BEGIN
SIGNAL_ADD(kSignalAnimationStop)
SIGNALS_END

- (void)dealloc {
    ZERO_RELEASE(_layer);
    ZERO_RELEASE(_animations);
    [super dealloc];
}

- (void)execute {
    _count = _animations.count;
    
    for (CAAnimation* each in _animations) {
        [each.signals connect:kSignalAnimationStop withSelector:@selector(__ani_end) ofTarget:self];
        [_layer addAnimation:each];
        [self retain];
    }
}

- (void)__ani_end {
    --_count;
    
    if (_count == 0) {
        [self.signals emit:kSignalAnimationStop];
    }    
    
    [self release];
}

@end

@implementation CALayer (extension)

- (void)roundlize {
    CGSize sz = self.bounds.size;
    CGFloat v = MAX(sz.width, sz.height);
    v *= .5f;
    [self roundlize:v];
}

- (void)roundlize:(CGFloat)val {
    self.masksToBounds = YES;
    self.cornerRadius = val;
    //self.shouldRasterize = YES;
    //会引起子层的文字变模糊
}

- (void)setWidth:(CGFloat)val {
    CGRect rc = self.frame;
    rc.size.width = val;
    self.frame = rc;
}

- (void)setHeight:(CGFloat)val {
    CGRect rc = self.frame;
    rc.size.height = val;
    self.frame = rc;
}

- (void)setSize:(CGSize)sz {
    CGRect rc = self.frame;
    rc.size = sz;
    self.frame = rc;
}

- (void)setBorder:(CGLine *)line {
    self.borderColor = line.color;
    self.borderWidth = line.width;
    if (line.shadow)
        self.shadow = line.shadow;
}

- (CGLine*)border {
    CGLine* ret = [CGLine lineWithColor:self.borderColor width:self.borderWidth];
    ret.shadow = self.shadow;
    return ret;
}

- (void)setShadow:(CGShadow *)shadow {
    self.shadowColor = shadow.color;
    self.shadowOffset = shadow.offset;
    self.shadowOpacity = shadow.opacity;
    self.shadowRadius = shadow.radius;
    self.masksToBounds = shadow == nil;
}

- (CGShadow*)shadow {
    CGShadow* ret = [CGShadow temporary];
    ret.color = self.shadowColor;
    ret.offset = self.shadowOffset;
    ret.opacity = self.shadowOpacity;
    ret.radius = self.shadowRadius;
    return ret;
}

- (void)addAnimation:(CAAnimation *)anim {
    if (anim.namekey == nil)
        anim.namekey = CAANIMATION_KEY;
    
    // 提交修改，刷新动画
    [anim commit];
    
    // 执行动画
    [self addAnimation:anim forKey:anim.namekey];
}

- (NSObject*)addAnimations:(NSArray*)anims {
    _CALayerAnimationsObject* anisobj = [[_CALayerAnimationsObject alloc] init];
    anisobj.layer = self;
    anisobj.animations = anims;
    [anisobj execute];
    return [anisobj autorelease];
}

- (NSObject*)addAnimations:(NSArray*)anims completion:(void(^)())block {
    [[self addAnimations:anims].signals connect:kSignalAnimationStop withBlock:^(SSlot *s) {
        block();
    }];
    return self;
}

- (void)addAnimation:(CAAnimation *)ani completion:(void (^)())block {
    [ani.signals connect:kSignalAnimationStop withBlock:^(SSlot *s) {
        block();
    }];
    
    if (ani.namekey == nil)
        ani.namekey = CAANIMATION_KEY;
    
    [self addAnimation:ani forKey:ani.namekey];
}

- (void)stopAnimation:(CAAnimation*)anim {
    if (anim.namekey) {
        [self removeAnimationForKey:anim.namekey];
    } else {
        WARN("animation 丢失了 namekey 数据，该数据会当 animationForKey 时丢失");
    }
}

- (void)stopAnimations {
    [self removeAllAnimations];
}

@end

@implementation CALayerExt

- (id)init {
    self = [super init];
    [self onInit];
    return self;
}

- (id)initWithLayer:(id)layer {
    self = [super initWithLayer:layer];
    if ([layer isKindOfClass:self.class]) {
        [self onCopy:layer];
    } else {
        [self onInit];
    }
    return self;
}

- (void)onCopy:(CALayerExt*)r {
    self.paddingEdge = r.paddingEdge;
}

- (void)dealloc {
    [self onFin];
    [super dealloc];
}

- (CGRect)rectForPaint {
    CGRect rc = self.bounds;
    rc = CGRectApplyPadding(rc, self.paddingEdge);
    return rc;
}

- (void)drawInContext:(CGContextRef)ctx {
    [super drawInContext:ctx];    
    if ([self respondsToSelector:@selector(onPaint:)]) {
        id<CALayerExt> lyr = (id)self;
        CGGraphic* gra = [CGGraphic graphicWithContext:ctx];
        [gra clip:self.rectForPaint];
        [lyr onPaint:gra];
    }
}

- (void)renderInContext:(CGContextRef)ctx {
    [super renderInContext:ctx];
}

@end

@implementation CASketchLayer

- (void)onInit {
    [super onInit];
    _sketch = [[CGSketch alloc] init];
}

- (void)onFin {
    ZERO_RELEASE(_sketch);
    [super onFin];
}

- (void)drawInContext:(CGContextRef)ctx {
    [self.sketch renderInContext:ctx];
}

- (void)clear {
    [self.sketch clear];
    [self setNeedsDisplay];
}

@end

@implementation CAAnimation (extension)

NSOBJECT_DYNAMIC_PROPERTY(CAAnimation, namekey, setNamekey, COPY_NONATOMIC);

SIGNALS_BEGIN
SIGNAL_ADD(kSignalAnimationStart)
SIGNAL_ADD(kSignalAnimationStop)
SIGNALS_END

- (void)setResetOnCompletion:(BOOL)resetOnCompletion {
    if (resetOnCompletion) {
        self.removedOnCompletion = YES;
        self.fillMode = kCAFillModeRemoved;
    } else {
        self.removedOnCompletion = NO;
        self.fillMode = kCAFillModeForwards;
    }
}

- (BOOL)resetOnCompletion {
    if (self.removedOnCompletion == YES)
        return NO;
    return self.fillMode != kCAFillModeForwards;
}

- (void)commit {
    PASS;
}

@end

NSString* const kCATransitionFlip = @"oglFlip";
NSString* const kCATransitionRipple = @"rippleEffect";
NSString* const kCATransitionSuck = @"suckEffect";
NSString* const kCATransitionCube = @"cube";
NSString* const kCATransitionCameraIrisHoollowOpen = @"cameraIrisHollowOpen";
NSString* const kCATransitionCameraIrisHoollowClose = @"cameraIrisHollowClose";

@implementation CATransitionExt

- (id)init {
    self = [super init];
    self.delegate = self;
    //self.resetOnCompletion = NO;
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)animationDidStart:(CAAnimation *)anim {
    [self.signals emit:kSignalAnimationStart];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self.signals emit:kSignalAnimationStop];
}

@end

@interface CAKeyframeAnimationExt () {
    NSValue* _last_value;
}

@property (nonatomic, readonly) NSMutableArray *ext_times, *ext_values;

@end

NSFORWARD_CLASS(CAKeyframeAnimationFlex, NSNumber);

@implementation CAKeyframeAnimationExt

- (id)init {
    self = [super init];
    self.delegate = self;
    self.resetOnCompletion = NO;
    
    _ext_times = [NSMutableArray new];
    _ext_values = [NSMutableArray new];
    _last_value = nil;
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_ext_times);
    ZERO_RELEASE(_ext_values);
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    CAAnimation* ani = [super copyWithZone:zone];
    ani.namekey = self.namekey;
    return ani;
}

- (void)animationDidStart:(CAAnimation *)anim {
    [self.signals emit:kSignalAnimationStart];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self.signals emit:kSignalAnimationStop];
}

- (void)addValue:(NSValue *)val time:(NSTimeInterval)tm {
    [_ext_values addObject:val];
    _last_value = val;

    [_ext_times addObject:@(tm)];
}

- (void)addValue:(NSValue *)val flex:(float)flex {
    [_ext_values addObject:val];
    _last_value = val;
    
    [_ext_times addObject:[CAKeyframeAnimationFlex object:@(flex)]];
}

- (void)addValue:(NSValue *)val {
    [_ext_values addObject:val];
    _last_value = val;
}

- (void)waitTime:(NSTimeInterval)tm {
    if (_last_value == nil)
        [_ext_values addObject:@(0)];
    else
        [_ext_values addObject:_last_value];
    [_ext_times addObject:@(tm)];
}

- (void)commit {
    if (_ext_values.count)
        self.values = _ext_values;
    
    if (_ext_times.count) {
        // 计算所有的 flex 以及被固定分配的时间
        float sumflex = 0;
        NSTimeInterval sumfixtm = 0;
        for (id each in _ext_times) {
            if ([each isKindOfClass:[CAKeyframeAnimationFlex class]])
                sumflex += [each floatValue];
            else
                sumfixtm += [each floatValue];
        }
        NSTimeInterval sumflextm = self.duration - sumfixtm;
        NSTimeInterval flextm = sumflextm / TRIEXPRESS(sumflex, sumflex, 1);
        
        __block NSTimeInterval ti = 0;
        self.keyTimes = [_ext_times arrayWithCollector:^id(id l) {
            NSTimeInterval sep = 0;
            if ([l isKindOfClass:[CAKeyframeAnimationFlex class]])
                sep = [l floatValue] * flextm;
            else
                sep = [l floatValue];
            ti += sep / self.duration;
            return @(ti);
        }];
    }
    
# ifdef DEBUG_MODE
    if (self.values && self.keyTimes)
        ASSERT(self.values.count == self.keyTimes.count);
# endif
}

@end

CGFloat kCAAnimationDuration = .3f;

@implementation CAKeyframeAnimation (extension)

+ (id)Translate:(CGPoint)pt {
    CAKeyframeAnimationExt* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform";
    ani.values = @[
                   [NSValue valueWithCATransform3D:CATransform3DIdentity],
                   [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(pt.x, pt.y, 0)]
                   ];
    ani.duration = kCAAnimationDuration;
    return ani;
}

+ (id)Tremble {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform";
    ani.values = [NSArray arrayWithObjects:
                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1)],
                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1)],
                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1)],
                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)],
                  nil];
    ani.duration = kCAAnimationDuration;
    return ani;
}

+ (id)TrembleOut {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform";
    ani.values = [NSArray arrayWithObjects:
                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.6, 0.6, 1)],
                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1)],
                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1)],
                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1)],
                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)],
                  nil];
    ani.duration = kCAAnimationDuration;
    return ani;
}

+ (id)Wabble {
    return [self Wabble:CATransform3DIdentity];
}

+ (id)Wabble:(CATransform3D)mat {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform";
    ani.values = [NSArray arrayWithObjects:
                  [NSValue valueWithCATransform3D:CATransform3DTranslate(mat, 5, 0, 0)],
                  [NSValue valueWithCATransform3D:CATransform3DTranslate(mat, -3, 0, 0)],
                  [NSValue valueWithCATransform3D:CATransform3DTranslate(mat, 1, 0, 0)],
                  [NSValue valueWithCATransform3D:CATransform3DTranslate(mat, 0, 0, 0)],
                  nil];
    ani.duration = kCAAnimationDuration;
    return ani;
}

+ (id)WabbleNeg {
    return [self WabbleNeg:CATransform3DIdentity];
}

+ (id)WabbleNeg:(CATransform3D)mat {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform";
    ani.values = [NSArray arrayWithObjects:
                  [NSValue valueWithCATransform3D:CATransform3DTranslate(mat, -5, 0, 0)],
                  [NSValue valueWithCATransform3D:CATransform3DTranslate(mat, 3, 0, 0)],
                  [NSValue valueWithCATransform3D:CATransform3DTranslate(mat, -1, 0, 0)],
                  [NSValue valueWithCATransform3D:CATransform3DTranslate(mat, 0, 0, 0)],
                  nil];
    ani.duration = kCAAnimationDuration;
    return ani;
}


+ (id)WabbleY {
    return [self WabbleY:CATransform3DIdentity];
}

+ (id)WabbleY:(CATransform3D)mat {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform";
    ani.values = [NSArray arrayWithObjects:
                  [NSValue valueWithCATransform3D:CATransform3DTranslate(mat, 0, 5, 0)],
                  [NSValue valueWithCATransform3D:CATransform3DTranslate(mat, 0, -3, 0)],
                  [NSValue valueWithCATransform3D:CATransform3DTranslate(mat, 0, 2, 0)],
                  [NSValue valueWithCATransform3D:CATransform3DTranslate(mat, 0, 0, 0)],
                  nil];
    ani.duration = kCAAnimationDuration;
    return ani;
}

+ (id)WabbleYNeg {
    return [self WabbleYNeg:CATransform3DIdentity];
}

+ (id)WabbleYNeg:(CATransform3D)mat {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform";
    ani.values = [NSArray arrayWithObjects:
                  [NSValue valueWithCATransform3D:CATransform3DTranslate(mat, 0, -5, 0)],
                  [NSValue valueWithCATransform3D:CATransform3DTranslate(mat, 0, 3, 0)],
                  [NSValue valueWithCATransform3D:CATransform3DTranslate(mat, 0, -2, 0)],
                  [NSValue valueWithCATransform3D:CATransform3DTranslate(mat, 0, 0, 0)],
                  nil];
    ani.duration = kCAAnimationDuration;
    return ani;
}

+ (id)FadeIn {
    return [self FadeFrom:0 To:1];
}

+ (id)FadeIn:(CGFloat)val {
    return [self FadeFrom:val To:1];
}

+ (id)FadeOut {
    return [self FadeFrom:1 To:0];
}

+ (id)FadeOut:(CGFloat)val {
    return [self FadeFrom:1 To:val];
}

+ (id)FadeFrom:(CGFloat)from To:(CGFloat)to {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"opacity";
    ani.values = [NSArray arrayWithObjects:
                  @(from),
                  @(to),
                  nil];
    ani.duration = kCAAnimationDuration;
    return ani;
}

+ (id)Twinkling {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"opacity";
    ani.values = [NSArray arrayWithObjects:
                  @(0), @(1),
                  @(0), @(1),
                  @(0), @(1),
                  @(0),
                  nil];
    ani.duration = kCAAnimationDuration * 2;
    return ani;
}

+ (id)Twinkling:(NSInteger)count {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"opacity";
    ani.values = BLOCK_RETURN({
        NSMutableArray* arr = [NSMutableArray temporary];
        [arr addObject:@(1)];
        for (NSInteger i = 0; i < count; ++i) {
            [arr addObject:@(0)];
            [arr addObject:@(1)];
        }
        return arr;
    });
    ani.duration = kCAAnimationDuration * count;
    return ani;
}

+ (id)Spin {
    return [[self class] Spin:YES];
}

+ (id)Spin:(BOOL)clockwise {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform.rotation.z";
    ani.repeatCount = NSNotFound;
    ani.values = [NSArray arrayWithObjects:
                  @(0),
                  @(TRIEXPRESS(clockwise, M_2PI, -M_2PI)),
                  nil];
    ani.duration = kCAAnimationDuration;
    return ani;
}

+ (id)InScale {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform";
    ani.values = [NSArray arrayWithObjects:
                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(.8, .8, 1)],
                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)],
                  nil];
    ani.duration = kCAAnimationDuration;
    return ani;
}

+ (id)ScaleIn {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform";
    ani.values = [NSArray arrayWithObjects:
                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(2, 2, 1)],
                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)],
                  nil];
    ani.duration = kCAAnimationDuration;
    return ani;
}

+ (id)ScaleOut {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform";
    ani.values = [NSArray arrayWithObjects:
                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)],
                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(2, 2, 1)],
                  nil];
    ani.duration = kCAAnimationDuration;
    return ani;
}

+ (id)RotateFrom:(CGFloat)from To:(CGFloat)to {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform.rotation.z";
    ani.values = [NSArray arrayWithObjects:
                  @(from), @(to), nil];
    ani.duration = kCAAnimationDuration;
    return ani;
}

+ (id)ScaleFrom:(CGFloat)from To:(CGFloat)to {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform";
    ani.values = [NSArray arrayWithObjects:
                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(from, from, 1)],
                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(to, to, 1)],
                  nil];
    ani.duration = kCAAnimationDuration;
    return ani;
}

+ (id)TranslateXFrom:(CGFloat)from To:(CGFloat)to {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform.translation.x";
    ani.values = [NSArray arrayWithObjects:
                  @(from), @(to), nil];
    ani.duration = kCAAnimationDuration;
    return ani;
}

+ (id)TranslateYFrom:(CGFloat)from To:(CGFloat)to {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform.translation.y";
    ani.values = [NSArray arrayWithObjects:
                  @(from), @(to), nil];
    ani.duration = kCAAnimationDuration;
    return ani;
}

+ (id)FoldClose {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform.scale.y";
    ani.values = [NSArray arrayWithObjects:
                  @(1),
                  @(0),
                  nil];
    ani.duration = kCAAnimationDuration;
    return ani;
}

+ (id)FoldOpen {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform.scale.y";
    ani.values = [NSArray arrayWithObjects:
                  @(0),
                  @(1),
                  nil];
    ani.duration = kCAAnimationDuration;
    return ani;
}

+ (id)ShrinkClose {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform.scale.x";
    ani.values = [NSArray arrayWithObjects:
                  @(1),
                  @(0),
                  nil];
    ani.duration = kCAAnimationDuration;
    return ani;
}

+ (id)ShrinkOpen {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform.scale.x";
    ani.values = [NSArray arrayWithObjects:
                  @(0),
                  @(1),
                  nil];
    ani.duration = kCAAnimationDuration;
    return ani;
}

+ (id)SlideFromTop:(UIView*)view {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform.translation.y";
    ani.values = [NSArray arrayWithObjects:
                  @(view.superview.bounds.origin.y - view.frame.size.height),
                  @(view.frame.origin.y),
                  nil];
    ani.duration = kCAAnimationDuration;
    return ani;
}

+ (id)SlideToTop:(UIView*)view {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform.translation.y";
    ani.values = [NSArray arrayWithObjects:
                  @(view.frame.origin.y),
                  @(view.superview.bounds.origin.y - view.frame.size.height),
                  nil];
    ani.duration = kCAAnimationDuration;
    return ani;
}

+ (id)SlideFromBottom:(UIView*)view {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform.translation.y";
    ani.values = [NSArray arrayWithObjects:
                  @(CGRectGetMaxY(view.superview.bounds)),
                  @(view.frame.origin.y),
                  nil];
    ani.duration = kCAAnimationDuration;
    return ani;
}

+ (id)SlideToBottom:(UIView*)view {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform.translation.y";
    ani.values = [NSArray arrayWithObjects:
                  @(view.frame.origin.y),
                  @(CGRectGetMaxY(view.superview.bounds)),
                  nil];
    ani.duration = kCAAnimationDuration;
    return ani;
}

+ (id)SlideFromLeft:(UIView*)view {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform.translation.x";
    ani.values = [NSArray arrayWithObjects:
                  @(view.superview.bounds.origin.x - view.frame.size.width),
                  @(view.frame.origin.x),
                  nil];
    ani.duration = kCAAnimationDuration;
    return ani;
}

+ (id)SlideToLeft:(UIView*)view {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform.translation.x";
    ani.values = [NSArray arrayWithObjects:
                  @(view.frame.origin.x),
                  @(view.superview.bounds.origin.x - view.frame.size.width),
                  nil];
    ani.duration = kCAAnimationDuration;
    return ani;
}

+ (id)SlideFromRight:(UIView*)view {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform.translation.x";
    ani.values = [NSArray arrayWithObjects:
                  @(CGRectGetMaxX(view.superview.bounds)),
                  @(view.frame.origin.x),
                  nil];
    ani.duration = kCAAnimationDuration;
    return ani;
}

+ (id)SlideToRight:(UIView*)view {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform.translation.x";
    ani.values = [NSArray arrayWithObjects:
                  @(view.frame.origin.x),
                  @(CGRectGetMaxX(view.superview.bounds)),
                  nil];
    ani.duration = kCAAnimationDuration;
    return ani;
}

+ (id)CubeTopFrom:(UIView*)l To:(UIView*)r {
    CATransition *transtion = [CATransitionExt animation];
    transtion.duration = kCAAnimationDuration;
    [transtion setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [transtion setType:@"cube"];
    [transtion setSubtype:kCATransitionFromTop];
    return transtion;
}

+ (id)CubeBottomFrom:(UIView*)l To:(UIView*)r {
    CATransition *transtion = [CATransitionExt animation];
    transtion.duration = kCAAnimationDuration;
    [transtion setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [transtion setType:@"cube"];
    [transtion setSubtype:kCATransitionFromBottom];
    return transtion;
}

+ (id)CubeLeftFrom:(UIView*)l To:(UIView*)r {
    CATransition *transtion = [CATransitionExt animation];
    transtion.duration = kCAAnimationDuration;
    [transtion setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [transtion setType:@"cube"];
    [transtion setSubtype:kCATransitionFromLeft];
    return transtion;
}

+ (id)CubeRightFrom:(UIView*)l To:(UIView*)r {
    CATransition *transtion = [CATransitionExt animation];
    transtion.duration = kCAAnimationDuration;
    [transtion setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [transtion setType:@"cube"];
    [transtion setSubtype:kCATransitionFromRight];
    return transtion;
}

@end

@interface CADisplayLinkExt ()

@property (nonatomic, readonly) CADisplayLink *dlink;

@end

@implementation CADisplayLinkExt

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_dlink);
    [super dealloc];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalTakeAction)
SIGNALS_END

- (BOOL)isRunning {
    return _dlink != nil;
}

- (void)start {
    ZERO_RELEASE(_dlink);
    _dlink = [[CADisplayLink displayLinkWithTarget:self selector:@selector(__cbdl)] retain];
    [_dlink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)stop {
    [_dlink invalidate];
    ZERO_RELEASE(_dlink);
}

- (void)invalidate {
    [self stop];
}

- (void)__cbdl {
    [self.touchSignals emit:kSignalTakeAction];
}

- (void)addToRunLoop:(NSRunLoop *)runloop forMode:(NSString *)mode {
    [_dlink addToRunLoop:runloop forMode:mode];
}

- (void)removeFromRunLoop:(NSRunLoop *)runloop forMode:(NSString *)mode {
    [_dlink removeFromRunLoop:runloop forMode:mode];
}

@dynamic timestamp, duration, frameInterval;

- (CFTimeInterval)timestamp {
    return _dlink.timestamp;
}

- (CFTimeInterval)duration {
    return _dlink.duration;
}

- (NSInteger)frameInterval {
    return _dlink.frameInterval;
}

- (void)setFrameInterval:(NSInteger)frameInterval {
    _dlink.frameInterval = frameInterval;
}

@end

@interface CADisplayStage ()
{
    dispatch_semaphore_t _mtx_wait; // 调度运行的信号
    dispatch_queue_t _que; // 调度队列
}

@property (nonatomic, readonly) CADisplayLinkExt *dlink;

@end

@implementation CADisplayStage

SHARED_IMPL;

- (id)init {
    self = [super init];
    
    _dlink = [[CADisplayLinkExt alloc] init];
    [_dlink.signals connect:kSignalTakeAction withSelector:@selector(cbDL) ofTarget:self].thread = kSSlotCurrentThread;
   
    _que = dispatch_queue_create((char const*)&_que, DISPATCH_QUEUE_SERIAL);
    _mtx_wait = dispatch_semaphore_create(1);
    _asyncMode = YES;
    
    return self;
}

- (void)dealloc {
    _mtx_wait = NULL;
    [_dlink invalidate];
    ZERO_RELEASE(_dlink);
    [super dealloc];
}

- (void)start {
    if (_dlink.isRunning)
        return;
    
    [_dlink start];
}

- (void)stop {
    if (_dlink.isRunning == NO)
        return;
    
    [_dlink stop];
}

- (float)fps {
    return 1 / _dlink.duration * 100;
}

- (void)setFps:(float)fps {
    _dlink.frameInterval = ceilf(60 / fps);
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalTakeAction)
SIGNALS_END

- (void)cbDL {
    if (_asyncMode == NO) {
        if (dispatch_semaphore_wait(_mtx_wait, DISPATCH_TIME_NOW)) {
            LOG("DL 线程已经在等待");
            return;
        }
    }
    
    dispatch_async(_que, ^{
        // 激活信号
        [self.touchSignals emit:kSignalTakeAction];
    });
}

- (void)continuee {
    if (_asyncMode == NO) {
        dispatch_semaphore_signal(_mtx_wait);
    }
}

@end

@interface NSStylizedString (private)

@property (nonatomic, retain) NSAttributedString *unsafeAttributedString;

@end

@interface CAStylizedTextLayer ()

@property (nonatomic, retain) NSAttributedString *attributedString;

@end

@implementation CAStylizedTextLayer

- (id)init {
    self = [super init];
    self.contentsScale = kUIScreenScale;
    //self.rasterizationScale = kUIScreenScale;
    self.needsDisplayOnBoundsChange = YES;
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_string);
    ZERO_RELEASE(_attributedString);
    [super dealloc];
}

- (id<CAAction>)actionForKey:(NSString *)event {
    return nil;
}

- (void)setString:(NSStylizedString *)string {
    [string.signals disconnectToTarget:self];
    
    PROPERTY_RETAIN(_string, string);
    
    if (_string.unsafeAttributedString)
        self.attributedString = _string.unsafeAttributedString;
    else
        self.attributedString = _string.attributedString;
    
    [string.signals connect:kSignalRequestRedraw withSelector:@selector(setNeedsDisplay) ofTarget:self];
}

- (CGRect)boundsForDraw {
    CGRect bounds = self.bounds;
    if (!kIOS7Above && bounds.size.height < CGVALUEMAX) {
        // ios6 中出现：如果bounds过矮，导致 lines==0，所以手动设个最大
        bounds.size.height = CGVALUEMAX;
    }
    return bounds;
}

- (void)drawInContext:(CGContextRef)ctx {
    [super drawInContext:ctx];
    CGRect bounds = [self boundsForDraw];
    
    // Text ends up drawn inverted, so we have to reverse it.
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx, bounds.origin.x, bounds.origin.y + bounds.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    
    [CAStylizedTextLayer DrawStylizedString:_string
                           attributedString:_attributedString
                                  inContext:ctx
                                     inRect:bounds];
}

static BOOL CTLineNeedTruncation(CTLineBreakMode mode)
{
    BOOL ret = NO;
    switch (mode)
    {
        default: ret = NO; break;
        case kCTLineBreakByTruncatingHead:
        case kCTLineBreakByTruncatingTail:
        case kCTLineBreakByTruncatingMiddle:
            ret = YES;
            break;
    }
    return ret;
}

static CTLineTruncationType CTLineTruncationTypeFromCTLinebreakMode(CTLineBreakMode mode)
{
    CTLineTruncationType ret = kCTLineTruncationEnd;
    switch (mode)
    {
        default: break;
        case kCTLineBreakByTruncatingHead: ret = kCTLineTruncationStart; break;
        case kCTLineBreakByTruncatingTail: ret = kCTLineTruncationEnd; break;
        case kCTLineBreakByTruncatingMiddle: ret = kCTLineTruncationMiddle; break;
    }
    return ret;
}

+ (void)DrawStylizedString:(NSStylizedString*)stystr
          attributedString:(NSAttributedString*)attrstr
                 inContext:(CGContextRef)ctx
                    inRect:(CGRect)rect
{
    // 建立限制区域
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    
    // 实例化CT绘制句柄
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrstr);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    // 取得区域内存在多少航
    NSArray* lines = (NSArray*)CTFrameGetLines(frame);
    
    // 获得每一行的起始
    CGPoint origins[lines.count];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
    
    // 是否需要断行显示
    CTLineBreakMode const trucationMode = ((NSFullStylization*)stystr.touchStyle).CTLinebreakMode;
    BOOL const needTrucation = stystr.touchStyle && CTLineNeedTruncation(trucationMode);
    
    // 如果不设置断行，则一次性输出即可
    if (needTrucation == NO)
        CTFrameDraw(frame, ctx);
    
    // 处理每一行
    for (NSUInteger idxLine = 0; idxLine < lines.count; ++idxLine)
    {
        CTLineRef line = (CTLineRef)[lines objectAtIndex:idxLine def:nil];
        CGPoint posLine = origins[idxLine];
        
        // 一次性画图，因为不能绘制断行，所以修改为逐行绘制
        if (needTrucation)
        {
            // 移动绘制位置
            CGContextSetTextPosition(ctx, posLine.x, posLine.y);

            if (idxLine + 1 != lines.count)
            {
                // 绘制普通行
                CGContextSetTextPosition(ctx, posLine.x, posLine.y);
                CTLineDraw(line, ctx);
            }
            else
            {
                // 如果还有没有显示的，需要断句
                CFRange range = CTLineGetStringRange(line);
                CFIndex full = CFAttributedStringGetLength((CFAttributedStringRef)attrstr);
                if (range.length && (CFMaxRange(range) < full))
                {
                    NSRange effetiveRange;
                    CFDictionaryRef attrs = (CFDictionaryRef)[attrstr attributesAtIndex:range.location effectiveRange:&effetiveRange];
                    CFAttributedStringRef truncationString = CFAttributedStringCreate(NULL, CFSTR("\u2026"), attrs);
                    CTLineRef truncationToken = CTLineCreateWithAttributedString(truncationString);
                    CFRelease(truncationString);
                    
                    // 获得最后一个字的大小
                    CGFloat width = CTLineGetOffsetForStringIndex(line, CFMaxRange(range) - 1, NULL);
                    
                    // 绘制最后一行，附带断行显示
                    CTLineRef lineTrunc = CTLineCreateTruncatedLine(line,
                                                                    width,
                                                                    CTLineTruncationTypeFromCTLinebreakMode(trucationMode),
                                                                    truncationToken);
                    CTLineDraw(lineTrunc, ctx);
                    
                    CFSAFE_RELEASE(truncationToken);
                    CFSAFE_RELEASE(lineTrunc);
                }
                else
                {
                    CTLineDraw(line, ctx);
                }
            }
        }
        
        // 提取自定义元素
        for (id each in (NSArray*)CTLineGetGlyphRuns(line))
        {
            CTRunRef run = (CTRunRef)each;
            CFRange rgnRun = CTRunGetStringRange(run);
            
            CGRect rc;
            CGFloat ascent, descent;
            rc.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            rc.size.height = ascent + descent;
            
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, rgnRun.location, NULL);
            rc.origin.x = posLine.x + rect.origin.x + xOffset;
            rc.origin.y = posLine.y + rect.origin.y - descent;
            
            // 绘制 image
            id<NSStylizedItemImage> image = [stystr imageOnRange:NSMakeRange(rgnRun.location, rgnRun.length) strict:YES];
            if (image) {
                rc = CGRectApplyMargin(rc, [image margin]);
                
                // 调整一下偏移
                CGRect prc = [image preferredRect];
                if (prc.origin.x) {
                    rc.origin.x += prc.origin.x;
                    rc.size.width -= prc.origin.x;
                }
                
                CGContextDrawImage(ctx, rc, [image image].CGImage);
            }
            
            // 绘制自定义属性
            NSDictionary* attrs = (NSDictionary*)CTRunGetAttributes(run);
            if ([attrs objectForKey:kCTCustomDeleteLineAttributeName])
            {
                CGLine* line = [attrs objectForKey:kCTCustomDeleteLineAttributeName];
                [line drawLineFrom:CGRectLeftCenter(rc)
                                to:CGRectRightCenter(rc)
                         inContext:ctx];
            }
            if ([attrs objectForKey:kCTCustomBottomLineAttributeName])
            {
                CGLine* line = [attrs objectForKey:kCTCustomBottomLineAttributeName];
                [line drawLineFrom:CGRectLeftTop(rc)
                                to:CGRectRightTop(rc)
                         inContext:ctx];
            }
        }
    }
    
    CFRelease(framesetter);
    CFRelease(path);
    CFRelease(frame);
}

- (id<NSStylizedItem>)itemAtPoint:(CGPoint)pt {
    CGRect rect = [self boundsForDraw];

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    
    // Create the frame and draw it into the graphics context
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedString);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    // Draw embeded images.
    NSArray* lines = (NSArray*)CTFrameGetLines(frame);
    
    // Get line start positions.
    CGPoint origins[[lines count]];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
    
    id<NSStylizedItem> ret = nil;
    for (id each in lines)
    {
        CTLineRef line = (CTLineRef)each;
        CFIndex strpos = CTLineGetStringIndexForPosition(line, pt);
        
        NSRange rgn = NSRangeZero;
        for (id<NSStylizedItem> each in self.string.items) {
            rgn.length = each.placedString.length;
            if (NSRangeContain(rgn, strpos)) {
                ret = each;
                break;
            }
            rgn.location += rgn.length;
        }
        
        if (ret)
            break;
    }
    
    CFRelease(framesetter);
    CFRelease(path);
    CFRelease(frame);

    return ret;
}

@end

@implementation NSStylizedString (CALayer)

- (BOOL)hasImage {
    for (id each in self.items) {
        if ([each conformsToProtocol:@protocol(NSStylizedItemImage)])
            return YES;
    }
    return NO;
}

- (id<NSStylizedItemImage>)imageOnRange:(NSRange)rgnin strict:(BOOL)strict {
    NSRange rgn = NSMakeRange(0, 0);
    for (id<NSStylizedItem> each in self.items) {
        rgn.length = each.placedString.length;
        
        BOOL isOn = NO;
        
        if (strict == NO)
        {
            if (!isOn &&
                rgnin.location >= rgn.location &&
                rgnin.location <= NSMaxRange(rgn))
            {
                isOn = YES;
            }
            
            if (!isOn &&
                rgn.location >= rgnin.location &&
                rgn.location <= NSMaxRange(rgnin))
            {
                isOn = YES;
            }
        }
        else
        {
            isOn = rgn.location == rgnin.location && rgn.length == rgnin.length;
        }
        
        if (isOn && [each conformsToProtocol:@protocol(NSStylizedItemImage)]) {
            return (id<NSStylizedItemImage>)each;
        }
        
        rgn.location += each.placedString.length;
        if (rgn.location > NSMaxRange(rgnin))
            return nil;
    }
    
    return nil;
}

@end

@interface CAGestureRecognizer ()

- (void)doPosition;

@end

@implementation CAGestureRecognizer

- (void)onInit {
    [super onInit];
    _enable = YES;
    _thresholdInterval = 5;
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalGestureRecognized)
SIGNALS_END

- (void)reset {
    _touchsCount = 0;
    _velocity = CGPointZero;
}

- (void)addPosition:(CGPoint)pos {
    if (_enable == NO)
        return;
    
    // 第一次移动，不做判断
    if (_touchsCount == 0) {
        _lastPosition = _currentPosition = pos;
        _lastTime = _currentTime = [NSTime Now];
        ++_touchsCount;
        return;
    }
    
    // 其后的移动
    _lastTime = _currentTime;
    _currentTime = [NSTime Now];
    _deltaTime = _currentTime - _lastTime;
    if (_deltaTime == 0)
        _deltaTime = 1;
    
    _lastPosition = _currentPosition;
    _currentPosition = pos;
    _deltaPosition = CGPointSubPoint(_currentPosition, _lastPosition);
    
    _velocity.x = _deltaPosition.x / _deltaTime;
    _velocity.y = _deltaPosition.y / _deltaTime;
    
    // 计算一次
    if (_deltaTime <= _thresholdInterval) {
        [self doPosition];
    }
    
    // 移动次数
    ++_touchsCount;
}

- (void)doPosition {
    PASS;
}

- (CGDirection)majorDirection {
    CGDirection ret = kCGDirectionUnknown;
    if (_deltaPosition.x > 0)
        ret |= kCGDirectionToRight;
    else if (_deltaPosition.x < 0)
        ret |= kCGDirectionToLeft;
    if (_deltaPosition.y > 0)
        ret |= kCGDirectionToBottom;
    else if (_deltaPosition.y < 0)
        ret |= kCGDirectionToTop;
    return ret;
}

@end

@implementation CADragGestureRecognizer

- (void)onInit {
    [super onInit];
    _threshold = CGPointMake(5, 5);
    _direction = kCGDirectionHorizontal | kCGDirectionVertical;
}

- (void)doPosition {
    [super doPosition];
    
    if (fabs(self.deltaPosition.x) > fabs(_threshold.x))
    {
        if (self.deltaPosition.x > 0) {
            if ([NSMask Mask:kCGDirectionToRight Value:_direction])
                [self.signals emit:kSignalGestureRecognized withResult:@(kCGDirectionToRight)];
        } else {
            if ([NSMask Mask:kCGDirectionToLeft Value:_direction])
                [self.signals emit:kSignalGestureRecognized withResult:@(kCGDirectionToLeft)];
        }
    }
    
    if (fabs(self.deltaPosition.y) > fabs(_threshold.y))
    {
        if (self.deltaPosition.y > 0) {
            if ([NSMask Mask:kCGDirectionToBottom Value:_direction])
                [self.signals emit:kSignalGestureRecognized withResult:@(kCGDirectionToBottom)];
        } else {
            if ([NSMask Mask:kCGDirectionToTop Value:_direction])
                [self.signals emit:kSignalGestureRecognized withResult:@(kCGDirectionToTop)];
        }
    }
}

@end

static CGPoint PointOnCubicBezier(CGPoint pt0, CGPoint pt1, float t)
{
    float ax, bx, cx; float ay, by, cy;
    float tSquared, tCubed;
    CGPoint result;
    cx = 3.0 * pt0.x;
    bx = 3.0 * (pt1.x - pt0.x) - cx;
    ax = 1.f - cx - bx;
    cy = 3.0 * (pt0.y);
    by = 3.0 * (pt1.y - pt0.y) - cy;
    ay = 1.f - cy - by;
    tSquared = t * t;
    tCubed = tSquared * t;
    result.x = (ax * tCubed) + (bx * tSquared) + (cx * t);
    result.y = (ay * tCubed) + (by * tSquared) + (cy * t);
    return result; 
}

NSString * const kCAMediaTimingFunctionCustom = @"::ca::timingfunction::custom";
NSString* const kCAMediaTimingFunctionSpring = @"::ca::timingfunction::spring";

@interface CAKeyframeProducer ()
{
    float _springFactor;
}

@end

@implementation CAKeyframeProducer

- (void)onInit {
    [super onInit];
    self.timefunction = kCAMediaTimingFunctionDefault;
}

- (void)onFin {
    [self stop];
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalStart)
SIGNAL_ADD(kSignalStop)
SIGNAL_ADD(kSignalValueChanged)
SIGNALS_END

- (void)start {
    [self.touchSignals emit:kSignalStart];
    _springFactor = 1;
}

- (void)stop {
    [self.touchSignals emit:kSignalStop];
}

- (void)frame:(float)ra {
    if (ra > 1)
        ra = 1;
    
    // 偏移时间函数
    if (self.timefunction == kCAMediaTimingFunctionLinear) {
        PASS;
    }
    else if (self.timefunction == kCAMediaTimingFunctionEaseIn) {
        CGPoint pt = PointOnCubicBezier(CGPointMake(0, 1), CGPointMake(1, 1), ra);
        ra = pt.y;
    }
    else if (self.timefunction == kCAMediaTimingFunctionEaseOut) {
        CGPoint pt = PointOnCubicBezier(CGPointMake(1, 0), CGPointMake(1, 0.3), ra);
        ra = pt.y;
    }
    else if (self.timefunction == kCAMediaTimingFunctionEaseInEaseOut) {
        CGPoint pt = PointOnCubicBezier(CGPointMake(0.2, 0.6), CGPointMake(0.6, 0.2), ra);
        ra = pt.y;
    }
    else if (self.timefunction == kCAMediaTimingFunctionSpring) {
        ra = 1 - exp(-7 * ra) * cos((M_2PI * 5 * ra + M_PI_2) * ra);
    }
    else if (self.timefunction == kCAMediaTimingFunctionCustom) {
        CGPoint pt = PointOnCubicBezier(_controlPointA, _controlPointB, ra);
        ra = pt.y;
    }
    
    [self.touchSignals emit:kSignalValueChanged withResult:@(ra)];
}

@end

@interface CAAnimationProducer ()
{
    NSInteger _countFrames; // 一共多少帧
    NSInteger _idxFrame; // 当前帧
}

@property (nonatomic, readonly) CADisplayLinkExt *dl;
+ (NSMutableArray*)AnimationProducers;

@end

@implementation CAAnimationProducer

- (void)onInit {
    [super onInit];
    _dl = [[CADisplayLinkExt alloc] init];
    [_dl.signals connect:kSignalTakeAction withSelector:@selector(__cb_frame) ofTarget:self];
    
    // 启动的时候需要把自己放到全局里面，结束时再移除，如果名字有冲突，则停止掉之前的
    with([self.signals connect:kSignalStart withSelector:@selector(__ap_start) ofTarget:self], {
        it.thread = kSSlotCurrentThread;
    });
    with([self.signals connect:kSignalStop withSelector:@selector(__ap_stop) ofTarget:self], {
        it.thread = kSSlotCurrentThread;
        it.priority = kSSlotPriorityLow;
    });
}

- (void)onFin {
    ZERO_RELEASE(_dl);
    ZERO_RELEASE(_keyname);
    [super onFin];
}

+ (NSMutableArray*)AnimationProducers {
    static NSMutableArray* aps = nil;
    DISPATCH_ONCE_EXPRESS({
        aps = [NSMutableArray new];
    });
    return aps;
}

- (void)__ap_start {
    NSMutableArray* aps = [CAAnimationProducer AnimationProducers];
    if (self.keyname) {
        for (CAAnimationProducer* ap in aps) {
            if ([self.keyname isEqualToString:ap.keyname])
                [ap stop];
        }
    }
    [aps addObject:self];
}

- (void)__ap_stop {
    NSMutableArray* aps = [CAAnimationProducer AnimationProducers];
    [aps removeObject:self];
}

- (void)start {
    _idxFrame = 0;
    [self.dl start];
    
    [super start];
}

- (void)stop {
    if (_dl.isRunning == NO)
        return;
    
    [_dl stop];
    [super stop];
}

- (void)__cb_frame {
    if (_idxFrame == 0) {
        ASSERTMSG(self.dl.duration != 0, @"DisplayLink 的 duration 不能为0");
        _countFrames = [NSMath CeilFloat:self.duration r:self.dl.duration];
    }
    
    // 计算当前的位置
    float ra = _idxFrame++ / (float)_countFrames;
    [self frame:ra];
    
    if (_idxFrame > _countFrames) {
        [self stop];
        return;
    }
}

+ (instancetype)FindProducer:(NSString*)keyname {
    if (keyname == nil)
        return nil;
    return [[CAAnimationProducer AnimationProducers] objectWithQuery:^id(CAAnimationProducer* l) {
        if ([keyname isEqualToString:l.keyname])
            return l;
        return nil;
    }];
}

+ (void)Stop:(NSString*)keyname {
    [[CAAnimationProducer FindProducer:keyname] stop];
}

+ (void)animates:(void (^)(CAAnimationProducer *))ani progress:(void (^)(float, float))progress {
    [self.class animates:ani progress:progress completion:nil];
}

+ (void)animates:(void(^)(CAAnimationProducer* ap))ani progress:(void(^)(float p, float d))progress completion:(void (^)())completion {
    CAAnimationProducer* ap = [CAAnimationProducer temporary];
    __block float np = 0;
    [ap.signals connect:kSignalValueChanged withBlock:^(SSlot *s) {
        float p = [s.data.object floatValue];
        float d = p - np;
        progress(p, d);
        np = p;
    }].thread = kSSlotCurrentThread;
    [ap.signals connect:kSignalStop withBlock:^(SSlot *s) {
        if (completion)
            completion();
    }].thread = kSSlotCurrentThread;
    ani(ap);
    [ap start];
}

@end
