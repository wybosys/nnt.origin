
# import "app.h"
# import "VCPracticeRTISTable.h"
# import "RTImageServer.h"

@implementation VPracticeRTISContent

@end

@implementation VPracticeRTISItem

- (void)onInit {
    [super onInit];
    self.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)updateData {
    [super updateData];

    UIUPDATE_BEGIN
    
    [[RTImageServer shared] setImage:[NSURL URLWithString:self.content.image] toView:self];
    //self.imageDataSource = self.content.image;
    
    UIUPDATE_END
}

- (CGSize)constraintBounds {
    return CGSizeMake(0, self.content.height);
}

@end

@interface VCPracticeRTISTable ()

@property (nonatomic, retain) NSMutableArray *contents;

@end

@implementation VCPracticeRTISTable

- (void)onInit {
    [super onInit];
    self.classForItem = [VPracticeRTISItem class];
}

- (void)onFin {
    [super onFin];
}

- (void)onLoaded {
    [super onLoaded];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    NSArray* imgs = @[
                      @"http://www.bzbuluo.cn/view/pics/20130927190444415.jpg",
                      @"http://www.bzbuluo.cn/view/pics/20130223160417669.jpg",
                      @"http://www.bzbuluo.cn/view/pics/20121221234927418.jpg"];
    self.contents = [NSMutableArray arrayWithTypes:[VPracticeRTISContent class]
                                             count:100
                                              init:^(VPracticeRTISContent* cnt, NSInteger idx) {
                                                  cnt.image = [imgs objectAtIndex:[NSRandom valueBoundary:0 To:3]];
                                                  cnt.height = [NSRandom valueBoundary:20 To:100];
                                              }];
}

- (NSInteger)tableViewExt:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _contents.count;
}

- (void)tableViewExt:(UITableViewExt *)tableView cell:(UITableViewCellExt *)cell item:(VPracticeRTISItem *)item atIndexPath:(NSIndexPath *)indexPath {
    item.content = [_contents objectAtIndex:indexPath.row def:nil];
}

@end
