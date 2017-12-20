
# import "Common.h"
# import "UIDripRefresh.h"
# import "AppDelegate+Extension.h"

#define kTotalViewHeight    400
#define kOpenedViewHeight   44
#define kMinTopPadding      9
#define kMaxTopPadding      5
#define kMinTopRadius       12.5
#define kMaxTopRadius       16
#define kMinBottomRadius    3
#define kMaxBottomRadius    16
#define kMinBottomPadding   4
#define kMaxBottomPadding   6
#define kMinArrowSize       2
#define kMaxArrowSize       3
#define kMinArrowRadius     5
#define kMaxArrowRadius     7

@interface UIDripRefresh ()

@property (nonatomic, readwrite) BOOL refreshing;

@end

@implementation UIDripRefresh

@synthesize refreshing = _refreshing;
@synthesize tintColor = _tintColor;

static inline CGFloat lerp(CGFloat a, CGFloat b, CGFloat p)
{
    return a + (b - a) * p;
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalValueChanged)
SIGNALS_END

- (id)initWithFrame:(CGRect)aFrame {
    self = [super initWithFrame:aFrame];
    
    _activity = _activity ? _activity : [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activity.center = CGPointMake(floor(self.frame.size.width / 2), floor(self.frame.size.height / 2));
    _activity.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _activity.alpha = 0;
    if ([_activity respondsToSelector:@selector(startAnimating)]) {
        [(UIActivityIndicatorView *)_activity startAnimating];
    }
    [self addSubview:_activity];
    
    _refreshHintLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 365, 120, 30)];
    _refreshHintLabel.backgroundColor = [UIColor clearColor];
    _refreshHintLabel.textAlignment = NSTextAlignmentCenter;
    _refreshHintLabel.font = [UIFont fontWithName:@"Arial" size:12];
    _refreshHintLabel.text = @"刷新完成";
    [self addSubview:_refreshHintLabel];
    SAFE_RELEASE(_refreshHintLabel);
    
    [self setLoadFinishHintHidden:YES];
    
    _refreshing = NO;
    _canRefresh = YES;
    _didSetInset = NO;
    _hasSectionHeaders = NO;
    _tintColor = [[UIColor colorWithRed:155.0 / 255.0 green:162.0 / 255.0 blue:172.0 / 255.0 alpha:1.0] retain];
    
    _shapeLayer = [CAShapeLayer layer];
    _shapeLayer.fillColor = [_tintColor CGColor];
    _shapeLayer.strokeColor = [[[UIColor clearColor] colorWithAlphaComponent:0.5] CGColor];
    _shapeLayer.lineWidth = 0.5;
    _shapeLayer.shadowColor = [[UIColor clearColor] CGColor];
    _shapeLayer.shadowOffset = CGSizeMake(0, 1);
    _shapeLayer.shadowOpacity = 0.4;
    _shapeLayer.shadowRadius = 0.5;
    [self.layer addSublayer:_shapeLayer];
    
    _arrowLayer = [CAShapeLayer layer];
    _arrowLayer.strokeColor = [[[UIColor darkGrayColor] colorWithAlphaComponent:0.5] CGColor];
    _arrowLayer.lineWidth = 0.5;
    _arrowLayer.fillColor = [[UIColor whiteColor] CGColor];
    [_shapeLayer addSublayer:_arrowLayer];
    
    _highlightLayer = [CAShapeLayer layer];
    _highlightLayer.fillColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.2] CGColor];
    [_shapeLayer addSublayer:_highlightLayer];
    
    self.maxDistance = 80;
    return self;
}

- (void)dealloc
{
    ZERO_RELEASE(_tintColor);
    ZERO_RELEASE(_activity);
    [super dealloc];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    _shapeLayer.fillColor = [_tintColor CGColor];
}

- (void)setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)activityIndicatorViewStyle
{
    if ([_activity isKindOfClass:[UIActivityIndicatorView class]]) {
        [(UIActivityIndicatorView *)_activity setActivityIndicatorViewStyle:activityIndicatorViewStyle];
    }
}

- (UIActivityIndicatorViewStyle)activityIndicatorViewStyle
{
    if ([_activity isKindOfClass:[UIActivityIndicatorView class]]) {
        return [(UIActivityIndicatorView *)_activity activityIndicatorViewStyle];
    }
    return 0;
}

