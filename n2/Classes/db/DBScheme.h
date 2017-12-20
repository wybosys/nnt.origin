
# ifndef __DBSCHEME_17D3938647A9437CAAA92B8CA7C4F17E_H_INCLUDED
# define __DBSCHEME_17D3938647A9437CAAA92B8CA7C4F17E_H_INCLUDED

# import "SqliteClauseMaker.h"

@protocol DBObject;

/** 利用 db 筛选器可以在数据集中筛选数据
 */
@interface DBFilter : NSObjectExt

typedef enum {
    FILTER_NIL,
    FILTER_AND,
    FILTER_OR,
} FILTER_TYPE;

/** 筛选类型 */
@property (nonatomic, assign) FILTER_TYPE type;

/** 筛选依赖的数据对象 */
@property (nonatomic, retain) id<DBObject> dbobj;

/** 筛选器组合表 */
@property (nonatomic, readonly) NSArray* filters;

/** 生成筛选器 */
+ (instancetype)match:(id<DBObject>)a ands:(id<DBObject>)b;
+ (instancetype)match:(id<DBObject>)a ors:(id<DBObject>)b;

- (id)ands:(id<DBObject>)o;
- (id)ors:(id<DBObject>)o;

+ (instancetype)Head:(id<DBObject>)o;
+ (instancetype)And:(id<DBObject>)o;
+ (instancetype)Or:(id<DBObject>)o;

/** 和其他筛选器生成组合查询 */
- (id)with:(DBFilter*)f;

@end

/** 数据集 */
@interface DBScheme : NSObjectExt

/** 数据表名字 */
@property (nonatomic, copy) NSString* name;

/** 查询条件 */
@property (nonatomic, retain) SqlClauseSelect* query;

/** 数据表是否存在 */
@property (nonatomic, readonly) BOOL exists;

/** 加入对象 */
- (DBScheme*)addObject:(id<DBObject>)obj;
- (DBScheme*)addObjects:(NSArray*)objs;

/** 更新对象 */
- (DBScheme*)updateObject:(id<DBObject>)obj;

/** 移除对象 */
- (DBScheme*)removeObject:(id<DBObject>)obj;

/** 清空 */
- (DBScheme*)clear;

/** 根据下标获取对象 */
- (BOOL)fetchObject:(id<DBObject>)obj atIndex:(NSUInteger)idx;

/** 根据 obj 中的查询条件填充第一个对象
 @note 如果对象不存在，则返回 NO
 */
- (BOOL)fetchObject:(id<DBObject>)obj;

/** 从下标开始获得一组对象 */
- (NSArray*)fetchObjects:(NSArray*)objs fromIndex:(NSUInteger)idx;

/** 从下标开始获得一组对象 */
- (NSArray*)fetchObjects:(NSArray*)objs;

/** 根据下标填充指定类型的对象 */
- (id)getObject:(Class)cls atIndex:(NSUInteger)idx;

/** 根据下标填充指定类型的对象 */
- (id)getObject:(Class)cls;

/** 获取所有对象 */
- (NSArray*)getObjects:(Class)cls;
- (NSArray*)getObjects:(Class)cls fromIndex:(NSUInteger)idx;

/** 根据对象筛选 */
- (instancetype)filter:(id<DBObject>)obj;
- (instancetype)filter:(id<DBObject>)obj comparsion:(NSString*)comparsion;
- (instancetype)filters:(DBFilter*)filter;

/** 事务回滚 */
- (BOOL)rollback;

/** 提交事务 */
- (BOOL)commit;

/** 个数合计 */
@property (nonatomic, readonly) NSInteger count;

/** 统计对象的个数，利用对象中不为空的数据字段属性 */
- (NSUInteger)countObject:(id<DBObject>)obj;

/** 执行自定义查询 */
- (NSArray*)query:(SqlClause*)clause;

@end

/** 带分页的数据集 */
@interface DBPaged : NSObject

/** 当前页的下标 */
@property (nonatomic, assign) NSUInteger index;

/** 一共有多少页 */
@property (nonatomic, assign) NSUInteger countForPage;

/** 关联数据集 */
@property (nonatomic, retain) DBScheme* scheme;

- (id)initWithScheme:(DBScheme*)scheme;
+ (id)pagedWithScheme:(DBScheme*)scheme;

@end

// 数据集记录发生改变
SIGNAL_DECL(kSignalDBSchemeChanged) @"::db::scheme::changed";

// 数据库打开时的信号
SIGNAL_DECL(kSignalDBOpened) @"::db::opened";

// 数据库打开失败
SIGNAL_DECL(kSignalDBOpenFailed) @"::db::open::failed";

# endif
