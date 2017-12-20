#import "UserSsobind.h"
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

@implementation UserSsobind
//input fields
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


- (id)init {
    self = [super init];
    if (self) {
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

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
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

    [super dealloc];
#endif
}

-(void)initRequest:(ASIFormDataRequest *)request {
    [request setUserInfo:[NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:self, API_USER_SSOBIND, nil]
        forKeys:[NSArray arrayWithObjects:@"class", @"api", nil]]];

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
    return API_USER_SSOBIND;
}

-(void)setIn_platform:(NSString*)_platform {
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

	}
}
@end;

