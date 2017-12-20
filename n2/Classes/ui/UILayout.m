
# import "Common.h"
# import "UILayout.h"
# import "NntLayout.h"

@interface UILayoutBlock : NSObject

@property (nonatomic, retain) UIView *view;
@property (nonatomic, copy) void(^block)(CGRect rc, UIView* view);

@end

@implementation UILayoutBlock

- (void)dealloc {
    ZERO_RELEASE(_view);
    [_block release];
    [super dealloc];
}

@end

@interface UILayout () {
    
    @public
    Layout* _layout;
    Linear* _linear;
    
}

@property (nonatomic, readonly) NSMutableArray* subs;
@property (nonatomic, retain) Layout* layout;
@property (nonatomic, retain) Linear* linear;

@end

@implementation UILayout

@synthesize layout = _layout, linear = _linear;

- (id)init {
    self = [super init];
    _subs = [[NSMutableArray alloc] init];
    return self;
}

- (id)initWithRect:(CGRect)rc withSpacing:(CGFloat)space {
    self = [self init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_layout);
    ZERO_RELEASE(_linear);
    ZERO_RELEASE(_subs);
    ZERO_RELEASE(_setblock);
    
    [super dealloc];
}

- (void)reset {
    [_layout reset];
    [_linear stop];
    [_subs removeAllObjects];
}

@dynamic rect;

- (CGRect)rect {
    return _layout.rect;
}

- (void)setRect:(CGRect)rect {
    [_layout setOriginRect:rect];
    [_linear resetLinearByLayout:_layout];
}

@dynamic position;

- (CGPoint)position {
    return _layout.position;
}

@dynamic margin, padding;

- (CGMargin)margin {
    return _layout.margin;
}

- (void)setMargin:(CGMargin)margin {
    _layout.margin = margin;
}

- (CGPadding)padding {
    return _layout.padding;
}

- (void)setPadding:(CGPadding)padding {
    _layout.padding = padding;
    [_linear resetLinearByLayout:_layout];
}

- (id)addAspectWithX:(CGFloat)x andY:(CGFloat)y toView:(UIView *)view {
    [_linear addAspectWithX:x andY:y];
    [_subs addObjectSafe:view];
    return self;
}

- (id)addFlex:(CGFloat)flex toView:(UIView *)view {
    [_linear addFlex:flex];
    [_subs addObjectSafe:view];
    return self;
}

- (id)addPixel:(CGFloat)pixel toView:(UIView*)view {
    [_linear addPixel:pixel];
    [_subs addObjectSafe:view];
    return self;
}

- (id)addFlex:(CGFloat)flex toView:(UIView*)view set:(void(^)(CGRect rc, UIView* view))block {
    UILayoutBlock* lb = [[UILayoutBlock alloc] init];
    lb.view = view;
    lb.block = block;

    [_linear addFlex:flex];
    [_subs addObject:lb];
    
    SAFE_RELEASE(lb);
    return self;
}

- (id)addPixel:(CGFloat)pixel toView:(UIView*)view set:(void(^)(CGRect rc, UIView* view))block {
    UILayoutBlock* lb = [[UILayoutBlock alloc] init];
    lb.view = view;
    lb.block = block;
    
    [_linear addPixel:pixel];
    [_subs addObject:lb];
    
    SAFE_RELEASE(lb);
    return self;
}

- (id)addFlex:(CGFloat)flex withSpacing:(CGFloat)space VBox:(void (^)(UIVBox *))block {
    return [self addFlex:flex withSpacing:space VBox:block set:nil];
}

- (id)addFlex:(CGFloat)flex withSpacing:(CGFloat)space VBox:(void (^)(UIVBox *))block set:(void (^)(CGRect))setblock {
    [_linear addFlex:flex];
    
    UIVBox* sub = [[UIVBox alloc] initWithRect:CGRectZero withSpacing:space];
    sub.setblock = setblock;
    block(sub);
    [_subs addObject:sub];
    SAFE_RELEASE(sub);
    
    return self;
}

- (id)addFlex:(CGFloat)flex withSpacing:(CGFloat)space HBox:(void (^)(UIHBox *))block {
    return [self addFlex:flex withSpacing:space HBox:block set:nil];
}

