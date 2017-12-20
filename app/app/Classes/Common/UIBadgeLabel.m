
# import "Common.h"
# import "UIBadgeLabel.h"

#define kDefaultBadgeTextColor [UIColor whiteColor]
#define kDefaultBadgeBackgroundColor [UIColor redColor]
#define kDefaultOverlayColor [UIColor colorWithWhite:1.0f alpha:0.3]

#define kDefaultBadgeTextFont [UIFont boldSystemFontOfSize:[UIFont systemFontSize]]

#define kDefaultBadgeShadowColor [UIColor clearColor]

#define kBadgeStrokeColor [UIColor whiteColor]
#define kBadgeStrokeWidth 2.0f

#define kMarginToDrawInside (kBadgeStrokeWidth * 2)

#define kShadowOffset CGSizeMake(0.0f, 3.0f)
#define kShadowOpacity 0.4f
#define kShadowColor [UIColor colorWithWhite:0.0f alpha:kShadowOpacity]
#define kShadowRadius 1.0f

#define kBadgeHeight 16.0f
#define kBadgeTextSideMargin 8.0f

#define kBadgeCornerRadius 10.0f

#define kDefaultBadgeAlignment JSBadgeViewAlignmentTopRight

@interface UIBadgeLabel()

- (void)_init;
- (CGSize)sizeOfTextForCurrentSettings;

@end


@implementation UIBadgeLabel

- (void)awakeFromNib {
    [super awakeFromNib];
    [self _init];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:CGRectMake(0, 0, 50, 50)])) {
        [self _init];
    }
    return self;
}

- (void)_init {
    self.backgroundColor = [UIColor clearColor];
    
    self.badgeBackgroundColor = kDefaultBadgeBackgroundColor;
    self.badgeOverlayColor = kDefaultOverlayColor;
    self.textColor = kDefaultBadgeTextColor;
    self.textShadowColor = kDefaultBadgeShadowColor;
    self.textFont = kDefaultBadgeTextFont;
}

- (void)dealloc {
    ZERO_RELEASE(_text);
    ZERO_RELEASE(_textColor);
    ZERO_RELEASE(_textShadowColor);
    ZERO_RELEASE(_textFont);
    ZERO_RELEASE(_badgeBackgroundColor);
    ZERO_RELEASE(_badgeOverlayColor);
    [super dealloc];
}

- (void)layoutSubviews {
    CGRect newFrame = self.frame;
    
    CGFloat textWidth = [self sizeOfTextForCurrentSettings].width;
    
    CGFloat viewWidth = textWidth + kBadgeTextSideMargin + (kMarginToDrawInside * 2);
    CGFloat viewHeight = kBadgeHeight + (kMarginToDrawInside * 2);
    
    newFrame.size.width = viewWidth;
    newFrame.size.height = viewHeight;
    
    newFrame.origin.x += _badgePositionAdjustment.x;
    newFrame.origin.y += _badgePositionAdjustment.y;
    
    self.frame = CGRectIntegral(newFrame);
    
    [self setNeedsDisplay];
}

- (CGSize)sizeOfTextForCurrentSettings {
    return [self.text sizeWithFont:self.textFont];
}

- (void)setBadgePositionAdjustment:(CGPoint)badgePositionAdjustment {
    _badgePositionAdjustment = badgePositionAdjustment;
    [self setNeedsLayout];
}

- (void)setText:(NSString *)text {
    PROPERTY_COPY(_text, text);
    [self setNeedsLayout];
}

- (void)setTextColor:(UIColor *)textColor {
    PROPERTY_RETAIN(_textColor, textColor);
    [self setNeedsLayout];
}

- (void)setTextShadowColor:(UIColor *)textShadowColor {
    PROPERTY_RETAIN(_textShadowColor, textShadowColor);
    [self setNeedsLayout];
}

- (void)setTextShadowOffset:(CGSize)textShadowOffset {
    _textShadowOffset = textShadowOffset;
    [self setNeedsLayout];
}

- (void)setTextFont:(UIFont *)textFont {
    PROPERTY_RETAIN(_textFont, textFont);
    [self setNeedsLayout];
}

- (void)setBadgeBackgroundColor:(UIColor *)badgeBackgroundColor {
    if (badgeBackgroundColor != _badgeBackgroundColor) {
        _badgeBackgroundColor = badgeBackgroundColor;
        [self setNeedsLayout];
    }
}

- (void)drawRect:(CGRect)rect {
    BOOL anyTextToDraw = (self.text.length > 0);
    
    if (anyTextToDraw)
    {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        CGRect rectToDraw = CGRectInset(rect, kMarginToDrawInside, kMarginToDrawInside);
        
        UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:rectToDraw byRoundingCorners:(UIRectCorner)UIRectCornerAllCorners cornerRadii:CGSizeMake(kBadgeCornerRadius, kBadgeCornerRadius)];
        
        /* Background and shadow */
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, borderPath.CGPath);
            
            CGContextSetFillColorWithColor(ctx, self.badgeBackgroundColor.CGColor);
            CGContextSetShadowWithColor(ctx, kShadowOffset, kShadowRadius, kShadowColor.CGColor);
            
            CGContextDrawPath(ctx, kCGPathFill);
        }
        CGContextRestoreGState(ctx);
        
        BOOL colorForOverlayPresent = self.badgeOverlayColor && ![self.badgeOverlayColor isEqual:[UIColor clearColor]];
        
        if (colorForOverlayPresent)
        {
            /* Gradient overlay */
            CGContextSaveGState(ctx);
            {
                CGContextAddPath(ctx, borderPath.CGPath);
                CGContextClip(ctx);
                
                CGFloat height = rectToDraw.size.height;
                CGFloat width = rectToDraw.size.width;
                
                CGRect rectForOverlayCircle = CGRectMake(rectToDraw.origin.x,
                                                         rectToDraw.origin.y - ceilf(height * 0.5),
                                                         width,
                                                         height);
                
                CGContextAddEllipseInRect(ctx, rectForOverlayCircle);
                CGContextSetFillColorWithColor(ctx, self.badgeOverlayColor.CGColor);
                
                CGContextDrawPath(ctx, kCGPathFill);
            }
            CGContextRestoreGState(ctx);
        }
        
        /* Stroke */
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, borderPath.CGPath);
            
            CGContextSetLineWidth(ctx, kBadgeStrokeWidth);
            CGContextSetStrokeColorWithColor(ctx, kBadgeStrokeColor.CGColor);
            
            CGContextDrawPath(ctx, kCGPathStroke);
        }
        CGContextRestoreGState(ctx);
        
        /* Text */
        CGContextSaveGState(ctx);
        {
            CGContextSetFillColorWithColor(ctx, self.textColor.CGColor);
            CGContextSetShadowWithColor(ctx, self.textShadowOffset, 1.0, self.textShadowColor.CGColor);
            
            CGRect textFrame = rectToDraw;
            CGSize textSize = [self sizeOfTextForCurrentSettings];
            
            textFrame.size.height = textSize.height;
            textFrame.origin.y = rectToDraw.origin.y + ceilf((rectToDraw.size.height - textFrame.size.height) / 2.0f);
            
            [self.text drawInRect:textFrame
                         withFont:self.textFont
                    lineBreakMode:(NSLineBreakMode)UILineBreakModeCharacterWrap
                        alignment:(NSTextAlignment)UITextAlignmentCenter];
        }
        CGContextRestoreGState(ctx);
    }
}

@end
