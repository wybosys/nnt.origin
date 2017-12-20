
# import "app.h"
# import "VCPracticeCollection.h"
# import "VPracticeTableItem.h"

@implementation VCPracticeCollection

- (void)onInit {
    [super onInit];
    self.title = @"COLLECTION";
    self.classForItem = [VPracticeTableItem class];
}

- (void)onLoaded {
    [super onLoaded];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (NSInteger)collectionViewExt:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 100;
}

- (void)collectionViewExt:(UICollectionView *)collectionView item:(VPracticeTableItem *)item atIndexPath:(NSIndexPath *)indexPath {
    item.text = [NSString stringWithFormat:@"ROW INDEX %d", (int)indexPath.row];
}

@end
