
# import "app.h"
# import "VCPracticeSketch.h"

@interface VPracticeSketch : UIViewExt

@property (nonatomic, readonly) CASketchLayer *lyrSketch;
@property (nonatomic, readonly) CGPrimitivePolygon *prm;

@end

@implementation VPracticeSketch

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self.layer addSublayer:BLOCK_RETURN({
        _lyrSketch = [CASketchLayer new];
        _lyrSketch.sketch.pen = [CGPen Pen:[UIColor randomColor].CGColor width:5];
        _lyrSketch.sketch.brush = BLOCK_RETURN({
            CGLinearGradientBrush* br = [CGLinearGradientBrush temporary];
            [br addColor:[UIColor randomColor].CGColor];
            [br addColor:[UIColor randomColor].CGColor];
            return br;
        });
        [_lyrSketch.sketch add:BLOCK_RETURN({
            _prm = [CGPrimitivePolygon new];
            return _prm;
        })];
        return _lyrSketch;
    })];
    
    [self.signals connect:kSignalTouchesMoved withBlock:^(SSlot *s) {
        [_prm add:self.extension.positionTouched];
        [_lyrSketch setNeedsDisplay];
    }];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    _lyrSketch.frame = rect;
}

@end

@implementation VCPracticeSketch

- (void)onInit {
    [super onInit];
    self.hidesBottomBarWhenPushed = YES;
    self.title = @"SKETCH";
    self.classForView = [VPracticeSketch class];
    self.panToBack = NO;
    self.enableContainerGesture = NO;
}

@end
