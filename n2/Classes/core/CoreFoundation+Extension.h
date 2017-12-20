
# ifndef __COREFOUNDATION_EXTENSION_42A6255351DB4714AEE08EAA445D36A4_H_INCLUDED
# define __COREFOUNDATION_EXTENSION_42A6255351DB4714AEE08EAA445D36A4_H_INCLUDED

extern NSString* kCFBundleDisplayNameKey;
extern NSString* kCFEnvironmentVariablesKey;
extern NSString* kCFPathKey;
extern NSString* kCFHomeKey;
extern NSString* kCFBundleURLTypesKey;
extern NSString* kCFBundleURLSchemesKey;

# define CFPROPERTY_RETAIN(old, nv) \
{ \
if (old == nv) return; \
CFSAFE_RELEASE(old); \
old = nv; \
CFSAFE_RETAIN(old); \
}

# define CFSAFE_RELEASE(val) \
if (val) { CFRelease(val); val = NULL; }
# define CFZERO_RELEASE(val) \
if (val) CFRelease(val); val = NULL;

# define CFSAFE_RETAIN(val) \
if (val) { CFRetain(val); }

extern const NSRange NSRangeZero;
extern const CFRange CFRangeZero;

static NSRange NSRangeFromCFRange(CFRange v) {
    return NSMakeRange(v.location, v.length);
}

static CFRange CFRangeFromNSRange(NSRange v) {
    return CFRangeMake(v.location, v.length);
}

extern BOOL NSRangeIntersect(NSRange, NSRange);

@interface CFObject : NSObject

@property (nonatomic, assign) CFTypeRef obj;

- (id)initWithCF:(CFTypeRef)obj;
+ (instancetype)object:(CFTypeRef)obj;

@end

# endif
