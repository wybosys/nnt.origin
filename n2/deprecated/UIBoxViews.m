
# import "Common.h"
# import "UIBoxViews.h"

/*
              2
              4
            3 0 1
              5
 */

enum {
    kBoxFaceFront = 0,
    kBoxFaceBack = 2,
    kBoxFaceLeft = 3,
    kBoxFaceRight = 1,
    kBoxFaceTop = 4,
    kBoxFaceBottom = 5,
    kBoxFaceCount = 6,
};

@interface UIBoxViews ()
{
    UIView *_views[kBoxFaceCount];
}

@end

@implementation UIBoxViews

- (void)onInit {
    [super onInit];
    
    self.backgroundColor = [UIColor grayColor];
    
    for (int i = 0; i < kBoxFaceCount; ++i) {
        UIView* v = [[UIViewExt alloc] initWithZero];
        _views[i] = v;
        [self addSubview:v];
        SAFE_RELEASE(v);
        
        v.userInteractionEnabled = NO;
        v.layer.doubleSided = NO;
    }
    
    [self updateFaces];
    
    CATransform3D mat = CATransform3DIdentity;
    mat.m34 = 0.001;
    self.layer.sublayerTransform = mat;
    
    [self.signals connect:kSignalTouchesMoved withSelector:@selector(cbTouches:) ofTarget:self];
}

- (void)onFin {
    [super onFin];
}

- (void)updateFaces {
    _views[kBoxFaceFront].backgroundColor = [UIColor redColor];
    
    _views[kBoxFaceLeft].backgroundColor = [UIColor greenColor];
    _views[kBoxFaceLeft].layer.anchorPoint = CGPointMake(1, 0.5);
    _views[kBoxFaceLeft].layer.transform = CATransform3DMakeRotation(M_PI_2, 0, 1, 0);
    
    _views[kBoxFaceBack].backgroundColor = [UIColor blueColor];
    _views[kBoxFaceBack].layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
    
    _views[kBoxFaceRight].backgroundColor = [UIColor yellowColor];
    _views[kBoxFaceRight].layer.anchorPoint = CGPointMake(0, 0.5);
    _views[kBoxFaceRight].layer.transform = CATransform3DMakeRotation(M_PI_2, 0, -1, 0);
    
    _views[kBoxFaceTop].backgroundColor = [UIColor orangeColor];
    _views[kBoxFaceTop].layer.anchorPoint = CGPointMake(0.5, 1);
    _views[kBoxFaceTop].layer.transform = CATransform3DMakeRotation(M_PI_2, -1, 0, 0);
    
    _views[kBoxFaceBottom].backgroundColor = [UIColor whiteColor];
    _views[kBoxFaceBottom].layer.anchorPoint = CGPointMake(0.5, 0);
    _views[kBoxFaceBottom].layer.transform = CATransform3DMakeRotation(M_PI_2, 1, 0, 0);
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    rect = CGRectDeflateWithRatio(rect, .2, .2);
    
    _views[kBoxFaceFront].frame = rect;
    _views[kBoxFaceFront].layer.zPosition = 0;
    
    _views[kBoxFaceBack].frame = rect;
    _views[kBoxFaceBack].layer.zPosition = rect.size.width;
    
    _views[kBoxFaceLeft].frame = CGRectOffset(rect, -rect.size.width, 0);
    _views[kBoxFaceLeft].layer.zPosition = 0;
    
    _views[kBoxFaceRight].frame = CGRectOffset(rect, rect.size.width, 0);
    _views[kBoxFaceRight].layer.zPosition = 0;
    
    CGRect tbrc = rect;
    tbrc.size = CGSizeSquare(tbrc.size, kCGEdgeMin);
    
    _views[kBoxFaceTop].frame = CGRectOffset(tbrc, 0, -tbrc.size.height);
    _views[kBoxFaceTop].layer.zPosition = 0;
    
    _views[kBoxFaceBottom].frame = CGRectOffset(tbrc, 0, rect.size.height);
    _views[kBoxFaceBottom].layer.zPosition = 0;
}

- (void)cbTouches:(SSlot*)s {
    CGPoint ptold = self.extension.deltaTouched;
    
    CGFloat radx = M_DEGREE, rady = M_DEGREE;
    radx = radx * ptold.x;
    rady = -rady * ptold.y;
    
    CATransform3D mat = self.layer.sublayerTransform;
    mat = CATransform3DTranslate(mat, 0, 0, 80);
    mat = CATransform3DRotate(mat, radx, 0, -1, 0);
    mat = CATransform3DRotate(mat, rady, -1, 0, 0);
    mat = CATransform3DTranslate(mat, 0, 0, -80);
    self.layer.sublayerTransform = mat;
}

@end
