
# import "Common.h"
# import "DBSqlite.h"
# import "DBConfig.h"
# import "FMDatabase.h"
# import "FMDatabaseAdditions.h"
# import "NSTypes+Extension.h"
# import "SqliteClauseMaker.h"
# import "NSTypes+DB.h"
# import "NSWeakTypes.h"
# import <sqlite3.h>

@interface DBSqlite ()

@property (nonatomic, retain) FMDatabase* db;
@property (nonatomic, readonly) NSMutableArray* operations;

# ifdef DEBUG_MODE
@property (nonatomic, readonly) NSWeakArray* schemes;
# endif

@end

typedef enum {
    kDBOperationTypeInsert,
    kDBOperationTypeDelete,
    kDBOperationTypeUpdate,
} DBOperationType;

@interface DBOperationRecord : NSObjectExt

@property (nonatomic, copy) NSString *database, *table;
@property (nonatomic, assign) DBOperationType type;

@end

@interface FMResultSet (extension)

- (id)objectForColumnIndex:(int)columnIdx def:(id)def;
- (id)objectForColumnName:(NSString *)columnName def:(id)def;

@end

@implementation FMResultSet (extension)

- (id)objectForColumnIndex:(int)columnIdx def:(id)def {
    id ret = [self objectForColumnIndex:columnIdx];
    if ([ret isKindOfClass:[NSNull class]])
        return def;
    return ret;
}

- (id)objectForColumnName:(NSString *)columnName def:(id)def {
    id ret = [self objectForColumnName:columnName];
    if ([ret isKindOfClass:[NSNull class]])
        return def;
    return ret;
}

@end

@implementation DBOperationRecord

- (void)onInit {
    [super onInit];
}

- (void)onFin {
    ZERO_RELEASE(_database);
    ZERO_RELEASE(_table);
    [super onFin];
}

@end

@implementation DBSqliteScheme

- (void)onInit {
    [super onInit];
    
    _dynamicMaintain = YES;

    // 设置默认参数
    [self.query collect:@"*"];
}

- (void)onFin {
    DEBUG_EXPRESS([_db.schemes removeObject:self]);
    ZERO_RELEASE(_db);
    [super onFin];
}

- (void)setDb:(DBSqlite *)db {
    if (_db == db)
        return;
    
    [_db.signals disconnectToTarget:self];
    DEBUG_EXPRESS([_db.schemes removeObject:self]);
    
    PROPERTY_RETAIN(_db, db);
    //PROPERTY_ASSIGN(_db, db);
    DEBUG_EXPRESS([_db.schemes addObject:self]);
    
    // 对于 sqlite，变更发生在数据库中
    [_db.signals connect:kSignalDBSchemeChanged
            withSelector:@selector(cbDbChanged:)
                ofTarget:self];
}

- (void)cbDbChanged:(SSlot*)s {
    NSString* table = s.data.object;
    if ([table isEqualToString:self.name] == NO)
        return;
    
    [self.signals emit:kSignalDBSchemeChanged];
}

- (DBScheme*)addObject:(id)obj {
# ifdef DEBUG_MODE
    if ([obj conformsToProtocol:@protocol(DBObject)] == NO) {
        WARN("DBScheme 添加的对象没有实现协议 DBObject");
        return self;
    }
# endif
    
    if (_dynamicMaintain && [obj conformsToProtocol:@protocol(DBObject)] == YES) {
        // 创建表
        NSArray* dbcolumns = [obj dbcolumns];
        if (self.exists == NO) {
            [self makeTable:dbcolumns];
        } else {
            [self upgradeTable:dbcolumns];
        }
    
        // 插入对象
        [self doAddObject:obj];
    }
    
    return self;
}

