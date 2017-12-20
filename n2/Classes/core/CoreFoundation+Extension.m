
# import "Common.h"
# import "CoreFoundation+Extension.h"

NSString *kCFBundleDisplayNameKey = @"CFBundleDisplayName";
NSString* kCFEnvironmentVariablesKey = @"EnvironmentVariables";
NSString* kCFPathKey = @"Path";
NSString* kCFHomeKey = @"HOME";
NSString* kCFBundleURLTypesKey = @"CFBundleURLTypes";
NSString* kCFBundleURLSchemesKey = @"CFBundleURLSchemes";

const NSRange NSRangeZero = {0};
const CFRange CFRangeZero = {0};

BOOL NSRangeIntersect(NSRange l, NSRange r) {
    if (NSMaxRange(l) <= r.location)
        return NO;
    if (NSMaxRange(r) <= l.location)
        return NO;
    return YES;
}

@implementation CFObject

- (id)initWithCF:(CFTypeRef)obj {
    self = [super init];
    self.obj = obj;
    return self;
}

+ (instancetype)object:(CFTypeRef)obj {
    return [[[self alloc] initWithCF:obj] autorelease];
}

- (void)dealloc {
    CFSAFE_RELEASE(_obj);
    [super dealloc];
}

- (void)setObj:(CFTypeRef)obj {
    CFPROPERTY_RETAIN(_obj, obj);
}

@end
