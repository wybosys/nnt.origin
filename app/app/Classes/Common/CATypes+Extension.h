
# ifndef __CATYPES_EXTENSION_B70D09EB4EB94E818872B4B8C5BA8084_H_INCLUDED
# define __CATYPES_EXTENSION_B70D09EB4EB94E818872B4B8C5BA8084_H_INCLUDED

# import "NSTypes+Extension.h"

extern CGFloat kCAAnimationDuration;

# define ANIMATEXPRESS(exp) \
[UIView animateWithDuration:kCAAnimationDuration animations:^{ \
exp; \
}];

@interface NSObject (ca_extension)

- (void)animateData;

@end

@interface CALayer (extension)

// 做成圆形
- (void)roundlize;

// 做成圆角
- (void)roundlize:(CGFloat)val;

// 直接设置大小属性
- (void)setWidth:(CGFloat)val;
- (void)setHeight:(CGFloat)val;
- (void)setSize:(CGSize)sz;

// 在layer上展示动画
- (void)addAnimation:(CAAnimation*)anim;
- (void)addAnimation:(CAAnimation*)ani completion:(void(^)())block;

// 展示一组动画
- (NSObject*)addAnimations:(NSArray*)anims;
- (NSObject*)addAnimations:(NSArray*)anims completion:(void(^)())block;

// 停止动画
- (void)stopAnimation:(CAAnimation*)anim;
- (void)stopAnimations;

// 边缘线
@property (nonatomic, assign) CGLine* border;

// 阴影
@property (nonatomic, assign) CGShadow* shadow;

@end

@protocol CALayerExt <NSObject>

@optional

// 绘制图元，只在 layer 需要重绘时调用
- (void)onPaint:(CGGraphic*)gra;

@end

@interface CALayerExt : CALayer

// 只在复制的时候使用
- (void)onCopy:(id)r;

// 边缘
@property (nonatomic, assign) CGPadding paddingEdge;

// 有效区域
- (CGRect)rectForPaint;

@end

@interface CASketchLayer : CALayerExt

// 绘图
@property (nonatomic, retain) CGSketch *sketch;

// 清空
- (void)clear;

@end

/** 对于 CAAnimation 的扩展，增加了信号等 */
@interface CAAnimation (extension)

/** 是否在动画结束时回归到最初的样子 */
@property (nonatomic, assign) BOOL resetOnCompletion;

/** 用于命名动画的key，默认为自动排序生成的string，如果使用 animationForKey 从 layer 中取得对象，会造成 namekey 为 nil*/
@property (nonatomic, copy) NSString *namekey;

/** 有些动画属于 设置-》应用 的使用流程，所以会当 add 到 layer 时调用此函数提交修改 */
- (void)commit;

@end

SIGNAL_DECL(kSignalAnimationStart) @"::ca::animatioin::start";
SIGNAL_DECL(kSignalAnimationStop) @"::ca::animation::stop";

@interface CAKeyframeAnimation (extension)

// 从一点移动到另外一点
+ (id)Translate:(CGPoint)pt;

// 放大-缩小
+ (id)Tremble;
+ (id)TrembleOut;

// 左右摇晃
+ (id)Wabble;
+ (id)Wabble:(CATransform3D)mat;
+ (id)WabbleNeg;
+ (id)WabbleNeg:(CATransform3D)mat;

// 上下摇晃
+ (id)WabbleY;
+ (id)WabbleY:(CATransform3D)mat;
+ (id)WabbleYNeg;
+ (id)WabbleYNeg:(CATransform3D)mat;

// 淡入淡出
+ (id)FadeIn;
+ (id)FadeIn:(CGFloat)val;
+ (id)FadeOut;
+ (id)FadeOut:(CGFloat)val;
+ (id)FadeFrom:(CGFloat)from To:(CGFloat)to;

// 闪烁
+ (id)Twinkling;
+ (id)Twinkling:(NSInteger)count;

// 自旋
+ (id)Spin;
+ (id)Spin:(BOOL)clockwise;

// 缩放
+ (id)ScaleIn;
+ (id)ScaleOut;
+ (id)InScale;

// 收缩
// 根据y轴
+ (id)FoldClose;
+ (id)FoldOpen;
// 根据x轴
+ (id)ShrinkClose;
+ (id)ShrinkOpen;

// 滑入画出
+ (id)SlideFromTop:(UIView*)view;
+ (id)SlideFromBottom:(UIView*)view;
+ (id)SlideFromLeft:(UIView*)view;
+ (id)SlideFromRight:(UIView*)view;

+ (id)SlideToTop:(UIView*)view;
+ (id)SlideToBottom:(UIView*)view;
+ (id)SlideToLeft:(UIView*)view;
+ (id)SlideToRight:(UIView*)view;

// 盒子转动
+ (id)CubeTopFrom:(UIView*)l To:(UIView*)r;
+ (id)CubeBottomFrom:(UIView*)l To:(UIView*)r;
+ (id)CubeLeftFrom:(UIView*)l To:(UIView*)r;
+ (id)CubeRightFrom:(UIView*)l To:(UIView*)r;

// 自定义
+ (id)RotateFrom:(CGFloat)from To:(CGFloat)to;
+ (id)ScaleFrom:(CGFloat)from To:(CGFloat)to;
+ (id)TranslateXFrom:(CGFloat)from To:(CGFloat)to;
+ (id)TranslateYFrom:(CGFloat)from To:(CGFloat)to;

@end

@interface CATransitionExt : CATransition

@end

