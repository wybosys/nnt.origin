
# ifndef __SQLITECLAUSEMAKER_B5C54C99348F420ABFC2ECBE2F740FF4_H_INCLUDED
# define __SQLITECLAUSEMAKER_B5C54C99348F420ABFC2ECBE2F740FF4_H_INCLUDED

@interface SqlString : NSObject {
    NSMutableString* _str;
}

+ (id)string;

- (id)space;
- (id)append:(NSString*)str;
- (id)format:(NSString*)fmt, ...;

- (NSString*)sql;

@end

@interface SqlVariable : NSObject <NSCopying>

@property (nonatomic, copy) NSString* name;
@property (nonatomic, retain) id value;

@end

@interface SqlClause : NSObject <NSCopying>
{
     NSMutableArray *_variables, *_subclauses;
}

// 绑定的变量以及子句
@property (nonatomic, retain) NSMutableArray *variables, *subClauses;

// 可以直接不安全的调用 sql 语句
@property (nonatomic, copy) NSString *sql;

// 增加一个子查询
- (id)addClause:(SqlClause*)cl;

// 直接sql语句
+ (instancetype)SQL:(NSString*)sql;

// 参数化查询用到的参数
- (NSArray*)names;
- (NSArray*)params;

@end

@interface SqlClauseArgument : SqlClause

@property (nonatomic, copy) NSString *operation;

- (id)addObject:(id)obj;
- (id)addString:(NSString*)str;

@end

@interface SqlClauseFrom : SqlClauseArgument

@end

@interface SqlClauseCollect : SqlClauseArgument

@end

@interface SqlClauseGroupby : SqlClauseArgument

@end

@interface SqlClauseOrderby : SqlClauseArgument

// default is true.
@property (nonatomic, assign) BOOL asc;

@end

@interface SqlClauseLimit : SqlClause

@property (nonatomic, retain) NSNumber *limit, *offset;

@end

@interface SqlClauseWhere : SqlClause {
    BOOL _inner;
}

@property (nonatomic, copy) NSString* operation;

+ (id)where:(NSString *)name operation:(NSString *)oper value:(id)value;
- (id)where:(NSString *)name operation:(NSString *)oper value:(id)value;

- (id)ands;
- (id)ors;

@end

@interface SqlClauseSelect : SqlClause

@property (nonatomic, retain) SqlClauseCollect* collect;
@property (nonatomic, retain) SqlClauseFrom* from;
@property (nonatomic, retain) SqlClauseGroupby* groupby;
@property (nonatomic, retain) SqlClauseOrderby* orderby;
@property (nonatomic, retain) SqlClauseLimit* limit;
@property (nonatomic, retain) SqlClauseWhere* where;

- (id)collect:(NSString*)value;
- (id)fromString:(NSString*)str;
- (id)groupbyString:(NSString*)str;
- (id)orderbyString:(NSString*)str;
- (id)orderbyString:(NSString*)str asc:(BOOL)asc;
- (id)limitBy:(NSNumber*)limit offset:(NSNumber*)offset;
- (id)where:(NSString*)name operation:(NSString*)oper value:(id)value;
- (id)where:(SqlClauseWhere*)cw;

@end

@interface SqlClauseFunction : SqlClause

@property (nonatomic, copy) NSString *function;

+ (id)clauseWithFunction:(NSString*)func;
- (id)initWithFunction:(NSString*)func;

@end

@interface SqlClauseCount : SqlClauseFunction

@end

@interface SqlClauseJoin : SqlClauseArgument

// 获取所有的数据(包含未匹配)，默认为 NO
@property (nonatomic, assign) BOOL full;

@end

# endif
