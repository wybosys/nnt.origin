
# ifndef __UIHTMLVIEW_C5A020EBFD974BC5B58BD589B5ECAFC8_H_INCLUDED
# define __UIHTMLVIEW_C5A020EBFD974BC5B58BD589B5ECAFC8_H_INCLUDED

@interface UIHtmlView : UIViewExt

- (void)loadHTML:(NSString*)string;

// 各种设定
@property (nonatomic, retain) UIColor *linkColor;
@property (nonatomic, retain) UIFont *textFont;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, assign) CGFloat lineHeightMultiplier;
@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, assign) CTTextAlignment textAlignment;

- (CGSize)bestSize:(CGSize)sz;

@end

# endif
