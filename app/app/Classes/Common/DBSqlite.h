
# ifndef __DBSQLITE_F242ECFA59F8443FB02788BD190C9E80_H_INCLUDED
# define __DBSQLITE_F242ECFA59F8443FB02788BD190C9E80_H_INCLUDED

# import "DBScheme.h"
# import "DBConfig.h"

@class DBSqlite;
@protocol DBObject;

/** sqlite 的数据集
 @note 数据集具有类似数据库记录变化之类的信号，而且数据集可以用来对象传递
 */
@interface DBSqliteScheme : DBScheme

/** 关联的数据库 */
@property (nonatomic, retain) DBSqlite* db;

/* 自动完备性检查（动态升级），默认为 YES */
@property (nonatomic, assign) BOOL dynamicMaintain;

@end

/** sqlite 数据库连接类 */
@interface DBSqlite : NSObjectExt

/** 初始化数据库连接 */
- (id)initWithConfig:(DBConfig*)cfg;

/** 打开数据库 */
+ (DBSqlite*)dbWithConfig:(DBConfig*)cfg;

/** 打开数据库 */
- (BOOL)open:(DBConfig*)cfg;

/** 关闭 */
- (void)close;

/** 事务提交修改 */
- (BOOL)commit;

/** 事务回滚 */
- (BOOL)rollback;

/** 打开数据集
 @param name 数据表的名称
 */
- (DBScheme*)openScheme:(NSString*)name;

@end

# endif
