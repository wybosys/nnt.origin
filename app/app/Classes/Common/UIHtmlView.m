
# import "Common.h"
# import "UIHtmlView.h"
# import "UITypes+Swizzle.h"

# import "DTAttributedTextView.h"
# import "DTHTMLAttributedStringBuilder.h"
# import "DTLinkButton.h"
# import "DTLazyImageView.h"
# import "DTImageTextAttachment.h"

#pragma GCC diagnostic ignored "-Wundeclared-selector"

@interface DTAttributedTextViewExt : DTAttributedTextView

@end

@implementation DTAttributedTextViewExt

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self.attributedTextContentView.signals connect:kSignalClicked ofTarget:self];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.signals emit:kSignalLayout];
}

UIVIEWS_SWIZZLE_IMPL_TOUCHES;

@end

@interface UIHtmlView ()
<
DTAttributedTextContentViewDelegate,
DTLazyImageViewDelegate
>
{
    BOOL _imageFetched;
}

@property (nonatomic, readonly) DTAttributedTextViewExt *textView;

@end

@implementation UIHtmlView

- (void)onInit {
    [super onInit];
    
    _textView = [[DTAttributedTextViewExt alloc] initWithZero];
    _textView.backgroundColor = [UIColor clearColor];
    [self addSubview:_textView];
    SAFE_RELEASE(_textView);
    
    self.linkColor = [UIColor blueColor];
    _textView.textDelegate = self;
    _textView.shouldDrawLinks = NO;
    _textView.scrollEnabled = YES;
    
    [_textView.signals connect:kSignalLayout withSelector:@selector(__cb_layout) ofTarget:self];
    [_textView.signals connect:kSignalClicked ofTarget:self];
}

- (void)onFin {
    ZERO_RELEASE(_linkColor);
    ZERO_RELEASE(_textColor);
    ZERO_RELEASE(_textFont);
    
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalLinkClicked)
SIGNAL_ADD(kSignalConstraintChanged)
SIGNALS_END

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    _textView.frame = rect;
}

- (CGSize)bestSize:(CGSize)sz {
    //return [self.textView.attributedString bestSize:sz];
    return [self.textView.attributedTextContentView suggestedFrameSizeToFitEntireStringConstraintedToWidth:sz.width];
}

- (void)loadHTML:(NSString *)string {
    NSDictionary* dict = nil;
    DTHTMLAttributedStringBuilder* builder = [[DTHTMLAttributedStringBuilder alloc]
                                              initWithHTML:[string dataUsingEncoding:NSUTF8StringEncoding]
                                              options:self.htmlOptions
                                              documentAttributes:&dict];
    self.textView.attributedString = builder.generatedAttributedString;
    SAFE_RELEASE(builder);
}

/*
- DTMaxImageSize: the maximum CGSize that a text attachment can fill
- DTDefaultFontFamily: the default font family to use instead of Times New Roman
- DTDefaultFontSize: the default font size to use instead of 12
- DTDefaultTextColor: the default text color
- DTDefaultLinkColor: the default color for hyperlink text
- DTDefaultLinkDecoration: the default decoration for hyperlinks
- DTDefaultLinkHighlightColor: the color to show while the hyperlink is highlighted
- DTDefaultTextAlignment: the default text alignment for paragraphs
- DTDefaultLineHeightMultiplier: The multiplier for line heights
- DTDefaultFirstLineHeadIndent: The default indent for left margin on first line
- DTDefaultHeadIndent: The default indent for left margin except first line
- DTDefaultListIndent: The amount by which lists are indented
- DTDefaultStyleSheet: The default style sheet to use
- DTUseiOS6Attributes: use iOS 6 attributes for building (UITextView compatible)
- DTWillFlushBlockCallBack: a block to be executed whenever content is flushed to the output string
- DTIgnoreInlineStylesOption: All inline style information is being ignored and only style blocks used
 */
