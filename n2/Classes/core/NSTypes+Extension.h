
# ifndef __NSTYPESEXTENSION_E9607F97A09A43EDA03420A656CD7FDE_H_INCLUDED
# define __NSTYPESEXTENSION_E9607F97A09A43EDA03420A656CD7FDE_H_INCLUDED

# import "Compiler.h"
# import "Architect.h"
# import "SSObject.h"
# import <CoreLocation/CoreLocation.h>
# import <CoreMotion/CoreMotion.h>
# import <UIKit/UIKit.h>
# import <CoreGraphics/CoreGraphics.h>

C_BEGIN
# import "Objc+Extension.h"
C_END

CC_WARNING_PUSH
CC_WARNING_DISABLE(-Wunused-function)

// 对象值发生变化
SIGNAL_DECL(kSignalValueChanged) @"::ns::value::changed";

// 标记当前程序运行在数据模式还是数据UI共有模式
//   数据模式仅处理数据
//   共有模式处理数据和UI
// 可以根据此标记来提高程序性能
extern BOOL DATA_ONLY_MODE;

// 标记当前的程序需要运行在屏幕更新后，默认为 NO
extern BOOL AFTER_SCREENUPDATED;

typedef long long NSLongLong;
typedef unsigned long long NSULongLong;

typedef enum {
    kNSWorkStateUnknown = 0,    // 未知状态
    kNSWorkStateDone,           // 完成
    kNSWorkStateDoing,          // 进行
    kNSWorkStateWaiting,        // 等待
    kNSWorkStateFailed,         // 失败
} NSWorkState;

typedef enum {
    kNSAlignmentNone = 0,
    kNSAlignmentLeft = 0x1, // 居左
    kNSAlignmentRight = 0x2, // 居右
    kNSAlignmentCenter = 0x100, // 居中
    kNSAlignmentTop = 0x10, // 顶头
    kNSAlignmentBottom = 0x20, // 沉下
    
    NSTextAlignmentTop = kNSAlignmentTop,
    NSTextAlignmentBottom = kNSAlignmentBottom,
} NSAlignment;

@interface NSThreadExt : NSObject

- (void)start;

@end

/** 弱引用的包裹类
 @note 通常所有的 obj 在 objc 中为强引用，如果需要在强引用中保存一个弱引用对象，使用该类来持有改对象 */
@interface NSWeakObject : NSObject

/** 弱引用的实际对象 */
@property (nonatomic, assign) NSObject* obj;

+ (NSWeakObject*)weakObject:(id)obj;
- (NSWeakObject*)initWithObject:(id)obj;

@end

@interface _NSStrongAttachment : NSObject

- (id)objectForKey:(id<NSCopying>)key;
- (id)objectForKey:(id<NSCopying>)key def:(id)def;
- (id)objectForKey:(id<NSCopying>)key create:(id(^)())create;
- (void)setObject:(id)obj forKey:(id<NSCopying>)key;
- (id)popObjectForKey:(id<NSCopying>)key def:(id)def;

# define _NSSTRONGATTACHMENT_DECL(val, name) \
- (void)set##name:(val)v forKey:(id<NSCopying>)key; \
- (val)get##name:(id<NSCopying>)key def:(val)def; \
- (val)get##name:(id<NSCopying>)key;

_NSSTRONGATTACHMENT_DECL(int, Int);
_NSSTRONGATTACHMENT_DECL(BOOL, Bool);
_NSSTRONGATTACHMENT_DECL(float, Float);

- (void)removeAllObjects;

@end

@interface _NSWeakAttachment : NSObject

- (id)objectForKey:(id<NSCopying>)key;
- (id)objectForKey:(id<NSCopying>)key def:(id)def;
- (void)setObject:(id)obj forKey:(id<NSCopying>)key;
- (id)popObjectForKey:(id<NSCopying>)key def:(id)def;
- (void)removeObjectForKey:(id<NSCopying>)key;

- (int)getInt:(id<NSCopying>)key def:(int)def;
- (int)getInt:(id<NSCopying>)key;

- (void)removeAllObjects;

@end

/** 对象附加数据仓库
 @note 如果需要动态给对象身上保存一些数据，用这个类来避免子类化的问题
 */
@interface NSAttachment : NSObject

/** 强引用类型存储，添加进去的 object 会使用 refcnt 特性，使用时需要注意防止 死链 */
@property (nonatomic, readonly) _NSStrongAttachment *strong;

/** 弱引用类型存储，添加进去的 object 的 refcnt 不会受到影响，但使用时需要格外注意生命期 */
@property (nonatomic, readonly) _NSWeakAttachment *weak;

/** 清空所有的对象 */
- (void)removeAllObjects;

@end

/** 用来检查标志位 */
@interface NSMask : NSObject

/** 检查 value 上是否设置了 mask 标志位 */
+ (BOOL)Mask:(uint)mask Value:(uint)value;

@end

enum {
    NSKeepFirstMatched = 0x4000,
};

/** 安全相关的函数 */
@interface NSCryptolib : NSObject

/** 编码字符创到 base64 */
+ (NSString*)base64string:(NSString*)string encoding:(NSStringEncoding)encoding;

/** 解码字符串 */
+ (NSString*)debase64string:(NSString*)string encoding:(NSStringEncoding)encoding;

/** 解码字符串 */
+ (NSData*)debase64data:(NSString*)string;

/** 提取特征 */
+ (NSString*)sha256string:(NSString*)string encoding:(NSStringEncoding)encoding;

@end

/** 标准的 exception 当序列化时会丢失一些数据，此类完善序列化之用 */
@interface NSSerializableException : NSObject <NSCoding>

/** 标准的异常，可能会当反序列化时丢失数据 */
@property (nonatomic, retain) NSException *exception;
@property (nonatomic, retain) NSArray *callStackSymbols;
@property (nonatomic, retain) NSDate *date;

@property (readonly) NSString *name;
@property (readonly) NSString *reason;
@property (readonly) NSDictionary *userInfo;

/** 可以用来附加数据的字典 */
@property (nonatomic, readonly) NSMutableDictionary *data;

@end

@interface NSException (serial)

- (NSSerializableException*)serializableException;

@end

extern NSStringEncoding NSGB18030Encoding;
extern NSStringEncoding NSGB2312Encoding;
extern NSStringEncoding NSGBKEncoding;
extern NSStringEncoding NSGig5Encoding;

@interface NSString (extension)

/** 简单的从data到string */
+ (instancetype)stringWithData:(NSData*)da encoding:(NSStringEncoding)encoding;

/** 从byte转成string */
+ (instancetype)stringWithByte:(Byte)b;

/** 返回 string 数据 */
- (NSString*)stringValue;

/** 如果是 string 对象，则会使用“”来括起来 */
- (NSString*)stdStringValue;

/** 如果 string 表示的是 timestamp 数据，则返回读出的 timestamp 对象 */
- (time_t)timestampValue;

/** 安全判断是不是为空
 @note 普通的 length 不会判断 space，并且当对象为 nil 是，正向判断会失效，所以提供反向判断的函数 */
- (BOOL)notEmpty;

/** 安全比较两个字符创，避免为 nil 的时候判断失败 */
+ (BOOL)IsEqual:(NSString*)l ToString:(NSString*)r;

/** 获得string对应的json对象 */
- (id)jsonObject;

/** 使用漂亮的格式来显示字串 */
- (NSString*)prettyString;

/** 可以修改的字符创 */
- (NSMutableString*)mutableString;

/** url 格式编码 */
- (NSString*)urlencode;

/** url 格式解码 */
- (NSString*)urldecode;

/** b64编码 */
- (NSString*)base64;

/** b64解码 */
- (NSString*)debase64;

/** 编码成 b64 格式的 hex 数据 */
- (NSData*)debase64data;

/** sha256 */
- (NSString*)sha256;

/** md5 */
- (NSString*)md5;

/** 计算文件字符串对应的 mimetype */
- (NSString*)fileMimetype;

/** 移除空格 */
- (NSString*)stringTrimSpace;

typedef enum {
    UUID_STR_32W,
    UUID_STR_36W,
} UUID_STR;

/** 生成 UUID */
+ (NSString*)uuid;

/** 生成 UUID */
+ (NSString*)uuid:(UUID_STR)type;

/** 把自己重复添加cnt次来形成一个新的字符串 */
- (NSString*)stringBySelfAppendingCount:(NSInteger)cnt;

/** 通过目标字符串来拆分子字符串 */
- (NSArray*)substringsByOccurrencesOfString:(NSString*)string options:(NSStringCompareOptions)options;

/** 生成子字符串，溢出的使用 fs 替代 */
- (NSString*)substringWithRange:(NSRange)range fillOverflow:(NSString*)fs;

/** 插入子字符来获得新字符串 */
- (NSString*)stringByInsertString:(NSString*)str atIndex:(NSUInteger)index;

/** 删除区域内的字符生成新字符串 */
- (NSString*)stringByRemoveInRange:(NSRange)range;

/** 取出该位置的字符 */
- (NSString*)stringAtIndex:(NSUInteger)idx;

/** 取出该位置的字符 */
- (NSString*)stringAtIndex:(NSUInteger)idx def:(NSString*)def;

/** 目标字符串的起始位置 */
- (NSInteger)indexOfSubString:(NSString*)str;

/** 按照固定长度来遍历子字符串 */
- (void)foreachSubstring:(BOOL(^)(NSString* str, int idx))block length:(int)length;

/** 生成随机字符串 */
+ (NSString*)RandomString;

/** 指定长度生成随机字符串 */
+ (NSString*)RandomString:(NSUInteger)length;

/** 通过是目标字符串重复 count 次数来生成字符创 */
+ (NSString*)stringRepeatString:(NSString*)str count:(NSInteger)count;

/** 提取目标字符串左边的字符串 */
- (NSString*)stringLeftside:(NSString*)sep;

