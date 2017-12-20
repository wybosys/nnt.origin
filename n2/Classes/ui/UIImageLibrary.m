
# import "Common.h"
# import "UIImageLibrary.h"
# import "FileSystem+Extension.h"
# import "AppDelegate+Extension.h"
# import "Objc+Extension.h"
# import "UIMediaLibraryPicker.h"

@implementation UIImageLibrary

SHARED_IMPL;

- (NSObject*)save:(UIImage *)image {
    NSError* err = [[NSError alloc] init];
    DISPATCH_DELAY_BEGIN(.1f)
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(__il_image_save:didFinishSavingWithError:contextInfo:), err);
    DISPATCH_DELAY_END
    return err;
}

- (void)__il_image_save:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSError* errobj = (NSError*)contextInfo;
    
    if (error) {
        [error show];
        [errobj.signals emit:kSignalFailed];
    } else {
        [errobj.signals emit:kSignalSucceed];
    }
    
    SAFE_RELEASE(errobj);
}

+ (void)Save:(UIImage*)image success:(void(^)())success failed:(void(^)())failed {
    NSObject* obj = [[UIImageLibrary shared] save:image];
    [obj.signals connect:kSignalSucceed withBlock:^(SSlot *s) {
        if (success)
            success();
    }];
    [obj.signals connect:kSignalFailed withBlock:^(SSlot *s) {
        if (failed)
            failed();
    }];
}

@end

@interface UIImageLibraryPicker ()
<UINavigationControllerDelegate,
UIImagePickerControllerDelegate>

@end

@implementation UIImageLibraryPicker

- (id)init {
    self = [super init];
    
# ifdef IOS10_FEATURES
    if (kIOS10Above) {
        NSDictionary *dictInfo = [[NSBundle mainBundle] infoDictionary];
        if ([dictInfo exists:@"NSPhotoLibraryUsageDescription"] == NO)
            FATAL("iOS10 需要在 Info.plist 里面写一个 Privacy - Photo Library Usage Description 的 string，用来提示用户为什么会使用照片");
        if ([dictInfo exists:@"NSCameraUsageDescription"] == NO)
            FATAL("iOS10 需要在 Info.plist 里面写一个 Privacy - Camera Usage Description 的 string，用来提示用户为什么会使用相机");
    }
# endif
    
    _paths = [[NSMutableArray alloc] init];
    [_paths addObject:[FSApplication shared].pathTemporary];
    
    self.title = @"选择图片";
    [self.signals connect:kSignalImagePickerSuccess redirectTo:kSignalDone ofTarget:self];
    
    _thumbSize = CGSizeZero;
    _thumbMode = UIViewContentModeScaleAspectFit;
    _maxCount = 0;
    _enableEditor = YES;

    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_paths);
    ZERO_RELEASE(_title);
    [super dealloc];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalDone)
SIGNAL_ADD(kSignalImagePickerSuccess)
SIGNAL_ADD(kSignalImagePickerFailed)
SIGNALS_END

- (void)execute {
    [UIKeyboardExt Close];
    
    UIActionSheetExt* as = [UIActionSheetExt temporary];
    as.title = self.title;
    [[as addItem:@"拍照"].signals connect:kSignalClicked withSelector:@selector(executeCamera) ofTarget:self];
    [[as addItem:@"从相册中选择"].signals connect:kSignalClicked withSelector:@selector(executePicker) ofTarget:self];
    [as addCancel:@"取消"];
    [as.attachment.strong setObject:self forKey:@"picker"];
    [as show];
}

- (void)executePicker {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO) {
        [UIHud Failed:@"不能打开相册，请在“设置->隐私”中打开访问权限"];
        return;
    }
    
    if (_maxCount == 0)
    {
        // 单张图片使用系统的来处理
        UIImagePickerController *imagePicker = [UIImagePickerController temporary];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        imagePicker.allowsEditing = NO;
        [[UIAppDelegate shared] presentModalViewController:imagePicker animated:YES];
    }
    else
    {
        // 多张图片选择
        UIMediaLibraryPicker* imgpk = [UIMediaLibraryPicker temporary];
        imgpk.hasVideo = NO;
        imgpk.maximumCount = _maxCount >= 1 ? _maxCount : 9;
        
        UINavigationControllerExt* navi = [UINavigationControllerExt navigationWithController:imgpk];
        [[UIAppDelegate shared] presentModalViewController:navi];
        
        [imgpk.signals connect:kSignalDone withSelector:@selector(actMultipickerDone:) ofTarget:self];
        [imgpk.signals connect:kSignalCancel withSelector:@selector(actMultipickerCancel:) ofTarget:self];
    }
    
    SAFE_RETAIN(self);
}

