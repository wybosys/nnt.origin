
# ifndef __MAPENHANCE_2DA01345D08540A7B0E2D43DF8953C91_H_INCLUDED
# define __MAPENHANCE_2DA01345D08540A7B0E2D43DF8953C91_H_INCLUDED

@interface iBeaconService : NSObjectExt

@property (nonatomic, copy) NSString *proximityid, *identifier;

+ (BOOL)isAvaliable;

// 开始提供服务
- (void)listen;
@property (nonatomic, readonly) BOOL listening;

// 使用服务
- (void)look;
@property (nonatomic, readonly) BOOL looking;

@end

# endif