- (DBScheme*)addObjects:(NSArray *)objs {
# ifdef DEBUG_MODE
    {
        NSArray* dbcolumns = nil;
        for (id each in objs) {
            if ([each conformsToProtocol:@protocol(DBObject)] == NO) {
                WARN("DBScheme 添加的对象没有实现协议 DBObject");
                continue;
            }
            
            if (dbcolumns == nil) {
                dbcolumns = [[each class] DBColumns];
            } else if ([dbcolumns isEqualToArray:[[each class] DBColumns]] == NO) {
                WARN("DBScheme 添加的对象存在不同的类型");
                continue;
            }
        }
    }
# endif
    
    NSArray* dbcolumns = nil;
    
    for (id each in objs) {
        
        if ([each conformsToProtocol:@protocol(DBObject)] == NO)
            continue;
        
        if (_dynamicMaintain && dbcolumns == nil) {
            // 生成数据表
            if (self.exists == NO) {
                dbcolumns = [each dbcolumns];
                [self makeTable:dbcolumns];
            } else {
                [self upgradeTable:dbcolumns];
            }
        }
        
        // 插入对象
        [self doAddObject:each];
    }
    
    return self;
}

- (BOOL)rollback {
    return [_db rollback];
}

- (BOOL)commit {
    return [_db commit];
}

- (BOOL)makeTable:(NSArray*)dbcolumns {
    NSMutableString* sql = [[NSMutableString alloc] initWithFormat:@"create table '%@' ", self.name];
    NSMutableArray* values = [[NSMutableArray alloc] init];
    
    [values addObject:@"__id__ integer primary key autoincrement"];
    
    for (DBColumnObject* each in dbcolumns) {
        NSMutableArray* features = [[NSMutableArray alloc] init];
        
        [features addObject:[NSString stringWithFormat:@"'%@'", each.name]];
        
        switch (each.type)
        {
            default: break;
            case DBColumnTypeInteger: {
                [features addObject:@"integer"];
            } break;
            case DBColumnTypeText: {
                [features addObject:@"text"];
            } break;
            case DBColumnTypeReal: {
                [features addObject:@"real"];
            } break;
        }
        
        if (each.nullable == false)
            [features addObject:@"not null"];
        
        if (each.defaultv.notEmpty) {
            if (each.type == DBColumnTypeText)
                [features addObject:[NSString stringWithFormat:@"default '%@'", each.defaultv]];
            else
                [features addObject:[NSString stringWithFormat:@"default %@", each.defaultv]];
        }
        
        NSString* value = [features componentsJoinedByString:@" "];
        [values addObject:value];
        
        SAFE_RELEASE(features);
    }
    
    NSString* strValues = [values componentsJoinedByString:@","];
    [sql appendFormat:@" (%@) ", strValues];
    
    SAFE_RELEASE(values);
    
    BOOL suc = [_db.db executeUpdate:sql];
    if (suc == NO) {
        FATAL("生成数据表 %s 失败", self.name.UTF8String);
    } else {
        INFO("新建数据表 %s 完成", self.name.UTF8String);
        [self commit];
    }
    
    SAFE_RELEASE(sql);
        
    return suc;
}

- (void)upgradeTable:(NSArray*)dbcolumns {
    FMResultSet* rs = [_db.db executeQuery:[NSString stringWithFormat:@"select * from %@", self.name]];
    
    // 需要跳过自动加上的 __id__
    if ((rs.columnCount - 1) == dbcolumns.count) {
        [rs close];
        return;
    }
    
    BOOL changed = NO;
    
    for (DBColumnObject* each in dbcolumns) {
        int idx = [rs columnIndexForName:each.name];
        if (idx != -1)
            continue;
        changed = YES;
        
        // 没有找到，需要增加栏位
        NSString* sql = [NSString stringWithFormat:@"alter table %@ add ", self.name];
        
        NSMutableArray* features = [[NSMutableArray alloc] init];
        
        [features addObject:[NSString stringWithFormat:@"'%@'", each.name]];
        
        switch (each.type)
        {
            default: break;
            case DBColumnTypeInteger: {
                [features addObject:@"integer"];
            } break;
            case DBColumnTypeText: {
                [features addObject:@"text"];
            } break;
            case DBColumnTypeReal: {
                [features addObject:@"real"];
            } break;
        }
        
        if (each.nullable == false)
            [features addObject:@"not null"];
        
        if (each.defaultv.notEmpty) {
            if (each.type == DBColumnTypeText)
                [features addObject:[NSString stringWithFormat:@"default '%@'", each.defaultv]];
            else
                [features addObject:[NSString stringWithFormat:@"default %@", each.defaultv]];
        }
        
        NSString* value = [features componentsJoinedByString:@" "];
        sql = [sql stringByAppendingString:value];
        if ([_db.db executeUpdate:sql] == NO)
            INFO("数据表 %s 增加栏 %s", self.name.UTF8String, each.name.UTF8String);
        
        SAFE_RELEASE(features);
    }
    [rs close];
    
    // 应用更新
    if (changed)
        [_db commit];
}

