#import "ForwardSend.h"
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

@implementation ForwardSend
//input fields
@synthesize in_platformlist;
@synthesize in_resid;
@synthesize in_picture;
@synthesize in_voice;
@synthesize in_title;
@synthesize in_message;
@synthesize in_comment;


//output fields
@synthesize code;
@synthesize message;


- (id)init {
    self = [super init];
    if (self) {
        in_platformlist = @"";
        in_resid = @"";
        in_picture = @"";
        in_voice = @"";
        in_title = @"";
        in_message = @"";
        in_comment = @"";

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
    SAFE_RELEASE(in_picture);
    SAFE_RELEASE(in_voice);
    SAFE_RELEASE(in_title);
    SAFE_RELEASE(in_message);
    SAFE_RELEASE(in_comment);

    [__inputSet__ release];
    if (__inputFiles__ != nil)
        [__inputFiles__ release];
    SAFE_RELEASE(message);

    [super dealloc];
#endif
}

-(void)initRequest:(ASIFormDataRequest *)request {
    [request setUserInfo:[NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:self, API_FORWARD_SEND, nil]
        forKeys:[NSArray arrayWithObjects:@"class", @"api", nil]]];

    if ([__inputSet__ containsObject:@"platformlist"])
    	[request setPostValue:in_platformlist forKey:@"platformlist"];
    if ([__inputSet__ containsObject:@"resid"])
    	[request setPostValue:in_resid forKey:@"resid"];
    if ([__inputSet__ containsObject:@"picture"])
    	[request setPostValue:in_picture forKey:@"picture"];
    if ([__inputSet__ containsObject:@"voice"])
    	[request setPostValue:in_voice forKey:@"voice"];
    if ([__inputSet__ containsObject:@"title"])
    	[request setPostValue:in_title forKey:@"title"];
    if ([__inputSet__ containsObject:@"message"])
    	[request setPostValue:in_message forKey:@"message"];
    if ([__inputSet__ containsObject:@"comment"])
    	[request setPostValue:in_comment forKey:@"comment"];
    
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
    return API_FORWARD_SEND;
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
}-(void)setIn_picture:(NSString*)_picture {
    if (in_picture)
        SAFE_RELEASE(in_picture);
    in_picture = SAFE_RETAIN(_picture);
    [__inputSet__ addObject:@"picture"];
}-(void)setIn_voice:(NSString*)_voice {
    if (in_voice)
        SAFE_RELEASE(in_voice);
    in_voice = SAFE_RETAIN(_voice);
    [__inputSet__ addObject:@"voice"];
}-(void)setIn_title:(NSString*)_title {
    if (in_title)
        SAFE_RELEASE(in_title);
    in_title = SAFE_RETAIN(_title);
    [__inputSet__ addObject:@"title"];
}-(void)setIn_message:(NSString*)_message {
    if (in_message)
        SAFE_RELEASE(in_message);
    in_message = SAFE_RETAIN(_message);
    [__inputSet__ addObject:@"message"];
}-(void)setIn_comment:(NSString*)_comment {
    if (in_comment)
        SAFE_RELEASE(in_comment);
    in_comment = SAFE_RETAIN(_comment);
    [__inputSet__ addObject:@"comment"];
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.code = [dict intValue:@"code"];
	    self.message = [dict strValue:@"message"];

	}
}
@end;

