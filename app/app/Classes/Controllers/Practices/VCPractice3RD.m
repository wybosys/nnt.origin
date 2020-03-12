
#import "app.h"
#import "VCPractice3RD.h"
#import "VCPracticeWidgets.h"
#import "VCPracticeCodeReader.h"
#import "VCPracticeFacebookPop.h"
#import "PracticeSnsPlatform.h"
#import <GPUImage/GPUImage.h>

@interface VPractice3RD : UIScrollViewExt

@property (nonatomic, readonly) UITextViewExt *inpText;
@property (nonatomic, readonly) VPracticeButton
*btnWeibo, *btnShareWeibo,
*btnQQ, *btnShareQQ, *btnShareQQSpace,
*btnWeixin, *btnShareWeixin,
*btnCodeReader,
*btnCodeMaker,
*btnPop,
*btnGpuImage;

@end

@implementation VPractice3RD

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:BLOCK_RETURN({
        _inpText = [UITextViewExt new];
        _inpText.placeholder = @"请输入将要分享的文字";
        _inpText.text = @"测试分享";
        return _inpText;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnWeibo = [VPracticeButton new];
        _btnWeibo.text = @"WEIBO";
        return _btnWeibo;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnShareWeibo = [VPracticeButton new];
        _btnShareWeibo.text = @"Share Weibo";
        return _btnShareWeibo;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnQQ = [VPracticeButton new];
        _btnQQ.text = @"QQ";
        return _btnQQ;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnShareQQ = [VPracticeButton new];
        _btnShareQQ.text = @"Share QQ";
        return _btnShareQQ;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnShareQQSpace = [VPracticeButton new];
        _btnShareQQSpace.text = @"Share QQSpace";
        return _btnShareQQSpace;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnWeixin = [VPracticeButton new];
        _btnWeixin.text = @"Weixin";
        return _btnWeixin;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnShareWeixin = [VPracticeButton new];
        _btnShareWeixin.text = @"Share Weixin";
        return _btnShareWeixin;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnCodeReader = [VPracticeButton new];
        _btnCodeReader.text = @"QRCODE READER";
        return _btnCodeReader;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnCodeMaker = [VPracticeButton new];
        _btnCodeMaker.text = @"QRCODE MAKER";
        return _btnCodeMaker;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnPop = [VPracticeButton new];
        _btnPop.text = @"Facebook Pop";
        return _btnPop;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnGpuImage = [VPracticeButton new];
        _btnGpuImage.text = @"GPUImage Movie";
        return _btnGpuImage;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox* box = [UIVBox boxWithRect:rect withSpacing:5];
    [box addPixel:100 toView:_inpText];
    
    [box addPixel:30 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_btnWeibo];
        [box addFlex:1 toView:_btnShareWeibo];
    }];
    
    [box addPixel:30 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_btnQQ];
        [box addFlex:1 toView:_btnShareQQ];
        [box addFlex:1 toView:_btnShareQQSpace];
    }];

    [box addPixel:30 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_btnWeixin];
        [box addFlex:1 toView:_btnShareWeixin];
    }];

    [box addPixel:30 toView:_btnCodeReader];
    [box addPixel:30 toView:_btnCodeMaker];
    [box addPixel:30 toView:_btnPop];
    [box addPixel:30 toView:_btnGpuImage];
    
    [box apply];
}

@end

@implementation VCPractice3RD

- (void)onInit {
    [super onInit];
    self.title = @"第三方";
    self.classForView = [VPractice3RD class];
}