- (BOOL)doAddObject:(id)obj {
    if ([obj dbid] != -1)
        return [self updateObject:obj] != nil;
    return [self doInsertObject:obj];
}

- (BOOL)doInsertObject:(id)obj {
    NSMutableArray* arrFields = [[NSMutableArray alloc] init];
    NSMutableArray* arrPoss = [[NSMutableArray alloc] init];
    NSMutableArray* arrValues = [[NSMutableArray alloc] init];
    NSMutableArray* arrWheres = [[NSMutableArray alloc] init];
    NSMutableArray* arrWhereValues = [[NSMutableArray alloc] init];
    
    for (DBColumnObject* each in [obj dbcolumns]) {
        if (each.used == NO)
            continue;
        
        id value = [obj valueForKeyPath:each.path def:nil];
        if (value == nil)
            continue;
    
        // 查询字段
        if (each.unique == true) {
            [arrWheres addObject:[NSString stringWithFormat:@"%@ = ?", each.name]];
            [arrWhereValues addObject:value];
        }
        
        // 值字段
        [arrValues addObject:value];
        [arrFields addObject:each.name];
        [arrPoss addObject:@"?"];
    }
    
    NSString* strFields = [arrFields componentsJoinedByString:@","];
    NSString* strPoss = [arrPoss componentsJoinedByString:@","];
    
    BOOL suc = NO;
    
    if (arrWheres.count == 0)
    {
        // 普通的插入操作
        NSString* sql = [NSString stringWithFormat:@"insert into '%@' (%@) values (%@)", self.name, strFields, strPoss];
        suc = [_db.db executeUpdate:sql withArgumentsInArray:arrValues];
    }
    else
    {
        // 需要先尝试update，如果失败，则再进行 insert
        NSString* strWheres = [arrWheres componentsJoinedByString:@" and "];
        
        NSMutableArray* arrUpdates = [[NSMutableArray alloc] init];
        for (NSString* name in arrFields) {
            [arrUpdates addObject:[NSString stringWithFormat:@"%@ = ?", name]];
        }
        
        NSString* strSets = [arrUpdates componentsJoinedByString:@","];
        
        NSString* sql = [NSString stringWithFormat:@"update '%@' set %@ where %@", self.name, strSets, strWheres];
        suc = [_db.db executeUpdate:sql withArgumentsInArray:[NSArray arrayWithArrays:arrValues, arrWhereValues, nil]];
        if (suc && _db.db.changes == 0) {
            // 进行 insert
            NSString* sql = [NSString stringWithFormat:@"insert into '%@' (%@) values (%@)", self.name, strFields, strPoss];
            suc = [_db.db executeUpdate:sql withArgumentsInArray:arrValues];
        }
        
        SAFE_RELEASE(arrUpdates);
    }
    
    SAFE_RELEASE(arrFields);
    SAFE_RELEASE(arrPoss);
    SAFE_RELEASE(arrWheres);
    SAFE_RELEASE(arrWhereValues);
    SAFE_RELEASE(arrValues);
    
    if (suc == NO)
        return NO;
    
    // 获得最后一条记录的id
    FMResultSet* rs = [_db.db executeQuery:[NSString stringWithFormat:@"select __id__ from %@ where [rowid] = %lld", self.name, _db.db.lastInsertRowId]];
    if (rs.next)
        [obj setDbidobj:[rs objectForColumnName:@"__id__" def:nil]];
    [rs close];
    
    return suc;
}

