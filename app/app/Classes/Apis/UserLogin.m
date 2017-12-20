#import "UserLogin.h"
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

@implementation UserLogin
//input fields
@synthesize in_appid;
@synthesize in_channelid;
@synthesize in_equipmentid;
@synthesize in_applicationversion;
@synthesize in_systemversion;
@synthesize in_cellbrand;
@synthesize in_cellmodel;
@synthesize in_mac;
@synthesize in_name;
@synthesize in_password;


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
        in_name = @"";
        in_password = @"";

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
    SAFE_RELEASE(in_name);
    SAFE_RELEASE(in_password);

    [__inputSet__ release];
    if (__inputFiles__ != nil)
        [__inputFiles__ release];
    SAFE_RELEASE(message);
    SAFE_RELEASE(data);

    [super dealloc];
#endif
}

-(void)initRequest:(ASIFormDataRequest *)request {
    [request setUserInfo:[NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:self, API_USER_LOGIN, nil]
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
    if ([__inputSet__ containsObject:@"name"])
    	[request setPostValue:in_name forKey:@"name"];
    if ([__inputSet__ containsObject:@"password"])
    	[request setPostValue:in_password forKey:@"password"];
    
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
    return API_USER_LOGIN;
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
}-(void)setIn_name:(NSString*)_name {
    if (in_name)
        SAFE_RELEASE(in_name);
    in_name = SAFE_RETAIN(_name);
    [__inputSet__ addObject:@"name"];
}-(void)setIn_password:(NSString*)_password {
    if (in_password)
        SAFE_RELEASE(in_password);
    in_password = SAFE_RETAIN(_password);
    [__inputSet__ addObject:@"password"];
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

