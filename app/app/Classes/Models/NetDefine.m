
# import "Common.h"
# import "NetDefine.h"
# import "AppContext.h"

int SITE_MODE = SITE_MODE_PUBLIC;
int PUBLISH_MODE = PUBLISH_MODE_ON;

NSString* SERVER_URL() {
    if (SITE_MODE == SITE_MODE_PRIVATE)
        return @CONNECTION_SITE_PRIVATE;
    return @CONNECTION_SITE_PUBLIC;
}

NSString* RTE_VERSION() {
    return [AppContext shared].curApp.version;
}

NSString* DEV_PREFIX() {
    if (SITE_MODE == SITE_MODE_PRIVATE)
        return @"dev_";
    return @"";
}

NSString* COMMON_USER_AVATAR(int type, int idr, NSString* v) {
    return [SERVER_URL() stringByAppendingFormat:@"file/get/type/%d/id/%d/v/%@", type, idr, v];
}