- (NSDictionary*)htmlOptions {
    NSMutableDictionary* opts = [NSMutableDictionary dictionary];
    [opts setObject:self.linkColor forKey:DTDefaultLinkColor def:nil];
    [opts setObject:self.textColor forKey:DTDefaultTextColor def:nil];
    [opts setObject:self.textFont.familyName forKey:DTDefaultFontFamily def:nil];
    [opts setObject:@(self.textFont.pointSize) forKey:DTDefaultFontSize def:nil];
    if (self.lineHeightMultiplier) {
        [opts setObject:@(self.lineHeightMultiplier) forKey:DTDefaultLineHeightMultiplier];
    } else if (self.lineHeight && self.textFont) {
        CGFloat mul = self.lineHeight / self.textFont.lineHeight;
        [opts setObject:@(mul) forKey:DTDefaultLineHeightMultiplier];
    }
    [opts setObject:@(self.textAlignment) forKey:DTDefaultTextAlignment];
    return opts;
}

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttributedString:(NSAttributedString *)string frame:(CGRect)frame
{
    NSDictionary *attributes = [string attributesAtIndex:0 effectiveRange:NULL];
	
	NSURL *URL = [attributes objectForKey:DTLinkAttribute];
	NSString *identifier = [attributes objectForKey:DTGUIDAttribute];
	
	
	DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:frame];
	button.URL = URL;
	button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
	button.GUID = identifier;
	
	// get image with normal link text
	UIImage *normalImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDefault];
	[button setImage:normalImage forState:UIControlStateNormal];
	
	// get image for highlighted link text
	UIImage *highlightImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDrawLinksHighlighted];
	[button setImage:highlightImage forState:UIControlStateHighlighted];
	
	// use normal push action for opening URL
	[button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
	
	// demonstrate combination with long press
	//UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(linkLongPressed:)];
	//[button addGestureRecognizer:longPress];
	
    return button;
}

- (void)linkPushed:(DTLinkButton*)link {
    LOG("UIHtmlView URL Clicked: %s", link.URL.absoluteString.UTF8String);
    [self.touchSignals emit:kSignalLinkClicked withResult:link.URL];
}

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame {
    if ([attachment isKindOfClass:[DTImageTextAttachment class]])
    {
        // if the attachment has a hyperlinkURL then this is currently ignored
		DTLazyImageView *imageView = [[DTLazyImageView alloc] initWithFrame:frame];
		imageView.delegate = self;
		
		// sets the image if there is one
		imageView.image = (UIImage*)[(DTImageTextAttachment *)attachment image];
		
		// url for deferred loading
		imageView.url = attachment.contentURL;
		
		// if there is a hyperlink then add a link button on top of this image
		if (attachment.hyperLinkURL)
		{
			// NOTE: this is a hack, you probably want to use your own image view and touch handling
			// also, this treats an image with a hyperlink by itself because we don't have the GUID of the link parts
			imageView.userInteractionEnabled = YES;
			
			DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:imageView.bounds];
			button.URL = attachment.hyperLinkURL;
			button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
			button.GUID = attachment.hyperLinkGUID;
			
			// use normal push action for opening URL
			[button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
			
			// demonstrate combination with long press
			//UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(linkLongPressed:)];
			//[button addGestureRecognizer:longPress];
			
			[imageView addSubview:button];
		}
		
		return [imageView autorelease];
    }
    return nil;
}

- (void)lazyImageView:(DTLazyImageView *)lazyImageView didChangeImageSize:(CGSize)size {
	NSURL *url = lazyImageView.url;
	CGSize imageSize = size;
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"contentURL == %@", url];
	
	BOOL didUpdate = NO;
	
	// update all attachments that matchin this URL (possibly multiple images with same size)
	for (DTTextAttachment *oneAttachment in [_textView.attributedTextContentView.layoutFrame textAttachmentsWithPredicate:pred])
	{
		// update attachments that have no original size, that also sets the display size
		if (CGSizeEqualToSize(oneAttachment.originalSize, CGSizeZero))
		{
			oneAttachment.originalSize = imageSize;
			
			didUpdate = YES;
		}
	}
    
    _imageFetched = YES;
	
	if (didUpdate)
	{
		// layout might have changed due to image sizes
		[_textView relayoutText];
	}
}

- (void)__cb_layout {
    BOOL bdchanged = NO;
    
    if (_imageFetched) {
        bdchanged = YES;
        _imageFetched = NO;
    }
    
    if (bdchanged)
        [self.signals emit:kSignalConstraintChanged];
}

@end
