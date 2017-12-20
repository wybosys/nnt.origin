
# import "app.h"
# import "VCPracticeScroll.h"
# import "VCPracticeTable.h"

@interface VPracticeNormalScroll : UIScrollViewExt

@property (nonatomic, readonly) UIButton *btnNext, *btnTop;
@property (nonatomic, readonly) VPracticeRollImages *rolImages;

@end

@implementation VPracticeNormalScroll

- (void)onInit {
    [super onInit];
    
    [self addSubview:BLOCK_RETURN({
        _btnTop = [UIButtonExt temporary];
        _btnTop.backgroundColor = [UIColor grayColor];
        _btnTop.text = @"TOP";
        return _btnTop;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _rolImages = [VPracticeRollImages temporary];
        return _rolImages;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnNext = [UIButtonExt temporary];
        _btnNext.backgroundColor = [UIColor grayColor];
        _btnNext.text = @"NEXT";
        return _btnNext;
    })];
    
    self.backgroundColor = [UIColor whiteColor];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox* box = [UIVBox boxWithRect:rect];
    [box addPixel:50 toView:_btnTop];
    [box addPixel:200 toView:_rolImages];
    [box addFlex:1 toView:nil];
    [box addPixel:50 toView:_btnNext];
    [box addFlex:1 toView:nil];
    [box apply];
    
    self.contentHeight = kUIApplicationSize.height * 2;
}

@end

@implementation VCPracticeNormalScroll

- (void)onInit {
    [super onInit];
    self.classForView = [VPracticeNormalScroll class];
    self.attributes.navigationBarDodge = YES;
}

- (void)onLoaded {
    [super onLoaded];

    VPracticeNormalScroll* view = (id)self.view;
    [view.btnTop.signals connect:kSignalClicked withSelector:@selector(actNull) ofTarget:self];
    [view.btnNext.signals connect:kSignalClicked withSelector:@selector(actNull) ofTarget:self];
    
    [view.signals connect:kSignalPullFlush withBlock:^(SSlot *s) {
        [UIHud Text:@"FLUSH"];
        view.workState = kNSWorkStateDone;
    }];
    [view.signals connect:kSignalPullMore withBlock:^(SSlot *s) {
        [UIHud Text:@"MORE"];
        view.workState = kNSWorkStateDone;
    }];
}

- (void)actNull {
    [self.navigationController pushViewController:[UINotImplementationViewController temporary]];
}

@end

@interface VCPracticeScroll ()

@property (nonatomic, readonly) UISegmentedControlExt* seg;

@end

@implementation VCPracticeScroll

- (void)onInit {
    [super onInit];
    
    self.attributes.navigationBarTranslucent = [NSBoolean Yes];
    self.attributes.navigationBarBlur = YES;
    self.attributes.navigationBarDodge = YES;
    
    self.title = @"SCROLL";
    self.classForView = [UIViewWrapper class];
}

- (void)onFin {
    [_seg.signals disconnect];
    [super onFin];
}

- (void)onLoaded {
    [super onLoaded];
    self.view.backgroundColor = [UIColor whiteColor];
    
    VCPracticeNormalScroll* c0 = [self reusableObject:@"c0" type:[VCPracticeNormalScroll class]];
    VCPracticeTable* c1 = [self reusableObject:@"c1" type:[VCPracticeTable class]];
    VCPracticeTable* c2 = [self reusableObject:@"c2" type:[VCPracticeTable class]];
    VCPracticeStretchHeaderScroll* c3 = [self reusableObject:@"c3" type:[VCPracticeStretchHeaderScroll class]];
    
    [self assignSubcontroller:c0];
    [self assignSubcontroller:c1];
    [self assignSubcontroller:c2];
    [self assignSubcontroller:c3];
    
    _seg = [[UISegmentedControlExt alloc] initWithItems:@[@"c0", @"c1", @"c2", @"c3"]];
    _seg.width = 200;
    [_seg.signals connect:kSignalSelectionChanged withSelector:@selector(actSegChanged:) ofTarget:self];
    self.navigationItem.titleView = _seg;
    _seg.selectedSegmentIndex = 0;
}

- (void)actSegChanged:(SSlot*)s {
    UISegmentedControlExt* seg = (id)s.sender;
    NSString* title = [seg titleForSegmentAtIndex:seg.selectedSegmentIndex];
    UIViewController* vc = [self reusableObject:title];
    ((UIViewWrapper*)self.view).contentView = vc.view;
}

@end

@interface VPracticeRollImages ()
<UIPagedViewDataSource>

@end

# define VPRI_PAGES 6

@implementation VPracticeRollImages

