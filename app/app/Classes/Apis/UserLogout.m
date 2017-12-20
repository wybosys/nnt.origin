#import "UserLogout.h"
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

@implementation UserLogout
//input fields

//output fields
@synthesize code;
@synthesize message;


- (id)init {
    self = [super init];
    if (self) {
        __inputSet__ = [[NSMutableSet alloc] init];
        code = 0;
        message = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    [__inputSet__ release];
    if (__inputFiles__ != nil)
        [__inputFiles__ release];
    SAFE_RELEASE(message);

    [super dealloc];
#endif
}

-(void)initRequest:(ASIFormDataRequest *)request {
    [request setUserInfo:[NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:self, API_USER_LOGOUT, nil]
        forKeys:[NSArray arrayWithObjects:@"class", @"api", nil]]];

    
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
    return API_USER_LOGOUT;
}


- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.code = [dict intValue:@"code"];
	    self.message = [dict strValue:@"message"];

	}
}
@end;

