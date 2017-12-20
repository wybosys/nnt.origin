
# import "app.h"
# import "VCPracticeCustomSearch.h"

@interface VPracticeCustomSearch : UIViewExt

@property (nonatomic, readonly) UIUnifiedSearchBar* searchbar;

@end

@implementation VPracticeCustomSearch

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:BLOCK_RETURN({
        _searchbar = [UIUnifiedSearchBar temporary];
        return _searchbar;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox* box = [UIVBox boxWithRect:rect];
    [box addPixel:_searchbar.bestHeight toView:_searchbar];
    [box apply];
}

@end

@interface VPracticeCustomSearchPage0 : UIViewControllerExt

@end

@implementation VPracticeCustomSearchPage0

- (void)onLoaded {
    [super onLoaded];
    UIView* v = self.view;
    v.backgroundColor = [UIColor whiteColor];
    [v.signals connect:kSignalClicked withBlock:^(SSlot *s) {
        UIViewControllerExt* ctlr = [UIViewControllerExt temporary];
        ctlr.view.backgroundColor = [UIColor blueColor];
        [self.navigationController pushViewController:ctlr];
    }];
}

@end

@implementation VCPracticeCustomSearch

- (void)onInit {
    [super onInit];
    self.title = @"SEARCH";
    //self.classForView = [VPracticeCustomSearch class];
    //self.hidesTopBarWhenPushed = YES;
}

- (void)onFin {
    [super onFin];
}

- (void)onLoaded {
    [super onLoaded];
    
    UIUnifiedSearchBar* searchbar = self.searchBar;
    //VPracticeCustomSearch* view = (id)self.view;
    //view.searchbar.contentViewController = self;
    //view.searchbar.actived = YES;
    
    [searchbar.stackController pushViewController:[VPracticeCustomSearchPage0 temporary]];
}

@end
