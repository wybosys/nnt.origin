
# ifndef __UISPLASHMANAGER_1BC685E2B94A44E582F33760228B7925_H_INCLUDED
# define __UISPLASHMANAGER_1BC685E2B94A44E582F33760228B7925_H_INCLUDED

@protocol UISplashManager <NSObject>

// 取得目标key对应的splash数据
- (id)splashObjectForKey:(NSString*)key;

// 设置
- (void)setSplashObject:(id)object forKey:(NSString*)key;

@end

@protocol UISplash <NSObject>

@optional
- (void)splashForViewController:(UIViewController*)ctlr;

@end

@interface UISplashManager : NSObjectExt
<UISplashManager>

// 是否为测试模式
@property (nonatomic, readonly) BOOL debugMode;

+ (UISplashManager*)shared;

// 注册vc使用splash
- (void)registerViewController:(UIViewController*)ctlr;

@end

# endif
