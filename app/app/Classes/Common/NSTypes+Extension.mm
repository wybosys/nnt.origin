
# import "Common.h"
# import "NSTypes+Extension.h"
# import "FileSystem+Extension.h"
# import <CoreText/CoreText.h>
# import "NSData+Base64.h"
# import "NSMemCache.h"
# import "CoreFoundation+Extension.h"
# import <CommonCrypto/CommonDigest.h>
# include <mach/mach_time.h>
# include <execinfo.h>
# import "AppDelegate+Extension.h"
# import <MobileCoreServices/MobileCoreServices.h>

extern const NSRange NSRangeZero;

BOOL DATA_ONLY_MODE = NO;
BOOL AFTER_SCREENUPDATED = NO;

NSString* kNSThreadTLSDefaultKey = @"::ns::thread::tls::defaultkey";

@implementation NSThread (extension)

static void __tls_release_idobj(void* p) {
    id o = (id)p;
    [o release];
}

+ (NSMutableArray*)TlsArrayForKey:(NSString*)key {
    dispatch_queue_t que = dispatch_get_current_queue();
    void* ret = dispatch_queue_get_specific(que, key);
    if (ret == NULL) {
        ret = [NSMutableArray new];
        dispatch_queue_set_specific(que, key, ret, __tls_release_idobj);
    }
    return (id)ret;
}

+ (void)TlsPush:(id)obj forKey:(NSString*)key {
    NSMutableArray* arr = [self.class TlsArrayForKey:key];
    [arr push:obj];
}

+ (id)TlsPop:(NSString*)key {
    NSMutableArray* arr = [self.class TlsArrayForKey:key];
    return [arr pop];
}

+ (id)TlsTop:(NSString*)key {
    NSMutableArray* arr = [self.class TlsArrayForKey:key];
    return arr.top;
}

+ (NSMutableArray*)TlsArray {
    return [self.class TlsArrayForKey:kNSThreadTLSDefaultKey];
}

+ (void)TlsPush:(id)obj {
    [self.class TlsPush:obj forKey:kNSThreadTLSDefaultKey];
}

+ (id)TlsPop {
    return [self.class TlsPop:kNSThreadTLSDefaultKey];
}

+ (id)TlsTop {
    return [self.class TlsTop:kNSThreadTLSDefaultKey];
}

@end

@interface NSThreadExt ()

@property (nonatomic, readonly) NSThread *thd;

@end

@implementation NSThreadExt

- (id)init {
    self = [super init];
    if (self) {
        _thd = [[NSThread alloc] initWithTarget:self selector:@selector(__cbthread) object:nil];
    }
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_thd);
    [super dealloc];
}

- (void)start {
    [_thd start];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalTakeAction)
SIGNALS_END

- (void)__cbthread {
    [self.touchSignals emit:kSignalTakeAction];
}

@end

@implementation NSWeakObject

@synthesize obj = _obj;

+ (NSWeakObject*)weakObject:(id)obj {
    NSWeakObject* ret = [[NSWeakObject alloc] init];
    ret.obj = obj;
    return [ret autorelease];
}

- (NSWeakObject*)initWithObject:(id)obj {
    self = [super init];
    self.obj = obj;
    return self;
}

@end

@interface _NSStrongAttachment ()

@property (nonatomic, readonly) NSMutableDictionary* store;

@end

@implementation _NSStrongAttachment

- (id)init {
    self = [super init];
    _store = [[NSMutableDictionary alloc] init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_store);
    [super dealloc];
}

- (void)removeAllObjects {
    [_store removeAllObjects];
}

- (id)objectForKey:(id<NSCopying>)key {
    return [_store objectForKey:key];
}

- (id)objectForKey:(id<NSCopying>)key def:(id)def {
    id ret = [_store objectForKey:key];
    if (ret == nil)
        return def;
    return ret;
}

- (id)objectForKey:(id<NSCopying>)key create:(id(^)())create {
    id ret = nil;
    SYNCHRONIZED_BEGIN
    ret = [_store objectForKey:key];
    if (ret == nil) {
        ret = create();
        if (ret)
            [_store setObject:ret forKey:key];
    }
    SYNCHRONIZED_END
    return ret;
}

- (id)popObjectForKey:(id<NSCopying>)key def:(id)def {
    id ret = [self objectForKey:key];
    if (ret == nil)
        return def;
    [ret consign];
    // delete from store
    [_store removeObjectForKey:key];
    return ret;
}

- (void)setObject:(id)obj forKey:(id<NSCopying>)key {
    if (obj == nil) {
        [_store removeObjectForKey:key];
        return;
    }
    
    [_store setObject:obj forKey:key];
}

# define _NSSTRONGATTACHMENT_IMPL(val, name, valname) \
- (void)set##name:(val)v forKey:(id<NSCopying>)key { \
    [self setObject:@(v) forKey:key]; \
} \
- (val)get##name:(id<NSCopying>)key def:(val)def { \
    id ret = [self objectForKey:key]; \
    if (ret == nil) \
        return def; \
    return [ret valname##Value]; \
} \
- (val)get##name:(id<NSCopying>)key { \
    return [self get##name:key def:0]; \
}

_NSSTRONGATTACHMENT_IMPL(int, Int, int);
_NSSTRONGATTACHMENT_IMPL(BOOL, Bool, bool);
_NSSTRONGATTACHMENT_IMPL(float, Float, float);

@end

@interface _NSWeakAttachment ()

@property (nonatomic, readonly) NSMutableDictionary* store;

@end

@implementation _NSWeakAttachment

- (id)init {
    self = [super init];
    _store = [[NSMutableDictionary alloc] init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_store);
    [super dealloc];
}

- (void)removeAllObjects {
    [_store removeAllObjects];
}

- (id)getObject:(id)obj {
    return ((NSWeakObject*)obj).obj;
}

- (id)objectForKey:(id<NSCopying>)key {
    return [self getObject:[_store objectForKey:key]];
}

- (void)setObject:(id)obj forKey:(id<NSCopying>)key {
    if (obj == nil) {
        [_store removeObjectForKey:key];
        return;
    }
    
    NSWeakObject* wo = [[NSWeakObject alloc] initWithObject:obj];
    [_store setObject:wo forKey:key];
    SAFE_RELEASE(wo);
}

- (id)objectForKey:(id<NSCopying>)key def:(id)def {
    id ret = [_store objectForKey:key];
    if (ret == nil)
        return def;
    return [self getObject:ret];
}

- (id)popObjectForKey:(id<NSCopying>)key def:(id)def {
    id ret = [self objectForKey:key];
    if (ret == nil)
        return def;
    [ret consign];
    // delete from store
    [_store removeObjectForKey:key];
    return ret;
}

- (void)removeObjectForKey:(id<NSCopying>)key {
    [_store removeObjectForKey:key];
}

- (int)getInt:(id<NSCopying>)key def:(int)def {
    id ret = [self objectForKey:key];
    if (ret == nil)
        return def;
    return [ret intValue];
}

- (int)getInt:(id<NSCopying>)key {
    return [self getInt:key def:0];
}

@end

@implementation NSAttachment

- (id)init {
    self = [super init];
    
    _strong = [[_NSStrongAttachment alloc] init];
    _weak = [[_NSWeakAttachment alloc] init];
    
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_strong);
    ZERO_RELEASE(_weak);
    
    [super dealloc];
}

- (void)removeAllObjects {
    [_strong removeAllObjects];
    [_weak removeAllObjects];
}

@end

@implementation NSMask

+ (BOOL)Mask:(uint)mask Value:(uint)value {
    return (value & mask) == mask;
}

@end

@implementation NSCryptolib

+ (NSString*)base64string:(NSString*)string encoding:(NSStringEncoding)encoding {
    NSData* da = [string dataUsingEncoding:encoding];
    return [da base64EncodedString];
}

+ (NSString*)debase64string:(NSString*)string encoding:(NSStringEncoding)encoding {
    NSData* da = [NSData dataFromBase64String:string];
    return [[[NSString alloc] initWithData:da encoding:encoding] autorelease];
}

+ (NSData*)debase64data:(NSString*)string {
    NSData* da = [NSData dataFromBase64String:string];
    return da;
}

+ (NSString*)sha256string:(NSString *)string encoding:(NSStringEncoding)encoding {
    NSMutableData* d = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    NSData* ds = [string dataUsingEncoding:encoding];
    if (CC_SHA256(ds.bytes, ds.length, (unsigned char*)d.mutableBytes) == NULL)
        return nil;
    return d.hexStringValue;
}

@end

@interface NSSerializableException ()

@property (nonatomic, retain) NSMutableDictionary *data;

@end

@implementation NSSerializableException

- (id)init {
    self = [super init];
    self.date = [NSDate date];
    _data = [NSMutableDictionary new];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_exception);
    ZERO_RELEASE(_callStackSymbols);
    ZERO_RELEASE(_date);
    ZERO_RELEASE(_data);
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.exception forKey:@"exception"];
    [aCoder encodeObject:self.callStackSymbols forKey:@"callstacksymbols"];
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.data forKey:@"data"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    self.exception = [aDecoder decodeObjectForKey:@"exception"];
    self.callStackSymbols = [aDecoder decodeObjectForKey:@"callstacksymbols"];
    self.date = [aDecoder decodeObjectForKey:@"date"];
    self.data = [aDecoder decodeObjectForKey:@"data"];
    return self;
}

- (NSString*)name {
    return _exception.name;
}

- (NSString*)reason {
    return _exception.reason;
}

- (NSDictionary*)userInfo {
    return _exception.userInfo;
}

- (NSString*)description {
    return _exception.description;
}

@end

@implementation NSException (serial)

- (NSSerializableException*)serializableException {
    NSSerializableException* exc = [NSSerializableException temporary];
    exc.exception = self;
    exc.callStackSymbols = self.callStackSymbols;
    return exc;
}

@end

NSStringEncoding NSGB18030Encoding = 0x80000632;
NSStringEncoding NSGB2312Encoding = 0x80000630;
NSStringEncoding NSGBKEncoding = 0x80000631;
NSStringEncoding NSGig5Encoding = 0x80000A03;

@implementation NSString (extension)

+ (instancetype)stringWithData:(NSData*)da encoding:(NSStringEncoding)encoding {
    return [[[NSString alloc] initWithData:da encoding:encoding] autorelease];
}

+ (instancetype)stringWithByte:(Byte)b {
    Byte bs[] = {b, 0};
    return [NSString stringWithUTF8String:(char const*)bs];
}

- (NSString*)stringValue {
    return self;
}

- (NSString*)stdStringValue {
    return [NSString stringWithFormat:@"\"%@\"", self];
}

- (time_t)timestampValue {
    return (time_t)[self longLongValue];
}

- (BOOL)notEmpty {
    if (self.length == 0)
        return NO;
    if ([self isEqualToString:@""])
        return NO;
    return [self stringByReplacingOccurrencesOfString:@" " withString:@""].length != 0;
}

+ (BOOL)IsEqual:(NSString *)l ToString:(NSString *)r {
    if (l == nil && r == nil)
        return YES;
    
    return [l isEqualToString:r];
}

- (id)jsonObject {
    NSData* da = [self dataUsingEncoding:NSUTF8StringEncoding];
# ifdef DEBUG_MODE
    NSError* err = nil;
    id ret = [NSJSONSerialization JSONObjectWithData:da
                                             options:0
                                               error:&err];
    if (err)
        [err log];
    return ret;
# endif
    return [NSJSONSerialization JSONObjectWithData:da
                                           options:0
                                             error:nil];
}

- (NSString*)prettyString {
    NSString* str = self;
    str = [str stringByReplacingOccurrencesOfString:@"\\\\\\\\\\\\" withString:@"\\"];
    str = [str stringByReplacingOccurrencesOfString:@"\\\\\\\\\\" withString:@"\\"];
    str = [str stringByReplacingOccurrencesOfString:@"\\\\\\\\" withString:@"\\"];
    str = [str stringByReplacingOccurrencesOfString:@"\\\\\\" withString:@"\\"];
    str = [str stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
    str = [str stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    str = [str stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    return str;
}

- (NSMutableString*)mutableString {
    return [NSMutableString stringWithString:self];
}

- (NSString*)urlencode {
    return [(NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[[self mutableCopy] autorelease],
                                                               NULL, CFSTR("￼=,!$&'()*+;@?\n\"<>#\t:/"),
                                                               kCFStringEncodingUTF8) autorelease];
}

- (NSString*)urldecode {
    return [(NSString*)CFURLCreateStringByReplacingPercentEscapes(NULL, (CFStringRef)[[self mutableCopy] autorelease],
                                                                  CFSTR(""))
                                                                  //CFSTR("￼=,!$&'()*+;@?\n<>#\t:/"))
            autorelease];
}

- (NSString*)base64 {
    return [NSCryptolib base64string:self encoding:NSUTF8StringEncoding];
}

- (NSString*)debase64 {
    return [NSCryptolib debase64string:self encoding:NSUTF8StringEncoding];
}

- (NSData*)debase64data {
    return [NSCryptolib debase64data:self];
}

- (NSString*)sha256 {
    return [NSCryptolib sha256string:self encoding:NSASCIIStringEncoding];
}

- (NSString*)md5 {
    const char *str = [self UTF8String];
    if (str == NULL)
        str = "";
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *ret = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                     r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return ret;
}

- (NSString*)fileMimetype {
    CFStringRef ext = (CFStringRef)[self pathExtension];
    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext, NULL);
    NSString *ret = [(id)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType) autorelease];
    CFSAFE_RELEASE(type);
    if (ret == nil)
        ret = @"application/octet-stream";
    return ret;
}

- (NSString*)stringTrimSpace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString*)uuid {
    return [[self class] uuid:UUID_STR_32W];
}

+ (NSString*)uuid:(UUID_STR)type {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef cfstring = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    const char *cStr = CFStringGetCStringPtr(cfstring,CFStringGetFastestEncoding(cfstring));
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    CFRelease(uuid);
    CFRelease(cfstring);
    
    NSString* format = @"";
    if (type == UUID_STR_32W)
        format = @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x";
    else
        format = @"%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x";
    return [NSString stringWithFormat:
            format,
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]];
}

- (NSString*)stringBySelfAppendingCount:(NSInteger)cnt {
    NSString* ret = self;
    while (cnt--) {
        ret = [ret stringByAppendingString:self];
    }
    return ret;
}

- (NSArray*)substringsByOccurrencesOfString:(NSString*)string options:(NSStringCompareOptions)options {
    NSMutableArray* ret = [NSMutableArray array];
    
    NSUInteger const maxlen = self.length;
    NSRange fpos = NSMakeRange(0, maxlen);
    while (fpos.location != NSNotFound)
    {
        NSString* val = @"";
        
        NSRange ffound = [self rangeOfString:string options:options range:fpos];
        if (ffound.location == NSNotFound) {
            val = [self substringWithRange:fpos];
            [ret addObject:val];
            break;
        }
        
        if (ffound.location != fpos.location) {
            NSRange fleft = NSMakeRange(fpos.location, ffound.location - fpos.location);
            val = [self substringWithRange:fleft];
            [ret addObject:val];
        } else {
            if ([NSMask Mask:NSKeepFirstMatched Value:options])
                [ret addObject:@""];
        }
        
        val = [self substringWithRange:ffound];
        [ret addObject:val];
        
        fpos.location = ffound.location + ffound.length;
        fpos.length = maxlen - ffound.location - ffound.length;
    }
    
    return ret;
}

- (NSString*)substringWithRange:(NSRange)range fillOverflow:(NSString*)fs {
    NSInteger ofs = 0;
    if (NSMaxRange(range) >= self.length) {
        ofs = NSMaxRange(range) - self.length;
        range.length = self.length - range.location;
    }
    if (range.location >= self.length)
        return @"";
    NSString* ret = [self substringWithRange:range];
    if (fs)
        ret = [ret stringByAppendingString:[fs stringBySelfAppendingCount:ofs]];
    return ret;
}

- (void)foreachSubstring:(BOOL(^)(NSString*, int))block length:(int)length {
    NSRange rgn = NSMakeRange(0, length);
    for (int i = 0; rgn.location < self.length; ++i)
    {
        NSString* str = [self substringWithRange:rgn];
        if (block(str, i) == NO)
            break;
        rgn.location += rgn.length;
    }
}

# define STRING_MAX_LENGTH 0x70000000

- (NSString*)stringByInsertString:(NSString*)str atIndex:(NSUInteger)index {
    NSString* left = [self substringWithRange:NSMakeRange(0, index) fillOverflow:nil];
    NSString* right = [self substringWithRange:NSMakeRange(index, STRING_MAX_LENGTH) fillOverflow:nil];
    return [NSString stringWithFormat:@"%@%@%@", left, str, right];
}

- (NSString*)stringByRemoveInRange:(NSRange)range {
    NSString* left = [self substringWithRange:NSMakeRange(0, range.location) fillOverflow:nil];
    NSString* right = [self substringWithRange:NSMakeRange(NSMaxRange(range), STRING_MAX_LENGTH) fillOverflow:nil];
    return [left stringByAppendingString:right];
}

- (NSString*)stringAtIndex:(NSUInteger)idx {
    return [self stringAtIndex:idx def:nil];
}

- (NSString*)stringAtIndex:(NSUInteger)idx def:(NSString *)def {
    return [self substringWithRange:NSMakeRange(idx, 1) fillOverflow:def];
}

- (NSInteger)indexOfSubString:(NSString*)str {
    NSRange rgn = [self rangeOfString:str];
    return rgn.location;
}

+ (NSString*)RandomString {
    return [NSString RandomString:0];
}

+ (NSString*)RandomString:(NSUInteger)length {
    static unichar chars[] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', ' ', '\n', '\t'};
    if (length == 0)
        length = [NSRandom valueBoundary:0 To:sizeof(chars)];
    NSMutableString* str = [NSMutableString stringWithCapacity:length];
    for (int i = 0; i < length; ++i) {
        int idx = [NSRandom valueBoundary:0 To:sizeof(chars)/sizeof(unichar)];
        [str appendString:[NSString stringWithCharacters:(chars + idx) length:1]];
    }
    return str;
}

+ (NSString*)stringRepeatString:(NSString*)str count:(NSInteger)count {
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:count];
    return [arr componentsJoinedByString:@""];
}

- (BOOL)containsString:(NSString *)aString {
    NSRange rgn = [self rangeOfString:aString];
    return rgn.location != NSNotFound;
}

- (NSString*)stringLeftside:(NSString*)sep {
    NSRange rgn = [self rangeOfString:sep];
    if (rgn.location == NSNotFound)
        return self;
    return [self substringToIndex:rgn.location];
}

- (NSString*)stringRightside:(NSString*)sep {
    NSRange rgn = [self rangeOfString:sep];
    if (rgn.location == NSNotFound)
        return @"";
    return [self substringFromIndex:NSMaxRange(rgn)];
}

- (NSArray*)explodeByLength:(NSInteger)length {
    NSMutableArray* ret = [NSMutableArray array];
    NSRange rgn = NSMakeRange(0, length);
    NSInteger lst = self.length;
    while (lst > 0) {
        if (lst < rgn.length)
            rgn.length = lst;
        NSString* str = [self substringWithRange:rgn];
        [ret addObject:str];
        rgn.location += rgn.length;
        lst -= rgn.length;
    }
    return ret;
}

- (NSArray*)componentsSeparatedByString:(NSString*)sep skipSpace:(BOOL)skipSpace {
    NSArray* arr = [self componentsSeparatedByString:sep];
    if (skipSpace)
        return [arr arrayWithCollector:^id(NSString* l) {
            return TRIEXPRESS(l.length, l, nil);
        }];
    return arr;
}

- (void*)hexPointerValue {
    NSScanner* scn = [NSScanner scannerWithString:self];
# ifdef X32_MODE
    uint d = 0;
    [scn scanHexInt:&d];
    return (void*)d;
# endif
# ifdef X64_MODE
    ulonglong d = 0;
    [scn scanHexLongLong:&d];
    return (void*)d;
# endif
}

@end

@implementation NSMutableString (extension)

- (void)clear {
    [self setString:@""];
}

- (void)appendString:(NSString *)str def:(NSString *)def {
    if (str) {
        [self appendString:str];
    } else if (def) {
        [self appendString:def];
    }
}

@end

@implementation NSPair

- (void)dealloc {
    ZERO_RELEASE(_firstObject);
    ZERO_RELEASE(_secondObject);
    [super dealloc];
}

+ (instancetype)pairFirst:(id)f Second:(id)s {
    return [[[[self class] alloc] initWithFirst:f withSecond:s] autorelease];
}

- (id)initWithFirst:(id)f withSecond:(id)s {
    self = [super init];
    self.firstObject = f;
    self.secondObject = s;
    return self;
}

@end

@implementation NSTriple

- (void)dealloc {
    ZERO_RELEASE(_thirdObject);
    [super dealloc];
}

+ (instancetype)pairFirst:(id)f Second:(id)s Thrid:(id)t {
    return [[[self.class alloc] initWithFirst:f withSecond:s Thrid:t] autorelease];
}

- (id)initWithFirst:(id)f withSecond:(id)s Thrid:(id)t {
    self = [super initWithFirst:f withSecond:s];
    self.thirdObject = t;
    return self;
}

@end

NSString* kCTCustomDeleteLineAttributeName = @"::ct::custom::deleteline::attributename";
NSString* kCTCustomBottomLineAttributeName = @"::ct::custom::bottomline::attributename";

typedef ::std::vector<CTParagraphStyleSetting> vector_paragraphstylesetting_t;

@interface NSStylization ()
{
    vector_paragraphstylesetting_t* _paragraphstylesettings;
}

- (vector_paragraphstylesetting_t&)paragraphstylesettings;

@end

@implementation NSStylization

- (id)init {
    self = [super init];
    return self;
}

- (id)initWithTextColor:(UIColor*)textColor textFont:(UIFont*)textFont {
    self = [self init];
    self.textColor = textColor;
    self.textFont = textFont;
    return self;
}

+ (instancetype)styleWithTextColor:(UIColor*)textColor textFont:(UIFont*)textFont {
    return [[[self alloc] initWithTextColor:textColor textFont:textFont] autorelease];
}

+ (instancetype)textColor:(UIColor*)textColor {
    return [self styleWithTextColor:textColor textFont:nil];
}

+ (instancetype)textFont:(UIFont*)textFont {
    return [self styleWithTextColor:nil textFont:textFont];
}

- (void)dealloc {
    ZERO_RELEASE(_textColor);
    ZERO_RELEASE(_textFont);
    ZERO_RELEASE(_deleteLine);
    ZERO_RELEASE(_bottomLine);
    
    if (_paragraphstylesettings) {
        for (vector_paragraphstylesetting_t::iterator iter = _paragraphstylesettings->begin();
             iter != _paragraphstylesettings->end();
             ++iter)
        {
            CTParagraphStyleSetting& val = *iter;
            free((void*)val.value);
        }
        zero_release(_paragraphstylesettings);
    }

    [super dealloc];
}

- (vector_paragraphstylesetting_t&)paragraphstylesettings {
    if (_paragraphstylesettings == nil)
        _paragraphstylesettings = new vector_paragraphstylesetting_t;
    return *_paragraphstylesettings;
}

- (CTParagraphStyleSetting*)paragraphstylesettingsForType:(CTParagraphStyleSpecifier)type {
    for (vector_paragraphstylesetting_t::iterator iter = self.paragraphstylesettings.begin();
         iter != self.paragraphstylesettings.end();
         ++iter)
    {
        if (iter->spec == type)
            return &*iter;
    }
    return NULL;
}

- (instancetype)setLineSpacing:(CGFloat)spacing {
    if (CTParagraphStyleSetting* set = [self paragraphstylesettingsForType:kCTParagraphStyleSpecifierLineSpacingAdjustment])
    {
        object_memcpy(set->value, spacing);
        return self;
    }
    
    CTParagraphStyleSetting set;
    set.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;
    set.value = object_memdup(spacing);
    set.valueSize = sizeof(spacing);
    
    self.paragraphstylesettings.push_back(set);
    return self;
}