- (NSArray*)fetchObjects:(NSArray *)objs fromIndex:(NSUInteger)idx {
    if (objs.count == 0)
        return nil;
    
    SqlClauseSelect* cl = [[SqlClauseSelect alloc] init];
    [cl limitBy:[NSNumber numberWithUnsignedInt:objs.count] offset:[NSNumber numberWithUnsignedInteger:idx]];
    [cl addClause:self.query];
    
    id obj = objs.firstObject;
    
    // 生成 where 语句
    for (DBColumnObject* each in [obj dbcolumns]) {
        if (each.used == NO)
            continue;
        
        id value = [obj valueForKeyPath:each.path def:nil];
        if (value == nil)
            continue;
        
        [cl where:each.name operation:@"=" value:value];
    }
    
    NSString* sql = cl.sql;
    NSArray* sqlArr = cl.params;
    FMResultSet* rs = [_db.db executeQuery:sql withArgumentsInArray:sqlArr];
    SAFE_RELEASE(cl);
    
    NSMutableArray* ret = [NSMutableArray array];
    
    for (int i = 0; i < objs.count; ++i) {
        id obj = [objs objectAtIndex:i];
        
        if ([self doGetObject:obj rs:rs] == NO) {
            break;
        }
        
        [ret addObject:obj];
    }
    
    [rs close];
    
    return ret;
}

- (id)getObject:(Class)cls atIndex:(NSUInteger)idx {
    SqlClauseSelect* cl = [[SqlClauseSelect alloc] init];
    [cl limitBy:@1 offset:[NSNumber numberWithUnsignedInteger:idx]];
    [cl addClause:self.query];
    
    id ret = [[cls alloc] init];

    NSString* sql = cl.sql;
    NSArray* sqlArr = cl.params;
    FMResultSet* rs = [_db.db executeQuery:sql withArgumentsInArray:sqlArr];
    SAFE_RELEASE(cl);
    
    if ([self doGetObject:ret rs:rs] == NO) {
        [rs close];
        SAFE_RELEASE(ret);
        return nil;
    }
    
    [rs close];
    
    return [ret autorelease];
}

- (BOOL)doGetObject:(id)obj rs:(FMResultSet*)rs {
    if (rs.next == NO)
        return NO;
    
    for (DBColumnObject* each in [obj dbcolumns]) {
        
        id value = [rs objectForColumnName:each.name def:nil];
        
        @try {
            if (value) {
                [obj setValue:value forKeyPath:each.path];
            }
        }
        @catch (NSException *exception) {
            [exception log];
        }
        
    }
    
    // 设置数据库索引id
    [obj setDbidobj:[rs objectForColumnName:@"__id__" def:nil]];
    
    // 更新数据
    if ([obj conformsToProtocol:@protocol(DBObject)])
        [obj updateData];
    
    return YES;
}

- (NSArray*)getObjects:(Class)cls fromIndex:(NSUInteger)idx {
    SqlClauseSelect* cl = [[SqlClauseSelect alloc] init];
    [cl limitBy:@-1 offset:[NSNumber numberWithUnsignedInteger:idx]];
    [cl addClause:self.query];    
    NSString* sql = cl.sql;
    NSArray* sqlArr = cl.params;
    NSMutableArray* objs = [NSMutableArray array];
    FMResultSet* rs = [_db.db executeQuery:sql withArgumentsInArray:sqlArr];
    SAFE_RELEASE(cl);
    
    while (rs.next) {
        id ret = [[cls alloc] init];
        
        for (DBColumnObject* each in [cls DBColumns]) {
            id value = [rs objectForColumnName:each.name def:nil];
            @try {
                if (value) {
                    [ret setValue:value forKeyPath:each.path];
                }
            }
            @catch (NSException *exception) {
                [exception log];
            }
        }
        
        // 设置数据库索引id
        [ret setDbidobj:[rs objectForColumnName:@"__id__" def:nil]];
        
        // 更新数据
        if ([ret conformsToProtocol:@protocol(DBObject)])
            [ret updateData];
        
        [objs addObject:ret];
        SAFE_RELEASE(ret);
    }
    
    [rs close];
    return objs;
}

