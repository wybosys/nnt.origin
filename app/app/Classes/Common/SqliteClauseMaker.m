
# import "Common.h"
# import "SqliteClauseMaker.h"

@implementation SqlString

- (id)init {
    self = [super init];
    _str = [[NSMutableString alloc] init];
    return self;
}

- (void)dealloc {
    SAFE_RELEASE(_str);
    [super dealloc];
}

+ (id)string {
    return [[[SqlString alloc] init] autorelease];
}

- (id)space {
    [_str appendString:@" "];
    return self;
}

- (id)append:(NSString*)str {
    if (str == nil)
        return self;
    
    [_str appendString:str];
    return self;
}

- (id)format:(NSString *)fmt, ... {
    if (fmt == nil)
        return self;
    
    va_list va;
    va_start(va, fmt);
    NSMutableString* tmp = [[NSMutableString alloc] initWithFormat:fmt arguments:va];
    [_str appendString:tmp];
    [tmp release];
    va_end(va);
    return self;
}

- (NSString*)sql {
    return _str;
}

@end

@implementation SqlVariable

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_name);
    ZERO_RELEASE(_value);
    
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    SqlVariable* ret = [[[self class] alloc] init];
    
    ret.name = _value;
    ret.value = _value;
    
    return ret;
}

@end

@implementation SqlClause

@synthesize variables = _variables, subClauses = _subclauses;

- (id)init {
    self = [super init];
    
    self.sql = @"";
    
    _variables = [[NSMutableArray alloc] init];
    _subclauses = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_sql);
    ZERO_RELEASE(_variables);
    ZERO_RELEASE(_subclauses);
                 
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    SqlClause* ret = [[[self class] alloc] init];
    
    ret.variables = [_variables deepCopy];
    ret.subClauses = [_subclauses deepCopy];
    
    return ret;
}

- (id)addClause:(SqlClause *)cl {
    [_subclauses addObject:cl];
    return self;
}

- (NSArray*)names {
    NSMutableArray* ret = [NSMutableArray array];
    
    for (SqlVariable* each in _variables) {
        if (each.name == nil)
            continue;
        [ret addObject:each.name];
    }
    
    return ret;
}

- (NSArray*)params {
    NSMutableArray* ret = [NSMutableArray array];
    
    /*
    for (SqlVariable* each in _variables) {
        [ret addObject:each.value];
    }
     */
    
    for (SqlClause* each in _subclauses) {
        [ret addObjectsFromArray:each.params];
    }
    
    return ret;
}

+ (instancetype)SQL:(NSString *)sql {
    SqlClause* ret = [[self alloc] init];
    ret.sql = sql;
    return [ret autorelease];
}

@end

@implementation SqlClauseArgument

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_operation);
    
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    SqlClauseArgument* ret = [super copyWithZone:zone];
    
    ret.operation = _operation;
    
    return ret;
}

- (id)addObject:(id)obj {
    SqlVariable* var = [[SqlVariable alloc] init];
    var.name = @"?";
    var.value = obj;
    [_variables addObject:var];
    SAFE_RELEASE(var);
    return self;
}

- (id)addString:(NSString *)str {
    SqlVariable* var = [[SqlVariable alloc] init];
    var.name = str;
    var.value = str;
    [_variables addObject:var];
    SAFE_RELEASE(var);
    return self;
}

@end

@implementation SqlClauseCollect

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (NSString*)sql {
    SqlString* ret = [SqlString string];
    
    NSArray* names = self.names;
    if (names.count)
        [[ret append:[names componentsJoinedByString:@","]] space];
    
    return ret.sql;
}

@end

@implementation SqlClauseFrom

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (NSString*)sql {
    SqlString* ret = [SqlString string];
    [[ret append:@"from"] space];
    
    SqlVariable* var = _variables.firstObject;
    [[ret append:var.value] space];
    
    return ret.sql;
}

@end

@implementation SqlClauseGroupby

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (NSString*)sql {
    SqlString* ret = [SqlString string];
    [[ret append:@"group by"] space];
    
    SqlVariable* var = _variables.firstObject;
    [[ret append:var.value] space];
    
    return ret.sql;
}

@end

@implementation SqlClauseOrderby

- (id)init {
    self = [super init];
    
    _asc = YES;
    
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    SqlClauseOrderby* ret = [super copyWithZone:zone];
    
    ret.asc = _asc;
    
    return ret;
}