- (void)onLoaded {
    [super onLoaded];
    
    VPractice3RD* view = (id)self.view;
    [view.btnWeibo.signals connect:kSignalClicked withSelector:@selector(connectWeibo) ofTarget:self];
    [view.btnQQ.signals connect:kSignalClicked withSelector:@selector(connectQQ) ofTarget:self];
    [view.btnShareQQ.signals connect:kSignalClicked withSelector:@selector(shareQQ) ofTarget:self];
    [view.btnShareQQSpace.signals connect:kSignalClicked withSelector:@selector(shareQQSpace) ofTarget:self];
    [view.btnWeixin.signals connect:kSignalClicked withSelector:@selector(connectWeixin) ofTarget:self];
    [view.btnCodeReader.signals connect:kSignalClicked withSelector:@selector(codeReader) ofTarget:self];
    [view.btnCodeMaker.signals connect:kSignalClicked withSelector:@selector(codeMaker) ofTarget:self];
    [view.btnPop.signals connect:kSignalClicked withSelector:@selector(facebookPop) ofTarget:self];
    [view.btnGpuImage.signals connect:kSignalClicked withSelector:@selector(gpuImagePlay) ofTarget:self];
}

- (SnsContent*)shareContent {
    VPractice3RD* view = (id)self.view;
    PracticeSnsContent* ret = [PracticeSnsContent temporary];
    ret.text = view.inpText.text;
    ret.image = [NSDataSource dsWithBundle:[[UIScreen namedForLaunchImage] stringByAppendingString:@".png"]];
    //ret.callback = @"strong.hdapp://abc";
    return ret;
}

- (void)connectWeibo {
    SnsWeibo* so = [SnsWeibo temporary];
    so.shareByServer = NO;
    [so bind:^{
        [so userinfo];
    }];
}

- (void)connectQQ {
    SnsQQ* so = [SnsQQ temporary];
    [so bind:^{
        [so userinfo];
    }];
}

- (void)connectWeixin {
    SnsWeixin* so = [SnsWeixin temporary];
    [so share:self.shareContent];
}

- (void)shareQQ {
    
}

- (void)shareQQSpace {
    
}

- (void)shareWeibo {
    
}

- (void)shareWeixin {
    
}

- (void)codeReader {
    VCPracticeCodeReader* ctlr = [VCPracticeCodeReader temporary];
    [self.navigationController pushViewController:ctlr];
}

- (void)codeMaker {
    UIBarCodeMaker* ctlr = [UIBarCodeMaker temporary];
    ctlr.content = @"http://www.baidu.com";
    [self.navigationController pushViewController:ctlr];
}

- (void)facebookPop {
    VCPracticeFacebookPop* ctlr = [VCPracticeFacebookPop temporary];
    [self.navigationController pushViewController:ctlr];
}

- (void)gpuImagePlay {
    GPUImageView *gp = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    gp.backgroundColor = [UIColor clearColor];
    [self.view addSubview:gp];

    NSURL *fmov = [NSBundle URLForFileNamed:@"white.mp4"];
    //AVPlayerItem *itmov = [[AVPlayerItem alloc] initWithURL:fmov];
    
    GPUImageChromaKeyBlendFilter *filter = [[GPUImageChromaKeyBlendFilter alloc] init];
    [filter setColorToReplaceRed:1 green:0 blue:1];
    filter.smoothing = 0.3;
    filter.thresholdSensitivity = 0.15;
    
    GPUImageMovie *mov = [[GPUImageMovie alloc] initWithURL:fmov];
    mov.playAtActualSpeed = YES;
    mov.shouldRepeat = YES;
    //mov.runBenchmark = YES;
    [mov addTarget:filter];
    
    //[mov addTarget:gp];
    [mov startProcessing];
    
    //AVPlayer *player = [[AVPlayer alloc] init];
    //player.rate = 1;
    //[player replaceCurrentItemWithPlayerItem:itmov];
    
    UIImage *timg = [UIImage imageNamed:@"transparent.png"];
    GPUImagePicture *vbkg = [[GPUImagePicture alloc] initWithImage:timg smoothlyScaleOutput:YES];
    [vbkg addTarget:filter];
    [vbkg processImage];
    
    [filter addTarget:gp];
    
    //DISPATCH_DELAY_BEGIN(0.1)
    //[player seekToTime:kCMTimeZero];
    //[player play];
    //DISPATCH_DELAY_END
}

@end