- (DBScheme*)updateObject:(id)obj {
    NSString* sqlValues = @"";
    NSMutableArray* arrValues = [[NSMutableArray alloc] init];
    
    // 生成 values 语句
    {
        NSMutableArray* values = [[NSMutableArray alloc] init];
        
        for (DBColumnObject* each in [obj dbcolumns]) {
            if (each.used == NO)
                continue;
            
            id val = [obj valueForKeyPath:each.path def:nil];
            if (val == nil)
                continue;
            
            [values addObject:[NSString stringWithFormat:@"%@ = ?", each.name]];
            [arrValues addObject:val];
        }
        
        sqlValues = [values componentsJoinedByString:@" , "];
        
        SAFE_RELEASE(values);
    }
    
    id idx = [obj dbidobj];
    SqlString* query = [SqlString string];
    [[query format:@"update %@ set", self.name] space];
    [query append:sqlValues];
    
    if (idx != nil) {
        // 定点更新
        [query format:@" where __id__ = %d", [idx intValue]];
    }
    
    // 执行
    NSString* sql = query.sql;
    BOOL suc = [_db.db executeUpdate:sql withArgumentsInArray:arrValues];
    SAFE_RELEASE(arrValues);
    
    if (suc == YES)
        return self;
    return nil;
}

- (DBScheme*)removeObject:(id)obj {
    id idx = [obj dbidobj];
    if (idx != nil)
    {
        // 定点移除
        NSString* sql = [NSString stringWithFormat:@"delete from '%@' where __id__ = %d", self.name, [idx intValue]];
        BOOL suc = [_db.db executeUpdate:sql];
        if (suc == YES)
            return self;
    }
    else
    {
        // 匹配移除
        NSString* sqlValues = @"";
        NSMutableArray* arrValues = [[NSMutableArray alloc] init];
        
        // 生成 values 语句
        {
            NSMutableArray* values = [[NSMutableArray alloc] init];
            
            for (DBColumnObject* each in [obj dbcolumns]) {
                if (each.used == NO)
                    continue;
                
                id val = [obj valueForKeyPath:each.path def:nil];
                if (val == nil)
                    continue;
                
                [values addObject:[NSString stringWithFormat:@"%@ = ?", each.name]];
                [arrValues addObject:val];
            }
            
            sqlValues = [values componentsJoinedByString:@" and "];
            
            SAFE_RELEASE(values);
        }

        SqlString* sql = [SqlString string];
        [sql format:@"delete from %@", self.name];
        
        if (arrValues.count) {
            [[sql space] append:@"where "];
            [sql append:sqlValues];
        }
        
        BOOL suc = [_db.db executeUpdate:sql.sql withArgumentsInArray:arrValues];
        SAFE_RELEASE(arrValues);
        
        if (suc == YES)
            return self;
    }
    
    return nil;
}

- (DBScheme*)clear {
    NSString* sql = [NSString stringWithFormat:@"delete from '%@'", self.name];
    BOOL suc = [_db.db executeUpdate:sql];
    if (suc == YES)
        return self;
    return nil;
}

- (NSInteger)count {
    SqlClauseCount* cl = [[SqlClauseCount alloc] init];
    [cl addClause:self.query];
    
    NSString* sql = cl.sql;
    NSArray* arrSql = cl.params;
    
    FMResultSet* rs = [_db.db executeQuery:sql withArgumentsInArray:arrSql];
    SAFE_RELEASE(cl);
    
    [rs next];
    NSUInteger ret = [rs intForColumnIndex:0];
    [rs close];
    return ret;
}

- (NSUInteger)countObject:(id)obj {
    NSUInteger ret = 0;
    
    NSMutableArray* arrWheres = [[NSMutableArray alloc] init];
    NSMutableArray* arrValues = [[NSMutableArray alloc] init];
    
    for (DBColumnObject* each in [obj dbcolumns]) {
        if (each.used == NO)
            continue;
        
        id value = [obj valueForKeyPath:each.path def:nil];
        if (value == nil)
            continue;
        
        [arrWheres addObject:[NSString stringWithFormat:@"%@=?", each.name]];
        [arrValues addObject:value];
    }
    
    if (arrWheres.count != 0) {
        // 可以用来查询
        NSString* sqlWhere = [arrWheres componentsJoinedByString:@" and "];
        NSString* sql = [NSString stringWithFormat:@"select count(*) as sum from '%@' where %@", self.name, sqlWhere];
        FMResultSet* rs = [_db.db executeQuery:sql withArgumentsInArray:arrValues];
        if (rs.next)
            ret = [rs intForColumn:@"sum"];
        [rs close];
    }
    
    SAFE_RELEASE(arrWheres);
    SAFE_RELEASE(arrValues);
    
    return ret;
}

