#import "ForwardTransferlog.h"
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

@implementation ForwardTransferlog
//input fields
@synthesize in_platformlist;
@synthesize in_resid;


//output fields
@synthesize code;
@synthesize message;


- (id)init {
    self = [super init];
    if (self) {
        in_platformlist = @"";
        in_resid = @"";

        __inputSet__ = [[NSMutableSet alloc] init];
        code = 0;
        message = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(in_platformlist);
    SAFE_RELEASE(in_resid);

    [__inputSet__ release];
    if (__inputFiles__ != nil)
        [__inputFiles__ release];
    SAFE_RELEASE(message);

    [super dealloc];
#endif
}

-(void)initRequest:(ASIFormDataRequest *)request {
    [request setUserInfo:[NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:self, API_FORWARD_TRANSFERLOG, nil]
        forKeys:[NSArray arrayWithObjects:@"class", @"api", nil]]];

    if ([__inputSet__ containsObject:@"platformlist"])
    	[request setPostValue:in_platformlist forKey:@"platformlist"];
    if ([__inputSet__ containsObject:@"resid"])
    	[request setPostValue:in_resid forKey:@"resid"];
    
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
    return API_FORWARD_TRANSFERLOG;
}

-(void)setIn_platformlist:(NSString*)_platformlist {
    if (in_platformlist)
        SAFE_RELEASE(in_platformlist);
    in_platformlist = SAFE_RETAIN(_platformlist);
    [__inputSet__ addObject:@"platformlist"];
}-(void)setIn_resid:(NSString*)_resid {
    if (in_resid)
        SAFE_RELEASE(in_resid);
    in_resid = SAFE_RETAIN(_resid);
    [__inputSet__ addObject:@"resid"];
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.code = [dict intValue:@"code"];
	    self.message = [dict strValue:@"message"];

	}
}
@end;