/** 提取目标字符串右边的字符串 */
- (NSString*)stringRightside:(NSString*)sep;

/** 使用固定长度分段 string */
- (NSArray*)explodeByLength:(NSInteger)length;

# ifndef IOS8_FEATURES
/** ios8 提供了改函数，但是由于改函数很容易被使用，所以 ios7 以下也手动实现该函数 */
- (BOOL)containsString:(NSString *)aString;
# endif

/** 使用字符分段，跳过空的 */
- (NSArray*)componentsSeparatedByString:(NSString*)sep skipSpace:(BOOL)skipSpace;

/** 十六进制转换成指针 */
- (void*)hexPointerValue;

@end

@interface NSMutableString (extension)

/** 清空 */
- (void)clear;

/** 带有保护的append，如果 str 为 nil，则使用 def，如果 def 也为 nil，此函数不做任何改动 */
- (void)appendString:(NSString*)str def:(NSString*)def;

@end

/** 用以实现类似于 C++ pair 类，只携带两个对象 */
@interface NSPair : NSObject

@property (nonatomic, retain) id firstObject;
@property (nonatomic, retain) id secondObject;

+ (instancetype)pairFirst:(id)f Second:(id)s;
- (id)initWithFirst:(id)f withSecond:(id)s;

@end

/** 用以实现类似于 C++ pair 类，只携带三个对象 */
@interface NSTriple : NSPair

@property (nonatomic, retain) id thirdObject;

+ (instancetype)pairFirst:(id)f Second:(id)s Thrid:(id)t;
- (id)initWithFirst:(id)f withSecond:(id)s Thrid:(id)t;

@end

@class CGLine;

/** 包装了字符串的样式 */
@interface NSStylization : NSObject

/** 文字颜色 */
@property (nonatomic, retain) UIColor *textColor;

/** 字体 */
@property (nonatomic, retain) UIFont *textFont;

/** 绘制删除线 */
@property (nonatomic, retain) CGLine *deleteLine;

/** 底部的线段 */
@property (nonatomic, retain) CGLine *bottomLine;

/** 字符间距，为比例值 */
@property (nonatomic, assign) CGFloat characterSpacing;

- (id)initWithTextColor:(UIColor*)textColor textFont:(UIFont*)textFont;
+ (instancetype)styleWithTextColor:(UIColor*)textColor textFont:(UIFont*)textFont;
+ (instancetype)textColor:(UIColor*)textColor;
+ (instancetype)textFont:(UIFont*)textFont;

/** 行距 */
- (instancetype)setLineSpacing:(CGFloat)spacing;

/** 断行样式 */
- (instancetype)setLineBreakMode:(NSLineBreakMode)val;

/** 行对齐 */
- (instancetype)setAlignment:(NSTextAlignment)val;

/** 段间距 */
- (instancetype)setParagraphSpacingBefore:(CGFloat)before After:(CGFloat)after;

/** 是否已经设置了对齐样式 */
- (BOOL)isAlignmentSet;

/** 是否已经设置了断行样式 */
- (BOOL)isLineBreakModeSet;

/** 将 style 设置给 attributedstring */
- (void)setIn:(NSMutableAttributedString*)str range:(NSRange)range;

@end

extern NSString* kCTCustomDeleteLineAttributeName;
extern NSString* kCTCustomBottomLineAttributeName;

@interface NSAttributedString (extension)

/** 计算限制中得最适合大小 */
- (CGSize)bestSize:(CGSize)maxsize;

/** 计算指定行数的最佳大小 */
- (CGSize)bestSize:(CGSize)maxsize inLineRange:(NSRange)rgn;

/** 计算限制大小中的行数 */
- (NSUInteger)numberOfLines:(CGSize)maxsize;

@end

struct _CGMargin;

@protocol NSStylizedItem <NSObject, NSCopying>

/** 具体的 string 数据 */
- (NSString*)string;

/** 用于填充的占位 string (仅用于逻辑处理) */
- (NSString*)placedString;

@end

@protocol NSStylizedItemString <NSStylizedItem>

/** 设置string */
- (void)setString:(NSString*)string;

@end

@protocol NSStylizedItemImage <NSStylizedItem>

/** 获得到携带的图片 */
- (UIImage*)image;

/** 图片期望的大小 */
- (CGRect)preferredRect;

/** 图片的边距 */
- (struct _CGMargin)margin;

@end

@protocol NSStylizedItemCustom;

@protocol NSStylizedItemCustomDelegate <NSObject>

// 一些大小的设置
- (CGFloat)ascentForItem:(id<NSStylizedItemCustom>)item;
- (CGFloat)descentForItem:(id<NSStylizedItemCustom>)item;
- (CGFloat)widthForItem:(id<NSStylizedItemCustom>)item;

@end

@protocol NSStylizedItemCustom <NSStylizedItem>

@property (nonatomic, assign) id<NSStylizedItemCustomDelegate> delegate;

- (NSStylization*)stylization;
- (NSString*)identifier;

@end

@interface NSFullStylization : NSStylization

- (NSLineBreakMode)linebreakMode;
- (CTLineBreakMode)CTLinebreakMode;

@end

/** 为了解决系统的 NSSAttributedString 较为复杂的问题，实现样式字符串
 */
@interface NSStylizedString : NSObject

/** 转换成 attributedstring 对象 */
@property (nonatomic, readonly) NSAttributedString *attributedString;

/** 全部的 style */
@property (nonatomic, readonly) NSStylization *style;

/** 最近使用 style */
@property (nonatomic, retain) NSStylization *lastStyle;

/** 清空 */
- (void)clear;

/** 字符串长度 */
- (NSUInteger)length;

/** touche style, 不保证style一定实例化 */
- (NSStylization*)touchStyle;

/** 添加文字 */
- (NSObject<NSStylizedItem>*)append:(NSStylization*)style format:(NSString*)format ,...;

/** 添加图片 */
- (NSObject<NSStylizedItem>*)appendImage:(UIImage*)image;

/** 添加图片 */
- (NSObject<NSStylizedItem>*)appendImage:(UIImage*)image preferredRect:(CGRect)rect;

/** 添加图片 */
- (NSObject<NSStylizedItem>*)appendImage:(UIImage*)image preferredRect:(CGRect)rect margin:(struct _CGMargin)margin;

/** 添加自定义对象，由具体的控件实现回调处理 */
- (NSObject<NSStylizedItemCustom>*)appendCustom:(NSStylization*)style string:(NSString*)string identifier:(NSString*)identifier;

/** 获得所有的string */
- (NSString*)stringValue;

/** 是否分段设置了 alignment 或者其他 */
- (BOOL)paragraphSpecifiedAlignment;

/** 是否分段设置了 alignment 或者其他 */
- (BOOL)paragraphSpecifiedLineBreak;

/** 返回所有有的 item id<NSStylizedItem> */
@property (nonatomic, readonly) NSMutableArray *items;

/** 针对item的操作 */
- (void)removeItem:(id<NSStylizedItem>)item;

/** 获取到该 range 对应的对象 */
- (NSObject<NSStylizedItem>*)itemForTextRange:(NSRange)range locationInRange:(NSRange*)locrange;

/** 设置所有的子 item 为同一个 style */
- (void)setStylization:(NSStylization*)style;

@end

@class NSDataSource;

@interface NSURL (extension)

/** 不为空 */
- (BOOL)notEmpty;

// 根据ds来获得真正的资源地址
- (NSURL*)initWithDataSource:(NSDataSource*)ds;
+ (NSURL*)URLWithDataSource:(NSDataSource*)ds;

/** 获得可以用来读取文件的地址 */
@property (nonatomic, readonly) NSString *filePath;

/** http 的地址 */
@property (nonatomic, readonly) NSString *httpPath;

@end

@interface NSURLRequest (extension)

+ (NSURLRequest*)requestWithURLString:(NSString *)URL;

@end

@interface NSURLConnection (extension)

@end

PRIVATE_CLASS_DECL(NSURLConnectionExt);

@class NSProgressValue;

@interface NSURLConnectionExt : NSURLConnection {
    PRIVATE_DECL(NSURLConnectionExt);
}

// 初始化请求
- (id)initWithRequest:(NSURLRequest *)request startImmediately:(BOOL)startImmediately;
- (id)initWithRequest:(NSURLRequest *)request;
+ (NSURLConnectionExt*)connectionWithRequest:(NSURLRequest *)request;
+ (NSURLConnectionExt*)connectionWithRequest:(NSURLRequest *)request startImmediately:(BOOL)startImmediately;

// 当前的下载进度
@property (nonatomic, readonly) NSProgressValue *progressValue;

// 如果保存到文件，则代表文件的地址，不传则代表保存到内存中
@property (nonatomic, copy) OPTIONAL NSURL *outputFile;

@end

// 项目启动
SIGNAL_DECL(kSignalStart) @"::ns::start";

// 项目取消
SIGNAL_DECL(kSignalCancel) @"::ns::cancel";

// 项目停止
SIGNAL_DECL(kSignalStop) @"::ns::stop";

// 项目完成
SIGNAL_DECL(kSignalDone) @"::ns::done";

// 项目正在处理
SIGNAL_DECL(kSignalProcessing) @"::ns::processing";

// 项目处理结束
SIGNAL_DECL(kSignalProcessed) @"::ns::processed";

// 下一个
SIGNAL_DECL(kSignalNext) @"::ns::next";

// 上一个
SIGNAL_DECL(kSignalPrevious) @"::ns::previous";

// 添加\创建成功
SIGNAL_DECL(kSignalAdded) @"::ns::added";

// 删除\移除成功
SIGNAL_DECL(kSignalRemoved) @"::ns::removed";

// 请求添加
SIGNAL_DECL(kSignalRequestAdd) @"::ns::request::add";

// 请求删除
SIGNAL_DECL(kSignalRequestRemove) @"::ns::request::remove";

