
# import "Common.h"
# import "NetObj.h"
# import "NSMemCache.h"

@implementation ASIHTTPRequest (addition)

- (void)setUserAgent:(NSString *)userAgent {
    [self setUserAgentString:userAgent];
}

@end

@implementation NetObj

- (void)initRequest:(ASIFormDataRequest *)request {
    PASS;
}

- (NSString*)getUrl {
    return @"";
}

- (HttpMethod)method {
    return kHttpMethodGet;
}

- (void)parse:(id)obj {
    PASS;
}

@end

@interface NetUrlObj ()
{
    NSMutableDictionary *_params, *_files;
    NSString *_url, *_message;
    id _data;
    NSInteger _code;
}
@end

@implementation NetUrlObj

@synthesize params = _params, files = _files;
@synthesize url = _url, data = _data, code = _code, message = _message;

- (void)initRequest:(ASIFormDataRequest *)request {
    [request setUserInfo:[NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:self, @"NETURL_OBJECT", nil]
                                                     forKeys:[NSArray arrayWithObjects:@"class", @"api", nil]]];
    
    if (self.method == kHttpMethodPost)
    {
        [_params foreach:^IteratorType(id key, id obj) {
            [request setPostValue:obj forKey:key];
            return YES;
        }];
    }
    
    [_files foreach:^IteratorType(id key, id obj) {
        [request setFile:obj forKey:key];
        return YES;
    }];
}

- (id)init {
    self = [super init];
    _params = [[NSMutableDictionary alloc] init];
    _files = [[NSMutableDictionary alloc] init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_url);
    ZERO_RELEASE(_data);
    ZERO_RELEASE(_params);
    ZERO_RELEASE(_files);
    ZERO_RELEASE(_message);
    [super dealloc];
}

- (void)setParam:(NSString*)name value:(id)value {
    [_params setObject:value forKey:name];
}

- (void)setFile:(NSString*)name path:(NSString*)path {
    [_files setObject:path forKey:name];
}

- (NSString*)getUrl {
    if (_url == nil)
        return self.url;
    return _url;
}

- (void)parse:(NSObject *)obj {
    self.data = obj;
    self.code = 0;
    self.message = @"";
}

@end

@implementation NSObject (netobj)

- (void)parseJSON:(id)jstr {
    if ([jstr isKindOfClass:[NSDictionary class]]) {
        [self performSelector:@selector(parse:) withObject:jstr];
        return;
    }
    
    if ([jstr isKindOfClass:[NSArray class]]) {
        [self performSelector:@selector(parse:) withObject:jstr];
        return;
    }
    
    if ([jstr respondsToSelector:@selector(stringValue)])
        [self performSelector:@selector(parse:) withObject:[[jstr stringValue] jsonObject]];
    
    [self performSelector:@selector(parse:) withObject:[jstr jsonObject]];
}

NSOBJECT_DYNAMIC_PROPERTY(NSObject, errorMessage, setErrorMessage, COPY_NONATOMIC);
NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR(NSObject, isRequested, setIsRequested, BOOL, @(val), [val boolValue], RETAIN_NONATOMIC);

- (void)reloadData:(BOOL)flush {
    PASS;
}

- (void)reloadData {
    [self reloadData:NO];
}

- (void)flushData {
    [self reloadData:YES];
}

@end

@implementation NSDictionary (netobj)

- (int)intValue:(NSString*)path {
    return [self intValue:path default:0];
}

- (long)longValue:(NSString*)path {
    return [self longValue:path default:0];
}

- (float)floatValue:(NSString*)path {
    return [self floatValue:path default:0.0];
}

- (NSString*)strValue:(NSString*)path {
    return [self strValue:path default:nil];
}

- (int)intValue:(NSString*)path default:(int)defValue {
    NSObject* obj = [self valueForKeyPath:path];
    if ([obj isKindOfClass:[NSNumber class]])
        return [(NSNumber*)obj intValue];
    else if ([obj isKindOfClass:[NSString class]])
        return [(NSString*)obj intValue];
    return defValue;
}

- (long)longValue:(NSString*)path default:(long)defValue {
    NSObject* obj = [self valueForKeyPath:path];
    if ([obj isKindOfClass:[NSNumber class]])
        return [(NSNumber*)obj longValue];
    else if ([obj isKindOfClass:[NSString class]])
        return (long)[(NSString*)obj longLongValue];
    return defValue;
}

- (float)floatValue:(NSString*)path default:(float)defValue {
    NSObject* obj = [self valueForKeyPath:path];
    if ([obj isKindOfClass:[NSNumber class]])
        return [(NSNumber*)obj floatValue];
    else if ([obj isKindOfClass:[NSString class]])
        return [(NSString*)obj floatValue];
    return defValue;
}

- (NSString*)strValue:(NSString*)path default:(NSString*)defValue {
    NSObject* obj = [self valueForKeyPath:path];
    if ([obj isKindOfClass:[NSNumber class]])
        return [(NSNumber*)obj stringValue];
    else if ([obj isKindOfClass:[NSString class]])
        return (NSString*)obj;
    return defValue;
}

- (NSArray*)arrayValue:(NSString*)path default:(NSArray*)defValue {
    NSObject* obj = [self valueForKeyPath:path];
    if(obj && [obj isKindOfClass:[NSArray class]])
        return (NSArray *)obj;
    return defValue;
}

- (NSArray*)arrayValue:(NSString*)path {
    NSObject* obj = [self valueForKeyPath:path];
    if(obj && [obj isKindOfClass:[NSArray class]])
        return (NSArray *)obj;
    return nil;
}

- (NSDictionary*)dictValue:(NSString*)path {
    NSObject* obj = [self valueForKeyPath:path];
    if(obj && [obj isKindOfClass:[NSDictionary class]])
        return (NSDictionary *)obj;
    return nil;
}

@end
