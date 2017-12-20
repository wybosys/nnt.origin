
# import "Common.h"
# import "UIMediaLibraryPicker.h"
# import <AssetsLibrary/AssetsLibrary.h>
# import "AppDelegate+Extension.h"
# import "NSStorage.h"

@interface UIAlbumRow ()

@property (nonatomic, readonly) UIImageViewExt *imgThumb, *imgThumb0, *imgThumb1;
@property (nonatomic, readonly) UILabelExt* lblName;
@property (nonatomic, retain) ALAssetsGroup* group;
@property (nonatomic, assign) int maximumCount;

@end

@implementation UIAlbumRow

- (void)onInit {
    [super onInit];
    
    CGLine* thumbdr = [CGLine lineWithColor:[UIColor whiteColor].CGColor width:1];
    
    [self addSubview:BLOCK_RETURN({
        _imgThumb1 = [UIImageViewExt temporary];
        _imgThumb1.contentMode = UIViewContentModeScaleAspectFill;
        _imgThumb1.layer.border = thumbdr;
        _imgThumb1.hidden = YES;
        return _imgThumb1;
    })];

    [self addSubview:BLOCK_RETURN({
        _imgThumb0 = [UIImageViewExt temporary];
        _imgThumb0.contentMode = UIViewContentModeScaleAspectFill;
        _imgThumb0.layer.border = thumbdr;
        _imgThumb0.hidden = YES;
        return _imgThumb0;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _imgThumb = [UIImageViewExt temporary];
        _imgThumb.contentMode = UIViewContentModeScaleAspectFill;
        _imgThumb.layer.border = thumbdr;
        return _imgThumb;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _lblName = [UILabelExt temporary];
        _lblName.textFont = [UIFont systemFontOfSize:16];
        _lblName.textColor = [UIColor blackColor];
        return _lblName;
    })];
    
    if (kIOS7Above)
        self.paddingEdge = CGPaddingMake(10, 10, 15, 30);
    else
        self.paddingEdge = CGPaddingMake(10, 10, 10, 30);
    [self.signals connect:kSignalClicked withSelector:@selector(openAlbum) ofTarget:self];
}

- (void)onFin {
    ZERO_RELEASE(_group);
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalDone)
SIGNALS_END

+ (CGSize)BestSize:(CGSize)sz {
    sz.height = 80;
    return sz;
}

- (CGSize)constraintBounds {
    return [self.class BestSize];
}

- (void)updateData {
    [super updateData];
    
    UIUPDATE_BEGIN
    
    self.imgThumb.image = [UIImage imageWithCGImage:self.group.posterImage];
    self.lblName.text = [self.group valueForProperty:ALAssetsGroupPropertyName];
    
    // 遍历以下，取得后两个
    self.imgThumb0.hidden = YES;
    self.imgThumb1.hidden = YES;
    
    NSRange rgn = NSMakeRange(0, 3);
    NSInteger cnt = self.group.numberOfAssets;
    if (NSMaxRange(rgn) >= cnt)
        rgn.length = cnt - rgn.location;
    [self.group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:rgn]
                                 options:0
                              usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                  if (index == 1) {
                                      self.imgThumb0.image = [UIImage imageWithCGImage:result.thumbnail];
                                      self.imgThumb0.visible = YES;
                                  } else if (index == 2) {
                                      self.imgThumb1.image = [UIImage imageWithCGImage:result.thumbnail];
                                      self.imgThumb1.visible = YES;
                                  }
                              }];

    UIUPDATE_END
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIHBox* box = [UIHBox boxWithRect:rect];
    [box addAspectWithX:1 andY:1 toView:_imgThumb];
    [box addPixel:20 toView:nil];
    [box addFlex:1 toView:_lblName];
    [box apply];
    
    self.imgThumb0.frame = CGRectOffset(CGRectDeflate(_imgThumb.frame, 2, 0), 0, -2);
    self.imgThumb1.frame = CGRectOffset(CGRectDeflate(_imgThumb.frame, 4, 0), 0, -4);
}

- (void)openAlbum {
    UIAlbumItemsList* ctlr = [UIAlbumItemsList temporary];
    ctlr.maximumCount = self.maximumCount;
    
    [ctlr.signals connect:kSignalDone ofTarget:self];
    [ctlr performSelector:@selector(setGroup:) withObject:self.group];
    [self.navigationController pushViewController:ctlr];
}

@end

@interface UIMediaLibraryPicker ()

@property (nonatomic, readonly) ALAssetsLibrary *library;
@property (nonatomic, readonly) NSMutableArray *groups;

@end

@implementation UIMediaLibraryPicker

