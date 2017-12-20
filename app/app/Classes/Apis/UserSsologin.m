#import "UserSsologin.h"
#import "Const.h"

#if __has_feature(objc_arc)
# define ARC_MODE
# define SAFE_RELEASE(obj) {}
# define SAFE_RETAIN(obj) obj
#else
# define SAFE_RELEASE(obj) [obj release]
# define SAFE_RETAIN(obj) [obj retain]
#endif

//for output

@implementation UserSsologin
//input fields
@synthesize in_appid;
@synthesize in_channelid;
@synthesize in_equipmentid;
@synthesize in_applicationversion;
@synthesize in_systemversion;
@synthesize in_cellbrand;
@synthesize in_cellmodel;
@synthesize in_mac;
@synthesize in_platform;
@synthesize in_accesstoken;
@synthesize in_accesssecret;
@synthesize in_expiretime;
@synthesize in_refreshtoken;
@synthesize in_uid;
@synthesize in_username;


//output fields
@synthesize code;
@synthesize message;
@synthesize data;


- (id)init {
    self = [super init];
    if (self) {
        in_appid = 0;
        in_channelid = 0;
        in_equipmentid = @"";
        in_applicationversion = @"";
        in_systemversion = @"";
        in_cellbrand = @"";
        in_cellmodel = @"";
        in_mac = @"";
        in_platform = @"";
        in_accesstoken = @"";
        in_accesssecret = @"";
        in_expiretime = 0;
        in_refreshtoken = @"";
        in_uid = @"";
        in_username = @"";

        __inputSet__ = [[NSMutableSet alloc] init];
        code = 0;
        message = @"";
        data = [[LoginOutputData alloc] init];

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(in_equipmentid);
    SAFE_RELEASE(in_applicationversion);
    SAFE_RELEASE(in_systemversion);
    SAFE_RELEASE(in_cellbrand);
    SAFE_RELEASE(in_cellmodel);
    SAFE_RELEASE(in_mac);
    SAFE_RELEASE(in_platform);
    SAFE_RELEASE(in_accesstoken);
    SAFE_RELEASE(in_accesssecret);
    SAFE_RELEASE(in_refreshtoken);
    SAFE_RELEASE(in_uid);
    SAFE_RELEASE(in_username);

    [__inputSet__ release];
    if (__inputFiles__ != nil)
        [__inputFiles__ release];
    SAFE_RELEASE(message);
    SAFE_RELEASE(data);

    [super dealloc];
#endif
}

-(void)initRequest:(ASIFormDataRequest *)request {
    [request setUserInfo:[NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:self, API_USER_SSOLOGIN, nil]
        forKeys:[NSArray arrayWithObjects:@"class", @"api", nil]]];

    if ([__inputSet__ containsObject:@"appid"])
    	[request setPostValue:[NSNumber numberWithInt:in_appid] forKey:@"appid"];
    if ([__inputSet__ containsObject:@"channelid"])
    	[request setPostValue:[NSNumber numberWithInt:in_channelid] forKey:@"channelid"];
    if ([__inputSet__ containsObject:@"equipmentid"])
    	[request setPostValue:in_equipmentid forKey:@"equipmentid"];
    if ([__inputSet__ containsObject:@"applicationversion"])
    	[request setPostValue:in_applicationversion forKey:@"applicationversion"];
    if ([__inputSet__ containsObject:@"systemversion"])
    	[request setPostValue:in_systemversion forKey:@"systemversion"];
    if ([__inputSet__ containsObject:@"cellbrand"])
    	[request setPostValue:in_cellbrand forKey:@"cellbrand"];
    if ([__inputSet__ containsObject:@"cellmodel"])
    	[request setPostValue:in_cellmodel forKey:@"cellmodel"];
    if ([__inputSet__ containsObject:@"mac"])
    	[request setPostValue:in_mac forKey:@"mac"];
    if ([__inputSet__ containsObject:@"platform"])
    	[request setPostValue:in_platform forKey:@"platform"];
    if ([__inputSet__ containsObject:@"accesstoken"])
    	[request setPostValue:in_accesstoken forKey:@"accesstoken"];
    if ([__inputSet__ containsObject:@"accesssecret"])
    	[request setPostValue:in_accesssecret forKey:@"accesssecret"];
    if ([__inputSet__ containsObject:@"expiretime"])
    	[request setPostValue:[NSNumber numberWithLong:in_expiretime] forKey:@"expiretime"];
    if ([__inputSet__ containsObject:@"refreshtoken"])
    	[request setPostValue:in_refreshtoken forKey:@"refreshtoken"];
    if ([__inputSet__ containsObject:@"uid"])
    	[request setPostValue:in_uid forKey:@"uid"];
    if ([__inputSet__ containsObject:@"username"])
    	[request setPostValue:in_username forKey:@"username"];
    
    if (__inputFiles__ != nil) {
        for (id key in [__inputFiles__ allKeys]) {
            [request setFile:[__inputFiles__ objectForKey:key] forKey:key];
        }
    }
}

