
# ifndef __UIMEDIALIBRARYPICKER_43358CDB504E4EB8BF2135D7739BCC34_H_INCLUDED
# define __UIMEDIALIBRARYPICKER_43358CDB504E4EB8BF2135D7739BCC34_H_INCLUDED

@interface UIAlbumRow : UIViewExt <UIConstraintView>

// 打开相册
- (void)openAlbum;

@end

@interface UIMediaLibraryPicker : UITableViewControllerExt

// 是否显示图片(是),短片(否)
@property (nonatomic, assign) BOOL hasImage, hasVideo;

// 跳过为空的album（是）
@property (nonatomic, assign) BOOL skipEmptyAlbum;

// 最大拾取个数
@property (nonatomic, assign) int maximumCount;

@end

@interface UIAlbumItem : UIViewExt

@end

@interface UIAlbumItemsRow : UIViewExt <UIConstraintView>

// 组成的项目
@property (nonatomic, assign) Class classForItem;

@end

@interface UIAlbumItemsList : UITableViewControllerExt

// 一行有多少个，默认为4
@property (nonatomic, assign) int numberColumns;

// 最大拾取个数
@property (nonatomic, assign) int maximumCount;

@end

# endif
