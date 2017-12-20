
# import "app.h"
# import "VCPracticeTableSplit.h"
# import "VCPracticeTable.h"

@interface VPracticeTableSplit : UIViewExt

@property (nonatomic, readonly) UISearchBarExt *barSearch;
@property (nonatomic, readonly) VCPracticeSimpleTable *ctlrTable;

@end

@implementation VPracticeTableSplit

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor grayColor];
    self.dodgeTopRegion = YES;
    
    [self addSubview:BLOCK_RETURN({
        _barSearch = [UISearchBarExt new];
        _barSearch.placeholder = @"SEARCH";
        return _barSearch;
    })];
    
    [self addSubcontroller:BLOCK_RETURN({
        _ctlrTable = [VCPracticeSimpleTable new];
        _ctlrTable.view.backgroundColor = [UIColor whiteColor];
        _ctlrTable.tableView.skipsNavigationBarInsetsAdjust = YES;
        return _ctlrTable;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox* box = [UIVBox boxWithRect:rect];
    [box addPixel:_barSearch.bestHeight toView:_barSearch];
    [box addFlex:1 toView:nil];
    [box addPixel:260 toView:_ctlrTable.view];
    [box apply];
}

@end

@implementation VCPracticeTableSplit

- (void)onInit {
    [super onInit];
    self.title = @"SPLIT TABLE";
    self.hidesBottomBarWhenPushed = YES;
    
    self.classForView = [VPracticeTableSplit class];
    self.attributes.navigationBarTranslucent = [NSBoolean Yes];
    self.attributes.navigationBarBlur = YES;
}

- (void)onLoaded {
    [super onLoaded];
    
    VPracticeTableSplit* view = (id)self.view;
    [view.barSearch.signals connect:kSignalSearchString withBlock:^(SSlot *s) {
        [view.ctlrTable flushData];
    }];
}

@end
