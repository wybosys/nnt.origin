#import "CommonObj.h"
#import "NetObj.h"

//output auto generated anonymous structs
//
@interface ForwardTransfermData : NSObject
// 
@property(nonatomic, retain) NSMutableArray* messages; //Message


- (void)parse:(NSObject*)obj;
@end;


//for output

//
@interface ForwardTransferm : NSObject<NetObj>
{
    NSMutableSet* __inputSet__;
    NSMutableDictionary* __inputFiles__;
}
//input fields
// 
@property(nonatomic, retain) NSString* in_title;
// 
@property(nonatomic, retain) NSString* in_summary;
// 
@property(nonatomic, retain) NSString* in_avatar;
// 
@property(nonatomic, retain) NSString* in_image;
//帖子的resid, "101_[gameid]_0_[postid]" 
@property(nonatomic, retain) NSString* in_resid;
// 
@property(nonatomic, retain) NSString* in_thread;
//留言信息 
@property(nonatomic, retain) NSString* in_message;


//output fields
//返回码  0：成功 
@property(nonatomic, assign) int code;
//返回结果描述 
@property(nonatomic, retain) NSString* message;
// 
@property(nonatomic, readonly) ForwardTransfermData* data;


- (void)parse:(NSObject*)obj;
- (void)addFile:(NSString*)path forKey:(NSString*)key;

@end;

