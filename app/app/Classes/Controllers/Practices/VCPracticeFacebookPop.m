
# import "app.h"
# import "VCPracticeFacebookPop.h"
# import <pop/POP.h>
# import "VCPracticeWidgets.h"

@interface VPracticeFacebookPop : UIViewExt

@property (nonatomic, readonly)
VPracticeButton
*btnSpring,
*btnDecay
;

@end

@implementation VPracticeFacebookPop

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:BLOCK_RETURN({
        _btnSpring = [VPracticeButton temporary];
        _btnSpring.text = @"Spring";
        return _btnSpring;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnDecay = [VPracticeButton temporary];
        _btnDecay.text = @"Decay";
        return _btnDecay;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox* box = [UIVBox boxWithRect:rect withSpacing:5];
    [box addPixel:30 toView:_btnSpring];
    [box addPixel:30 toView:_btnDecay];
    [box apply];
}

@end

@implementation VCPracticeFacebookPop

- (void)onInit {
    [super onInit];
    self.classForView = [VPracticeFacebookPop class];
}

- (void)onFin {
    [super onFin];
}

- (void)onLoaded {
    [super onLoaded];
    VPracticeFacebookPop* view = (id)self.view;
    [view.btnSpring.signals connect:kSignalClicked withSelector:@selector(actSpring:) ofTarget:self];
    [view.btnDecay.signals connect:kSignalClicked withSelector:@selector(actDecay:) ofTarget:self];
}

- (void)actSpring:(SSlot*)s {
    UIView* v = (id)s.sender;
    POPSpringAnimation *ani = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
    ani.springBounciness = 20.0f;
    ani.toValue = @(M_PI/4);
    ani.velocity = @(0.5);
    [v.layer pop_addAnimation:ani forKey:nil];
}

- (void)actDecay:(SSlot*)s {
    UIView* v = (id)s.sender;
    POPDecayAnimation* ani = [POPDecayAnimation animationWithPropertyNamed:kPOPLayerPosition];
    ani.velocity = [NSValue valueWithCGPoint:CGPointMake(0, 200)];
    [v.layer pop_addAnimation:ani forKey:nil];
}

@end
