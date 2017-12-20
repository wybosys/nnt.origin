
# ifndef __UIBARCODER_E5CD806FED524655A28F6051F17E9829_H_INCLUDED
# define __UIBARCODER_E5CD806FED524655A28F6051F17E9829_H_INCLUDED

@interface UIBarCodeScannerView : UIViewExt

@end

typedef enum {
    kNSActionModeWait, // 等待模式，动作激发后则停止掉工作队列，业务需要手动继续开始
    kNSActionModeContinuee, // 持续模式，动作激发后，继续工作
    kNSActionModeDefault = kNSActionModeWait
} NSActionMode;

@interface UIBarCodeScanner : UIViewControllerExt

// 模式，是连续模式，还是等待模式（扫描成功后，等待业务层通知继续扫描下一个）
@property (nonatomic, assign) NSActionMode actionMode;

// 启动或者停止，默认使用 appear 和 disappear 已经控制，业务层不需要默认处理
- (void)start;
- (void)stop;

// 直接扫描图片
+ (NSArray*)ScanImage:(UIImage*)image;

@end

@interface UIBarCodeMaker : UIViewControllerExt

@property (nonatomic, copy) NSString *content;
@property (nonatomic, readonly, retain) UIImage *image;
@property (nonatomic, readonly) UIImageView *imageView;

// 尺寸，默认260
@property (nonatomic, assign) CGFloat size;

@end

@interface NSBarCode : NSObjectExt

@property (nonatomic, copy) NSString *data;

// 打印日志
- (void)log;

@end

# endif
