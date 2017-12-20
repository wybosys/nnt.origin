
# import "Common.h"
# import "ModelTypes.h"
# import "HardwareUtility.h"
# import "NSTypes+Extension.h"
# import "FileSystem+Extension.h"
# import "DBConfig.h"
# import "AppContext.h"
# import "ApiSession.h"
# import <AudioToolbox/AudioToolbox.h>
# import <AdSupport/AdSupport.h>

@interface App ()

@property (nonatomic, copy) NSString *version;

@end

@implementation App

@synthesize version = _version;
@synthesize idApp = _appid, idChannel = _channelid;

- (id)init {
    self = [super init];

    NSDictionary *dictInfo = [[NSBundle mainBundle] infoDictionary];
    self.version = [dictInfo getString:(NSString*)kCFBundleVersionKey];
    _channelid = [dictInfo getInt:@"ChannelId" def:1];
    _appid = 1;
    _hasMall = NO;
    
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_version);
    ZERO_RELEASE(_hasJiFeng);
    
    [super dealloc];
}

@end

@interface UserData ()

@property (nonatomic, copy) NSString* home;
@property (nonatomic, retain) DBSqlite* db;
@property (nonatomic, retain) NSStorageExt* storage;
@property (nonatomic, retain) NSMemCache* memcache;

@end

@implementation UserData

- (id)init {
    self = [super init];
    
    self.username = [[NSStorageExt shared] getStringForKey:@"::app::login::name" def:@""];
    self.passwd = [[NSStorageExt shared] getStringForKey:@"::app::login::passwd" def:@""];
    self.platform = [[NSStorageExt shared] getIntegerForKey:@"::models::user::last::platform" def:kUserPlatformXHB];
    self.prefix = @"";
    
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_malenickname);
    ZERO_RELEASE(_femalenickname);
    ZERO_RELEASE(_username);
    ZERO_RELEASE(_passwd);
    ZERO_RELEASE(_nickname);
    ZERO_RELEASE(_avatar);
    ZERO_RELEASE(_home);
    ZERO_RELEASE(_prefix);
    ZERO_RELEASE(_db);
    ZERO_RELEASE(_storage);
    ZERO_RELEASE(_memcache);
    ZERO_RELEASE(_bindplatformlist);
    ZERO_RELEASE(_prefs);
    ZERO_RELEASE(_nativeplace);
    ZERO_RELEASE(_inviteseq);
    ZERO_RELEASE(_currentNotice);
    ZERO_RELEASE(_introduction);
    ZERO_RELEASE(_updateInfo);
    [super dealloc];
}

SIGNALS_BEGIN
SIGNALS_END

- (BOOL)isBinded:(NSString *)platform {
    return [_bindplatformlist containsObject:platform];
}

- (void)setLogined:(BOOL)logined {
    if (_logined == logined)
        return;
    _logined = logined;
    
    if (_logined == false) {
        // 断开数据库
        self.db = nil;
        
        // 断开参数数据库
        self.storage = nil;
                
        // 清空缓存
        self.memcache = nil;
        [NSMemCache SetDefaults:nil];
        
        // 如果是主动注销，则关闭自动登录
        self.allowAutologin = NO;
        return;
    }
    
    // 初始化用户目录
    self.home = [[FSApplication shared] pathWritable:[NSString stringWithFormat:@"%@%d/", self.prefix, self.accountId]];
    [[FSApplication shared] mkdir:_home];
    
    // 打开数据库
    DBConfig* cfg = [DBConfig config];
    cfg.path = [_home stringByAppendingString:@"strong.db"];
    self.db = [DBSqlite dbWithConfig:cfg];
    
    // 打开参数保存数据库
    self.storage = [NSStorageExt storageForPath:[self.home stringByAppendingString:@"storage.db"]];
    
    // 打开缓存数据库
    self.memcache = [NSMemCache memcacheWithPath:[self.home stringByAppendingString:@"memcache.db"]];
    [self.memcache makeDefaults];
    
    // 打开自动登录
    self.allowAutologin = YES;
}

- (BOOL)allowAutologin {
    return [[NSStorageExt shared] getBoolForKey:@"::models::user::autologin::allow" def:false];
}

- (void)setAllowAutologin:(BOOL)allowAutologin {
    [[NSStorageExt shared] setBool:allowAutologin forKey:@"::models::user::autologin::allow"];
}

- (void)setPlatform:(UserPlatform)platform {
    _platform = platform;
    [[NSStorageExt shared] setInteger:platform forKey:@"::models::user::last::platform"];
}

- (void)setNickname:(NSString *)nickname {
    if ([_nickname isEqualToString:nickname])
        return;
    PROPERTY_COPY(_nickname, nickname);
}

- (void)setAvatar:(NSString *)avatar {
    if ([_avatar isEqualToString:avatar])
        return;
    PROPERTY_COPY(_avatar, avatar);
}

- (void)setIntroduction:(NSString *)introduction {
    if ([_introduction isEqualToString:introduction])
        return;
    PROPERTY_COPY(_introduction, introduction);
}

@end

@interface Device ()

@property (nonatomic, copy) NSString* equipid;
@property (nonatomic, copy) NSString* sysversion;
@property (nonatomic, copy) NSString* cellbrand;
@property (nonatomic, copy) NSString* cellmodel;
@property (nonatomic, copy) NSString* macaddr;
@property (nonatomic, copy) NSString* carrier;

- (void)load;

@end

@implementation Device

- (id)init {
    self = [super init];
    
    [self load];
    
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_equipid);
    ZERO_RELEASE(_sysversion);
    ZERO_RELEASE(_cellbrand);
    ZERO_RELEASE(_cellmodel);
    ZERO_RELEASE(_macaddr);
    ZERO_RELEASE(_carrier);
    
    [super dealloc];
}

- (void)load {    
    self.equipid = [UIDevice UniqueIdentifier];
    self.sysversion = [NSString stringWithFormat:@"iOS %@", [[UIDevice currentDevice] systemVersion]];
    self.cellbrand = @"APPLE";
    self.cellmodel = [HardwareUtility PlatformString];
    self.macaddr = [HardwareUtility NetMACAddress];
    self.carrier = [HardwareUtility CarrierName];
}

@end

@implementation Perferences

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_db);
    
    [super dealloc];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalValueChanged)
SIGNALS_END

@end

@interface Beep ()
{
    AudioServicesPropertyID _newmsg;
}

@end

@implementation Beep

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    [super dealloc];
}

SIGNALS_BEGIN

SIGNAL_ADD(kSignalBeepNewMessage)
[self.signals connect:kSignalBeepNewMessage withSelector:@selector(cbNewMessage) ofTarget:self].eps = .5;

SIGNALS_END

- (void)loadBundle:(NSString *)str {
    str = [[FSApplication shared] pathBundle:str];
    str = [str stringByAppendingString:@"/New.aif"];
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:str], &_newmsg);
}

- (void)cbNewMessage {
    AudioServicesPlaySystemSound(_newmsg);
}

@end