- (instancetype)setLineBreakMode:(NSLineBreakMode)val {
    CTLineBreakMode mode;
    switch (val)
    {
        case NSLineBreakByCharWrapping: mode = kCTLineBreakByCharWrapping; break;
        case NSLineBreakByClipping: mode = kCTLineBreakByClipping; break;
        case NSLineBreakByTruncatingHead: mode = kCTLineBreakByTruncatingHead; break;
        case NSLineBreakByTruncatingMiddle: mode = kCTLineBreakByTruncatingMiddle; break;
        case NSLineBreakByTruncatingTail: mode = kCTLineBreakByTruncatingTail; break;
        case NSLineBreakByWordWrapping: mode = kCTLineBreakByWordWrapping; break;
    }

    if (CTParagraphStyleSetting* set = [self paragraphstylesettingsForType:kCTParagraphStyleSpecifierLineBreakMode])
    {
        object_memcpy(set->value, mode);
        return self;
    }
    
    CTParagraphStyleSetting set;
    set.spec = kCTParagraphStyleSpecifierLineBreakMode;
    set.value = object_memdup(mode);
    set.valueSize = sizeof(mode);

    self.paragraphstylesettings.push_back(set);
    return self;
}

- (BOOL)isLineBreakModeSet {
    return [self paragraphstylesettingsForType:kCTParagraphStyleSpecifierLineBreakMode] != NULL;
}

- (instancetype)setAlignment:(NSTextAlignment)val {
    CTTextAlignment align;
    switch (val)
    {
        case NSTextAlignmentCenter: align = kCTTextAlignmentCenter; break;
        case NSTextAlignmentJustified: align = kCTTextAlignmentJustified; break;
        case NSTextAlignmentLeft: align = kCTTextAlignmentLeft; break;
        case NSTextAlignmentNatural: align = kCTTextAlignmentNatural; break;
        case NSTextAlignmentRight: align = kCTTextAlignmentRight; break;
    }
    
    if (CTParagraphStyleSetting* set = [self paragraphstylesettingsForType:kCTParagraphStyleSpecifierAlignment])
    {
        object_memcpy(set->value, align);
        return self;
    }
    
    CTParagraphStyleSetting set;
    set.spec = kCTParagraphStyleSpecifierAlignment;
    set.value = object_memdup(align);
    set.valueSize = sizeof(align);
    
    self.paragraphstylesettings.push_back(set);
    return self;
}

- (instancetype)setParagraphSpacingBefore:(CGFloat)before After:(CGFloat)after {
    if (before) {
        if (CTParagraphStyleSetting* set = [self paragraphstylesettingsForType:kCTParagraphStyleSpecifierParagraphSpacingBefore]) {
            object_memcpy(set->value, before);
        } else {
            
            CTParagraphStyleSetting nset;
            nset.spec = kCTParagraphStyleSpecifierParagraphSpacingBefore;
            nset.value = object_memdup(before);
            nset.valueSize = sizeof(before);
            
            self.paragraphstylesettings.push_back(nset);
        }
    }
        
    if (after) {
        if (CTParagraphStyleSetting* set = [self paragraphstylesettingsForType:kCTParagraphStyleSpecifierParagraphSpacing]) {
            object_memcpy(set->value, after);
        } else {
            
            CTParagraphStyleSetting nset;
            nset.spec = kCTParagraphStyleSpecifierParagraphSpacing;
            nset.value = object_memdup(after);
            nset.valueSize = sizeof(after);
            
            self.paragraphstylesettings.push_back(nset);
        }
    }

    return self;
}

- (BOOL)isAlignmentSet {
    return [self paragraphstylesettingsForType:kCTParagraphStyleSpecifierAlignment] != NULL;
}

- (void)setIn:(NSMutableAttributedString*)str range:(NSRange)range {
    if (_textColor) {
        [str addAttribute:(NSString*)kCTForegroundColorAttributeName
                    value:(id)_textColor.CGColor
                    range:range];
    }
    
    if (_textFont) {
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)_textFont.fontName,
                                                  _textFont.pointSize,
                                                  NULL);
        [str addAttribute:(NSString*)kCTFontAttributeName
                    value:(id)fontRef
                    range:range];
        CFRelease(fontRef);
    }
    
    if (_characterSpacing) {
        CFTypeRef num = CFNumberCreate(kCFAllocatorDefault, kCFNumberFloat32Type, &_characterSpacing);
        [str addAttribute:(NSString*)kCTKernAttributeName
                    value:(id)num
                    range:range];
        CFRelease(num);
    }
    
    if (_paragraphstylesettings) {
        CTParagraphStyleRef style = CTParagraphStyleCreate(&_paragraphstylesettings->front(), _paragraphstylesettings->size());
        [str addAttribute:(NSString*)kCTParagraphStyleAttributeName
                    value:(id)style
                    range:range];
        CFRelease(style);
    }
    
    if (_deleteLine) {
        if (_deleteLine.color == nil && _textColor)
            _deleteLine.color = _textColor.CGColor;
        [str addAttribute:kCTCustomDeleteLineAttributeName
                    value:_deleteLine
                    range:range];
    }
    
    if (_bottomLine) {
        if (_bottomLine.color == nil && _textColor)
            _bottomLine.color = _textColor.CGColor;
        [str addAttribute:kCTCustomBottomLineAttributeName
                    value:_bottomLine
                    range:range];
    }
}

@end

@implementation NSAttributedString (extension)

- (CGSize)bestSize:(CGSize)maxsize {
    CGSize sz;
    AUTORELEASE_BEGIN
    CTFramesetterRef fs = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self);
    sz = CTFramesetterSuggestFrameSizeWithConstraints(fs, CFRangeMake(0, 0), NULL, maxsize, NULL);
    CFRelease(fs);
    AUTORELEASE_END
    sz = CGSizeBBXIntegral(sz);
    return sz;
}

- (CGSize)bestSize:(CGSize)maxsize inLineRange:(NSRange)rgn {
    CGSize sz;
    AUTORELEASE_BEGIN
    
    // 计算出标准大小
    CTFramesetterRef fs = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self);
    sz = CTFramesetterSuggestFrameSizeWithConstraints(fs, CFRangeMake(0, 0), NULL, maxsize, NULL);
    
    // 计算出目标行限定的大小
    CGMutablePathRef ph = CGPathCreateMutable();
    CGPathAddRect(ph, nil, CGRectMakeWithSize(maxsize));
    CTFrameRef frame = CTFramesetterCreateFrame(fs, CFRangeMake(0, 0), ph, NULL);
    
    NSArray* lines = (NSArray*)CTFrameGetLines(frame);
    
    if (lines.count >= (rgn.location + rgn.length))
    {
        CGPoint origins[lines.count];
        CTFrameGetLineOrigins(frame, CFRangeMake(0, lines.count), origins);
        // 取得目标行的行首位置
        CGPoint ptorigin = origins[rgn.location + rgn.length - 1];
        ptorigin.y = maxsize.height - ptorigin.y;
        // 计算目标行行高
        CTLineRef line = (CTLineRef)lines[rgn.location + rgn.length - 1];
        CGFloat lh = 0;
        for (id each in (NSArray*)CTLineGetGlyphRuns(line))
        {
            CTRunRef run = (CTRunRef)each;
            CGRect rc;
            CGFloat ascent, descent;
            rc.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            // 这个数据加上会引起总高多余了一个高度，所以实验采用扣除这个高度来调整
            ascent = 0;
            rc.size.height = ascent + descent;
            lh = MAX(lh, rc.size.height);
        }
        CGFloat maxh = ptorigin.y + lh;
        sz.height = MIN(maxh, sz.height);
    }
    
    CGPathRelease(ph);
    CFRelease(fs);
    CFRelease(frame);
    
    AUTORELEASE_END
    
    sz = CGSizeBBXIntegral(sz);
    return sz;
}

- (NSUInteger)numberOfLines:(CGSize)maxsize {
    NSUInteger ret = 0;
    
    AUTORELEASE_BEGIN
    
    // 计算出标准大小
    CTFramesetterRef fs = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self);
    
    // 计算出目标行限定的大小
    CGMutablePathRef ph = CGPathCreateMutable();
    CGPathAddRect(ph, nil, CGRectMakeWithSize(maxsize));
    CTFrameRef frame = CTFramesetterCreateFrame(fs, CFRangeMake(0, 0), ph, NULL);
    
    NSArray* lines = (NSArray*)CTFrameGetLines(frame);
    ret = lines.count;
    
    CGPathRelease(ph);
    CFRelease(fs);
    CFRelease(frame);
    
    AUTORELEASE_END
    
    return ret;
}

@end

@interface NSStylizedItem : NSObject
<NSStylizedItem>

@property (nonatomic, copy) NSString *string;

- (BOOL)isString;

@end

@implementation NSStylizedItem

- (id)init {
    self = [super init];
    self.string = @"";
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_string);
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    NSStylizedItem* ret = [[[self class] alloc] init];
    ret.string = self.string;
    return ret;
}

static NSString* kNSStylizedItemKey = @"::ns::stylized::item";

- (void)setIn:(NSMutableAttributedString*)str offset:(NSUInteger)offset {
    PASS;
}

- (void)setIn:(NSMutableAttributedString*)str range:(NSRange)range {
    [str addAttribute:kNSStylizedItemKey value:self range:range];
}

- (BOOL)isString {
    return YES;
}

// 用于生成位于 attributedString 中得占位
- (NSString*)placedString {
    return self.string;
}

@end

@interface NSStylizedItemString : NSStylizedItem <NSStylizedItemString>

@property (nonatomic, retain) NSStylization *stylization;

@end

@implementation NSStylizedItemString

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_stylization);
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    NSStylizedItemString* ret = [super copyWithZone:zone];
    ret.stylization = self.stylization;
    return ret;
}

- (void)setIn:(NSMutableAttributedString*)str offset:(NSUInteger)offset {
    [super setIn:str offset:offset];
    
    NSRange rg = NSMakeRange(offset, self.string.length);
    [self setIn:str range:rg];
    
    [self.stylization setIn:str range:rg];
}

@end

@interface NSStylizedItemImage : NSStylizedItem <NSStylizedItemImage>

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, assign) CGRect preferredRect;
@property (nonatomic, assign) CGMargin margin;

@end

@implementation NSStylizedItemImage

- (id)init {
    self = [super init];
    self.string = @" ";
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_image);
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    NSStylizedItemImage* ret = [super copyWithZone:zone];
    ret.image = self.image;
    ret.preferredRect = self.preferredRect;
    ret.margin = self.margin;
    return ret;
}

- (NSString*)placedString {
    return @"#";
}

- (BOOL)isString {
    return NO;
}

static CGFloat __s_stylizeditemimage_ascent(void* refCon)
{
    CGFloat ret = 0;
    NSStylizedItemImage* arg = (NSStylizedItemImage*)refCon;
    CGRect prc = arg.preferredRect;
    if (CGSizeEqualToSize(prc.size, CGSizeZero) == NO)
        ret = prc.size.height;
    else
        ret = arg.image.size.height;
    if (CGPointEqualToPoint(prc.origin, CGPointZero) == NO)
        ret -= prc.origin.y;
    ret += arg.margin.top;
    return ret;
}

static CGFloat __s_stylizeditemimage_descent(void* refCon)
{
    CGFloat ret = 0;
    NSStylizedItemImage* arg = (NSStylizedItemImage*)refCon;
    CGRect prc = arg.preferredRect;
    if (CGPointEqualToPoint(prc.origin, CGPointZero) == NO)
        ret = prc.origin.y;
    else
        ret = 0;
    ret += arg.margin.bottom;
    return ret;
}

static CGFloat __s_stylizeditemimage_width(void* refCon)
{
    CGFloat ret = 0;
    NSStylizedItemImage* arg = (NSStylizedItemImage*)refCon;
    CGRect prc = arg.preferredRect;
    if (CGSizeEqualToSize(prc.size, CGSizeZero) == NO)
        ret = prc.size.width;
    else
        ret = arg.image.size.width;
    ret += prc.origin.x;
    ret += arg.margin.left + arg.margin.right;
    return ret;
}

static void __s_stylizeditemimage_dealloc(void* refCon)
{
    PASS;
}

- (void)setIn:(NSMutableAttributedString*)str offset:(NSUInteger)offset {
    [super setIn:str offset:offset];
    
    // 占位符设置成不可见
    NSStylization* tmpsty = [NSStylization textColor:[UIColor clearColor]];
    [tmpsty setIn:str range:NSMakeRange(offset, 1)];
    
    // 自定义回调
    CTRunDelegateCallbacks cbs;
    cbs.version = kCTRunDelegateVersion1;
    cbs.getAscent = __s_stylizeditemimage_ascent;
    cbs.getDescent = __s_stylizeditemimage_descent;
    cbs.getWidth = __s_stylizeditemimage_width;
    cbs.dealloc = __s_stylizeditemimage_dealloc;
    
    CTRunDelegateRef dlg = CTRunDelegateCreate(&cbs, self);
    
    NSRange rg = NSMakeRange(offset, self.string.length);
    
    [str addAttribute:(NSString*)kCTRunDelegateAttributeName
                value:(id)dlg
                range:rg];
    CFRelease(dlg);
    
    [self setIn:str range:rg];
}

@end

@interface NSStylizedItemCustom : NSStylizedItem <NSStylizedItemCustom>

@property (nonatomic, retain) NSStylization *stylization;
@property (nonatomic, retain) NSString *identifier;

@end

@implementation NSStylizedItemCustom

@synthesize delegate;

- (id)init {
    self = [super init];
    self.stylization = [NSStylization textColor:[UIColor whiteColor]];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_stylization);
    ZERO_RELEASE(_identifier);
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    NSStylizedItemCustom* ret = [super copyWithZone:zone];
    ret.stylization = self.stylization;
    ret.identifier = self.identifier;
    ret.delegate = self.delegate;
    return ret;
}

- (BOOL)isString {
    return NO;
}

- (NSString*)placedString {
    // 使用空格作为占位符会导致在折行时不计入大小，而导致折行失败
    // 换成 # 或其他占位符会正确计算折行，但是由于字符会被显示出来的问题，所以需要在设置渲染时将占位符的颜色隐去
    return @"#";
}

static CGFloat __s_stylizeditemcustom_ascent(void* refCon)
{
    NSStylizedItemCustom* arg = (NSStylizedItemCustom*)refCon;
    CGFloat ret = [arg.delegate ascentForItem:arg];
    return ret;
}

static CGFloat __s_stylizeditemcustom_descent(void* refCon)
{
    NSStylizedItemCustom* arg = (NSStylizedItemCustom*)refCon;
    CGFloat ret = [arg.delegate descentForItem:arg];
    return ret;
}

static CGFloat __s_stylizeditemcustom_width(void* refCon)
{
    NSStylizedItemCustom* arg = (NSStylizedItemCustom*)refCon;
    CGFloat ret = [arg.delegate widthForItem:arg];
    return ret;
}

static void __s_stylizeditemcustom_dealloc(void* refCon)
{
    PASS;
}

- (void)setIn:(NSMutableAttributedString*)str offset:(NSUInteger)offset {
    [super setIn:str offset:offset];
    
    // 占位符设置成不可见
    NSStylization* tmpsty = [NSStylization textColor:[UIColor clearColor]];
    [tmpsty setIn:str range:NSMakeRange(offset, 1)];
    
    // 自定义回调
    CTRunDelegateCallbacks cbs;
    cbs.version = kCTRunDelegateVersion1;
    cbs.getAscent = __s_stylizeditemcustom_ascent;
    cbs.getDescent = __s_stylizeditemcustom_descent;
    cbs.getWidth = __s_stylizeditemcustom_width;
    cbs.dealloc = __s_stylizeditemcustom_dealloc;
    
    CTRunDelegateRef dlg = CTRunDelegateCreate(&cbs, self);
    
    NSRange rg = NSMakeRange(offset, self.placedString.length);
    
    [str addAttribute:(NSString*)kCTRunDelegateAttributeName
                value:(id)dlg
                range:rg];
    
    CFRelease(dlg);
    
    [self setIn:str range:rg];
}

@end

@interface NSFullStylization ()
{
    NSLineBreakMode _lb;
    CTLineBreakMode _ctlb;
}

@end

@implementation NSFullStylization

- (instancetype)setLineBreakMode:(NSLineBreakMode)val {
    _lb = val;
    
    switch (val)
    {
        case NSLineBreakByCharWrapping: _ctlb = kCTLineBreakByCharWrapping; break;
        case NSLineBreakByClipping: _ctlb = kCTLineBreakByClipping; break;
        case NSLineBreakByTruncatingHead: _ctlb = kCTLineBreakByTruncatingHead; break;
        case NSLineBreakByTruncatingMiddle: _ctlb = kCTLineBreakByTruncatingMiddle; break;
        case NSLineBreakByTruncatingTail: _ctlb = kCTLineBreakByTruncatingTail; break;
        case NSLineBreakByWordWrapping: _ctlb = kCTLineBreakByWordWrapping; break;
    }
    
    return self;
}

- (NSLineBreakMode)linebreakMode {
    return _lb;
}

- (CTLineBreakMode)CTLinebreakMode {
    return _ctlb;
}

@end

@interface NSStylizedString ()
{
    NSStylization *_fullStyle;
}

// 为了提高性能，提供一个对象暂时把attributedString保存起来，应用层不要使用这个对象
@property (nonatomic, retain) NSAttributedString *unsafeAttributedString;

@end

@implementation NSStylizedString

@synthesize style = _fullStyle;

- (id)init {
    self = [super init];
    _items = [[NSMutableArray alloc] init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_items);
    ZERO_RELEASE(_lastStyle);
    ZERO_RELEASE(_fullStyle);
    ZERO_RELEASE(_unsafeAttributedString);
    [super dealloc];
}

- (NSStylization*)style {
    if (_fullStyle == nil) {
        _fullStyle = [[NSFullStylization alloc] init];
        if (_lastStyle == nil)
            self.lastStyle = _fullStyle;
    }
    return _fullStyle;
}

- (NSStylization*)touchStyle {
    return _fullStyle;
}

- (NSAttributedString*)attributedString {
    // 生成完整字符串
    NSMutableString* fullStr = [NSMutableString string];
    for (NSStylizedItem* each in self.items) {
        [fullStr appendString:each.placedString];
    }
    
    // 设置段落
    NSUInteger offset = 0;
    NSMutableAttributedString* ret = [[NSMutableAttributedString alloc] initWithString:fullStr];
    for (NSStylizedItem* each in self.items) {
        [each setIn:ret offset:offset];
        offset += each.placedString.length;
    }
    
    // 设置全部的样式
    if (_fullStyle)
        [_fullStyle setIn:ret range:NSMakeRange(0, offset)];
        
    return [ret autorelease];
}

- (BOOL)paragraphSpecifiedAlignment {
    for (NSStylizedItem* each in self.items) {
        if ([each respondsToSelector:@selector(stylization)])
        {
            NSStylization* sty = [each performSelector:@selector(stylization)];
            if (sty.isAlignmentSet)
                return YES;
        }
    }
    return NO;
}

- (BOOL)paragraphSpecifiedLineBreak {
    for (NSStylizedItem* each in self.items) {
        if ([each respondsToSelector:@selector(stylization)])
        {
            NSStylization* sty = [each performSelector:@selector(stylization)];
            if (sty.isLineBreakModeSet)
                return YES;
        }
    }
    return NO;
}

- (void)clear {
    [(NSMutableArray*)self.items removeAllObjects];
}

- (NSUInteger)length {
    NSUInteger sum = 0;
    for (NSStylizedItem* each in self.items) {
        if (each.isString == NO)
            continue;
        
        sum += each.string.length;
    }
    return sum;
}

- (NSString*)stringValue {
    NSMutableString* str = [NSMutableString string];
    for (NSStylizedItem* each in self.items) {
        if (each.isString == NO)
            continue;
        
        [str appendString:each.string];
    }
    return str;
}

- (NSString*)description {
    return self.stringValue;
}

- (NSObject<NSStylizedItem>*)append:(NSStylization*)style format:(NSString*)format ,... {
    if (format == nil)
        format = @"";
    
    NSStylizedItemString* item = [[NSStylizedItemString alloc] init];
        
    if (style) {
        if (style.textColor == nil)
            style.textColor = _lastStyle.textColor;
        if (style.textFont == nil)
            style.textFont = _lastStyle.textFont;
        self.lastStyle = style;
    } else {
        style = _lastStyle;
    }
    item.stylization = style;
    
    va_list va;
    va_start(va, format);
    NSString* str = [[NSString alloc] initWithFormat:format arguments:va];
    va_end(va);
    item.string = str;
    SAFE_RELEASE(str);
    
    [self.items addObject:item];
    SAFE_RELEASE(item);
    
    return item;
}

- (NSObject<NSStylizedItemCustom>*)appendCustom:(NSStylization*)style string:(NSString *)string identifier:(NSString *)identifier {
    NSStylizedItemCustom* item = [[NSStylizedItemCustom alloc] init];
    
    if (style) {
        if (style.textColor == nil)
            style.textColor = _lastStyle.textColor;
        if (style.textFont == nil)
            style.textFont = _lastStyle.textFont;
        self.lastStyle = style;
    } else {
        style = _lastStyle;
    }
    item.stylization = style;
    
    item.string = string;
    item.identifier = identifier;
    
    [self.items addObject:item];
    SAFE_RELEASE(item);
    
    return item;
}

- (void)setStylization:(NSStylization*)style {
    for (NSObject<NSStylizedItem>* each in self.items) {
        [each tryPerformSelector:@selector(setStylization:) withObject:style];
    }
}

- (NSObject<NSStylizedItem>*)appendImage:(UIImage*)image {
    return [self appendImage:image preferredRect:CGRectZero];
}

- (NSObject<NSStylizedItem>*)appendImage:(UIImage*)image preferredRect:(CGRect)rect {
    return [self appendImage:image preferredRect:rect margin:CGMarginZero];
}

- (NSObject<NSStylizedItem>*)appendImage:(UIImage*)image preferredRect:(CGRect)rect margin:(CGMargin)margin {
    NSStylizedItemImage* item = [[NSStylizedItemImage alloc] init];
    
    item.image = image;
    item.preferredRect = rect;
    item.margin = margin;
    
    [self.items addObject:item];
    SAFE_RELEASE(item);
    
    // 有些是通过异步获取的图片，所以需要连接一下信号
    [image.signals connect:kSignalImageFetched withSelector:@selector(cbImageFetched:) ofTarget:self];
    
    return item;
}

// 如果图片为异步获取，则需要替换掉原始图片
- (void)cbImageFetched:(SSlot*)s {
    for (id each in self.items) {
        if ([each isKindOfClass:[NSStylizedItemImage class]]) {
            NSStylizedItemImage* ii = each;
            if (ii.image == s.sender) {
                ii.image = s.data.object;
                break;
            }
        }
    }
    
    [self.signals emit:kSignalRequestRedraw];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalRequestRedraw)
SIGNALS_END

- (void)removeItem:(id<NSStylizedItem>)item {
    [self.items removeObject:item];
}

- (NSObject<NSStylizedItem>*)itemForTextRange:(NSRange)range locationInRange:(NSRange*)locrange {
    NSRange tgtrgn = NSRangeZero;
    for (NSStylizedItem* each in self.items) {
        tgtrgn.length = each.placedString.length;
        if (NSRangeContain(tgtrgn, range.location)) {
            if (locrange) {
                locrange->location = range.location - tgtrgn.location;
                NSInteger left = NSMaxRange(*locrange) - locrange->location;
                locrange->length = MIN(left, locrange->length);
            }
            return each;
        }
        tgtrgn.location += tgtrgn.length;
    }
    return nil;
}

- (void)setUnsafeAttributedString:(NSAttributedString *)unsafeAttributedString {
    PROPERTY_RETAIN(_unsafeAttributedString, unsafeAttributedString);
}