- (void)onInit {
    [super onInit];
    
    self.attributes.navigationBarBlur = YES;
    self.attributes.navigationBarTranslucent = [NSBoolean Yes];
    self.attributes.navigationBarDodge = YES;
    
    if ([UINavigationBar appearance].barColor == nil)
        self.attributes.navigationBarColor = [UIColor whiteWithAlpha:.8];
    
    self.title = @"媒体库";
    self.hasImage = YES;
    self.hasVideo = NO;
    self.skipEmptyAlbum = YES;
    self.maximumCount = -1;
    self.classForItem = [UIAlbumRow class];
    
    _library = [[ALAssetsLibrary alloc] init];
    _groups = [[NSMutableArray alloc] init];
}

- (void)onFin {
    ZERO_RELEASE(_library);
    ZERO_RELEASE(_groups);
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalCancel)
SIGNAL_ADD(kSignalDone)
SIGNALS_END

- (void)onLoaded {
    [super onLoaded];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = BLOCK_RETURN({
        UIBarButtonItem* btn = [UIBarButtonItem itemWithTitle:@"取消"];
        [btn.signals connect:kSignalClicked withSelector:@selector(goBack) ofTarget:self];
        [btn.signals connect:kSignalClicked redirectTo:kSignalCancel ofTarget:self];
        return btn;
    });
    
    [self reloadData];
    
    // 如果相片存在变化，则刷新一下
    [[UIAppDelegate shared].signals connect:kSignalNotificationAssetsChanged withSelector:@selector(reloadData) ofTarget:self];
}

- (void)reloadData {
    [_groups removeAllObjects];
    
    DISPATCH_ASYNC_ONMAIN({
        // 获取到filter
        ALAssetsFilter* filter = nil;
        if (self.hasImage && self.hasVideo)
            filter = [ALAssetsFilter allAssets];
        else if (self.hasImage)
            filter = [ALAssetsFilter allPhotos];
        else if (self.hasVideo)
            filter = [ALAssetsFilter allVideos];
        else {
            WARN("错误设置了选择媒体的类型，必须Photo和Video选择一种");
            filter = [ALAssetsFilter allPhotos];
        }
        
        // 读取所有的相册
        [self.library enumerateGroupsWithTypes:ALAssetsGroupAll
                                    usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                        if (group) {
                                            [group setAssetsFilter:filter];
                                            // 如果没有照片，则跳过
                                            if (self.skipEmptyAlbum) {
                                                if (group.numberOfAssets)
                                                    [_groups addObject:group];
                                            } else {
                                                [_groups addObject:group];
                                            }
                                        } else {
                                            [self.tableView reloadData];
                                        }
                                    }
                                  failureBlock:^(NSError *error) {
                                      [error log];
                                  }];
    });
}

- (NSInteger)tableViewExt:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groups.count;
}

- (void)tableViewExt:(UITableViewExt *)tableView cell:(UITableViewCellExt *)cell item:(UIAlbumRow *)item atIndexPath:(NSIndexPath *)indexPath {
    item.group = [self.groups objectAtIndex:indexPath.row def:nil];
    item.maximumCount = self.maximumCount;
    [item.signals connect:kSignalDone withSelector:@selector(cbSelectionDone:) ofTarget:self];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)cbSelectionDone:(SSlot*)s {
    [self.signals emit:kSignalDone withResult:s.data.object];
}

@end

@interface UIAlbumItem ()

@property (nonatomic, readonly) UIImageViewExt *imgThumb, *imgSelection;

@property (nonatomic, retain) UIImage *thumb;
@property (nonatomic, retain) ALAssetRepresentation* data;
@property (nonatomic, assign) BOOL selected;

@end

@implementation UIAlbumItem

- (void)onInit {
    [super onInit];
    
    [self addSubview:BLOCK_RETURN({
        _imgThumb = [UIImageViewExt temporary];
        _imgThumb.contentMode = UIViewContentModeScaleAspectFill;
        return _imgThumb;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _imgSelection = [UIImageViewExt temporary];
        _imgSelection.states = @{[NSBoolean Yes]: @"common.bundle/SelectionOverlay"};
        [_imgSelection.signals connect:kSignalClicked withSelector:@selector(actClicked) ofTarget:self];
        return _imgSelection;
    })];
    
    self.paddingEdge = CGPaddingMake(4, 0, 0, 4);
}

- (void)onFin {
    ZERO_RELEASE(_data);
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalSelectionChanging)
SIGNAL_ADD(kSignalSelectionChanged)
SIGNALS_END

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    _imgThumb.frame = rect;
    _imgSelection.frame = rect;
}

- (void)updateData {
    [super updateData];
    _imgThumb.image = self.thumb;
    _imgSelection.currentState = [NSBoolean boolean:self.selected];
}

