 
# import "Common.h"
# import "NSStorage.h"
# import "DBOracleBDB.h"
# import "DBConfig.h"
# import "FileSystem+Extension.h"
# import <Security/Security.h>

@implementation NSStorageInfo

@end

@interface NSStorageExt () {
    OracleBDB* _bdb;
}

@end

@implementation NSStorageExt

SHARED_IMPL;

- (id)init {
    self = [super init];
    
    _autoSync = YES;
    _bdb = [[OracleBDB alloc] init];
    
    DBConfig* dbcnf = [DBConfig config];
    dbcnf.path = [[FSApplication shared] pathWritable:@"storage.db"];
    [_bdb open:dbcnf];
    
    return self;
}

- (id)initWithPath:(NSString *)path {
    self = [super init];
    
    _autoSync = YES;
    _bdb = [[OracleBDB alloc] init];
    
    DBConfig* dbcnf = [DBConfig config];
    dbcnf.path = path;
    [_bdb open:dbcnf];
    
    return self;
}

+ (NSStorageExt*)storageForPath:(NSString *)path {
    return [[[NSStorageExt alloc] initWithPath:path] autorelease];
}

- (void)dealloc {
    ZERO_RELEASE(_bdb);
    
    [super dealloc];
}

- (BOOL)exists:(NSString *)key {
    return [_bdb exist:key];
}

- (void)doSync {
    if (_autoSync)
        [_bdb sync];
}

- (void)setBool:(bool)v forKey:(NSString *)key {
    [_bdb setBool:v forKey:key];
    [self doSync];
}

- (void)setInteger:(NSInteger)v forKey:(NSString*)key {
    [_bdb setInteger:v forKey:key];
    [self doSync];
}

- (void)setFloat:(float)v forKey:(NSString*)key {
    [_bdb setObject:@(v) forKey:key];
    [self doSync];
}

- (void)setDouble:(double)v forKey:(NSString*)key {
    [_bdb setObject:@(v) forKey:key];
    [self doSync];
}

- (void)setString:(NSString *)v forKey:(NSString *)key {
    [_bdb setObject:v forKey:key];
    [self doSync];
}

- (void)setObject:(id<NSCoding>)v forKey:(NSString*)key {
    [_bdb setObject:v forKey:key];
    [self doSync];
}

- (bool)getBoolForKey:(NSString *)key def:(bool)def {
    id ret = [_bdb objectForKey:key];
    if (ret == nil)
        return def;
    return [ret boolValue];
}

- (NSInteger)getIntegerForKey:(NSString*)key def:(int)def {
    id ret = [_bdb objectForKey:key];
    if (ret == nil)
        return def;
    return [ret integerValue];
}

- (float)getFloatForKey:(NSString*)key def:(float)def {
    id ret = [_bdb objectForKey:key];
    if (ret == nil)
        return def;
    return [ret floatValue];
}
- (double)getDoubleForKey:(NSString*)key def:(double)def {
    id ret = [_bdb objectForKey:key];
    if (ret == nil)
        return def;
    return [ret doubleValue];
}

- (NSString*)getStringForKey:(NSString*)key def:(NSString*)def {
    id ret = [_bdb objectForKey:key];
    if (ret == nil)
        return def;
    return [ret stringValue];
}

- (NSData*)getDataForKey:(NSString *)key def:(NSData *)def {
    id ret = [_bdb objectForKey:key];
    if (ret == nil)
        return def;
    //if ([ret isKindOfClass:[NSData data]])
    //    return ret;
    //if ([ret isKindOfClass:[NSMutableData data]])
    //    return ret;
    return ret;
}

- (id)getObjectForKey:(NSString *)key def:(id)def {
    id ret = [_bdb objectForKey:key];
    if (ret == nil)
        return def;
    return ret;
}