- (id)addFlex:(CGFloat)flex withSpacing:(CGFloat)space HBox:(void(^)(UIHBox* box))block set:(void (^)(CGRect))setblock {
    [_linear addFlex:flex];
    
    UIHBox* sub = [[UIHBox alloc] initWithRect:CGRectZero withSpacing:space];
    sub.setblock = setblock;
    block(sub);
    [_subs addObject:sub];
    SAFE_RELEASE(sub);
    
    return self;
}

- (id)addFlex:(CGFloat)flex withSpacing:(CGFloat)space HFlow:(void(^)(UIHFlow* box))block {
    return [self addFlex:flex withSpacing:space HFlow:block set:nil];
}

- (id)addFlex:(CGFloat)flex withSpacing:(CGFloat)space HFlow:(void(^)(UIHFlow* box))block set:(void(^)(CGRect rc))setblock {
    [_linear addFlex:flex];
    
    UIHFlow* sub = [[UIHFlow alloc] initWithRect:CGRectZero withSpacing:space];
    sub.setblock = setblock;
    block(sub);
    [_subs addObject:sub];
    SAFE_RELEASE(sub);
    
    return self;
}

- (id)addPixel:(CGFloat)pixel withSpacing:(CGFloat)space VBox:(void (^)(UIVBox *))block {
    return [self addPixel:pixel withSpacing:space VBox:block set:nil];
}

- (id)addPixel:(CGFloat)pixel withSpacing:(CGFloat)space VBox:(void(^)(UIVBox* box))block set:(void (^)(CGRect))setblock {
    [_linear addPixel:pixel];
    
    UIVBox* sub = [[UIVBox alloc] initWithRect:CGRectZero withSpacing:space];
    sub.setblock = setblock;
    block(sub);
    [_subs addObject:sub];
    SAFE_RELEASE(sub);
    
    return self;
}

- (id)addPixel:(CGFloat)pixel withSpacing:(CGFloat)space HBox:(void (^)(UIHBox *))block {
    return [self addPixel:pixel withSpacing:space HBox:block set:nil];
}

- (id)addPixel:(CGFloat)pixel withSpacing:(CGFloat)space HBox:(void(^)(UIHBox* box))block set:(void (^)(CGRect))setblock {
    [_linear addPixel:pixel];
    
    UIHBox* sub = [[UIHBox alloc] initWithRect:CGRectZero withSpacing:space];
    sub.setblock = setblock;
    block(sub);
    [_subs addObject:sub];
    SAFE_RELEASE(sub);
    
    return self;
}

- (id)addPixel:(CGFloat)pixel withSpacing:(CGFloat)space HFlow:(void(^)(UIHFlow* box))block {
    return [self addPixel:pixel withSpacing:space HFlow:block set:nil];
}

- (id)addPixel:(CGFloat)pixel withSpacing:(CGFloat)space HFlow:(void(^)(UIHFlow* box))block set:(void(^)(CGRect rc))setblock {
    [_linear addPixel:pixel];
    
    UIHFlow* sub = [[UIHFlow alloc] initWithRect:CGRectZero withSpacing:space];
    sub.setblock = setblock;
    block(sub);
    [_subs addObject:sub];
    SAFE_RELEASE(sub);
    
    return self;
}

- (id)addAspectWithX:(CGFloat)x andY:(CGFloat)y withSpacing:(CGFloat)space VBox:(void(^)(UIVBox* box))block {
    [_linear addAspectWithX:x andY:y];
    
    UIVBox* sub = [[UIVBox alloc] initWithRect:CGRectZero withSpacing:space];
    block(sub);
    [_subs addObject:sub];
    SAFE_RELEASE(sub);
    
    return self;
}

- (id)addAspectWithX:(CGFloat)x andY:(CGFloat)y withSpacing:(CGFloat)space HBox:(void(^)(UIHBox* box))block {
    [_linear addAspectWithX:x andY:y];
    
    UIHBox* sub = [[UIHBox alloc] initWithRect:CGRectZero withSpacing:space];
    block(sub);
    [_subs addObject:sub];
    SAFE_RELEASE(sub);
    
    return self;
}

- (id)addAspectWithX:(CGFloat)x andY:(CGFloat)y toView:(UIView*)view set:(void(^)(CGRect rc, UIView* view))block {
    UILayoutBlock* lb = [[UILayoutBlock alloc] init];
    lb.view = view;
    lb.block = block;
    
    [_linear addAspectWithX:x andY:y];
    [_subs addObject:lb];
    
    SAFE_RELEASE(lb);
    return self;
}