- (void)actClicked {
    SSlotTunnel* tun = [SSlotTunnel temporary];
    [self.signals emit:kSignalSelectionChanging withTunnel:tun];
    if (tun.vetoed)
        return;
    
    self.selected = !self.selected;
    if (self.selected) {
        _imgSelection.currentState = [NSBoolean boolean:self.selected];
    } else {
        _imgSelection.currentState = nil;
    }
    
    [self.signals emit:kSignalSelectionChanged];
}

@end

@interface UIAlbumItemsRow ()
{
    NSMutableArray* _vItems;
}

@property (nonatomic, assign) int numberItems;
@property (nonatomic, retain) ALAssetsGroup* group;
@property (nonatomic, assign) NSRange range;
@property (nonatomic, retain) NSDictionary *selections;

@end

@implementation UIAlbumItemsRow

- (void)onInit {
    [super onInit];
    self.classForItem = [UIAlbumItem class];
    self.paddingEdge = CGPaddingMake(0, 0, 4, 0);
    
    _vItems = [[NSMutableArray alloc] init];
}

- (void)onFin {
    ZERO_RELEASE(_vItems);
    ZERO_RELEASE(_group);
    ZERO_RELEASE(_selections);
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalSelectionChanging)
SIGNAL_ADD(kSignalSelectionChanged)
SIGNALS_END

+ (CGSize)BestSize:(CGSize)sz {
    sz.height = TRIEXPRESS(kDeviceRunningOniPAD, 140, 80);
    return sz;
}

- (CGSize)constraintBounds {
    return [self.class BestSize];
}

- (void)setNumberItems:(int)numberItems {
    if (_numberItems == numberItems)
        return;
    _numberItems = numberItems;
    
    [_vItems growByType:self.classForItem toSize:numberItems init:^(UIAlbumItem* obj, NSInteger idx) {
        obj.tag = idx;
        [obj.signals connect:kSignalSelectionChanging withSelector:@selector(actSelectedChanging:) ofTarget:self];
        [obj.signals connect:kSignalSelectionChanged withSelector:@selector(actSelectedChanged:) ofTarget:self];
        [self addSubview:obj];
    }];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIHBox* box = [UIHBox boxWithRect:rect];
    [_vItems foreach:^BOOL(id obj) {
        [box addFlex:1 toView:obj];
        return YES;
    }];
    [box apply];
}

- (void)updateData {
    [super updateData];
    
    UIUPDATE_BEGIN
    
    NSMutableArray* items = [NSMutableArray temporary];
    [self.group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:self.range]
                                 options:0
                              usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                  if (result) {
                                      [items addObject:result];
                                  } else {
                                      *stop = YES;
                                  }
                              }];
    
    [_vItems foreachWithArray:items step:^IteratorType(UIAlbumItem* my, ALAsset* other, NSInteger idx) {
        my.data = other.defaultRepresentation;
        my.thumb = [UIImage imageWithCGImage:other.thumbnail];
        my.hidden = other == nil;
        
        NSTriple* td = self.selections[my.data.url];
        my.selected = [td.secondObject boolValue];
        
        [my updateData];
        return YES;
    } def:nil];
    
    UIUPDATE_END
}

- (void)actSelectedChanging:(SSlot*)s {
    UIAlbumItem* ai = (id)s.sender;
    ALAssetRepresentation* repr = ai.data;
    id key = repr.url;
    NSTriple* da = [NSTriple pairFirst:key
                                Second:[NSBoolean boolean:!ai.selected]
                                 Thrid:nil];
    [self.signals emit:kSignalSelectionChanging withResult:da withTunnel:s.tunnel];
}

- (void)actSelectedChanged:(SSlot*)s {
    UIAlbumItem* ai = (id)s.sender;
    ALAssetRepresentation* repr = ai.data;
    id key = repr.url;
    CGImageRef img = repr.fullScreenImage;
    NSTriple* da = [NSTriple pairFirst:key
                                Second:[NSBoolean boolean:ai.selected]
                                 Thrid:[UIImage imageWithCGImage:img]];
    [self.signals emit:kSignalSelectionChanged withResult:da];
}

@end

@interface UIAlbumItemsList ()
{
    NSInteger _lastCount;
}

@property (nonatomic, retain) ALAssetsGroup* group;
@property (nonatomic, readonly) NSMutableDictionary* selections;

@end

@implementation UIAlbumItemsList

