
# import "app.h"
# import "VCPracticeTable.h"
# import "VPracticeTableItem.h"
# import "VPracticePullIdentifier.h"
# import "VPracticeKeyboardPanel.h"
# import "VCPracticeSearchBar.h"
# import "VCPracticeTableSplit.h"

@interface VCPracticeTable ()

@property (nonatomic, readonly) NSMutableArray *datas;
@property (nonatomic, retain) NSArray *sortdatas;
@property (nonatomic, readonly) VPracticeKeyboardPanel *pnlInput;

@end

@implementation VCPracticeTable

- (void)onInit {
    [super onInit];
    
    self.title = @"Table";
    
    self.attributes.navigationBarTranslucent = [NSBoolean Yes];
    self.attributes.navigationBarBlur = YES;
    self.attributes.navigationBarDodge = YES;
    
    _datas = [[NSMutableArray alloc] init];
}

- (void)onFin {
    ZERO_RELEASE(_datas);
    ZERO_RELEASE(_sortdatas);
    ZERO_RELEASE(_pnlInput);
    [super onFin];
}

- (void)onLoaded {
    [super onLoaded];
    
    self.classForItem = [VPracticeTableItem class];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.identifierTop = [VPracticePullFlush temporary];
    self.tableView.identifierBottom = [VPracticePullMore temporary];
    //self.tableView.edgeInsetsAddition = UIEdgeInsetsMake(0, 0, 200, 0);
    self.tableView.sectionTitleStyle = [UITextStyle styleWithColor:[UIColor redColor] backgroundColor:nil];
    
    _pnlInput = [[VPracticeKeyboardPanel alloc] init];
    [_pnlInput.signals connect:kSignalBoundsChanged withSelector:@selector(actFooterExpand) ofTarget:self];
    self.tableView.tableFloatingFooterView = _pnlInput;
    
    [self.tableView.signals connect:kSignalPullFlush withSelector:@selector(flushData) ofTarget:self];
    [self.tableView.signals connect:kSignalPullMore withSelector:@selector(reloadData) ofTarget:self];
    
    VCPracticeSearchBar* search = [VCPracticeSearchBar temporary];
    search.contentsViewController = self;
    [self assignSubcontroller:search];
    self.tableView.tableHeaderView = search.view;
    
    // show custom table with custom search.
    self.navigationItem.rightBarButtonItem = BLOCK_RETURN({
        UIBarButtonItem* btn = [UIBarButtonItem itemWithTitle:@"SPLIT"];
        [btn.signals connect:kSignalClicked withBlock:^(SSlot *s) {
            [self.navigationController pushViewController:[VCPracticeTableSplit temporary]];
        }];
        return btn;
    });
    
    [self.tableView.panGestureRecognizer.signals connect:kSignalDirectionChanged withBlock:^(SSlot *s) {
        CGDirection dir = (CGDirection)[s.data.object intValue];
        BOOL hidden = [NSMask Mask:kCGDirectionToBottom Value:dir];
        [self.navigationController setNavigationBarHidden:hidden animated:YES];
    }];
}

- (void)onFirstAppeared {
    [super onFirstAppeared];
    [self flushData];
    
    DISPATCH_DELAY_BEGIN(1)
    [[UIAppDelegate shared].statusBar show:@"TEST TABLE 1" duration:1];
    [[UIAppDelegate shared].statusBar show:@"TEST TABLE 2" duration:1];
    UILabelExt* lbl = [UILabelExt temporary];
    lbl.text = @"TEST GLOBAL TABLE";
    lbl.textFont = [UIFont systemFontOfSize:kUIStatusBarFontSize];
    lbl.textColor = [UIColor redColor];
    lbl.textAlignment = NSTextAlignmentCenter;
    [[UIAppDelegate shared].statusBar display:lbl duration:2];
    DISPATCH_DELAY_END
}

- (void)reloadData:(BOOL)flush {
    if (flush)
        [_datas removeAllObjects];
    
    [_datas addObjectsFromArray:[NSArray arrayWithInstance:^id(NSInteger idx) {
        return [NSString RandomString:[NSRandom valueBoundary:10 To:100]];
    } count:[NSRandom valueBoundary:5 To:10]]];
    
    self.tableView.identifierBottom.disabled = _datas.count > 50;
    
    // 将 _datas 分类
    self.sortdatas = [[NSArray arrayFromDictionary:[NSDictionary dictionaryFromArray:_datas keyConverter:^id(NSString* obj) {
        return [obj stringAtIndex:0];
    } valueConverter:^id(NSString* val) {
        return val;
    } multi:YES]
                                       byConverter:^id(NSString* key, NSArray* val) {
                                           return [NSPair pairFirst:key Second:val];
                                       }]
                      sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                          return [[obj1 firstObject] compare:[obj2 firstObject]];
                      }];
    
    DISPATCH_DELAY_BEGIN(1)
    self.tableView.workState = kNSWorkStateDone;
    [self.tableView reloadData:flush];
    DISPATCH_DELAY_END
}

- (void)actFooterExpand {
    self.tableView.tableFloatingFooterView = _pnlInput;
}

- (NSInteger)numberOfSectionsInTableViewExt:(UITableView *)tableView {
    return self.sortdatas.count;
}

- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.sortdatas arrayWithCollector:^id(id l) {
        return [l firstObject];
    }];
}

- (NSInteger)tableViewExt:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray* arr = [[self.sortdatas objectAtIndex:section def:nil] secondObject];
    return arr.count;
}

- (void)tableViewExt:(UITableViewExt *)tableView cell:(UITableViewCellExt *)cell item:(UIView *)item atIndexPath:(NSIndexPath *)indexPath {
    VPracticeTableItem* ti = (id)item;
    ti.text = [[[self.sortdatas objectAtIndex:indexPath.section def:nil] secondObject] objectAtIndex:indexPath.row def:@""];
    ti.index = @(indexPath.row).stringValue;
}

@end

@interface VCPracticeSimpleTable ()

@property (nonatomic, retain) NSArray *datas;

@end

@implementation VCPracticeSimpleTable

- (void)onInit {
    [super onInit];
    self.classForItem = [VPracticeTableItem class];
}

- (void)onLoaded {
    [super onLoaded];
    [self flushData];
}

- (void)reloadData:(BOOL)flush {
    self.datas = [NSArray arrayWithInstance:^id(NSInteger idx) {
        return [NSString RandomString:20];
    } count:[NSRandom valueBoundary:5 To:20]];
    [self.tableView reloadData:flush];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (void)tableViewExt:(UITableViewExt *)tableView cell:(UITableViewCellExt *)cell item:(VPracticeTableItem *)item atIndexPath:(NSIndexPath *)indexPath {
    item.text = [self.datas objectAtIndex:indexPath.row def:@""];
}

@end