- (void)executeCamera {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        [UIHud Failed:@"此设备不支持拍照，或请在“设置->隐私”中打开相机权限"];
        return;
    }

    UIImagePickerController *imagePicker = [UIImagePickerController temporary];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    [[UIAppDelegate shared] presentModalViewController:imagePicker animated:YES];
    
    SAFE_RETAIN(self);
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (self.enableEditor)
    {
        UIImageCropController* crop = [[UIImageCropController alloc] init];
        crop.image = image;
        
        if (self.lockAspect && CGSizeEqualToSize(self.limitSize, CGSizeZero) == NO)
            crop.aspect = self.limitSize.width / self.limitSize.height;
	
        // 收起来
        [picker dismissViewControllerAnimated:NO completion:^{
            UINavigationController* navi = [UINavigationControllerExt navigationWithController:crop];
            [[UIAppDelegate shared] presentModalViewController:navi];
        }];
        
        [crop.signals connect:kSignalCancel withSelector:@selector(cbCropCancel:) ofTarget:self];
        [crop.signals connect:kSignalDone withSelector:@selector(cbCropDone:) ofTarget:self];
    
        SAFE_RELEASE(crop);
    }
    else
    {
        if (CGSizeEqualToSize(_limitSize, CGSizeZero) == NO &&
            CGSizeEqualToSize(image.size, _limitSize) == NO)
        {
            image = [image imageResize:_limitSize contentMode:UIViewContentModeScaleAspectFit];
        }
        
        [_paths removeAllObjects];
        [_paths addObject:[[FSApplication shared].pathTemporary stringByAppendingString:@".jpg"]];
        [UIImageJPEGRepresentation(image, 0.5) writeToFile:_paths.firstObject atomically:YES];
        
        if (CGSizeEqualToSize(_thumbSize, CGSizeZero) == NO &&
            CGSizeEqualToSize(image.size, _thumbSize) == NO)
        {
            image = [image imageResize:_thumbSize contentMode:_thumbMode];
        }
        [self.signals emit:kSignalImagePickerSuccess withResult:[NSArray arrayWithObjects:image, nil]];
        
        // 收起来
        [picker dismissModalViewController];
        
        // 释放内存
        SAFE_RELEASE(self);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewController];
    [self.signals emit:kSignalImagePickerFailed];

    SAFE_RELEASE(self);
}

- (void)cbCropCancel:(SSlot*)s {
    [self.signals emit:kSignalImagePickerFailed];
    
    UIImageCropController* crop = (UIImageCropController*)s.sender;
    [crop.navigationController dismissModalViewController];
    
    SAFE_RELEASE(self);
}

- (void)cbCropDone:(SSlot*)s {
    UIImage* image = (UIImage*)s.data.object;
    if (CGSizeEqualToSize(_limitSize, CGSizeZero) == NO &&
        CGSizeEqualToSize(image.size, _limitSize) == NO)
    {
        image = [image imageResize:_limitSize contentMode:UIViewContentModeScaleAspectFit];
    }
    
    [_paths removeAllObjects];
    [_paths addObject:[[FSApplication shared].pathTemporary stringByAppendingString:@".jpg"]];
    [UIImageJPEGRepresentation(image, 0.5) writeToFile:_paths.firstObject atomically:YES];
    
    if (CGSizeEqualToSize(_thumbSize, CGSizeZero) == NO &&
        CGSizeEqualToSize(image.size, _thumbSize) == NO)
    {
        image = [image imageResize:_thumbSize contentMode:_thumbMode];
    }
    [self.signals emit:kSignalImagePickerSuccess withResult:[NSArray arrayWithObjects:image, nil]];
    
    UIImageCropController* crop = (UIImageCropController*)s.sender;
    [crop.navigationController dismissModalViewController];
    
    SAFE_RELEASE(self);
}

- (void)actMultipickerDone:(SSlot*)s {
    [UIHud ShowProgress];
    
    NSArray* datas = s.data.object;
    DISPATCH_ASYNC({
        [_paths removeAllObjects];
        NSArray* images = [datas arrayWithCollector:^id(NSPair* l) {
            return l.firstObject;
        }];
        
        for (UIImage* image in images) {
            NSString* file = [[FSApplication shared].pathTemporary stringByAppendingString:@".jpg"];
            if (CGSizeEqualToSize(_limitSize, CGSizeZero) == NO &&
                CGSizeEqualToSize(image.size, _limitSize) == NO)
            {
                image = [image imageResize:_limitSize contentMode:UIViewContentModeScaleAspectFit];
            }
            [UIImageJPEGRepresentation(image, 0.5) writeToFile:file atomically:YES];
            [_paths addObject:file];
            if (CGSizeEqualToSize(_thumbSize, CGSizeZero) == NO &&
                CGSizeEqualToSize(image.size, _thumbSize) == NO)
            {
                image = [image imageResize:_thumbSize contentMode:_thumbMode];
            }
        }
        DISPATCH_ONMAIN({
            [UIHud HideProgress];
            
            [self.signals emit:kSignalImagePickerSuccess withResult:images];
            [self release];
        })
    })
}

- (void)actMultipickerCancel:(SSlot*)s {
    [self.signals emit:kSignalImagePickerFailed];
    
    SAFE_RELEASE(self);
}

@end
