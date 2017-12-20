
# ifndef __FILESYSTEMEXTENSION_D999D30520D24C28B07E7F263E723C4E_H_INCLUDED
# define __FILESYSTEMEXTENSION_D999D30520D24C28B07E7F263E723C4E_H_INCLUDED

/** 基于目录控制 FS 中的文件、文件夹 */
@interface FSDirectory : NSObjectExt

+ (instancetype)directory:(NSString*)path;
- (id)initWithDirectory:(NSString*)path;

/** 根目录 */
@property (nonatomic, copy) NSString* pathRoot;

/** 返回相对于当前的目录 */
- (NSString*)path:(NSString*)name;

/** 相对于当前创建文件夹 */
- (BOOL)mkdir:(NSString*)name;
- (BOOL)mkdir:(NSString*)name intermediate:(BOOL)intermediate;

/** 创建文件夹 */
+ (BOOL)mkdir:(NSString*)path;
+ (BOOL)mkdir:(NSString*)path intermediate:(BOOL)intermediate;

/** 相对于当前是否存在文件 
 @note 需要传入是否可读的期望
 */
- (BOOL)exists:(NSString*)name;
- (BOOL)existsDir:(NSString*)name;
- (BOOL)existsFile:(NSString*)name;

/** 目标文件、文件夹是否存在 */
+ (BOOL)exists:(NSString*)path;
+ (BOOL)existsDir:(NSString*)path;
+ (BOOL)existsFile:(NSString*)path;

/** 相对于当前删除文件 */
- (BOOL)remove:(NSString*)name;

/** 删除文件 */
+ (BOOL)remove:(NSString*)path;

/** 生成临时用的文件的位置 */
- (NSString*)pathTemporary;

@end

/** App 容器中的 FS 访问对象 */
@interface FSApplication : FSDirectory

/** bundle 目录 */
@property (nonatomic, readonly) NSString* dirBundle;

/** cache 目录 */
@property (nonatomic, readonly) NSString* dirCache;

/** 临时目录 */
@property (nonatomic, copy) NSString* dirTmp;

/** bundle 中的路径 */
- (NSString*)pathBundle:(NSString*)name;

/** 可写的路径 */
- (NSString*)pathWritable:(NSString*)name;

/** cache 中的路径 */
- (NSString*)pathCache:(NSString*)name;

/** cache 中的目录，保证目录可用*/
- (NSString*)dirCache:(NSString*)name;

/** tmp 的路径 */
- (NSString*)pathTmp:(NSString*)name;

/** tmp 中的目录，保证存在*/
- (NSString*)dirTmp:(NSString*)name;

@end

/** 文件下载的句柄 */
@interface FileSessionHandle : NSObjectExt

/** 是否正在下载 */
@property (nonatomic, readonly) NSWorkState state;

/** 本地文件的路径 */
@property (nonatomic, readonly) NSURL *localFile;

@end

/** 下载文件的管理器 */
@interface FileSession : NSObjectExt

/** 默认的下载目录为 tmp */
@property (nonatomic, copy) NSString* directory;

/** 下载文件，返回的将是可以用来 connect 的对象 */
- (FileSessionHandle*)fetch:(NSURL*)url;

/** 本地文件 */
- (NSURL*)localFileForURL:(NSURL*)url;

@end

# endif
