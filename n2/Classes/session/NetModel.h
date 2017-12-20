
# import <Foundation/Foundation.h>
# import "ASIFormDataRequest.h"

// 需要在业务层实现服务器的地址
extern NSString* SERVER_URL();

@class ASIHTTPRequest;
@class ASINetworkQueue;
@class ASIFormDataRequest;
@class JsonData;
@class NetObj;
@class SNetObj;

/*******************************************************************************
 * 描述:
 apiSuccessed:ForApi:  成功之后回调
 apiSuccessedWithDictionary:ForApi: 成功后回调(不解析)
 apiFailed:WithMsg:    失败时候回调
 
 delegate是Assign类型的，上层不需要置Nil操作。
 
 *******************************************************************************/

typedef enum NetModelDoUnDoOperationState
{
    NetModelDoUnDoOperationState_None = 0,
    NetModelDoUnDoOperationState_Do = 1,
    NetModelDoUnDoOperationState_UnDo = 2
}NetModelDoUnDoOperationState;

@interface NetModelDoUnDoRequest : ASIFormDataRequest

@property(nonatomic,assign)int identifier;
@property(nonatomic,retain)id netModel;
@property(nonatomic,assign)NetModelDoUnDoOperationState curOperation;
@property(nonatomic,assign)NetModelDoUnDoOperationState nextOperation;

-(void)goNextOperation;
-(BOOL)shouldDoOperation;

@end

@interface NetModel : NSObject{
    ASINetworkQueue *_networkQueue;
}
@property(nonatomic,assign)id delegate;
@property(nonatomic,retain)ASINetworkQueue *networkQueue;
@property(nonatomic,assign)NetModelDoUnDoOperationState doUndoState;
@property(nonatomic,copy)NSString *from;

+ (void)setUserAgent:(NSString *)newUserAgent;

- (ASIFormDataRequest*)beginRequest:(NSString*)api;
- (void)endRequest:(ASIFormDataRequest*)request;
- (void)encryptRequest:(ASIFormDataRequest*)request netobj:(id)netobj;

- (BOOL)didReceiveData:(JsonData*)data forApi:(NSString*)api;

- (void)request:(id)netModel;
- (void)request:(id)netModel AndNotificationId:(int)idValue;
- (void)request:(id)netModel AndDoUnDoIdentifier:(int)idValue;
- (void)cancelAllOperations;

// 处理封装的 snetobj 结构
- (void)request_s:(SNetObj*)no;

@end

@interface NetModelProgressObserver : NSObject
<ASIProgressDelegate>

@property (nonatomic, assign) SNetObj* sapi;
@property (nonatomic, assign) SSignal* marksignal;

@end
