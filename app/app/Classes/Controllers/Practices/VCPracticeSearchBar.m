
# import "app.h"
# import "VCPracticeSearchBar.h"

@interface VPracticeSearchItem : UIViewExt <UIConstraintView>

@property (nonatomic, readonly) UILabelExt *lblContent;
@property (nonatomic, copy) NSString *content;

@end

@implementation VPracticeSearchItem

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor randomColor];
    
    _lblContent = [[UILabelExt alloc] init];
    [self addSubview:_lblContent];
    SAFE_RELEASE(_lblContent);
    
    _lblContent.textColor = [UIColor randomColor];
    _lblContent.textFont = [UIFont boldSystemFontOfSize:20];
    
    self.paddingEdge = CGPaddingMake(10, 10, 20, 20);
}

- (void)onFin {
    ZERO_RELEASE(_content);
    [super onFin];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    _lblContent.frame = rect;
}

- (void)updateData {
    [super updateData];
    _lblContent.text = _content;
}

- (CGSize)constraintBounds {
    return CGSizeMake(0, 30 * [NSRandom valueBoundary:1 To:2]);
}

@end

@interface VCPracticeSearchBar ()

@property (nonatomic, readonly) NSMutableArray* datas;

@end

@implementation VCPracticeSearchBar

- (void)onInit {
    [super onInit];
    _datas = [NSMutableArray new];
}

- (void)onFin {
    ZERO_RELEASE(_datas);
    [super onFin];
}

- (void)onLoaded {
    [super onLoaded];
    
    self.searchBar.placeholder = @"测试搜索";
    self.classForItem = [VPracticeSearchItem class];
    
    [self.signals connect:kSignalSearchString withSelector:@selector(cbSearch:) ofTarget:self];
    [self.signals connect:kSignalPullFlush withSelector:@selector(flushData) ofTarget:self];
    [self.signals connect:kSignalSearchEnd withSelector:@selector(actClear) ofTarget:self];
}

- (void)reloadData:(BOOL)flush {
    [_datas removeAllObjects];
    self.tableView.workState = kNSWorkStateDone;
    [self.searchBar reloadData:flush];
}

- (void)cbSearch:(SSlot*)s {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [_datas addObject:s.data.object];
    [self.searchBar flushData];
}

- (void)actClear {
    [_datas removeAllObjects];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datas.count;
}

- (void)tableViewExt:(UITableViewExt *)tableView cell:(UITableViewCellExt *)cell item:(VPracticeSearchItem *)item atIndexPath:(NSIndexPath *)indexPath {
    item.content = [_datas objectAtIndex:indexPath.row];
}

@end