- (void)setActivityIndicatorViewColor:(UIColor *)activityIndicatorViewColor
{
    if ([_activity isKindOfClass:[UIActivityIndicatorView class]] && [_activity respondsToSelector:@selector(setColor:)]) {
        [(UIActivityIndicatorView *)_activity setColor:activityIndicatorViewColor];
    }
}

- (UIColor *)activityIndicatorViewColor
{
    if ([_activity isKindOfClass:[UIActivityIndicatorView class]] && [_activity respondsToSelector:@selector(color)]) {
        return [(UIActivityIndicatorView *)_activity color];
    }
    return nil;
}

- (void)setMaxDistance:(CGFloat)maxDistance {
    _maxDistance = maxDistance -(kMaxTopRadius + kMaxBottomRadius + kMaxTopPadding + kMaxBottomPadding);
}

- (void)drawRect:(CGRect)rect {
    if (_refreshing) {
        //NSLog(@"A:refresh");
        if (_offset != 0) {
            // Keep thing pinned at the top
            //NSLog(@"A:refresh and offset!=0");
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            _shapeLayer.position = CGPointMake(0, self.maxDistance + _offset + kOpenedViewHeight);
            [CATransaction commit];
            
            _activity.center = CGPointMake(floor(self.frame.size.width / 2), MIN(_offset + self.frame.size.height + floor(kOpenedViewHeight / 2), self.frame.size.height - kOpenedViewHeight/ 2));
            
        }
        return;
    }

    [self setLoadFinishHintHidden:YES];
    
    _shapeLayer.hidden = NO;
    _lastOffset = _offset;
    
    BOOL triggered = NO;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    //Calculate some useful points and values
    CGFloat verticalShift = MAX(0, -(kMaxTopRadius + kMaxBottomRadius + kMaxTopPadding + kMaxBottomPadding) + _offset);
    CGFloat distance = MIN(self.maxDistance, fabs(verticalShift));
    CGFloat percentage = 1 - (distance / self.maxDistance);
    
    //CGFloat currentTopPadding = lerp(kMinTopPadding, kMaxTopPadding, percentage);
    CGFloat currentTopRadius = lerp(kMinTopRadius, kMaxTopRadius, percentage);
    CGFloat currentBottomRadius = lerp(kMinBottomRadius, kMaxBottomRadius, percentage);
    CGFloat currentBottomPadding =  lerp(kMinBottomPadding, kMaxBottomPadding, percentage);
    
    CGPoint topOrigin = CGRectCenter(self.bounds);
    CGPoint bottomOrigin = CGPointMake(floor(self.bounds.size.width / 2),
                                       self.bounds.size.height - currentBottomPadding - currentBottomRadius);
    if (bottomOrigin.y < currentBottomRadius) {
        bottomOrigin.y = topOrigin.y;
    }
    if (percentage == 0) {
        bottomOrigin.y -= (fabs(verticalShift) - self.maxDistance);
        triggered = YES;
        [self.signals emit:kSignalValueChanged];
    }
    
    //Top semicircle
    CGPathAddArc(path, NULL, topOrigin.x, topOrigin.y, currentTopRadius, 0, M_PI, YES);
    
    //Left curve
    CGPoint leftCp1 = CGPointMake(lerp((topOrigin.x - currentTopRadius), (bottomOrigin.x - currentBottomRadius), 0.1), lerp(topOrigin.y, bottomOrigin.y, 0.2));
    CGPoint leftCp2 = CGPointMake(lerp((topOrigin.x - currentTopRadius), (bottomOrigin.x - currentBottomRadius), 0.9), lerp(topOrigin.y, bottomOrigin.y, 0.2));
    CGPoint leftDestination = CGPointMake(bottomOrigin.x - currentBottomRadius, bottomOrigin.y);
    
    CGPathAddCurveToPoint(path, NULL, leftCp1.x, leftCp1.y, leftCp2.x, leftCp2.y, leftDestination.x, leftDestination.y);
    
    //Bottom semicircle
    CGPathAddArc(path, NULL, bottomOrigin.x, bottomOrigin.y, currentBottomRadius, M_PI, 0, YES);
    
    //Right curve
    CGPoint rightCp2 = CGPointMake(lerp((topOrigin.x + currentTopRadius), (bottomOrigin.x + currentBottomRadius), 0.1), lerp(topOrigin.y, bottomOrigin.y, 0.2));
    CGPoint rightCp1 = CGPointMake(lerp((topOrigin.x + currentTopRadius), (bottomOrigin.x + currentBottomRadius), 0.9), lerp(topOrigin.y, bottomOrigin.y, 0.2));
    CGPoint rightDestination = CGPointMake(topOrigin.x + currentTopRadius, topOrigin.y);
    
    CGPathAddCurveToPoint(path, NULL, rightCp1.x, rightCp1.y, rightCp2.x, rightCp2.y, rightDestination.x, rightDestination.y);
    CGPathCloseSubpath(path);
    
    if (!triggered) {
        // Set paths
        //NSLog(@"C: refresh , Not triggered");
        _shapeLayer.path = path;
        _shapeLayer.shadowPath = path;
        
        // Add the arrow shape
        
        CGFloat currentArrowSize = lerp(kMinArrowSize, kMaxArrowSize, percentage);
        CGFloat currentArrowRadius = lerp(kMinArrowRadius, kMaxArrowRadius, percentage);
        CGFloat arrowBigRadius = currentArrowRadius + (currentArrowSize / 2);
        CGFloat arrowSmallRadius = currentArrowRadius - (currentArrowSize / 2);
        CGMutablePathRef arrowPath = CGPathCreateMutable();
        CGPathAddArc(arrowPath, NULL, topOrigin.x, topOrigin.y, arrowBigRadius, 0, 3 * M_PI_2, NO);
        CGPathAddLineToPoint(arrowPath, NULL, topOrigin.x, topOrigin.y - arrowBigRadius - currentArrowSize);
        CGPathAddLineToPoint(arrowPath, NULL, topOrigin.x + (2 * currentArrowSize), topOrigin.y - arrowBigRadius + (currentArrowSize / 2));
        CGPathAddLineToPoint(arrowPath, NULL, topOrigin.x, topOrigin.y - arrowBigRadius + (2 * currentArrowSize));
        CGPathAddLineToPoint(arrowPath, NULL, topOrigin.x, topOrigin.y - arrowBigRadius + currentArrowSize);
        CGPathAddArc(arrowPath, NULL, topOrigin.x, topOrigin.y, arrowSmallRadius, 3 * M_PI_2, 0, YES);
        CGPathCloseSubpath(arrowPath);
        _arrowLayer.path = arrowPath;
        [_arrowLayer setFillRule:kCAFillRuleEvenOdd];
        CGPathRelease(arrowPath);
        
        // Add the highlight shape
        
        CGMutablePathRef highlightPath = CGPathCreateMutable();
        CGPathAddArc(highlightPath, NULL, topOrigin.x, topOrigin.y, currentTopRadius, 0, M_PI, YES);
        CGPathAddArc(highlightPath, NULL, topOrigin.x, topOrigin.y + 1.25, currentTopRadius, M_PI, 0, NO);
        
        _highlightLayer.path = highlightPath;
        [_highlightLayer setFillRule:kCAFillRuleNonZero];
        CGPathRelease(highlightPath);
        
    } else {
        // Start the shape disappearance animation
        //NSLog(@"C: refresh , triggered");
        CGFloat radius = lerp(kMinBottomRadius, kMaxBottomRadius, 0.2);
        CABasicAnimation *pathMorph = [CABasicAnimation animationWithKeyPath:@"path"];
        pathMorph.duration = 0.15;
        pathMorph.fillMode = kCAFillModeForwards;
        pathMorph.removedOnCompletion = NO;
        CGMutablePathRef toPath = CGPathCreateMutable();
        CGPathAddArc(toPath, NULL, topOrigin.x, topOrigin.y, radius, 0, M_PI, YES);
        CGPathAddCurveToPoint(toPath, NULL, topOrigin.x - radius, topOrigin.y, topOrigin.x - radius, topOrigin.y, topOrigin.x - radius, topOrigin.y);
        CGPathAddArc(toPath, NULL, topOrigin.x, topOrigin.y, radius, M_PI, 0, YES);
        CGPathAddCurveToPoint(toPath, NULL, topOrigin.x + radius, topOrigin.y, topOrigin.x + radius, topOrigin.y, topOrigin.x + radius, topOrigin.y);
        CGPathCloseSubpath(toPath);
        pathMorph.toValue = (__bridge id)toPath;
        [_shapeLayer addAnimation:pathMorph forKey:nil];
        CABasicAnimation *shadowPathMorph = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
        shadowPathMorph.duration = 0.15;
        shadowPathMorph.fillMode = kCAFillModeForwards;
        shadowPathMorph.removedOnCompletion = NO;
        shadowPathMorph.toValue = (__bridge id)toPath;
        [_shapeLayer addAnimation:shadowPathMorph forKey:nil];
        CGPathRelease(toPath);
        CABasicAnimation *shapeAlphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        shapeAlphaAnimation.duration = 0.1;
        shapeAlphaAnimation.beginTime = CACurrentMediaTime() + 0.1;
        shapeAlphaAnimation.toValue = [NSNumber numberWithFloat:0];
        shapeAlphaAnimation.fillMode = kCAFillModeForwards;
        shapeAlphaAnimation.removedOnCompletion = NO;
        [_shapeLayer addAnimation:shapeAlphaAnimation forKey:nil];
        CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        alphaAnimation.duration = 0.1;
        alphaAnimation.toValue = [NSNumber numberWithFloat:0];
        alphaAnimation.fillMode = kCAFillModeForwards;
        alphaAnimation.removedOnCompletion = NO;
        [_arrowLayer addAnimation:alphaAnimation forKey:nil];
        [_highlightLayer addAnimation:alphaAnimation forKey:nil];
        
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        _activity.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1);
        [CATransaction commit];
        [UIView animateWithDuration:0.2 delay:0.15 options:UIViewAnimationOptionCurveLinear animations:^{
            _activity.alpha = 1;
            _activity.layer.transform = CATransform3DMakeScale(1, 1, 1);
        } completion:nil];
        
        self.refreshing = YES;
        _canRefresh = NO;
    }
    
    CGPathRelease(path);
}