extern NSString* const kCATransitionFlip;
extern NSString* const kCATransitionRipple;
extern NSString* const kCATransitionSuck;
extern NSString* const kCATransitionCube;
extern NSString* const kCATransitionCameraIrisHoollowOpen;
extern NSString* const kCATransitionCameraIrisHoollowClose;

/** 对 keyframe 扩展，提供分次设置的功能 */
@interface CAKeyframeAnimationExt : CAKeyframeAnimation

/** 增加一个数值，和 layout 类似，此处添加的为精确时间 */
- (void)addValue:(NSValue*)val time:(NSTimeInterval)tm;

/** 增加一个数值，和 layout 类似，此处添加的是占比时间 */
- (void)addValue:(NSValue*)val flex:(float)flex;

/** 只增加一个数值 */
- (void)addValue:(NSValue*)val;

/** 停留一段时间 */
- (void)waitTime:(NSTimeInterval)tm;

@end

@interface CADisplayLinkExt : NSObject

- (void)addToRunLoop:(NSRunLoop *)runloop forMode:(NSString *)mode;
- (void)removeFromRunLoop:(NSRunLoop *)runloop forMode:(NSString *)mode;
- (void)invalidate;
@property(readonly, nonatomic) CFTimeInterval timestamp, duration;
//@property(nonatomic) BOOL paused;
@property(nonatomic) NSInteger frameInterval;

- (void)start;
- (void)stop;

/** 是否正在运行 */
- (BOOL)isRunning;

@end

/** 用来控制显示的帧滴答器 */
@interface CADisplayStage : NSObject

/** 帧速限制 */
@property (nonatomic, assign) float fps;

/** 一步还是同步模式，如果是同步模式，需要业务层处理结束后调用 continuee 函数，默认为异步模式，即为 YES */
@property (nonatomic, assign) BOOL asyncMode;

/** 控制 */
- (void)start;
- (void)stop;

/** 等待执行 
 @note 如果遇到耗时操作，需要使用 等待-继续 的模式来解决 UI 被挂起的问题
 */
- (void)continuee;

@end

@interface CAStylizedTextLayer : CALayer

@property (nonatomic, retain) NSStylizedString* string;
@property (nonatomic, readonly) NSAttributedString *attributedString;
@property (nonatomic, assign) NSInteger numberOfLines;

// 绘制
+ (void)DrawStylizedString:(NSStylizedString*)stystr
          attributedString:(NSAttributedString*)attrstr
                 inContext:(CGContextRef)ctx
                    inRect:(CGRect)rect;

// 查找
- (id<NSStylizedItem>)itemAtPoint:(CGPoint)pt;

@end

@interface NSStylizedString (CALayer)

/** 是否含有 image */
- (BOOL)hasImage;

/** 查找位于 range 之内的 image, strict 完全匹配模式YES */
- (id<NSStylizedItemImage>)imageOnRange:(NSRange)rgn strict:(BOOL)strict;

@end

/** 使用对点的累计，来计算手势 */
@interface CAGestureRecognizer : NSObjectExt

/** 上一次的地址，当前地址 */
@property (nonatomic, assign) CGPoint lastPosition, currentPosition;

/** 上一次的时间，当前时间 */
@property (nonatomic, assign) time_t lastTime, currentTime;

/** 增量 */
@property (nonatomic, readonly) CGPoint deltaPosition;
@property (nonatomic, readonly) time_t deltaTime;

/** 速度 */
@property (nonatomic, readonly) CGPoint velocity;

/** 动的次数 */
@property (nonatomic, assign) NSInteger touchsCount;

/** 最小的激活时间，多长时间内必须动作结束，单位为 ms */
@property (nonatomic, assign) NSInteger thresholdInterval;

/** 重置 */
- (void)reset;

/** 移动一次位置 */
- (void)addPosition:(CGPoint)pos;

/** 总体的方向 */
- (CGDirection)majorDirection;

/** 是否可用 */
@property (nonatomic, assign) BOOL enable;

@end

@interface CADragGestureRecognizer : CAGestureRecognizer

/** 阈值，默认为5个像素 */
@property (nonatomic, assign) CGPoint threshold;

/** 支持的方向，默认为横竖向都可以 */
@property (nonatomic, assign) CGDirection direction;

@end

/** 通过自定义控制点来控制动画 */
EXTERN NSString* const kCAMediaTimingFunctionCustom;

/** 弹簧时间函数 */
EXTERN NSString* const kCAMediaTimingFunctionSpring;

/** 自定义任一属性帧数据生成器 */
@interface CAKeyframeProducer : NSObjectExt

/** 持续时间 */
@property (nonatomic, assign) NSTimeInterval duration;

/** 时间函数 */
@property (nonatomic, assign) NSString *timefunction;

/** 开始 */
- (void)start;

/** 停止 */
- (void)stop;

/** 处理一帧 */
- (void)frame:(float)value;

/** 如果时间函数为 kCAMediaTimingFunctionCustom，则需要设置控制点 */
@property (nonatomic, assign) CGPoint controlPointA, controlPointB;

@end

/** 自定义任一属性的帧动画生成器 */
@interface CAAnimationProducer : CAKeyframeProducer

/** 使用 block 来立即运行一个动画 */
+ (void)animates:(void(^)(CAAnimationProducer* ap))ani progress:(void(^)(float p, float delt))progress;
+ (void)animates:(void(^)(CAAnimationProducer* ap))ani progress:(void(^)(float p, float delt))progress completion:(void(^)())completion;

/** 定义的名称，可以用来操作动画 */
@property (nonatomic, retain) NSString *keyname;

/** 查找指定名字的动画 */
+ (instancetype)FindProducer:(NSString*)keyname;

/** 停止该名字的动画 */
+ (void)Stop:(NSString*)keyname;

@end

# endif
