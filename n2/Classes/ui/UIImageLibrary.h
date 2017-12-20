
# ifndef __UILOCALIMAGEPICKER_9ADAD60150AD4112965B59C7CA6C850A_H_INCLUDED
# define __UILOCALIMAGEPICKER_9ADAD60150AD4112965B59C7CA6C850A_H_INCLUDED

@interface UIImageLibrary : NSObject

+ (UIImageLibrary*)shared;

// 保存图片到相册
- (NSObject*)save:(UIImage*)image;

// 使用回调的保存
+ (void)Save:(UIImage*)image success:(void(^)())success failed:(void(^)())failed;

@end

@interface UIImageLibraryPicker : NSObject

// 提示的语句
@property (nonatomic, copy) NSString* title;

// 生成file的Size
@property (nonatomic, assign) CGSize limitSize;

// kSignalImagePickerSuccess返回的图片使用thumbSize
@property (nonatomic, assign) CGSize thumbSize;

// 生成缩略图所使用的模式
@property (nonatomic, assign) UIViewContentMode thumbMode;

// 0为单选，>=1为多选
@property (nonatomic, assign) NSInteger maxCount;

// 选取、拍摄图片的地址
@property (nonatomic, readonly) NSMutableArray *paths;

// 是否限制长宽比，默认为 NO
@property (nonatomic, assign) BOOL lockAspect;

// 是否允许编辑，默认为 YES，仅当单张照片选取模式时生效
@property (nonatomic, assign) BOOL enableEditor;

// 执行选择性
- (void)execute;

// 选择图片
- (void)executePicker;

// 拍摄图片
- (void)executeCamera;

@end

SIGNAL_DECL(kSignalImagePickerSuccess) @"::ui::imagepicker::success";
SIGNAL_DECL(kSignalImagePickerFailed) @"::ui::imagepicker::failed";

# endif
