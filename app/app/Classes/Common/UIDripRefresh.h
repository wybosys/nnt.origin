
# ifndef __UIDRIPVIEW_AD368CFA809442EF91067FCDC7345C6A_H_INCLUDED
# define __UIDRIPVIEW_AD368CFA809442EF91067FCDC7345C6A_H_INCLUDED

@interface UIDripRefresh : UIViewExt
{
    UILabel      *_refreshHintLabel;
    CAShapeLayer *_shapeLayer;
    CAShapeLayer *_arrowLayer;
    CAShapeLayer *_highlightLayer;
    UIView *_activity;
    BOOL _refreshing;
    BOOL _canRefresh;
    BOOL _didSetInset;
    BOOL _hasSectionHeaders;
    CGFloat _lastOffset;
}

@property (nonatomic, assign) CGFloat maxDistance;
@property (nonatomic, readonly) BOOL refreshing;
@property (nonatomic, retain) UIColor *tintColor;
@property (nonatomic, assign) UIActivityIndicatorViewStyle activityIndicatorViewStyle;
@property (nonatomic, retain) UIColor *activityIndicatorViewColor; // iOS5 or more

@property (nonatomic, assign) CGFloat offset;

// Tells the control that a refresh operation was started programmatically
- (void)beginRefreshing;

// Tells the control the refresh operation has ended
- (void)endRefreshing;

@end

# endif