@end

@implementation NSURL (extension)

- (BOOL)notEmpty {
    return self.absoluteString.notEmpty;
}

- (NSURL*)initWithDataSource:(NSDataSource*)ds {
    if (ds.url.notEmpty)
        return [self initWithString:ds.url.absoluteString];
    if (ds.bundle.notEmpty) {
        NSString* file = [[FSApplication shared] pathBundle:ds.bundle];
        return [self initWithString:file];
    }
    [self release];
    return nil;
}

+ (NSURL*)URLWithDataSource:(NSDataSource*)ds {
    return [[[[self class] alloc] initWithDataSource:ds] autorelease];
}

- (NSString*)filePath {
    return self.relativePath;
}

- (NSString*)httpPath {
    return self.relativePath;
}

@end

@implementation NSURLRequest (extension)

+ (NSURLRequest*)requestWithURLString:(NSString *)URL {
    return [self requestWithURL:[NSURL URLWithString:URL]];
}

@end

@implementation NSURLConnection (extension)

@end

PRIVATE_IMPL_BEGIN(NSURLConnectionExt, NSObject <NSURLConnectionDataDelegate>,)

@property (nonatomic, retain) NSMutableData *buffer;
@property (nonatomic, retain) NSProgressValue *progress;
@property (nonatomic, assign) FILE* fd;

PRIVATE_IMPL(NSURLConnectionExt)

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_buffer);
    ZERO_RELEASE(_progress);
    [super dealloc];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse* respn = (NSHTTPURLResponse*)response;
    long long len = respn.expectedContentLength;
    if ((len == -1 || len == 0) && [response isKindOfClass:[NSHTTPURLResponse class]]) {
        WARN("NSURLResponse 没有返回 excepted length");
    }
    
    // 是否需要序列化到文件
    BOOL serialFile = d_owner.outputFile.notEmpty;
    
    // 判断mime是否相符
    NSDictionary* headers = respn.allHeaderFields;
    NSString* ctRemote = [headers objectForKey:@"Content-Type"];
    if (ctRemote) {
        // 取得期望文件的mime
        NSString* ctDes = respn.URL.filePath.fileMimetype;
        if ([ctDes isEqualToString:ctRemote] == NO) {
            WARN("服务器返回的文件类型和请求的文件类型不匹配, 请求地址: %s, 请求类型 %s, 返回 %s",
                 respn.URL.absoluteString.UTF8String,
                 ctDes.UTF8String,
                 ctRemote.UTF8String
                 );
            serialFile = NO;
        }
    }
    
    // 打开文件句柄
    if (serialFile)
    {
        NSString* fs = d_owner.outputFile.filePath;
        _fd = fopen(fs.UTF8String, "w+");
        if (_fd == NULL) {
            FATAL("打开文件 %s 失败，不能保存下载的数据到文件", fs.UTF8String);
        }
    }
    
    self.progress = [NSProgressValue temporary];
    self.progress.max = len;
        
    if (_fd == NULL) {
        self.buffer = [NSMutableData data];
        self.progress.totoalbuffer = self.buffer;
    }
    
    [d_owner.signals emit:kSignalStart withResult:self.progress];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (_fd) {
        fwrite(data.bytes, 1, data.length, _fd);
    } else {
        [(NSMutableData*)self.progress.totoalbuffer appendData:data];
        self.progress.packetbuffer = data;
    }
    
    self.progress.value += data.length;
    [d_owner.signals emit:kSignalValueChanged withResult:self.progress];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.progress.packetbuffer = nil;
    
    // 关闭文件句柄
    if (_fd) {
        fclose(_fd);
        _fd = NULL;
    }
    
    [d_owner.signals emit:kSignalDone withResult:self.progress];
    [d_owner.signals emit:kSignalProcessed];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // 关闭文件句柄
    if (_fd) {
        fclose(_fd);
        _fd = NULL;
    }

    // 断开信号
    [d_owner.signals emit:kSignalFailed withResult:error];
    [d_owner.signals emit:kSignalProcessed];
    [error log];
}

PRIVATE_IMPL_END()

@implementation NSURLConnectionExt

- (id)initWithRequest:(NSURLRequest *)request startImmediately:(BOOL)startImmediately {
    PRIVATE_CONSTRUCT(NSURLConnectionExt);
    self = [super initWithRequest:request delegate:d_ptr startImmediately:startImmediately];
    return self;
}

- (id)initWithRequest:(NSURLRequest *)request {
    return [self initWithRequest:request startImmediately:NO];
}

+ (NSURLConnectionExt*)connectionWithRequest:(NSURLRequest *)request {
    return [[[self alloc] initWithRequest:request] autorelease];
}

+ (NSURLConnectionExt*)connectionWithRequest:(NSURLRequest *)request startImmediately:(BOOL)startImmediately {
    return [[[self alloc] initWithRequest:request startImmediately:startImmediately] autorelease];
}

- (void)dealloc {
    ZERO_RELEASE(_outputFile);
    PRIVATE_DESTROY();
    [super dealloc];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalStart)
SIGNAL_ADD(kSignalFailed)
SIGNAL_ADD(kSignalDone)
SIGNAL_ADD(kSignalValueChanged)
SIGNAL_ADD(kSignalProcessed)
SIGNALS_END

- (NSProgressValue*)progressValue {
    return d_ptr.progress;
}

@end

@implementation NSMutableURLRequest (extension)

+ (NSMutableURLRequest*)mutableRequestWithRequest:(NSURLRequest*)req {
    NSMutableURLRequest* ret = [[[self class] alloc] init];
    ret.URL = req.URL;
    [ret setAllHTTPHeaderFields:req.allHTTPHeaderFields];
    [ret setHTTPMethod:req.HTTPMethod];
    return [ret autorelease];
}

- (void)addCookies:(NSArray *)cookies {
    NSString *cookieHeader = nil;
    for (NSHTTPCookie *cookie in cookies) {
        if (!cookieHeader) {
            cookieHeader = [NSString stringWithFormat:@"%@=%@", [cookie name], [cookie value]];
        }
        else {
            cookieHeader = [NSString stringWithFormat:@"%@; %@=%@", cookieHeader, [cookie name], [cookie value]];
        }
    }
    if (cookieHeader) {
        [self setValue:cookieHeader forHTTPHeaderField:@"Cookie"];
    }
}

NSOBJECT_DYNAMIC_PROPERTY_EXT(NSMutableURLRequest, userAgent,, setUserAgent,, {
    [self setValue:val forHTTPHeaderField:@"UserAgent"];
}, COPY_NONATOMIC);

- (void)SWIZZLE_CALLBACK(setValue):(NSString*)value forHTTPHeaderField:(NSString*)field {
    PASS;
}

- (NSString*)SWIZZLE_CALLBACK(value):(NSString*)value forHTTPHeaderField:(NSString*)field {
    if ([field isEqualToString:@"User-Agent"]) {
        if (self.userAgent && value != self.userAgent)
            return self.userAgent;
    }
    return value;
}

@end

@implementation NSClass

+ (instancetype)object:(Class)cls {
    NSClass* ret = [NSClass temporary];
    ret.classValue = cls;
    return ret;
}

+ (BOOL)Implement:(Class)cls forProtocol:(Protocol*)ptl {
    while (cls && cls != [NSObject class]) {
        if (class_conformsToProtocol(cls, ptl))
            return YES;
        cls = class_getSuperclass(cls);
    }
    return NO;
}

+ (void)ForeachProperty:(BOOL (^)(objc_property_t *))block forClass:(Class)cls {
    [NSClass ForeachProperty:block forClass:cls rootClass:[NSObject class]];
}

+ (void)ForeachProperty:(BOOL (^)(objc_property_t *))block forClass:(Class)cls forProtocol:(Protocol *)ptl {
    if (cls == [NSObject class])
        return;
    
    char const* name = class_getName(cls);
    if (*name == '_')
        return;
    
    uint szprops;
    objc_property_t* props = class_copyPropertyList(cls, &szprops);
    for (int i = 0; i < szprops; ++i) {
        char const* name = property_getName(props[i]);
        if (*name == '_')
            continue;
        
        if (block(props + i) == NO)
            break;
    }
    free(props);
    
    // 如果父类是 NSObject，跳掉
    Class supercls = class_getSuperclass(cls);
    if (supercls == NULL ||
        supercls == [NSObject class])
        return;
    
    // 当前的类必须实现协议
    if ([NSClass Implement:cls forProtocol:ptl]) {
        // 父类也需要实现协议
        if (supercls) {
            if ([NSClass Implement:supercls forProtocol:ptl]) {
                [NSClass ForeachProperty:block forClass:supercls forProtocol:ptl];
            }
        }
    }
}

+ (void)ForeachProperty:(BOOL (^)(objc_property_t *))block forClass:(Class)cls rootClass:(Class)rootCls {
    if (cls == rootCls)
        return;
    
    char const* name = class_getName(cls);
    if (*name == '_')
        return;
    
    uint szprops;
    objc_property_t* props = class_copyPropertyList(cls, &szprops);
    for (int i = 0; i < szprops; ++i) {
        char const* name = property_getName(props[i]);
        if (*name == '_')
            continue;
        
        if (block(props + i) == NO)
            break;
    }
    free(props);
    
    // 如果当前不是根类
    if (cls != rootCls) {
        // 如果父类不是 定义的 则继续
        Class supercls = class_getSuperclass(cls);
        if (supercls && supercls != [NSObject class]) {
            if (supercls != rootCls) {
                [NSClass ForeachProperty:block forClass:supercls rootClass:rootCls];
            }
        }
    }
}

+ (void)ForeachMethod:(BOOL (^)(Method mth))block forClass:(Class)cls {
    uint count = 0;
    Method* mths = class_copyMethodList(cls, &count);
    for (uint i = 0; i < count; ++i) {
        if (!block(mths[i]))
            break;
    }
    free(mths);
    
    // 遍历父类
    Class scls = class_getSuperclass(cls);
    if (scls && scls != [NSObject class])
        [NSClass ForeachMethod:block forClass:scls];
}

@end

@implementation NSMixinClass

+ (instancetype)classes:(Class)cls, ... {
    NSMixinClass* ret = [[self alloc] init];
    NSMutableArray* mutarr = (id)ret.classes;
    [mutarr addObject:[NSClass object:cls]];
    
    va_list va;
    va_start(va, cls);
    while (Class cls = va_arg(va, Class)) {
        [mutarr addObject:[NSClass object:cls]];
    }
    va_end(va);
    
    return [ret autorelease];
}

- (id)init {
    self = [super init];
    _classes = [[NSMutableArray alloc] init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_classes);
    [super dealloc];
}

- (Class)classValue {
    NSClass* ro = _classes.firstObject;
    return ro.classValue;
}

@end

@implementation NSObjectExt

- (id)init {
    self = [super init];
    if (self)
        [self onInit];
    return self;
}

- (void)dealloc {
    [self onFin];
    [super dealloc];
}

@end

@implementation NSObject (extension)

SHARED_IMPL;

- (void)pass {
    PASS;
}

- (void*)pointerValue {
    return self;
}

- (void)updateData {
    PASS;
}

- (void)setNeedsUpdateData {
    [self updateData];
}

+ (instancetype)temporary {
    return [[[[self class] alloc] init] autorelease];
}

# ifdef DEBUG_MODE

- (id)unsafeClone {
    id ret = [[[[self class] alloc] init] autorelease];
    [ret loadProperties:self.propertyValues];
    return ret;
}

# endif

- (BOOL)existsProperty:(NSString *)property {
    Class cls = [self class];
    objc_property_t prop = class_getProperty(cls, property.UTF8String);
    return prop != NULL;
}

- (instancetype)obeyClass:(Class)cls {
    if ([self isKindOfClass:cls])
        return self;
    return nil;
}

static void* __s_nsobject_attachment_key;

- (NSAttachment*)attachment {
    NSAttachment* attachment = nil;
    SYNCHRONIZED_BEGIN
    attachment = objc_getAssociatedObject(self, &__s_nsobject_attachment_key);
    if (attachment == nil) {
        attachment = [[NSAttachment alloc] init];
        objc_setAssociatedObject(self, &__s_nsobject_attachment_key, attachment, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        SAFE_RELEASE(attachment);
    }
    SYNCHRONIZED_END
    return attachment;
}

- (instancetype)consign {
    return [[self retain] autorelease];
}

- (instancetype)clone {
    return [[self copy] autorelease];
}

- (id)autodrop {
    return [self autorelease];
}

- (id)grabRef {
    return [self retain];
}

- (void)dropRef {
    [self release];
}

- (NSDictionary*)propertyValues {
    return [self propertyValuesOfClass:[self class]];
}

- (NSDictionary*)encodablePropertyValues {
    NSDictionary* dict = self.propertyValues;
    return [dict dictionaryWithCollect:^id(id key, id val) {
        if ([val conformsToProtocol:@protocol(NSCoding)])
            return val;
        return nil;
    }];
}

- (NSDictionary*)propertyValuesOfClass:(Class)cls {
    NSMutableDictionary* ret = [NSMutableDictionary dictionary];
    
    if (cls == nil)
        cls = [self class];
    
    uint szprops;
    objc_property_t* props = class_copyPropertyList(cls, &szprops);
    for (uint i = 0; i < szprops; ++i) {
        char const* propName = property_getName(props[i]);
        NSString* strPropName = [NSString stringWithCString:propName encoding:NSASCIIStringEncoding];
        
        id propObj = [self valueForKey:strPropName];
        if (propObj == nil)
            continue;
        
        [ret setObject:propObj
                forKey:strPropName];
    }
    free(props);
    
    return ret;
}

- (void)loadPropertiesOfObject:(id)obj {
    return [self loadPropertiesOfObject:obj ofClass:[obj class]];
}

- (void)loadPropertiesOfObject:(id)obj ofClass:(Class)cls {
    if (cls == nil)
        cls = [obj class];
    id pvs = [obj propertyValuesOfClass:cls];
    [self loadProperties:pvs];
}

- (void)loadProperties:(NSDictionary*)dict {
    for (NSString* each in dict.allKeys) {
        id value = [dict valueForKey:each];
        @try {
            [self setValue:value forKey:each];
        } @catch (NSException* excp) {
            //[excp log];
        }
    }
}

- (void)foreachProperty:(BOOL(^)(id key, id value))block {
    Class cls = [self class];
    uint szprops;
    objc_property_t* props = class_copyPropertyList(cls, &szprops);
    for (uint i = 0; i < szprops; ++i) {
        char const* propName = property_getName(props[i]);
        NSString* strPropName = [NSString stringWithCString:propName encoding:NSASCIIStringEncoding];
        id propObj = [self valueForKey:strPropName];
        if (block(strPropName, propObj) == NO)
            break;
    }
    free(props);
}

- (void)iteratorProperty:(IteratorType (^)(id key, id value))block {
    if (block(nil, self) == kIteratorTypeBreak)
        return;

    Class cls = [self class];
    [NSClass ForeachProperty:^BOOL(objc_property_t *prop) {
        char const* propName = property_getName(*prop);
        NSString* strPropName = [NSString stringWithCString:propName encoding:NSASCIIStringEncoding];
        id propObj = [[self valueForKey:strPropName] consign];
        IteratorType ret = block(strPropName, propObj);
        
        if (ret == kIteratorTypeBreak)
            return NO;
        
        if ([propObj isKindOfClass:[NSArray class]]) {
            for (id each in propObj) {
                [each iteratorProperty:block];
            }
        } else if ([propObj isKindOfClass:[NSDictionary class]]) {
            for (id each in [propObj allValues]) {
                [each iteratorProperty:block];
            }
        }

        if (ret == kIteratorTypeOk)
            [propObj iteratorProperty:block];
        
        return YES;
    } forClass:cls];
}

- (id)valueForKeyPath:(NSString *)path def:(id)def {
    id ret = nil;
    @try {
        ret = [self valueForKeyPath:path];
    }
    @catch (NSException *exception) {
        //[exception log];
    }
    
    if (ret == nil)
        return def;
    
    return ret;
}

- (void)performSoleSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:aSelector object:anArgument];
    [self performSelector:aSelector withObject:anArgument afterDelay:delay];
}

- (void)performSyncSelector:(SEL)aSelector withObject:(id)anArgument {
    //LOG("%x +++++++++++++", self);
    SYNCHRONIZED_BEGIN
    [self performSelector:aSelector withObject:anArgument];
    SYNCHRONIZED_END
    //LOG("%x -------------", self);
}

- (BOOL)tryPerformSelector:(SEL)aSelector withObject:(id)anArgument {
    if ([self respondsToSelector:aSelector]) {
        [self performSelector:aSelector withObject:anArgument];
        return YES;
    }
    return NO;
}

- (NSString*)jsonString {
    NSData* da = nil;
# ifdef DEBUG_MODE
    NSError* err = nil;
    @try {
        da = [NSJSONSerialization dataWithJSONObject:self
                                             options:NSJSONWritingPrettyPrinted
                                               error:&err];
    } @catch (NSException* e) { [e log]; };
    if (err)
        [err log];
# else
    @try {
        da = [NSJSONSerialization dataWithJSONObject:self
                                             options:0
                                               error:nil];
    } @catch (NSException* e) { [e log]; };
# endif
    return [NSString stringWithData:da encoding:NSUTF8StringEncoding];
}

- (void)onInit {
# ifdef DEBUG_MODE
    [[NSTrailChange shared] objectIsIniting:self];
# endif
}

- (void)onFin {
# ifdef DEBUG_MODE
    [[NSTrailChange shared] objectIsFining:self];
# endif
}

- (NSString*)keyForResuableObject:(id<NSCopying>)idr {
    return [NSString stringWithFormat:@"::ns::resuable::%@", [(id)idr description]];
}

- (id)reusableObject:(id<NSCopying>)idr {
    return [self.attachment.strong objectForKey:[self keyForResuableObject:idr]];
}

- (id)reusableObject:(id<NSCopying>)idr def:(id)def {
    return [self.attachment.strong objectForKey:[self keyForResuableObject:idr] def:def];
}

- (void)reusableObject:(id<NSCopying>)idr set:(id)set {
    id key = [self keyForResuableObject:idr];
    if (set == nil)
        [self.attachment.strong popObjectForKey:key def:nil];
    else
        [self.attachment.strong setObject:set forKey:key];
}

- (id)reusableObject:(id<NSCopying>)idr instance:(id(^)())instance {
    id ret = [self reusableObject:idr];
    if (ret)
        return ret;
    ret = instance();
    if (ret == nil)
        return ret;
    [self.attachment.strong setObject:ret forKey:[self keyForResuableObject:idr]];
    return ret;
}

- (id)reusableObject:(id<NSCopying>)idr type:(Class)type {
    return [self reusableObject:idr instance:^id{
        return [[[type alloc] init] autorelease];
    }];
}

- (id)objectWithProcess:(id(^)(id, id))block ofTarget:(id)target {
    return block(self, target);
}

- (instancetype)me:(void(^)(id _self))block {
    block(self);
    return self;
}

- (void)type:(Class)cls process:(void(^)(id))process {
    if ([self isKindOfClass:cls] == NO)
        return;
    process(self);
}

- (NSInteger)copyToMem:(void*)mem {
    return 0;
}

+ (BOOL)IsEqual:(id)l to:(id)r {
    if (l == r)
        return YES;
    if (l == nil)
        return NO;
    return [l isEqual:r];
}

@end

@interface NSMemObject ()
{
    BOOL _release;
}

@end

@implementation NSMemObject

+ (instancetype)mem:(void*)ptr needfree:(BOOL)needfree {
    NSMemObject* ret = [[self alloc] init];
    ret->_ptr = ptr;
    ret->_release = needfree;
    return [ret autorelease];
}

+ (instancetype)allocmem:(NSInteger)size {
    return [self.class mem:malloc(size) needfree:YES];
}

+ (instancetype)allocmem:(NSInteger)count type:(NSInteger)type {
    return [self allocmem:count*type];
}

- (void)dealloc {
    if (_release) {
        free(_ptr);
        _ptr = NULL;
    }
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    NSMemObject* ret = [[self.class alloc] init];
    ret->_ptr = self.ptr;
    if (_release) {
        _release = NO;
        ret->_release = YES;
    }
    return ret;
}

@end

@implementation NSForwardObject

- (id)init {
    self = [super init];
    return self;
}

- (id)initWithObject:(id)object {
    self = [super init];
    self.object = object;
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_object);
    [super dealloc];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return _object;
}

+ (instancetype)object:(id)object {
    return [[[self alloc] initWithObject:object] autorelease];
}

- (NSString*)description {
    return [self.object description];
}

- (id)copyWithZone:(NSZone *)zone {
    NSForwardObject* ret = [[[self class] alloc] init];
    SAFE_COPY(ret.object, _object);
    return ret;
}

- (BOOL)isEqual:(id)object {
    return [self.object isEqual:object];
}

- (NSUInteger)hash {
    return [self.object hash];
}

@end

@implementation NSPropertyString @end

@implementation NSBlockObject

- (void)dealloc {
    Block_release(_block);
    [super dealloc];
}

+ (instancetype)block:(id)block {
    NSBlockObject* ret = [[self class] temporary];
    ret.block = (common_block_t)block;
    return ret;
}

@end

@implementation NSMutableData (extension)

- (NSMutableData*)appendInt:(int)val {
    [self appendBytes:&val length:sizeof(int)];
    return self;
}

- (NSMutableData*)appendByte:(Byte)val {
    [self appendBytes:&val length:sizeof(Byte)];
    return self;
}

- (NSMutableData*)appendCString:(char const*)str {
    int len = (int)strlen(str);
    [self appendBytes:str length:len];
    return self;
}

- (NSMutableData*)appendString:(NSString*)str encoding:(NSStringEncoding)encoding {
    NSData* strdata = [str dataUsingEncoding:encoding];
    [self appendData:strdata];
    return self;
}

@end

@implementation NSData (extension)

- (id)initWithContentsOfDataSource:(NSDataSource*)ds {
    if (ds.url.notEmpty)
        return [self initWithContentsOfURL:ds.url];
    if (ds.bundle.notEmpty) {
        NSString* file = [[FSApplication shared] pathBundle:ds.bundle];
        return [self initWithContentsOfFile:file];
    }
    [self release];
    return nil;
}

+ (NSData*)dataWithContentsOfDataSource:(NSDataSource*)ds {
    return [[[[self class] alloc] initWithContentsOfDataSource:ds] autorelease];
}

static NSString* __gstbl_hex2char[] = {
    @"00", @"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"0a", @"0b", @"0c", @"0d", @"0e", @"0f",
    @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"1a", @"1b", @"1c", @"1d", @"1e", @"1f",
    @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"2a", @"2b", @"2c", @"2d", @"2e", @"2f",
    @"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39", @"3a", @"3b", @"3c", @"3d", @"3e", @"3f",
    @"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49", @"4a", @"4b", @"4c", @"4d", @"4e", @"4f",
    @"50", @"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59", @"5a", @"5b", @"5c", @"5d", @"5e", @"5f",
    @"60", @"61", @"62", @"63", @"64", @"65", @"66", @"67", @"68", @"69", @"6a", @"6b", @"6c", @"6d", @"6e", @"6f",
    @"70", @"71", @"72", @"73", @"74", @"75", @"76", @"77", @"78", @"79", @"7a", @"7b", @"7c", @"7d", @"7e", @"7f",
    @"80", @"81", @"82", @"83", @"84", @"85", @"86", @"87", @"88", @"89", @"8a", @"8b", @"8c", @"8d", @"8e", @"8f",
    @"90", @"91", @"92", @"93", @"94", @"95", @"96", @"97", @"98", @"99", @"9a", @"9b", @"9c", @"9d", @"9e", @"9f",
    @"a0", @"a1", @"a2", @"a3", @"a4", @"a5", @"a6", @"a7", @"a8", @"a9", @"aa", @"ab", @"ac", @"ad", @"ae", @"af",
    @"b0", @"b1", @"b2", @"b3", @"b4", @"b5", @"b6", @"b7", @"b8", @"b9", @"ba", @"bb", @"bc", @"bd", @"be", @"bf",
    @"c0", @"c1", @"c2", @"c3", @"c4", @"c5", @"c6", @"c7", @"c8", @"c9", @"ca", @"cb", @"cc", @"cd", @"ce", @"cf",
    @"d0", @"d1", @"d2", @"d3", @"d4", @"d5", @"d6", @"d7", @"d8", @"d9", @"da", @"db", @"dc", @"dd", @"de", @"df",
    @"e0", @"e1", @"e2", @"e3", @"e4", @"e5", @"e6", @"e7", @"e8", @"e9", @"ea", @"eb", @"ec", @"ed", @"ee", @"ef",
    @"f0", @"f1", @"f2", @"f3", @"f4", @"f5", @"f6", @"f7", @"f8", @"f9", @"fa", @"fb", @"fc", @"fd", @"fe", @"ff"
};

