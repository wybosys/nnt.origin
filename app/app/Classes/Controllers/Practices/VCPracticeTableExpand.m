
# import "app.h"
# import "VCPracticeTableExpand.h"

@implementation VPracticeTableExpandPanel

- (void)onInit {
    [super onInit];
    
    self.backgroundColor = [UIColor randomColor];
}

@end

@implementation VPracticeTableExpandItem

- (void)onInit {
    [super onInit];
    
    [self addSub:BLOCK_RETURN({
        _btnTop = [UIButtonExt temporary];
        _btnTop.backgroundColor = [UIColor randomColor];
        _btnTop.text = @"TOP";
        return _btnTop;
    })];
    
    [self addSub:BLOCK_RETURN({
        _btnBottom = [UIButtonExt temporary];
        _btnBottom.backgroundColor = [UIColor randomColor];
        _btnBottom.text = @"BOTTOM";
        return _btnBottom;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    UIHBox* box = [UIHBox boxWithRect:rect];
    [box addFlex:1 toView:_btnTop];
    [box addFlex:1 toView:_btnBottom];
    [box apply];
}

@end

@implementation VCPracticeTableExpand

- (void)onInit {
    [super onInit];
    self.title = @"Table Expand";
    self.classForItem = [VPracticeTableExpandItem class];
    //self.hidesBottomBarWhenPushed = YES;
}

- (void)onLoaded {
    [super onLoaded];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.dockingSectionHeader = YES;
    self.tableView.rowHeight = 60;
}

- (NSInteger)numberOfSectionsInTableViewExt:(UITableView *)tableView {
    return [[self reusableObject:@"section:count" instance:^id{
        return @([NSRandom valueBoundary:3 To:20]);
    }] integerValue];
}

- (NSInteger)tableViewExt:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (void)tableViewExt:(UITableViewExt *)tableView cell:(UITableViewCellExt *)cell item:(VPracticeTableExpandItem*)item atIndexPath:(NSIndexPath *)indexPath {
    cell.paddingEdge = CGPaddingMake(2.5, 2.5, 5, 5);
    [item.btnTop.signals connect:kSignalClicked withSelector:@selector(actToggleTop:) ofTarget:self];
    [item.btnBottom.signals connect:kSignalClicked withSelector:@selector(actToggleBottom:) ofTarget:self];
}

- (void)actToggleTop:(SSlot*)s {
    UIButtonExt* btn = (id)s.sender;
    VPracticeTableExpandItem* cv = (id)btn.superview;
    NSIndexPath* ip = [UITableViewCellExt CellFromView:cv].indexPath;
    NSString* key = [NSString stringWithFormat:@"%d:top", (int)ip.section];
    [self.attachment.strong setBool:![self.attachment.strong getBool:key] forKey:key];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:ip.section]];
}

- (void)actToggleBottom:(SSlot*)s {
    UIButtonExt* btn = (id)s.sender;
    VPracticeTableExpandItem* cv = (id)btn.superview;
    NSIndexPath* ip = [UITableViewCellExt CellFromView:cv].indexPath;
    NSString* key = [NSString stringWithFormat:@"%d:bottom", (int)ip.section];
    [self.attachment.strong setBool:![self.attachment.strong getBool:key] forKey:key];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:ip.section]];
}

- (CGFloat)tableViewExt:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString* key = [NSString stringWithFormat:@"%d:top", (int)section];
    BOOL en = [self.attachment.strong getBool:key];
    if (en)
        return 40;
    return 0;
}

- (CGFloat)tableViewExt:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    NSString* key = [NSString stringWithFormat:@"%d:bottom", (int)section];
    BOOL en = [self.attachment.strong getBool:key];
    if (en)
        return 80;
    return 0;
}

- (Class)tableView:(UITableViewExt *)tableView viewClassForSectionHeaderInSection:(NSInteger)section {
    return [VPracticeTableExpandPanel class];
}

- (Class)tableView:(UITableViewExt *)tableView viewClassForSectionFooterInSection:(NSInteger)section {
    return [VPracticeTableExpandPanel class];
}

- (void)tableViewExt:(UITableViewExt *)tableView header:(UIView *)header inSection:(NSInteger)section {

}

- (void)tableViewExt:(UITableViewExt *)tableView footer:(UIView *)footer inSection:(NSInteger)section {

}

@end