- (NSString*)sql {
    SqlString* ret = [SqlString string];
    [[ret append:@"order by"] space];
    
    SqlVariable* var = _variables.firstObject;
    [[ret append:var.value] space];
    
    if (_asc == NO)
        [[ret append:@"desc"] space];
    
    return ret.sql;
}

@end

@implementation SqlClauseLimit

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc{
    SAFE_RELEASE(_limit);
    SAFE_RELEASE(_offset);
    
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    SqlClauseLimit* ret = [super copyWithZone:zone];
    
    SAFE_COPY(ret.limit, _limit);
    SAFE_COPY(ret.offset, _offset);
    
    return ret;
}

- (NSString*)sql {
    SqlString* ret = [SqlString string];
    
    if (_subclauses)
        [[ret append:[_subclauses.firstObject sql]] space];
    
    if (_limit)
        [[ret format:@"limit %d", _limit.integerValue] space];
    
    if (_offset)
        [[ret format:@"offset %d", _offset.integerValue] space];
    
    return ret.sql;
}

- (NSArray*)params {
    NSMutableArray* ret = [NSMutableArray array];
 
    if (_subclauses)
        [ret addObjectsFromArray:[_subclauses.firstObject params]];
    
    return ret;
}

@end

@implementation SqlClauseWhere

- (id)init {
    self = [super init];
    self.operation = @"and";
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_operation);
    [super dealloc];
}

- (id)ands {
    self.operation = @"and";
    return self;
}

- (id)ors {
    self.operation = @"or";
    return self;
}

+ (id)where:(NSString *)name operation:(NSString *)oper value:(id)value {
    SqlClauseWhere* ret = [[[SqlClauseWhere alloc] init] autorelease];
    return [ret where:name operation:oper value:value];
}

- (id)where:(NSString *)name operation:(NSString *)oper value:(id)value {
    SqlClauseArgument* argu = [[SqlClauseArgument alloc] init];
    argu.operation = oper;
    
    SqlVariable* var = [[SqlVariable alloc] init];
    var.name = name;
    var.value = value;
    [argu.variables addObject:var];
    
    [self addClause:argu];
    
    SAFE_RELEASE(var);
    SAFE_RELEASE(argu);
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    SqlClauseWhere* ret = [super copyWithZone:zone];
    ret.operation = self.operation;
    return ret;
}

- (NSString*)sql {
    SqlString* ret = [SqlString string];
    
    if (_inner == NO)
        [[ret append:@"where"] space];
    
    NSMutableArray* comps = [NSMutableArray array];
    
    for (SqlClause* each in _subclauses) {        
        if ([each isKindOfClass:[SqlClauseArgument class]]) {
        
            SqlClauseArgument* argu = (SqlClauseArgument*)each;
            SqlVariable* var = argu.variables.firstObject;
            
            SqlString* sql = [SqlString string];
            
            [[sql append:var.name] space];
            [[sql append:argu.operation] space];
            [[sql append:@"?"] space];
            
            if (comps.count)
                [comps addObject:self.operation];
                
            [comps addObject:sql.sql];
            continue;
        }
        
        if ([each isKindOfClass:[SqlClauseWhere class]]) {
            
            SqlClauseWhere* cw = (SqlClauseWhere*)each;
            cw->_inner = YES;

            SqlString* sql = [SqlString string];
            [sql append:@"("];
            [sql append:cw.sql];
            [[sql append:@")"] space];
            
            if (comps.count)
                [comps addObject:cw.operation];
            
            [comps addObject:sql.sql];
            continue;
        }
    }
    
    [ret append:[comps componentsJoinedByString:@" "]];    
    return ret.sql;
}

- (NSArray*)params {
    NSMutableArray* ret = [NSMutableArray array];
 
    for (SqlClause* each in _subclauses) {
        
        if ([each isKindOfClass:[SqlClauseArgument class]]) {
        
            SqlClauseArgument* argu = (SqlClauseArgument*)each;
            SqlVariable* var = argu.variables.firstObject;
        
            if (var.value) {
                [ret addObject:var.value];  
            }
            
            continue;
        }
        
        if ([each isKindOfClass:[SqlClauseWhere class]]) {
            
            SqlClauseWhere* cw = (SqlClauseWhere*)each;
            if (cw.params) {
                [ret addObjectsFromArray:cw.params];
            }
            
            continue;
        }
        
    }
    
    return ret;
}

@end

