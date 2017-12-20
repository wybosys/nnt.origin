
# import "UIIrrlichtController.h"
# import "NSSystemFeatures.h"
# import "Rlt3d.h"

@interface VCRlt3d : UIIrrlichtController

/** 使用经纬度增加一个热点 */
- (void)addTagPoint:(RltTag)pt;

/** 缩放整个视野 */
- (void)zoomScene:(float)scale;

/** 移动视野，像素 */
- (void)moveScene:(CGPoint)per;

/** 移动中点到经纬度 */
- (void)centerScene:(CGPoint)per;

/** 旋转 */
- (void)rotateScene:(CGPoint)per;

/** 暂停 */
- (void)pause;

/** 恢复 */
- (void)resume;

@end
