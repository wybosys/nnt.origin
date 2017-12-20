
# import "app.h"
# import "VCPracticeSignalSlot.h"
# import "VCPracticeWidgets.h"

@interface VPracticeSignalSlot : UIViewExt

@property (nonatomic, readonly) VPracticeButton
*btnComplex,
*btnBenchmark
;

@end

@implementation VPracticeSignalSlot

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:BLOCK_RETURN({
        _btnComplex = [VPracticeButton temporary];
        _btnComplex.text = @"Complex Signals";
        return _btnComplex;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnBenchmark = [VPracticeButton temporary];
        _btnBenchmark.text = @"Benchmark";
        return _btnBenchmark;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox* box = [UIVBox boxWithRect:rect withSpacing:5];
    [box addPixel:30 toView:_btnComplex];
    [box addPixel:30 toView:_btnBenchmark];
    [box apply];
}

@end

@implementation VCPracticeSignalSlot

- (void)onInit {
    [super onInit];
    self.title = @"Signal Slot";
    self.hidesBottomBarWhenPushed = YES;
    self.classForView = [VPracticeSignalSlot class];
}

- (void)onLoaded {
    [super onLoaded];
    
    VPracticeSignalSlot* view = (id)self.view;
    [view.btnComplex.signals connect:kSignalClicked withSelector:@selector(testComplex) ofTarget:self];
    [view.btnBenchmark.signals connect:kSignalClicked withSelector:@selector(actBenchmark) ofTarget:self];
}

- (void)testComplex {
    NSObject* obj = [self reusableObject:@"complexobj" instance:^id{
        NSObject* obj = [NSObject temporary];
        
        [obj.signals addSignal:@"A"];
        [obj.signals addSignal:@"B"];
        [obj.signals addSignal:@"C"];
        
        [obj.signals connects:[SComplexSignal Or:@"A", @"B", nil] withBlock:^(SSlot *s) {
            [UIHud Text:@"DONE"];
        }].boundaryEmit = 1;
        
        [obj.signals connect:@"A" withBlock:^(SSlot *s) {
            LOG("A");
        }];
        [obj.signals connect:@"B" withBlock:^(SSlot *s) {
            LOG("B");
        }];
        [obj.signals connect:@"C" withBlock:^(SSlot *s) {
            LOG("C");
        }];
        return obj;
    }];
    
    switch ([self.attachment.strong getInt:@"tcomplex"] % 3)
    {
        case 0: [obj.signals emit:@"C"]; break;
        case 1: [obj.signals emit:@"A"]; break;
        case 2: [obj.signals emit:@"B"]; break;
    }
    
    [self.attachment.strong setInt:[self.attachment.strong getInt:@"tcomplex"]+1 forKey:@"tcomplex"];
}

- (void)actBenchmark {
    NSPerformanceSuit* ps = [self reusableObject:@"ps" type:[NSPerformanceSuit class]];
    if (ps.isEmpty == NO)
        return;
    
    [ps measure:@"连接断开 10w 次" block:^{
        NSObject* obj = [NSObject temporary];
        [obj.signals addSignal:@"test"];
        for (int i = 0; i < 100000; ++i) {
            [obj.signals connect:@"test" withSelector:@selector(pass) ofTarget:obj];
            [obj.signals disconnect:@"test" withSelector:@selector(pass) ofTarget:obj];
        }
    }];
    
    [ps measure:@"激活 10w 次信号(绑定100个插槽)" block:^{
        NSObject* obj = [NSObject temporary];
        [obj.signals addSignal:@"test"];
        for (int i = 0; i < 100; ++i) {
            [obj.signals connect:@"test" withSelector:@selector(pass) ofTarget:obj];
        }
        for (int i = 0; i < 100000; ++i) {
            [obj.signals emit:@"test"];
        }
    }];
    
    [ps start];
}

@end