- (void)apply {
    for (id sub in _subs) {
        
        CGRect rc = [_layout addLinear:_linear];
        rc = CGRectIntegralEx(rc);

        //LOG(NSStringFromCGRect(rc).UTF8String);
        
        if ([sub isKindOfClass:[NSNull class]])
            continue;
        
        if ([sub isKindOfClass:[UIView class]]) {
            UIView* view = (UIView*)sub;
            view.frame = rc;
            continue;
        }
        
        if ([sub isKindOfClass:[UILayoutBlock class]]) {
            UILayoutBlock* lb = (UILayoutBlock*)sub;
            lb.block(rc, lb.view);
            continue;
        }
        
        if ([sub isKindOfClass:[UILayout class]]) {
            
            UILayout* lyt = (UILayout*)sub;
            
            // 是否绑定了一个 inView
            if (lyt.inView) {
                
                // 设置 inView 大小
                lyt.inView.frame = rc;
                
                // 使用 inView 的 bounds 来布局子控件
                [lyt setRect:lyt.inView.rectForLayout];
                
            } else {
                
                // 标准的大小
                [lyt setRect:rc];
                
            }
            
            // 应用子布局
            [lyt apply];
            
            continue;
        }
        
    }
    
    if (self.setblock)
        (self.setblock)(self.layout.originRect);
}

- (void)setMinFlexValue:(CGFloat)minFlexValue {
    _linear.minFlexValue = minFlexValue;
}

- (CGFloat)minFlexValue {
    return _linear.minFlexValue;
}

- (id)addFlex:(CGFloat)flex VBox:(void(^)(UIVBox* box))block {
    return [self addFlex:flex withSpacing:0 VBox:block];
}

- (id)addFlex:(CGFloat)flex HBox:(void(^)(UIHBox* box))block {
    return [self addFlex:flex withSpacing:0 HBox:block];
}

- (id)addFlex:(CGFloat)flex HFlow:(void (^)(UIHFlow *))block {
    return [self addFlex:flex HFlow:block set:nil];
}

- (id)addFlex:(CGFloat)flex VBox:(void(^)(UIVBox* box))block set:(void(^)(CGRect rc))sblock {
    return [self addFlex:flex withSpacing:0 VBox:block set:sblock];
}

- (id)addFlex:(CGFloat)flex HBox:(void(^)(UIHBox* box))block set:(void(^)(CGRect rc))sblock {
    return [self addFlex:flex withSpacing:0 HBox:block set:sblock];
}

- (id)addFlex:(CGFloat)flex HFlow:(void(^)(UIHFlow* box))block set:(void(^)(CGRect rc))sblock {
    return [self addFlex:flex withSpacing:0 HFlow:block set:sblock];
}

- (id)addPixel:(CGFloat)pixel VBox:(void(^)(UIVBox* box))block {
    return [self addPixel:pixel withSpacing:0 VBox:block];
}

- (id)addPixel:(CGFloat)pixel HBox:(void(^)(UIHBox* box))block {
    return [self addPixel:pixel withSpacing:0 HBox:block];
}

- (id)addPixel:(CGFloat)pixel HFlow:(void(^)(UIHFlow* box))block {
    return [self addPixel:pixel withSpacing:0 HFlow:block];
}

- (id)addPixel:(CGFloat)pixel VBox:(void(^)(UIVBox* box))block set:(void(^)(CGRect rc))sblock {
    return [self addPixel:pixel withSpacing:0 VBox:block set:sblock];
}

- (id)addPixel:(CGFloat)pixel HBox:(void(^)(UIHBox* box))block set:(void(^)(CGRect rc))sblock {
    return [self addPixel:pixel withSpacing:0 HBox:block set:sblock];
}

- (id)addPixel:(CGFloat)pixel HFlow:(void(^)(UIHFlow* box))block set:(void(^)(CGRect rc))sblock {
    return [self addPixel:pixel withSpacing:0 HFlow:block set:sblock];
}

- (id)addAspectWithX:(CGFloat)x andY:(CGFloat)y VBox:(void(^)(UIVBox* box))block {
    return [self addAspectWithX:x andY:y withSpacing:0 VBox:block];
}

