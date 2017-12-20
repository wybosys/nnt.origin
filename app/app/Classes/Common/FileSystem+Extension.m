
# import "Common.h"
# import "FileSystem+Extension.h"
# import "NSTypes+Extension.h"

# include <sys/types.h>
# include <sys/event.h>
# include <sys/time.h>

@interface FSDirectory ()
{
    NSFileManager* _fmgr;
    BOOL _writable;
}

@end

@implementation FSDirectory

+ (instancetype)directory:(NSString*)path {
    return [[[self alloc] initWithDirectory:path] autorelease];
}

- (id)initWithDirectory:(NSString*)path {
    self = [super init];
    self.pathRoot = path;
    return self;
}

- (void)onInit {
    [super onInit];
    _fmgr = [NSFileManager defaultManager];
}

- (void)onFin {
    ZERO_RELEASE(_pathRoot);
    [super onFin];
}

- (void)setPathRoot:(NSString *)pathRoot {
    PROPERTY_COPY(_pathRoot, pathRoot);
    _writable = [_fmgr isWritableFileAtPath:_pathRoot];
}

- (NSString*)path:(NSString *)name {
    if (name == nil)
        name = @"";
    return [_pathRoot stringByAppendingFormat:@"/%@", name];
}

- (BOOL)mkdir:(NSString*)name {
    return [self mkdir:name intermediate:YES];
}

- (BOOL)mkdir:(NSString*)name intermediate:(BOOL)intermediate {
    return [_fmgr createDirectoryAtPath:[self path:name]
            withIntermediateDirectories:intermediate
                             attributes:nil
                                  error:nil];
}

+ (BOOL)mkdir:(NSString*)path {
    return [FSDirectory mkdir:path intermediate:YES];
}

+ (BOOL)mkdir:(NSString*)path intermediate:(BOOL)intermediate {
    return [[NSFileManager defaultManager] createDirectoryAtPath:path
                                     withIntermediateDirectories:intermediate
                                                      attributes:nil
                                                           error:nil];
}

- (BOOL)exists:(NSString*)name {
    return [_fmgr fileExistsAtPath:[self path:name]];
}

- (BOOL)existsDir:(NSString*)name {
    BOOL dir;
    if ([_fmgr fileExistsAtPath:[self path:name] isDirectory:&dir])
        return dir;
    return NO;
}

- (BOOL)existsFile:(NSString*)name {
    BOOL dir;
    if ([_fmgr fileExistsAtPath:[self path:name] isDirectory:&dir])
        return !dir;
    return NO;
}

+ (BOOL)exists:(NSString*)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (BOOL)existsDir:(NSString*)path {
    BOOL dir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&dir])
        return dir;
    return NO;
}

+ (BOOL)existsFile:(NSString*)path {
    BOOL dir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&dir])
        return !dir;
    return NO;
}

- (BOOL)remove:(NSString*)name {
    return [_fmgr removeItemAtPath:[self path:name] error:nil];
}

