
# import "app.h"
# import "VCPractice2SegmentScroll.h"

@implementation VCPractice2SegmentScroll

- (void)onInit {
    [super onInit];
    self.title = @"2 Segments Scroll";
    self.classForItem = [UILabelExt class];
}

- (void)onLoaded {
    [super onLoaded];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

- (NSInteger)tableViewExt:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (void)tableViewExt:(UITableViewExt *)tableView cell:(UITableViewCellExt *)cell item:(UILabelExt *)item atIndexPath:(NSIndexPath *)indexPath {
    item.textColor = [UIColor randomColor];
    item.text = @(indexPath.row).stringValue;
    item.textAlignment = NSTextAlignmentCenter;
}

@end
