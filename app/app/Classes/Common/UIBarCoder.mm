
# import "Common.h"
# import "UIBarCoder.h"
# import <zbar/zbar.h>
# import <zbar/ZBarSDK.h>
# import "QREncoder.h"
# import "UIImageLibrary.h"
# import "NSStorage.h"

@interface MaskView : UIViewExt

@property (nonatomic, readonly) UIImageViewExt *bkg, *line;
@property (nonatomic, readonly) UILabelExt *lblNotice;

- (void)animation;

@end

@implementation MaskView

- (void)onInit {
    [super onInit];
    
    [self addSub:BLOCK_RETURN({
        _bkg = [[UIImageViewExt alloc] initWithImage:[UIImage stretchImage:@"ico_ge_Sweep"]];
        return _bkg;
    })];
    
    [_bkg addSub:BLOCK_RETURN({
        _line = [[UIImageViewExt alloc] initWithImage:[UIImage stretchImage:@"ico_ge_Sweep_pic"]];
        return _line;
    })];
    
    [self addSub:BLOCK_RETURN({
        _lblNotice = [[UILabelExt alloc] init];
        _lblNotice.textFont = [UIFont systemFontOfSize:(32 * .5f)];
        _lblNotice.textColor = [UIColor colorWithRGB:0xcccccc];
        _lblNotice.textAlignment = NSTextAlignmentCenter;
        _lblNotice.text = @"将二维码/条码放入框内, 即可自动扫描";
        return _lblNotice;
    })];
    
    [self animation];
}

- (void)animation {
    CAKeyframeAnimation* ani = [CAKeyframeAnimationExt animation];
    ani.keyPath = @"transform.translation.y";
    ani.values = [NSArray arrayWithObjects:
                  @(192),
                  @(0),
                  nil];
    ani.duration = 1;
    ani.autoreverses = YES;
    ani.repeatCount = INFINITY;
    [_line.layer addAnimation:ani];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox *box = [UIVBox boxWithRect:rect];
    [box addFlex:1 toView:nil];
    
    [box addPixel:195 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:nil];
        [box addPixel:195 toView:_bkg];
        [box addFlex:1 toView:nil];
    }];
    
    [box addPixel:60 toView:_lblNotice];
    [box addFlex:1 toView:nil];
    [box apply];
    
    {
        UIVBox *box = [UIVBox boxWithRect:_bkg.bounds];
        [box addPixel:2 toView:_line];
        [box apply];
    }
}

@end

@interface UIBarCodeScannerView ()

@property (nonatomic, readonly) ZBarReaderView *barReader;
@property (nonatomic, readonly) MaskView *mask;

@end

@implementation UIBarCodeScannerView

- (void)onInit {
    [super onInit];
    
    _barReader = [[ZBarReaderView alloc] init];
    [self addSubview:_barReader];
    
    _mask = [[MaskView alloc] init];
    [self addSubview:_mask];
    
    SAFE_RELEASE(_barReader);
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    _barReader.frame = rect;
    _mask.frame = rect;
}

@end

@interface UIBarCodeScanner ()
<ZBarReaderViewDelegate>

@end

@implementation UIBarCodeScanner

- (void)onInit {
    [super onInit];
    self.hidesBottomBarWhenPushed = YES;
    self.classForView = [UIBarCodeScannerView class];
    self.actionMode = kNSActionModeDefault;
}

- (void)onLoaded {
    [super onLoaded];
    
    UIBarCodeScannerView* view = (id)self.view;
    view.barReader.readerDelegate = self;
    
    // 右上角的从相册扫描功能
    self.navigationItem.rightBarButtonItem = BLOCK_RETURN({
        UIBarButtonItem* btn = [UIBarButtonItem itemWithTitle:@"相册"];
        [btn.signals connect:kSignalClicked withSelector:@selector(__barcode_fromlocal) ofTarget:self];
        return btn;
    });
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalValueChanged)
SIGNALS_END

- (void)onAppearing {
    [super onAppearing];
    [self start];
}

- (void)onDisappearing {
    [super onDisappearing];
    [self stop];
}

