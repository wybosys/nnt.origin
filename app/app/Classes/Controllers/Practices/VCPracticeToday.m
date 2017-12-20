
# import "app.h"
# import "VCPracticeToday.h"

@implementation VCPracticeToday

- (void)onLoaded {
    [super onLoaded];
    
    [[UIAppDelegate shared].signals connect:kSignalAppOpenUrl withBlock:^(SSlot *s) {
        NSDictionary* d = s.data.object;
        NSURL* url = d[@"url"];
        if ([url.relativeString isEqualToString:@"strong.hdapp://today.hdapp"]) {
            [UIHud Success:@"从 Today 回调成功"];
        }
    }];
}

- (void)onAppeared {
    [super onAppeared];
    self.view.backgroundColor = [UIColor randomColor];
}

@end
