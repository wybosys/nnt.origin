
# import "app.h"
# import "VCPracticeSnapshot.h"
# import "VCPracticeWidgets.h"

@interface VPracticeSnapshot : UIViewExt

@property (nonatomic, readonly) VPracticeButton
*btnSnapshot;

@property (nonatomic, readonly) UIImageViewExt *imgPic;

@end

@implementation VPracticeSnapshot

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:BLOCK_RETURN({
        _btnSnapshot = [VPracticeButton temporary];
        _btnSnapshot.text = @"Snapshot";
        return _btnSnapshot;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _imgPic = [UIImageViewExt temporary];
        _imgPic.contentMode = UIViewContentModeScaleAspectFit;
        _imgPic.imageDataSource = @"http://image.zcool.com.cn/2013/16/26/1371454149868.jpg";
        return _imgPic;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox* box = [UIVBox boxWithRect:rect withSpacing:5];
    [box addPixel:30 toView:_btnSnapshot];
    [box addFlex:1 toView:_imgPic];
    [box apply];
}

@end

@implementation VCPracticeSnapshot

- (void)onInit {
    [super onInit];
    self.classForView = [VPracticeSnapshot class];
}

- (void)onLoaded {
    [super onLoaded];
    VPracticeSnapshot* view = (id)self.view;
    [view.btnSnapshot.signals connect:kSignalClicked withSelector:@selector(actSnapshot) ofTarget:self];
}

- (void)actSnapshot {
    VPracticeSnapshot* view = (id)self.view;
    [NSPerformanceMeasure measure:^{
        view.imgPic.image = view.renderToImage;
    }];
}

@end