// 表是否存在
- (BOOL)exists {
    NSString* sql = [NSString stringWithFormat:@"select count(*) as sum from sqlite_master where type='table' and tbl_name='%@'", self.name];
    FMResultSet* rs = [_db.db executeQuery:sql];
    [rs next];
    int sum = [rs intForColumn:@"sum"];
    [rs close];
    return sum != 0;
}

- (BOOL)reboundIds {
    return [_db.db executeUpdate:[NSString stringWithFormat:@"UPDATE sqlite_sequence SET seq = (SELECT MAX(__id__) FROM '%@') WHERE name='%@'", self.name, self.name]];
}

- (id)filter:(id)obj comparsion:(NSString *)comparsion {
    for (DBColumnObject* each in [obj dbcolumns]) {
        if (each.used == NO)
            continue;
        
        id value = [obj valueForKeyPath:each.path def:nil];
        if (value == nil)
            continue;
        
        [self.query where:each.name operation:comparsion value:value];
    }
    
    return self;
}

static void ApplyFilter2Clause(DBFilter* filter, SqlClauseWhere* where)
{
    if (filter.dbobj)
    {
        for (DBColumnObject* each in [filter.dbobj dbcolumns])
        {
            if (each.used == NO)
                continue;
            id value = [(id)filter.dbobj valueForKeyPath:each.path def:nil];
            if (value == nil)
                continue;
            [where where:each.name operation:@"=" value:value];
        }
        [where ands];
    }
    else
    {
        SqlClauseWhere* subwhere = [SqlClauseWhere temporary];
        for (DBFilter* each in filter.filters)
        {
            SqlClauseWhere* cw = [SqlClauseWhere temporary];
            ApplyFilter2Clause(each, cw);
            [subwhere addClause:cw];
            if (each.type == FILTER_AND)
                [subwhere ands];
            else if (each.type == FILTER_OR)
                [subwhere ors];
            
            [where addClause:subwhere];
            subwhere = [SqlClauseWhere temporary];
        }
    }
}

- (id)filters:(DBFilter*)filter {
    SqlClauseWhere* sqlwhere = self.query.where;
    ApplyFilter2Clause(filter, sqlwhere);
    return self;
}

- (NSArray*)query:(SqlClause*)clause {
    NSString* sql = clause.sql;
    NSArray* params = clause.params;
    NSMutableArray* ret = [NSMutableArray array];
    
    FMResultSet* rs = [_db.db executeQuery:sql withArgumentsInArray:params];
    while (rs.next) {
        [ret addObject:rs.resultDictionary];
    }
    [rs close];
    
    return ret;
}

@end

@interface DBSqlite ()

@property (nonatomic, retain) DBConfig *dbcfg;
@property (nonatomic, readonly) NSAtomicCounter *transactionCounter;

@end

@implementation DBSqlite

- (void)onInit {
    [super onInit];
    
    _operations = [[NSMutableArray alloc] init];
    _transactionCounter = [[NSAtomicCounter alloc] init];
    DEBUG_EXPRESS(_schemes = [[NSWeakArray alloc] init]);
}

- (id)initWithConfig:(DBConfig *)cfg {
    self = [self init];
    if ([self open:cfg] == NO) {
        [self release];
        return nil;
    }
    return self;
}

+ (DBSqlite*)dbWithConfig:(DBConfig *)cfg {
    return [[[DBSqlite alloc] initWithConfig:cfg] autorelease];
}

