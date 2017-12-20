
# ifndef __NETOBJ_FE2926DF6F6A40D4849D3328843CBE7C_H_INCLUDED
# define __NETOBJ_FE2926DF6F6A40D4849D3328843CBE7C_H_INCLUDED

# import "SSObject.h"
# import "ASIHTTPRequest.h"
# import "ASIFormDataRequest.h"

@interface ASIFormDataRequest (addition)

@property (nonatomic, readonly) NSMutableArray* postData;

@end

@interface ASIHTTPRequest (addition)

- (void)setUserAgent:(NSString *)userAgent;

@end

typedef enum {
    kHttpMethodGet,
    kHttpMethodPost,
} HttpMethod;

@protocol NetObj <NSObject>

// 初始化 ASI 请求
- (void)initRequest:(ASIFormDataRequest*)request;

// 请求的方法
- (HttpMethod)method;

// 获得接口的地址
- (NSString*)getUrl;

// 解析对象
- (void)parse:(id)obj;

@end

@interface NetObj : NSObjectExt <NetObj>

@end

@protocol NetUrlObj <NSObject>

// 访问的url
@property (nonatomic, copy) NSString *url;

// 结果code
@property (nonatomic, assign) NSInteger code;

// 获得的数据
@property (nonatomic, retain) id data;
@property (nonatomic, retain) NSString *message;

// 附加的参数
@property (nonatomic, readonly) NSMutableDictionary *params, *files;
- (void)setParam:(NSString*)name value:(id)value;
- (void)setFile:(NSString*)name path:(NSString*)path;

@end

@interface NetUrlObj : NetObj <NetUrlObj>
@end

@interface NSObject (netobj)

// 错误消息
@property (nonatomic, copy) NSString *errorMessage;

// 是否已经调用
@property (nonatomic, assign) BOOL isRequested;

// 解析json
- (void)parseJSON:(id)jstr;

// 重新加载
- (void)reloadData:(BOOL)flush;
- (void)reloadData;
- (void)flushData;

@end

SIGNAL_DECL(kSignalRequestFlushData) @"::data::flush::requesting";
SIGNAL_DECL(kSignalRequestReloadData) @"::data::reload::requesting";
SIGNAL_DECL(kSignalRequestUpdateData) @"::data::update::requesting";

// 生成的 API 需要用到这些函数
@interface NSDictionary (netobj)

- (int)intValue:(NSString*)path;
- (long)longValue:(NSString*)path;
- (float)floatValue:(NSString*)path;
- (NSString*)strValue:(NSString*)path;
- (int)intValue:(NSString*)path default:(int)defValue;
- (float)floatValue:(NSString*)path default:(float)defValue;
- (NSString*)strValue:(NSString*)path default:(NSString*)defValue;
- (NSArray*)arrayValue:(NSString*)path default:(NSArray*)defValue;
- (NSArray*)arrayValue:(NSString*)path;
- (NSDictionary*)dictValue:(NSString*)path;

@end

# endif