+ (BOOL)remove:(NSString *)path {
    return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (NSString*)pathTemporary {
    NSString* sufx = [NSString stringWithFormat:@"/~fs~ext_%d_%ld_~", (int)time(NULL), clock()];
    return [_pathRoot stringByAppendingString:sufx];
}

@end

@implementation FSApplication

SHARED_IMPL;

- (void)onInit {
    [super onInit];
    
    NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSArray* caches = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	   
    // 获得系统目录
    _dirBundle = [[NSBundle mainBundle].resourcePath copy];
    _dirCache = [caches.lastObject copy];
    _dirTmp = [NSTemporaryDirectory() copy];
    
    // 设置可读的目录
    self.pathRoot = dirs.lastObject;
}

- (void)onFin {
    ZERO_RELEASE(_dirBundle);
    ZERO_RELEASE(_dirCache);
    ZERO_RELEASE(_dirTmp);
    [super onFin];
}

- (NSString*)pathBundle:(NSString *)name {
    return [_dirBundle stringByAppendingFormat:@"/%@", name];
}

- (NSString*)pathWritable:(NSString*)name {
    return [self.pathRoot stringByAppendingFormat:@"/%@", name];
}

- (NSString*)pathCache:(NSString *)name {
    return [_dirCache stringByAppendingFormat:@"/%@", name];
}

- (NSString*)dirCache:(NSString*)name {
    NSString* ret = [_dirCache stringByAppendingFormat:@"/%@/", name];
    [self mkdir:ret];
    return ret;
}

- (NSString*)pathTmp:(NSString *)name {
    return [_dirTmp stringByAppendingFormat:@"/%@", name];
}

- (NSString*)dirTmp:(NSString*)name {
    NSString* ret = [_dirTmp stringByAppendingFormat:@"/%@/", name];
    [self mkdir:ret];
    return ret;
}

- (NSString*)pathTemporary {
    NSString* sufx = [NSString stringWithFormat:@"/~fs~ext_%d_%ld_~", (int)time(NULL), clock()];
    return [_dirTmp stringByAppendingString:sufx];
}

@end

@interface FileSessionHandle ()

// 请求的地址
@property (nonatomic, retain) NSURL *url;

// 如果是从远端现在的文件，最终将保存到这个路径的文件
@property (nonatomic, retain) NSURL *output;

// 下载器
@property (nonatomic, retain) NSURLConnectionExt *connect;

// 使得状态可以控制
@property (nonatomic, assign) NSWorkState state;

@end

@implementation FileSessionHandle

- (void)onInit {
    [super onInit];
}

- (void)onFin {
    ZERO_RELEASE(_url);
    ZERO_RELEASE(_output);
    ZERO_RELEASE(_connect);
    [super onFin];
}

- (NSURL*)localFile {
    if (_output)
        return _output;
    if (_url.isFileURL)
        return _url;
    return nil;
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalStart)
SIGNAL_ADD(kSignalDone)
SIGNAL_ADD(kSignalFailed)
SIGNAL_ADD(kSignalValueChanged)
SIGNALS_END

- (void)setConnect:(NSURLConnectionExt *)connect {
    if (_connect == connect)
        return;
    
    [_connect.signals disconnectToTarget:self];
    PROPERTY_RETAIN(_connect, connect);
    
    // 设置本地目录
    _connect.outputFile = _output;
    
    // 连接connect的信号
    [_connect.signals connect:kSignalStart withSelector:@selector(__fsh_start) ofTarget:self];
    [_connect.signals connect:kSignalDone withSelector:@selector(__fsh_done) ofTarget:self];
    [_connect.signals connect:kSignalFailed withSelector:@selector(__fsh_failed) ofTarget:self];
    [_connect.signals connect:kSignalValueChanged ofTarget:self];
}

- (void)setOutput:(NSURL *)output {
    PROPERTY_RETAIN(_output, output);
    _connect.outputFile = _output;
}

- (void)start {
    if (_connect) {
        [_connect start];
        return;
    }
    
    // 如果没有 connect，并且 url 为本地文件路径，则直接激发成功的消息
    if (_url.isFileURL == NO) {
        LOG("文件路径错误，不能启动本地文件下载");
        return;
    }
    
    // 发送成功的信号
    [self.signals emit:kSignalStart];
    [self.signals emit:kSignalValueChanged withResult:[NSPercentage Completed]];
    [self.signals emit:kSignalDone];
}

- (void)delayStart {
    [self performSelector:@selector(start) withObject:nil afterDelay:.1];
}

- (void)__fsh_start {
    _state = kNSWorkStateDoing;
    [self.signals emit:kSignalStart];
}

- (void)__fsh_done {
    _state = kNSWorkStateDone;
    [self.signals emit:kSignalDone];
}

- (void)__fsh_failed {
    _state = kNSWorkStateFailed;
    [self.signals emit:kSignalFailed];
}

@end

@interface FileSession ()

@property (nonatomic, readonly) NSMutableDictionary *workers;

@end

@implementation FileSession

SHARED_IMPL;

- (void)onInit {
    [super onInit];
    
    _workers = [NSMutableDictionary new];
    self.directory = [FSApplication shared].dirTmp;
}

- (void)onFin {
    ZERO_RELEASE(_workers);
    ZERO_RELEASE(_directory);
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalStart)
SIGNAL_ADD(kSignalFailed)
SIGNAL_ADD(kSignalDone)
SIGNAL_ADD(kSignalValueChanged)
SIGNALS_END

- (NSURL*)localFileForURL:(NSURL *)url {
    NSString* lf = [self.directory stringByAppendingFormat:@"%ld.%@", (long)url.hash, url.lastPathComponent];
    return [NSURL fileURLWithPath:lf isDirectory:YES];
}

- (FileSessionHandle*)fetch:(NSURL*)url {
    if (url == nil) {
        WARN("试图 fetch 一个为空的地址");
        return nil;
    }
    
    // 视图访问本地文件
    if (url.isFileURL) {
        FileSessionHandle* fsh = [FileSessionHandle temporary];
        fsh.url = url;
        [fsh delayStart];
        return fsh;
    }
    
    // 本地目标文件的地址
    NSURL* output = [self localFileForURL:url];
    
    // 判断本地文件是否存在
    // 如果本地文件存在，则直接使用本地下载好了的
    if ([[FSApplication shared] existsFile:output.filePath]) {
        FileSessionHandle* fsh = [FileSessionHandle temporary];
        fsh.url = output;
        fsh.state = kNSWorkStateDone;
        [fsh delayStart];
        return fsh;
    }
    
    // 开始下载流程
    FileSessionHandle* fsh = [_workers objectForKey:url];
    if (fsh != nil)
        return fsh;
    
    NSURLRequest* req = [NSURLRequest requestWithURL:url];
    fsh = [FileSessionHandle temporary];
    fsh.url = url;
    fsh.output = output;
    fsh.connect = [NSURLConnectionExt connectionWithRequest:req startImmediately:NO];
    // 绑定句柄
    [_workers setObject:fsh forKey:url];
    
    // 绑定后处理函数
    [fsh.signals connect:kSignalStart withSelector:@selector(__fs_started:) ofTarget:self];
    [fsh.signals connect:kSignalDone withSelector:@selector(__fs_fetch_failed:) ofTarget:self];
    [fsh.signals connect:kSignalFailed withSelector:@selector(__fs_fetch_failed:) ofTarget:self];
    [fsh.signals connect:kSignalValueChanged withSelector:@selector(__fs_fetching:) ofTarget:self];

    // 延迟一下启动下载
    [fsh delayStart];
    return fsh;
}

// 如果下载完成或下载失败，需要从worker队列中移除

- (void)__fs_started:(SSlot*)s {
    FileSessionHandle* fsh = (id)s.sender;
    [self.signals emit:kSignalStart withResult:fsh];
}

- (void)__fs_fetched:(SSlot*)s {
    FileSessionHandle* fsh = (id)s.sender;
    [self.signals emit:kSignalDone withResult:fsh];
    [self.workers removeObjectForKey:fsh.url];
}

- (void)__fs_fetch_failed:(SSlot*)s {
    FileSessionHandle* fsh = (id)s.sender;
    [self.signals emit:kSignalFailed withResult:fsh];
    [self.workers removeObjectForKey:fsh.url];
}

- (void)__fs_fetching:(SSlot*)s {
    FileSessionHandle* fsh = (id)s.sender;
    [self.signals emit:kSignalValueChanged withResult:fsh];
}

@end
