
# import "Common.h"
# import "DBScheme.h"
# import "SqliteClauseMaker.h"

@interface DBFilter ()
{
    NSMutableArray* _filters;
}

@end

@implementation DBFilter

@synthesize filters = _filters;

- (void)onInit {
    [super onInit];
    _filters = [[NSMutableArray alloc] init];
}

- (void)onFin {
    ZERO_RELEASE(_filters);
    [super onFin];
}

+ (instancetype)match:(id<DBObject>)a ands:(id<DBObject>)b {
    DBFilter* ret = [DBFilter temporary];
    [ret->_filters addObject:[self.class Head:a]];
    [ret->_filters addObject:[self.class And:b]];
    return ret;
}

+ (instancetype)match:(id<DBObject>)a ors:(id<DBObject>)b {
    DBFilter* ret = [DBFilter temporary];
    [ret->_filters addObject:[self.class Head:a]];
    [ret->_filters addObject:[self.class Or:b]];
    return ret;
}

- (id)ands:(id<DBObject>)o {
    DBFilter* df = [self.class And:o];
    [_filters addObject:df];
    return self;
}

- (id)ors:(id<DBObject>)o {
    DBFilter* df = [self.class Or:o];
    [_filters addObject:df];
    return self;
}

+ (instancetype)Head:(id<DBObject>)o {
    DBFilter* df = [DBFilter temporary];
    df.dbobj = o;
    return df;
}

+ (instancetype)And:(id<DBObject>)o {
    DBFilter* df = [DBFilter temporary];
    df.dbobj = o;
    df.type = FILTER_AND;
    return df;
}

+ (instancetype)Or:(id<DBObject>)o {
    DBFilter* df = [DBFilter temporary];
    df.dbobj = o;
    df.type = FILTER_OR;
    return df;
}

- (id)with:(DBFilter*)f {
    [_filters addObject:f];
    return self;
}

@end

@implementation DBScheme

- (void)onInit {
    [super onInit];
    _query = [[SqlClauseSelect alloc] init];
}

- (void)onFin {
    ZERO_RELEASE(_name);
    ZERO_RELEASE(_query);
    
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalDBSchemeChanged)
SIGNALS_END

- (BOOL)exists {
    return NO;
}

- (void)setName:(NSString *)name {
    if (_name == name)
        return;
    
    PROPERTY_COPY(_name, name);
    
    // 设置到sql
    [_query fromString:_name];
}

- (DBScheme*)addObject:(id<DBObject>)obj {
    return self;
}

- (DBScheme*)addObjects:(NSArray*)objs {
    return self;
}

- (DBScheme*)updateObject:(id<DBObject>)obj {
    return self;
}

- (DBScheme*)removeObject:(id<DBObject>)obj {
    return self;
}

- (DBScheme*)clear {
    return self;
}

- (instancetype)filter:(id<DBObject>)obj {
    return [self filter:obj comparsion:@"="];
}

- (instancetype)filter:(id<DBObject>)obj comparsion:(NSString *)comparsion {
    return self;
}

- (instancetype)filters:(DBFilter*)filter {
    return self;
}

- (BOOL)fetchObject:(id<DBObject>)obj atIndex:(NSUInteger)idx {
    NSArray* arr = [[NSArray alloc] initWithObject:obj];
    NSArray* ret = [self fetchObjects:arr fromIndex:idx];
    SAFE_RELEASE(arr);
    return ret.count != 0;
}

- (BOOL)fetchObject:(id<DBObject>)obj {
    return [self fetchObject:obj atIndex:0];
}

- (NSArray*)fetchObjects:(NSArray *)objs fromIndex:(NSUInteger)idx {
    return nil;
}

- (NSArray*)fetchObjects:(NSArray *)objs {
    return [self fetchObjects:objs fromIndex:0];
}

- (id)getObject:(Class)cls atIndex:(NSUInteger)idx {
    return nil;
}

- (id)getObject:(Class)cls {
    return [self getObject:cls atIndex:0];
}

- (NSArray*)getObjects:(Class)cls {
    return [self getObjects:cls fromIndex:0];
}

- (NSArray*)getObjects:(Class)cls fromIndex:(NSUInteger)idx {
    return nil;
}

- (BOOL)rollback {
    return NO;
}

- (BOOL)commit {
    return NO;
}

- (NSInteger)count {
    return 0;
}

- (NSUInteger)countObject:(id<DBObject>)obj {
    return 0;
}

- (NSArray*)query:(SqlClause*)clause {
    return nil;
}

@end

@implementation DBPaged

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_scheme);
    [super dealloc];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalDBSchemeChanged)
SIGNALS_END

- (id)initWithScheme:(DBScheme *)scheme {
    self = [self init];    
    self.scheme = scheme;
    return self;
}

+ (id)pagedWithScheme:(DBScheme *)scheme {
    return [[[[self class] alloc] initWithScheme:scheme] autorelease];
}

- (void)setIndex:(NSUInteger)index {
    if (_index == index)
        return;
    _index = index;
    [self updateSQLObject];
}

- (void)setCountForPage:(NSUInteger)countForPage {
    if (_countForPage == countForPage)
        return;
    _countForPage = countForPage;
    [self updateSQLObject];
}

- (void)updateSQLObject {
    [_scheme.query limitBy:[NSNumber numberWithUnsignedInteger:_countForPage]
                    offset:[NSNumber numberWithUnsignedInteger:_index * _countForPage]];
}

- (void)setScheme:(DBScheme *)scheme {
    if (_scheme == scheme)
        return;
    
    [_scheme.signals disconnectToTarget:self];
    
    PROPERTY_RETAIN(_scheme, scheme);
    
    [_scheme.signals connect:kSignalDBSchemeChanged ofTarget:self];
}

@end
