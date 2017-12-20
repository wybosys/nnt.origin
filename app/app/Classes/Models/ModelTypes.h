
# ifndef __MODELTYPES_7448E4A678AD47C7A6EBEF6C6AF9B059_H_INCLUDED
# define __MODELTYPES_7448E4A678AD47C7A6EBEF6C6AF9B059_H_INCLUDED

# import "CommonObj.h"
# import "Const.h"
# import "DBSqlite.h"
# import "NSStorage.h"
# import "NSMemCache.h"

@interface App : NSObject

// 一些信息
@property (nonatomic, readonly) NSString *version;
@property (nonatomic, readonly) int idApp, idChannel;

// 是否开放商城模块
@property (nonatomic, assign) BOOL hasMall;

// 是否开放积分墙模块
@property (nonatomic, copy) NSString *hasJiFeng;

@end

typedef enum {
    kUserPlatformXHB, // 小伙伴平台上的用户
    kUserPlatform3rd, // 第三方平台上的用户
} UserPlatform;

@interface UserData : NSObject

@property (nonatomic, copy) NSString *username, *prefix;
@property (nonatomic, assign) int gender; //0女  1男
@property (nonatomic, copy) NSString *passwd;
@property (nonatomic, assign) int accountId;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *malenickname,*femalenickname;
@property (nonatomic, copy) NSString *introduction;
@property (nonatomic, assign) int suggestAvatars;
@property (nonatomic, assign) BOOL logined;
@property (nonatomic, retain) NSMutableArray* bindplatformlist;
@property (nonatomic, assign) int status;
@property (nonatomic, retain) UserPref* prefs;
@property (nonatomic, copy) NSString *nativeplace;
@property (nonatomic, copy) NSString *inviteseq;
@property (nonatomic, assign) UserPlatform platform;
@property (nonatomic, assign) int level;
@property (nonatomic, retain) LoginOutputDataNotice* currentNotice;
@property (nonatomic, retain) UpdateInfo *updateInfo;

@property (nonatomic, readonly) NSString *home; // home目录
@property (nonatomic, readonly) DBSqlite *db; // 用户sql数据库
@property (nonatomic, readonly) NSStorageExt *storage; // 用户kv数据库
@property (nonatomic, readonly) NSMemCache *memcache; // 用户缓存

@property (nonatomic, assign) BOOL allowAutologin;

- (BOOL)isBinded:(NSString *) platform;

@end

@interface Device : NSObject

@property (nonatomic, readonly) NSString* equipid;
@property (nonatomic, readonly) NSString* sysversion;
@property (nonatomic, readonly) NSString* cellbrand;
@property (nonatomic, readonly) NSString* cellmodel;
@property (nonatomic, readonly) NSString* macaddr;
@property (nonatomic, readonly) NSString* carrier;

@end

@interface Perferences : NSObject

@property (nonatomic, retain) NSStorageExt* db;

@end

@interface Beep : NSObject

- (void)loadBundle:(NSString*)str;

@end

SIGNAL_DECL(kSignalBeepNewMessage) @"::ct::beep::message::new";

# endif
