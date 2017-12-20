
# ifndef __APISESSION_UI_4DA658C9EEEE42BE98994C052FCFC4FF_H_INCLUDED
# define __APISESSION_UI_4DA658C9EEEE42BE98994C052FCFC4FF_H_INCLUDED

# import "ApiSession.h"

@interface UIScrollView (netobj_working)

+ (void)SetIdentifierWorkingInstanceCallback:(void(^)(UIScrollView*))block;

@end

@interface SNetObj (ui)

@property (nonatomic, assign) UIScrollView *scrollView;

@end

@interface SNetObjs (ui)

@property (nonatomic, assign) UIScrollView *scrollView;

@end

# endif