- (void)onFin {
    [self close];
    
    ZERO_RELEASE(_db);
    ZERO_RELEASE(_dbcfg);
    ZERO_RELEASE(_operations);
    ZERO_RELEASE(_transactionCounter);
    DEBUG_EXPRESS(ZERO_RELEASE(_schemes));
    
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalDBOpened)
SIGNAL_ADD(kSignalDBOpenFailed)
SIGNAL_ADD(kSignalDBSchemeChanged)
SIGNALS_END

static void HandlerUpdate(void* arg, int type, char const* database, char const* table, sqlite3_int64 rowid)
{
    DBSqlite* db = (DBSqlite*)arg;
    DBOperationRecord* oper = [[DBOperationRecord alloc] init];
    
    switch (type)
    {
        case SQLITE_INSERT: {
            oper.type = kDBOperationTypeInsert;
            [db.operations addObject:oper];
        } break;
        case SQLITE_DELETE: {
            oper.type = kDBOperationTypeDelete;
            [db.operations addObject:oper];
        } break;
        case SQLITE_UPDATE: {
            oper.type = kDBOperationTypeUpdate;
            [db.operations addObject:oper];
        } break;
        default: break;
    }
    
    oper.database = [NSString stringWithFormat:@"%s", database];
    oper.table = [NSString stringWithFormat:@"%s", table];
    
    SAFE_RELEASE(oper);
}

static int HandlerCommit(void* arg)
{    
    return 0;
}

static void HandlerRollback(void* arg)
{
    DBSqlite* db = (DBSqlite*)arg;
    [db.operations removeAllObjects];
}

- (BOOL)beginTransaction {
    if (_transactionCounter.radd)
        return YES;
    return [self.db beginDeferredTransaction];
}

- (BOOL)commitTransaction {
    if (_transactionCounter.sub == 0)
        return [self.db commit];
    return YES;
}

- (BOOL)open:(DBConfig *)cfg {
    FMDatabase* db = [[FMDatabase alloc] initWithPath:cfg.path];
    db.logsErrors = kDebugMode;
    //db.logsErrors = NO;
    
    int flag = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX;
    if ([db openWithFlags:flag] == NO) {
        [self.signals emit:kSignalDBOpenFailed withResult:cfg];
        ZERO_RELEASE(db);
        return NO;
    }
    
    self.db = db;
    self.dbcfg = cfg;
    
    // 监听修改
    sqlite3* dbh = db.sqliteHandle;
    sqlite3_update_hook(dbh, HandlerUpdate, self);
    sqlite3_commit_hook(dbh, HandlerCommit, self);
    sqlite3_rollback_hook(dbh, HandlerRollback, self);
    
    INFO("SQLite 打开数据库成功 %s", cfg.path.UTF8String);
    
    // 默认进入事务模式
    if ([self beginTransaction] == NO)
        FATAL("启动事务失败");
    
    [self.signals emit:kSignalDBOpened];
    
    SAFE_RELEASE(db);
    return YES;
}

- (void)close {
    if (_db == nil)
        return;
    
    [_db close];
    self.db = nil;
    
    INFO("SQLite 关闭数据库 %s", _dbcfg.path.UTF8String);
}

- (BOOL)commit {
    if ([self commitTransaction] == NO) {
        FATAL("提交事务失败");
        return NO;
    }
    
    // 合并修改，并查找出需要激活的信号
    NSArray* opers = [_operations valueForKeyPath:@"@distinctUnionOfObjects.table"];
    for (NSString* each in opers) {
        LOG("数据表 %s 已经修改", each.UTF8String);
        [self.signals emit:kSignalDBSchemeChanged withResult:each];
    }
    
    // 清空历史的修改记录
    [_operations removeAllObjects];
    
    // 开始新的事务
    [self beginTransaction];
    
    return YES;
}

- (BOOL)rollback {
    if ([_db rollback] == NO) {
        FATAL("回滚事务失败");
        return NO;
    }
    
    [self beginTransaction];
    return YES;
}

- (DBScheme*)openScheme:(NSString *)name {
    DBSqliteScheme* scheme = [[DBSqliteScheme alloc] init];
    scheme.name = name;
    scheme.db = self;
    return [scheme autorelease];
}

@end
