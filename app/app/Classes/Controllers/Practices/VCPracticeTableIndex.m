
#import "app.h"
#import "VCPracticeTableIndex.h"

@implementation SimpleTextItem

- (void)onInit {
    [super onInit];
    self.textFont = [UIFont systemFontOfSize:20];
    self.textColor = [UIColor blackColor];
    self.contentPadding = CGPaddingMake(5, 5, 10, 10);
    self.multilines = YES;
}

- (CGSize)constraintBounds {
    CGFloat h = 0;
    h += self.bestHeightForWidth;
    return CGSizeMake(0, h);
}

@end

@implementation SimpleSectionLabel

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor blackColor];
    self.textColor = [UIColor whiteColor];
    self.textFont = [UIFont boldSystemFontOfSize:16];
}

+ (CGSize)BestSize:(CGSize)sz {
    return CGSizeMake(0, 30);
}

@end

@interface VCPracticeTableIndex ()

@property (nonatomic, readonly) NSMutableDictionary* datas;

@end

@implementation VCPracticeTableIndex

- (void)onInit {
    [super onInit];
    
    self.title = @"Table Index";
    
    self.attributes.navigationBarTranslucent = [NSBoolean Yes];
    self.attributes.navigationBarBlur = YES;
    self.attributes.navigationBarDodge = YES;
    
    _datas = [[NSMutableDictionary alloc] init];
    self.classForItem = [SimpleTextItem class];
}

- (void)onFin {
    ZERO_RELEASE(_datas);
    [super onFin];
}

- (void)onLoaded {
    [super onLoaded];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.sectionIndexTitlesView = [UIIndexTitlesView temporary];
    
    for (int i = 0; i < 20; ++i) {
        NSMutableArray* arr = [_datas objectForKey:@(i).stringValue instanceType:[NSMutableArray class]];
        int count = [NSRandom valueBoundary:5 To:20];
        for (int j = 0; j < count; ++j) {
            [arr addObject:[NSString RandomString]];
        }
    }
}

- (NSArray*)titlesForIndexTitlesView:(UIIndexTitlesView *)tv {
//- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[NSArray arrayWithRange:NSMakeRange(0, self.tableView.numberOfSections)]
            arrayWithCollector:^id(id l) {
                return [l stringValue];
            }];
}

- (Class)tableView:(UITableViewExt *)tableView viewClassForSectionHeaderInSection:(NSInteger)section {
    return [SimpleSectionLabel class];
}

- (CGFloat)tableViewExt:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [SimpleSectionLabel BestHeight];
}

- (void)tableViewExt:(UITableViewExt *)tableView header:(SimpleSectionLabel *)header inSection:(NSInteger)section {
    header.text = @(section).stringValue;
}

- (NSInteger)numberOfSectionsInTableViewExt:(UITableView *)tableView {
    return _datas.count;
}

- (NSInteger)tableViewExt:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray* arr = [_datas objectForKey:@(section).stringValue def:nil];
    return arr.count;
}

- (void)tableViewExt:(UITableViewExt *)tableView cell:(UITableViewCellExt *)cell item:(SimpleTextItem *)item atIndexPath:(NSIndexPath *)indexPath {
    NSArray* arr = [_datas objectForKey:@(indexPath.section).stringValue def:nil];
    item.text = [arr objectAtIndex:indexPath.row def:@""];
}

@end
