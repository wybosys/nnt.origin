#import "CommonObj.h"
#import "NetObj.h"

//for output

//默认输出
@interface ForwardSend : NSObject<NetObj>
{
    NSMutableSet* __inputSet__;
    NSMutableDictionary* __inputFiles__;
}
//input fields
//"WEIBO","QQ" 
@property(nonatomic, retain) NSString* in_platformlist;
// 
@property(nonatomic, retain) NSString* in_resid;
//填入picture的url 
@property(nonatomic, retain) NSString* in_picture;
//填入声音的url 
@property(nonatomic, retain) NSString* in_voice;
//消息标题 
@property(nonatomic, retain) NSString* in_title;
//消息内容 
@property(nonatomic, retain) NSString* in_message;
// 
@property(nonatomic, retain) NSString* in_comment;


//output fields
//返回码  0：成功 
@property(nonatomic, assign) int code;
//返回结果描述 
@property(nonatomic, retain) NSString* message;


- (void)parse:(NSObject*)obj;
- (void)addFile:(NSString*)path forKey:(NSString*)key;

@end;