- (id)addAspectWithX:(CGFloat)x andY:(CGFloat)y HBox:(void(^)(UIHBox* box))block {
    return [self addAspectWithX:x andY:y withSpacing:0 HBox:block];
}

@end

@implementation UIBox

+ (id)boxWithRect:(CGRect)rc withSpacing:(CGFloat)space {
    if (rc.size.width > rc.size.height)
        return [UIHBox boxWithRect:rc withSpacing:space];
    return [UIVBox boxWithRect:rc withSpacing:space];
}

+ (id)boxWithRect:(CGRect)rc {
    return [[self class] boxWithRect:rc withSpacing:0];
}

@end

@implementation UIVBox

+ (id)boxWithRect:(CGRect)rc withSpacing:(CGFloat)space {
    return [[[[self class] alloc] initWithRect:rc withSpacing:space] autorelease];
}

- (id)initWithRect:(CGRect)rc withSpacing:(CGFloat)space {
    self = [super initWithRect:rc withSpacing:space];
    _layout = [[LayoutVBox alloc] initWithRect:rc withSpacing:space];
    _linear = [[Linear alloc] initWithVBoxLayout:(LayoutVBox*)_layout];
    return self;
}

@end

@implementation UIHBox

+ (id)boxWithRect:(CGRect)rc withSpacing:(CGFloat)space {
    return [[[[self class] alloc] initWithRect:rc withSpacing:space] autorelease];
}

- (id)initWithRect:(CGRect)rc withSpacing:(CGFloat)space {
    self = [super initWithRect:rc withSpacing:space];
    _layout = [[LayoutHBox alloc] initWithRect:rc withSpacing:space];
    _linear = [[Linear alloc] initWithHBoxLayout:(LayoutHBox*)_layout];
    return self;
}

@end

@interface UIHFlow ()

@property (nonatomic, readonly) NSMutableArray *sizes;
@property (nonatomic, readonly) NSMutableArray *blocks;
@property (nonatomic, readwrite) NSUInteger row;

@end

@interface UIView (flow)

@property (nonatomic, assign) NSUInteger flowSegmentIndex;
@property (nonatomic, assign) UIFlowOption flowOptions;

@end

@implementation UIView (flow)

NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR(UIView, flowSegmentIndex, setFlowSegmentIndex, NSUInteger, @(val), [val unsignedIntegerValue], RETAIN_NONATOMIC);
NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR(UIView, flowOptions, setFlowOptions, UIFlowOption, @(val), [val unsignedIntegerValue], RETAIN_NONATOMIC);

@end

@implementation UIHFlow

+ (id)flowWithRect:(CGRect)rc {
    return [[[[self class] alloc] initWithRect:rc withSpacing:0] autorelease];
}

+ (id)flowWithRect:(CGRect)rc withSpacing:(CGFloat)spacing {
    return [[[[self class] alloc] initWithRect:rc withSpacing:spacing] autorelease];
}

- (id)initWithRect:(CGRect)rc withSpacing:(CGFloat)space {
    self = [super initWithRect:rc withSpacing:space];
    _layout = [[LayoutHFlow alloc] initWithRect:rc withSpacing:space];
    _sizes = [[NSMutableArray alloc] init];
    _blocks = [[NSMutableArray alloc] init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_sizes);
    ZERO_RELEASE(_blocks);
    [super dealloc];
}

- (id)addSize:(CGSize)size toView:(UIView *)view {
    return [self addSize:size toView:view set:nil];
}

- (id)addSize:(CGSize)size toView:(UIView*)view withOptions:(UIFlowOption)options {
    return [self addSize:size toView:view withOptions:options set:nil];
}

- (id)addSize:(CGSize)size toView:(UIView*)view set:(void(^)(CGRect rc, UIView* view))block {
    return [self addSize:size toView:view withOptions:kUIFlowOptionNull set:block];
}

- (id)addSize:(CGSize)size toView:(UIView*)view withOptions:(UIFlowOption)options set:(void (^)(CGRect, UIView *))block {
    view.flowOptions = options;
    [self.subs addObjectSafe:view];
    [self.sizes addObject:[NSSize size:size]];
    if (block)
        [self.blocks addObject:[NSBlockObject block:block]];
    return self;
}