- (void)onInit {
    [super onInit];
    
    self.attributes.navigationBarBlur = YES;
    self.attributes.navigationBarTranslucent = [NSBoolean Yes];
    self.attributes.navigationBarDodge = YES;
    
    if ([UINavigationBar appearance].barColor == nil)
        self.attributes.navigationBarColor = [UIColor whiteWithAlpha:.8];
    
    self.numberColumns = TRIEXPRESS(kDeviceRunningOniPAD, 5, 4);
    self.classForItem = [UIAlbumItemsRow class];
    _selections = [[NSMutableDictionary alloc] init];
}

- (void)onFin {
    ZERO_RELEASE(_group);
    ZERO_RELEASE(_selections);
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalDone)
SIGNALS_END

- (void)onLoaded {
    [super onLoaded];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = BLOCK_RETURN({
        UIViewExt* v = [UIViewExt temporary];
        v.height = 10;
        return v;
    });
    
    self.title = [self.group valueForProperty:ALAssetsGroupPropertyName];
    
    self.navigationItem.rightBarButtonItem = BLOCK_RETURN({
        UIBarButtonItem* btn = [UIBarButtonItem itemWithTitle:@"确定"];
        [btn.signals connect:kSignalClicked withSelector:@selector(dismissModalViewController) ofTarget:self.superViewController];
        [btn.signals connect:kSignalClicked withSelector:@selector(actDone) ofTarget:self];
        return btn;
    });
    
    [self reloadData];
    
    // 如果相片存在变化，则刷新一下
    [[UIAppDelegate shared].signals connect:kSignalNotificationAssetsChanged withSelector:@selector(reloadData) ofTarget:self];
}

- (void)onDisappeared {
    [super onDisappeared];
    
    // 记录现在滚动到的位置
    NSString* key = [[self.group valueForProperty:ALAssetsGroupPropertyURL] absoluteString];
    UITableViewCell* cell = [self.tableView.visibleCells lastObject];
    [[NSStorageExt shared] setObject:cell.indexPath forKey:key];
}

- (void)reloadData {
    _lastCount = self.group.numberOfAssets;
    [self.tableView reloadData];
}

- (void)onViewLayout {
    [super onViewLayout];
    
    // 滚动到最后
    int rows = [NSMath CeilFloat:_lastCount r:self.numberColumns];
    if (rows) {
        // 取出上一次的位置
        NSString* key = [[self.group valueForProperty:ALAssetsGroupPropertyURL] absoluteString];
        NSIndexPath* ip = [[NSStorageExt shared] getObjectForKey:key def:nil];
        NSInteger row = TRIEXPRESS(ip, ip.row, rows - 1);
        NSInteger cntrows = [self.tableView numberOfRowsInSection:0];
        row = MIN(row, cntrows);
        if (row == 0)
            return;
        OBJC_NOEXCEPTION(
                         [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]
                                               atScrollPosition:UITableViewScrollPositionBottom
                                                       animated:NO];
                         );
    }
}

- (NSInteger)tableViewExt:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [NSMath CeilFloat:_lastCount r:self.numberColumns];
}

- (void)tableViewExt:(UITableViewExt *)tableView cell:(UITableViewCellExt *)cell item:(UIAlbumItemsRow *)item atIndexPath:(NSIndexPath *)indexPath {
    item.numberItems = self.numberColumns;
    item.group = self.group;
    item.selections = self.selections;
    
    NSRange rgn = {indexPath.row * self.numberColumns, self.numberColumns};
    if (NSMaxRange(rgn) >= _lastCount)
        rgn.length = _lastCount - rgn.location;
    item.range = rgn;
    
    [item.signals connect:kSignalSelectionChanging withSelector:@selector(actSelectionChanging:) ofTarget:self];
    [item.signals connect:kSignalSelectionChanged withSelector:@selector(actSelectionChanged:) ofTarget:self];
}

- (void)actSelectionChanging:(SSlot*)s {
    NSTriple* d = s.data.object;
    if ([d.secondObject boolValue])
    {
        // 如果设置了最大拾取的数目，则需要当多选的时候提示用户不能点选
        if (self.maximumCount && _selections.count == _maximumCount)
        {
            [UIHud Text:[NSString stringWithFormat:@"只能选取 %d 张照片", self.maximumCount]];
            [s.tunnel veto];
        }
    }
}

- (void)actSelectionChanged:(SSlot*)s {
    NSTriple* d = s.data.object;
    if ([d.secondObject boolValue])
        _selections[d.firstObject] = d;
    else
        [_selections removeObjectForKey:d.firstObject];
    
    LOG("拾取了%d张图片", _selections.count);
}

- (void)actDone {
    NSArray* arr = [NSArray arrayFromDictionary:_selections byConverter:^id(id key, NSTriple* val) {
        return [NSPair pairFirst:val.thirdObject Second:val.firstObject];
    }];
    [self.signals emit:kSignalDone withResult:arr];
}

@end