- (NSString*)hexStringValue {
    byte const* p = (byte const*)self.bytes;
    size_t l = self.length;
    NSMutableString* str = [NSMutableString stringWithCapacity:l + l];
    while (l--)
    {
        [str appendString:__gstbl_hex2char[*p++]];
    }
    return str;
}

- (NSString*)base64 {
    return [self base64EncodedString];
}

@end

@implementation NSStreamData

@synthesize offset = _offset;

- (id)initWithData:(NSData *)data {
    self = [super init];
    
    _data = [data retain];
    _offset = 0;
    
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_data);
    
    [super dealloc];
}

- (NSInteger)lengthLeft {
    return _data.length - _offset;
}

- (void*)bytesLeft {
    return (Byte*)_data.bytes + _offset;
}

- (BOOL)readInt:(int *)val {
    if (self.lengthLeft < sizeof(int))
        return NO;
    *val = *(int*)self.bytesLeft;
    _offset += sizeof(int);
    return YES;
}

- (BOOL)readInteger:(NSInteger*)val {
    if (self.lengthLeft < sizeof(NSInteger))
        return NO;
    *val = *(NSInteger*)self.bytesLeft;
    _offset += sizeof(NSInteger);
    return YES;
}

- (BOOL)readFloat:(float*)val {
    if (self.lengthLeft < sizeof(float))
        return NO;
    *val = *(float*)self.bytesLeft;
    _offset += sizeof(float);
    return YES;
}

- (BOOL)readDouble:(double*)val {
    if (self.lengthLeft < sizeof(double))
        return NO;
    *val = *(double*)self.bytesLeft;
    _offset += sizeof(double);
    return YES;
}

- (BOOL)readReal:(real*)val {
    if (self.lengthLeft < sizeof(real))
        return NO;
    *val = *(real*)self.bytesLeft;
    _offset += sizeof(real);
    return YES;
}

- (BOOL)readByte:(Byte *)val {
    if (self.lengthLeft < sizeof(Byte))
        return NO;
    *val = *(Byte*)self.bytesLeft;
    _offset += sizeof(Byte);
    return YES;
}

- (NSData*)readData:(NSInteger)length {
    if (self.lengthLeft < length)
        return nil;
    
    NSData* ret = [NSData dataWithBytes:self.bytesLeft length:length];
    _offset += length;
    
    return ret;
}

@end

NSCLASS_SUBCLASS(_NSMutableDictionaryQuearray, NSForwardObject);

@implementation NSMutableDictionary (extension)

- (instancetype)setInt:(int)val forKey:(id)key {
    [self setObject:[NSNumber numberWithInt:val] forKey:key];
    return self;
}

- (instancetype)setFloat:(float)val forKey:(id)key {
    [self setObject:[NSNumber numberWithFloat:val] forKey:key];
    return self;
}

- (instancetype)setDouble:(double)val forKey:(id)key {
    [self setObject:[NSNumber numberWithDouble:val] forKey:key];
    return self;
}

- (instancetype)setBool:(bool)val forKey:(id)key {
    [self setObject:[NSNumber numberWithBool:val] forKey:key];
    return self;
}

- (instancetype)setTimestamp:(time_t)v forKey:(id)key {
    [self setObject:[NSNumber numberWithTimestamp:v] forKey:key];
    return self;
}

- (void)setObject:(id)anObject forKey:(id)aKey def:(id)def {
    if (anObject == nil)
        anObject = def;
    if (anObject == nil)
        return;
    
    [self setObject:anObject forKey:aKey];
}

- (void)setValue:(id)anObject forKey:(NSString *)aKey def:(id)def {
    if (anObject == nil)
        anObject = def;
    if (anObject == nil)
        return;
    
    [self setValue:anObject forKey:aKey];
}

- (void)setObject:(id)anObject forInt:(NSInteger)idx {
    [self setObject:anObject forKey:[NSNumber numberWithInteger:idx]];
}

- (void)setObjectsFromDictionary:(NSDictionary*)dict {
    for (id key in dict.allKeys) {
        id val = [dict objectForKey:key];
        [self setObject:val forKey:key];
    }
}

- (void)removeObjectForInt:(NSInteger)idx {
    [self removeObjectForKey:[NSNumber numberWithInteger:idx]];
}

- (void)removeObjectByFilter:(BOOL(^)(id k, id v))block {
    NSMutableArray* arr = [NSMutableArray array];
    for (id k in self.allKeys) {
        id v = [self objectForKey:k];
        if (block(k, v))
            [arr addObject:k];
    }
    [self removeObjectsForKeys:arr];
}

- (void)removeObjectByKeyFilter:(BOOL(^)(id k))block {
    NSMutableArray* arr = [NSMutableArray array];
    for (id k in self.allKeys) {
        if (block(k))
            [arr addObject:k];
    }
    [self removeObjectsForKeys:arr];
}

- (id)popObjectForKey:(id)key {
    id obj = [self objectForKey:key];
    if (obj)
        [obj consign];
    [self removeObjectForKey:key];
    return obj;
}

- (void)pushQueObject:(id)anObject forKey:(id)aKey {
    id obj = [self objectForKey:aKey];
    
    // 不存在，则直接设置
    if (obj == nil) {
        [self setObject:anObject forKey:aKey];
        return;
    }
    
    // 存在并且为 quearray
    if ([obj isKindOfClass:[_NSMutableDictionaryQuearray class]]) {
        [(NSMutableArray*)obj addObject:anObject];
        return;
    }
    
    // 存在但是不是 quearray，则新建一个，把之前存在的和 anObject 都放进去
    _NSMutableDictionaryQuearray* tmp = [_NSMutableDictionaryQuearray object:[NSMutableArray temporary]];
    [(NSMutableArray*)tmp addObject:obj];
    [(NSMutableArray*)tmp addObject:anObject];
    [self setObject:tmp forKey:aKey];
}

- (id)popQueObjectForKey:(id)aKey {
    id obj = [self objectForKey:aKey];
    if (obj == nil)
        return obj;
    
    if ([obj isKindOfClass:[_NSMutableDictionaryQuearray class]] == NO) {
        return [self popObjectForKey:aKey];
    }
    
    _NSMutableDictionaryQuearray* ms = obj;
    return [(NSMutableArray*)ms pop];
}

- (BOOL)existsQueObject:(id)anObject forKey:(id)aKey {
    id obj = [self objectForKey:aKey];
    if (obj == nil)
        return NO;
    
    if ([obj isKindOfClass:[_NSMutableDictionaryQuearray class]] == NO) {
        return [NSObject IsEqual:obj to:anObject];
    }
    
    _NSMutableDictionaryQuearray* ms = obj;
    return [(NSMutableArray*)ms containsObject:anObject];
}

- (void)swapObjectByKey:(id)aKey withKey:(id)toKey {
    id obj0 = [[self objectForKey:aKey] retain];
    id obj1 = [[self objectForKey:toKey] retain];
    if (obj0) {
        [self setObject:obj0 forKey:toKey];
        if (obj1 == nil)
            [self removeObjectForKey:aKey];
    }
    if (obj1) {
        [self setObject:obj1 forKey:aKey];
        if (obj0 == nil)
            [self removeObjectForKey:toKey];
    }
    [obj0 release];
    [obj1 release];
}

- (id)objectForKey:(id)aKey instance:(id(^)())instance {
    id obj = [self objectForKey:aKey def:nil];
    if (obj != nil)
        return obj;
    obj = instance();
    [self setObject:obj forKey:aKey];
    return obj;
}

- (id)objectForKey:(id)aKey instanceType:(Class)type {
    return [self objectForKey:aKey instance:^id{
        return [type temporary];
    }];
}

+ (instancetype)restrict:(id)obj {
    if (obj == nil)
        return [NSMutableDictionary dictionary];
    if ([obj isKindOfClass:[NSMutableDictionary class]])
        return obj;
    if ([obj isKindOfClass:[NSDictionary class]])
        return [NSMutableDictionary dictionaryWithDictionary:obj];
    return nil;
}

- (void)replaceAllValues:(id (^)(id, id))replacement {
    NSMutableDictionary* tmp = [NSMutableDictionary dictionaryWithCapacity:self.count];
    for (id key in self) {
        id val = self[key];
        id o = replacement(key, val);
        if (o)
            tmp[key] = o;
    }
    [self removeAllObjects];
    [self addEntriesFromDictionary:tmp];
}

@end

@implementation NSDictionary (extension)

- (instancetype)clone {
    return [self.class dictionaryWithDictionary:self];
}

+ (instancetype)dictionaryFromArray:(NSArray *)arr keyConverter:(id (^)(id))keyConverter valueConverter:(id (^)(id))valueConverter {
    return [[self class] dictionaryFromArray:arr keyConverter:keyConverter valueConverter:valueConverter multi:NO];
}

+ (instancetype)dictionaryFromArray:(NSArray*)arr keyConverter:(id(^)(id))keyConverter valueConverter:(id(^)(id))valueConverter multi:(BOOL)multi {
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:arr.count];
    for (id each in arr) {
        id key = keyConverter(each);
        id val = valueConverter(each);
        if (key && val) {
            if (multi) {
                NSMutableArray* arr = [dict objectForKey:key];
                if (arr == nil) {
                    arr = [NSMutableArray temporary];
                    [dict setObject:arr forKey:key];
                }
                [arr addObject:val];
            } else {
                [dict setObject:val forKey:key];
            }
        }
    }
    return dict;
}

- (BOOL)exists:(id<NSCopying>)key {
    return [self objectForKey:key] != nil;
}

- (void)foreach:(IteratorType(^)(id key, id obj))block {
    for (id key in self.allKeys) {
        id val = [self objectForKey:key];
        if (block(key, val) == kIteratorTypeBreak)
            break;
    }
}

- (id)objectForKey:(id)aKey def:(id)def {
    id ret = [self objectForKey:aKey];
    if (ret == nil)
        return def;
    return ret;
}

- (id)valueForKey:(NSString *)key def:(id)def {
    id ret = [self valueForKey:key];
    if (ret == nil)
        return def;
    return ret;
}

- (int)getInt:(id<NSCopying>)key {
    return [self getInt:key def:0];
}

- (int)getInt:(id<NSCopying>)key def:(int)def {
    id obj = [self objectForKey:key];
    if (obj == nil)
        return def;
    return [obj intValue];
}

- (float)getFloat:(id<NSCopying>)key {
    return [self getFloat:key def:0];
}

- (float)getFloat:(id<NSCopying>)key def:(float)def {
    id obj = [self objectForKey:key];
    if (obj == nil)
        return def;
    return [obj floatValue];
}

- (double)getDouble:(id<NSCopying>)key {
    return [self getDouble:key def:0];
}

- (double)getDouble:(id<NSCopying>)key def:(double)def {
    id obj = [self objectForKey:key];
    if (obj == nil)
        return def;
    return [obj doubleValue];
}

- (BOOL)getBool:(id<NSCopying>)key {
    return [self getBool:key def:false];
}

- (BOOL)getBool:(id<NSCopying>)key def:(BOOL)def {
    id obj = [self objectForKey:key];
    if (obj == nil)
        return def;
    return [obj boolValue];
}

- (time_t)getTimestamp:(id<NSCopying>)key def:(time_t)def {
    id obj = [self objectForKey:key];
    if (obj == nil)
        return def;
    return [obj timestampValue];
}

- (NSString*)getString:(id<NSCopying>)key {
    return [self getString:key def:@""];
}

- (NSString*)getString:(id<NSCopying>)key def:(NSString *)def {
    id obj = [self objectForKey:key];
    if (obj == nil)
        return def;
    return [obj stringValue];
}

- (NSArray*)getArray:(id<NSCopying>)key {
    return [self getArray:key def:nil];
}

- (NSArray*)getArray:(id<NSCopying>)key def:(NSArray *)def {
    id ret = [self objectForKey:key];
    if (ret == nil)
        return def;
    ret = [ret obeyClass:[NSArray class]];
    if (ret == nil)
        return def;
    return ret;
}

- (NSDictionary*)getDictionary:(id<NSCopying>)key {
    return [self getDictionary:key def:nil];
}

- (NSDictionary*)getDictionary:(id<NSCopying>)key def:(NSDictionary*)def {
    id ret = [self objectForKey:key];
    if (ret == nil)
        return def;
    ret = [ret obeyClass:[NSDictionary class]];
    if (ret == nil)
        return def;
    return ret;
}

- (id)initWithObject:(id)obj forKey:(id)key {
    return [self initWithObjectsAndKeys:obj, key, nil];
}

- (id)objectForKeySafe:(id<NSCopying>)key {
    id ret = [self objectForKey:key];
    if ([ret isKindOfClass:[NSNull class]])
        return nil;
    return ret;
}

- (id)objectForInt:(NSInteger)idx {
    return [self objectForKeySafe:[NSNumber numberWithInteger:idx]];
}

- (NSArray*)allValuesSafe {
    return [self.allValues arrayWithFilter:^BOOL(id l) {
        return [l isKindOfClass:[NSNull class]] == NO;
    }];
}

+ (instancetype)restrict:(id)obj {
    if ([obj isKindOfClass:[NSDictionary class]])
        return obj;
    if ([obj isKindOfClass:[NSMutableDictionary class]])
        return obj;
    return nil;
}

- (NSPair*)objectAtIndex:(NSInteger)idx {
    if (idx >= self.count)
        return nil;
    
    NSEnumerator* ekey = self.keyEnumerator;
    id key = nil;
    for (int i = 0; i <= idx; ++i) {
        key = ekey.nextObject;
    }
    id val = self[key];
    return [NSPair pairFirst:key Second:val];
}

- (NSArray*)objectsForQueryPath:(NSString*)query {
    return [self objectsForQueryPath:query def:nil];
}

- (NSArray*)objectsForQueryPath:(NSString*)query def:(NSArray*)def {
    // 格式为 . 隔开的正则式，例如 abc.cde
    NSRegularExpression* rex = [NSRegularExpression cachedRegularExpressionWithPattern:@"([a-zA-Z0-9\\[\\]\\-\\+\\*]+)"];
    NSArray* comps = [rex capturesInString:query];
    if (comps.count == 0)
        return def;
    // 一次一层的执行
    NSMutableArray* res = [NSMutableArray arrayWithObject:self];
    for (NSString* comp in comps) {
        NSMutableArray* tmp = [NSMutableArray temporary];
        for (id obj in res) {
            if ([obj isKindOfClass:[NSDictionary class]] == NO)
                continue;
            [tmp addObjectsFromArray:[(NSDictionary*)obj objectsForQuery:comp]];
        }
        res = tmp;
    }
    if (res.count == 0)
        return def;
    return res;
}

- (NSArray*)objectsForQuery:(NSString*)query {
    return [self objectsForQuery:query def:nil];
}

- (NSArray*)objectsForQuery:(NSString*)query def:(NSArray*)def {
    NSRegularExpression* rex = [NSRegularExpression regularExpressionWithPattern:query];
    NSMutableArray* ret = [NSMutableArray temporary];
    for (NSString* key in self.allKeys) {
        if ([rex isMatchs:key]) {
            id val = [self objectForKey:key];
            [ret addObject:val];
        }
    }
    if (ret.count == 0)
        return def;
    return ret;
}

- (NSArray*)valuesOfSortedKeys {
    NSArray* keys = [self.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    return [self objectsForKeys:keys notFoundMarker:[NSNull null]];
}

- (NSDictionary*)dictionaryWithCollect:(id(^)(id key, id val))collect {
    NSMutableDictionary* dict = [NSMutableDictionary temporary];
    [self foreach:^IteratorType(id key, id obj) {
        id o = collect(key, obj);
        if (o)
            [dict setObject:o forKey:key];
        return kIteratorTypeOk;
    }];
    return dict;
}

@end

@implementation NSArray (extension)

- (instancetype)clone {
    return [self.class arrayWithArray:self];
}

- (void)foreach:(BOOL(^)(id obj))block {
    for (id each in self) {
        if (block(each) == NO)
            break;
    }
}

- (void)foreachWithIndex:(BOOL(^)(id obj, NSInteger idx))block {
    NSInteger idx = 0;
    for (id each in self) {
        if (block(each, idx++) == NO)
            break;
    }
}

- (void)foreach:(BOOL(^)(id obj))block forClass:(Class)cls {
    for (id each in self) {
        if ([each isKindOfClass:cls] == NO)
            continue;
        if (block(each) == NO)
            break;
    }
}

- (void)foreach:(IteratorType(^)(id))block sepdo:(void (^)(id))sepdo {
    int count = 0, max = self.count;
    while (count < max)
    {
        id obj = [self objectAtIndex:count];
        IteratorType it = block(obj);
        if (it == kIteratorTypeBreak)
            break;
        
        ++count;
        if (it == kIteratorTypeNext)
            continue;
        
        if (count < max)
            sepdo(obj);
    }
}

- (void)foreach:(IteratorType (^)(id first))firstb next:(IteratorType (^)(id second))secondb {
    int count = 0, max = self.count;
    while (count < max)
    {
        id obj = [self objectAtIndex:count++];
        IteratorType it = firstb(obj);
        if (it == kIteratorTypeBreak)
            break;
        if (it == kIteratorTypeNext)
            continue;
        
        id nobj = [self objectAtIndex:count++ def:nil];
        if (nobj == nil)
            break;
        
        it = secondb(nobj);
        if (it == kIteratorTypeBreak)
            break;
        if (it == kIteratorTypeNext)
            continue;
    }
}

- (void)foreach:(IteratorType (^)(id obj, NSInteger idx))block range:(NSRange)range overflow:(BOOL)of def:(id)def {
    for (NSUInteger idx = 0; idx < range.length; ++idx)
    {
        NSUInteger tgt = idx + range.location;
        if (tgt > self.count && !of)
            break;
        
        id obj = [self objectAtIndex:tgt def:def];
        IteratorType it = block(obj, tgt);
        if (it == kIteratorTypeBreak)
            break;
    }
}

- (void)foreach:(IteratorType (^)(id obj, NSInteger idx))block range:(NSRange)range {
    for (NSUInteger idx = range.location;
         idx < self.count && range.length--;
         ++idx)
    {
        id obj = [self objectAtIndex:idx];
        IteratorType it = block(obj, idx);
        if (it == kIteratorTypeBreak)
            break;
    }
}

- (void)foreach:(IteratorType (^)(id obj, NSInteger idx))block notIn:(NSArray*)des {
    NSArray* arr = [self arrayByRemoveObjects:des];
    NSInteger idx = 0;
    for (id each in arr) {
        IteratorType it = block(each, idx++);
        if (it == kIteratorTypeBreak)
            break;
    }
}

- (void)foreach:(IteratorType (^)(id obj, NSInteger idx))normal end:(IteratorType (^)(id obj, NSInteger idx))end {
    NSInteger const count = self.count;
    NSInteger const endc = count - 1;
    for (NSInteger i = 0; i < count; ++i) {
        id obj = [self objectAtIndex:i];
        IteratorType it;
        if (i == endc)
            it = end(obj, i);
        else
            it = normal(obj, i);
        if (it == kIteratorTypeBreak)
            break;
    }
}

- (void)stepWithArray:(NSArray*)arr each:(IteratorType (^)(id my, id other, NSInteger idx))block {
    int const min = MIN(self.count, arr.count);
    for (int i = 0; i < min; ++i) {
        id my = [self objectAtIndex:i];
        id other = [arr objectAtIndex:i];
        IteratorType it = block(my, other, i);
        if (it == kIteratorTypeBreak)
            break;
    }
}

- (void)foreachWithArray:(NSArray*)arr step:(IteratorType (^)(id my, id other, NSInteger idx))block {
    [self foreachWithArray:arr step:block def:nil];
}

- (void)foreachWithArray:(NSArray*)arr step:(IteratorType (^)(id my, id other, NSInteger idx))block def:(id)def {
    int const max = MAX(self.count, arr.count);
    for (int i = 0; i < max; ++i) {
        id my = [self objectAtIndex:i def:def];
        id other = [arr objectAtIndex:i def:def];
        IteratorType it = block(my, other, i);
        if (it == kIteratorTypeBreak)
            break;
    }
}

+ (id)arrayWithArrays:(NSArray*)arr, ... {
    va_list va;
    va_start(va, arr);
    id ret = [self arrayWithArrays:arr arg:va];
    va_end(va);
    return ret;
}

+ (id)arrayWithArrays:(NSArray *)arr arg:(va_list)arg {
    NSMutableArray* mut = [NSMutableArray array];
    [mut addObjectsFromArray:arr];
    
    NSArray* tmp = va_arg(arg, NSArray*);
    while (tmp != nil) {
        [mut addObjectsFromArray:tmp];
        tmp = va_arg(arg, NSArray*);
    }
    
    return mut;
}

+ (id)arrayFromDictionary:(NSDictionary*)dict byConverter:(id(^)(id key, id val))converter {
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:dict.count];
    for (id key in dict) {
        id val = dict[key];
        id obj = converter(key, val);
        if (obj)
            [arr addObject:obj];
    }
    return arr;
}

+ (instancetype)arrayWithRange:(NSRange)range {
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:range.length];
    for (int i = 0; i < range.length; ++i) {
        [arr addObject:@(range.location + i)];
    }
    return arr;
}

+ (instancetype)arrayWithCount:(NSInteger)count Objects:(id)firstObj, ... {
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:count];
    va_list va;
    va_start(va, firstObj);
    [arr addObject:firstObj def:nil];
    while (--count) {
        [arr addObject:va_arg(va, id) def:nil];
    }
    va_end(va);
    return arr;
}

+ (instancetype)arrayWithCount:(NSInteger)count instance:(id(^)(NSInteger idx))ins {
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i = 0; i < count; ++i) {
        [arr addObject:ins(i)];
    }
    return arr;
}

+ (instancetype)arrayWithRange:(NSRange)rgn instance:(id(^)(NSInteger idx))ins {
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:rgn.length];
    for (NSInteger i = 0; i < rgn.length; ++i) {
        [arr addObject:ins(i + rgn.location)];
    }
    return arr;
}

- (id)arrayWithFilter:(BOOL(^)(id l))filter {
    NSMutableArray* mut = [NSMutableArray array];
    for (id each in self) {
        if (filter(each))
            [mut addObject:each];
    }
    return mut;
}

- (id)arrayWithCollector:(id(^)(id l))collector {
    NSMutableArray* mut = [NSMutableArray array];
    for (id each in self) {
        id obj = collector(each);
        if (obj == nil)
            continue;
        [mut addObject:obj];
    }
    return mut;
}

- (instancetype)arrayWithIndexedCollector:(id(^)(id l, NSInteger idx))collector {
    NSMutableArray* mut = [NSMutableArray array];
    NSInteger idx = 0;
    for (id each in self) {
        id obj = collector(each, idx++);
        if (obj == nil)
            continue;
        [mut addObject:obj];
    }
    return mut;
}

