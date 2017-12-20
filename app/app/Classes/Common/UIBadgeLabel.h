
# ifndef __UIBADGELABEL_863AB2E4BCBA415EB1CC6DB71D0C25D9_H_INCLUDED
# define __UIBADGELABEL_863AB2E4BCBA415EB1CC6DB71D0C25D9_H_INCLUDED

@interface UIBadgeLabel : UIViewExt

@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, assign) CGSize textShadowOffset;
@property (nonatomic, retain) UIColor *textShadowColor;
@property (nonatomic, retain) UIFont *textFont;
@property (nonatomic, retain) UIColor *badgeBackgroundColor;
@property (nonatomic, retain) UIColor *badgeOverlayColor;
@property (nonatomic, assign) CGPoint badgePositionAdjustment;
@property (nonatomic, assign) CGRect frameToPositionInRelationWith;

@end

# endif
