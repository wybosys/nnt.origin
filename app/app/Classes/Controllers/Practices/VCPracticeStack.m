
# import "app.h"
# import "VCPracticeStack.h"

@implementation VCPracticeStackPage

- (void)onInit {
    [super onInit];
}

- (void)onFin {
    [super onFin];
}

- (void)onLoaded {
    [super onLoaded];
    
    UIView* view = self.view;
    view.backgroundColor = [UIColor randomColor];

    [view addSubview:BLOCK_RETURN({
        UIButtonExt* btn = [UIButtonExt temporary];
        btn.frame = CGRectMake(50, 50, 100, 50);
        btn.text = @"Previous";
        [btn.signals connect:kSignalClicked withSelector:@selector(actPrev) ofTarget:self];
        return btn;
    })];
    
    [view addSubview:BLOCK_RETURN({
        UIButtonExt* btn = [UIButtonExt temporary];
        btn.frame = CGRectMake(50, 120, 100, 50);
        btn.text = @"Next";
        [btn.signals connect:kSignalClicked withSelector:@selector(actNext) ofTarget:self];
        return btn;
    })];
}

- (void)actPrev {
    [(VCPracticeStack*)self.superViewController popViewController];
}

- (void)actNext {
    [(VCPracticeStack*)self.superViewController pushViewController:[VCPracticeStackPage temporary]];
}

@end

@implementation VCPracticeStack

- (void)onInit {
    [super onInit];
    
    VCPracticeStackPage* ctlr = [VCPracticeStackPage temporary];
    [self pushViewController:ctlr];
}

@end