- (instancetype)arrayWithArray:(NSArray*)arr equal:(BOOL(^)(id l, id r))equal replace:(id(^)(id l, id r))replace {
    NSMutableArray* mut = [NSMutableArray array];
    for (id l in self) {
        for (id r in arr) {
            if (equal(l, r)) {
                id o = replace(l, r);
                if (o)
                    [mut addObject:o];
            }
        }
    }
    return mut;
}

- (instancetype)arrayWithArray:(NSArray*)arr collector:(id(^)(id l, id r, NSInteger idx))collector {
    NSInteger const count = MAX(self.count, arr.count);
    NSMutableArray* mut = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; ++i) {
        id l = [self objectAtIndex:i def:nil];
        id r = [arr objectAtIndex:i def:nil];
        id o = collector(l, r, i);
        if (o)
            [mut addObject:o];
    }
    return mut;
}

- (id)arrayByLimit:(NSInteger)count {
    NSMutableArray* mut = [NSMutableArray arrayWithCapacity:count];
    count = MIN(count, self.count);
    for (int i = 0; i < count; ++i) {
        [mut addObject:[self objectAtIndex:i]];
    }
    return mut;
}

- (instancetype)arrayByRange:(NSRange)rg {
    return [self arrayByRange:rg def:nil];
}

- (instancetype)arrayByRange:(NSRange)rg def:(id)def {
    NSMutableArray* mut = [NSMutableArray arrayWithCapacity:rg.length];
    for (int i = 0; i < rg.length; ++i) {
        id obj = [self objectAtIndex:(rg.location + i) def:def];
        if (obj == nil)
            break;
        [mut addObject:obj];
    }
    return mut;
}

- (instancetype)arrayByRemoveRange:(NSRange)rg {
    NSMutableArray* ret = [NSMutableArray array];
    NSUInteger maxl = NSMaxRange(rg);
    NSUInteger idx = 0;
    for (id obj in self) {
        if (idx < rg.location && idx < maxl)
            [ret addObject:obj];
        else if (idx >= maxl)
            [ret addObject:obj];
        ++idx;
    }
    return ret;
}

- (instancetype)arrayFromIndex:(NSInteger)idx {
    NSMutableArray* ret = [NSMutableArray array];
    for (NSInteger i = idx; i < self.count; ++i) {
        [ret addObject:[self objectAtIndex:i]];
    }
    return ret;
}

- (instancetype)arrayToIndex:(NSInteger)idx {
    NSMutableArray* ret = [NSMutableArray array];
    idx = MIN(idx, self.count);
    for (NSInteger i = 0; i < idx; ++i) {
        [ret addObject:[self objectAtIndex:i]];
    }
    return ret;
}

- (instancetype)arrayByRemoveObject:(id)obj {
    NSMutableArray* ret = [NSMutableArray arrayWithArray:self];
    [ret removeObject:obj];
    return ret;
}

- (instancetype)arrayByRemoveAllObjects:(id)obj {
    NSMutableArray* ret = [NSMutableArray arrayWithArray:self];
    [ret removeObjectsMatch:^BOOL(id o) {
        return [NSObject IsEqual:obj to:o];
    }];
    return ret;
}

- (instancetype)arrayByRemoveObjects:(NSArray*)objs {
    NSMutableArray* ret = [NSMutableArray arrayWithArray:self];
    [ret removeObjectsInArray:objs];
    return ret;
}

- (instancetype)arrayIntersects:(NSArray*)objs {
    NSMutableArray* ret = [NSMutableArray arrayWithCapacity:MAX(self.count, objs.count)];
    for (id each in self) {
        if ([objs containsObject:each])
            [ret addObject:each];
    }
    return ret;
}

- (instancetype)arrayByRemoveObject:(id)obj comparison:(BOOL (^)(id, id))comparison {
    NSMutableArray* ret = [NSMutableArray arrayWithCapacity:self.count];
    for (id each in self) {
        if (comparison(obj, each) == NO)
            [ret addObject:each];
    }
    return ret;
}

- (instancetype)arrayByInsertObject:(id)obj atIndex:(NSUInteger)idx {
    NSMutableArray* ret = [NSMutableArray arrayWithArray:self];
    [ret insertObject:obj atIndex:idx];
    return ret;
}

- (id)firstObject {
    return [self objectAtIndex:0 def:nil];
}

- (id)secondObject {
    return [self objectAtIndex:1 def:nil];
}

- (id)thirdObject {
    return [self objectAtIndex:2 def:nil];
}

- (id)fourthObject {
    return [self objectAtIndex:3 def:nil];
}

- (BOOL)containsClass:(Class)cls {
    return [self objectWithQuery:^id(id l) {
        if ([l isKindOfClass:cls])
            return l;
        return nil;
    }] != nil;
}

- (BOOL)containsObject:(id)anObject comparison:(BOOL(^)(id l, id anObject))comparison {
    for (id each in self) {
        if (comparison(each, anObject))
            return YES;
    }
    return NO;
}

- (id)deepCopy {
    NSMutableArray* arr = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (id each in self) {
        id o = [each copy];
        [arr addObject:o];
        SAFE_RELEASE(o);
    }
    id ret = [NSArray arrayWithArray:arr];
    SAFE_RELEASE(arr);
    return ret;
}

- (id)initWithObject:(id)object {
    return [self initWithObjects:object, nil];
}

- (id)initWithObject:(id)object count:(NSInteger)count {
    if (count > 0) {
        id objs[count];
        for (uint i = 0; i < count; ++i)
            objs[i] = object;
        return [self initWithObjects:objs count:count];
    }
    return [self init];
}

- (id)initWithTypes:(Class)type count:(NSInteger)count {
    return [self initWithTypes:type count:count init:nil];
}

- (instancetype)initWithTypes:(Class)type count:(NSInteger)count init:(void(^)(id, NSInteger))init {
    if (count > 0) {
        id tmps[count];
        for (uint i = 0; i < count; ++i) {
            tmps[i] = [[type alloc] init];
        }
        self = [self initWithObjects:tmps count:count];
        for (uint i = 0; i < count; ++i) {
            if (init)
                init(tmps[i], i);
            SAFE_RELEASE(tmps[i]);
        }
        return self;
    }
    return [self init];
}

- (instancetype)initWithInstance:(id (^)(NSInteger))block count:(NSInteger)count {
    if (count > 0) {
        id tmps[count];
        for (uint i = 0; i < count; ++i) {
            tmps[i] = block(i);
        }
        return [self initWithObjects:tmps count:count];
    }
    return [self init];
}

+ (id)arrayWithTypes:(Class)type count:(NSInteger)count {
    return [[[self alloc] initWithTypes:type count:count] autorelease];
}

+ (id)arrayWithTypes:(Class)type count:(NSInteger)count init:(void (^)(id, NSInteger))init {
    return [[[self alloc] initWithTypes:type count:count init:init] autorelease];
}

+ (instancetype)arrayWithObject:(id)anObject count:(NSInteger)count {
    return [[[self alloc] initWithObject:anObject count:count] autorelease];
}

+ (instancetype)arrayWithInstance:(id (^)(NSInteger))block count:(NSInteger)count {
    return [[[self alloc] initWithInstance:block count:count] autorelease];
}

- (id)objectAtIndexSafe:(NSUInteger)index {
    id ret = [self objectAtIndex:index];
    if ([ret isKindOfClass:[NSNull class]])
        return nil;
    return ret;
}

- (id)objectAtIndex:(NSUInteger)index def:(id)def {
    if (index >= self.count)
        return def;
    id ret = [self objectAtIndexSafe:index];
    if (ret == nil)
        return def;
    return ret;
}

- (id)objectAtIndex:(NSUInteger)index type:(Class)type {
    return [self objectAtIndex:index type:type def:nil];
}

- (id)objectAtIndex:(NSUInteger)index type:(Class)type def:(id)def {
    id ret = [self objectAtIndex:index def:def];
    if ([ret isKindOfClass:type])
        return ret;
    return def;
}

- (id)objectAtRIndex:(NSInteger)index {
    NSInteger idx = self.count - index - 1;
    return [self objectAtIndex:idx];
}

- (id)objectAtRIndex:(NSInteger)index def:(id)def {
    id ret = [self objectAtRIndex:index];
    if (ret == nil)
        ret = def;
    return ret;
}

- (int)intAtIndex:(NSUInteger)index def:(int)def {
    id obj = [self objectAtIndex:index def:nil];
    if (obj == nil)
        return def;
    return [obj intValue];
}

- (float)floatAtIndex:(NSUInteger)index def:(float)def {
    id obj = [self objectAtIndex:index def:nil];
    if (obj == nil)
        return def;
    return [obj floatValue];
}

- (id)objectWithComparison:(BOOL(^)(id l, id r))comparison {
    id l = self.firstObject;
    for (id each in self) {
        if (each == l)
            continue;
        
        if (comparison(l, each) == NO)
            l = each;
    }
    return l;
}

- (id)objectWithQuery:(id(^)(id l))query {
    id ret = nil;
    for (id each in self) {
        ret = query(each);
        if (ret)
            break;
    }
    return ret;
}

- (id)nextObject:(id)obj {
    return [self nextObject:obj def:nil];
}

- (id)nextObject:(id)obj def:(id)def {
    NSInteger idx = [self indexOfObject:obj];
    if (idx == NSNotFound)
        return def;
    if (idx == self.count - 1)
        return def;
    return [self objectAtIndex:idx + 1];
}

- (id)previousObject:(id)obj {
    return [self previousObject:obj def:nil];
}

- (id)previousObject:(id)obj def:(id)def {
    NSInteger idx = [self indexOfObject:obj];
    if (idx == NSNotFound)
        return def;
    if (idx == 0)
        return def;
    return [self objectAtIndex:idx - 1];
}

- (NSArray*)safeArray {
    NSMutableArray* ret = [NSMutableArray array];
    for (id each in self) {
        if ([each isKindOfClass:[NSNull class]])
            continue;
        [ret addObject:each];
    }
    return ret;
}

- (NSArray*)reversedArray {
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:self.count];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [ret addObject:element];
    }
    return ret;
}

- (NSArray*)disorderArray {
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:self.count];
    NSMutableArray *src = [NSMutableArray arrayWithArray:self];
    while (src.count) {
        NSInteger idx = [NSRandom valueBoundary:0 To:(src.count - 1)];
        id obj = [src objectAtIndex:idx];
        [ret addObject:obj];
        [src removeObjectAtIndex:idx];
    }
    return ret;
}

+ (id)arrayWithObjects:(id)firstObj arg:(va_list)arg {
    NSMutableArray* ret = [NSMutableArray array];
    [ret addObject:firstObj];
    id obj = va_arg(arg, id);
    while (obj) {
        [ret addObject:obj];
        obj = va_arg(arg, id);
    }
    return ret;
}

+ (id)arrayWithSet:(NSSet*)set {
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:set.count];
    for (id each in set) {
        [arr addObject:each];
    }
    return arr;
}

+ (id)SmallestArrayInArrays:(NSArray*)arr, ... {
    va_list va;
    va_start(va, arr);
    id ret = [self SmallestArrayInArrays:arr arg:va];
    va_end(va);
    return ret;
}

+ (id)SmallestArrayInArrays:(NSArray *)arr arg:(va_list)arg {
    int count = arr.count;
    id ret = arr;
    arr = va_arg(arg, NSArray*);
    while (arr) {
        if (arr.count < count) {
            count = arr.count;
            ret = arr;
        }
        arr = va_arg(arg, NSArray*);
    }
    return ret;
}

- (NSArray*)subarrayWithRange:(NSRange)range def:(id)def {
    if (range.location + range.length <= self.count)
        return [self subarrayWithRange:range];
    
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:range.length];
    for (int i = range.location; i < self.count; ++i)
        [arr addObject:[self objectAtIndex:i]];
    if (def) {
        int df = range.location + range.length - self.count;
        while (df--) {
            [arr addObject:def];
        }
    }
    return arr;
}

- (NSInteger)countByCollector:(NSInteger(^)(id))block {
    NSInteger ret = 0;
    for (id each in self) {
        ret += block(each);
    }
    return ret;
}

- (id)objectAtIndex:(NSInteger)index countSubArray:(NSInteger(^)(id))block collector:(id(^)(id, NSInteger))collector {
    for (id each in self) {
        NSInteger tgtcnt = block(each);
        if (index < tgtcnt)
            return collector(each, index);
        index -= tgtcnt;
    }
    return nil;
}

- (id)objectAtIndex:(NSInteger)index collector:(id(^)(id))block {
    id obj = [self objectAtIndex:index def:nil];
    return block(obj);
}

- (NSArray*)arrayUnique:(id(^)(id))block {
    NSMutableArray* ret = [NSMutableArray array];
    for (id each in self) {
        id o = block(each);
        if ([ret containsObject:o] == NO)
            [ret addObject:each];
    }
    return ret;
}

- (NSArray*)arrayUnique {
    return [self arrayUnique:^id(id o) {
        return o;
    }];
}

+ (instancetype)restrict:(id)obj {
    if ([obj isKindOfClass:[NSArray class]])
        return obj;
    if ([obj isKindOfClass:[NSMutableArray class]])
        return obj;
    return nil;
}

- (NSInteger)indexOfQuery:(BOOL(^)(id obj))query {
    return [self indexOfQuery:query def:NSNotFound];
}

- (NSInteger)indexOfQuery:(BOOL(^)(id obj))query def:(NSInteger)def {
    NSInteger idx = 0;
    for (id each in self) {
        if (query(each))
            return idx;
        ++idx;
    }
    return def;
}

- (NSInteger)copyToMem:(void*)mem {
    NSInteger ret = 0;
    for (id each in self) {
        ret += [each copyToMem:((Byte*)mem) + ret];
    }
    return ret;
}

- (NSInteger)boundary {
    NSInteger cnt = self.count;
    return TRIEXPRESS(cnt > 1, cnt - 1, 0);
}

@end

@implementation NSMutableArray (extension)

- (void)removeObjectsMatch:(BOOL(^)(id obj))match {
    NSMutableArray* matchs = [[NSMutableArray alloc] init];
    for (id each in self) {
        if (match(each))
            [matchs addObject:each];
    }
    [self removeObjectsInArray:matchs];
    SAFE_RELEASE(matchs);
}

- (void)removeObjectsMatch:(BOOL(^)(id l, id r))block withObject:(id)r {
    NSMutableArray* matchs = [[NSMutableArray alloc] init];
    for (id each in self) {
        if (block(each, r))
            [matchs addObject:each];
    }
    [self removeObjectsInArray:matchs];
    SAFE_RELEASE(matchs);
}

- (void)removeObjectsMatch:(BOOL (^)(id, id))block withObjects:(NSArray*)arr {
    for (id each in arr) {
        [self removeObjectsMatch:block withObject:each];
    }
}

- (NSArray*)removeObjectsNotIn:(NSArray*)arr {
    NSMutableArray* tmp = [NSMutableArray arrayWithArray:self];
    [tmp removeObjectsInArray:arr];
    [self removeObjectsInArray:tmp];
    return tmp;
}

- (NSArray*)removeObjectsNotIn:(NSArray*)arr removed:(void(^)(id))block {
    NSArray* tmp = [self removeObjectsNotIn:arr];
    for (id each in tmp) {
        block(each);
    }
    return tmp;
}

- (void)removeAllObjects:(void(^)(id))block {
    for (id each in [NSArray arrayWithArray:self])
        block(each);
    [self removeAllObjects];
}

- (void)removeObjectAtRIndex:(NSUInteger)rindex {
    if (self.count > rindex)
    {
        [self removeObjectAtIndex:self.count - rindex - 1];
    }
}

- (void)addInt:(int)val {
    [self addObject:[NSNumber numberWithInt:val]];
}

- (void)addInteger:(NSInteger)val {
    [self addObject:[NSNumber numberWithInteger:val]];
}

- (void)addFloat:(float)val {
    [self addObject:[NSNumber numberWithFloat:val]];
}

- (void)addObjectsFromArray:(NSArray*)arr collector:(id(^)(id))block {
    for (id each in arr) {
        id obj = block(each);
        if (obj == nil)
            continue;
        [self addObject:obj];
    }
}

- (void)addObjectsFromV:(va_list)va {
    id obj = nil;
    while ((obj = va_arg(va, id)))
        [self addObject:obj];
}

- (void)addObjects:(id)obj, ... {
    [self addObject:obj];
    va_list va;
    va_start(va, obj);
    [self addObjectsFromV:va];
    va_end(va);
}

- (void)addObjectsOfCount:(NSInteger)count instance:(id(^)(NSInteger idx, NSInteger i))instance {
    NSInteger cnt = self.count;
    for (int i = 0; i < count; ++i) {
        id obj = instance(cnt + i, i);
        if (obj)
            [self addObject:obj];
    }
}

- (void)resizeByType:(Class)cls toSize:(NSUInteger)size {
    [self resizeByType:cls toSize:size add:nil remove:nil];
}

- (void)resizeByType:(Class)cls toSize:(NSUInteger)size add:(void(^)(id))add remove:(void(^)(id))remove {
    if (self.count == size)
        return;
    
    if (self.count > size) {
        NSRange rgn = NSMakeRange(size, self.count - size);
        if (remove) {
            for (int i = rgn.location; i < rgn.location + rgn.length; ++i) {
                remove([self objectAtIndex:i]);
            }
        }
        [self removeObjectsInRange:rgn];
        return;
    }
    
    int d = size - self.count;
    while (d--) {
        id tmp = [[cls alloc] init];
        if (add)
            add(tmp);
        [self addObject:tmp];
        SAFE_RELEASE(tmp);
    }
}

- (void)resizeTo:(NSUInteger)size def:(id)obj {
    if (self.count == size)
        return;
    
    if (self.count > size) {
        NSRange rgn = NSMakeRange(size, self.count - size);
        [self removeObjectsInRange:rgn];
        return;
    }
    
    int d = size - self.count;
    while (d--) {
        [self addObject:obj];
    }
}

- (void)growByType:(Class)cls toSize:(NSUInteger)size {
    [self growByType:cls toSize:size init:nil];
}

- (void)growByType:(Class)cls toSize:(NSUInteger)size init:(void(^)(id, NSInteger))init {
    if (self.count >= size)
        return;
    const int d = size - self.count;
    const int oldsz = self.count;
    for (int i = 0; i < d; ++i)
    {
        id tmp = [[cls alloc] init];
        if (init)
            init(tmp, oldsz + i);
        [self addObject:tmp];
        SAFE_RELEASE(tmp);
    }
}

- (NSArray*)limitToSize:(NSUInteger)size {
    if (self.count <= size)
        return self;
    
    NSMutableArray* ret = [NSMutableArray array];
    int d = self.count - size;
    while (d--) {
        [ret addObject:self.lastObject];
        [self removeLastObject];
    }
    return ret;
}

- (void)addObjectSafe:(id)anObject {
    if (anObject == nil)
        [self addObject:[NSNull null]];
    else
        [self addObject:anObject];
}

- (void)addObject:(id)anObject def:(id)def {
    if (anObject == nil)
        anObject = def;
    if (anObject)
        [self addObject:anObject];
}

- (void)push:(id)obj {
    [self insertObject:obj atIndex:0];
}

- (id)pop {
    if (self.count == 0)
        return nil;
    
    id obj = [self.firstObject consign];
    [self removeObjectAtIndex:0];
    return obj;
}

- (id)top {
    return self.firstObject;
}

- (NSArray*)popAllObjects {
    NSArray* ret = [NSArray arrayWithArray:self];
    [self removeAllObjects];
    return ret;
}

- (void)swapObjectAtIndex:(NSInteger)idx withIndex:(NSInteger)toidx {
    id obj0 = [[self objectAtIndex:idx] retain];
    id obj1 = [[self objectAtIndex:toidx] retain];
    
    [self replaceObjectAtIndex:idx withObject:obj1];
    [self replaceObjectAtIndex:toidx withObject:obj0];
    
    [obj0 release];
    [obj1 release];
}

- (void)moveObjectAtIndex:(NSInteger)idx toIndex:(NSInteger)toidx {
    if (idx == toidx)
        return;
    
    id obj0 = [[self objectAtIndex:idx] retain];
    [self insertObject:obj0 atIndex:toidx];
    SAFE_RELEASE(obj0);
    
    if (idx < toidx) {
        [self removeObjectAtIndex:idx];
    } else {
        [self removeObjectAtIndex:idx + 1];
    }
}

- (void)readdObject:(id)obj {
    [obj retain];
    [self removeObject:obj];
    [self addObject:obj];
    [obj release];
}

- (void)readdObjectAtIndex:(NSInteger)idx {
    id obj = [[self objectAtIndex:idx] retain];
    [self removeObjectAtIndex:idx];
    [self addObject:obj];
    [obj release];
}

- (NSArray*)removeObjectsInRange:(NSRange)range {
    NSMutableArray* ret = [NSMutableArray array];
    for (int i = 0; i < range.length; ++i) {
        id obj = [self objectAtIndex:(range.location + i) def:nil];
        if (obj == nil)
            break;
        [ret addObject:obj];
    }
    [self removeObjectsInArray:ret];
    return ret;
}

- (void)readdObjectsInRange:(NSRange)range {
    NSArray* arr = [self removeObjectsInRange:range];
    [self addObjectsFromArray:arr];
}

- (void)moveObject:(id)obj afterObject:(id)to {
    NSInteger idx = [self indexOfObject:obj];
    NSInteger toidx = [self indexOfObject:to];
    if (idx == NSNotFound ||
        toidx == NSNotFound)
        return;
    [self moveObjectAtIndex:idx toIndex:toidx + 1];
}

- (void)moveObject:(id)obj beforeObject:(id)to {
    NSInteger idx = [self indexOfObject:obj];
    NSInteger toidx = [self indexOfObject:to];
    if (idx == NSNotFound ||
        toidx == NSNotFound)
        return;
    [self moveObjectAtIndex:idx toIndex:toidx];
}

- (void)insertObjects:(NSArray*)objects atIndex:(NSInteger)idx {
    NSIndexSet* is = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(idx, objects.count)];
    [self insertObjects:objects atIndexes:is];
}

+ (instancetype)restrict:(id)obj {
    if (obj == nil)
        return [NSMutableArray array];
    if ([obj isKindOfClass:[NSMutableArray class]])
        return obj;
    if ([obj isKindOfClass:[NSArray class]])
        return [NSMutableArray arrayWithArray:obj];
    return nil;
}

- (void)fillArray:(NSArray *)array {
    [self removeAllObjects];
    [self addObjectsFromArray:array];
}

- (id)rol {
    if (self.count == 0)
        return nil;
    id obj = [self objectAtIndex:0];
    [self addObject:obj];
    [self removeObjectAtIndex:0];
    return obj;
}

- (id)ror {
    if (self.count == 0)
        return nil;
    NSInteger pos = self.count - 1;
    id obj = [self objectAtIndex:pos];
    [self insertObject:obj atIndex:0];
    [self removeObjectAtIndex:pos];
    return obj;
}

@end

@interface NSSegmentableArray ()

@property (nonatomic, readonly) NSFixedLengthStack *current;
@property (nonatomic, readonly) NSMutableArray *arrs;

@end

@implementation NSSegmentableArray

- (void)onInit {
    [super onInit];
    _arrs = [[NSMutableArray alloc] init];
}

- (void)onFin {
    ZERO_RELEASE(_arrs);
    [super onFin];
}

- (void)segment:(NSInteger)seg {
    NSFixedLengthStack* sck = [NSFixedLengthStack stackWithCapacity:seg];
    [_arrs addObject:sck];
}

- (void)segment {
    NSFixedLengthStack* sck = [NSFixedLengthStack stackWithCapacity:-1];
    [_arrs addObject:sck];
}

- (NSInteger)count {
    return _arrs.count;
}

- (NSArray*)arrayAtIndex:(NSInteger)idx {
    NSFixedLengthStack* sck = [_arrs objectAtIndex:idx];
    return sck.array;
}

@synthesize current;