- (void)apply {
    for (UIView* each in self.subs) {
        if ([each isKindOfClass:[NSNull class]])
            continue;
        each.flowSegmentIndex = -1;
    }
    
    typedef void (^flowcb_t)(CGRect rc, UIView* view);
    
    for (int i = 0; i < self.subs.count; ++i) {
        id sub = [self.subs objectAtIndexSafe:i];
        NSSize* sz = [self.sizes objectAtIndex:i];
        NSBlockObject* bo = [self.blocks objectAtIndex:i def:nil];
        flowcb_t cb = (flowcb_t)bo.block;
        
        LayoutHFlow* flow = (LayoutHFlow*)_layout;
        CGRect rc = [flow strideSize:sz.size];
        rc = CGRectIntegralEx(rc);
        
        if (_row != flow.row)
        {
            // 出现行变动
            if (_fillMode)
            {
                // 填充模式
                NSArray* passed = [self.subs arrayWithCollector:^id(id l) {
                    if ([l flowSegmentIndex] == _row)
                        return l;
                    return nil;
                }];
                
                if (passed.count)
                {
                    CGFloat val = self.rect.size.width;
                    val -= CGRectGetMaxX([passed.lastObject frame]) + self.margin.right;
                    
                    // 计算出参与增长的元素
                    NSUInteger count = [passed countByCollector:^NSInteger(UIView* each) {
                        if ([NSMask Mask:kUIFlowOptionFix Value:each.flowOptions])
                            return 0;
                        return 1;
                    }];
                    
                    if (count)
                        val = val / count; // 计算出每一个需要增加的宽度
                    else
                        val = 0;
                    
                    for (uint i = 0, j = 0; i < passed.count; ++i, ++j)
                    {
                        UIView* view = [passed objectAtIndex:i];
                        NSBlockObject* bo = [self.blocks objectAtIndex:[self.subs indexOfObject:view] def:nil];
                        flowcb_t cb = (flowcb_t)bo.block;
                        
                        CGRect rc = view.frame;
                        if (i != 0)
                            rc.origin.x += val * j;
                        
                        if ([NSMask Mask:kUIFlowOptionFix Value:view.flowOptions] == NO)
                            rc.size.width += val;
                        else
                            j = MIN_SUB(j, 1, -1);
                        //rc = CGRectIntegralEx(rc);
                        
                        if (cb) {
                            cb(rc, view);
                        } else {
                            view.frame = rc;
                        }
                    }
                }
            }
            
            _row = flow.row;
        }
        [sub setFlowSegmentIndex:_row];

        if (cb) {
            cb(rc, sub);
        } else {
            [sub setFrame:rc];
        }
    }
    
    // 如果是最后一行，需要单独处理一下
    if (_fillMode && _row != 0)
    {
        // 填充模式
        NSArray* passed = [self.subs arrayWithCollector:^id(id l) {
            if ([l flowSegmentIndex] == _row)
                return l;
            return nil;
        }];
        
        if (passed.count)
        {
            CGFloat val = self.rect.size.width;
            val -= CGRectGetMaxX([passed.lastObject frame]) + self.margin.right;
            
            // 计算出参与增长的元素
            NSUInteger count = [passed countByCollector:^NSInteger(UIView* each) {
                if ([NSMask Mask:kUIFlowOptionFix Value:each.flowOptions])
                    return 0;
                return 1;
            }];
            
            if (count)
                val = val / count; // 计算出每一个需要增加的宽度
            else
                val = 0;
            
            for (uint i = 0, j = 0; i < passed.count; ++i, ++j)
            {
                UIView* view = [passed objectAtIndex:i];
                NSBlockObject* bo = [self.blocks objectAtIndex:[self.subs indexOfObject:view] def:nil];
                flowcb_t cb = (flowcb_t)bo.block;
                
                CGRect rc = view.frame;
                if (i != 0)
                    rc.origin.x += val * j;
                
                if ([NSMask Mask:kUIFlowOptionFix Value:view.flowOptions] == NO)
                    rc.size.width += val;
                else
                    j = MIN_SUB(j, 1, -1);
                //rc = CGRectIntegralEx(rc);

                if (cb) {
                    cb(rc, view);
                } else {
                    view.frame = rc;
                }
            }
        }
    }
}

@end
