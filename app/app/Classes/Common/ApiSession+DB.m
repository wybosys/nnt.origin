
# import "Common.h"
# import "ApiSession+DB.h"
# import "DBScheme.h"

@interface SSignals (DB)

- (SSlot*)connect:(SSignal*)sig withBlock:(SSlotCallbackBlock)block;

@end

@implementation ApiSession (DB)

- (void)fetch:(id<NetObj>)obj
         with:(void(^)(SNetObj *m))block
        clean:(void(^)(id<NetObj> m, DBScheme*db))clean
      process:(NSArray*(^)(id<NetObj> m))process
           db:(DBScheme*)db {
    
    [self fetch:obj with:^(SNetObj *m) {
        
        // 绑定成功消息以用来处理数据
        [m.signals connect:kSignalApiSucceed withBlock:^(SSlot *s) {
            
            NSObject<NetObj>* m = ((SNetObj*)s.sender).netobj;
            
            // 数据发生更新
            if (m.mcUpdated)
            {                
                // 发生了更新
                NSArray* rows = process(m);
                
                // 清空数据表
                if (clean == nil)
                    [db clear];
                else
                    clean(m, db);
                
                // 插入数据
                [db addObjects:rows];
                                
                [db commit];
                
            }
            
        }];
        
        // 运行传进来的
        block(m);
        
    }];
    
}

- (void)fetch:(id<NetObj>)obj
         with:(SEL)sel withTarget:(id)target
        clean:(SEL)cleansel withTarget:(id)cleantarget
      process:(SEL)processsel withTarget:(id)processtarget
           db:(DBScheme*)db {
    
    [self fetch:obj with:^(SNetObj *m) {
        [target performSelector:sel withObject:m];
    } clean:^(id<NetObj> m, DBScheme *db) {
        [cleantarget performSelector:cleansel withObject:m withObject:db];
    } process:^NSArray *(id<NetObj> m) {
        return [processtarget performSelector:processsel withObject:m];
    } db:db];
    
}

@end
