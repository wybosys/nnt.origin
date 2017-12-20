
@interface VPracticeRTISContent : NSObject

@property (nonatomic, copy) NSString* image;
@property (nonatomic, assign) CGFloat height;

@end

@interface VPracticeRTISItem : UIImageViewExt <UIConstraintView>

@property (nonatomic, retain) VPracticeRTISContent *content;

@end

@interface VCPracticeRTISTable : UITableViewControllerExt

@end
