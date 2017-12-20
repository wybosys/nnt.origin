
# ifndef __APISESSION_DB_98862DD32D51490498BA6C8B0A5200A2_H_INCLUDED
# define __APISESSION_DB_98862DD32D51490498BA6C8B0A5200A2_H_INCLUDED

# import "ApiSession.h"

/*
 
 功能：
 1，状态回调；
 2，自动清空、保存结果到数据库
 3, 转换API对象到数据库对象
 
 fetch
 callback
 clear
 process
 db
 
 api.register(callback)
 api.block(clear)
 api.block(process)
 api.db = db;
 api.fetch(m)
 array = process(m)
 db.add(array)
 
 */

@class DBScheme;

@interface SNetObj (DB)

@end

@interface ApiSession (DB)

- (void)fetch:(id<NetObj>)obj
         with:(void(^)(SNetObj *m))block
        clean:(void(^)(id<NetObj> m, DBScheme*db))clean
      process:(NSArray*(^)(id<NetObj> m))process
           db:(DBScheme*)db;

- (void)fetch:(id<NetObj>)obj
         with:(SEL)sel withTarget:(id)target
        clean:(SEL)cleansel withTarget:(id)cleantarget
      process:(SEL)processsel withTarget:(id)processtarget
           db:(DBScheme*)db;

@end

# endif
