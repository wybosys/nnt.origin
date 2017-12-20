
# import "Common.h"
# import "UISplashManager.h"
# import "NSStorage.h"

@implementation UISplashManager

SHARED_IMPL;

- (void)registerViewController:(UIViewController*)ctlr {
    if ([ctlr conformsToProtocol:@protocol(UISplash)] == NO)
        return;
    [ctlr.signals connect:kSignalViewAppear withSelector:@selector(__splash_vc_appeared:) ofTarget:self];
}

- (id)splashObjectForKey:(NSString*)key {
    return [[NSStorageExt shared] getObjectForKey:key def:nil];
}

- (void)setSplashObject:(id)object forKey:(NSString*)key {
    [[NSStorageExt shared] setObject:object forKey:key];
}

- (void)__splash_vc_appeared:(SSlot*)s {
    UIViewController* ctlr = (UIViewController*)s.sender;
    NSString* key = NSStringFromClass(ctlr.class);
    
    id obj = [self splashObjectForKey:key];
    if (self.debugMode)
        obj = nil;
    
    if (obj && [obj boolValue])
        return;
    
    [self setSplashObject:@(YES) forKey:key];
    
    if ([ctlr respondsToSelector:@selector(splashForViewController:)])
        [ctlr performSelector:@selector(splashForViewController:) withObject:ctlr];
}

- (BOOL)debugMode {
    return NO;
}

@end
