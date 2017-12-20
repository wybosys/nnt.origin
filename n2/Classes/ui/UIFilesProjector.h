
# ifndef __UIFILESPROJECTOR_225028C2A9DE4A9481D5EC325DC83835_H_INCLUDED
# define __UIFILESPROJECTOR_225028C2A9DE4A9481D5EC325DC83835_H_INCLUDED

# import "UIScrollableWidgets.h"

@interface UIFilesProjector : UIPagedViewController

/** 文件组的源文件以及预览文件，为 NSDataSource 的 Array */
@property (nonatomic, retain) NSArray *files, *thumbs;

/** 源头的view，用来生成打开的动画 */
@property (nonatomic, assign) UIView *viewSource;

/** 显示 */
- (void)open;

/** 关闭 */
- (void)close;

/** 显示当前页的计数器 */
@property (nonatomic, readonly) UIPageControlExt* pageControl;

@end

# endif