- (NSFixedLengthStack*)current {
    if (current == nil) {
        current = _arrs.firstObject;
        return current;
    }
    if (current.capacity == current.count)
        current = [_arrs nextObject:current];
    return current;
}

- (void)addObject:(id)obj {
    [self.current add:obj];
}

- (void)addObject:(id)obj def:(id)def {
    if (obj == nil)
        obj = def;
    [self.current add:obj];
}

- (void)addObjectsFromArray:(NSArray*)arr {
    for (id each in arr) {
        [self addObject:each];
    }
}

- (void)removeAllSegments {
    [_arrs removeAllObjects];
}

- (void)removeAllObjects {
    for (NSFixedLengthStack* each in _arrs) {
        [each removeAllObjects];
    }
    current = nil;
}

@end

@interface NSFixedLengthStack ()
{
    NSMutableArray *_arr;
}

@end

@implementation NSFixedLengthStack

@synthesize array = _arr;

+ (instancetype)stackWithCapacity:(NSUInteger)capacity {
    return [[[self alloc] initWithCapacity:capacity] autorelease];
}

- (id)initWithCapacity:(NSUInteger)capacity {
    self = [super init];
    self.capacity = capacity;
    return self;
}

- (void)onInit {
    [super onInit];
    _arr = [[NSMutableArray alloc] init];
}

- (void)onFin {
    ZERO_RELEASE(_arr);
    [super onFin];
}

- (id)push:(id)obj {
    NSInteger cnt = self.count;
    if (cnt < _capacity) {
        [_arr addObject:obj];
        return nil;
    }
    id ret = [_arr pop];
    [_arr addObject:obj];
    return ret;
}

- (BOOL)add:(id)obj {
    NSInteger cnt = self.count;
    if (cnt < _capacity) {
        [_arr addObject:obj];
        return YES;
    }
    return NO;
}

- (id)pop {
    return [_arr pop];
}

- (id)objectAtIndex:(NSInteger)idx {
    return [_arr objectAtIndex:idx def:nil];
}

- (void)removeAllObjects {
    [_arr removeAllObjects];
}

- (NSInteger)count {
    return _arr.count;
}

@end

@implementation NSSet (extension)

+ (instancetype)setWithSets:(NSSet *)set, ... {
    NSMutableSet* ret = [NSMutableSet temporary];
    [ret unionSet:set];
    va_list va;
    va_start(va, set);
    while (id obj = va_arg(va, id)) {
        [ret unionSet:obj];
    }
    va_end(va);
    return ret;
}

- (BOOL)containsInt:(NSInteger)val {
    return [self containsObject:@(val)];
}

- (void)foreach:(IteratorType(^)(id obj, NSInteger idx))fe {
    NSInteger idx = 0;
    for (id obj in self) {
        if (fe(obj, idx++) == kIteratorTypeBreak)
            break;
    }
}

@end

@implementation NSMutableSet (extension)

- (void)addInt:(NSInteger)val {
    [self addObject:@(val)];
}

- (void)removeInt:(NSInteger)val {
    [self removeObject:@(val)];
}

@end

NSString* kNSDateStyleMySQL = @"yyyy-MM-dd HH:mm:ss";

@implementation NSDate (extension)

- (id)initWithTimestamp:(time_t)t {
    self = [self initWithTimeIntervalSince1970:(NSTimeInterval)t];
    return self;
}

- (time_t)timestamp {
    return [self timeIntervalSince1970];
}

- (NSTimeInterval)timeDifference:(NSDate *)other {
    NSTimeInterval ret = [self timeIntervalSinceDate:other];
    return fabs(ret);
}

+ (id)dateWithString:(NSString*)str style:(NSString*)style {
    static NSDateFormatter* df = nil;
    SYNCHRONIZED_BEGIN
    if (df == nil) {
        df = [[NSDateFormatter alloc] init];
        df.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
        df.dateFormat = style;
    }
    SYNCHRONIZED_END
    //NSDateFormatter* df = [[NSDateFormatter alloc] init];
    //df.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    //df.dateFormat = style;
    id ret = [df dateFromString:str];
    //SAFE_RELEASE(df);
    return ret;
}

- (NSString*)styleString:(NSString*)style {
    static NSDateFormatter* df = nil;
    SYNCHRONIZED_BEGIN
    if (df == nil) {
        df = [[NSDateFormatter alloc] init];
        df.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
        df.dateFormat = style;
    }
    SYNCHRONIZED_END
    //NSDateFormatter* df = [[NSDateFormatter alloc] init];
    //df.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    //df.dateFormat = style;
    id ret = [df stringFromDate:self];
    //SAFE_RELEASE(df);
    return ret;
}

- (BOOL)isSameDay:(NSDate*)r {
    NSDateComponents *lc = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    NSDateComponents *rc = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:r];
    return lc.year == rc.year &&
    lc.month == rc.month &&
    lc.day == rc.day;
}

- (NSUInteger)year {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:self];
    return [components year];
}

- (NSUInteger)month {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:self];
    return [components year];
}

- (NSUInteger)day {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:self];
    return [components year];
}

- (NSUInteger)hour {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:self];
    return [components year];
}

- (NSUInteger)minute {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:self];
    return [components year];
}

- (NSUInteger)second {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitSecond fromDate:self];
    return [components year];
}

@end

@implementation NSAnimatedValue

- (id)init {
    self = [super init];
    _animated = YES;
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_value);
    [super dealloc];
}

+ (instancetype)animated:(NSValue*)val {
    NSAnimatedValue* ret = [[self.class alloc] init];
    ret.value = val;
    return [ret autorelease];
}

+ (instancetype)nonanimated:(NSValue*)val {
    NSAnimatedValue* ret = [[self.class alloc] init];
    ret.value = val;
    ret.animated = NO;
    return [ret autorelease];
}

@end

@implementation NSNumber (extension)

+ (id)numberWithTimestamp:(time_t)ts {
    return [NSNumber numberWithLong:ts];
}

- (time_t)timestampValue {
    return (time_t)[self longValue];
}

+ (id)Yes {
    return kNumber1;
}

+ (id)No {
    return kNumber0;
}

- (NSString*)stdStringValue {
    return [self stringValue];
}

+ (id)numberWithReal:(real)val {
    return X32_SYMBOL([NSNumber numberWithFloat:val])
    X64_SYMBOL([NSNumber numberWithDouble:val]);
}

- (real)realValue {
    return X32_SYMBOL([self floatValue]) X64_SYMBOL([self doubleValue]);
}

@end

@implementation NSNumberObject

@dynamic number;

- (NSNumber*)number {
    return self.object;
}

- (void)setNumber:(NSNumber *)number {
    self.object = number;
}

- (void)setBoolValue:(BOOL)boolValue {
    self.number = @(boolValue);
}

- (BOOL)boolValue {
    return self.number.boolValue;
}

@end

@implementation NSAnyNumber

+ (instancetype)number:(any_number)val {
    NSAnyNumber* ret = [[[self alloc] init] autorelease];
    ret.value = val;
    return ret;
}

@end

NSNumber const* kNumber0 = @0;
NSNumber const* kNumber1 = @1;
NSNumber const* kNumberNO = @0;
NSNumber const* kNumberYES = @1;

NSString const* kStringEmpty = @"";

@interface NSTimerExt ()
{
    // 一些配置参数，以用来重新启动即时
    NSTimeInterval _ti;
    
    // 类型 timer or scheme
    int _type;
    
    // 是否在运行
    BOOL _running;
}

@property (nonatomic, retain) NSTimer *tmr;

@end

@implementation NSTimerExt

- (void)onInit {
    [super onInit];
}

- (void)onFin {
    [_tmr invalidate];
    self.tmr = nil;
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalTakeAction)
SIGNALS_END

@synthesize repeats;

+ (instancetype)timerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo start:(BOOL)start {
    NSTimerExt* ret = [NSTimerExt temporary];
    ret.tmr = [NSTimer timerWithTimeInterval:ti target:ret selector:@selector(doAction) userInfo:nil repeats:yesOrNo];
    ret->_ti = ti;
    ret->repeats = yesOrNo;
    ret->_type = 0;
    if (start) {
        ret->_running = YES;
        [[NSRunLoop currentRunLoop] addTimer:ret.tmr forMode:NSDefaultRunLoopMode];
    }
    return ret;
}

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo start:(BOOL)start {
    NSTimerExt* ret = [NSTimerExt temporary];
    if (start) {
        ret.tmr = [NSTimer scheduledTimerWithTimeInterval:ti target:ret selector:@selector(doAction) userInfo:nil repeats:yesOrNo];
        ret->_running = YES;
    }
    ret->_ti = ti;
    ret->repeats = yesOrNo;
    ret->_type = 1;
    return ret;
}

+ (instancetype)timerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo {
    return [self.class timerWithTimeInterval:ti repeats:yesOrNo start:YES];
}

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo {
    return [self.class scheduledTimerWithTimeInterval:ti repeats:yesOrNo start:YES];
}

+ (instancetype)RepeatInterval:(NSTimeInterval)ti {
    return [self.class scheduledTimerWithTimeInterval:ti repeats:YES];
}

- (id)initWithRepeatInterval:(NSTimeInterval)ti {
    return [self initWithScheduledTimeInterval:ti repeats:YES];
}

- (id)initWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo start:(BOOL)start {
    self = [super init];
    self.tmr = [NSTimer timerWithTimeInterval:ti target:self selector:@selector(doAction) userInfo:nil repeats:yesOrNo];
    _ti = ti;
    repeats = yesOrNo;
    _type = 0;
    if (start) {
        _running = YES;
        [[NSRunLoop currentRunLoop] addTimer:self.tmr forMode:NSDefaultRunLoopMode];
    }
    return self;
}

- (id)initWithScheduledTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo start:(BOOL)start {
    self = [super init];
    if (start) {
        self.tmr = [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(doAction) userInfo:nil repeats:yesOrNo];
        _running = YES;
    }
    _ti = ti;
    repeats = yesOrNo;
    _type = 1;
    return self;
}

- (id)initWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo {
    return [self initWithTimeInterval:ti repeats:yesOrNo start:YES];
}

- (id)initWithScheduledTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo {
    return [self initWithScheduledTimeInterval:ti repeats:yesOrNo start:YES];
}

- (void)doAction {
    [self.signals emit:kSignalTakeAction];
}

- (void)invalidate {
    [self stop];
}

- (void)stop {
    [_tmr invalidate];
    ZERO_RELEASE(_tmr);
    _running = NO;
}

- (BOOL)isRunning {
    return _running;
}

- (void)start {
    if (_running) {
        LOG("已经启动了定时器");
        return;
    }
    
    if (_type == 0) {
        self.tmr = [NSTimer timerWithTimeInterval:_ti target:self selector:@selector(doAction) userInfo:nil repeats:repeats];
        [[NSRunLoop currentRunLoop] addTimer:self.tmr forMode:NSDefaultRunLoopMode];
    } else if (_type == 1) {
        self.tmr = [NSTimer scheduledTimerWithTimeInterval:_ti target:self selector:@selector(doAction) userInfo:nil repeats:repeats];
    }
    _running = YES;
}

@dynamic fireDate, timeInterval;

- (void)setFireDate:(NSDate*)fireDate {
    _tmr.fireDate = fireDate;
}

- (NSDate*)fireDate {
    return _tmr.fireDate;
}

- (NSTimeInterval)timeInterval {
    return _tmr.timeInterval;
}

@end

@interface NSCountTimer ()
{
    NSTimeInterval _buf;
}

@property (nonatomic, retain) NSTimerExt* tmr;

@end

@implementation NSCountTimer

- (void)onInit {
    [super onInit];
}

- (void)onFin {
    [self stop];
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalTakeAction)
SIGNAL_ADD(kSignalDone)
SIGNALS_END

- (void)start {
    if (self.tmr != nil)
        return;
    
    [self retain];
    
    _buf = 0;
    _countSteps = 0;
    
    self.tmr = [NSTimerExt scheduledTimerWithTimeInterval:self.timeStep repeats:YES];
    [self.tmr.signals connect:kSignalTakeAction withSelector:@selector(__cb_tick) ofTarget:self];
    
    // 预先fire一次
    [self.signals emit:kSignalTakeAction];
}

- (void)__cb_tick {
    _buf += self.timeStep;
    ++_countSteps;
    
    if (fabs(_buf) > fabs(self.timeBoundary)) {
        [self.signals emit:kSignalDone];
        [self stop];
    } else {
        [self.signals emit:kSignalTakeAction];
    }
}

- (void)stop {
    [self.tmr invalidate];
    self.tmr = nil;
}

@end

@interface NSTimeoutManager ()

@property (nonatomic, readonly) NSMutableDictionary *tmrs;

@end

@implementation NSTimeoutManager

SHARED_IMPL;

- (void)onInit {
    [super onInit];
    _tmrs = [[NSMutableDictionary alloc] init];
}

- (void)onFin {
    ZERO_RELEASE(_tmrs);
    [super onFin];
}

+ (NSString*)KeyName:(NSString*)key inThread:(BOOL)inThread {
    if (inThread) {
        return [NSString stringWithFormat:@"%x:%@", getpid(), key];
    }
    return key;
}

+ (BOOL)IsTimeout:(NSString*)key inThread:(BOOL)inThread {
    NSString* kn = [NSTimeoutManager KeyName:key inThread:inThread];
    if ([[NSTimeoutManager shared].tmrs objectForKey:kn] == nil)
        return YES;
    return NO;
}

+ (NSObjectExt*)SetTimeout:(NSTimeInterval)timeout key:(NSString*)key inThread:(BOOL)inThread {
    NSString* kn = [NSTimeoutManager KeyName:key inThread:inThread];
    NSTimerExt *tmr = [[NSTimeoutManager shared].tmrs objectForKey:kn];
    // 如果时间不匹配，则需要新生成一个
    if (tmr.timeInterval != timeout)
        tmr = nil;
    // 如果不存在对应的计时器，则实例化一个并且再激活后移除
    if (tmr == nil) {
        tmr = [NSTimerExt timerWithTimeInterval:timeout repeats:NO];
        [tmr.signals connect:kSignalTakeAction withBlock:^(SSlot *s) {
            [[NSTimeoutManager shared].tmrs removeObjectForKey:kn];
        }];
        [[NSTimeoutManager shared].tmrs setObject:tmr forKey:kn];
    }
    return tmr;
}

@end

@interface NSTimeUnit ()
{
    int64_t _ut; // 以纳秒为保存单位
}

@end

@implementation NSTimeUnit

+ (instancetype)TimeInterval:(NSTimeInterval)ti {
    NSTimeUnit* ret = [[[self alloc] init] autorelease];
    ret->_ut = ti * 1e9;
    return ret;
}

+ (instancetype)Nanoseconds:(int64_t)t {
    NSTimeUnit* ret = [[[self alloc] init] autorelease];
    ret->_ut = t;
    return ret;
}

+ (instancetype)Microseconds:(int64_t)t {
    NSTimeUnit* ret = [[[self alloc] init] autorelease];
    ret->_ut = t * 1e3;
    return ret;
}

+ (instancetype)Milliseconds:(int64_t)t {
    NSTimeUnit* ret = [[[self alloc] init] autorelease];
    ret->_ut = t * 1e6;
    return ret;
}

- (NSTimeUnit*)difference:(NSTimeUnit *)tu {
    return [[self class] Nanoseconds:(_ut - tu->_ut)];
}

- (NSTimeInterval)timeInterval {
    return 0.001f * self.milliseconds;
}

- (int64_t)nanoseconds {
    return _ut;
}

- (int64_t)microseconds {
    return _ut * 1e-3;
}

- (float)milliseconds {
    return 0.001 * self.microseconds;
}

- (float)seconds {
    return 0.000001 * self.microseconds;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"%fms", self.milliseconds];
}

@end

@implementation NSTime

@synthesize timestamp = _timestamp;

- (id)init {
    self = [super init];
    
    _tm = (struct tm*)calloc(sizeof(struct tm), 1);
    self.timestamp = time(NULL);
    
    return self;
}

- (id)initWithTimestamp:(time_t)t {
    self = [super init];
    
    _tm = (struct tm*)calloc(sizeof(struct tm), 1);
    self.timestamp = t;
    
    return self;
}

- (id)initWithUTCTimestamp:(time_t)t {
    self = [super init];
    
    _tm = (struct tm*)calloc(sizeof(struct tm), 1);
    [self setUTCTimestamp:t];
    
    return self;
}

- (id)initWithDate:(NSDate *)date {
    self = [super init];
    
    _tm = (struct tm*)calloc(sizeof(struct tm), 1);
    self.timestamp = date.timeIntervalSince1970;
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    NSTime* ret = [[self.class alloc] initWithTimestamp:_timestamp];
    return ret;
}

+ (id)timeWithDate:(NSDate*)date {
    return [[[[self class] alloc] initWithDate:date] autorelease];
}

+ (NSTime*)timeWithString:(NSString*)str style:(NSString*)style {
    return [[self class] timeWithDate:[NSDate dateWithString:str style:style]];
}

+ (NSTime*)timeWithTimestamp:(time_t)t {
    return [[[[self class] alloc] initWithTimestamp:t] autorelease];
}

- (void)setTimestamp:(time_t)timestamp {
    _timestamp = timestamp;
    
    struct tm* tmp = localtime(&_timestamp);
    memcpy(_tm, tmp, sizeof(struct tm));
}

- (void)setUTCTimestamp:(time_t)timestamp {
    _timestamp = timestamp;
    
    struct tm* tmp = gmtime(&_timestamp);
    memcpy(_tm, tmp, sizeof(struct tm));
}

- (void)dealloc {
    free(_tm);
    
    [super dealloc];
}

+ (time_t)Now {
    return time(NULL) - 1;
}

+ (instancetype)time {
    return [[[[self class] alloc] init] autorelease];
}

+ (instancetype)Random {
    NSInteger offset = [NSRandom valueBoundary:-1000000 To:1000000];
    time_t tm = [[self class] Now];
    tm += offset;
    return [[[[self class] alloc] initWithTimestamp:tm] autorelease];
}

+ (time_t)TimestampTodayBegin {
    time_t now = time(NULL);
    struct tm* tmp = localtime(&now);
    tmp->tm_hour = 0;
    tmp->tm_min = 0;
    tmp->tm_sec = 0;
    now = timelocal(tmp);
    return now;
}

+ (time_t)TimestampTodayEnd {
    time_t now = time(NULL);
    struct tm* tmp = localtime(&now);
    tmp->tm_hour = 23;
    tmp->tm_min = 59;
    tmp->tm_sec = 59;
    now = timelocal(tmp);
    return now;
}

+ (instancetype)TodayBegin {
    time_t now = [self.class TimestampTodayBegin];
    return [[[[self class] alloc] initWithTimestamp:now] autorelease];
}

+ (instancetype)TodayEnd {
    time_t now = [self.class TimestampTodayEnd];
    return [[[[self class] alloc] initWithTimestamp:now] autorelease];
}

- (int)distanceToday {
    NSTime* df = [self difference:[NSTime temporary]];
    return df.days;
}

- (instancetype)dayBegin {
    struct tm tmp;
    memcpy(&tmp, _tm, sizeof(tmp));
    tmp.tm_hour = 0;
    tmp.tm_min = 0;
    tmp.tm_sec = 0;
    time_t now = timelocal(&tmp);
    return [[[[self class] alloc] initWithTimestamp:now] autorelease];
}

- (instancetype)dayEnd {
    struct tm tmp;
    memcpy(&tmp, _tm, sizeof(tmp));
    tmp.tm_hour = 23;
    tmp.tm_min = 59;
    tmp.tm_sec = 59;
    time_t now = timelocal(&tmp);
    return [[[[self class] alloc] initWithTimestamp:now] autorelease];
}

- (NSTime*)difference:(NSTime *)other {
    time_t d = _timestamp - other->_timestamp;
    BOOL neg = NO;
    if (d < 0) {
        d = -d;
        neg = YES;
    }
    NSTime* ret = [[NSTime alloc] initWithUTCTimestamp:d];
    ret.neg = neg;
    return [ret autorelease];
}

# define NSTIME_RETURNVALUE(val) { \
return TRIEXPRESS(self.neg, -(val), (val)); \
}

- (int)yeard {
    if (_tm)
        return (_tm->tm_year - 70);
    return 0;
}

- (int)diff_yeard {
    NSTIME_RETURNVALUE(self.yeard);
}

- (int)year {
    if (_tm)
        return _tm->tm_year + 1900;
    return 0;
}

- (int)month {
    if (_tm)
        return (_tm->tm_mon);
    return 0;
}

- (int)diff_month {
    NSTIME_RETURNVALUE(self.month);
}

- (int)day {
    if (_tm)
        return (_tm->tm_mday - 1);
    return 0;
}

- (int)diff_day {
    NSTIME_RETURNVALUE(self.day);
}

- (int)weekday {
    if (_tm) {
        if (_tm->tm_wday == 0)
            return (6);
        return (_tm->tm_wday - 1);
    }
    return 0;
}

- (int)diff_weekday {
    NSTIME_RETURNVALUE(self.weekday);
}

- (int)yearday {
    if (_tm) {
        return (_tm->tm_yday);
    }
    return 0;
}

- (int)diff_yearday {
    NSTIME_RETURNVALUE(self.yearday);
}

- (int)hour {
    if (_tm)
        return (_tm->tm_hour);
    return 0;
}

- (int)diff_hour {
    NSTIME_RETURNVALUE(self.hour);
}

- (int)minute {
    if (_tm)
        return (_tm->tm_min);
    return 0;
}

- (int)diff_minute {
    NSTIME_RETURNVALUE(self.minute);
}

- (int)second {
    if (_tm)
        return (_tm->tm_sec);
    return 0;
}

- (int)diff_second {
    NSTIME_RETURNVALUE(self.second);
}

- (int)days {
    return (_tm->tm_yday + self.yeard * 365);
}

- (int)diff_days {
    NSTIME_RETURNVALUE(self.days);
}

- (int)hyear {
    return self.year;
}

- (int)hmonth {
    return self.month + 1;
}

- (int)hday {
    return self.day + 1;
}

+ (void)SleepSecond:(NSTimeInterval)ti {
    [NSTime SleepMilliSecond:ti * 1e3];
}

+ (void)SleepMilliSecond:(NSTimeInterval)ti {
    usleep(ti * 1e3);
}

- (BOOL)isFuture {
    return _timestamp > time(NULL);
}

- (BOOL)isForetime {
    time_t now = time(NULL);
    return _timestamp < now;
}

- (BOOL)isThisYear {
    NSTime* d = [self difference:[NSTime TodayBegin]];
    return d.yeard == 0;
}

- (NSString*)prettyYear {
    if (self.yeard == 1)
        return @"去年";
    else if (self.yeard == 2)
        return @"前年";
    return [NSString stringWithFormat:@"%d年", self.year];
}

- (NSString*)prettyDay {
    if (self.days == 0)
        return @"今天";
    else if (self.days == 1) {
        if (self.neg)
            return @"昨天";
        else
            return @"明天";
    } else if (self.days == 2) {
        if (self.neg)
            return @"前天";
        else
            return @"后天";
    }
    return @(self.days).stringValue;
}

- (NSString*)prettyWeekDay {
    NSString* ret = @"";
    switch (_tm->tm_wday) {
        case 1: ret = @"周一"; break;
        case 2: ret = @"周二"; break;
        case 3: ret = @"周三"; break;
        case 4: ret = @"周四"; break;
        case 5: ret = @"周五"; break;
        case 6: ret = @"周六"; break;
        case 0: ret = @"周日"; break;
    }
    return ret;
}

- (int)weekfree {
    return 6 - self.weekday;
}

- (NSDate*)dateValue {
    return [NSDate dateWithTimeIntervalSince1970:self.timestamp];
}

- (NSString*)stringValue {
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    df.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];//@"Aisa/Shanghai"];
    df.dateFormat = kNSDateStyleMySQL;
    NSString* ret = [df stringFromDate:[self dateValue]];
    ret = [ret stringByAppendingString:@" UTC"];
    SAFE_RELEASE(df);
    return ret;
}