- (void)start {
    UIBarCodeScannerView* view = (id)self.view;
    [view.barReader start];
}

- (void)stop {
    UIBarCodeScannerView* view = (id)self.view;
    [view.barReader stop];
}

- (void)readerView:(ZBarReaderView*)readerView
     didReadSymbols:(ZBarSymbolSet*)symbols
          fromImage:(UIImage*)image
{
    if (self.actionMode == kNSActionModeWait) {
        [readerView stop];
    }
    
    NSMutableArray* bars = [NSMutableArray temporary];
    for (ZBarSymbol *sym in symbols)
    {
        NSBarCode* tmp = [NSBarCode temporary];
        tmp.data = sym.data;
        [tmp log];
        
        [bars addObject:tmp];
    }
    
    [self.signals emit:kSignalValueChanged withResult:bars];
}

+ (NSArray*)ScanImage:(UIImage *)image {
    ZBarImageScanner* scn = [ZBarImageScanner temporary];
    ZBarImage* img = [[ZBarImage alloc] initWithCGImage:image.CGImage];
    NSInteger cnt = [scn scanImage:img];
    ZERO_RELEASE(img);
    if (cnt == 0)
        return [NSArray array];
    
    NSMutableArray* ret = [NSMutableArray temporary];
    for (ZBarSymbol *sym in scn.results)
    {
        NSBarCode* tmp = [NSBarCode temporary];
        tmp.data = sym.data;
        [tmp log];
        
        [ret addObject:tmp];
    }
    
    return ret;
}

- (void)__barcode_fromlocal {
    if ([[NSStorageExt shared] getBoolForKey:@"::ui::barcoder::tips::fromlocal" def:NO] == NO) {
        [[NSStorageExt shared] setBool:YES forKey:@"::ui::barcoder::tips::fromlocal"];
        [UIHud Text:@"可以从相册中选择一张图片来扫描"];
    }
    UIImageLibraryPicker* pk = [UIImageLibraryPicker temporary];
    pk.maxCount = 1;
    [pk.signals connect:kSignalImagePickerSuccess withBlock:^(SSlot *s) {
        UIImage* img = [s.data.object firstObject];
        NSArray* codes = [self.class ScanImage:img];
        if (codes.count == 0) {
            [UIHud Text:@"没有找到条码或二维码"];
        } else {
            [self.signals emit:kSignalValueChanged withResult:codes];
        }
    }];
    [pk executePicker];
}

@end

@interface UIBarCodeMaker ()

@property (nonatomic, retain, readwrite) UIImage *image;

@end

@implementation UIBarCodeMaker

- (void)onInit {
    [super onInit];
    self.hidesBottomBarWhenPushed = YES;
    self.classForView = [UIViewWrapper class];
    _size = 260;
}

- (void)onFin {
    ZERO_RELEASE(_content);
    ZERO_RELEASE(_image);
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalValueChanged)
SIGNALS_END

- (void)onLoaded {
    [super onLoaded];
    
    ((UIViewWrapper*)self.view).contentView = BLOCK_RETURN({
        return [UIImageViewExt temporary];
    });
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageViewExt* iv = (id)self.imageView;
    iv.contentMode = UIViewContentModeScaleAspectFit;
    
    if (self.content.notEmpty)
        [self updateData];
}

- (void)setContent:(NSString *)content {
    PROPERTY_COPY(_content, content);
    [self updateData];
}

- (void)updateData {
    DISPATCH_ASYNC_BEGIN

    DataMatrix* qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:self.content];
    UIImage* qrcodeImage = [QREncoder renderDataMatrix:qrMatrix imageDimension:self.size];
    [self.signals emit:kSignalValueChanged withResult:qrcodeImage];
    DISPATCH_ONMAIN({
        self.imageView.image = qrcodeImage;
    });
    
    DISPATCH_ASYNC_END
}

- (UIImageView*)imageView {
    return (id)self.view.behalfView;
}

@end

@implementation NSBarCode

- (void)onFin {
    ZERO_RELEASE(_data);
    [super onFin];
}

- (void)log {
    LOG("扫描出条码: %s", self.data.UTF8String);
}

@end
