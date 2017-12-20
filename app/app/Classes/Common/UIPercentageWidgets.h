
@interface CAProgressLayer : CALayerExt <CALayerExt>

@property (nonatomic, assign) float progress;

@end

@interface UIActivityIndicatorView (percentage)
<NSPercentage>

@end

@interface UIProgressView (percentage)
<NSPercentage>

@end

/** 和父类的区别是自动启动并且当停止时隐藏 */
@interface UIActivityIndicatorExt : UIActivityIndicatorView

@end

/** 环形的进度条 */
@interface UIRingPercentageIndicator : UIViewExt
<NSPercentage>

@property (nonatomic, retain) NSPercentage *percentage;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, retain) CGPen* pen;
@property (nonatomic, assign) BOOL roating;

@end

@interface UIProgressBar : UIViewExt
<NSPercentage>

@property (nonatomic, retain) NSPercentage *percentage;
@property (nonatomic, retain) CGPen *pen;
@property (nonatomic, retain) CGBrush *brush;

@end

/** 环形的activity指示器 */
@interface UIRingActivityIndicator : UIViewExt
<NSPercentage>

@property (nonatomic, retain) CGPen *pen;
@property (nonatomic, assign) CGFloat radius;

- (void)startAnimating;
- (void)stopAnimating;

@end
