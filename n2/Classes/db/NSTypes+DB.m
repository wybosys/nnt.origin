
# import "Common.h"
# import "NSTypes+DB.h"

@implementation DBObject

- (void)onInit {
    [super onInit];
}

- (void)onFin {
    [super onFin];
}

- (NSString*)description {
    NSArray* cols = self.dbcolumns;
    NSMutableString* str = [NSMutableString string];
    if (self.dbidobj)
        [str appendFormat:@"dbid = %d, ", self.dbid];
    for (DBColumnObject* col in cols) {
        NSString* path = col.path;
        id val = [self valueForKeyPath:path def:nil];
        if (val == nil)
            continue;
        NSString* name = col.name;
        [str appendFormat:@"%@ = %@, ", name, val];
    }
    [str appendString:@"\n"];
    return str;
}

@end

@implementation NSObject (db)

- (NSArray*)dbcolumns {
    if ([self conformsToProtocol:@protocol(DBObject)] == NO)
        return nil;
    
    Class cls = [self class];
    
    NSMutableArray* cols = [NSMutableArray array];
    
    [NSClass ForeachProperty:^BOOL(objc_property_t *prop) {
        id propObj = object_getPropertyObject(self, *prop);
        if ([propObj isKindOfClass:[DBColumnObject class]] == NO)
            return YES;
        [cols addObject:propObj];
        return YES;
    }
                    forClass:cls
                  forProtocol:@protocol(DBObject)
     ];
    
    return cols;
}

+ (NSArray*)DBColumns {
    Class cls = [self class];
    
    if ([NSClass Implement:cls forProtocol:@protocol(DBObject)] == NO)
        return nil;
    
    id tmpobj = [[cls alloc] init];
    NSArray* arr = [tmpobj dbcolumns];
    SAFE_RELEASE(tmpobj);
    
    return arr;
}

@dynamic dbid;
@dynamic dbidobj;

- (int)dbid {
    return [[[self attachment] strong] getInt:@"::db::__id__" def:-1];
}

- (void)setDbid:(int)dbid {
    [[[self attachment] strong] setInt:dbid forKey:@"::db::__id__"];
}

- (id)dbidobj {
    return [[[self attachment] strong] objectForKey:@"::db::__id__" def:nil];
}

- (void)setDbidobj:(id)dbidobj {
    ASSERTMSG(self.dbidobj == nil, @"设置一个已经存在 dbid 的记录");
    [[[self attachment] strong] setObject:dbidobj forKey:@"::db::__id__"];
}

- (BOOL)dbEqual:(NSObject<DBObject> *)obj {
    if ([self class] != [obj class])
        return NO;
    __block BOOL ret = YES;
    [self foreachProperty:^BOOL(id key, id value) {
        if ([value isKindOfClass:[DBColumnObject class]] == NO)
            return YES;
        
        if ([value isEqualToValue:[obj valueForKey:key]] == NO) {
            ret = NO;
            return NO;
        }
        
        return YES;
    }];
    return ret;
}

@end

@implementation DBColumnObject

- (id)init {
    self = [super init];
    
    self.nullable = true;
    
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_name);
    ZERO_RELEASE(_path);
    ZERO_RELEASE(_defaultv);
    
    [super dealloc];
}

+ (DBColumnObject*)column {
    return [[[DBColumnObject alloc] init] autorelease];
}

- (void)setName:(NSString *)name {
    PROPERTY_COPY(_name, name);
    
    if (_path == nil)
        self.path = [_name stringByAppendingString:@".value"];
}

- (BOOL)isEqual:(id)r {
    if ([r isKindOfClass:[self class]] == NO)
        return NO;
    
    DBColumnObject* ro = (DBColumnObject*)r;
    BOOL suc = true;
    
    suc &= [_name isEqualToString:ro.name];
    suc &= [_path isEqualToString:ro.path];
    suc &= _type == ro.type;
    suc &= _length == ro.length;
    suc &= _decimals == ro.decimals;
    suc &= _autoincrement == ro.autoincrement;
    suc &= _primarykey == ro.primarykey;
    suc &= _nullable == ro.nullable;
    suc &= _unique == ro.unique;
    suc &= [NSString IsEqual:_defaultv ToString:ro.defaultv];
    
    return suc;
}

- (NSString*)description {
    return [[self valueForKey:@"value"] stringValue];
}

- (void)clear {
    [self performSelector:@selector(setValue:) withObject:nil];
    self.used = NO;
}

@end

static BOOL equal_String(DBColumnString* l, DBColumnString* r) {
    return [l.value isEqualToString:r.value];
}

static BOOL equal_Integer(DBColumnInteger* l, DBColumnInteger* r) {
    return l.value == r.value;
}

static BOOL equal_Float(DBColumnFloat* l, DBColumnFloat* r) {
    return l.value == r.value;
}

static BOOL equal_Double(DBColumnDouble* l, DBColumnDouble* r) {
    return l.value == r.value;
}

# define DBCOLUMNTYPE_IMPL(Name, Value, Prop, DBType) \
@implementation DBColumn##Name \
- (id)init { \
self = [super init]; \
self.type = DBColumnType##DBType; \
return self; } \
@synthesize value; \
- (void)setValue:(Value)v { \
PROPERTY_##Prop(value, v); \
self.used = YES; \
} \
- (void)dealloc { \
PROPERTY_##Prop##_RELEASE(value); \
[super dealloc]; \
} \
\
- (BOOL)isEqualToValue:(DBColumn##Name*)obj { \
return equal_##Name(self, obj); \
} \
@end

DBCOLUMNTYPE_IMPL(String, NSString*, COPY, Text);
DBCOLUMNTYPE_IMPL(Integer, NSInteger, ASSIGN, Integer);
DBCOLUMNTYPE_IMPL(Float, float, ASSIGN, Real);
DBCOLUMNTYPE_IMPL(Double, double, ASSIGN, Real);

@implementation DBColumnString (value)

- (NSString*)stringValue {
    return self.value;
}

@end

@implementation DBColumnInteger (value)

- (int)intValue {
    return self.value;
}

- (NSInteger)integerValue {
    return self.value;
}

- (NSUInteger)unsignedIntegerValue {
    return self.value;
}

@end

@implementation DBColumnFloat (value)

- (float)floatValue {
    return self.value;
}

- (double)doubleValue {
    return self.value;
}

@end

@implementation DBColumnDouble (value)

- (float)floatValue {
    return (float)self.value;
}

- (double)doubleValue {
    return self.value;
}

@end
