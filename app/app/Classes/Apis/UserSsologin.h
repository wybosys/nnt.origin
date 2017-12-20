#import "CommonObj.h"
#import "NetObj.h"

//for output

//登录输出
@interface UserSsologin : NSObject<NetObj>
{
    NSMutableSet* __inputSet__;
    NSMutableDictionary* __inputFiles__;
}
//input fields
//应用ID 
@property(nonatomic, assign) int in_appid;
//渠道ID 
@property(nonatomic, assign) int in_channelid;
//设备ID 
@property(nonatomic, retain) NSString* in_equipmentid;
//应用版本 
@property(nonatomic, retain) NSString* in_applicationversion;
//系统版本 
@property(nonatomic, retain) NSString* in_systemversion;
// 
@property(nonatomic, retain) NSString* in_cellbrand;
// 
@property(nonatomic, retain) NSString* in_cellmodel;
//mac地址 
@property(nonatomic, retain) NSString* in_mac;
//WEIBO QQ 
@property(nonatomic, retain) NSString* in_platform;
// 
@property(nonatomic, retain) NSString* in_accesstoken;
// 
@property(nonatomic, retain) NSString* in_accesssecret;
// 
@property(nonatomic, assign) long in_expiretime;
// 
@property(nonatomic, retain) NSString* in_refreshtoken;
// 
@property(nonatomic, retain) NSString* in_uid;
// 
@property(nonatomic, retain) NSString* in_username;


//output fields
// 
@property(nonatomic, assign) int code;
// 
@property(nonatomic, retain) NSString* message;
// 
@property(nonatomic, readonly) LoginOutputData* data;


- (void)parse:(NSObject*)obj;
- (void)addFile:(NSString*)path forKey:(NSString*)key;

@end;