- (void)addObject:(id<NSCoding>)v arrayKey:(NSString*)key {
    NSMutableArray* arr = [self getObjectForKey:key def:nil];
    if (arr == nil)
        arr = [NSMutableArray temporary];
    [arr addObject:v];
    [self setObject:arr forKey:key];
}

- (id)objectAtIndex:(NSUInteger)idx arrayKey:(NSString*)key def:(id)def {
    NSMutableArray* arr = [self getObjectForKey:key def:nil];
    return [arr objectAtIndex:idx def:def];
}

- (id)objectAtIndex:(NSUInteger)idx arrayKey:(NSString*)key {
    return [self objectAtIndex:idx arrayKey:key def:nil];
}


- (BOOL)remove:(NSString *)key {
    if ([_bdb removeForKey:key]) {
        [self doSync];
        return YES;
    }
    return NO;
}

- (void)sync {
    [_bdb sync];
}

- (NSStorageInfo*)info {
    NSStorageInfo* ret = [NSStorageInfo temporary];
    
    OracleBDBInfo* info = _bdb.info;
    ret.size = info.size;
    
    return ret;
}

- (void)clear {
    [_bdb clear];
}

- (void)foreach:(BOOL(^)(id k, id v))block {
    [_bdb foreach:block];
}

@end

@implementation NSPersistentStorageService

SHARED_IMPL;

static NSString* kNSPersistentStorageServiceType = @"::ns::service::persistentstorage";

- (void)setObject:(id<NSCoding>)obj forKey:(NSString*)key {
    if ([self exists:key])
        [self remove:key];
    
    NSData* daobj = [NSKeyedArchiver archivedDataWithRootObject:obj def:nil];
    if (daobj == nil) {
        WARN("序列化一个对象失败");
        return;
    }
    
    NSDictionary* ks = @{
                         (id)kSecClass: (id)kSecClassGenericPassword,
                         (id)kSecAttrAccount: key,
                         (id)kSecAttrLabel: kNSPersistentStorageServiceType,
                         (id)kSecAttrGeneric: daobj
                         };
    
    OSStatus sta = SecItemAdd((CFDictionaryRef)ks, NULL);
    if (sta != errSecSuccess) {
        INFO("持久化对象失败 %d", sta);
    }
}

- (id)getObjectForKey:(NSString*)key def:(id)def {
    NSDictionary* ks = @{
                         (id)kSecClass: (id)kSecClassGenericPassword,
                         (id)kSecAttrAccount: key,
                         (id)kSecAttrLabel: kNSPersistentStorageServiceType,
                         (id)kSecReturnAttributes: (id)kCFBooleanTrue
                         };
    
    NSDictionary* result;
    OSStatus sta = SecItemCopyMatching((CFDictionaryRef)ks, (CFTypeRef*)&result);
    if (sta == errSecItemNotFound)
        return def;
    if (sta == errSecSuccess) {
        NSData* da = [result objectForKey:(id)kSecAttrGeneric def:nil];
        if (da == nil)
            return def;
        return [NSKeyedUnarchiver unarchiveObjectWithData:da def:def];
    }
    return nil;
}

- (BOOL)remove:(NSString*)key {
    NSDictionary* ks = @{
                         (id)kSecClass: (id)kSecClassGenericPassword,
                         (id)kSecAttrAccount: key,
                         (id)kSecAttrLabel: kNSPersistentStorageServiceType
                         };
    
    OSStatus sta = SecItemDelete((CFDictionaryRef)ks);
    return sta == errSecSuccess;
}

- (BOOL)exists:(NSString *)key {
    NSDictionary* ks = @{
                         (id)kSecClass: (id)kSecClassGenericPassword,
                         (id)kSecAttrAccount: key,
                         (id)kSecAttrLabel: kNSPersistentStorageServiceType,
                         };
    OSStatus sta = SecItemCopyMatching((CFDictionaryRef)ks, NULL);
    return sta != errSecItemNotFound;
}

@end