- (NSString*)description {
    return [self stringValue];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[NSTime class]] == NO)
        return NO;
    NSTime* r = object;
    return self.timestamp == r.timestamp;
}

+ (NSTimeUnit*)PidTime {
    uint64_t start;
    uint64_t elapsedNano;
    static mach_timebase_info_data_t sTimebaseInfo;
    
    // Start the clock.
    start = mach_absolute_time();

    // Convert to nanoseconds.
    // If this is the first time we've run, get the timebase.
    // We can use denom == 0 to indicate that sTimebaseInfo is
    // uninitialised because it makes no sense to have a zero
    // denominator is a fraction.
    if ( sTimebaseInfo.denom == 0 ) {
        (void) mach_timebase_info(&sTimebaseInfo);
    }
    
    // Do the maths. We hope that the multiplication doesn't
    // overflow; the price you pay for working in fixed point.
    elapsedNano = start * sTimebaseInfo.numer / sTimebaseInfo.denom;
    return [NSTimeUnit Nanoseconds:elapsedNano];
}

- (NSComparisonResult)compare:(NSTime*)other {
    if (self->_timestamp < other->_timestamp)
        return NSOrderedAscending;
    if (self->_timestamp == other->_timestamp)
        return NSOrderedSame;
    return NSOrderedDescending;
}

- (NSUInteger)hash {
    return self->_timestamp;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    self.timestamp = [aDecoder decodeIntegerForKey:@"timestamp"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self->_timestamp) forKey:@"timestamp"];
}

@end

NSString* kNSTimeFormatCurrentWeek = @"本";
NSString* kNSTimeFormatPreviousWeek = @"上";
NSString* kNSTimeFormatNextWeek = @"下";

@implementation NSTime (pretty)

- (NSString*)prettyString {
    NSMutableString* ret = [NSMutableString string];
    NSTime* today = [NSTime TodayBegin];
    NSTime* dt = [[self dayBegin] difference:today];
    if (dt.yeard == 0) {
        if (dt.month == 0) {
            if (dt.day < 3) {
                [ret appendString:dt.prettyDay];
                [ret appendFormat:@" %02d:%02d", self.hour, self.minute];
                return ret;
            }
            
            if (dt.day <= today.weekday ||
                dt.day < today.weekfree) {
                [ret appendString:kNSTimeFormatCurrentWeek];
                [ret appendString:self.prettyWeekDay];
                [ret appendFormat:@" %02d:%02d", self.hour, self.minute];
                return ret;
            }
            
            if (dt.neg) {
                if (dt.day <= today.weekday + 7) {
                    [ret appendString:kNSTimeFormatPreviousWeek];
                    [ret appendString:self.prettyWeekDay];
                    [ret appendFormat:@" %02d:%02d", self.hour, self.minute];
                    return ret;
                }
            } else {
                if (dt.day <= today.weekfree + 7) {
                    [ret appendString:kNSTimeFormatNextWeek];
                    [ret appendString:self.prettyWeekDay];
                    [ret appendFormat:@" %02d:%02d", self.hour, self.minute];
                    return ret;
                }
            }
            
            [ret appendFormat:@"%02d-%02d", self.month + 1, self.day + 1];
            [ret appendFormat:@" %02d:%02d", self.hour, self.minute];
            return ret;
            
        } else {
            return [self stringValue];
        }
    }
    else {
        return [self stringValue];
    }
    return @"";
}

# define SLOWABS(v) ((v) < 0 ? -(v) : (v))

- (NSString*)prettyDistanceString {
    NSTime* ct = [[NSTime alloc] init];
    NSTime* dt = [self difference:ct];
    NSMutableString* strtime = [NSMutableString string];
    if (dt.yeard)
        [strtime appendFormat:@"%d年", SLOWABS(dt.yeard)];
    if (dt.month)
        [strtime appendFormat:@"%d月", SLOWABS(dt.month)];
    if (dt.day)
        [strtime appendFormat:@"%d天", SLOWABS(dt.day)];
    if (strtime.length == 0)
    {
        if (dt.hour)
            [strtime appendFormat:@"%d小时", SLOWABS(dt.hour)];
        if (dt.minute)
            [strtime appendFormat:@"%d分", SLOWABS(dt.minute)];
    }
    if (strtime.notEmpty) {
        if (dt.neg)
            [strtime appendString:@"前"];
        else
            [strtime appendString:@"后"];
    } else {
        if (dt.neg)
            [strtime appendString:@"刚刚"];
        else
            [strtime appendString:@"稍后"];
    }
    SAFE_RELEASE(ct);
    return strtime;
}

@end

@implementation NSMutableTime

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {    
    [super dealloc];
}

- (void)updateData {
    _timestamp = timegm(_tm);
}

- (time_t)timestamp {
    [self updateData];
    return _timestamp;
}

- (void)setYeard:(int)yeard {
    _tm->tm_year = yeard + 70;
}

- (void)setYear:(int)year {
    _tm->tm_year = year - 1900;
}

- (void)setMonth:(int)month {
    _tm->tm_mon = month;
}

- (void)setDay:(int)day {
    _tm->tm_mday = day + 1;
}

- (void)setHour:(int)hour {
    _tm->tm_hour = hour;
}

- (void)setMinute:(int)minute {
    _tm->tm_min = minute;
}

- (void)setSecond:(int)second {
    _tm->tm_sec = second;
}

@end

@interface NSRegularExpressionCache : NSObjectsCache @end
@implementation NSRegularExpressionCache SHARED_IMPL @end

@implementation NSRegularExpression (extension)

+ (NSRegularExpression *)regularExpressionWithPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options {
    NSError* err = nil;
    NSRegularExpression* ret = [self regularExpressionWithPattern:pattern options:options error:&err];
    if (err)
        [err log];
    return ret;
}

+ (NSRegularExpression *)regularExpressionWithPattern:(NSString *)pattern {
    return [self regularExpressionWithPattern:pattern options:0];
}

- (id)initWithPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options {
    NSError* err = nil;
    self = [self initWithPattern:pattern options:options error:&err];
    if (err)
        [err log];
    return self;
}

- (id)initWithPattern:(NSString *)pattern {
    return [self initWithPattern:pattern options:0];
}

+ (NSRegularExpression*)cachedRegularExpressionWithPattern:(NSString *)pattern
                                                   options:(NSRegularExpressionOptions)options
                                                     error:(NSError **)error
{
    NSRegularExpression* ret = [[NSRegularExpressionCache shared] addInstance:^id{
        NSRegularExpression* regr = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                              options:options
                                                                                error:error];
        return regr;
    } withKey:pattern];
    return ret;
}

+ (NSRegularExpression*)cachedRegularExpressionWithPattern:(NSString *)pattern
                                                   options:(NSRegularExpressionOptions)options {
    NSError* err = nil;
    NSRegularExpression* ret = [self cachedRegularExpressionWithPattern:pattern options:options error:&err];
    if (err)
        [err log];
    return ret;
}

+ (NSRegularExpression*)cachedRegularExpressionWithPattern:(NSString *)pattern {
    NSRegularExpression* ret = [self cachedRegularExpressionWithPattern:pattern options:0];
    return ret;
}

+ (id)Digital {
    return [NSRegularExpression cachedRegularExpressionWithPattern:@"[0-9\\.]+" options:NSRegularExpressionCaseInsensitive error:nil];
}

+ (id)Email {
    return [NSRegularExpression cachedRegularExpressionWithPattern:@"\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*" options:NSRegularExpressionCaseInsensitive error:nil];
}

+ (id)MobilePhone {
    return [NSRegularExpression cachedRegularExpressionWithPattern:@"[0-9]{11}" options:0 error:nil];
}

+ (id)EmailAndMobilePhone {
    return [NSRegularExpression cachedRegularExpressionWithPattern:@"[0-9]{11}|\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*" options:NSRegularExpressionCaseInsensitive error:nil];
}

+ (id)Password {
    return [NSRegularExpression cachedRegularExpressionWithPattern:@"[0-9a-z!@#$%^&*()\\-=\\[\\]{};:'\",<>\\./\\\\|]{6,16}" options:NSRegularExpressionCaseInsensitive error:nil];
}

+ (id)KeyValues {
    return [NSRegularExpression cachedRegularExpressionWithPattern:@"([a-z0-9_]+)=([^&]+)" options:NSRegularExpressionCaseInsensitive error:nil];
}

+ (id)Price {
    return [NSRegularExpression cachedRegularExpressionWithPattern:@"([0-9]*)(\\.[0-9]{0,2})?$"];
}

+ (id)AppUrlOnAppstore {
    return [NSRegularExpression cachedRegularExpressionWithPattern:@"^https://itunes.apple.com/.+/id([0-9]+)\\?"];
}

+ (instancetype)CharsInRange:(NSRange)rgn {
    return [NSRegularExpression cachedRegularExpressionWithPattern:[NSString stringWithFormat:@".{%d,%d}", (int)rgn.location, (int)NSMaxRange(rgn)]];
}

- (NSArray*)stringsMatchedInString:(NSString*)str {
    return [self stringsMatchedInString:str options:0];
}

- (NSArray*)stringsMatchedInString:(NSString*)str options:(NSMatchingOptions)options {
    return [self stringsMatchedInString:str options:options range:NSMakeRange(0, str.length)];
}

- (NSArray*)stringsMatchedInString:(NSString*)str options:(NSMatchingOptions)options range:(NSRange)range {
    if (str.length == 0)
        return nil;

    NSArray* result = [self matchesInString:str options:options range:range];
    NSMutableArray* ret = [NSMutableArray array];
    for (NSTextCheckingResult* each in result) {        
        if (each.numberOfRanges == 1) {
            NSRange rg = [each rangeAtIndex:0];
            NSString* tmp = [str substringWithRange:rg];
            [ret addObject:tmp];
            continue;
        }
        
        NSMutableArray* arr = [[NSMutableArray alloc] init];
        for (int i = 0; i < each.numberOfRanges; ++i) {
            NSRange rg = [each rangeAtIndex:i];
            if (rg.location == NSNotFound) {
                [arr addObjectSafe:nil];
                continue;
            }
            
            NSString* tmp = [str substringWithRange:rg];
            [arr addObject:tmp];
        }
        [ret addObject:arr];
        SAFE_RELEASE(arr);
    }
    return ret;
}

- (NSArray*)capturesInString:(NSString *)str {
    return [self capturesInString:str options:0];
}

- (NSArray*)capturesInString:(NSString*)str options:(NSMatchingOptions)options {
    return [self capturesInString:str options:options range:NSMakeRange(0, str.length)];
}

- (NSArray*)capturesInString:(NSString*)str options:(NSMatchingOptions)options range:(NSRange)range {
    NSMutableArray* ret = [NSMutableArray array];
    NSArray* result = [self stringsMatchedInString:str options:options range:range];
    [result foreach:^BOOL(NSArray* obj) {
        [ret addObjectsFromArray:obj];
        return YES;
    } forClass:[NSArray class]];
    return ret;
}

- (BOOL)isMatchs:(NSString *)str {
    NSRange rgn = [self rangeOfFirstMatchInString:str options:0 range:NSMakeRange(0, str.length)];
    return rgn.location != NSNotFound;
}

- (NSArray *)matchesInString:(NSString *)string range:(NSRange)range {
    return [self matchesInString:string options:0 range:range];
}

- (NSUInteger)numberOfMatchesInString:(NSString *)string range:(NSRange)range {
    return [self numberOfMatchesInString:string options:0 range:range];
}

- (NSTextCheckingResult *)firstMatchInString:(NSString *)string range:(NSRange)range {
    return [self firstMatchInString:string options:0 range:range];
}

- (NSRange)rangeOfFirstMatchInString:(NSString *)string range:(NSRange)range {
    return [self rangeOfFirstMatchInString:string options:0 range:range];
}

@end

@implementation NSAtomicCounter

@synthesize value;

- (id)init {
    self = [super init];
    value = 0;
    return self;
}

- (NSInteger)radd {
    return ATOMIC_INC(value, 1);
}

- (NSInteger)rsub {
    return ATOMIC_DEC(value, 1);
}

- (NSInteger)add {
    return ATOMIC_ADD(value, 1);
}

- (NSInteger)sub {
    return ATOMIC_SUB(value, 1);
}

- (void)reset {
    value = 0;
}

- (NSString*)description {
    return @(value).stringValue;
}

@end

@implementation NSDataSource

- (id)init {
    self = [super init];
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    NSDataSource* ds = [[[self class] alloc] init];
    
    SAFE_COPY(ds.url, _url);
    SAFE_COPY(ds.bundle, _bundle);
    ds.data = self.data;
    
    return ds;
}

+ (instancetype)dsWithUrl:(NSURL *)url {
    if (url.absoluteString.notEmpty == NO)
        return nil;
    
    NSDataSource* ret = [[[self class] alloc] init];
    ret.url = url;
    return [ret autorelease];
}

+ (instancetype)dsWithUrlString:(NSString *)ustr {
    NSURL* url = nil;
    
    if (ustr.isAbsolutePath) {
        url = [NSURL fileURLWithPath:ustr];
    } else {
        url = [NSURL URLWithString:ustr];
    }

    return [[self class] dsWithUrl:url];
}

+ (instancetype)asyncWithUrl:(NSURL*)url {
    NSDataSource* ret = [self dsWithUrl:url];
    ret.async = YES;
    return ret;
}

+ (instancetype)asyncWithUrlString:(NSString*)url {
    NSDataSource* ret = [self dsWithUrlString:url];
    ret.async = YES;
    return ret;
}

+ (instancetype)dsWithBundle:(NSString *)bd {
    NSDataSource* ret = [[[self class] alloc] init];
    ret.bundle = bd;
    return [ret autorelease];
}

+ (instancetype)dsWithData:(id)data {
    NSDataSource* ret = [[[self class] alloc] init];
    ret.data = data;
    return [ret autorelease];
}

- (void)dealloc {
    ZERO_RELEASE(_url);
    ZERO_RELEASE(_bundle);
    ZERO_RELEASE(_data);
    
    [super dealloc];
}

- (BOOL)sync {
    return !self.async;
}

- (BOOL)notEmpty {
    if (_url.notEmpty)
        return YES;
    if (_bundle.notEmpty)
        return YES;
    if (_data != nil)
        return YES;
    return NO;
}

@end

@implementation NSUsed

@synthesize used;
@synthesize object;

- (id)init {
    self = [super init];
    used = NO;
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(object);
    [super dealloc];
}

- (void)setObject:(id)obj {
    if (obj == object)
        return;
    
    PROPERTY_RETAIN(object, obj);

    used = YES;
}

@end

# define NSUSED_IMPL(Name, Value, Prop) \
@implementation NSUsed##Name \
@synthesize value; \
- (void)setValue:(Value)val { \
if (value == val) \
return; \
PROPERTY_##Prop(value, val); \
self.used = YES; \
} \
@end

NSUSED_IMPL(Integer, NSInteger, ASSIGN);
NSUSED_IMPL(String, NSString*, COPY);

@interface NSSyncLoop ()
{
    CFRunLoopRef hdl;
}

@end

@implementation NSSyncLoop

- (void)wait {
    hdl = CFRunLoopGetCurrent();
    if (hdl != CFRunLoopGetMain())
    {
        CFRunLoopTimerRef tmr = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, 0, 5, 0, 0, ^(CFRunLoopTimerRef timer) {});
        CFRunLoopAddTimer(hdl, tmr, kCFRunLoopCommonModes);
        CFRelease(tmr);
    }
    else
    {
        INFO("即将通过 NSSyncLoop 来阻塞 主 进程");
    }
    CFRunLoopRun();
}

- (void)continuee {
    if (hdl) {
        CFRunLoopStop(hdl);
        hdl = NULL;
    }
}

+ (BOOL)InMainThread {
    return dispatch_get_current_queue() == dispatch_get_main_queue();
}

+ (void)WaitIdle {
    AUTORELEASE_BEGIN
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.002f, TRUE) == kCFRunLoopRunHandledSource);
    AUTORELEASE_END
}

+ (NSSyncLoop*)loop {
    return [[[[self class] alloc] init] autorelease];
}

@end

@interface NSBoolean ()

@property (nonatomic, assign) BOOL value;

@end

@implementation NSBoolean

- (id)initWithBool:(BOOL)val {
    self = [super init];
    self.value = val;
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    NSBoolean* ret = [[self.class alloc] init];
    ret.value = self.value;
    return ret;
}

+ (id)boolean:(BOOL)val {
    return [[[[self class] alloc] initWithBool:val] autorelease];
}

+ (id)Random {
    return [[self class] boolean:([NSRandom valueBoundary:0 To:100] > 50)];
}

static NSBoolean* gs_boolean_yes = nil;
static NSBoolean* gs_boolean_no = nil;

+ (instancetype)Yes {
    SYNCHRONIZED_BEGIN
    if (gs_boolean_yes == nil)
        gs_boolean_yes = [[self boolean:YES] retain];
    SYNCHRONIZED_END
    return gs_boolean_yes;
}

+ (instancetype)No {
    SYNCHRONIZED_BEGIN
    if (gs_boolean_no == nil)
        gs_boolean_no = [[self boolean:NO] retain];
    SYNCHRONIZED_END
    return gs_boolean_no;
}

- (BOOL)boolValue {
    return _value;
}

- (instancetype)negative {
    if (_value)
        return [NSBoolean No];
    return [NSBoolean Yes];
}

- (NSUInteger)hash {
    return _value;
}

- (BOOL)isEqual:(id)object {
    return self.boolValue == [object boolValue];
}

- (NSString*)description {
    return TRIEXPRESS(self.value, @"YES", @"NO");
}

@end

@implementation NSBundle (extension)

- (NSString*)imageNamed:(NSString *)name {
    NSString* ret = nil;
    if ((ret = [self pathForResource:name ofType:@"png"]))
        return ret;
    if ((ret = [self pathForResource:name ofType:@"jpg"]))
        return ret;
    if ((ret = [self pathForResource:name ofType:@"jpeg"]))
        return ret;
    if ((ret = [self pathForResource:name ofType:@"bmp"]))
        return ret;
    if ((ret = [self pathForResource:name ofType:@"gif"]))
        return ret;
    return ret;
}

// 查找制定文件的路径
+ (NSURL*)URLForFileNamed:(NSString*)name {
    NSBundle* bdl = [NSBundle mainBundle];
    return [bdl.bundleURL URLByAppendingPathComponent:name];
}

@end

@implementation NSPercentage

- (void)setMax:(double)max {
    _max = max;
    
    if (_max)
        _percent = _value / _max;
    else
        _percent = 0;
}

- (void)setValue:(double)value {
    _value = value;
    
    if (_max)
        _percent = _value / _max;
    else
        _percent = 0;
}

- (void)setPercent:(double)percent {
    _percent = percent;
    _value = _max * _percent;
}

- (id)initWithPercent:(double)val {
    self = [super init];
    _percent = val;
    _max = 1;
    return self;
}

- (id)initWithMax:(double)max value:(double)val {
    self = [super init];
    _max = max;
    self.value = val;
    return self;
}

+ (instancetype)percent:(double)val {
    return [[[self alloc] initWithPercent:val] autorelease];
}

+ (instancetype)percentWithMax:(double)max value:(double)val {
    return [[[self alloc] initWithMax:max value:val] autorelease];
}

- (double)percent1 {
    return self.percent;
}

- (void)setPercent1:(double)percent1 {
    self.percent = percent1;
}

- (double)percent10 {
    return self.percent * 10;
}

- (void)setPercent10:(double)percent10 {
    self.percent = percent10 * 0.1;
}

- (double)percent100 {
    return self.percent * 100;
}

- (void)setPercent100:(double)percent100 {
    self.percent = percent100 * 0.01;
}

- (BOOL)isEqual:(NSPercentage*)object {
    if ([object isKindOfClass:[self class]] == NO)
        return NO;
    return self.max == object.max &&
    self.value == object.value &&
    self.percent == object.percent;
}

+ (instancetype)Completed {
    return [[self class] percent:1];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"percentage: %.2f%%, max: %f, value:%f", self.percent100, _max, _value];
}

@end

@implementation NSPointPercentage

- (id)initWithPoint:(CGPoint)pt inSize:(CGSize)size {
    self = [super init];
    if (self) {
        _percentX = [[NSPercentage alloc] initWithMax:size.width value:pt.x];
        _percentY = [[NSPercentage alloc] initWithMax:size.height value:pt.y];
    }
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_percentX);
    ZERO_RELEASE(_percentY);
    [super dealloc];
}

+ (instancetype)percent:(CGPoint)pt inSize:(CGSize)size {
    return [[[self alloc] initWithPoint:pt inSize:size] autorelease];
}

@end

@implementation NSProgressValue

- (void)dealloc {
    ZERO_RELEASE(_totoalbuffer);
    ZERO_RELEASE(_packetbuffer);
    [super dealloc];
}

@end

@implementation NSURLEncoder

+ (id)decodeWithString:(NSString *)str {
    return [[[[self class] alloc] initWithString:str] autorelease];
}

- (id)initWithString:(NSString *)str {
    self = [self init];
    if ([self decode:str] == NO) {
        [self release];
        return nil;
    }
    return self;
}

- (id)init {
    self = [super init];
    _values = [[NSMutableDictionary alloc] init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_url);
    ZERO_RELEASE(_values);
    
    [super dealloc];
}

- (BOOL)decode:(NSString *)str {
    NSRegularExpression* rekv = [NSRegularExpression KeyValues];
    // 先根据 ? 拆成两部分
    NSRange found = [str rangeOfString:@"?"];
    if (found.location == NSNotFound) {
        // 先测试 key-values
        NSArray* result = [rekv stringsMatchedInString:str options:0];
        if (result.count == 0) {
            self.url = str;
            [self.values removeAllObjects];
        } else {
            
            NSMutableDictionary* kvs = [[NSMutableDictionary alloc] init];
            
            // 处理array
            NSArray* result = [rekv stringsMatchedInString:str options:0];
            for (NSArray* each in result) {
                NSString* key = [each objectAtIndex:1];
                NSString* value = [each objectAtIndex:2];
                value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [kvs pushQueObject:value forKey:key];
            }
            
            self.values = kvs;
            SAFE_RELEASE(kvs);
            
        }
    } else {
        
        NSMutableDictionary* kvs = [[NSMutableDictionary alloc] init];
        
        // 分两块
        NSString* left = [str substringToIndex:found.location];
        NSString* right = [str substringFromIndex:found.location + 1];
        
        self.url = left;
        
        // 处理array
        NSArray* result = [rekv stringsMatchedInString:right options:0];
        for (NSArray* each in result) {
            NSString* key = [each objectAtIndex:1];
            NSString* value = [each objectAtIndex:2];
            value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [kvs pushQueObject:value forKey:key];
        }
        
        self.values = kvs;
        SAFE_RELEASE(kvs);
    }
    
    return YES;
}

- (NSString*)description {
    NSMutableString* str = [NSMutableString string];
    [str appendString:self.url];
    if (self.values.count) {
        [str appendString:@"/?"];
        NSArray* arr = [NSArray arrayFromDictionary:self.values byConverter:^id(id key, id val) {
            return [NSString stringWithFormat:@"%@=%@", key, val];
        }];
        [str appendString:[arr componentsJoinedByString:@"&"]];
    }
    return str;
}

@end

@implementation NSURIEncode

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_scheme);
    ZERO_RELEASE(_domain);
    
    [super dealloc];
}

+ (id)decodeWithString:(NSString*)str {
    return [[[[self class] alloc] initWithString:str] autorelease];
}

- (id)initWithString:(NSString*)str {
    self = [self init];
    if ([self decode:str] == NO) {
        [self release];
        return nil;
    }
    return self;
}

