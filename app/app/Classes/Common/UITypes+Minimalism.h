
# ifndef __UITYPES_MINIMALISM_C432FEB4262141ADB6E77AE12E7F5E73_H_INCLUDED
# define __UITYPES_MINIMALISM_C432FEB4262141ADB6E77AE12E7F5E73_H_INCLUDED

# import <UIKit/UIKit.h>

@interface NSObject (minimalism)

- (void)onInit;
- (void)onFin;

// 实例化一个临时对象
+ (id)temporary;

@end

@interface UIView (minimalism)

- (void)onLayout:(CGRect)rect;

@end

@interface UIViewExt : UIView

@end

@interface UIViewControllerExt : UIViewController

@property (nonatomic, assign) Class classForView;

- (void)onLoaded;

@end

@interface UILabel (minimalism)

@property (nonatomic, retain) UIFont* textFont;

@end

@interface UIButton (minimalism)

@property (nonatomic, retain) UIColor* textColor;
@property (nonatomic, retain) UIFont* textFont;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, copy) NSString* text;

@end

# endif