// 请求修改
SIGNAL_DECL(kSignalRequestModify) @"::ns::request::modify";

// 遇到了最大值
SIGNAL_DECL(kSignalReachMax) @"::ns::reach::max";

// 遇到了最小值
SIGNAL_DECL(kSignalReachMin) @"::ns::reach::min";

// 项目激活成功
SIGNAL_DECL(kSignalEnabled) @"::ns::enabled";

// 项目禁止成功
SIGNAL_DECL(kSignalDisabled) @"::ns::disabled";

// 项目的激活状态发生改变
SIGNAL_DECL(kSignalEnableChanged) @"::ns::enable::changed";

@interface NSMutableURLRequest (extension)

@property (nonatomic, copy) NSString *userAgent;

+ (NSMutableURLRequest*)mutableRequestWithRequest:(NSURLRequest*)req;

- (void)addCookies:(NSArray*)cookies;
- (void)setUserAgent:(NSString*)ua;

@end

@interface NSClass : NSObject

@property (nonatomic, assign) Class classValue;
+ (instancetype)object:(Class)cls;

// 遍历类的所有 property，包含父类的
+ (void)ForeachProperty:(BOOL(^)(objc_property_t* prop))block forClass:(Class)cls;
+ (void)ForeachProperty:(BOOL(^)(objc_property_t* prop))block forClass:(Class)cls forProtocol:(Protocol*)ptl;

// 遍历类所有的 property，知道遇到父类
+ (void)ForeachProperty:(BOOL (^)(objc_property_t* prop))block forClass:(Class)cls rootClass:(Class)rootCls;

// 迭代所有的父类，检测有没有实现协议
+ (BOOL)Implement:(Class)cls forProtocol:(Protocol*)ptl;

// 遍历类所有的函数
+ (void)ForeachMethod:(BOOL (^)(Method mth))block forClass:(Class)cls;

@end

// 混合类型，可以负载一堆 class
@interface NSMixinClass : NSClass

+ (instancetype)classes:(Class)cls, ...;

// 类型列表
@property (nonatomic, retain) NSArray* classes;

@end

typedef enum {
    kIteratorTypeBreak = 0,
    kIteratorTypeOk   = 1,
    kIteratorTypeNext = 2,
} IteratorType;

@interface NSObjectExt : NSObject

/** 空函数，不做任何处理，通常用于必须要传一个 selector，但是又没功能的情况 */
- (void)pass;

@end

@protocol NSObjectShared <NSObject>

+ (instancetype)shared;

@optional
- (void)onInstanceShared;

@end

@interface NSObject (extension)

/** 空函数，不做任何处理，通常用于必须要传一个 selector，但是又没功能的情况 */
- (void)pass;

/** 返回指针 */
- (void*)pointerValue;

/** 快速单件模式 */
+ (instancetype)shared;

/** 是否存在该属性 */
- (BOOL)existsProperty:(NSString*)property;

/** 如果对象是 cls 类型，返回 self，否则返回 nil. */
- (instancetype)obeyClass:(Class)cls;

/** 返回附加对象 */
- (NSAttachment*)attachment;

/** retain 并且 autorelease */
- (instancetype)consign;

/** 复制 并且 autorelease */
- (instancetype)clone;

/** autorelease的别名 */
- (id)autodrop;

/** 为了代替原始的release、retain用来调试 */
- (id)grabRef;
- (void)dropRef;

/** property 转换成 dictionary */
- (NSDictionary*)propertyValues;

/** 所有的 property 转换成 dictionary */
- (NSDictionary*)propertyValuesOfClass:(Class)cls;

/** 取得所有可以用来序列化的 property 值 */
- (NSDictionary*)encodablePropertyValues;

/** 从dictionary 读取 property */
- (void)loadProperties:(NSDictionary*)dict;

/** 使用另外一个 object 的所有 properties 设置自己的 property， 如果某一个 property 不存在，则跳过这个 property 继续
 如果 class 为 nil， 则使用 [obj class] 作为制定的类 */
- (void)loadPropertiesOfObject:(id)obj;
- (void)loadPropertiesOfObject:(id)obj ofClass:(Class)cls;

/** 遍历所有的 property
 仅遍历当前class的property */
- (void)foreachProperty:(BOOL(^)(id key, id value))block;

/** 遍历自己和superclass的property */
- (void)iteratorProperty:(IteratorType(^)(id key, id obj))block;

/** 其他 */
- (id)valueForKeyPath:(NSString*)path def:(id)def;

/** 查询一个重用对象 */
- (id)reusableObject:(id<NSCopying>)idr;

/** 查询一个重用对象，如果不存在则返回 def */
- (id)reusableObject:(id<NSCopying>)idr def:(id)def;

/** 设置一个重用对象 */
- (void)reusableObject:(id<NSCopying>)idr set:(id)set;

/** 查询一个重用对象，如果不存在，则使用 instance 实例化一个 */
- (id)reusableObject:(id<NSCopying>)idr instance:(id(^)())instance;

/** 查询一个重用对象，如果不存在，则使用 type 来实例化一个 */
- (id)reusableObject:(id<NSCopying>)idr type:(Class)type;

/** 临时对象 */
+ (instancetype)temporary;

# ifdef DEBUG_MODE

// 复制一个对象
- (id)unsafeClone;

# endif

/** 需要实现的更新数据 */
- (void)setNeedsUpdateData;

/** 数据更新 */
- (void)updateData;

/** 延迟运行，如果调用多个，则先cancel之前的 */
- (void)performSoleSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay;

/** 互斥调用 */
- (void)performSyncSelector:(SEL)aSelector withObject:(id)anArgument;

/** 尝试调用 */
- (BOOL)tryPerformSelector:(SEL)aSelector withObject:(id)anArgument;

/** json */
- (NSString*)jsonString;

// 谨慎，需要相应类继承或者手动调用
- (void)onInit;
- (void)onFin;

/** 自己调用自己 */
- (id)objectWithProcess:(id(^)(id _self, id _target))block ofTarget:(id)target;

/** 自己调用自己 */
- (instancetype)me:(void(^)(id _self))block;

/** 如果是这种类型，则调用 */
- (void)type:(Class)cls process:(void(^)(id))process;

/** 输出到内存，返回占用了多少字节 */
- (NSInteger)copyToMem:(void*)mem;

/** 避免为 nil 的时候 isequal 失效 */
+ (BOOL)IsEqual:(id)l to:(id)r;

@end

