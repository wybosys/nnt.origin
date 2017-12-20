
# import "app.h"
# import "VCPracticeMask.h"

@interface VPracticeMask : UIViewExt

@property (nonatomic, readonly) UIMaskStackView *vMask;

@end

@implementation VPracticeMask

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:BLOCK_RETURN({
        _vMask = [UIMaskStackView temporary];
        return _vMask;
    })];
    
    [_vMask addMask:BLOCK_RETURN({
        UILabelExt* lbl = [UILabelExt temporary];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.textFont = [UIFont boldSystemFontOfSize:30];
        lbl.textColor = [UIColor randomColor];
        lbl.stylizedString = BLOCK_RETURN({
            NSStylizedString* str = [NSStylizedString temporary];
            [str append:[NSStylization textColor:[UIColor randomColor]] format:[NSString RandomString:10]];
            [str append:[NSStylization textColor:[UIColor randomColor]] format:[NSString RandomString:10]];
            return str;
        });
        return lbl;
    })];
    
    [_vMask addNormal:BLOCK_RETURN({
        UIImageViewExt* img = [UIImageViewExt temporary];
        img.contentMode = UIViewContentModeScaleAspectFill;
        img.imageDataSource = @"http://image.zcool.com.cn/2013/16/26/1371454149868.jpg";
        CAAnimation* ani = [CAKeyframeAnimation RotateFrom:0 To:M_2PI];
        ani.duration = 5;
        ani.repeatCount = INFINITY;
        [img.layer addAnimation:ani];
        return img;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    _vMask.frame = rect;
}

@end

@implementation VCPracticeMask

- (void)onInit {
    [super onInit];
    self.classForView = [VPracticeMask class];
}

@end