- (void)beginRefreshing
{
    if (!_refreshing) {
        
        CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        alphaAnimation.duration = 0.0001;
        alphaAnimation.toValue = [NSNumber numberWithFloat:0];
        alphaAnimation.fillMode = kCAFillModeForwards;
        alphaAnimation.removedOnCompletion = NO;
        [_shapeLayer addAnimation:alphaAnimation forKey:nil];
        [_arrowLayer addAnimation:alphaAnimation forKey:nil];
        [_highlightLayer addAnimation:alphaAnimation forKey:nil];
        
        _activity.alpha = 1;
        _activity.layer.transform = CATransform3DMakeScale(1, 1, 1);
        
        self.refreshing = YES;
        _canRefresh = NO;
    }
}

- (void)endRefreshing
{
    //NSLog(@"D:end refresh");
    if (_refreshing) {
        //NSLog(@"D:end refresh is now refresh");
        self.refreshing = NO;
        // Create a temporary retain-cycle, so the scrollView won't be released
        // halfway through the end animation.
        // This allows for the refresh control to clean up the observer,
        // in the case the scrollView is released while the animation is running
        //__block UIScrollView *blockScrollView = self.scrollView;
        [UIView animateWithDuration:.2 animations:^{
            ////NSLog(@"D:end refresh set scrollview contentinset:%@",NSStringFromUIEdgeInsets(self.originalContentInset));
            _activity.alpha = 0;
            _activity.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1);
        } completion:^(BOOL finished) {
            //NSLog(@"D:end refresh set hintlabel hidden");
            [self setLoadFinishHintHidden:NO];
            [UIView animateWithDuration:.6 animations:^{
                _refreshHintLabel.alpha = .9;
            } completion:^(BOOL finish)
             {
                 [UIView animateWithDuration:.2 animations:^{
                 } completion:^(BOOL finish)
                  {
                      //NSLog(@"D:end refresh set all layer dismiss");
                      _refreshHintLabel.alpha = 1.0;
                      [_shapeLayer removeAllAnimations];
                      _shapeLayer.path = nil;
                      _shapeLayer.shadowPath = nil;
                      _shapeLayer.position = CGPointZero;
                      [_arrowLayer removeAllAnimations];
                      _arrowLayer.path = nil;
                      [_highlightLayer removeAllAnimations];
                      _highlightLayer.path = nil;
                      // We need to use the scrollView somehow in the end block,
                      // or it'll get released in the animation block.
                  }];
             }];
        }];
    }
}

-(void)setLoadFinishHintHidden:(BOOL)yesIsHidden
{
    _shapeLayer.hidden = yesIsHidden;
    _arrowLayer.hidden = !yesIsHidden;
    _highlightLayer.hidden = !yesIsHidden;
    _refreshHintLabel.hidden = yesIsHidden;
}

@end
