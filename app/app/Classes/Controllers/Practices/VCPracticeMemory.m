
# import "app.h"
# import "VCPracticeMemory.h"
# import "NSMemCache.h"

@interface VPracticeMemory : UIScrollViewExt

@property (nonatomic, readonly) VPracticeButton
*btnFlymake;

@end

@implementation VPracticeMemory

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:BLOCK_RETURN({
        _btnFlymake = [VPracticeButton temporary];
        _btnFlymake.text = @"Flymake";
        return _btnFlymake;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    UIVBox* box = [UIVBox boxWithRect:rect withSpacing:5];
    [box addPixel:30 toView:_btnFlymake];
    [box apply];
}

@end

@implementation VCPracticeMemory

- (void)onInit {
    [super onInit];
    self.classForView = [VPracticeMemory class];
}

- (void)onLoaded {
    [super onLoaded];
    VPracticeMemory* view = (id)self.view;
    [view.btnFlymake.signals connect:kSignalClicked withSelector:@selector(actFlymake) ofTarget:self];
}

- (void)actFlymake {
    NSFlymakeCache* fc = [NSFlymakeCache temporary];
    fc.threshold = 100;
    fc.thresholdFifo = 50;
    
    for (int i = 0; i < 200; ++i) {
        NSString* str = @(i).stringValue;
        [fc addInstance:^id{
            return str;
        } withKey:str];
    }
    
    for (int i = 30; i < 50; ++i) {
        NSString* str = @(i).stringValue;
        [fc objectForKey:str];
    }
    
    for (int i = 0; i < 200; ++i) {
        NSString* str = @(i).stringValue;
        [fc addInstance:^id{
            return str;
        } withKey:str];
    }
    
    LOG("flymake: %d", fc.count);
}

@end
