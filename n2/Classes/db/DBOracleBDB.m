
# import "Common.h"
# import "DBOracleBDB.h"
# import <BDB/db.h>
# import "DBConfig.h"

@implementation OracleBDBInfo

@end

@interface OracleBDB () {
    DB* _db;
}

@property (nonatomic, retain) DBConfig* dbcfg;

- (BOOL)_putKey:(void*)key lkey:(u_int32_t)lkey data:(void*)data ldata:(u_int32_t)ldata;
- (BOOL)_getKey:(void*)key lkey:(u_int32_t)lkey data:(void**)data ldata:(u_int32_t*)ldata;
- (BOOL)_exists:(void*)key lkey:(u_int32_t)lkey;

@end

@implementation OracleBDB

- (id)init {
    self = [super init];
    
    _db = NULL;
    
    return self;
}

- (id)initWithConfig:(DBConfig *)cfg {
    self = [self init];
    if ([self open:cfg] == NO) {
        [self release];
        return nil;
    }
    return self;
}

+ (OracleBDB*)dbWithConfig:(DBConfig *)cfg {
    return [[[OracleBDB alloc] initWithConfig:cfg] autorelease];
}

- (void)dealloc {
    [self close];
    
    SAFE_RELEASE(_dbcfg);
    
    [super dealloc];
}

- (BOOL)open:(DBConfig *)cfg {
    [self close];
    
    if (db_create(&_db, NULL, 0) != 0) {
        INFO("BDB 初始化数据库失败");
        return NO;
    }
    
    if (_db->open(_db,
                  NULL,
                  cfg.path.UTF8String,
                  NULL,
                  DB_BTREE,
                  DB_CREATE,
                  0) != 0)
    {
        FATAL("BDB 打开数据库失败 %s", cfg.path.UTF8String);
        return NO;
    }

    INFO("BDB 打开数据库成功 %s", cfg.path.UTF8String);

    self.dbcfg = cfg;
    
    return YES;
}

- (void)close {
    if (_db == nil)
        return;
    
    [self sync];    
        
    _db->close(_db, 0);
    _db = NULL;
    
    INFO("BDB 关闭数据库 %s", _dbcfg.path.UTF8String);
}

- (void)sync {
    _db->sync(_db, 0);
}

- (BOOL)_putKey:(void*)key lkey:(u_int32_t)lkey data:(void*)data ldata:(u_int32_t)ldata {
    DBT dk, dv;
    memset(&dk, 0, sizeof(DBT));
    memset(&dv, 0, sizeof(DBT));
    dk.data = key;
    dk.size = lkey;
    dv.data = data;
    dv.size = ldata;
    int sta = _db->put(_db, NULL, &dk, &dv, DB_OVERWRITE_DUP);
    return sta == 0;
}

- (BOOL)_getKey:(void*)key lkey:(u_int32_t)lkey data:(void**)data ldata:(u_int32_t*)ldata {
    DBT dk, dv;
    memset(&dk, 0, sizeof(DBT));
    memset(&dv, 0, sizeof(DBT));
    dk.data = key;
    dk.size = lkey;
    dv.flags = DB_DBT_MALLOC;
    int sta = _db->get(_db, NULL, &dk, &dv, 0);
    if (sta == 0)
    {
        *data = dv.data;
        *ldata = dv.size;
    }
    return sta == 0;
}

- (BOOL)_delKey:(void*)key lkey:(u_int32_t)lkey {
    DBT dk;
    memset(&dk, 0, sizeof(DBT));
    dk.data = key;
    dk.size = lkey;
    int sta = _db->del(_db, NULL, &dk, 0);
    return sta == 0;
}

- (BOOL)_exists:(void *)key lkey:(u_int32_t)lkey {
    DBT dk;
    memset(&dk, 0, sizeof(DBT));
    dk.data = key;
    dk.size = lkey;
    int sta = _db->exists(_db, NULL, &dk, 0);
    return sta != DB_NOTFOUND;
}

- (BOOL)exist:(NSString *)key {
    NSData* da = [key dataUsingEncoding:NSUTF8StringEncoding];
    return [self _exists:(void*)da.bytes lkey:(u_int32_t)da.length];
}

- (BOOL)removeForKey:(NSString *)key {
    NSData* da = [key dataUsingEncoding:NSUTF8StringEncoding];
    return [self _delKey:(void*)da.bytes lkey:(u_int32_t)da.length];
}

- (BOOL)setBool:(bool)v forKey:(NSString*)key {
    return [self setObject:[NSNumber numberWithBool:v] forKey:key];
}

- (BOOL)setInteger:(NSInteger)v forKey:(NSString*)key {
    return [self setObject:[NSNumber numberWithInteger:v] forKey:key];
}

- (BOOL)setObject:(id)v forKey:(NSString *)key {
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:v def:nil];
    if (data == nil) {
        FATAL("BDB 遇到一个不能序列化的类型 %s", class_getName([v class]));
        return NO;
    }
    
    NSData* dkey = [key dataUsingEncoding:NSUTF8StringEncoding];
    BOOL suc = [self _putKey:(void*)dkey.bytes
                        lkey:(u_int32_t)dkey.length
                        data:(void*)data.bytes
                       ldata:(u_int32_t)data.length];
    if (suc == NO)
        FATAL("BDB 保存对象失败");
    return suc;
}

- (id)objectForKey:(NSString *)key {
    NSData* dkey = [key dataUsingEncoding:NSUTF8StringEncoding];
    
    void* data;
    u_int32_t ldata;
    if ([self _getKey:(void*)dkey.bytes
                 lkey:(u_int32_t)dkey.length
                 data:&data
                ldata:&ldata] == NO) {
        return nil;
    }
    
    NSData* da = [NSData dataWithBytesNoCopy:data
                                      length:ldata
                                freeWhenDone:NO];
    id ret = [NSKeyedUnarchiver unarchiveObjectWithData:da def:nil];
    return ret;
}

- (OracleBDBInfo*)info {
    OracleBDBInfo* ret = [OracleBDBInfo temporary];
    DB_BTREE_STAT* stat = NULL;
    int sta = _db->stat(_db, NULL, &stat, DB_READ_COMMITTED);
    if (sta == 0) {
        // 排除不用的页，以及当前页
        ret.size = stat->bt_pagesize * (stat->bt_pagecnt - stat->bt_free - stat->bt_empty_pg - 1);
    }
    return ret;
}

- (void)clear {
    int sta = _db->truncate(_db, NULL, NULL, 0);
    if (sta == 0) {
        [self sync];
        LOG("BDB 清空数据库");
    }
}

- (void)foreach:(BOOL (^)(id, id))block {
    DBT dk, dv;
    memset(&dk, 0, sizeof(dk));
    memset(&dv, 0, sizeof(dv));
    DBC *cur = NULL;
    _db->cursor(_db, NULL, &cur, 0);
    while (0 == (cur->get(cur, &dk, &dv, DB_NEXT))) {
        
        NSData* da = [NSData dataWithBytesNoCopy:dk.data length:dk.dlen freeWhenDone:NO];
        id k = [NSKeyedUnarchiver unarchiveObjectWithData:da def:nil];
        da = [NSData dataWithBytesNoCopy:dv.data length:dv.dlen freeWhenDone:NO];
        id v = [NSKeyedUnarchiver unarchiveObjectWithData:da def:nil];
        
        if (block(k, v) == NO)
            break;
    }
}

@end
