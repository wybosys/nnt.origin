
# import "app.h"
# import "VCPracticeDbKv.h"
# import "VCPracticeWidgets.h"
# import "DBOracleBDB.h"

@interface VPracticeDbKv : UIViewExt

@property (nonatomic, readonly) UITextFieldExt *inpKey, *inpValue;
@property (nonatomic, readonly) UIButtonExt *btnAdd, *btnGet, *btnDel;

// benchmark
@property (nonatomic, readonly) VPracticeButton
*btnBenchmark;

@end

@implementation VPracticeDbKv

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:BLOCK_RETURN({
        _inpKey = [UITextFieldExt temporary];
        _inpKey.placeholder = @"KEY";
        _inpKey.borderStyle = UITextBorderStyleBezel;
        return _inpKey;
    })];

    [self addSubview:BLOCK_RETURN({
        _inpValue = [UITextFieldExt temporary];
        _inpValue.placeholder = @"VALUE";
        _inpValue.borderStyle = UITextBorderStyleBezel;
        return _inpValue;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnAdd = [UIButtonExt temporary];
        _btnAdd.text = @"SAVE";
        _btnAdd.textColor = [UIColor blackColor];
        return _btnAdd;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnGet = [UIButtonExt temporary];
        _btnGet.text = @"GET";
        _btnGet.textColor = [UIColor blackColor];
        return _btnGet;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnDel = [UIButtonExt temporary];
        _btnDel.text = @"DEL";
        _btnDel.textColor = [UIColor redColor];
        return _btnDel;
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
    [box addPixel:30 toView:_inpKey];
    [box addPixel:30 toView:_inpValue];
    [box addPixel:30 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_btnAdd];
        [box addFlex:1 toView:_btnGet];
        [box addFlex:1 toView:_btnDel];
    }];
    [box addPixel:30 toView:_btnBenchmark];
    [box apply];
}

@end

@interface VCPracticeDbKv ()

@property (nonatomic, readonly) NSPerformanceSuit* ps;

@end

@implementation VCPracticeDbKv

- (void)onInit {
    [super onInit];
    self.title = @"DB - KeyValue";
    self.hidesBottomBarWhenPushed = YES;
    self.classForView = [VPracticeDbKv class];
    
    _ps = [[NSPerformanceSuit alloc] init];
}

- (void)onLoaded {
    [super onLoaded];
    
    VPracticeDbKv* view = (id)self.view;
    [view.btnAdd.signals connect:kSignalClicked withSelector:@selector(actSAVE) ofTarget:self];
    [view.btnGet.signals connect:kSignalClicked withSelector:@selector(actGET) ofTarget:self];
    [view.btnDel.signals connect:kSignalClicked withSelector:@selector(actDEL) ofTarget:self];
    [view.btnBenchmark.signals connect:kSignalClicked withSelector:@selector(actBenchmark) ofTarget:self];
}

- (void)actSAVE {
    VPracticeDbKv* view = (id)self.view;
    NSString* k = view.inpKey.text;
    NSString* v = view.inpValue.text;
    [[NSStorageExt shared] setObject:v forKey:k];
}

- (void)actGET {
    VPracticeDbKv* view = (id)self.view;
    NSString* k = view.inpKey.text;
    NSString* v = [[NSStorageExt shared] getObjectForKey:k def:@""];
    view.inpValue.text = v;
}

- (void)actDEL {
    VPracticeDbKv* view = (id)self.view;
    NSString* k = view.inpKey.text;
    [[NSStorageExt shared] remove:k];
}

- (void)actBenchmark {
    [_ps measure:@"10w string add" block:^{
        OracleBDB* bdb = [OracleBDB dbWithConfig:[DBConfig tempFile:@"test.bdb"]];
        for (int i = 0; i < 100000; ++i) {
            [bdb setObject:[NSString RandomString:10] forKey:@(i).stringValue];
        }
        [bdb close];
    }];
    
    [_ps measure:@"10w string read" block:^{
        OracleBDB* bdb = [OracleBDB dbWithConfig:[DBConfig tempFile:@"test.bdb"]];
        for (int i = 0; i < 100000; ++i) {
            NSString* str = [bdb objectForKey:@(i).stringValue];
            if (str == nil)
                FATAL("BDB lost data");
        }
        [bdb close];
    }];
    
    [_ps measure:@"10w string delete" block:^{
        OracleBDB* bdb = [OracleBDB dbWithConfig:[DBConfig tempFile:@"test.bdb"]];
        for (int i = 0; i < 100000; ++i) {
            BOOL suc = [bdb removeForKey:@(i).stringValue];
            if (suc == NO)
                FATAL("BDB lost data");
        }
        [bdb close];
    }];
    
    [_ps start];
}

@end