@implementation SqlClauseSelect

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    SAFE_RELEASE(_collect);
    SAFE_RELEASE(_from);
    SAFE_RELEASE(_groupby);
    SAFE_RELEASE(_orderby);
    SAFE_RELEASE(_limit);
    SAFE_RELEASE(_where);
    
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    SqlClauseSelect* ret = [super copyWithZone:zone];
    
    SAFE_COPY(ret.collect, _collect);
    SAFE_COPY(ret.from, _from);
    SAFE_COPY(ret.groupby, _groupby);
    SAFE_COPY(ret.orderby, _orderby);
    SAFE_COPY(ret.limit, _limit);
    SAFE_COPY(ret.where, _where);
    
    return ret;
}

- (id)collect:(NSString *)value {
    SqlClauseCollect* cl = [[SqlClauseCollect alloc] init];
    [cl addString:value];
    self.collect = cl;
    SAFE_RELEASE(cl);
    return self;
}

- (id)fromString:(NSString *)str {
    SqlClauseFrom* cl = [[SqlClauseFrom alloc] init];
    [cl addObject:str];
    self.from = cl;
    SAFE_RELEASE(cl);
    return self;
}

- (id)groupbyString:(NSString *)str {
    SqlClauseGroupby* cl = [[SqlClauseGroupby alloc] init];
    [cl addObject:str];
    self.groupby = cl;
    SAFE_RELEASE(cl);
    return self;
}

- (id)orderbyString:(NSString *)str {
    return [self orderbyString:str asc:YES];
}

- (id)orderbyString:(NSString*)str asc:(BOOL)asc {
    SqlClauseOrderby* cl = [[SqlClauseOrderby alloc] init];
    cl.asc = asc;
    [cl addObject:str];
    self.orderby = cl;
    SAFE_RELEASE(cl);
    return self;
}

- (id)limitBy:(NSNumber *)limit offset:(NSNumber *)offset {
    SqlClauseLimit* cl = [[SqlClauseLimit alloc] init];
    cl.limit = limit;
    cl.offset = offset;
    self.limit = cl;
    SAFE_RELEASE(cl);
    return self;
}

- (id)where:(NSString *)name operation:(NSString *)oper value:(id)value {
    [self.where where:name operation:oper value:value];
    return self;
}

- (id)where:(SqlClauseWhere *)cw {
    if (_where == nil) {
        self.where = cw;
        return self;
    }
    
    [self.where addClause:cw];    
    return self;
}

- (SqlClauseWhere*)where {
    if (_where == nil)
        _where = [[SqlClauseWhere alloc] init];
    return _where;
}

- (NSString*)sql {
    SqlString* ret = [SqlString string];
    
    if (_subclauses.count) {
        [ret append:@"select * from ("];
        [ret append:[_subclauses.firstObject sql]];
        [ret append:@")"];
    } else {
        [[ret append:@"select"] space];
    }
    
    [ret append:_collect.sql];
    [ret append:_from.sql];
    [ret append:_where.sql];
    [ret append:_groupby.sql];
    [ret append:_orderby.sql];
    [ret append:_limit.sql];
    
    return ret.sql;
}

- (NSArray*)params {
    NSMutableArray* ret = [NSMutableArray array];
    
    if (_subclauses.count) {
        [ret addObjectsFromArray:[_subclauses.firstObject params]];
    }
    
    [ret addObjectsFromArray:_collect.params];
    [ret addObjectsFromArray:_from.params];
    [ret addObjectsFromArray:_where.params];
    [ret addObjectsFromArray:_groupby.params];
    [ret addObjectsFromArray:_orderby.params];
    [ret addObjectsFromArray:_limit.params];
    
    return ret;
}

@end

@implementation SqlClauseFunction

+ (id)clauseWithFunction:(NSString*)func {
    return [[[self alloc] initWithFunction:func] autorelease];
}

- (id)initWithFunction:(NSString *)func {
    self = [self init];
    self.function = func;
    return self;
}

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_function);
    [super dealloc];
}

- (NSString*)sql {
    SqlString* ret = [SqlString string];
    
    if (_subclauses.count) {
        [ret format:@"select %@ from (", _function];
        [ret append:[_subclauses.firstObject sql]];
        [ret append:@")"];
    }
    
    return ret.sql;
}

@end

@implementation SqlClauseCount

- (id)init {
    self = [super init];
    self.function = @"count(*)";
    return self;
}

- (void)dealloc {
    [super dealloc];
}

@end

@implementation SqlClauseJoin

- (id)init {
    self = [super init];
    self.full = NO;
    return self;
}

@end