- (void)onInit {
    [super onInit];
    
    [self addSubcontroller:BLOCK_RETURN({
        _vcPages = [UIPagedViewController temporary];
        _vcPages.option = kUIPagedOptionInfinite;
        //_vcPages.option = kUIPagedOptionAutomicContinued;
        //_vcPages.option = kUIPagedOptionAutomatic | kUIPagedOptionContinued | kUIPagedOptionBackward;
        return _vcPages;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _ctlPage = [UIPageControlExt temporary];
        return _ctlPage;
    })];
    
    _vcPages.pages = [NSArray arrayWithTypes:[UILabelExt class] count:VPRI_PAGES init:^(UILabelExt* obj, NSInteger idx) {
        obj.textAlignment = NSTextAlignmentCenter;
        obj.textColor = [UIColor randomColor];
        obj.textFont = [UIFont boldSystemFontOfSize:60];
        obj.backgroundColor = [obj.textColor bleachWithValue:.9];
        obj.text = [NSString stringWithFormat:@"%d", (int)idx];
    }];
    _vcPages.pagedView.dataSource = self;
    [_vcPages.signals connect:kSignalSelectionChanged withSelector:@selector(cbSelectedChanged:) ofTarget:self];
    [_vcPages reloadData];
    _vcPages.selectedIndex = 1;
    
    for (int i = 0; i < 7; ++i) {
        NSString* name = [NSString stringWithFormat:@"page%d", i];
        [_ctlPage setImage:[UIImage imageNamed:name] forPage:i];
    }
}

- (void)cbSelectedChanged:(SSlot*)s {
    _ctlPage.numberOfPages = VPRI_PAGES;
    _ctlPage.currentPage = [s.data.object intValue];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    _vcPages.view.frame = rect;
    
    UIVBox* box = [UIVBox boxWithRect:rect];
    [box addFlex:1 toView:nil];
    [box addPixel:20 toView:_ctlPage];
    [box apply];
}

- (Class)pagedView:(UIPagedView*)view typeForPageAtIndex:(NSInteger)idx {
    return [UILabelExt class];
}

- (void)pagedView:(UIPagedView *)view page:(UILabelExt*)obj atIndex:(NSInteger)idx {
    obj.textAlignment = NSTextAlignmentCenter;
    obj.textColor = [UIColor randomColor];
    obj.textFont = [UIFont boldSystemFontOfSize:60];
    obj.backgroundColor = [obj.textColor bleachWithValue:.9];
    obj.text = [NSString stringWithFormat:@"%d", (int)idx];
}

- (NSInteger)numberOfPagesInPagedView:(UIPagedView*)view {
    return VPRI_PAGES;
}

@end

@interface VPracticeSimpleScroll : UIScrollViewExt

@property (nonatomic, readonly) UIButtonExt
*btnTop,
*btnBottom
;

@end

@implementation VPracticeSimpleScroll

- (void)onInit {
    [super onInit];
    
    [self addSubview:BLOCK_RETURN({
        _btnTop = [UIButtonExt temporary];
        _btnTop.backgroundColor = [UIColor redColor];
        _btnTop.text = @"TOP";
        return _btnTop;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnBottom = [UIButtonExt temporary];
        _btnBottom.backgroundColor = [UIColor redColor];
        _btnBottom.text = @"BOTTOM";
        return _btnBottom;
    })];
    
    self.backgroundColor = [UIColor whiteColor];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox* box = [UIVBox boxWithRect:rect];
    [box addPixel:30 toView:_btnTop];
    [box addFlex:1 toView:nil];
    [box addPixel:30 toView:_btnBottom];
    [box apply];
    
    self.contentHeight = box.position.y;
}

@end

@implementation VCPracticeSimpleScroll

- (void)onInit {
    [super onInit];
    self.title = @"SimpleScroll";
    self.classForView = [VPracticeSimpleScroll class];
    
    self.attributes.navigationBarTranslucent = [NSBoolean Yes];
    self.attributes.navigationBarDodge = YES;
    self.attributes.navigationBarBlur = YES;
}

- (void)onLoaded {
    [super onLoaded];
}

@end

@interface VPracticeStretchHeader : UIViewExt <UIStretchableView, UIConstraintView>

@property (nonatomic, readonly) UIImageViewExt *imgBg;

@end

@implementation VPracticeStretchHeader

- (void)onInit {
    [super onInit];
    [self addSubview:BLOCK_RETURN({
        _imgBg = [UIImageViewExt temporary];
        _imgBg.fadesChanging = YES;
        _imgBg.contentMode = UIViewContentModeScaleAspectFill;
        _imgBg.imageDataSource = @"http://d.hiphotos.baidu.com/image/pic/item/a50f4bfbfbedab643806ced4f436afc379311ea9.jpg";
        [_imgBg.signals connect:kSignalImageChanged redirectTo:kSignalConstraintChanged ofTarget:self];
        return _imgBg;
    })];
    
    [self.signals connect:kSignalClicked withBlock:^(SSlot *s) {
        _imgBg.imageDataSource = @"http://e.hiphotos.baidu.com/image/pic/item/8d5494eef01f3a2901e887e59a25bc315c607cfc.jpg";
    }];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalConstraintChanged)
SIGNALS_END

- (UIView*)viewForStretchable {
    return _imgBg;
}

- (CGFloat)heightForStretchable {
    return self.bounds.size.height;
}

- (CGSize)bestSize:(CGSize)sz {
    return CGSizeMake(0, 200);
}

- (CGSize)constraintBounds {
    return _imgBg.image.size;
}

@end

@implementation VCPracticeStretchHeaderScroll

- (void)onLoaded {
    [super onLoaded];
    self.tableView.tableHeaderView = BLOCK_RETURN({
        VPracticeStretchHeader* v = [VPracticeStretchHeader temporary];
        return v;
    });
}

@end