# define NSOBJ_GLOBALOBJ(type, name) \
static type* __gsobj_##name = nil; \
static type* name () { \
    if (__gsobj_##name == nil) \
        __gsobj_##name = [[type alloc] init]; \
    return __gsobj_##name; \
}

/** 内存序列化 */
@interface NSMemObject : NSObject <NSCopying>

+ (instancetype)mem:(void*)ptr needfree:(BOOL)needfree;
+ (instancetype)allocmem:(NSInteger)size;
+ (instancetype)allocmem:(NSInteger)count type:(NSInteger)type;

@property (nonatomic, readonly) void* ptr;

@end

# define NSOBJECT_MAKEGS(cls) \
@interface cls : NSObject @end \
@implementation cls SHARED_IMPL @end

/** @brief 前向对象，可以使用这个类对一些不能进行重载的对象进行重载
 @note
 比如 NSString 重载后运行的时候将 crash，但是有时候业务需要一个是string但是类型又不能是NSString的对象，就可以这样做
 @code
 NSCLASS_SUBCLASS(NSStringXXX, NSForwardObject);
 id obj = [NSStringXXX object:@"ABC"];
 [obj isKindOfClass:[NSString class]]; // NO
 [obj isKindOfClass:[NSStringXXX class]]; // YES
 但是因为对象类型变化，则使用该对象的时候将没有智能补全代码的功能，用是可以按照源对象的方式用
 label.text = obj; // OK == label.text = @"ABC"
 */
@interface NSForwardObject : NSObject <NSCopying>

@property (nonatomic, retain) id object;

+ (instancetype)object:(id)object;
- (id)initWithObject:(id)object;

@end

# define NSFORWARD_CLASS(name, cls) \
@interface name : NSForwardObject \
@property (nonatomic, readonly) cls* value; \
@end \
@implementation name \
- (id)init { \
self = [super init]; \
self.object = [cls temporary]; \
return self; \
} \
- (id)initWithObject:(cls*)n { \
self = [super init]; \
self.object = n; \
return self; \
} \
- (cls*)value { return self.object; } \
@end

@interface NSPropertyString : NSForwardObject @end

/** 用来将FUND类型的block转成 NS 类型的对象 */
@interface NSBlockObject : NSObject

typedef void (^common_block_t)();
@property (nonatomic, copy) common_block_t block;

+ (instancetype)block:(id)block;

@end

# define NSOBJECT_DYNAMIC_PROPERTY_KEY(cls, prop) __ ## cls ## __key__ ## prop

# define NSOBJECT_DYNAMIC_PROPERTY_EXT(cls, prop, getexp, setprop, beforsetexp, setpropexp, type) \
@dynamic prop; \
static void* NSOBJECT_DYNAMIC_PROPERTY_KEY(cls, prop); \
- (id)prop { \
id ret = objc_getAssociatedObject(self, &NSOBJECT_DYNAMIC_PROPERTY_KEY(cls, prop)); \
getexp; \
return ret; \
} \
- (void)setprop:(id)val { \
beforsetexp; \
objc_setAssociatedObject(self, &NSOBJECT_DYNAMIC_PROPERTY_KEY(cls, prop), val, OBJC_ASSOCIATION_ ## type); \
setpropexp; \
}

# define NSOBJECT_DYNAMIC_PROPERTY_DECL(cls, prop) \
@dynamic prop; \
static void* NSOBJECT_DYNAMIC_PROPERTY_KEY(cls, prop);

# define NSOBJECT_DYNAMIC_PROPERTY_SET(cls, prop, type, val) \
objc_setAssociatedObject(self, &NSOBJECT_DYNAMIC_PROPERTY_KEY(cls, prop), val, OBJC_ASSOCIATION_ ## type)

# define NSOBJECT_DYNAMIC_PROPERTY_GET(cls, prop) \
objc_getAssociatedObject(self, &NSOBJECT_DYNAMIC_PROPERTY_KEY(cls, prop))

# define NSOBJECT_DYNAMIC_PROPERTY_IMPL_GET(cls, prop) \
- (id)prop { \
id ret = objc_getAssociatedObject(self, &NSOBJECT_DYNAMIC_PROPERTY_KEY(cls, prop)); \
return ret; \
}

# define NSOBJECT_DYNAMIC_PROPERTY_IMPL_SET(cls, prop, setprop, type) \
- (void)setprop:(id)val { \
NSOBJECT_DYNAMIC_PROPERTY_SET(cls, prop, type, val); \
}

# define NSOBJECT_DYNAMIC_PROPERTY(cls, prop, setprop, type) \
NSOBJECT_DYNAMIC_PROPERTY_EXT(cls, prop, , setprop, , , type)

# define NSOBJECT_DYNAMIC_PROPERTY_READONLY_IMPL_EXT(cls, prop, propcls, exp) \
static void* NSOBJECT_DYNAMIC_PROPERTY_KEY(cls, prop); \
- (id)prop { \
propcls* val = (propcls*)objc_getAssociatedObject(self, &NSOBJECT_DYNAMIC_PROPERTY_KEY(cls, prop)); \
if (val == nil) { \
val = [[propcls alloc] init]; \
exp; \
objc_setAssociatedObject(self, &NSOBJECT_DYNAMIC_PROPERTY_KEY(cls, prop), val, OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
SAFE_RELEASE(val); \
} \
return val; \
}

# define NSOBJECT_DYNAMIC_PROPERTY_READONLY_EXT(cls, prop, propcls, exp) \
@dynamic prop; \
NSOBJECT_DYNAMIC_PROPERTY_READONLY_IMPL_EXT(cls, prop, propcls, exp);

# define NSOBJECT_DYNAMIC_PROPERTY_READONLY(cls, prop, propcls) \
NSOBJECT_DYNAMIC_PROPERTY_READONLY_EXT(cls, prop, propcls, );

# define NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR_EXT(cls, prop, setprop, valtype, beforeto, toobj, afterto, fromobj, type) \
NSOBJECT_DYNAMIC_PROPERTY_DECL(cls, prop); \
NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR_EXT2(cls, prop, setprop, valtype, beforeto, toobj, afterto, fromobj, type);

# define NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR_EXT2(cls, prop, setprop, valtype, beforeto, toobj, afterto, fromobj, type) \
static void* NSOBJECT_DYNAMIC_PROPERTY_KEY(cls, prop); \
- (void)setprop:(valtype)val { \
beforeto; \
NSOBJECT_DYNAMIC_PROPERTY_SET(cls, prop, type, toobj); \
afterto; \
} \
- (valtype)prop { \
id val = NSOBJECT_DYNAMIC_PROPERTY_GET(cls, prop); \
return fromobj; \
}

# define NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR(cls, prop, setprop, valtype, toobj, fromobj, type) \
NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR_EXT(cls, prop, setprop, valtype, ,toobj,, fromobj, type)

# define NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR2(cls, prop, setprop, valtype, toobj, fromobj, type) \
NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR_EXT2(cls, prop, setprop, valtype, ,toobj,, fromobj, type)

# define NSPROPERTY_AVAGET_IMPL(name, cls) \
- (cls*)$##name { \
SYNCHRONIZED_BEGIN \
if (_##name == nil) \
_##name = [[cls alloc] init]; \
SYNCHRONIZED_END \
return _##name; \
}

# define NSPROPERTY_BRIDGE_TO(aprop, setaprop, toprop, type) \
@dynamic aprop; \
- (type)aprop { return toprop; } \
- (void)setaprop:(type)val { toprop = val; }

/** 克隆，用来从A类型生成和A一模一样的对象B
 不用 copying 的原因是有些类已经实现了copying，但是还存在一些额外的复制函数，所以可以通过这个来决定到底是用哪个复制
 */
@protocol NSCloning <NSObject>

- (instancetype)clone;

@end

@interface NSMutableData (extension)

// 直接添加对象
- (NSMutableData*)appendInt:(int)val;
- (NSMutableData*)appendByte:(Byte)val;
- (NSMutableData*)appendCString:(char const*)str;
- (NSMutableData*)appendString:(NSString*)str encoding:(NSStringEncoding)encoding;

@end

@class NSDataSource;

@interface NSData (extension)

/** 根据ds获取数据，注意！！如果是本地，则将直接load出来文件的数据，注意性能问题 */
- (id)initWithContentsOfDataSource:(NSDataSource*)ds;
+ (NSData*)dataWithContentsOfDataSource:(NSDataSource*)ds;

/** 显示成hexstring */
- (NSString*)hexStringValue;

/** base64编码，解码是由string来进行 */
- (NSString*)base64;

@end

@interface NSStreamData : NSObject {
    NSData* _data;
    NSInteger _offset;
}

// 数据偏移的位置
@property (nonatomic, assign) NSInteger offset;

- (id)initWithData:(NSData*)data;

// 读取制定长度的数值
- (BOOL)readInt:(int*)val;
- (BOOL)readInteger:(NSInteger*)val;
- (BOOL)readFloat:(float*)val;
- (BOOL)readDouble:(double*)val;
- (BOOL)readReal:(real*)val;
- (BOOL)readByte:(Byte*)val;
- (NSData*)readData:(NSInteger)length;

@end

@interface NSMutableDictionary (extension)

// 直接设置
- (instancetype)setInt:(int)val forKey:(id)key;
- (instancetype)setFloat:(float)val forKey:(id)key;
- (instancetype)setDouble:(double)val forKey:(id)key;
- (instancetype)setTimestamp:(time_t)v forKey:(id)key;
- (instancetype)setBool:(bool)val forKey:(id)key;

/** 安全设置，如果遇到nil，则替换成def，否则跳过 */
- (void)setObject:(id)anObject forKey:(id)aKey def:(id)def;
- (void)setValue:(id)value forKey:(NSString *)key def:(id)def;

/** 复合规则的对象将被移除 */
- (void)removeObjectByFilter:(BOOL(^)(id k, id v))block;
- (void)removeObjectByKeyFilter:(BOOL(^)(id k))block;

/** 弹出对应键值的对象 */
- (id)popObjectForKey:(id)key;

/** 与另外一个 dictionary 合并 */
- (void)setObjectsFromDictionary:(NSDictionary*)dict;

/** 使用 int 作为 key 来增加对象，注意不是 index*/
- (void)setObject:(id)anObject forInt:(NSInteger)idx;

/** 使用 int 作为 key 来移除对象，注意不是 index */
- (void)removeObjectForInt:(NSInteger)idx;

/** 增加array类型，如果键存在，则自动替换进去array 
 最终形成的是一个 key-values(queue) 的结构
 */
- (void)pushQueObject:(id)anObject forKey:(id)aKey;
- (BOOL)existsQueObject:(id)anObject forKey:(id)aKey;
- (id)popQueObjectForKey:(id)aKey;

/** 获得指定的对象，如果之前不存在，则使用指定的过程初始化对象并加到dict中 */
- (id)objectForKey:(id)aKey instance:(id(^)())instance;
- (id)objectForKey:(id)aKey instanceType:(Class)type;

/** 交换 */
- (void)swapObjectByKey:(id)aKey withKey:(id)toKey;

/** 替换掉value */
- (void)replaceAllValues:(id(^)(id key, id val))replacement;

@end

@interface NSDictionary (extension)
<NSCloning>

/** 使用转换器转换 */
+ (instancetype)dictionaryFromArray:(NSArray*)arr keyConverter:(id(^)(id))keyConverter valueConverter:(id(^)(id))valueConverter;

/** 如果multi为YES，则key将对应的是value类型是array */
+ (instancetype)dictionaryFromArray:(NSArray*)arr keyConverter:(id(^)(id))keyConverter valueConverter:(id(^)(id))valueConverter multi:(BOOL)multi;

/** 是否存在该key */
- (BOOL)exists:(id<NSCopying>)key;

/** 遍历 */
- (void)foreach:(IteratorType(^)(id key, id obj))block;

/** 获取key对应的对象 */
- (id)objectForKey:(id)aKey def:(id)def;

/** 获取key对应的对象 */
- (id)valueForKey:(NSString*)key def:(id)def;

/** 获取数值 */
- (int)getInt:(id<NSCopying>)key;
- (int)getInt:(id<NSCopying>)key def:(int)def;

- (float)getFloat:(id<NSCopying>)key;
- (float)getFloat:(id<NSCopying>)key def:(float)def;

- (double)getDouble:(id<NSCopying>)key;
- (double)getDouble:(id<NSCopying>)key def:(double)def;

- (BOOL)getBool:(id<NSCopying>)key;
- (BOOL)getBool:(id<NSCopying>)key def:(BOOL)def;

- (time_t)getTimestamp:(id<NSCopying>)key def:(time_t)def;

- (NSString*)getString:(id<NSCopying>)key;
- (NSString*)getString:(id<NSCopying>)key def:(NSString*)def;

- (NSArray*)getArray:(id<NSCopying>)key;
- (NSArray*)getArray:(id<NSCopying>)key def:(NSArray*)def;

- (NSDictionary*)getDictionary:(id<NSCopying>)key;
- (NSDictionary*)getDictionary:(id<NSCopying>)key def:(NSDictionary*)def;

- (id)initWithObject:(id)obj forKey:(id)key;

/** 获取int对应的对象，只能是set的时候也使用int来set，注意！！只是int不是下标，而是一个为int数值的key */
- (id)objectForInt:(NSInteger)idx;

/** 返回安全的对象，如果 obj 为 NSNull，返回的将是 nil */
- (id)objectForKeySafe:(id<NSCopying>)key;

/** 返回安全的对象列表，如果含有 NSNull 则过滤掉 */
- (NSArray*)allValuesSafe;

/** 确保是dict类型 */
+ (instancetype)restrict:(id)obj;

/** 根据下标取得对象, 由于是查找树，所以下标算法将是从头开始遍历，注意会影响性能 */
- (NSPair*)objectAtIndex:(NSInteger)idx;

/** 使用正则表达式的keypath
 @code 例子
 NSDictionary* dict = @{@"abc": @"0",
 @"cbc": @{@"cde": @"11"},
 @"fgh": @"2",
 @"ebe": @{@"cde": @"33"}
 };
 id result = [dict objectsForQueryPath:@"[a-z]+b[a-z]+.cde"];
 将取得 [@"33", @"11"]
 */
- (NSArray*)objectsForQueryPath:(NSString*)query;
- (NSArray*)objectsForQueryPath:(NSString*)query def:(NSArray*)def;
- (NSArray*)objectsForQuery:(NSString*)query;
- (NSArray*)objectsForQuery:(NSString*)query def:(NSArray*)def;

/** 取得根据keys排序的objects */
- (NSArray*)valuesOfSortedKeys;

/** 使用筛选器筛选出新的 dict */
- (NSDictionary*)dictionaryWithCollect:(id(^)(id key, id val))collect;

@end

@interface NSArray (extension)
<NSCloning>

/** 由多个 array 合并为一个 array */
+ (instancetype)arrayWithArrays:(NSArray*)arr, ...;
+ (instancetype)arrayWithArrays:(NSArray *)arr arg:(va_list)arg;

/** 使用转换器转换 */
+ (id)arrayFromDictionary:(NSDictionary*)dict byConverter:(id(^)(id key, id val))converter;

/** 第1个元素，如果不存在，则为 nil */
- (id)firstObject;

/** 第2个元素，如果不存在，则为 nil */
- (id)secondObject;

/** 第3个元素，如果不存在，则为 nil */
- (id)thirdObject;

/** 第4个元素，如果不存在，则为 nil */
- (id)fourthObject;

/** 深度copy，会顺次copy每一个子对象 */
- (id)deepCopy;

- (id)initWithObject:(id)object;
- (id)initWithObject:(id)object count:(NSInteger)count;

- (instancetype)initWithTypes:(Class)type count:(NSInteger)count;
- (instancetype)initWithTypes:(Class)type count:(NSInteger)count init:(void(^)(id obj, NSInteger idx))init;
- (instancetype)initWithInstance:(id(^)(NSInteger))block count:(NSInteger)count;
+ (instancetype)arrayWithTypes:(Class)type count:(NSInteger)count;
+ (instancetype)arrayWithTypes:(Class)type count:(NSInteger)count init:(void(^)(id obj, NSInteger idx))init;
+ (instancetype)arrayWithObjects:(id)firstObj arg:(va_list)arg;
+ (instancetype)arrayWithSet:(NSSet*)set;
+ (instancetype)arrayWithObject:(id)anObject count:(NSInteger)count;
+ (instancetype)arrayWithInstance:(id(^)(NSInteger))block count:(NSInteger)count;
+ (instancetype)arrayWithRange:(NSRange)range;
+ (instancetype)arrayWithCount:(NSInteger)count Objects:(id)firstObj, ...;
+ (instancetype)arrayWithCount:(NSInteger)count instance:(id(^)(NSInteger idx))ins;
+ (instancetype)arrayWithRange:(NSRange)rgn instance:(id(^)(NSInteger idx))ins;

- (instancetype)arrayWithFilter:(BOOL(^)(id l))filter;
- (instancetype)arrayWithCollector:(id(^)(id l))collector;
- (instancetype)arrayWithIndexedCollector:(id(^)(id l, NSInteger idx))collector;
- (instancetype)arrayByRemoveObject:(id)obj;
- (instancetype)arrayByRemoveAllObjects:(id)obj;
- (instancetype)arrayByRemoveObject:(id)obj comparison:(BOOL(^)(id l, id r))comparison;
- (instancetype)arrayByRemoveObjects:(NSArray*)objs;
- (instancetype)arrayIntersects:(NSArray*)objs;
- (instancetype)arrayWithArray:(NSArray*)arr equal:(BOOL(^)(id l, id r))equal replace:(id(^)(id l, id r))replace;
- (instancetype)arrayWithArray:(NSArray*)arr collector:(id(^)(id l, id r, NSInteger idx))collector;
- (instancetype)arrayByInsertObject:(id)obj atIndex:(NSUInteger)idx;

/** 找到一组array里面最小的 */
+ (instancetype)SmallestArrayInArrays:(NSArray*)arr, ...;
+ (instancetype)SmallestArrayInArrays:(NSArray *)arr arg:(va_list)arg;

/** 调整大小，如果大于，裁剪，小于则不变 */
- (instancetype)arrayByLimit:(NSInteger)count;
- (instancetype)arrayByRange:(NSRange)rg;
- (instancetype)arrayByRange:(NSRange)rg def:(id)def;
- (instancetype)arrayByRemoveRange:(NSRange)rg;
- (instancetype)arrayFromIndex:(NSInteger)idx;
- (instancetype)arrayToIndex:(NSInteger)idx;

/** 子列表，如果def不为nil，则填充补足的部分 */
- (instancetype)subarrayWithRange:(NSRange)range def:(id)def;

/** 安全读取数据 */
- (id)objectAtIndexSafe:(NSUInteger)index;
- (id)objectAtIndex:(NSUInteger)index def:(id)def;
- (id)objectAtIndex:(NSUInteger)index type:(Class)type;
- (id)objectAtIndex:(NSUInteger)index type:(Class)type def:(id)def;
- (int)intAtIndex:(NSUInteger)index def:(int)def;
- (float)floatAtIndex:(NSUInteger)index def:(float)def;

/** 获得指定元素之后的对象 */
- (id)nextObject:(id)obj;
- (id)nextObject:(id)obj def:(id)def;

/** 获得指定元素之前的对象 */
- (id)previousObject:(id)obj;
- (id)previousObject:(id)obj def:(id)def;

/** 反向读取数据 */
- (id)objectAtRIndex:(NSInteger)index;
- (id)objectAtRIndex:(NSInteger)index def:(id)def;

/** 是否存在该类实现的对象 */
- (BOOL)containsClass:(Class)cls;

/** 根据条件来查找 */
- (BOOL)containsObject:(id)anObject comparison:(BOOL(^)(id l, id anObject))comparison;

/** 获得元素 */
- (id)objectWithComparison:(BOOL(^)(id l, id r))comparison;
- (id)objectWithQuery:(id(^)(id l))query;

/** 遍历 */
- (void)foreach:(BOOL(^)(id obj))block;
- (void)foreach:(BOOL(^)(id obj))block forClass:(Class)cls;
- (void)foreachWithIndex:(BOOL(^)(id obj, NSInteger idx))block;

/** 按照增加 sep 的方式遍历
 先回调 blockdo
 如果此次调用后，没有走到结尾，则再调用 sepdo
 */
- (void)foreach:(IteratorType (^)(id))block sepdo:(void (^)(id))block;

/** 双指针遍历 */
- (void)foreach:(IteratorType (^)(id first))block next:(IteratorType (^)(id second))block;

/** 按照 range 遍历元素，如果 range overflow，则根据设置来决定是否继续 */
- (void)foreach:(IteratorType (^)(id obj, NSInteger idx))block range:(NSRange)range overflow:(BOOL)of def:(id)def;

/** 范围内的遍历 */
- (void)foreach:(IteratorType (^)(id obj, NSInteger idx))block range:(NSRange)range;

/** 遍历不属于目标的对象 */
- (void)foreach:(IteratorType (^)(id obj, NSInteger idx))block notIn:(NSArray*)des;

/** 通常的 foreach 是挨个遍历，但是有时业务需要得知当前的是第一个还是最后一个 */
- (void)foreach:(IteratorType (^)(id obj, NSInteger idx))normal end:(IteratorType (^)(id obj, NSInteger idx))end;

/** 同步双数组指针遍历
 同步遍历最小子集 */
- (void)stepWithArray:(NSArray*)arr each:(IteratorType (^)(id my, id other, NSInteger idx))block;

/** 同步遍历最大，超过的将用nil代替 */
- (void)foreachWithArray:(NSArray*)arr step:(IteratorType (^)(id my, id other, NSInteger idx))block;
- (void)foreachWithArray:(NSArray*)arr step:(IteratorType (^)(id my, id other, NSInteger idx))block def:(id)def;

/** 安全数组，滤过 null */
- (NSArray*)safeArray;

/** 反转 */
- (NSArray*)reversedArray;

/** 乱序 */
- (NSArray*)disorderArray;

/** 唯一性 */
- (NSArray*)arrayUnique:(id(^)(id))block;
- (NSArray*)arrayUnique;

/** 子元素统计 */
- (NSInteger)countByCollector:(NSInteger(^)(id))block;
- (id)objectAtIndex:(NSInteger)index countSubArray:(NSInteger(^)(id))block collector:(id(^)(id, NSInteger))block;
- (id)objectAtIndex:(NSInteger)index collector:(id(^)(id))block;

/** 查找目标的索引 */
- (NSInteger)indexOfQuery:(BOOL(^)(id obj))query;
- (NSInteger)indexOfQuery:(BOOL(^)(id obj))query def:(NSInteger)def;

/** 索引边界，返回 count - 1，如果 count == 0，返回 0 */
- (NSInteger)boundary;

/** 确保是array类型 */
+ (instancetype)restrict:(id)obj;

@end

@interface NSMutableArray (extension)

/** 使用条件来移除对象 */
- (void)removeObjectsMatch:(BOOL(^)(id obj))match;
- (void)removeObjectsMatch:(BOOL(^)(id l, id r))block withObject:(id)r;
- (void)removeObjectsMatch:(BOOL (^)(id, id))block withObjects:(NSArray*)arr;

/** 移除不在另外一个arr中的自己的对象 */
- (NSArray*)removeObjectsNotIn:(NSArray*)arr;
- (NSArray*)removeObjectsNotIn:(NSArray*)arr removed:(void(^)(id))block;

/** 移除指定范围内的对象 */
- (NSArray*)removeObjectsInRange:(NSRange)range;

/** 添加经过处理的另外一个arr的对象 */
- (void)addObjectsFromArray:(NSArray*)arr collector:(id(^)(id))block;

/** 从省略参数中增加对象 */
- (void)addObjectsFromV:(va_list)va;

/** 增加对象 */
- (void)addObjects:(id)obj, ...;
- (void)addObjectsOfCount:(NSInteger)count instance:(id(^)(NSInteger idx, NSInteger i))instance;

/** 清空类表，并挨个对清空对象调用后处理 */
- (void)removeAllObjects:(void(^)(id))block;

/** 使用反向下标来删除对象，比如此处的0，其实是正向的 count - 1 
 @note 反向移除，输入将从队尾开始算下标
 */
- (void)removeObjectAtRIndex:(NSUInteger)rindex;

/** 添加数值 */
- (void)addInt:(int)val;
- (void)addInteger:(NSInteger)val;
- (void)addFloat:(float)val;

/** 如果 anObject == nil，则自动用 NSNull 添加，以避免 null pointer 的 exception */
- (void)addObjectSafe:(id)anObject;
- (void)addObject:(id)anObject def:(id)def;

/** 交换对象 */
- (void)swapObjectAtIndex:(NSInteger)idx withIndex:(NSInteger)toidx;

/** 调整顺序 */
- (void)moveObjectAtIndex:(NSInteger)idx toIndex:(NSInteger)toidx;
- (void)moveObject:(id)obj afterObject:(id)to;
- (void)moveObject:(id)obj beforeObject:(id)to;

/** 将对象添加到队尾，remove & add */
- (void)readdObject:(id)obj;

/** 将指定位置的对象添加到队尾 */
- (void)readdObjectAtIndex:(NSInteger)idx;

/** 将指定范围的一堆对象保持顺序添加到队尾 */
- (void)readdObjectsInRange:(NSRange)range;

/** 从指定位置起插入一堆对象 */
- (void)insertObjects:(NSArray*)objects atIndex:(NSInteger)idx;

/** 使用目标arr来填充自己，之后成员等同于目标arr */
- (void)fillArray:(NSArray*)array;

/** 调整大小，之后数组即为 size 个 */
- (void)resizeByType:(Class)cls toSize:(NSUInteger)size;
- (void)resizeByType:(Class)cls toSize:(NSUInteger)size add:(void(^)(id))add remove:(void(^)(id))remove;
- (void)resizeTo:(NSUInteger)size def:(id)obj;

/** 增长到大小，如果小于，则新建类型 */
- (void)growByType:(Class)cls toSize:(NSUInteger)size;
- (void)growByType:(Class)cls toSize:(NSUInteger)size init:(void(^)(id obj, NSInteger idx))init;

/** 限制大小，如果小于则不变化，大于则删除元素 */
- (NSArray*)limitToSize:(NSUInteger)size;

/** 类似stack的用法 */
- (void)push:(id)obj;
- (id)pop;
- (id)top;
- (NSArray*)popAllObjects;

/** 循环左移 */
- (id)rol;

/** 循环右移 */
- (id)ror;

@end

/** 分段的数组
 @note 比如分为1、3、5三段，填充时会按照索引0、1、2一次填充3个 array，如果需要填充无数个，则最后一个段设置为无限流量
 */
@interface NSSegmentableArray : NSObjectExt

/** 指定段的容量 */
- (void)segment:(NSInteger)seg;

/** 不限流量 */
- (void)segment;

/** 获得某一段的列表 */
- (NSArray*)arrayAtIndex:(NSInteger)idx;

/** 添加一个 object */
- (void)addObject:(id)obj;
- (void)addObject:(id)obj def:(id)def;
- (void)addObjectsFromArray:(NSArray*)arr;

/** 清空 */
- (void)removeAllSegments;
- (void)removeAllObjects;

/** segment 的个数 */
@property (nonatomic, readonly) NSInteger count;

@end

/** 定长栈 */
@interface NSFixedLengthStack : NSObjectExt

@property (nonatomic, assign) NSUInteger capacity; // 容量
@property (nonatomic, readonly) NSInteger count; // 当前的大小

/** 内部实现用的 array */
@property (nonatomic, readonly) NSArray *array;

/** 按照容量初始化 */
- (id)initWithCapacity:(NSUInteger)capacity;
+ (instancetype)stackWithCapacity:(NSUInteger)capacity;

/** 添加一个对象，如果超过了容量，则按照 FIFO 抛弃（返回）一个对象，来达到固定长度的目的 */
- (id)push:(id)obj;

/** 添加一个对象，如果超过了容量，则返回 FALSE */
- (BOOL)add:(id)obj;

/** 弹出栈顶对象 */
- (id)pop;

/** 下标获得对象 */
- (id)objectAtIndex:(NSInteger)idx;

/** 清空 */
- (void)removeAllObjects;

@end

@interface NSSet (extension)

+ (instancetype)setWithSets:(NSSet*)set, ...;

/** 是否包含该数值 */
- (BOOL)containsInt:(NSInteger)val;

/** 带索引遍历 */
- (void)foreach:(IteratorType(^)(id obj, NSInteger idx))fe;

@end

@interface NSMutableSet (extension)

- (void)addInt:(NSInteger)val;
- (void)removeInt:(NSInteger)val;

@end

extern NSString* kNSDateStyleMySQL;

@interface NSDate (extension)

- (id)initWithTimestamp:(time_t)t;
- (time_t)timestamp;

/** 间隔 */
- (NSTimeInterval)timeDifference:(NSDate*)other;

/** 从 string 转换 */
+ (id)dateWithString:(NSString*)str style:(NSString*)style;

/** 按照 style 转换 */
- (NSString*)styleString:(NSString*)style;

/** 取得当前时区的ymd */
- (NSUInteger)year;
- (NSUInteger)month;
- (NSUInteger)day;
- (NSUInteger)hour;
- (NSUInteger)minute;
- (NSUInteger)second;

/** 是否是同一天 */
- (BOOL)isSameDay:(NSDate*)r;

@end

@interface NSTimerExt : NSObjectExt

/** 实例化即激活
 @note start, YES 自动激活，NO 等待 手动调用 start
 */
+ (instancetype)timerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo start:(BOOL)start;
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo start:(BOOL)start;

/** 自动激活，这两个函数都会自动运行，业务上设计为没什么区别 */
+ (instancetype)timerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo;
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo;

+ (instancetype)RepeatInterval:(NSTimeInterval)ti;
- (id)initWithRepeatInterval:(NSTimeInterval)ti;

- (id)initWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo start:(BOOL)start;
- (id)initWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo;
- (id)initWithScheduledTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo start:(BOOL)start;
- (id)initWithScheduledTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo;

/** 停止计时器 */
- (void)invalidate;

/** 停止计时器 */
- (void)stop;

/** 启动定时器 */
- (void)start;

/** 是否正在运行 */
@property (nonatomic, readonly) BOOL isRunning;

/** 计时器数据，文档参照 NSTimer */
@property (copy) NSDate *fireDate;
@property (readonly) NSTimeInterval timeInterval;

/** 是否是重复激活 */
@property (readonly) BOOL repeats;

@end

/** 为了简化业务层使用滴答来启动动作的代码 */
@interface NSCountTimer : NSObjectExt

/** 步进和边界，每一次不进会发出action的信号，到达边界后发出done的信号 */
@property (nonatomic, assign) NSTimeInterval timeStep, timeBoundary;

/** 已经步进的次数 */
@property (nonatomic, readonly) NSInteger countSteps;

/** 启动 */
- (void)start;

/** 停止 */
- (void)stop;

@end

/** 为了简化查询超时的处理 */
@interface NSTimeoutManager : NSObjectExt

/** 查询是否已经超时 
 @param inThread 是否在同一个线程中，之后的同名函数如果仅不带 inThread 参数，则代表默认为 YES
 */
+ (BOOL)IsTimeout:(NSString*)key inThread:(BOOL)inThread;

/** 设置超时 
 @note 如果已经超时或者 timeout 不一样，则因为 timer 对象已经销毁（或需要重新实例化），此时会重新实例化一个新的返回；
 没有超时则直接返回计时器
 */
+ (NSObjectExt*)SetTimeout:(NSTimeInterval)timeout key:(NSString*)key inThread:(BOOL)inThread;

@end

@interface NSTimeUnit : NSObject

/** 秒 */
+ (instancetype)TimeInterval:(NSTimeInterval)ti;

/** 纳秒 */
+ (instancetype)Nanoseconds:(int64_t)t;

/** 微秒 */
+ (instancetype)Microseconds:(int64_t)t;

/** 毫秒 */
+ (instancetype)Milliseconds:(int64_t)t;

/** 计算两个之间的差距 */
- (NSTimeUnit*)difference:(NSTimeUnit*)tu;

@property (nonatomic, readonly) NSTimeInterval timeInterval;
@property (nonatomic, readonly) int64_t nanoseconds;
@property (nonatomic, readonly) int64_t microseconds;
@property (nonatomic, readonly) float milliseconds;
@property (nonatomic, readonly) float seconds;

@end

// 执行动作
SIGNAL_DECL(kSignalTakeAction) @"::ui::take::action";

@interface NSTime : NSObject <NSCopying, NSCoding>
{
    struct tm* _tm;
    time_t _timestamp;
}

@property (nonatomic, assign) time_t timestamp;
@property (nonatomic, assign) BOOL neg;

- (id)init;
- (id)initWithTimestamp:(time_t)t;
- (id)initWithDate:(NSDate*)date;

+ (id)timeWithDate:(NSDate*)date;
+ (instancetype)timeWithString:(NSString*)str style:(NSString*)style;
+ (instancetype)timeWithTimestamp:(time_t)t;

/** 时间差异 */
- (instancetype)difference:(NSTime*)other;

/** 当前的时刻 */
+ (time_t)Now;

/** 随机一个时间 */
+ (instancetype)Random;

/** 当前的时间对象 */
+ (instancetype)time;

/** 今天的起始和结束点 */
+ (instancetype)TodayBegin;
+ (instancetype)TodayEnd;

/** 时间对应的当天的起始和结束点 */
- (instancetype)dayBegin;
- (instancetype)dayEnd;

/** 和今天相距几天，0代表今天，-1代表昨天，1代表明天 */
- (int)distanceToday;

/** diff前缀的代表如果neg为true，则返回的是-value
 自1970 */
@property (nonatomic, readonly) int yeard, diff_yeard;

/** 实际数据年 */
@property (nonatomic, readonly) int year;

/** 月 */
@property (nonatomic, readonly) int month, diff_month;

/** 日/月 */
@property (nonatomic, readonly) int day, diff_day;

/** 日/周 */
@property (nonatomic, readonly) int weekday, diff_weekday;

/** 日/年 */
@property (nonatomic, readonly) int yearday, diff_yearday;

/** 小时 */
@property (nonatomic, readonly) int hour, diff_hour;

/** 分钟 */
@property (nonatomic, readonly) int minute, diff_minute;

/** 秒 */
@property (nonatomic, readonly) int second, diff_second;

/** 合计天数 */
@property (nonatomic, readonly) int days, diff_days;

/** sleep指定时长 */
+ (void)SleepSecond:(NSTimeInterval)ti;
+ (void)SleepMilliSecond:(NSTimeInterval)ti;

/** 获取高精度的进程时间 */
+ (NSTimeUnit*)PidTime;

/** 本周剩余天数 */
- (int)weekfree;

/** 是否未来、过去 */
- (BOOL)isFuture;
- (BOOL)isForetime;

/** 是否今年 */
- (BOOL)isThisYear;

/** 取得易读的时间点 */
- (int)hyear;
- (int)hmonth;
- (int)hday;

/** 比较 */
- (NSComparisonResult)compare:(NSTime*)other;

- (NSDate*)date;

@end

static NSComparisonResult INVERSE_COMPARISON(NSComparisonResult res) {
    NSComparisonResult ret;
    switch (res) {
        case NSOrderedAscending: ret = NSOrderedDescending; break;
        case NSOrderedSame: ret = NSOrderedSame; break;
        case NSOrderedDescending: ret = NSOrderedAscending; break;
    }
    return ret;
}

// 用于格式化日期时使用的标记符
// "本周一"的"本"
extern NSString* kNSTimeFormatCurrentWeek;
extern NSString* kNSTimeFormatPreviousWeek;
extern NSString* kNSTimeFormatNextWeek;

@interface NSTime (pretty)

/** 可读性强的文字 */
- (NSString*)prettyString;

/** 可读性强的距离当前多少的文字 */
- (NSString*)prettyDistanceString;

@end

@interface NSMutableTime : NSTime

// 标准时间
@property (nonatomic, assign) int yeard;

// 逻辑时间
@property (nonatomic, assign) int year;
@property (nonatomic, assign) int month;
@property (nonatomic, assign) int day;
@property (nonatomic, assign) int hour;
@property (nonatomic, assign) int minute;
@property (nonatomic, assign) int second;

@end

@interface NSAnimatedValue : NSObject

@property (nonatomic, retain) NSValue* value;
@property (nonatomic, assign) BOOL animated; // default is YES

+ (instancetype)animated:(NSValue*)val;
+ (instancetype)nonanimated:(NSValue*)val;

@end

@interface NSNumber (extension)

+ (instancetype)numberWithTimestamp:(time_t)ts;
- (time_t)timestampValue;

+ (id)Yes;
+ (id)No;

- (NSString*)stdStringValue;

+ (instancetype)numberWithReal:(real)val;
- (real)realValue;

@end

@interface NSNumberObject : NSForwardObject

@property (nonatomic, retain) NSNumber* number;
@property (nonatomic, assign) BOOL boolValue;

@end

@interface NSAnyNumber : NSObject

@property (nonatomic, assign) any_number value;

+ (instancetype)number:(any_number)val;

@end

extern NSNumber const* kNumber0;
extern NSNumber const* kNumber1;
extern NSNumber const* kNumberYES;
extern NSNumber const* kNumberNO;

extern NSString const* kStringEmpty;

@interface NSRegularExpression (extension)

+ (instancetype)Digital;
+ (instancetype)Email;
+ (instancetype)MobilePhone;
+ (instancetype)EmailAndMobilePhone;
+ (instancetype)Password;
+ (instancetype)KeyValues;
+ (instancetype)Price;
+ (instancetype)AppUrlOnAppstore;

/** 字数限制的 re */
+ (instancetype)CharsInRange:(NSRange)rgn;

/** 取得匹配的结果 */
- (NSArray*)stringsMatchedInString:(NSString*)str;
- (NSArray*)stringsMatchedInString:(NSString*)str options:(NSMatchingOptions)options;
- (NSArray*)stringsMatchedInString:(NSString*)str options:(NSMatchingOptions)options range:(NSRange)range;

/** 正则归类出结果 */
- (NSArray*)capturesInString:(NSString*)str;
- (NSArray*)capturesInString:(NSString*)str options:(NSMatchingOptions)options;
- (NSArray*)capturesInString:(NSString*)str options:(NSMatchingOptions)options range:(NSRange)range;

/** 简化写法 */
+ (NSRegularExpression *)regularExpressionWithPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options;
+ (NSRegularExpression *)regularExpressionWithPattern:(NSString *)pattern;
- (id)initWithPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options;
- (id)initWithPattern:(NSString *)pattern;

/** 提供一个cache，以提高性能 */
+ (NSRegularExpression*)cachedRegularExpressionWithPattern:(NSString *)pattern
                                                   options:(NSRegularExpressionOptions)options
                                                     error:(NSError **)error;
+ (NSRegularExpression*)cachedRegularExpressionWithPattern:(NSString *)pattern
                                                   options:(NSRegularExpressionOptions)options;
+ (NSRegularExpression*)cachedRegularExpressionWithPattern:(NSString *)pattern;

/** 字符串是否匹配模式 */
- (BOOL)isMatchs:(NSString*)str;

/** 简化一些匹配，并且加上保护以避免异常 */
- (NSArray *)matchesInString:(NSString *)string range:(NSRange)range;
- (NSUInteger)numberOfMatchesInString:(NSString *)string range:(NSRange)range;
- (NSTextCheckingResult *)firstMatchInString:(NSString *)string range:(NSRange)range;
- (NSRange)rangeOfFirstMatchInString:(NSString *)string range:(NSRange)range;

@end

/** 原子的计数器 */
@interface NSAtomicCounter : NSObject

@property (readonly) NSInteger value;

// i++/--
- (NSInteger)radd;
- (NSInteger)rsub;

// ++/--i
- (NSInteger)add;
- (NSInteger)sub;

// i = 0
- (void)reset;

@end

@interface NSDataSource : NSObject <NSCopying>

/** 远程数据的url */
@property (nonatomic, copy) NSURL *url;

/** 本地数据的名字 */
@property (nonatomic, copy) NSString *bundle;

/** 具体数据，而不是需要获取 */
@property (nonatomic, retain) id data;

/** 异步还是同步，比如读取远程数据时。默认为NO，代表同步 */
@property (nonatomic, assign) BOOL async;
@property (nonatomic, readonly) BOOL sync;

+ (instancetype)dsWithUrl:(NSURL*)url;
+ (instancetype)dsWithUrlString:(NSString*)url;

+ (instancetype)asyncWithUrl:(NSURL*)url;
+ (instancetype)asyncWithUrlString:(NSString*)url;

+ (instancetype)dsWithBundle:(NSString*)bd;
+ (instancetype)dsWithData:(id)data;

- (BOOL)notEmpty;

@end

@interface NSUsed : NSObject

@property (nonatomic, assign) BOOL used;
@property (nonatomic, retain) id object;

@end

# define NSUSED_DECL(Name, Value, Prop) \
@interface NSUsed##Name : NSUsed \
@property (nonatomic, Prop) Value value; \
@end

NSUSED_DECL(Integer, NSInteger, assign);
NSUSED_DECL(String, NSString*, copy);

/** 同步锁 */
@interface NSSyncLoop : NSObject

+ (NSSyncLoop*)loop;

/** 阻塞直到释放 */
- (void)wait;

/** 释放 */
- (void)continuee;

/** 是否位于主线程中执行 */
+ (BOOL)InMainThread;

/** 等待当前队列空置 */
+ (void)WaitIdle;

@end

@interface NSBoolean : NSObject <NSCopying>

@property (nonatomic, readonly) BOOL boolValue;

- (id)initWithBool:(BOOL)val;
+ (id)boolean:(BOOL)val;

// 求反
- (instancetype)negative;

+ (instancetype)Yes;
+ (instancetype)No;
+ (instancetype)Random;

@end

@interface NSBundle (extension)

/** 根据名字查找图片, 会自动补全扩展名 */
- (NSString*)imageNamed:(NSString*)name;

/** 查找指定文件的路径 */
+ (NSURL*)URLForFileNamed:(NSString*)name;

@end

/** 包裹比例值的对象 
 @note 使用对象而不是直接使用 float，目的为：
 float 不会带有 max、value 的信息，而业务层有时需要显示
 使用对象可以区别于原始类型，例如 ui 层的各种指示器，可以通过 category 来提供统一的设置 percent 的函数 */
@interface NSPercentage : NSObject

- (id)initWithPercent:(double)val;
- (id)initWithMax:(double)max value:(double)val;

+ (instancetype)percent:(double)val;
+ (instancetype)percentWithMax:(double)max value:(double)val;

@property (nonatomic, assign) double max, value;
@property (nonatomic, assign) double percent;

/** 百分百完成的 */
+ (instancetype)Completed;

/** 返回位于 [0, 1] 之间的比率 */
@property (nonatomic, assign) double percent1;

/** 返回位于 [0, 10] 之间的比率 */
@property (nonatomic, assign) double percent10;

/** 返回位于 [0, 100] 之间的比率 */
@property (nonatomic, assign) double percent100;

@end

/** 通常会遇到两个方向的百分比，方便业务层使用 */
@interface NSPointPercentage : NSObject

- (id)initWithPoint:(CGPoint)pt inSize:(CGSize)size;
+ (instancetype)percent:(CGPoint)pt inSize:(CGSize)size;

/** 两个方向的比率 */
@property (nonatomic, retain) NSPercentage *percentX, *percentY;

@end

@interface NSProgressValue : NSPercentage

@property (nonatomic, assign) double packet;
@property (nonatomic, retain) NSData *totoalbuffer, *packetbuffer;

@end

@protocol NSPercentage <NSObject>

/** 有数据变化 */
- (void)percentage:(id)target value:(NSPercentage*)value;

@optional

/** 开始 */
- (void)percentageBegan:(id)target;

/** 完成，属于完全完成，在业务中，有可能完成并不是100%，所以需要带出完成时候的数据 */
- (void)percentageDone:(id)target value:(NSPercentage*)value;

/** 结束，value 为结束时的比率，因为有可能进行到一半的时候完成，所以需要带出一个比例值 */
- (void)percentageEnd:(id)target value:(NSPercentage*)value complete:(BOOL)complete;

/** 失败 */
- (void)percentage:(id)target value:(NSPercentage*)value error:(NSError*)error;

@end

// 从url中解析出url对象来
@interface NSURLEncoder : NSObject

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSMutableDictionary* values;

+ (id)decodeWithString:(NSString*)str;
- (id)initWithString:(NSString*)str;
- (BOOL)decode:(NSString*)str;

@end

// 从url中分解出 scheme 和 domain
@interface NSURIEncode : NSObject

@property (nonatomic, retain) NSString *scheme, *domain;

+ (id)decodeWithString:(NSString*)str;
- (id)initWithString:(NSString*)str;
- (BOOL)decode:(NSString*)str;

@end

@interface NSNull (extension)

- (NSString*)stringValue;
- (int)intValue;
- (float)floatValue;
- (double)doubleValue;

@end

@interface NSMath : NSObject

/** 5 / 3 = 2 */
+ (NSInteger)CeilInteger:(NSInteger)l r:(NSInteger)r;
+ (float)CeilFloat:(float)l r:(float)r;
+ (double)CeilDouble:(double)l r:(double)r;

/** 5 / 3 = 1 */
+ (NSInteger)FloorInteger:(NSInteger)l r:(NSInteger)r;
+ (float)FloorFloat:(float)l r:(float)r;
+ (double)FloorDouble:(double)l r:(double)r;

/** 取余数
 @note 得到浮点数固定数位的 int 值
 @code residue:12.34 width:2 将获得 12
 */
+ (int)Residue:(float)l width:(int)width;

// 解决宏的一些问题
+ (int)maxi:(int)l r:(int)r;
+ (float)maxf:(float)l r:(float)r;
+ (double)maxd:(double)l r:(double)r;
+ (int)mini:(int)l r:(int)r;
+ (float)minf:(float)l r:(float)r;
+ (double)mind:(double)l r:(double)r;

@end

@interface NSBytesSizePresenter : NSObject {
    NSULongLong _value;
}

- (id)initWithSize:(NSULongLong)val;
+ (instancetype)presenterWithSize:(NSULongLong)val;

/** 各个分位的大小 */
@property (nonatomic, assign) NSULongLong P, T, G, M, K, B;

/** 总大小 */
@property (nonatomic, assign) NSULongLong value;

/** M 分位的总大小 */
@property (nonatomic, readonly) NSULongLong Ms;
@property (nonatomic, readonly) float Mf;

@end

@interface NSUUID (extension)

+ (instancetype)UUIDString:(NSString*)str;

@end

@interface NSError (extension)

@end

// 工作执行成功
SIGNAL_DECL(kSignalSucceed) @"::ns::succeed";

// 工作执行失败
SIGNAL_DECL(kSignalFailed) @"::ns::failed";

@interface NSMutex : NSObject <NSLocking>

@end

@interface NSKeyedUnarchiver (extension)

+ (id)unarchiveObjectWithData:(NSData *)data def:(id)def;

@end

@interface NSKeyedArchiver (extension)

+ (NSData *)archivedDataWithRootObject:(id)rootObject def:(id)def;

@end

@interface NSOperation (extension)

@property (nonatomic, copy) NSString* name;

// 正在启动
- (void)onStart;

// 已经结束
- (void)onEnd;

// 正在处理
- (void)onProcess;

@end

@interface NSOperationExt : NSOperation

@end

@interface NSBlockOperationExt : NSBlockOperation

@end

@interface NSOperationQueue (extension)

@property (nonatomic, readonly) BOOL isEmpty;

- (void)start;
- (void)stop;

@end

@interface NSOperationQueueExt : NSOperationQueue

@end

/** 性能衡量 */
@interface NSPerformanceMeasure : NSBlockOperationExt

/** 输出结果 */
- (NSTimeUnit*)time;

/** 打印结果 */
- (void)log:(NSString*)format;

/** 子测试 */
- (void)measure:(void(^)())block;

/** 运行单次测试 */
+ (void)measure:(void(^)())block result:(void(^)(NSTimeUnit*))result;

/** 运行单次测试 */
+ (void)measure:(void(^)())block;

@end

/** 性能衡量批处理 */
@interface NSPerformanceSuit : NSOperationQueueExt

/** 添加一次测试 */
- (void)measure:(NSString*)name block:(void(^)())block;
- (void)measure:(NSString*)name block:(void(^)())block measure:(void(^)(NSPerformanceMeasure*))pm;

/** 当测试完成后，打印此次测试的输入 */
- (void)log:(NSPerformanceMeasure*)pm;

@end

@interface NSCallstackRecord : NSObjectExt

@property (nonatomic, assign) NSInteger idx;
@property (nonatomic, retain) NSString *module;
@property (nonatomic, assign) void* address;
@property (nonatomic, retain) NSString *function;

@end

/** 调试工具 */
@interface NSDiagnostic : NSObject

/** 获得调用路径 */
+ (NSArray*)Callstacks;

/** 查找期望的 */
+ (NSCallstackRecord*)queryCallstack:(BOOL(^)(NSString*))query;
+ (NSCallstackRecord*)callstackForSelector:(SEL)sel;

@end

/** 记录是否存在已经修改的数据 */
@interface NSTrailChange : NSObject

# ifdef DEBUG_MODE
- (void)objectIsIniting:(id)obj;
- (void)objectIsFining:(id)obj;
- (NSULongLong)countOfType:(Class)cls;
# endif

/** 开始一次修改 */
+ (void)Record;

/** 清空修改记录 */
+ (void)Clear;

/** 是否已经修改 */
+ (BOOL)IsChanged;

/** 已经修改 */
+ (void)SetChange;

@end

@interface NSIndexPath (extension)

- (BOOL)isSameSection:(NSUInteger)section;
- (BOOL)isSameRow:(NSUInteger)row;
- (BOOL)isSameCell:(NSIndexPath*)ip;

@end

@interface NSIndexSet (extension)

+ (instancetype)indexSetWithArray:(NSArray*)arr;

@end

static CGFloat CGFloatMin(CGFloat l, CGFloat r) {
    return MIN(l, r);
}

static CGFloat CGFloatMax(CGFloat l, CGFloat r) {
    return MAX(l, r);
}

static CGFloat CGFloatCeil(CGFloat v) {
    return X64_SYMBOL(ceil) X32_SYMBOL(ceilf) (v);
}

static CGFloat CGFloatFloor(CGFloat v) {
    return X64_SYMBOL(floor) X32_SYMBOL(floorf) (v);
}

@interface NSRandom : NSObject

+ (real)valueBoundary:(real)low To:(real)high;

@end

extern real random_between(real l, real h);

static BOOL NSRangeEqualToRange(NSRange l, NSRange r) {
    return l.location == r.location &&
    l.length == r.length;
}

static BOOL NSRangeEqualToCFRange(NSRange l, CFRange r) {
    return l.location == r.location &&
    l.length == r.length;
}

static BOOL NSRangeContain(NSRange rg, NSInteger loc) {
    return rg.location <= loc &&
    NSMaxRange(rg) > loc;
}

static NSInteger CFMaxRange(CFRange rg) {
    return rg.location + rg.length;
}

static BOOL CFRangeContain(CFRange rg, NSInteger loc) {
    return rg.location <= loc &&
    CFMaxRange(rg) > loc;
}

static NSRange NSMakeBoundaryRange(NSUInteger l, NSUInteger h) {
    return NSMakeRange(l, h - l);
}

@interface NSPinyin : NSObjectExt

/** 字符串转换成拼音串，非中文的会add到返回的array中 */
+ (NSArray*)StringToPinyin:(NSString*)str;

/** 声母 */
+ (NSString*)StringFirstNew:(NSString*)str;

@end

CC_WARNING_POP

# endif