-(void)addFile:(NSString*)path forKey:(NSString*)key {
    if (__inputFiles__ == nil)
        __inputFiles__ = [[NSMutableDictionary alloc] init];
    [__inputFiles__ setObject:path forKey:key];    
}

-(NSString*)getUrl {
    return API_USER_SSOLOGIN;
}

-(void)setIn_appid:(int)_appid {
    in_appid = _appid;
    [__inputSet__ addObject:@"appid"];
}-(void)setIn_channelid:(int)_channelid {
    in_channelid = _channelid;
    [__inputSet__ addObject:@"channelid"];
}-(void)setIn_equipmentid:(NSString*)_equipmentid {
    if (in_equipmentid)
        SAFE_RELEASE(in_equipmentid);
    in_equipmentid = SAFE_RETAIN(_equipmentid);
    [__inputSet__ addObject:@"equipmentid"];
}-(void)setIn_applicationversion:(NSString*)_applicationversion {
    if (in_applicationversion)
        SAFE_RELEASE(in_applicationversion);
    in_applicationversion = SAFE_RETAIN(_applicationversion);
    [__inputSet__ addObject:@"applicationversion"];
}-(void)setIn_systemversion:(NSString*)_systemversion {
    if (in_systemversion)
        SAFE_RELEASE(in_systemversion);
    in_systemversion = SAFE_RETAIN(_systemversion);
    [__inputSet__ addObject:@"systemversion"];
}-(void)setIn_cellbrand:(NSString*)_cellbrand {
    if (in_cellbrand)
        SAFE_RELEASE(in_cellbrand);
    in_cellbrand = SAFE_RETAIN(_cellbrand);
    [__inputSet__ addObject:@"cellbrand"];
}-(void)setIn_cellmodel:(NSString*)_cellmodel {
    if (in_cellmodel)
        SAFE_RELEASE(in_cellmodel);
    in_cellmodel = SAFE_RETAIN(_cellmodel);
    [__inputSet__ addObject:@"cellmodel"];
}-(void)setIn_mac:(NSString*)_mac {
    if (in_mac)
        SAFE_RELEASE(in_mac);
    in_mac = SAFE_RETAIN(_mac);
    [__inputSet__ addObject:@"mac"];
}-(void)setIn_platform:(NSString*)_platform {
    if (in_platform)
        SAFE_RELEASE(in_platform);
    in_platform = SAFE_RETAIN(_platform);
    [__inputSet__ addObject:@"platform"];
}-(void)setIn_accesstoken:(NSString*)_accesstoken {
    if (in_accesstoken)
        SAFE_RELEASE(in_accesstoken);
    in_accesstoken = SAFE_RETAIN(_accesstoken);
    [__inputSet__ addObject:@"accesstoken"];
}-(void)setIn_accesssecret:(NSString*)_accesssecret {
    if (in_accesssecret)
        SAFE_RELEASE(in_accesssecret);
    in_accesssecret = SAFE_RETAIN(_accesssecret);
    [__inputSet__ addObject:@"accesssecret"];
}-(void)setIn_expiretime:(long)_expiretime {
    in_expiretime = _expiretime;
    [__inputSet__ addObject:@"expiretime"];
}-(void)setIn_refreshtoken:(NSString*)_refreshtoken {
    if (in_refreshtoken)
        SAFE_RELEASE(in_refreshtoken);
    in_refreshtoken = SAFE_RETAIN(_refreshtoken);
    [__inputSet__ addObject:@"refreshtoken"];
}-(void)setIn_uid:(NSString*)_uid {
    if (in_uid)
        SAFE_RELEASE(in_uid);
    in_uid = SAFE_RETAIN(_uid);
    [__inputSet__ addObject:@"uid"];
}-(void)setIn_username:(NSString*)_username {
    if (in_username)
        SAFE_RELEASE(in_username);
    in_username = SAFE_RETAIN(_username);
    [__inputSet__ addObject:@"username"];
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.code = [dict intValue:@"code"];
	    self.message = [dict strValue:@"message"];

	    [data parse:[dict objectForKey:@"data"]];

	}
}
@end;