- (BOOL)decode:(NSString*)str {
    NSRegularExpression* releft = [NSRegularExpression cachedRegularExpressionWithPattern:@"([a-z0-9]+)://([a-z0-9\\._]+)(.+)?" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray* result = [releft stringsMatchedInString:str options:0];
    if (result.count == 0)
        return NO;
    self.scheme = [[result firstObject] objectAtIndex:1];
    self.domain = [[result firstObject] objectAtIndex:2];
    return YES;
}

@end

@implementation NSNull (extension)

- (NSString*)stringValue {
    return @"";
}

- (int)intValue {
    return 0;
}

- (float)floatValue {
    return 0;
}

- (double)doubleValue {
    return 0;
}

@end

@implementation NSMath

+ (NSInteger)CeilInteger:(NSInteger)l r:(NSInteger)r {
    return ceilf(l / (float)r);
}

+ (NSInteger)FloorInteger:(NSInteger)l r:(NSInteger)r {
    return floorf(l / (float)r);
}

+ (float)CeilFloat:(float)l r:(float)r {
    return ceilf(l / r);
}

+ (float)FloorFloat:(float)l r:(float)r {
    return floorf(l / r);
}

+ (double)CeilDouble:(double)l r:(double)r {
    return ceil(l / r);
}

+ (double)FloorDouble:(double)l r:(double)r {
    return floor(l / r);
}

+ (int)Residue:(float)l width:(int)width {
    float val = (l - floorf(l)) * pow(10, width);
    return int(val);
}

+ (int)maxi:(int)l r:(int)r {
    return MAX(l, r);
}

+ (float)maxf:(float)l r:(float)r {
    return MAX(l, r);
}

+ (double)maxd:(double)l r:(double)r {
    return MAX(l, r);
}

+ (int)mini:(int)l r:(int)r {
    return MIN(l, r);
}

+ (float)minf:(float)l r:(float)r {
    return MIN(l, r);
}

+ (double)mind:(double)l r:(double)r {
    return MIN(l, r);
}

@end

@implementation NSBytesSizePresenter

- (id)initWithSize:(NSULongLong)val {
    self = [super init];
    self.value = val;
    return self;
}

+ (instancetype)presenterWithSize:(NSULongLong)val {
    return [[(NSBytesSizePresenter*)[[self class] alloc] initWithSize:val] autorelease];
}

const NSULongLong SIZE_K = 1 << 10;
const NSULongLong SIZE_M = 1 << 20;
const NSULongLong SIZE_G = 1 << 30;
const NSULongLong SIZE_T = SIZE_G * SIZE_K;
const NSULongLong SIZE_P = SIZE_T * SIZE_K;

- (void)setValue:(NSULongLong)val {
    _value = val;
    
    _P = _value / SIZE_P;
    NSULongLong left = _value % SIZE_P;
    _T = left / SIZE_T;
    left = left % SIZE_T;
    _G = left / SIZE_G;
    left = left % SIZE_G;
    _M = left / SIZE_M;
    left = left % SIZE_M;
    _K = left / SIZE_K;
    _B = left % SIZE_K;
}

- (NSULongLong)value {
    _value = _P * SIZE_P;
    _value += _T * SIZE_T;
    _value += _G * SIZE_G;
    _value += _M * SIZE_M;
    _value += _K * SIZE_K;
    _value += _B;
    return _value;
}

- (NSULongLong)Ms {
    return _P * SIZE_K + _T * SIZE_K + _G * SIZE_K + _M;
}

- (float)Mf {
    float val = self.Ms;
    val += _K * .001f;
    return val;
}

@end

@interface NSMutex ()
{
    pthread_mutex_t _mtx;
}

@end

@implementation NSMutex

- (id)init {
    self = [super init];
    
    pthread_mutex_init(&_mtx, NULL);
    
    return self;
}

- (void)dealloc {
    pthread_mutex_destroy(&_mtx);
    
    [super dealloc];
}

- (void)lock {
    pthread_mutex_lock(&_mtx);
}

- (void)unlock {
    pthread_mutex_unlock(&_mtx);
}

@end

@implementation NSError (extension)

SIGNALS_BEGIN
SIGNAL_ADD(kSignalSucceed)
SIGNAL_ADD(kSignalFailed)
SIGNALS_END

@end

@implementation NSUUID (extension)

+ (instancetype)UUIDString:(NSString*)str {
    return [[[[self class] alloc] initWithUUIDString:str] autorelease];
}

@end

real random_between(real l, real h) {
    real val = rand();
    val /= RAND_MAX;
    val = val * (h - l) + l;
    return val;
}

@implementation NSRandom

+ (real)valueBoundary:(real)low To:(real)high {
    return random_between(low, high);
}

@end

@implementation NSKeyedUnarchiver (extension)

+ (id)unarchiveObjectWithData:(NSData *)data def:(id)def {
    id ret = nil;
    @try {
        ret = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    @catch (NSException *exception) {
        ret = def;
        [exception log];
    }
    return ret;
}

@end

@implementation NSKeyedArchiver (extension)

+ (NSData *)archivedDataWithRootObject:(id)rootObject def:(id)def {
    NSData* ret = nil;
    @try {
        ret = [NSKeyedArchiver archivedDataWithRootObject:rootObject];
    }
    @catch (NSException* exception) {
        ret = def;
        [exception log];
    }
    return ret;
}

@end

@implementation NSOperation (extension)

NSOBJECT_DYNAMIC_PROPERTY(NSOperation, name, setName, COPY_NONATOMIC);

SIGNALS_BEGIN
SIGNAL_ADD(kSignalStart)
SIGNAL_ADD(kSignalDone)
SIGNAL_ADD(kSignalProcessing)
SIGNALS_END

- (void)onStart {
    [self.touchSignals emit:kSignalStart];
}

- (void)onEnd {
    [self.touchSignals emit:kSignalDone];
}

- (void)onProcess {
    [self.touchSignals emit:kSignalProcessing];
}

@end

@implementation NSOperationExt

- (id)init {
    self = [super init];
    [self onInit];
    return self;
}

- (void)dealloc {
    [self onFin];
    [super dealloc];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalDone)
SIGNALS_END

- (void)start {
    [self onStart];
    [super start];
}

- (void)main {
    [super main];
    [self onProcess];
    [self onEnd];
}

@end

@implementation NSBlockOperationExt

- (id)init {
    self = [super init];
    [self onInit];
    return self;
}

- (void)dealloc {
    [self onFin];
    [super dealloc];
}

- (void)start {
    [self onStart];
    [super start];
}

- (void)main {
    [super main];
    [self onProcess];
    [self onEnd];
}

@end

@interface NSOperationQueue (SignalSlot)
<SSignals>

@end

@implementation NSOperationQueue (SignalSlot)

SIGNALS_BEGIN
self.signals.delegate = self;
SIGNAL_ADD(kSignalDone)
SIGNALS_END

- (void)waitSignals {
    [self waitUntilAllOperationsAreFinished];
    [self.touchSignals emit:kSignalDone];
}

- (void)signals:(NSObject *)object signalConnected:(NSString *)sig slot:(SSlot *)slot {
    PASS;
}

@end

@implementation NSOperationQueue (extension)

- (BOOL)isEmpty {
    return self.operationCount == 0;
}

- (void)start {
    if (self.isSuspended == NO)
        return;
    self.suspended = NO;
    
    if (self.touchSignals.delegate == self) {
        DISPATCH_ASYNC({
            [self waitSignals];
        });
    }
}

- (void)stop {
    if (self.isSuspended == YES)
        return;
    self.suspended = YES;
}

@end

@implementation NSOperationQueueExt

- (id)init {
    self = [super init];
    [self onInit];
    return self;
}

- (void)dealloc {
    [self onFin];
    [super dealloc];
}

@end

@interface NSPerformanceMeasure ()

@property (nonatomic, retain) NSTimeUnit *tm_start, *tm_end;

@end

@implementation NSPerformanceMeasure

- (void)onInit {
    [super onInit];
    self.name = @"";
}

- (void)onFin {
    ZERO_RELEASE(_tm_start);
    ZERO_RELEASE(_tm_end);
    [super onFin];
}

- (void)start {
    LOG("开始衡量 %s", self.name.UTF8String);
    
    [super start];
}

- (void)onStart {
    self.tm_start = [NSTime PidTime];
    [super onStart];
}

- (void)onEnd {
    self.tm_end = [NSTime PidTime];
    [super onEnd];
    
    [self log:@""];
}

- (void)main {
    [super main];
}

- (NSTimeUnit*)time {
    return [self.tm_end difference:self.tm_start];
}

- (void)log:(NSString *)format {
# ifdef DEBUG_MODE
    NSString* str = [format stringByAppendingFormat:@" 耗时：%.2f 毫秒", self.time.milliseconds];
    LOG(str.UTF8String);
# endif
}

- (void)measure:(void (^)())block {
    [self addExecutionBlock:block];
}

+ (void)measure:(void(^)())block result:(void(^)(NSTimeUnit*))result {
    NSPerformanceMeasure* pm = [self.class temporary];
    [pm.signals connect:kSignalDone withBlock:^(SSlot *s) {
        NSPerformanceMeasure* pm = (id)s.sender;
        if (result)
            result(pm.time);
    }];
    [pm measure:block];
    [pm start];
}

+ (void)measure:(void (^)())block {
    [self measure:block result:nil];
}

@end

@implementation NSPerformanceSuit

- (void)onInit {
    [super onInit];
    self.suspended = YES;
    self.maxConcurrentOperationCount = 1;
    
    [self.signals connect:kSignalDone withSelector:@selector(stop) ofTarget:self];
}

- (void)onFin {
    [super onFin];
}

- (void)measure:(NSString*)name block:(void(^)())block {
    [self measure:name block:block measure:nil];
}

- (void)measure:(NSString*)name block:(void(^)())block measure:(void(^)(NSPerformanceMeasure*))pm {
    NSPerformanceMeasure* mp = [NSPerformanceMeasure blockOperationWithBlock:block];
    mp.name = name;
    
    if (pm)
        pm(mp);
    
    [self addOperation:mp];
    
    // 打印
    [mp.signals connect:kSignalDone withSelector:@selector(__pm_done:) ofTarget:self];
}

- (void)start {
    [super start];
}

- (void)__pm_done:(SSlot*)s {
    [self log:(id)s.sender];
}

- (void)log:(NSPerformanceMeasure *)pm {
    [pm log:pm.name];
}

@end

@implementation NSCallstackRecord

- (void)onFin {
    ZERO_RELEASE(_module);
    ZERO_RELEASE(_function);
    [super onFin];
}

+ (instancetype)recordWithCallstackString:(NSString*)str {
    NSArray* comps = [str componentsSeparatedByString:@" " skipSpace:YES];
    NSCallstackRecord* rcd = [NSCallstackRecord temporary];
    rcd.idx = [[comps objectAtIndex:0] intValue] - 1;
    rcd.module = [comps objectAtIndex:1];
    rcd.address = [[comps objectAtIndex:2] hexPointerValue];
    rcd.function = BLOCK_RETURN({
        NSString* l = [comps objectAtIndex:3];
        NSString* r = [comps objectAtIndex:4];
        return [NSString stringWithFormat:@"%@ %@" COMMA l COMMA r];
    });
    return rcd;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"%ld %@ 0x%tx %@", (long)_idx, _module, _address, _function];
}

@end

@implementation NSDiagnostic

+ (NSArray*)Callstacks {
    NSMutableArray* ret = [NSMutableArray temporary];
    void* callstack[128];
    int i, frames = backtrace(callstack, 128);
    char** strs = backtrace_symbols(callstack, frames);
    
    // 从1开始因为需要忽略掉 Callstacks 自身的调用
    for (i = 1; i < frames; ++i) {
        NSString* str = [NSString stringWithFormat:@"%s", strs[i]];
        [ret addObject:[NSCallstackRecord recordWithCallstackString:str]];
    }
    free(strs);
    
    return ret;
}

+ (NSCallstackRecord*)queryCallstack:(BOOL(^)(NSString*))query {
    void* callstack[128];
    int i, frames = backtrace(callstack, 128);
    char** strs = backtrace_symbols(callstack, frames);
    
    for (i = 1; i < frames; ++i) {
        NSString* str = [NSString stringWithFormat:@"%s", strs[i]];
        if (query(str)) {
            free(strs);
            return [NSCallstackRecord recordWithCallstackString:str];
        }
    }
    
    free(strs);
    return nil;
}

+ (NSCallstackRecord*)callstackForSelector:(SEL)sel {
    NSString* ssel = NSStringFromSelector(sel);
    return [self.class queryCallstack:^BOOL(NSString *str) {
        return [str containsString:ssel];
    }];
}

@end

@interface NSTrailChange ()
{
    ::std::map<NSString*, NSULongLong> _objlifes;
}

@end

static BOOL __gs_changed = NO;

@implementation NSTrailChange

SHARED_IMPL;

+ (void)Record {
    __gs_changed = NO;
}

+ (void)Clear {
    __gs_changed = NO;
}

+ (BOOL)IsChanged {
    return __gs_changed;
}

+ (void)SetChange {
    __gs_changed = YES;
}

# ifdef DEBUG_MODE

- (void)objectIsIniting:(id)obj {
    auto fnd = _objlifes.find([obj class]);
    if (fnd == _objlifes.end())
        _objlifes[[obj class]] = 1;
    else
        ++fnd->second;
}

- (void)objectIsFining:(id)obj {
    auto fnd = _objlifes.find([obj class]);
    if (fnd != _objlifes.end())
        --fnd->second;
    else
        LOG("%s 还没有被拦截到 init", objc_getClassName(obj));
}

- (NSULongLong)countOfType:(Class)cls {
    auto fnd = _objlifes.find(cls);
    if (fnd == _objlifes.end())
        return 0;
    return fnd->second;
}

# endif

@end

# define CH2PY_TABLE_SIZE 396
static int gs_pinyin_code [CH2PY_TABLE_SIZE] = {
    -20319,-20317,-20304,-20295,-20292,-20283,-20265,-20257,-20242,-20230,-20051,-20036,-20032,-20026,-20002,-19990,-19986,-19982,-19976,-19805,-19784,-19775,-19774,-19763,-19756,-19751,-19746,-19741,-19739,-19728,-19725,-19715,-19540,-19531,-19525,-19515,-19500,-19484,-19479,-19467,-19289,-19288,-19281,-19275,-19270,-19263,-19261,-19249,-19243,-19242,-19238,-19235,-19227,-19224,-19218,-19212,-19038,-19023,-19018,-19006,-19003,-18996,-18977,-18961,-18952,-18783,-18774,-18773,-18763,-18756,-18741,-18735,-18731,-18722,-18710,-18697,-18696,-18526,-18518,-18501,-18490,-18478,-18463,-18448,-18447,-18446,-18239,-18237,-18231,-18220,-18211,-18201,-18184,-18183,-18181,-18012,-17997,-17988,-17970,-17964,-17961,-17950,-17947,-17931,-17928,-17922,-17759,-17752,-17733,-17730,-17721,-17703,-17701,-17697,-17692,-17683,-17676,-17496,-17487,-17482,-17468,-17454,-17433,-17427,-17417,-17202,-17185,-16983,-16970,-16942,-16915,-16733,-16708,-16706,-16689,-16664,-16657,-16647,-16474,-16470,-16465,-16459,-16452,-16448,-16433,-16429,-16427,-16423,-16419,-16412,-16407,-16403,-16401,-16393,-16220,-16216,-16212,-16205,-16202,-16187,-16180,-16171,-16169,-16158,-16155,-15959,-15958,-15944,-15933,-15920,-15915,-15903,-15889,-15878,-15707,-15701,-15681,-15667,-15661,-15659,-15652,-15640,-15631,-15625,-15454,-15448,-15436,-15435,-15419,-15416,-15408,-15394,-15385,-15377,-15375,-15369,-15363,-15362,-15183,-15180,-15165,-15158,-15153,-15150,-15149,-15144,-15143,-15141,-15140,-15139,-15128,-15121,-15119,-15117,-15110,-15109,-14941,-14937,-14933,-14930,-14929,-14928,-14926,-14922,-14921,-14914,-14908,-14902,-14894,-14889,-14882,-14873,-14871,-14857,-14678,-14674,-14670,-14668,-14663,-14654,-14645,-14630,-14594,-14429,-14407,-14399,-14384,-14379,-14368,-14355,-14353,-14345,-14170,-14159,-14151,-14149,-14145,-14140,-14137,-14135,-14125,-14123,-14122,-14112,-14109,-14099,-14097,-14094,-14092,-14090,-14087,-14083,-13917,-13914,-13910,-13907,-13906,-13905,-13896,-13894,-13878,-13870,-13859,-13847,-13831,-13658,-13611,-13601,-13406,-13404,-13400,-13398,-13395,-13391,-13387,-13383,-13367,-13359,-13356,-13343,-13340,-13329,-13326,-13318,-13147,-13138,-13120,-13107,-13096,-13095,-13091,-13076,-13068,-13063,-13060,-12888,-12875,-12871,-12860,-12858,-12852,-12849,-12838,-12831,-12829,-12812,-12802,-12607,-12597,-12594,-12585,-12556,-12359,-12346,-12320,-12300,-12120,-12099,-12089,-12074,-12067,-12058,-12039,-11867,-11861,-11847,-11831,-11798,-11781,-11604,-11589,-11536,-11358,-11340,-11339,-11324,-11303,-11097,-11077,-11067,-11055,-11052,-11045,-11041,-11038,-11024,-11020,-11019,-11018,-11014,-10838,-10832,-10815,-10800,-10790,-10780,-10764,-10587,-10544,-10533,-10519,-10331,-10329,-10328,-10322,-10315,-10309,-10307,-10296,-10281,-10274,-10270,-10262,-10260,-10256,-10254
};

static char const* gs_pinyin_string [CH2PY_TABLE_SIZE] = {
"a","ai","an","ang","ao","ba","bai","ban","bang","bao","bei","ben","beng","bi","bian","biao","bie","bin","bing","bo","bu","ca","cai","can","cang","cao","ce","ceng","cha","chai","chan","chang","chao","che","chen","cheng","chi","chong","chou","chu","chuai","chuan","chuang","chui","chun","chuo","ci","cong","cou","cu","cuan","cui","cun","cuo","da","dai","dan","dang","dao","de","deng","di","dian","diao","die","ding","diu","dong","dou","du","duan","dui","dun","duo","e","en","er","fa","fan","fang","fei","fen","feng","fo","fou","fu","ga","gai","gan","gang","gao","ge","gei","gen","geng","gong","gou","gu","gua","guai","guan","guang","gui","gun","guo","ha","hai","han","hang","hao","he","hei","hen","heng","hong","hou","hu","hua","huai","huan","huang","hui","hun","huo","ji","jia","jian","jiang","jiao","jie","jin","jing","jiong","jiu","ju","juan","jue","jun","ka","kai","kan","kang","kao","ke","ken","keng","kong","kou","ku","kua","kuai","kuan","kuang","kui","kun","kuo","la","lai","lan","lang","lao","le","lei","leng","li","lia","lian","liang","liao","lie","lin","ling","liu","long","lou","lu","lv","luan","lue","lun","luo","ma","mai","man","mang","mao","me","mei","men","meng","mi","mian","miao","mie","min","ming","miu","mo","mou","mu","na","nai","nan","nang","nao","ne","nei","nen","neng","ni","nian","niang","niao","nie","nin","ning","niu","nong","nu","nv","nuan","nue","nuo","o","ou","pa","pai","pan","pang","pao","pei","pen","peng","pi","pian","piao","pie","pin","ping","po","pu","qi","qia","qian","qiang","qiao","qie","qin","qing","qiong","qiu","qu","quan","que","qun","ran","rang","rao","re","ren","reng","ri","rong","rou","ru","ruan","rui","run","ruo","sa","sai","san","sang","sao","se","sen","seng","sha","shai","shan","shang","shao","she","shen","sheng","shi","shou","shu","shua","shuai","shuan","shuang","shui","shun","shuo","si","song","sou","su","suan","sui","sun","suo","ta","tai","tan","tang","tao","te","teng","ti","tian","tiao","tie","ting","tong","tou","tu","tuan","tui","tun","tuo","wa","wai","wan","wang","wei","wen","weng","wo","wu","xi","xia","xian","xiang","xiao","xie","xin","xing","xiong","xiu","xu","xuan","xue","xun","ya","yan","yang","yao","ye","yi","yin","ying","yo","yong","you","yu","yuan","yue","yun","za","zai","zan","zang","zao","ze","zei","zen","zeng","zha","zhai","zhan","zhang","zhao","zhe","zhen","zheng","zhi","zhong","zhou","zhu","zhua","zhuai","zhuan","zhuang","zhui","zhun","zhuo","zi","zong","zou","zu","zuan","zui","zun","zuo"
};

NSString* chinese2pinyin(unichar ch) {
    NSString* str = @"";
    if (ch < 0xA1) {
        str = [NSString stringWithCharacters:&ch length:1];
    } else {
        short_b8* b8 = (short_b8*)&ch;
        int charasc = (byte)b8->_0 * 256 + (byte)b8->_1 - 65536;
        if (charasc > 0 && charasc < 0xA1) {
            str = [NSString stringWithCharacters:&ch length:1];
        } else if (charasc < -20319 || charasc > -10247) {
            PASS;
        } else {
            for (int i = CH2PY_TABLE_SIZE - 1; i >= 0; --i) {
                if (gs_pinyin_code[i] <= charasc) {
                    str = [NSString stringWithCString:gs_pinyin_string[i] encoding:NSASCIIStringEncoding];
                    break;
                }
            }
        }
    }
    return str;
}

NSArray* chinese2pinyin_stream(void const* __buf, size_t len) {
    NSMutableArray* ret = [[NSMutableArray alloc] initWithCapacity:len];
    byte const* buf = (byte const*)__buf;
    NSString *lstchn = nil, *lsten = nil;
    for (int idx = 0; idx < len; ++idx, ++buf) {
        byte one = *buf;
        if (one < 0xA1) {
            if (lstchn) {
                [ret addObject:lstchn];
                lstchn = nil;
            }
            
            NSString* tmp = chinese2pinyin(one);
            if (tmp == nil)
                tmp = @"";
            
            if (lsten == nil)
                lsten = tmp;
            else
                lsten = [lsten stringByAppendingString:tmp];
        } else {
            if (lsten) {
                [ret addObject:lsten];
                lsten = nil;
            }
            unichar one = *(unichar const*)buf;
            NSString* tmp = chinese2pinyin(one);
            if (tmp == nil)
                tmp = @"";
            
            if (lstchn == nil)
                lstchn = tmp;
            else
                lstchn = [lstchn stringByAppendingString:tmp];
            
            ++buf;
            ++idx;
        }
    }
    if (lsten) {
        [ret addObject:lsten];
    }
    if (lstchn) {
        [ret addObject:lstchn];
    }
    return [ret autorelease];
}

@implementation NSPinyin

+ (NSArray*)StringToPinyin:(NSString *)str {
    NSData* data = [str dataUsingEncoding:NSGB18030Encoding];
    NSArray* arr = chinese2pinyin_stream([data bytes], [data length]);
    return arr;
}

+ (NSString*)StringFirstNew:(NSString *)str {
    NSArray* arr = [[self class] StringToPinyin:[str stringAtIndex:0]];
    return [arr.firstObject stringAtIndex:0];
}

@end

@implementation NSIndexPath (extension)

- (BOOL)isSameSection:(NSUInteger)section {
    return self.section == section;
}

- (BOOL)isSameRow:(NSUInteger)row {
    return self.row == row;
}

- (BOOL)isSameCell:(NSIndexPath *)ip {
    if (ip == nil)
        return NO;
    return self.section == ip.section &&
    self.row == ip.row;
}

@end

@implementation NSIndexSet (extension)

+ (instancetype)indexSetWithArray:(NSArray*)arr {
    NSMutableIndexSet* set = [NSMutableIndexSet indexSet];
    for (id each in arr) {
        [set addIndex:[each unsignedIntegerValue]];
    }
    return [[[self.class alloc] initWithIndexSet:set] autorelease];
}

@end
