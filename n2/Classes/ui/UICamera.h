
# pragma once

SIGNAL_DECL(kSignalSnapshot) @"::ui::snapshot";

@interface UICameraView : UIViewExt

@end

@interface UICamera : UIViewControllerExt

// 截屏
- (void)snapshot;

@end
